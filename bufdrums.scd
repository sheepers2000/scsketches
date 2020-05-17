(
//handy defs for the file go here
~paths = File.getcwd+/+"samples";
~out = 0;
~revBus = Bus.audio(s, 2);
~filterBus = Bus.audio(s, 2);

SynthDef(\reverb, {
	arg size = 10, in = 10, out = 0, damp = 0.8, time = 3, dry = 1,
	wet = 0.1, ef = 0.05, spread = 15;
	var sig;
	sig = GVerb.ar(In.ar(in, 2), size, time, damp, 1, spread, dry, ef, wet);
	Out.ar(out, sig);
}).add;

SynthDef(\lpf, {
	arg in = 0, freq = 200, out = 0, mix = 1;
	var dry, wet;
	dry = In.ar(in, 2);
	wet = LPF.ar(dry, freq, mix);
	Out.ar(out, (wet * mix) + (dry * (1 - mix)));
}).add;

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

~makeReverb = {
	~reverb = Synth.tail(s, \reverb, [
		\in, ~revBus,
		\size, 100,
		\time, 2,
		\damp, 0.8,
		\wet, 0.2,
		\ef, 0.3,
		\dry, 1
	]);
};

~makeFilter = {
	~filter = Synth.tail(s, \lpf, [
		\in, ~filterBus
	]);
};
)

(
ServerBoot.add(~makeBuffers);
ServerTree.add(~makeReverb);
ServerTree.add(~makeFilter);
)

s.boot;

~bufs[\hihatclosed][1].play;

(

SynthDef(\beeps, {
	arg freq = 1, phase = 0, width = 0.5, ffreq = 220, rq = 0.0001,
	out = 0, gate = 1, amp = 1,
	atk = 0.001, dk = 0.5, sus = 1, rel = 1, hp = 100;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel), gate, doneAction: 2);
	sig = Saw.ar(freq, 0.5);
	sig = BPF.ar(sig, ffreq, rq, 1/rq.sqrt);
	sig = HPF.ar(sig, hp);
	sig = sig * env * amp;
	Out.ar(out, sig!2)
}).add;

SynthDef(\trilead, {
	arg freq = 440, phase = 0, out = 0, amp = 1, pan = 0,
	atk = 0.01, dk = 0.5, sus = 0.5, rel = 0.5, gate = 1,
	lpffreq = 1000;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel), gate, doneAction: 2);
	sig = LFTri.ar(freq, phase);
	sig = LPF.ar(sig, lpffreq);
	sig = Pan2.ar(sig, pan) * env * amp * 0.3;
	Out.ar(out, sig);
}).add;

SynthDef.new(\bass, {
	arg freq = 440, amp = 1, gate = 1, mix = 0.2,
	atk = 0.01, dk = 0.5, sus = 0.5, rel = 0.1,
	ffreq = 440, fres = 0.5;
	var sig, env;
	env = EnvGen.ar(Env.adsr(atk, dk, sus, rel), gate, doneAction: 2);
	sig = (SinOsc.ar(freq) * (1-mix)) + (Pulse.ar(freq) * mix);
	sig = RLPF.ar(sig, ffreq, fres, 1/fres.sqrt);
	sig = sig * env * amp *0.9;
	sig = Pan2.ar(sig);
	Out.ar(0,sig);
}).add;

SynthDef(\geetar, {
	arg freq = 220, amp = 1, gate = 1, detune = 0.1, out = 0,
	atk = 0.01, dk = 10, sus = 0, rel = 0.01, curve = -10.0,
	fatk = 0.01, fdk = 4, fcurve = -10.0, fres = 1, ffreq = 4,
	dist = 1, vrate = 5, vdepth = 0.1;
	var sig, env, fenv, dt;
	dt = LFNoise1.kr(1, detune).midiratio;
	sig = Pulse.ar(freq * dt) + SyncSaw.ar(freq, freq * 3 * dt) + SinOsc.ar((freq / 2) * dt);
	sig = sig.clip2(dist) * dist.reciprocal;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve: curve), gate, doneAction: 2);
	fenv = EnvGen.kr(Env.perc(fatk, fdk, curve: fcurve), gate).exprange(0.1, 1.0);
	sig = Vibrato.ar(sig, vrate, vdepth, 0.3, 0.2);
	sig = BPF.ar(sig, freq * ffreq * fenv, fres) * env * amp;
	Out.ar(out, sig!2);
}).add;

SynthDef.new(\pulse, {
	arg freq = 220, detune = 0.1, width = 0.5, widthrange = 0.05, amp = 1, pan = 0,
	atk = 1, dk = 5, sus = 0.5, rel = 2,  gate = 1,
	ffreq = 880, fres = 0.7, fdetune = 10, fresdrift = 0,
	out = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel), gate, doneAction:2);
	sig = Pulse.ar(
		freq * LFNoise1.kr(
			{LFNoise1.kr(1).exprange(0.1,2)}!4,
			detune).midiratio,
		width * LFNoise1.kr(
			{LFNoise1.kr(4).exprange(0.1,1)}!4,
			widthrange).midiratio
		);
	sig = RLPF.ar(
		sig,
		ffreq * LFNoise1.kr(
			{LFNoise1.kr(1).exprange(0.1,2)}!4,
			fdetune
		).midiratio,
		fres * LFNoise1.kr(
			{LFNoise1.kr(2).exprange(0.1,2)}!4,
			fresdrift).midiratio
	);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

