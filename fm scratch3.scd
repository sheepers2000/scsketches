(
t = TempoClock(110/120).permanent_(true);
s.options.memSize_(2.pow(20));
s.options.memSize;
s.boot;
)

(

(
SynthDef(\fm, {
	arg freq = 220, amp = 1, out = 0, send, sendAmt = 1, pan = 0, phase = 0, gate = 1,
	mratio = 1, cratio = 1, mamp = 400,
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
	car = SinOsc.ar((freq *
		LFNoise1.kr(dtrate,
			{ LFNoise1.kr(1, detune) }!2
		).midiratio
		* cratio) + mod);
	car = MoogFF.ar(car, ffreq, fres) * env * amp * 0.5; //filter bc why not
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
	arg in, out = 0, maxTime = 3, time = 0.5, decay = 5, return = 1, spread = 1,
	dif = 100;
	var sig;
	sig = CombL.ar(In.ar(in, 2), maxTime, {LFNoise1.kr(1).range(time-(time/dif), time+(time/dif))}!32, decay);
	sig = Splay.ar(sig, spread);
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
	\dk, 1,
	\mdk, 0.3,
	\octave, 3,
	\dur, 1/4,
	\ffreq, 2000,
	\fres, 0,
	\mratio, Pseq([1, 2, 3, 2, 1, 2, 3], inf),
	\cratio, 1,
	\legato, 1,
	\mdetune, 0.00,
	\mamp, Pseq([100, 110, 120, 110], inf),
	\send, ~reverbBus,
	\sendAmt, 0.1
).quant = 4;
)
Pbindef(\bass).play(t);
Pbindef(\bass, \mamp, Pseq([100, 200, 20000, 200, 200, 100, 20000, 10000], inf));
Pbindef(\bass).stop;

(
Pbindef(\snare,
	\instrument, \fm,
	\mamp, 1000000,
	\dk, 0.2,
	\mratio, [2, 10, 100],
	\dur, Pseq((1/8)!4++[Rest(1), 1], inf),
	\out, 0,
	\amp, 0.1,
	\sendAmt, 0.1,
	\send, ~reverbBus,
	\stretch, 1
).quant = 4;
)
Pbindef(\snare).play(t);
Pbindef(\snare).clear

~tempSynths = Group.new(s);

( //cicada chorus
40.do({ |i|
	Synth(\fm, [\atk, 10, \dk, 10, \amp, 1/64, \detune, 0.5, \freq, 36.midicps * (i + 1),
		\sus, 0.5, \matk, 1, \mdk, 1, \rel, 10,
		\msus, 0.2, \mratio, 4 * (i + 2), \mdetune, 0.3, \mamp, 300, \send, ~reverbBus
	], ~tempSynths);
})
)

~tempSynths.set(\gate, 0); //nuke em bbs

(
Pbindef(\powerchord,
	\instrument, \fm,
	\dk, 4,
	\mdk, 2,
	\msus, 0.5,
	\sus, 0.2,
	\rel, 2,
	\note, Pseq([[-5, 0, 7, 14]], inf),
	\dur, 8,
	\mratio, [2, 3, 2],
	\mamp, 600,
	\detune, 0.05,
	\legato, 1/2,
	\octave, 4,
	\ctranspose, Pseq([0, -5, -7], inf),
	\cratio, 1,
	\amp, 0.03,
	\send, ~ringBus,
	\sendAmt, 0.3,
	\out, 0
).quant = 4;
)
Pbindef(\powerchord).play(t);
Pbindef(\powerchord).stop;

(
Pbindef(\bells,
	\instrument, \fm,
	\mratio, Pwhite(5, 7),
	\note, Pseq([7, 3, \, \, \, 7], inf),
	\dur, Pseq([1/2, 1/2, 1, 4], inf),
	\legato, 2,
	\dk, 10,
	\mdk, 2,
	\stretch, 4,
	\rel, 2,
	\ctranspose, Pstutter(6, Pseries(0, -5, inf).wrap(-11, 0)),
	\out, nil,
	\send, ~delayBus,
	\sendAmt, 0.5
).quant = 4;
)
Pbindef(\bells).play(t);
Pbindef(\bells).stop;

(
Pbindef(\tinks,
	\instrument, \fm,
	\cratio, 7,
	\mratio, 13,
	\dk, 0.2,
	\note, Pseq([\, 12, 7, 10, 7, \], inf),
	\octave, 6,
	\dur, Pseq([1 + 1/8, 1/8, 1/8, 1/8, 1/8, 4], inf),
	\mamp, 1000000,
	\pan, Pwhite(-0.5, 0.5),
	\send, ~reverbBus,
	\sendAmt, 0.3,
	\amp, 0.05
).quant = 4;
)
Pbindef(\tinks).play(t);
Pbindef(\tinks).stop;

(
Pbindef(\melody,
	\instrument, \fm,
	\note, Pseq([\, 3, 5, 0, \, 2, 3, -1,
		\, 3, 5, 3, \, 2, 3, -6,
		\, 2, 3, -6, \, -6, -5, 0], inf),
	\atk, 0.5,
	\dur, Pseq([2, 1/2, 1/2, 1, 2, 1/2, 1/2, 1], inf),
	\stretch, 2,
	\legato, 7/8,
	\dk, 4,
	\mdk, 2,
	\mratio, Pseq([2, 2.5, 3, 3.5, 4], inf),
	\send, ~reverbBus
).quant = 8;
)
Pbindef(\melody).play(t);
Pbindef(\melody).stop;

(
Pbindef(\pad,
	\instrument, \fm,
	\atk, 3,
	\dk, 8,
	\rel, 4,
	\matk, 3,
	\sus, 0.7,
	\msus, 0,
	\mdk, 4,
	\mratio, Pwhite(3, 7),
	\cratio, 1,
	\octave, 4,
	\mdetune, 0.1,
	\detune, 0.1,
	\note, Pseq([[3, 7, 12]], inf),
	\dur, 16,
	\ctranspose, Pseq([0, -2, -4, -5], inf),
	\legato, 0.5,
	\send, ~reverbBus,
	\out, nil
).quant = 16;
)
Pbindef(\pad).play(t);
Pbindef(\pad).stop;
