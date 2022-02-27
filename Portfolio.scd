///////////////////////// Synths /////////////////////////

(
~hpf = 30;
~lpf = 1500;
t = 0.045;
~atk = 0.003;
~rel = 0.1;
~lof = 30;
~hif = 150;
~loq = 0.001;
~hiq = 0.04;
~amp = 0.6;
)
(
~hpf = 1520;
~lpf = 1300;
t = 0.005;
~atk = 0.3;
~rel = 0.001;
~lof = 30;
~hif = 800;
~loq = 0.001;
~hiq = 0.009;
~amp = 0.1
)
(
fork{
    inf.do({
		{(LPF.ar(HPF.ar(RHPF.ar(WhiteNoise.ar(1), rrand(~lof,~hif), rrand(~loq, ~hiq)), ~hpf), ~lpf)
			* EnvGen.ar(Env.perc(~atk, ~rel), doneAction:2))*~amp!2}.play;
        t.wait;
    });
}
)




////////////////////////////////////////////
(
~car = 40;
~modfreq = 20;
~modamp = 80;
~def = 700;
~amp = 0.5;
)

(
fork{
    inf.do({
		{(LPF.ar(HPF.ar(RHPF.ar(SinOsc.ar(~car + SinOsc.ar(~modfreq, mul:~modamp), mul: Impulse.ar(~def )), rrand(~lof,~hif), rrand(~loq, ~hiq)), ~hpf), ~lpf)
			* EnvGen.ar(Env.perc(~atk, ~rel), doneAction:2))*~amp!2}.play;
        t.wait;
    });
}
)



///////////////////////////////////////////////

(
SynthDef(\poc, {
	arg freq = 300, speed = 60, size = 2, lpf = 20000, rq = 1, lpfvol = 1;
	var sig;
	sig = SinOsc.ar(freq, mul: LFSaw.ar(SinOsc.ar(speed, mul:size)));
	sig = RLPF.ar(sig, lpf, rq, lpfvol);
	sig = Pan2.ar(sig, 0, 0.4);
	Out.ar(0, sig);
}
).add;
)

a = Synth(\poc,[\freq, 50, \speed, 50]);
a.free;

a.set(\freq, 20, \speed, 28.5, \size, 100, \lpf, 2900, \rq, 0.17);








(
SynthDef(\background, {
	arg freq = 100, speed =2, size = 60, lpf = 2050, rq = 0.1, lpfvol = 0.1,
	atk = 0.001, sus = 0.5, rel = 1, amp = 0.3;
	var sig, env;
	env = EnvGen.kr(Env.new([0, 1, 1, 0], [atk, sus, rel]), doneAction:2);
	sig = SinOsc.ar(freq, mul: LFSaw.ar(SinOsc.ar(speed, mul:size)));
	sig = RLPF.ar(sig, lpf, rq, lpfvol);
	sig = sig * env;
	sig = Pan2.ar(sig, 0, amp);
	Out.ar(0, sig);
}
).add;
)

t = 0.2;
(
Routine({
	loop{
		Synth(\background);
		t.wait
	}
}).play;
)

///////////////////////

a = {SinOsc.ar(80 + SinOsc.ar(15, mul: 10), 2pi/SinOsc.ar(SinOscFB.ar(0.65,2pi/1, mul: 50, add:95), mul: 179.2, add:180)) * 0.1 !2}.play;

a.free;

b = {SinOsc.ar(80 + SinOsc.ar(30, mul: 20), 2pi/SinOsc.ar(SinOscFB.ar(8,2pi/1, mul: 50, add:95), mul: 179.2, add:180)) * 0.1 !2}.play;

b.free;
//////////////////////

