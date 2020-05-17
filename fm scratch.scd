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
	//env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve), gate, doneAction: 2);
	//menv = EnvGen.kr(Env.adsr(matk, mdk, msus, mrel, mcurve), gate, doneAction: 0);
	env = EnvGen.kr(Env.perc(atk, dk, curve: curve), doneAction: 2);
	menv = EnvGen.kr(Env.perc(matk, mdk, curve: mcurve), doneAction: 0);
	//fm
	mod = SinOsc.ar(freq * mratio *
		LFNoise1.kr(mdtrate, mdetune).midiratio, mul: mamp) * menv;
	car = SinOsc.ar(freq *
		LFNoise1.kr(dtrate, detune).midiratio
		* cratio + mod, phase);
	car = MoogFF.ar(car, ffreq, fres) * env * amp * 0.5; //filter bc why not
	car = Pan2.ar(car, pan);
	Out.ar(out, car);
}).add;
)

(
Pbindef(\bass,
	\instrument, \fm,
	\octave, 3,
	\note, Pseq([0, 5], inf),
	\dur, 1/4,
	\amp, 0.5,
	\dk, 0.5,
	\mdk, 0.3,
	\ctranspose, Pstutter(16, Pseries(0, 7, inf)).wrap(0, 11),
	\mratio, Pseq([1, 1, 1, Pwhite(0.5, 2, 5).round(0.5)], inf)
).quant = 2;
)
Pbindef(\bass).play(t);

(
Pbindef(\arpeggio,
	\instrument, \fm,
	\octave, 5,
	\note, Pseq([Pshuf(Scale.minorPentatonic.degrees, 6)], inf),
	\ctranspose, Pstutter(32, Pseries(0, -5, inf)).wrap(0, 11),
	\dur, 1/8,
	\amp, 0.5,
	\mratio, Pwhite(1, 1),'
	\cratio, Pwhite(1, 1),
	\dk, 0.5
).quant = 2
)
Pbindef(\arpeggio).play(t);
Pbindef(\bass, \dk, 0.2, \dur, 1/8, \cratio, Pwhite(0.5, 0.6, inf), \mratio, Pwhite(0.7, 1.3, inf), \mamp, 400, \amp, 0.01);
(
Pbindef(\arpeggio,
	\dk, Pwhite(1.0, 2.0, inf),
	\octave, Pseq([[5, 6]], inf),
	\ctranspose, 0,
	\amp, Pseries(0.3, -0.03, 10),
	\mratio, Pwhite(1, 4),
	\cratio, Pwhite(0.25, 1).round(0.25)
)
)

(
Pbindef(\arpeggio,
	\dk, 10,
	\dur, 2,
	\mdk, 5,
)
)



(
Pbindef(\topnotes,
	\instrument, \fm,
	\note, Pseq([3, 5, 7, 9], inf),
	\dur, 1/4,
	\mratio, Pwhite(5.0, 7.0),
	\cratio, Pwhite(0.98, 1.02),
	\dk, 2,
	\mdk, 1,
	\octave, 5,
	\amp, Pseries(0.2, -0.02, 10),
	\mamp, 100
).quant = 2;
)

Pbindef(\topnotes).play(t);

Pbindef(\bass).play(t); Pbindef(\arpeggio).play(t);

