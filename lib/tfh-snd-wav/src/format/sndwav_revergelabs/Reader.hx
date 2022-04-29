package format.sndwav_revergelabs;

import haxe.io.Bytes;
import format.sndwav_revergelabs.Data;

class Reader {
	var i:sys.io.FileInput;

	public function new(i) {
		this.i = i;
		i.bigEndian = false;
	}

	public function read() {
		// Skip unknown data
		Tools.skipUnknownData(i);
		var soundsCount = i.readInt32();
		var soundsBlock = [];
		trace(soundsCount);
		var _ = 0;
		while (_ < soundsCount) {
			var soundFile = parseSounds();
			soundsBlock.push(soundFile);
			_++;
		}
		trace('test from Reader');
	}

	function parseSounds():Sound {
		var S_OGG = 0x5367674F;
		var S_RIFF = 0x46464952;
		var soundLength = i.readInt32();
		i.read(8);
		var soundFile = i.read(soundLength);
		// trace(soundFile.length);
		var fileTag = soundFile.getInt32(0);
		var soundFormat = ogg;
		if (fileTag == S_OGG) {
			soundFormat = ogg;
			// trace('Ogg');
		} else if (fileTag == S_RIFF) {
			soundFormat = wav;
			// trace('Wav');
		}
		return {
			soundLength: soundLength,
			soundFormat: soundFormat,
			soundFile: soundFile
		}
	}
}
