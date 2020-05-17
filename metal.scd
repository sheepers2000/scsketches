
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

SynthDef.new(\pia, {
	arg freq = 440, amp = 0.5, gate = 1;
	var sig, env;
	env = EnvGen.ar(Env.adsr(0.01, 0.5, 0.5, 0.5), gate, doneAction: 2);
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

m = Pbind(
	\instrument, \pia,
	\scale, Scale.minor,
	\degree, Pseq(
		[0, -3, 0, 3, 4, 2,
		-0.9, -3, -0.9, 3, 4, 2,
		-1, -4, -1, 2, 3, 1.1,
		-1, -4, -1, 2, -0.9, -3] + 4, inf),
	\dur, 1/4,
	\db, -20
);
a = Pbind(
	\instrument, \kick,
	\freq, 60,
	\dur, 1/4,
	\db, -5
);
b = Pbind(
	\instrument, \snare,
	\freq, Pseq([200, \, \], inf),
	\dur, 1/8,
	\dk, 0.15,
	\db, -15
);
c = Pbind(
	\instrument, \bass,
	\scale, Scale.minor,
	\degree, Pseq([0, 0, 0, -4, -4, -4, -0.9, -0.9, -3], inf),
	\dur, Pseq([1/8, 1/8, ((5/4) + (6/4) + (6/4)),
		1/8, 1/8, 2/4, 1/8, 1/8, 2/4], inf),
	\legato, 0.3,
	\octave, 3,
	\db, -5
);
t = TempoClock.new(150/120);
Ppar([a, b, c, m], inf).play(t);
)
[0,7]!3.postln

Scale.minor.degrees

(
k = Pbind(
	\instrument, \pia,
	\degree, Pseq([0, 2, 4], inf),
	\dur, 1/8
).play;
j = Pbind(
	\instrument, \bass,
	\degree, Pseq([0, -3], inf),
	\dur, 1/4,
	\octave, 3
).play;
)