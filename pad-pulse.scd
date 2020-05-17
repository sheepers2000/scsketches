(
MIDIClient.init;
MIDIIn.connectAll;
)
s.options.numOutputBusChannels_(8);

(
~notes = Array.newClear(128);
//Warbly Pulse wave synth pad with a lot of randomness. For best results, double or more.
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

MIDIdef.noteOn(\noteOn, {
	arg vel, note, chan, src;
	[note, vel, chan].postln;
	~notes[note] = Synth.new(\pulse, [
		\freq, note.midicps,
		\amp, vel.linexp(1, 127, 0.01, 0.7),
		\atk, (128-vel).linexp(1, 127, 0.2, 1),
		\gate, 1,
		\detune, 0.5,
		\ffreq, note.midicps * 2 * vel.linexp(1, 127, 1.0, 2.0)
	]);
});
MIDIdef.noteOff(\noteOff, {
	arg vel, note, chan, src;
	~notes[note].set(\gate, 0);
	~notes[note] = nil;
});

)
s.quit;
