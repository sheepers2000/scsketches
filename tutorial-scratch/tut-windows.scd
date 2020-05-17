s.boot;

(
SynthDef("ScoreSine", { arg freq=440;
	Out.ar([0,1],
		SinOsc.ar(freq, 0, 0.2) * Line.kr(1, 0, 0.5, doneAction: 2)
	)
}).add;

x = [
	[0.0, [\s_new, \ScoreSine, 1000, 0, 0, \freq, 1413]],
	[0.5, [\s_new, \ScoreSine, 1001, 0, 0, \freq, 712]],
	[1.0, [\s_new, \ScoreSine, 1002, 0, 0, \freq, 417]],
	[2.0, [\c_set, 0, 0]]
];
z = Score(x);
)
z.play;

{Resonz.ar(Dust2.ar(5), 300, 0.001, 100)}.play;

(
f = 50;
n = 20;
{
	Out.ar([0,1], Mix.fill(n, {|i| Resonz.ar(Dust2.ar(10), f * (i + 1), 0.0001, 4000)})
		* n.reciprocal);
}.play
)


(
f = 20;
n = 50;
t = Array.fill(n, { |i|
	{
		Out.ar([0,1], { Resonz.ar(Dust2.ar(2), f * (i + 1), 0.0001, 3000)
		* n.reciprocal
		});
	}.play;
});

w = Window.new("Buttons", Rect(50,100,290,250), scroll: true);
w.view.decorator = FlowLayout.new(w.view.bounds);
n.do({|i|
	Button.new(w, Rect(0,0,130,30)).states_([
		["Freq" + (f * (i + 1)) + "On", Color.black, Color.white],
		["Freq" + (f * (i + 1)) + "Off", Color.white, Color.black]
	]).action_({arg butt;
		t[i].run(butt.value == 0);
	});
});
w.front;
)

(
f = 200;
n = 10;
t = Array.fill(n, { |i|
	{
		Out.ar([0,1], { SinOsc.ar(f * (i = 1), 0, 0.1*(1/n))
		});
	}.play;
});

w = Window.new("Buttons", Rect(50,100,290,250), scroll: true);
w.view.decorator = FlowLayout.new(w.view.bounds);
n.do({|i|
	Button.new(w, Rect(0,0,130,30)).states_([
		["Freq" + (f * (i + 1)) + "On", Color.black, Color.white],
		["Freq" + (f * (i + 1)) + "Off", Color.white, Color.black]
	]).action_({arg butt;
		t[i].run(butt.value == 0);
	});
});
w.front;
)