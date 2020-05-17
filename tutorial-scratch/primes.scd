(
n = ;
f = 100;
{ Out.ar([0,1], Mix.ar(SinOsc.ar(Array.fill(n, { |i| f * ((((i+1).squared)).postln) }).postln;, 0, Array.fill(n, { |i| 0.1 * 1/(i+1)})))) }.play;
)

(
n = 16;
f = 50;
{ Out.ar(
	[0,1],
	Mix.ar(
		SinOsc.ar(
			(f*~primes.value(1,n)).postln,
			0,
			Array.fill(
				n,
				{ |i| 0.1 * 1/(i+1)})
)))}.play;
)

(
~primes = { arg start = 1, harmonics = 5;
var primes = [];
while { primes.size < harmonics } {
	start = start + 1;
	primes = primes.add(start.nextPrime);
	start = start.nextPrime;
};
primes.postln;
};
)
~primes.value(1,20);

s.boot;

(
t = TempoClock.new;
t.tempo = 100/120;
Pbind(
	\degree, Pwrap(Pseq(~primes.value(1,1000),inf)/2, 0, 7),
	\dur, Prand([1/8], inf),
	\legato, 0.1
).play(t);
Pbind(
	\degree, Pwrap(Pseq(~primes.value(1,1000).reverse, inf)/2, 0, 7) - 14,
	\dur, 2
).play(t);
)

