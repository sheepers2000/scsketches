
(
SynthDef(\beeps, {
	arg freq = 1, phase = 0, width = 0.5, ffreq = 220, rq = 0.0001,
	out = 0, gate = 1, amp = 1,
	atk = 0.001, dk = 0.5, sus = 1, rel = 1, hp = 100;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel), gate, doneAction: 2);
	sig = Saw.ar(freq, 0.5);
	sig = BPF.ar(sig, ffreq, rq, 1/rq.sqrt);
	sig = HPF.ar(sig, hp);
	sig = sig * env * amp;
	Out.ar(out, sig!2)
}).add;
)

(
Pbind(
	\instrument, \beeps,
	\ffreq, Pseq([
		7,
		Pwrand(
			[ 4,  5,  8,  9, 10, 12, 14, \],
			[7, 7, 1, 10, 4, 6, 10, 10].normalizeSum,
			2),
		16,
		Pwrand(
			[7, 10, 11, 12, 14, 18, \],
			[4, 10, 1, 12, 14, 2, 10].normalizeSum,
			2),
		Prand([5,9])] + 60, inf).midicps,
	\dur, Pseq([Pshuf([1/4, 1/4, 1/2, 1/2, 1/2, 1, 1] , 4)], inf),
	\freq, 2,
	\rq, 0.001,
	\amp, 1,
	\legato, 1,
	\hp, 200,
	\sus, 0.5,
	\rel, 2
).play;
)