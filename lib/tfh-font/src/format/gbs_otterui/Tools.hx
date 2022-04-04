package format.gbs_otterui;

import sys.io.FileInput;
import sys.FileSystem;
import format.gbs_otterui.GbsData;

class Tools {
	public static function checkInputLength(i:FileInput) {
		var cur = i.tell();
		i.seek(0, SeekBegin);
		var l = i.readAll().length;
		i.seek(cur, SeekBegin);
		return l;
	}

	public static function fileExists(path:String):Bool {
		var fSize = FileSystem.stat(path).size;
		if (fSize < 60) {
			trace('$path:\nIncorrect or empty file.');
			return false;
		}
		return true;
	}

	public static function checkFonts(path:String):Bool {
		var i = sys.io.File.read(path);
		if (i.readString(4) != 'CSGG')
			return false;
		i.seek(16, SeekBegin);
		var fontsCount = i.readInt32();
		i.close();
		if (fontsCount > 0)
			return true;
		return false;
	}

	public static function checkFileInput(i:FileInput) {
		if (i.readString(4) != 'CSGG')
			throw 'File is not a valid GBS file.';
		var fileSize = i.readInt32();
		var checkFSize = fileSize - 4;
		i.seek(checkFSize, SeekBegin);
		if (i.read(4).toHex() != '21433412') // Check EndMarker
			throw 'The file is corrupted or the file size is incorrectly specified.';
		// Check offsets
		var values = checkOffsets(i, fileSize);
		return values;
	}

	public static function checkOffsets(i:FileInput, fileSize:Int) {
		i.seek(0, SeekBegin);
		i.read(36);
		var fontsOffset = i.readInt32();
		var texturesOffset = i.readInt32();
		var soundsOffset = i.readInt32();
		var viewsOffset = i.readInt32();
		var messagesOffset = i.readInt32();

		var fontsToFileEnd = fileSize - (fontsOffset + 56);
		var texturesToFileEnd = fileSize - (texturesOffset + 56);
		var soundsToFileEnd = fileSize - (soundsOffset + 56);
		var viewsToFileEnd = fileSize - (viewsOffset + 56);
		var messagesToFileEnd = (fileSize - 56) - messagesOffset;

		var fBlockSize = fontsToFileEnd - texturesToFileEnd;
		var tBlockSize = texturesToFileEnd - soundsToFileEnd;
		var sBlockSize = soundsToFileEnd - viewsToFileEnd;
		var vBlockSize = viewsToFileEnd - messagesToFileEnd;
		var mBlockSize = messagesToFileEnd - 4;

		var eofCheck = fileSize - fBlockSize - tBlockSize - sBlockSize - vBlockSize - mBlockSize - 56 - 4;
		if (eofCheck == 0) {
			trace("Data offsets ok.");
		} else {
			trace("\n*****\nWARNING! Data offsets is range out end of file!\n*****\n");
			trace("Fonts to file end: " + fontsToFileEnd);
			trace("Textures to file end: " + texturesToFileEnd);
			trace("Sounds to file end: " + soundsToFileEnd);
			trace("Views to file end: " + viewsToFileEnd);
			trace("Messages to file end: " + messagesToFileEnd + '\n');
			trace("File Size: " + fileSize);
			trace("Fonts Size: " + fBlockSize);
			trace("Textures Size: " + tBlockSize);
			trace("Sounds Size: " + sBlockSize);
			trace("Views Size: " + vBlockSize);
			trace("Messages Size: " + mBlockSize);
		}
		trace('File has been checked.');
		i.seek(0, SeekBegin);
		return {
			tBlockSize: tBlockSize,
			sBlockSize: sBlockSize,
			vBlockSize: vBlockSize,
			mBlockSize: mBlockSize
		}
	}

	public static function tagOffset(i:FileInput, header:GbsHeader, tag:Tags) {
		switch (tag) {
			case readFonts:
				i.seek(header.fontsOffset + 56, SeekBegin);
			case readTextures:
				i.seek(header.texturesOffset + 56, SeekBegin);
			case readSounds:
				i.seek(header.soundsOffset + 56, SeekBegin);
			case readViews:
				i.seek(header.viewsOffset + 56, SeekBegin);
			case readMessages:
				i.seek(header.messagesOffset + 56, SeekBegin);
		}
	}

	public static function isZero(s:String, pos:Int):Bool {
		#if (python || lua)
		if (s.length == 0 || pos < 0 || pos >= s.length)
			return false;
		#end
		var c = s.charCodeAt(pos);
		return c == 0;
	}

	// uses for Eval and dynamic targets
	public #if cs inline #end static function rclean(s:String):String {
		#if cs
		return untyped s.TrimEnd();
		#else
		var l = s.length;
		var r = 0;
		while (r < l && isZero(s, l - r - 1)) {
			r++;
		}
		if (r > 0) {
			return s.substr(0, l - r);
		} else {
			return s;
		}
		#end
	}
}
