(
SynthDef.new(\kick, {
	arg freq = 60, amp = 0.75, gate = 1, noise = 0.25, atk = 0.001, dk = 0.1;
	var sig, env;
	env = EnvGen.kr(Env.perc(atk, dk, curve: -5.0), gate, doneAction: 2);
	sig = SinOsc.ar(freq) + PinkNoise.ar(noise, 0) * env * amp;
	sig = Pan2.ar(sig);
	Out.ar(0, sig);
}).add;

SynthDef.new(\snare, {
	arg freq = 200, amp = 0.5, gate = 1, noise = 0.5, color = 0.5, atk = 0.001, dk = 0.1;
	var sig, fundEnv, noiseEnv;
	fundEnv = EnvGen.kr(Env.perc(atk, 0.1), gate, doneAction: 0);
	noiseEnv = EnvGen.kr(Env.perc(atk * 10, dk * 2), gate, doneAction: 2); //let snares ring longer
	sig = (Pulse.ar(freq, color, 1 - noise) * fundEnv) + (WhiteNoise.ar(noise, 0) * noiseEnv) * amp;
	sig = Pan2.ar(sig);
	Out.ar(0, sig);
}).add;

SynthDef.new(\pizz, {
	arg freq = 440, amp = 0.5, gate = 1;
	var sig, env;
	env = EnvGen.ar(Env.adsr(0.01, 0.3, 0.5, 0.5), gate, doneAction: 2);
	sig = Pulse.ar(freq, 0.5, amp) * env;
	sig = FreeVerb.ar(sig, 0.5, 0.9, 0.3);
	sig = Pan2.ar(sig);
	Out.ar(0,sig);
}).add;

SynthDef.new(\bass, {
	arg freq = 440, amp = 1, gate = 1, mix = 0.2;
	var sig, env;
	env = EnvGen.ar(Env.adsr(0.01, 0.5, 0.5, 0.1), gate, doneAction: 2);
	sig = (SinOsc.ar(freq) * (1-mix)) + (Pulse.ar(freq) * mix) * env * amp *0.9;
	sig = Pan2.ar(sig);
	Out.ar(0,sig);
}).add;

SynthDef.new(\guitar, {
	arg freq = 220, amp = 1, gate = 1, atk = 0.001, dk = 10, sus = 0.01,
	rel = 0.1, color = 0.5, detune = 7, out = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve: -10.0), gate, doneAction: 2);
	detune = 1 + (detune / 1000);
	sig = Mix.new(VarSaw.ar([freq, freq * 2, freq * 3, freq * 4, freq * 6] * Rand(detune.reciprocal, detune), Rand(0.0, 0.5), color, [1, 0.8, 0.7, 0.2, 0.6]));
	sig = sig.squared.softclip(0.5) * amp * 0.3 * env;
	sig = Pan2.ar(sig);
	Out.ar(out, sig);
}).add;
)
k = Synth.new(\guitar, [\freq, ]);
k.free;

(
var kicknotes, kickdurs, snarenotes, snaredurs, bassnotes, bassdurs, guitnotes, guitdurs;
kickdurs = [1/8, 1/8, 1/4];
kicknotes = [60, 60, \];
~kick = Pbind(
	\instrument, \kick,
	\freq, Pseq(kicknotes, inf),
	\dur, Pseq(kickdurs, inf),
	\db, -10
);
snaredurs = [1/4];
snarenotes = [\, 200];
~snare = Pbind(
	\instrument, \snare,
	\freq, Pseq(snarenotes, inf),
	\dur, Pseq(snaredurs, inf),
	\db, -10,
	\dk, 0.15
);
bassnotes = Array.series(8, 0, 0) ++ [6, 5, 3];
bassdurs = Array.series(8, 1/8, 0) ++ [3/8, 3/8, 1/4];
~bass = Pbind(
	\instrument, \bass,
	\note, Pseq(bassnotes, inf),
	\dur, Pseq(bassdurs, inf),
	\octave, 3,
	\db, -10
);
guitnotes = bassnotes.at([7, 8, 9, 10]) +.t [0, 7, 12];
guitdurs = [1, 3/8, 3/8, 2/8];
~guit = Pbind(
	\instrument, \guitar,
	\note, Pseq(guitnotes, inf),
	\dur, Pseq(guitdurs, inf),
	\db, -10,
	\octave, 4
);
~lead = Pbind(
	\instrument, \pizz,
	\scale, Scale.harmonicMinor,
	\degree, Prand(Array.series(14, 0, 1), inf),
	\dur, Pwrand([1/16, 1/8, 1/4] * 2, [1/2, 3/8, 1/8], inf),
	\db, -10
);
)
Ppar([~snare, ~kick, ~bass, ~guit, ~lead], inf).play;

(Array.series(8, 0, 0) +.t [0, 7]).postln;


