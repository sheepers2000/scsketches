s.boot;

{SinOsc.ar(440,0,0.5)}.play;

(
Pbind(
	\degree, Pshuf([-2,0,1,2,5,6],16),
	\dur, 1/6
).play.quant(1/6);
)

(
p = Pbind(
    \degree, Pslide((-6, -4 .. 12), 8, 3, 1, 0),
    \dur, Pseq([0.1, 0.1, 0.2], inf),
    \sustain, 0.15
).play;
)

(
p = Pbind(
	\degree, Pseq(#[0, 3, 6, 5, 5, 5, 0, 2, 1], 1),
	\dur, 1/8
).asStream;
)

p.next(());

(
var notes = [0, 1, 3, 5, 6, 8, 10, 12];
var scram = notes.scramble;
Pbind(
	\note, Pseq(scram, inf),
	\dur, 1/8
).play;
Pbind(
	\note, Pser(scram.scramble-12, inf),
	\dur, 1
).play;
)

(
var scale = [0, 2, 4, 7, 9, 12];
var notes = [0,1,2,3,4,5,\rest, \rest];
TempoClock.default.tempo = 110/120;
p = Pbind(
	\scale, scale,
	\root, -3,
	\degree, Pseq([
		Pshuf(notes.rand.postln, 16),
		Pshuf(notes.rand.postln, 16)],
	inf),
	\dur, 1/8,
	\legato, 1
).play;
b = Pbind(
	\scale, scale,
	\root, -3,
	\degree, Pseq([
		Pshuf(notes-16, 4),
		Pshuf(notes-16, 4)],
	inf),
	\dur, 4,
	\legato, 1
).play;
)

z = Pwhite(1, 5, inf) * 2;

(
TempoClock.default.tempo = 84/60;
​
p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Pseq(#[rest, 4, 3, 4, 2, 4, 1, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2, 4,
        -3, 4, -1.9, 4, -0.9, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2], 1),
    \dur, 0.25
).play;
)
​
(
p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Place([#[rest, 3, 2, 1, 0, -0.9, 0, 1, 2, -3, -1.9, -0.9, 0, -0.9, 0, 1, 2],
        (4 ! 16) ++ \rest], 17),
    \dur, 0.25
).play;
)
​
(
p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Ppatlace([Pseq(#[rest, 3, 2, 1, 0, -0.9, 0, 1, 2, -3, -1.9, -0.9, 0, -0.9, 0, 1, 2], 1),
        Pn(4, 16)], inf),
    \dur, 0.25
).play;
)

(4 ! 16).postln;

(
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

SynthDef(\stretchedFragments, { |out, bufnum, start, time = 1, stretch = 0.5, amp = 1, attack = 0.01, decay = 0.05|
    var sig = PlayBuf.ar(1, bufnum, rate: stretch.reciprocal, startPos: start), eg;
    sig = PitchShift.ar(sig, pitchRatio: stretch);
    eg = EnvGen.kr(Env.linen(attack, time, decay), sig.abs > 0, doneAction: Done.freeSelf);
    Out.ar(out, (sig * eg) ! 2)
}).add; // note add! Without this, arguments won't work
)

(
TempoClock.default.tempo = 180/120;

p = Pbind(
    \instrument, \stretchedFragments,
    \bufnum, b,
    \start, Pwhite(0.2, (b.numFrames * 0.9).asInteger, inf),
    \delta, Pexprand(0.2, 10.0, inf),
    \time, Pkey(\delta),
    \stretch, Pexprand(0.5, 10.0, inf),
    \amp, 0.5,
    \attack, 0.2,
    \decay, 0.2,
	\legato, 10
).play;
)

p.stop;
b.free;
(
p = Pbind(
    \degree, Pseries(14, Pwhite(1, 3, inf), inf).fold(7, 21)
        + Prand(#[[0, -2, -4], [0, -3, -5], [0, -2, -5], [0, -1, -4]], inf),
    \dur, Pwrand(#[1, 0.5], #[0.8, 0.2], inf)
).play;
)