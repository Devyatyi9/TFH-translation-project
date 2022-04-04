package otterui;

import sys.io.FileInput;
import otterui.GbsData;

class Tools {
	// public function new() {}
	public static function checkFileSize() {}

	public static function checkFileInput(i:FileInput) {
		if (i.readString(4) != 'CSGG')
			throw 'File is not a valid GBS file.';
		var checkFSize = (i.readInt32() - 4);
		i.seek(checkFSize, SeekBegin);
		if (i.read(4).toHex() != '21433412') // Check EndMarker
			throw 'The file is corrupted or the file size is incorrectly specified.';
		trace('File is correct');
		i.seek(0, SeekBegin);
	}

	public static function tagOffset(i:FileInput, header:GbsHeader, tag:Tags) {
		switch (tag) {
			case readFonts:
				i.seek(header.fontsOffset, SeekCur);
			case readTextures:
				i.seek(header.texturesOffset, SeekCur);
			case readSounds:
				i.seek(header.soundsOffset, SeekCur);
			case readViews:
				i.seek(header.viewsOffset, SeekCur);
			case readMessages:
				i.seek(header.messagesOffset, SeekCur);
		}
	}
}
