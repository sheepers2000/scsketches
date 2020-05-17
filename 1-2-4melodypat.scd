(
~bassPat = Pdef.new(\bass,
	Pbind(
		\instrument, \pulse,
		\midinote, Pseq([
			[36, 48],
			[36, 48],
			[38, 50],
			[38, 50],
			[41, 53],
			[41, 53],
			[36, 48],
			[36, 48]
		], inf),
		\dur, 2,
		\strum, 1/4,
		\amp, 0.1,
		\atk, 0.5
	)
);
~melody = Pdef.new(\melody,
	Pbind(
		\instrument, \pulse,
		\midinote, Pseq([\, \, 69, 67, 65, 67, 65, 60], inf),
		\dur, 1/4,
		\amp, 0.3,
		\atk, 0.01
	),
);
)
Ppar([~melody, ~bassPat], inf).play;