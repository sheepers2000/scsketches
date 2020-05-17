Server.local.plotTree;
(
SynthDef.new(\pulsey, {
	arg freq = 200, partials = 4, amp = 0.5, atk = 0.001, dk = 1, gate = 1, sus = 0.5, rls = 1;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rls, curve: -3), gate, doneAction: 2);
	sig = Pulse.ar(Rand(freq, freq * partials).round(freq), mul: amp) * env;
	Out.ar([0,1], sig);
}).add;
)

x = Synth.new(\pulsey, [\atk, 0.01, \dk, 1, \sus, 0.2, \amp: 0.2]);
x.set(\gate, 0);

Env.new([0.001, 1, 0.001], [1, 1], [-3,3]).plot;

(
x = {
	var sig, env;
	var freq;
	freq = SinOsc.kr(1);
	env = EnvGen.kr(Env.new([0.01, 1, 0.01], [4, 4], \exp), doneAction: 2);
	sig = Pulse.ar(440 * freq, mul: 0.2) * env;
	sig = Pan2.ar(sig, SinOsc.kr(10, 0, 0.5));
	Out.ar(0, sig);
}.play;
)

s.stop;

(
y = {
	var gate = 1, num = 10;
	var sig, env;
	env = EnvGen.kr(Env.asr(0.5, 1, 3), gate, doneAction: 2);
	sig = Splay.ar(PinkNoise.ar(Array.series(num, 0.2, 0))) * env;
	Out.ar(0, sig);
}.play;
)

(
y = {
	var gate = 1, num = 6;
	var sig, env;
	env = EnvGen.kr(Env.asr(0.5, 1, 3), gate, doneAction: 2);
	sig = Splay.ar(LFNoise0.ar(Array.series(num,200,10),0.3)) * env;
	Out.ar(0, sig);
}.play;
)