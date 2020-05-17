s.meter;

(
SynthDef.new(\boop, {
	arg freq = 440, out = 0;
	var trig, sig;
	freq = LFNoise0.kr(3).exprange(freq, freq*4).round(freq);
	trig = Dust2.kr(5);
	sig = SinOsc.ar(freq, mul: 0.5);
	sig = Pan2.ar(sig, LFNoise0.kr(5));
	sig = sig * EnvGen.kr(Env.perc(), trig);
	Out.ar(out, sig);
}).add;
)

x = Synth(\boop, [\freq, 70]);

(
SynthDef.new(\verb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 0.9, 0.3);
	Out.ar(out, sig);
}).add;
)

~revBus = Bus.audio(s, 1);

y = Synth.tail(s, \verb, [\in, ~revBus]);
x = Synth.new(\boop, [\out, ~revBus]);

~oscGrp = Group.new(s);
~fxGrp = Group.after(~oscGrp);
(
z = Array.fill(10, { |i|
	Synth.new(\boop, [\freq, 50 * i+1, \out, ~revBus], ~oscGrp);
})
)
(
r = Routine({
	inf.do({
		z.do({
			arg node, count;
			node.set(\freq, 10 * (count + 1));
			1.wait;
			count.postln;
			node.postln;
		})
	})
});
)
~oscGrp.free;
r.stop;

x.free;

s.quit;