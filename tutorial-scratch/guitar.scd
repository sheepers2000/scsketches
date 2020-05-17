(
SynthDef.new(\guitar, {
	arg freq = 220, amp = 1, gate = 1, atk = 0.001, dk = 10, sus = 0.01,
	rel = 0.1, color = 0.5, detune = 7, out = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk, dk, sus, rel, curve: -10.0), gate, doneAction: 2);
	detune = 1 + (detune / 1000);
	sig = Mix.new(VarSaw.ar([freq, freq * 2, freq * 3, freq * 4, freq * 6] * Rand(detune.reciprocal, detune), Rand(0.0, 0.5), color, [1, 0.8, 0.7, 0.2, 0.1]));
	sig = sig.squared.softclip(0.5) * amp * 0.3 * env;
	sig = Pan2.ar(sig);
	Out.ar(out, sig);
}).add;

SynthDef.new(\verb, {
	arg in, size = 1, damp = 0.2, dk, out = 0, level = 0.75;
	var sig;
	sig = FreeVerb.ar(In.ar(in, 2), 0.5, size, damp, level);
	Out.ar(out, sig);
}).add;
)
~revBus = Bus.new();

~guits = Group.new();

r = Synth.new(\verb, [\n, ~revBus], ~guits, 'addToTail');
3.do({ |i| Synth.new(\guitar, [\freq, 110 * (i+1)], ~guits) });
r.free;

~guits.set(\gate, 0);

{ SinOsc.ar(300, 0, MouseX.kr(0.1, 80, 1)).cubed.softclip * 0.2 }.scope(1);