(
SynthDef(\saw, {
	arg freq, amp, out, rel;
	var sig, env, mod;
	mod = LFSaw.kr(0.2, mul: 20);
	env = EnvGen.kr(Env.perc(0.05, rel), doneAction:2);
	sig = (Saw.ar(freq + mod) + SinOsc.ar(freq/2)) * env;
	sig = Pan2.ar(sig, 0, amp);
	Out.ar(out, sig);
}).add;

~limiter = Bus.audio(s, 2);

SynthDef(\limiter, {
	arg amp;
	var in, sig;
	in = In.ar(~limiter);
	sig = Limiter.ar(in, amp);
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;

)


(
~speed = 0.2;
~number = 8;
~high = 70;
~rel = 0.01;
~amp = 1;
)
(
Routine({
	Synth(\limiter, [\amp, 0.1]);

	loop{
		rrand(0, ~number).do({
			Synth(\saw, [\freq, rrand(~high/1.5, ~high).round(50), \amp, ~amp,\rel, rrand(0, ~rel), \out, ~limiter]);
			(~speed * 0.1).wait;
	});
		~speed.wait;
	};
}).play;
)

//////////////////////////////////////


(
SynthDef(\gagak, {
	arg out = 0, rate = 1, silence = 0.02, amp = 0, pitch = 420;
	var sig, mod, numb, ramp;
	numb = Array.series(6, {LFNoise1.ar(0.05, pitch/10, pitch)}, 0.1);

	mod = EnvGen.kr(Env.new([0, 1, 1, 0], [0.01, (1/rate) - silence, 0.01]), Impulse.kr(rate));
	sig = LFSaw.ar(numb)*mod + SinOsc.ar(numb)*mod;
	sig = Mix.ar(sig);
	sig = sig * SinOsc.kr(0.1, mul:0.2, add:0.8);
	sig = Pan2.ar(sig, LFNoise0.ar(20, mul: SinOsc.ar(0.01, mul:0.6)), amp);
	Out.ar(out, sig);
}).add;
)
e = Synth(\gagak);
e.set(\amp, 0.05, \rate, 4.5, \silence, 0.016, \pitch, 80)

///////////////////////////////////////

(
SynthDef.new(\noise, {

	arg amp = 0.01, pan = 0, out = 0, minspeed = 1, maxspeed = 3, freq = 100, bw = 1, passamp = 1;


	var sig, pulse;

	pulse = LFPulse.ar(LFNoise0.kr(4).range(minspeed, maxspeed));


	sig = WhiteNoise.ar();
	sig = sig * pulse;
	sig = BBandPass.ar(sig, freq, bw, passamp);
	sig = Clip.ar(sig, -0.2, 0.2);
	sig = sig * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

a = Synth.new(\noise, [\amp, 0.01,]);
a.set(\freq, 100, \bw, 0.25,\passamp, 10, \amp, 0.4, \maxspeed, 13, \minspeed, 0.01);
a.free;

/////////////////////////////////////////////

(
SynthDef.new(\jus, {
	arg freq = 200, amp= 0.2, bfreq = 200, bw = 1, bmul = 1, modspeed = 50, modw = 0.5, modamp = 50, pan=0, out=0;
	var sig, mod, spreadmod;
	spreadmod = Array.rand(5, 0.85, 1.15);
	mod = LFPulse.ar(modspeed, width: modw, mul: modamp);
	sig = Saw.ar(freq + (mod*spreadmod));
	sig = BBandPass.ar(sig, bfreq, bw, bmul);
	sig = sig * 0.2;
	sig = Splay.ar(sig);
	Out.ar(out, sig);
}).add;

////////////gui////////////

w = Window("Jus").front;



~onoff = Button.new(w, Rect(30, 450, 30, 30)).states_([
	["",Color.white, Color(1,1,1)],
	["",Color.black,Color(0,0,0)]
]).action_({
	arg but;
	if( but.value == 1, { a = Synth.new(\jus, [
	\freq, ~sfreq.value.linlin(0, 1, 0, 12000),
	\bfreq, ~bfreq.value.linlin(0,1,100,18000),
	\bw, ~bw.value.linlin(0, 1, 0.001, 4),
	\modspeed, ~modspeed.value.linlin(0, 1, 0, 100),
	\modamp, ~modamp.value.linlin(0, 1, 1, 500),
	\modw, ~mw.value.linlin(0, 1, 0.01, 0.99),
	]);

}, {a.free}
);
});


~sfreq = Slider.new(w, Rect(30, 20, 30, 400)).action_({
	arg slider;
	var cf;
	cf = slider.value.linlin(0, 1, 0, 12000);
	a.set(\freq, cf);
});

~bfreq = Slider.new(w, Rect(70, 20, 30,400)).action_({
	arg slider;
	var cf;
	cf = slider.value.linlin(0,1,100, 12000);
	a.set(\bfreq, cf);
});

~bw = Knob.new(w, Rect(70, 450, 40, 40)).action_({
	arg knob;
	var q;
	q = knob.value.linlin(0,1,0.001, 4);
	a.set(\bw, q);
});

~modspeed = Slider.new(w, Rect(110, 20, 30,400)).action_({
	arg slider;
	var modspeed;
	modspeed = slider.value.linlin(0, 1, 0, 100);
	a.set(\modspeed, modspeed);
});
~modamp = Slider.new(w, Rect(150, 20, 30, 400)).action_({
	arg slider;
	var modamp;
	modamp = slider.value.linlin(0, 1, 1, 500);
	a.set(\modamp, modamp);
});

~mw = Knob.new(w, Rect(120, 450, 40, 40)).action_({
	arg knob;
	var mw;
	mw = knob.value.linlin(0, 1, 0.01, 0.99);
	a.set(\modw, mw);
});


)


