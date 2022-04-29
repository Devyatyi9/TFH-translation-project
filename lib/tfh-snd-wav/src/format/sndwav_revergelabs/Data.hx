package format.sndwav_revergelabs;

import haxe.Int32;

enum SoundFormat {
	ogg;
	wav;
}

typedef Sound = {
	var soundLength:Int32;
	var soundFormat:SoundFormat;
	var soundFile:haxe.io.Bytes;
}
