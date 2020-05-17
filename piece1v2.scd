(
//handy defs for the file go here
~paths = File.getcwd+/+"samples";
~out = 0;
~revBus = Bus.audio(s, 2);
t = TempoClock(107/120).permanent_(true);

~makeBuffers = {
	~bufs = Dictionary.new;
	PathName(~paths+/+"drums").entries.do {
		arg subfolder;
		subfolder.postln;
		~paths.postln;
		~bufs.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size, { |i|
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};

~makeNodes = {
	s.bind({
		~maing = Group.new;
		~revg = Group.after(~maing);
		~reverb = Synth.tail(~revg, \reverb, [
			\in, ~revBus,
			\size, 50,
			\time, 2,
			\damp, 0.8,
			\wet, 0.2,
			\ef, 0.3,
			\dry, 1
		]);
	});
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};
)

(
ServerBoot.add(~makeBuffers);
ServerQuit.add(~cleanup);
)

(
s.waitForBoot({

	s.sync;

	SynthDef(\reverb, {
		arg size = 10, in = 10, out = 0, damp = 0.8, time = 3, dry = 1,
		wet = 0.1, ef = 0.05, spread = 15;
		var sig;
		sig = GVerb.ar(In.ar(in, 2), size, time, damp, 1, spread, dry, ef, wet);
		Out.ar(out, sig);
	}).add;

	SynthDef.new(\playbuf, {
		arg buf, amp = 1, pan = 0, out = 0, rate = 1,
		atk = 0.001, rel = 4, curve = -4.0;
		var sig, env;
		env = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: 2);
		sig = PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf), doneAction: 2) * env * amp;
		sig = Pan2.ar(sig, pan);
		Out.ar(out, sig);
	}).add;

	SynthDef.new(\synthkick, {
		arg freq = 60, amp = 1, noise = 0.25, atk = 0.001, rel = 0.3, tone = 0.5;
		var sig, env, filtnoise;
		tone = tone.linexp(0.0, 1.0, 40, 10000);
		filtnoise = LPF.ar(PinkNoise.ar(noise), tone);
		env = EnvGen.kr(Env.perc(atk, rel, curve: -5.0), doneAction: 2);
		sig = (SinOsc.ar(freq) + filtnoise) * env * amp;
		sig = Pan2.ar(sig);
		Out.ar(0, sig);
	}).add;

	SynthDef.new(\pulse, {
		arg freq = 220, detune = 0.1, width = 0.5, widthrange = 0.05, amp = 1, pan = 0,
		atk = 1.5, dk = 3, sus = 0.5, rel = 2,  gate = 1,
		ffreq = 880, fres = 0.7, fdetune = 10, fresdrift = 0,
		out = 0;
		var sig, env;
		env = EnvGen.kr(Env.adsr(atk, dk, sus, rel), gate, doneAction:2);
		sig = Pulse.ar(
			freq * LFNoise1.kr(
				{LFNoise1.kr(1).exprange(0.1,2)}!6,
				detune).midiratio,
			width * LFNoise1.kr(
				{LFNoise1.kr(4).exprange(0.1,1)}!6,
				widthrange).midiratio
		);
		sig = RLPF.ar(
			sig,
			ffreq * LFNoise1.kr(
				{LFNoise1.kr(1).exprange(0.1,2)}!6,
				fdetune
			).midiratio,
			fres * LFNoise1.kr(
				{LFNoise1.kr(2).exprange(0.1,2)}!6,
				fresdrift).midiratio
		);
		sig = Splay.ar(sig);
		sig = Balance2.ar(sig[0], sig[1], pan);
		sig = sig * env * amp * 0.8;
		Out.ar(out, sig);
	}).add;

	SynthDef(\fm, {
		arg freq = 220, amp = 1, out = 0, pan = 0, phase = 0, gate = 1,
		mratio = 1, cratio = 1, mamp = 200,
		atk = 0.01, dk = 2, sus = 0, rel = 0.1, curve = -4, detune = 0, dtrate = 4,
		matk = 0.01, mdk = 2, msus = 0, mrel = 0.1, mcurve = -4, mdetune = 0, mdtrate = 4,
		ffreq = 6000, fres = 2;
		var car, mod, env, menv;
		//envelopes
		// env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve), doneAction: 2);
		// menv = EnvGen.kr(Env.adsr(matk, mdk, msus, mrel, mcurve), doneAction: 0);
		env = EnvGen.kr(Env.perc(atk, dk, curve: curve), doneAction: 2);
		menv = EnvGen.kr(Env.perc(matk, mdk, curve: mcurve), doneAction: 2);
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

	SynthDef.new(\bass, {
		arg freq = 110, amp = 1, gate = 1, mix = 0.2, detune = 0.005, dtrate = 4,
		atk = 0.01, dk = 0.5, sus = 0.5, rel = 0.1,
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

	s.sync;

	ServerTree.add(~makeNodes);
	s.freeAll;
	s.sync;
});
)

(
~randamps = Pexprand(0.2,0.5,5);
~tomseq1 = Pseq([1, ~randamps, 1, ~randamps, 1, ~randamps, 1, ~randamps, 1,
		Pexprand(0.2, 0.5, 3), 1, Pexprand(0.2, 0.5, 3)], inf);
/*
Pbindef(\toms,
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\toms], inf),
	\dur, 1/8,
	\amp, ~tomseq1 + 0.7,
	\out, ~revBus,
	\pan, Pwhite(-0.3, 0.3)
);
*/

Pbindef(\toms,
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\toms], inf),
	\dur, 1/2,
	\amp, Pseq([1]++0.7!15, inf),
	\stretch, Pseq([Pgeom(1, 24/32, 32)]++[Pgeom((24/32).pow(31), 32/24, 32)], inf),
	\rate, Pseq([Pgeom(1, 7/8, 32)]++[Pgeom((7/8).pow(31), 8/7, 32)], inf),
	\out, ~revBus,
	\pan, Pwhite(-0.3, 0.3)
).quant = 4;

Pbindef(\topmel,
	\instrument, \fm,
	\note, Pseq([Pshuf([0, 5, 5, 7, 11, 12, 19, 17], 8)], inf),
	\dur, 1/8,
	\amp, ~tomseq1 /2 - 0.1,
	\mratio, Pwhite(2, 4).round,
	\detune, 0.2,
	\octave, Pseq([Pshuf([5,6,5,6,5,6], 64)], inf),
	\pan, Pwhite(0.0, 0.4),
	\out, ~revBus
).quant = 4;

Pbindef(\lowmel,
	\instrument, \fm,
	\octave, 4,
	\note, Pseq([Pshuf([0, -2, 3, 5, 7, 10], 8)], inf),
	\dur, 1/8,
	\amp, ~tomseq1 - 0.1,
	\dk, 0.7,
	\cratio, Pwhite(1, 3).round,
	\mratio, Pwhite(2, 4).round,
	\pan, Pwhite(-0.2, 0),
	\out, ~revBus
).quant = 4;

Pbindef(\bass,
	\instrument, \bass,
	\note, Pstutter(4, Pseq([0, 0, -5, -5], inf)),
	\dk, 2,
	\dur, 1,
	\amp, 0.7,
	\octave, 3,
	\mix, 0.3,
	\ffreq, 1000
).quant = 16;

Pbindef(\kik,
	\instrument, \synthkick,
	\freq, \default,
	\dur, 1/8,
	\amp, 0.8,
	\noise, 0.7,
	\tone, 0.6
).quant = 4;

Pbindef(\pad,
	\instrument, \pulse,
	\note, Pwrap(Pseries([0, 3, 7], 2), -7, 14),
	\dur, 8
).quant = 4;

)

(
Pbindef(\tomblast,
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\toms], inf),
	\dur, Pstutter(16, Pseq([Pseries(2, 1, 62).reciprocal]++[Pseries(64, -1, 62).reciprocal], inf)),
	\amp, Pseq([1]++0.7!15, inf),
	\stretch, 1,
	\rate, Pwhite(0.6, 1.4),
	\out, ~revBus,
	\pan, Pwhite(-0.3, 0.3)
).quant = 4;
)

Pbindef(\tomblast).play(t, quant: 4);
Pbindef(\tomblast).stop;
Pbindef(\pad, \amp, 0.15, \sus, 1, \atk, 15, \rel, 15, \octave, 3, \ffreq, Pexprand(500, 3000)).quant = 2;
Pbindef(\pad).play(t, quant: 4);
Pbindef(\pad).stop;
Pbindef(\toms).play(t, quant: 4);
Pbindef(\toms).stop
Pbindef(\topmel).play(t, quant: 4);
Pbindef(\topmel).stop;
Pbindef(\lowmel).play(t, quant: 4);
Pbindef(\lowmel).stop;
Pbindef(\bass).play(t, quant: 4);
Pbindef(\bass, \mix, 0.5, \ffreq, 1000, \octave, 3, \note, 0, \atk, 0.1, \dk, 1, \amp, 0.7);
Pbindef(\bass, \dur, 1).quant = 4;
Pbindef(\bass).stop;
Pbindef(\toms, \amp, Pseq([1, Pexprand(0.4, 0.7, 3)], inf) + 0.5).quant = 4;
Pbindef(\kik).play(t, quant: 4);
Pbindef(\kik).stop;
Pbindef(\bass).stop;