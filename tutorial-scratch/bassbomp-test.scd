
(
SynthDef(\bassbomp, {
	arg freq = 110, amp = 1, out = 0, pan = 0, gate = 1,
	atk = 0.01, dk = 0.5, sus = 0, rel = 0.1,
	detune = 0.01;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel), gate, doneAction: 2);
	sig = SinOsc.ar(freq * LFNoise1.kr({
		LFNoise1.kr(4).range(0.1,1.0)}!2, detune).midiratio, 0, amp/2);
	sig = sig * amp * env;
	Out.ar(out, sig);
}).add;

SynthDef(\reslpf, {
	arg freq = 300, res = 1, mix = 0.5, in = 10, out = 0;
	var dry, wet;
	dry = SoundIn.ar(in, 2) * 1-mix;
	wet = RLPF.ar(SoundIn.ar(in, 1)!2, freq, res);
	Out.ar(out, wet);
}).add;
)


~filterBus = Bus.new;
(
f = Synth.tail(s, \reslpf, [
	\in, 0,
	\out, 0
]);
)

f.set(\freq, 1000, \res, 0.1)
(
x = Synth(\bassbomp, [
	\gate, 1,
	\out, ~filterBus,
	\sus, 0.5
]);
)
