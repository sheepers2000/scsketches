(
t = TempoClock(130/120).permanent_(true);
s.options.memSize_(2.pow(20));
s.options.memSize;
s.boot;
)

(

(
/*
SynthDef(\fm, {
	arg freq = 220, amp = 1, out = 0, send, sendAmt = 1, pan = 0, phase = 0, gate = 1,
	mratio = 1, cratio = 1, mamp = 400,
	atk = 0.01, dk = 2, sus = 0, rel = 0.1, curve = -4, detune = 0, dtrate = 4,
	matk = 0.01, mdk = 2, msus = 0, mrel = 0.1, mcurve = -4, mdetune = 0, mdtrate = 4,
	fatk = 0.01, fdk = 0.01, fsus = 1, frel = 1, fcurve = -7, ffreq = 6000, fres = 2;
	var car, mod, env, menv, fenv;
	//envelopes
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve), gate, doneAction: 2);
	menv = EnvGen.kr(Env.adsr(matk, mdk, msus, mrel, mcurve), gate, doneAction: 0);
	fenv = EnvGen.kr(Env.adsr(fatk, fdk, fsus, frel, curve: fcurve), gate, doneAction: 0);
	//fm
	mod = SinOsc.ar(freq * mratio *
		{ LFNoise1.kr(mdtrate,
			{ LFNoise1.kr(1, mdetune) }!2
	).midiratio }, mul: mamp) * menv;
	car = SinOsc.ar((freq *
		LFNoise1.kr(dtrate,
			{ LFNoise1.kr(1, detune) }!2
		).midiratio
		* cratio) + mod);
	car = MoogFF.ar(car, ffreq * fenv, fres) * env * amp * 0.5; //filter bc why not
	car = Balance2.ar(car[0], car[1], pan);
	Out.ar(out, car);
	Out.ar(send, car * sendAmt);
}).add;
);
*/

SynthDef(\fm, {
	arg freq = 220, amp = 1, out = 0, send, sendAmt = 1, pan = 0, phase = 0, gate = 1,
	mratio = 1, cratio = 1, mamp = 400,
	atk = 0.01, dk = 2, sus = 0, rel = 0.1, curve = -4, detune = 0, dtrate = 4,
	matk = 0.01, mdk = 2, msus = 0, mrel = 0.1, mcurve = -4, mdetune = 0, mdtrate = 4,
	fatk = 0.01, fdk = 0.01, fsus = 1, frel = 10, fcurve = -7, ffreq = 6000, fres = 2;
	var car, mod, env, menv, fenv;
	//envelopes
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve), gate, doneAction: 2);
	menv = EnvGen.kr(Env.adsr(matk, mdk, msus, mrel, mcurve), gate, doneAction: 0);
	fenv = EnvGen.kr(Env.adsr(fatk, fdk, fsus, frel, curve: fcurve), gate, doneAction: 0);
	//fm
	mod = SinOsc.ar(freq * mratio *
		{ LFNoise1.kr(mdtrate,
			{ LFNoise1.kr(1, mdetune) }!2
	).midiratio }, mul: mamp) * menv;
	car = SinOsc.ar((freq *
		LFNoise1.kr(dtrate,
			{ LFNoise1.kr(1, detune) }!2
		).midiratio
		* cratio) + mod);
	car = LPF.ar(car, ffreq * (fenv + 0.05)) * env * amp * 0.5; //filter bc why not
	car = Balance2.ar(car[0], car[1], pan);
	Out.ar(out, car);
	Out.ar(send, car * sendAmt);
}).add;
);

(
SynthDef(\delay, {
	arg in, out = 0, maxTime = 3, time = 0.5, decay = 5, amp = 1;
	var sig;
	sig = CombL.ar(In.ar(in, 2), maxTime, time, decay)!2;
	sig = LeakDC.ar(sig) * amp;
	Out.ar(out, sig);
}).add;
);

(
SynthDef(\reverb, {
	arg in, out = 0, maxTime = 1, time = 0.5, decay = 1, return = 1, spread = 1,
	dif = 100, wobble = 0.1;
	var sig;
	sig = CombL.ar(In.ar(in, 2), maxTime, { LFNoise1.kr(wobble).exprange(time/dif, time) }!32, decay);
	sig = Splay.ar(sig, spread);
	sig = Balance2.ar(sig[0], sig[1], 0) * 0.8;
	sig = LeakDC.ar(sig) * return;
	Out.ar(out, sig);
}).add;
);

(
SynthDef(\ringmod, {
	arg in, out = 0, modfreq = 600, modphase = 0, modamp = 400, lfo = 1/16;
	var sig;
	sig = In.ar(in, 2) * Pulse.ar(modfreq);
	Out.ar(out, sig);
}).add;
);
)

