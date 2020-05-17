
(
SynthDef(\fm, {
	arg freq = 220, amp = 1, out = 0, pan = 0, phase = 0, gate = 1,
	mratio = 1, cratio = 1, mamp = 200,
	atk = 0.01, dk = 2, sus = 0, rel = 0.1, curve = -4, detune = 0, dtrate = 4,
	matk = 0.01, mdk = 2, msus = 0, mrel = 0.1, mcurve = -4, mdetune = 0, mdtrate = 4,
	ffreq = 6000, fres = 2;
	var car, mod, env, menv;
	//envelopes
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve), doneAction: 2);
	menv = EnvGen.kr(Env.adsr(matk, mdk, msus, mrel, mcurve), doneAction: 0);
	//fm
	mod = SinOsc.ar(freq * mratio *
		LFNoise1.kr(mdtrate, mdetune).midiratio, mul: mamp) * menv;
	car = SinOsc.ar(freq *
		LFNoise1.kr(dtrate, detune).midiratio
		* cratio + mod, phase);
	car = MoogFF.ar(car, ffreq, fres) * env * amp * 0.1; //filter bc why not
	car = Pan2.ar(car, pan);
	Out.ar(out, car);
}).add;

SynthDef.new(\bass, {
	arg freq = 110, amp = 1, gate = 1, mix = 0.2, detune = 0.005, dtrate = 4,
	atk = 0.01, dk = 2, sus = 0, rel = 0.1,
	ffreq = 880, fres = 2;
	var sig, env;
	env = EnvGen.ar(Env.adsr(atk, dk, sus, rel), gate, doneAction: 2);
	sig = (SinOsc.ar(Vibrato.kr(freq, dtrate, detune, 0.3, 0.5)) * (1-mix)) +
		(Pulse.ar(Vibrato.kr(freq, dtrate, detune, 0.3, 0.5)) * mix);
	sig = MoogFF.ar(sig, ffreq, fres);
	sig = sig * env * amp;
	sig = Pan2.ar(sig);
	Out.ar(0,sig);
}).add;
)

Synth(\bass)