//more bassy than the sample
SynthDef.new(\synthkick, {
	arg freq = 60, amp = 1, noise = 0.25, atk = 0.001, rel = 0.3, tone = 600;
	var sig, env, filtnoise;
	filtnoise = LPF.ar(PinkNoise.ar(noise), tone);
	env = EnvGen.kr(Env.perc(atk, rel, curve: -5.0), doneAction: 2);
	sig = (SinOsc.ar(freq) + filtnoise) * env * amp;
	sig = Pan2.ar(sig);
	Out.ar(0, sig);
}).add;

SynthDef.new(\playbuf, {
	arg buf, amp = 1, pan = 0, out = 0,
	atk = 0.001, rel = 10, curve = -4.0;
	var sig, env;
	env = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: 2);
	sig = PlayBuf.ar(1, buf, s.sampleRate/44100, doneAction: 2) * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\guitar, {
	arg freq = 220, amp = 1, gate = 1, atk = 0.001, dk = 10, sus = 0.01,
	rel = 0.1, color = 0.5, detune = 7, out = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve: -10.0), gate, doneAction: 2);
	detune = 1 + (detune / 1000);
	sig = Mix.new(VarSaw.ar([freq, freq * 2, freq * 3, freq * 4, freq * 6] * Rand(detune.reciprocal, detune), Rand(0.0, 0.5), color, [1, 0.8, 0.7, 0.2, 0.1]));
	sig = sig.squared.softclip(0.5) * amp * env;
	sig = Pan2.ar(sig);
	Out.ar(out, sig);
}).add;

)

(

~hatPat = Pbind(
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\hihatclosed], inf),
	\dur, 1/8,
	\amp, 3
);

~kickPat = Pbind(
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\kick], inf),
	\dur, 1/2,
	\amp, 4,
	\rel, 0.5,
	\out, ~filterBus
);

~kickPat2 = Pbind(
	\dur, Pseq([3/8, 13/8], inf)
);

~synthKickPat = Pbind(
	\instrument, \synthkick,
	\dur, 1/2,
	\rel, 0.3,
	\freq, \default,
	\amp, 0.8,
	\noise, Pwhite(0.1, 0.3, inf),
	\tone, Pwhite(800,1600, inf),
	\out, ~revBus
);

~snarePat = Pbind(
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\snare], inf),
	\note, Pseq([\, 0], inf),
	\dur, 1/2,
	\amp, 3
);

~tomPat = Pbind(
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\toms], inf),
	\dur, 1/8,
	\amp, Pseq([
		1,
		Pexprand(0.2, 0.7, 2),
		1,
		Pexprand(0.3, 0.7, 2),
		1,
		Pexprand(0.5, 0.7, 1)], inf) * 1.4,
	\pan, Pwhite(-1.0, 1.0, inf) /3,
	\out, ~revBus
);

~tomPat2 = Pbind(
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\toms], inf),
	\dur, 1/8,
	\amp, Pseq([
		1,
		Pexprand(0.2, 0.7, 2),
		1,
		Pexprand(0.2, 0.7, 2),
		1,
		Pexprand(0.2, 0.7, 2),
		1,
		Pexprand(0.3, 0.7, 2),
		1,
		Pexprand(0.7, 0.9, 3)], inf),
	\pan, Pwhite(-1.0, 1.0, inf) /3,
	\out, ~revBus
);

//4 chords, always land on the I6, then 3 random

~pulsePat = Pbind(
	\instrument, \pulse,
	\note, Pseq([[0, 7, 9, 12],
		Pseq({ Array.fill(4, { Scale.minorPentatonic.degrees.choose })}!3)], inf),
	\detune, 0.4,
	\dur, 8,
	\amp, 0.1,
	\legato, 1.1,
	\rel, 5,
	\sus, 1
);


//melody pattern template

~melodyPatTemp = Pbind(
	\instrument, \trilead,
	\sus, 0,
	\dk, 1,
	\amp, 0.3,
	\out, ~revBus
);

~melody1 = Pbind(
	\scale, Scale.minorPentatonic,
	\degree, Pseq([Pshuf(Array.series(6,4,1), 4)], inf),
	\dur, 1/8,
	\pan, Pkey(\degree, inf).linlin(-23, 23, -0.7, 0.7)
);

~bassPatTemp = Pbind(
	\instrument, \bass,
	\octave, 3,
	\db, -10,
	\sus, 0,
	\dk, 1,
	\rel, 0.2,
	\mix, 0.1,
	\ffreq, 800,
	\fres, 0.5
);