(
~ringBus = Bus.audio(s, 2);
~delayBus = Bus.audio(s, 2);
~reverbBus = Bus.audio(s, 2);
)

(
~makeSynths = {
	s.bind({
		~reverb = Synth(\reverb, [\in, ~reverbBus], target: s, addAction: 'addToTail');
		~delay = Synth(\delay,	[\in, ~delayBus, \decay, 30, \time, t.tempo], s, 'addToTail');
		~ringmod = Synth(\ringmod, [\in, ~ringBus], s, 'addToTail');
		~tempSynths = Group.new(s);
	});
}
);
ServerTree.removeAll
ServerTree.add(~makeSynths, s);

(
Pbindef(\bass,
	\instrument, \fm,
	\scale, Scale.minor,
	\degree, Ppatlace([Pseq([0, 0, 2], inf), Pseq([0, 0, 3, 0], inf)], inf),
	\dur, 1/4,
	\octave, 3,
	\mratio, Pseq([2, 2, 3], inf),
	\mamp, Pseq([100, 100, 200, 100], inf),
	\ffreq, Pseq([6000, 600, 600, 6000, 600], inf),
	\fres, Pseq([0, 0, 0, 1, 0, 0, 1], inf),
	\mdk, Pseq([2, 0.5, 0.5, 2, 1, 1], inf),
	\mtranspose, Pstutter(32, Pseq([0, -3], inf)),
	\send, ~reverbBus,
	\sendAmt, 0.1,
).quant = 4;
)
Pbindef(\bass, \degree, 0);
Pbindef(\bass).play(t);
Pbindef(\bass).stop;

(
Pbindef(\climb,
	\instrument, \fm,
	\mratio, Pseq((3..5), inf),
	\scale, Scale.minorPentatonic,
	\cratio, 1,
	\octave, 6,
	\dur, 1/2,
	\dk, 4,
	\rel, 2,
	\mdk, 0.5,
	\amp, Pseq([0.15, 0.05, 0.05], inf),
	\degree, Pslide((0..4), inf),
	\legato, 2,
	\send, ~reverbBus,
	\mamp, 100,
	\mtranspose, Pstutter(16, Pseq([0, -1, -2], inf)),
	\fres, 0.5,
	\ffreq, 3000,
	\pan, Pwhite(-1.0, 1.0)
).quant = 4;
)
Pbindef(\climb).play(t);
Pbindef(\climb).stop;

(
Pbindef(\arp,
	\instrument, \fm,
	\scale, Scale.minor,
	\dur, 1/4,
	\dk, 3,
	\mdk, 0.5,
	\legato, 0.9,
	\rel, 1,
	\octave, 4,
	\mratio, Prand([2, 4], inf),
	\mamp, 100,
	\ffreq, 1600,
	\fatk, 0.01,
	\fdk, 1,
	\degree, Pseq([2, 4, 6, 8, 10, 12b], inf),
	\mtranspose, Pstutter(32, Pseq([0, -2, -1], inf)),
	\amp, Pseq([0.2, 0.05, 0.1, 0.05], inf),
	\send, ~reverbBus,
	\sendAmt, 1,
).quant = 4;
)
Pbindef(\arp).play(t);
Pbindef(\arp).stop;


(
Pbindef(\chord,
	\instrument, \fm,
	\degree, Pseq([(0, 2..6), [-3, -1, 1]], inf),
	\dur, 15/4,
	\octave, 5,
	\ffreq, Pseq((1000, 1300..2000), inf),
	\fres, 0,
	\mratio, Pseq([(2..3), (2..4), (2..5)], inf),
	\cratio, 1,
	\amp, 0.05,
	\atk, 0.3,
	\matk, 0.5,
	\legato, 0.8,
	\rel, 2,
	\curve: -2,
	\send, ~reverbBus,
	\sendAmt, 0.05
).quant = 4;
)
Pbindef(\chord).play(t);
Pbindef(\chord).stop;

(
Pbindef(\pad,
	\instrument, \fm,
	\atk, 4,
	\sus, 1,
	\rel, 4,
	\mratio, (4..9),
	\cratio, (2..5),
	\fres, 0,
	\ffreq, 1000,
	\octave, 4,
	\degree, Pseq([(0, 2..6), (1, 3..7)], inf),
	\dur, 8,
	\amp, 0.04,
	\detune, 0.1,
	\mdetune, 0.4,
	\fatk, 4,
	\fdk, 0,
	\fsus, 1,
	\send, ~reverbBus,
).quant = 8;
)
Pbindef(\pad).play(t);
Pbindef(\pad).stop;