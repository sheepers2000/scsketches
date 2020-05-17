t = TempoClock(110/120).permanent_(true);

(
SynthDef(\fm, {
	arg freq = 220, amp = 1, out = 0, pan = 0, phase = 0, gate = 1,
	mratio = 1, cratio = 1, mamp = 200,
	atk = 0.01, dk = 2, sus = 0, rel = 0.1, curve = -4, detune = 0, dtrate = 4,
	matk = 0.01, mdk = 2, msus = 0, mrel = 0.1, mcurve = -4, mdetune = 0, mdtrate = 4,
	ffreq = 6000, fres = 2;
	var car, mod, env, menv;
	//envelopes
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve), gate, doneAction: 2);
	menv = EnvGen.kr(Env.adsr(matk, mdk, msus, mrel, mcurve), gate, doneAction: 0);
	//env = EnvGen.kr(Env.perc(atk, dk, curve: curve), doneAction: 2);
	//menv = EnvGen.kr(Env.perc(matk, mdk, curve: mcurve), doneAction: 0);
	//fm
	mod = SinOsc.ar(freq * mratio *
		{ LFNoise1.kr(mdtrate,
			{ LFNoise1.kr(1, mdetune) }!2
	).midiratio }, mul: mamp) * menv;
	car = SinOsc.ar(freq *
		LFNoise1.kr(dtrate,
			{ LFNoise1.kr(1, detune) }!2
		).midiratio
		* cratio + mod, phase);
	car = MoogFF.ar(car, ffreq, fres) * env * amp * 0.5; //filter bc why not
	car = Balance2.ar(car[0], car[1], pan);
	Out.ar(out, car);
}).add;
)

(
PmonoArtic(\fm,
	\mratio, Pgeom(4, 0.9998, 25000),
	\octave, 4,
	\cratio, Pgeom(1, 1.00002, 25000),
	\dur, 1/100,
	\legato, 2,
	\sus, 1,
	\msus, 1,
	\detune, 0.2,
	\mdetune, 0.2,
	\mamp, Pgeom(100, 1.0007, 25000),
	\ffreq, 4000,
).trace.play;
)