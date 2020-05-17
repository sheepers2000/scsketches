
(
t = TempoClock.new;
t.tempo = 90/120;
Pdef(\one,
	Pbind(
		\midinote, Pwrap(
			Pseq(
				Array.series(6, 48, 7).postln,
				inf
			),
			0, 127),
		\dur, 1/8
	)
).play(t);
Pdef(\two,
	Pbind(
		\midinote, Pwrap(
			Pseq(
				Array.series(7, 72, -5),
				inf
			),
			0,127),
		\dur, 1/8
	)
).play(t);
)

t.tempo = 120/120;

(
Pbind(*[
	stretch: Pseg([0,0.1,0.2,1],8).linexp(0,1,1,1/8),
	midinote: 100.cpsmidi,
	harmonic: Pwhite(1, 16),
	legato: Pkey(\stretch) * Pkey(\harmonic)/2,
	db: -10 - Pkey(\harmonic),
	detune: Pwhite(0.0, 3.0),
	dur: 0.2
]).play;
)