~bassPat1 = Pbind(
	\note, Pseq([
		Pseq([{ Scale.majorPentatonic.degrees.choose }, 0], 4),
		Pseq([{ Scale.majorPentatonic.degrees.choose }, -2], 4),
		Pseq([{ Scale.majorPentatonic.degrees.choose }, -4], 4),
		Pseq([{ Scale.majorPentatonic.degrees.choose }, -7], 4)
	], inf),
	\dur, Pseq([1/8, 15/8], inf),
	\octave, 3
);

~bassPat2 = Pbind(
	\note, Pseq([
		Pseries(0, 0, 64),
		Pseries(-2, 0, 64),
		Pseries(-4, 0, 64),
		Pseries(-7, 0, 64)
	], inf),
	\dur, Pseq([3/8], inf),
	\octave, 3,
	\rel, 0.8,
);

~bassPat3 = Pbind(
	\instrument, \bass,
	\note, Pseq([
		Pseries(0, 0, 16),
		Pseries(-2, 0, 16),
		Pseries(-4, 0, 16),
		Pseries(-7, 0, 16)
	], inf),
	\dur, Pseq([3/8], inf),
	\rel, 0.8
);

~bassPat4 = Pbind(
	\note, Pseq([
		Pseries(0, 0, 32),
		Pseries(-2, 0, 32),
		Pseries(-4, 0, 32),
		Pseries(-7, 0, 32)
	], inf),
	\dur, Pseq([1/8, 1/4], inf),
	\rel, 1,

);

//for readability i put these notes out the dang ole thing
~bassNotes = [0, 0, -2, 0, 7, 0, 3, 0, 12, 10, 12, 10, 9, 9, 7, 7];
~bassPat5 = Pbind(
	\note, Pseq([
		Pseq(~bassNotes, 4),
		Pseq(~bassNotes - 2, 4),
		Pseq(~bassNotes + 5, 4),
		Pseq(~bassNotes + 7, 4)
	], inf),
	\dur, Pseq([1/8], inf),
);

~ridePat = Pbind(
	\instrument, \playbuf,
	\buf, Pxrand(~bufs[\ride], inf),
	\dur, Pseq([1/8, 1/4, 1/8], inf),
	\amp, Pseq([
		1,
		Pexprand(0.2, 0.5, 2),
		1,
		Pexprand(0.3, 0.5, 2),
		1,
		Pexprand(0.5, 0.7, 1)], inf) * 4,
	\pan, Pwhite(-0.1, 0.3, inf) /3,
	\out, ~revBus,
);

~shredPat = Pbind(
	\instrument, \geetar,
	\midinote, Pseries(48, 2, 26),
	\dur, Pseq([Pseries(1/16, 0, 25), 10]),
	\fres, 0.5,
	\detune, 0.01,
	\amp, 0.01,
	\sus, 0,
	\curve, -4.0,
	\dist, 0.4,
	\fdk, 1,
	\out, ~revBus
);

)
~kickPat.play;
~synthKickPat.play;
~shredPat.play;
(~bassPat5 <> ~bassPatTemp).play(TempoClock(107/120));

(

p = Ppar([
	~kickPat2 <> ~synthKickPat,
	~kickPat2 <> ~kickPat,
	~ridePat,
	Pbind(\dur, 1/4, \note, 7) <> ~bassPat3 <> ~bassPatTemp <> Pbind(\stretch, 2),
	~melodyPatTemp <> Pbind(
		\scale, Scale.minorPentatonic,
		\degree, Pseq([Pshuf(Array.series(6,4,1), 4)], inf),
		\dur, 1/8,
		\pan, Pkey(\degree, inf).linlin(-23, 23, -0.7, 0.7)
	),
	~melodyPatTemp <> Pbind(
		\scale, Scale.minorPentatonic,
		\degree, Pseq([Pshuf(Array.series(4, -5, 1), 16)], inf),
		\dur, 1/8,
		\pan, Pkey(\degree, inf).linlin(-23, 23, -0.7, 0.7),
		\lpffreq, 2000
	)
], inf);
)
t = TempoClock(107/120);

Pdef(\lowmel, ~kickPat2 <> ~melody1 <> ~melodyPat);
Pbindf(Pdef(\lowmel, ~lowmel)).play;
~topmel = ~melody1 <> ~melodyPatTemp;
~tom = ~tomPat.play(t, quant:4);
~topmel = ~topmel.play(t, quant:4);
~lowmel = ~topmel <> Pbind(\mtranspose, -6);
~lowmel = ~lowmel.play(t, quant: 8);
~pad = Pbind(\note, [0, 3, 7]) <> ~pulsePat;
~pad1 = ~pad.play(t, quant: 8);
~pad1.stop;
~pad = Pbind(\note, Pseq([0, 3, 7], [3, 7, 10], [7, 12, 10], inf)) <> ~pulsePat;
~bass = Pbind(\dur, 1/4, \note, 7) <> ~bassPatTemp;
~bass1 = ~bass.play(t, quant: 4);
~bass1.set(\note, 12);