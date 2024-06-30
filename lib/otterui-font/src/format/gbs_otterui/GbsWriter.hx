package format.gbs_otterui;

import format.gbs_otterui.GbsData;
import haxe.io.Bytes;

using StringTools;

class GbsWriter {
	var o:haxe.io.Output;

	public function new(o) {
		this.o = o;
		o.bigEndian = false;
	}

	public function write(gbs:GbsFile, ?patchMarker = false, ?skipQuestionMark = false) {
		writeHeader(gbs.header);
		if (gbs.header.fontsCount > 0) {
			var i = 0;
			while (i < gbs.header.fontsCount) {
				writeFonts(gbs.fontsBlock[i]);
				var allocatedCharsLength = gbs.fontsBlock[i].fontLength - 100;
				var charsBlockLength = gbs.fontsBlock[i].charsCount * 40;
				var bufferSize = allocatedCharsLength - charsBlockLength;
				if (bufferSize > 0) {
					var bufferBytes = Bytes.alloc(bufferSize);
					o.writeFullBytes(bufferBytes, 0, bufferSize);
				}
				i++;
			}
		} else {
			trace('Skip fonts writhing in the file.');
		}
		if (gbs.header.texturesCount > 0) {
			o.write(gbs.textures);
		}
		if (gbs.header.soundsCount > 0) {
			o.write(gbs.sounds);
		}
		if (gbs.header.viewsCount > 0) {
			o.write(gbs.views);
		}
		if (gbs.header.messagesCount > 0) {
			o.write(gbs.messages);
		}
		var endMarker = Bytes.ofHex('21433412');
		o.write(endMarker);
		trace('Gbs file has been written.');
	}

	function writeHeader(gbs:GbsHeader) {
		o.writeString("CSGG");
		o.writeInt32(gbs.fileSize);
		o.writeFloat(gbs.dataVersion);
		o.writeInt32(gbs.sceneID);
		o.writeInt32(gbs.fontsCount);
		o.writeInt32(gbs.texturesCount);
		o.writeInt32(gbs.soundsCount);
		o.writeInt32(gbs.viewsCount);
		o.writeInt32(gbs.messagesCount);
		o.writeInt32(gbs.fontsOffset);
		o.writeInt32(gbs.texturesOffset);
		o.writeInt32(gbs.soundsOffset);
		o.writeInt32(gbs.viewsOffset);
		o.writeInt32(gbs.messagesOffset);
	}

	function writeFonts(gbs:GbsFont, ?skipQuestionMark = false) {
		o.writeString("TNFG");
		o.writeInt32(gbs.fontLength);
		o.writeInt32(gbs.fontID);
		o.writeString(gbs.fontName.rpad('\x00', 64));
		o.writeInt32(gbs.fontSize);
		o.writeInt32(gbs.atlasWidth);
		o.writeInt32(gbs.atlasHeight);
		o.writeInt32(gbs.maxTop);
		o.writeInt32(gbs.atlasCount);
		o.writeInt32(gbs.charsCount);
		// ?skipQuestionMark
		// '?\x00' - utf8, '?' - utf16
		var i = 0;
		while (i < gbs.charsCount) {
			writeChars(gbs.charsBlock[i]);
			i++;
		}
	}

	function writeChars(gbs:GbsChar) {
		#if !utf16
		if (gbs.imageGlyph == no) {
			o.writeString(gbs.charCode + '\x00\x00', RawNative); // Eval
		} else {
			/*
				// Remix characters
				var charArray = gbs.charCode.split('');
				charArray.reverse();
				var charGlyph = '';
				for (i in charArray) {
					charGlyph = charGlyph + i;
				}
				o.writeString(charGlyph, RawNative); */
			o.writeString(gbs.charCode, RawNative);
		}
		#else
		if (gbs.imageGlyph == no) {
			o.writeString(gbs.charCode + '\u{0000}', RawNative); // HL or C++
		} else {
			/*
				// Remix characters
				var charArray = gbs.charCode.split('');
				charArray.reverse();
				var charGlyph = '';
				for (i in charArray) {
					charGlyph = charGlyph + i;
				}
				var charByte = Bytes.ofString(charGlyph, RawNative);
				charGlyph = charByte.getString(0, 4);
				trace(charGlyph);
				trace(charByte);
				o.writeString(charGlyph, RawNative); */
			// check encoding issue
			// o.write()
			// trace(gbs.charCode);
			o.writeString(gbs.charCode.lpad('\x00', 4), UTF8);
		}
		#end
		if (gbs.imageGlyph == no)
			o.writeInt32(0);
		else
			o.writeInt32(1);
		o.writeInt32(gbs.charXOffset);
		o.writeInt32(gbs.charYOffset);
		o.writeInt32(gbs.charWidth);
		o.writeInt32(gbs.charHeight);
		o.writeInt32(gbs.charTop);
		o.writeInt32(gbs.charAdvance);
		o.writeInt32(gbs.charLeftBearing);
		o.writeInt32(gbs.charAtlasIndex);
	}
}
