
//setting up melodies...

~melodyNotes1 = [ 4, 5, 9, 10, 12, 14, \];
~melody1Weights1 = [1, 1, 10, 1, 5, 1, 5].normalizeSum;
~melody1Weights2 = [1, 1, 1, 5, 10, 5, 1].normalizeSum;
~melodyNotes2 = [7, 10, 12, 14, 17, \];
~melody2Weights1 = [1, 1, 5, 10, 1, 5].normalizeSum;
~melody2Weights2 = [1, 5, 10, 5, 1, 5].normalizeSum;

~melody1 = Pseq([
		7,
		{ ~melodyNotes1.wchoose(~melody1Weights1) }.value,
		{ ~melodyNotes1.wchoose(~melody1Weights2) }.value,
		14,
		{ ~melodyNotes2.wchoose(~melody2Weights1) }.value,
		{ ~melodyNotes2.wchoose(~melody2Weights2) }.value,
		Prand([5,9])], 2);
~melody2 = Pseq([
		9,
		{ ~melodyNotes1.wchoose(~melody1Weights1) }.value,
		{ ~melodyNotes1.wchoose(~melody1Weights2) }.value,
		16,
		{ ~melodyNotes2.wchoose(~melody2Weights1) }.value,
		{ ~melodyNotes2.wchoose(~melody2Weights2) }.value,
	Prand([10,7])], 2);
~melody3 = Pseq([
		10,
		{ ~melodyNotes1.wchoose(~melody1Weights1) }.value,
		{ ~melodyNotes1.wchoose(~melody1Weights2) }.value,
		12,
		{ ~melodyNotes2.wchoose(~melody2Weights1) }.value,
		{ ~melodyNotes2.wchoose(~melody2Weights2) }.value,
		Prand([9, 12])], 2);

~melodyPat1 = Pbind(
	\note, Pseq([~melody1, ~melody2, ~melody3, ~melody1], inf),
	\dur, Pseq([Pshuf([1/4, 1/4, 1/2, 1/2, 1/2, 1, 1], 16)], inf),
	\stretch, 0.5,
);

~melodyPat2 = Pbind(
	\note, Pseq([~melody1, ~melody2, ~melody3, ~melody1], inf) - 12,
	\dur, Pseq([Pshuf([1/4, 1/4, 1/2, 1/2, 1/2, 1, 1], 16)], inf),
	\amp, 0.2,
	\stretch, 0.5,
	\lpffreq, 400,
);

