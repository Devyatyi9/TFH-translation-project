package format.sndwav_revergelabs;

import haxe.Int32;

typedef SoundContainer = {
	var unknownData:haxe.io.Bytes;
	var soundsCount:Int32;
	var soundsBlock:Array<Sound>;
}

enum SoundFormat {
	ogg;
	wav;
}

typedef Sound = {
	var soundLength:Int32;
	var soundFormat:SoundFormat;
	var soundFile:haxe.io.Bytes;
}

typedef SoundJson = {
	var SoundNumber:Int32;
	var SoundName:String;
	var Description:String;
	// var SoundFormat:SoundFormat;
}

typedef ArrayJson = {
	var soundsInfoBlock:Array<SoundJson>;
}

//
