(
w = Window("gui", Rect(Window.screenBounds.width / 2, Window.screenBounds.height / 2, 300, 200))
.front
.alwaysOnTop_(true)
.background_(Color.white);

~slider = Slider(w, Rect(20, 20, 20, 150))
.background_(Color.red)
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,100,4000);
	x.set(\freq, cf.postln;);
});
)

~slider.value_(0.8);
w.background_(Color.magenta);
~slider.background_(Color.white);

(
SynthDef.new(\simplebpf,
	{
		arg freq = 440;
		var sig;
		sig = PinkNoise.ar(1!2);
		sig = BPF.ar(sig, freq);
		Out.ar(0,sig);
}).add;
)

x = Synth.new(\simplebpf);
x.free;