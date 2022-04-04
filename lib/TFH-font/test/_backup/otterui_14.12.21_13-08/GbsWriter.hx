package otterui;

import otterui.GbsData;
import haxe.io.Bytes;

class GbsWriter {
	var o:haxe.io.Output;

	public function new(o) {
		this.o = o;
		o.bigEndian = false;
	}

	public function write(gbs:GbsFile, ?patchMarker = false, ?skipQuestionMark = false) {
		writeHeader(gbs.header);
		if (gbs.header.fontsCount < 1) {
			trace('Skip fonts writhing in the file.');
		} else {
			var i = 0;
			while (i < gbs.header.fontsCount) {
				writeFonts(gbs.fontsBlock[i]);
				i++;
			}
		}
		// if (gbs.header.texturesCount > 0) {}
		// if (gbs.header.soundsCount > 0) {}
		// if (gbs.header.viewsCount > 0) {}
		// if (gbs.header.messagesCount > 0) {}
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
		// FontName StringTools rpad()
		o.writeString(gbs.fontName);
		o.writeInt32(gbs.fontSize);
		o.writeInt32(gbs.atlasWidth);
		o.writeInt32(gbs.atlasHeight);
		o.writeInt32(gbs.maxTop);
		o.writeInt32(gbs.atlasCount);
		o.writeInt32(gbs.charsCount);
		// ?skipQuestionMark
		var i = 0;
		while (i < gbs.charsCount) {
			writeChars(gbs.charsBlock[i]);
			i++;
		}
	}

	function writeChars(gbs:GbsChar) {
		// charCode StringTools rpad()
		o.writeString(gbs.charCode);
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
