(
SynthDef.new(\gloom, {
	arg freq = 80, amp = 1, nharm = 10, atk = 0.5, dk = 1, sus = 0.75, rel = 2,
	gate = 1, detune = 10, pan = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel), gate, doneAction:2);
	sig = Blip.ar(
		freq *
		LFNoise1.kr(0.2!16).bipolar(detune.neg/100, detune/100).midiratio,
		nharm
	);
	sig = sig *
	LFNoise1.kr(0.2!16, 0.5).exprange(0.3,1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

k = Synth.new(\gloom);
k.set(\detune, 20, \nharm, 11);
k.set(\gate, 0);

(
Pdef(\gloompat,
	Pbind(
		\instrument, \gloom,
		\note, Pseq([0, 7, 14, 21, 28], inf),
		\nharm, Pshuf(Array.series(5,6,1),inf),
		\dur, 1/4,
		\octave, 3,
		\rel, 5
	);
).play;
)