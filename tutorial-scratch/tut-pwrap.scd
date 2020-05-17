(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(1/10, 1, inf),
	\midinote, 10,
 	\atk, Pwhite(0.05, 1.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.5, 0.5, inf),
	\harmonic, Pexprand(1, 80).round(2).trace
).play;
)

(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

(
Pbind(
	\note, Pwrap(Pseries(0, 2, inf), 0, 6),
	\dur, 1/8,
	\harmonic, 4
).trace.play;
)