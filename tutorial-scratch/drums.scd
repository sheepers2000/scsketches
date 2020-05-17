s.quit;
s.boot;
{ Klang.ar(`[ {exprand(400, 2000)}.dup(16), {exprand(0.5,1)}.dup(16), nil ], 1, 0) * 0.04 }.scope(1);

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
	//let the snares ring out longer
	noiseEnv = EnvGen.kr(Env.perc(atk * 10, dk * 2), gate, doneAction: 2);
	sig = (Pulse.ar(freq, color, 1 - noise) * fundEnv) + (WhiteNoise.ar(noise, 0) * noiseEnv) * amp;
	sig = Pan2.ar(sig);
	Out.ar(0, sig);
}).add;
)



k = Synth.new(\kick);
s = Synth.new(\snare, [\color, 0.5, \freq, 200, \noise, 0.5, \dk, 0.2]);

(
a = Pbind(
	\instrument, \kick,
	\freq, 60,
	\dur, 1/8
);
b = Pbind(
	\instrument, \snare,
	\freq, Pseq([\, 200], inf),
	\dur, 1/8,
	\dk, 0.15
);
)

Ppar([a, b], inf).play;

