package otterui;

import otterui.GbsData;

// using StringTools;
class GbsReader {
	var i:sys.io.FileInput;

	public function new(i) {
		this.i = i;
		i.bigEndian = false;
	}

	public function read(path:String, ?onlyFonts = false):GbsFile {
		Tools.checkFileInput(i);
		var header = parseHeader();
		var fontsBlock = [];
		if (header.fontsCount < 1) {
			trace('Fonts not found in the file.');
		} else {
			Tools.tagOffset(i, header, readFonts);
			var _ = 0;
			while (_ < header.fontsCount) {
				var fontInstance = parseFonts();
				fontsBlock.push(fontInstance);
				_++;
			}
		}
		// if onlyFonts == true {}
		// if (gbs.header.texturesCount > 0) {}
		// if (gbs.header.soundsCount > 0) {}
		// if (gbs.header.viewsCount > 0) {}
		// if (gbs.header.messagesCount > 0) {}
		trace('Gbs file has been read.');
		return {
			header: header,
			fontsBlock: fontsBlock,
			textures: null,
			sounds: null,
			views: null,
			messages: null
		}
	}

	function parseHeader():GbsHeader {
		i.read(4); // skip header
		var fileSize = i.readInt32();
		if (i.read(4).toHex() != '3333733f')
			throw 'Not supported file version.';
		var dataVersion = 0.95;
		var sceneID = i.readInt32();
		var fontsCount = i.readInt32();
		var texturesCount = i.readInt32();
		var soundsCount = i.readInt32();
		var viewsCount = i.readInt32();
		var messagesCount = i.readInt32();
		var fontsOffset = i.readInt32();
		var texturesOffset = i.readInt32();
		var soundsOffset = i.readInt32();
		var viewsOffset = i.readInt32();
		var messagesOffset = i.readInt32();

		return {
			fileSize: fileSize,
			dataVersion: dataVersion,
			sceneID: sceneID,
			fontsCount: fontsCount,
			texturesCount: texturesCount,
			soundsCount: soundsCount,
			viewsCount: viewsCount,
			messagesCount: messagesCount,
			fontsOffset: fontsOffset,
			texturesOffset: texturesOffset,
			soundsOffset: soundsOffset,
			viewsOffset: viewsOffset,
			messagesOffset: messagesOffset
		}
	}

	// Fonts
	function parseFonts():GbsFont {
		if (i.readString(4) != 'TNFG')
			throw 'Font reading error.';
		var fontLength = i.readInt32();
		var fontID = i.readInt32();
		var fontName = i.readString(64);
		// fontName.rtrim();
		var fontSize = i.readInt32();
		var atlasWidth = i.readInt32();
		var atlasHeight = i.readInt32();
		var maxTop = i.readInt32();
		var atlasCount = i.readInt32();
		var charsCount = i.readInt32();
		var charsBlock = [];
		var _ = 0;
		while (_ < charsCount) {
			charsBlock.push(parseChars());
			_++;
		}

		return {
			fontLength: fontLength,
			fontID: fontID,
			fontName: fontName,
			fontSize: fontSize,
			atlasWidth: atlasWidth,
			atlasHeight: atlasHeight,
			maxTop: maxTop,
			atlasCount: atlasCount,
			charsCount: charsCount,
			charsBlock: charsBlock
		}
	}

	// Chars
	function parseChars():GbsChar {
		var charCode = i.readString(4);
		// charCode.rtrim();
		var imageGlyph;
		if (i.readInt32() == 0)
			imageGlyph = no;
		else
			imageGlyph = yes;
		var charXOffset = i.readInt32();
		var charYOffset = i.readInt32();
		var charWidth = i.readInt32();
		var charHeight = i.readInt32();
		var charTop = i.readInt32();
		var charAdvance = i.readInt32();
		var charLeftBearing = i.readInt32();
		var charAtlasIndex = i.readInt32();

		return {
			charCode: charCode,
			imageGlyph: imageGlyph,
			charXOffset: charXOffset,
			charYOffset: charYOffset,
			charWidth: charWidth,
			charHeight: charHeight,
			charTop: charTop,
			charAdvance: charAdvance,
			charLeftBearing: charLeftBearing,
			charAtlasIndex: charAtlasIndex
		}
	}
}
