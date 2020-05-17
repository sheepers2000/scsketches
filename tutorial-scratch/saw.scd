(
SynthDef.new(\saw, {
	arg freq = 440, amp = 0.5, atk = 0.001, dk = 1, gate = 1, detune = 5;
	var sum = 0, temp, env, num = 20;
	env = EnvGen.kr(Env.perc(atk,dk), gate, doneAction: 2);
	detune = 1 + (detune / 1000);
	num.do{ |i|
		temp = VarSaw.ar(freq * {Rand(detune.reciprocal, detune)}!2 * (i + 1),
			{Rand(0.0,1.0)}!2,
			{ExpRand(0.2, 0.5)}!2,
			1/(i + 1)
		);
		sum = sum + temp;
	};
	sum = sum * amp * 2 * (1/num) * env;
	Out.ar(0, sum);
}).add;
)
x = Synth.new(\saw, [\dk, 3, \num, 20]);
Tuning.directory;
Scale.directory;
(
Pbind(
	\instrument, \saw,
	\scale, Scale.minor(),
	\degree, Pwrap(Pseries(0, 2, inf), -7, 7)-14,
	\dur, 1,
	\dk, 3,
	\amp, 1,
	\detune, 5
).play;
)

1.02.reciprocal