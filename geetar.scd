
(
x = {
	var in, amp, freq, hasFreq, out;
	in = SoundIn.ar(0);
	amp = Amplitude.ar(in);
	# freq, hasFreq = Pitch.kr(in);
	LFTri.ar(freq*[1,2]) * amp;
}.play;
)

x.free;

(
Pbind(
	\note, Pseries(0, 1, inf),
	\dur, Pseq([3/8], inf),
).trace.play;
Pbind(
	\note, -7,
	\dur, Pseq([8], inf)
).trace.play;
)

(
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
)

(
Pbind(
	\instrument, \geetar,
	\midinote, Pseries(48, 2, 24),
	\dur, Pseq([Pseries(1/11, 0, 23), 4]),
	\fres, 0.5,
	\detune, 0.01,
	\amp, 1,
	\sus, 0,
	\curve, -4.0,
	\dist, 0.1,
	\fdk, 1
).play;
)

Vibrato

(
SynthDef(\gtr, {
	arg freq = 220, detune = 0.1, out = 0;
	var sig, dt;
	dt = LFNoise1.kr(1, detune).midiratio;
	sig = Pulse.ar(freq * dt) + SyncSaw.ar(freq, freq * 3 * dt) + SinOsc;
	Out.ar(out, sig!2);
}).add;
)

Synth(\geetar);

x = Synth.new(\geetar);
x.plot

({
	var freq = 220, amp = 1, gate = 1, detune = 0.1, out = 0,
	atk = 0.01, dk = 10, sus = 0, rel = 0.1, curve = -10.0,
	fatk = 0.01, fdk = 4, fcurve = -10.0, fres = 1, ffreq = 4,
	dist = 1;
	var sig, env, fenv;
	detune = LFNoise1.kr(1, ).midiratio;
	sig = Pulse.ar(freq * detune) + SyncSaw.ar(freq, freq * 3 * detune) + SinOsc((freq / 2) * detune);
	// sig = sig.clip2(dist) * dist.reciprocal;
	env = EnvGen.ar(Env.adsr(atk, dk, sus, rel, curve: curve), gate, doneAction: 2);
	fenv = EnvGen.ar(Env.perc(fatk, fdk, curve: fcurve)).exprange(0.1, 1.0);
	sig = BPF.ar(sig, freq * ffreq * fenv, fres);
	Out.ar(out, sig!2);
}.play;);