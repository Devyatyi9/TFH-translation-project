package format.gbs_otterui;

import haxe.io.StringInput;
import haxe.Resource;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import format.gbs_otterui.GbsData;

using format.gbs_otterui.Tools;

class GbsReader {
	var i:sys.io.FileInput;

	public function new(i) {
		this.i = i;
		i.bigEndian = false;
	}

	public function read(?onlyFonts = false):GbsFile {
		var offSizes = Tools.checkFileInput(i);
		var header = parseHeader();
		var fontsBlock = [];
		if (header.fontsCount > 0) {
			Tools.tagOffset(i, header, readFonts);
			var _ = 0;
			while (_ < header.fontsCount) {
				var cur = i.tell();
				var fontInstance = parseFonts();
				fontsBlock.push(fontInstance);
				i.seek(cur, SeekBegin);
				i.seek(fontInstance.fontLength, SeekCur);
				_++;
			}
		} else {
			trace('Fonts not found in the file.');
		}
		var textures = Bytes.alloc(0);
		var sounds = Bytes.alloc(0);
		var views = Bytes.alloc(0);
		var messages = Bytes.alloc(0);
		if (onlyFonts == false) {
			var tBlockSize = offSizes.tBlockSize;
			var sBlockSize = offSizes.sBlockSize;
			var vBlockSize = offSizes.vBlockSize;
			var mBlockSize = offSizes.mBlockSize;
			try {
				if (header.texturesCount > 0) {
					Tools.tagOffset(i, header, readTextures);
					textures = i.read(tBlockSize);
				}
				if (header.soundsCount > 0) {
					Tools.tagOffset(i, header, readSounds);
					sounds = i.read(sBlockSize);
				}
				if (header.viewsCount > 0) {
					Tools.tagOffset(i, header, readViews);
					views = i.read(vBlockSize);
				}
				if (header.messagesCount > 0) {
					Tools.tagOffset(i, header, readMessages);
					messages = i.read(mBlockSize);
				}
			} catch (e:haxe.io.Eof) {
				throw "Invalid data offsets in gbs file.";
			}
		}
		trace('Gbs file has been read.');
		return {
			header: header,
			fontsBlock: fontsBlock,
			textures: textures,
			sounds: sounds,
			views: views,
			messages: messages
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
		#if target.static
		var fontName = i.readString(64);
		#else
		var fontName = i.readString(64).rclean();
		#end
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
		// if use Eval (for debug or launch via IDE) it will display characters incorrect because of use UTF-8 encoding,
		// HL and C++ use UTF-16LE for this
		// var charCode = i.readString(2, RawNative);
		var charCode = "";
		var charHexCode:haxe.io.Bytes = i.read(2);
		var tempCharBytes:haxe.io.Bytes = i.read(2);
		var glyphCode:haxe.io.Bytes = Bytes.alloc(0);
		// var glyphCode = i.readString(2, UTF8);
		// trace("'" + charCode + "'");
		var isImageGlyph;
		if (i.readInt32() == 0) {
			isImageGlyph = no;
			var localCharInput = new BytesInput(charHexCode, 0, 2); // BytesBuffer = new BytesBuffer();
			charCode = localCharInput.readString(2, RawNative);
			// var tempCode = charHexCode.getUInt16(0);
			// charCode = String.fromCharCode(tempCode); // .getString(0, 2, RawNative) // .fromCharCode(tempCode)
		} else {
			isImageGlyph = yes;
			var hexConcatenate = charHexCode.toHex() + tempCharBytes.toHex();
			glyphCode = haxe.io.Bytes.ofHex(hexConcatenate);
			#if utf16
			// var charByte = Bytes.ofString(charCode, RawNative);
			// trace(charByte.length);
			/*
				if (charByte.length != 0) {
					var charCode1 = charByte.getString(0, 1, UTF8);
					var charCode2 = charByte.getString(1, 1, UTF8);
					charCode = charCode1 + charCode2;
			}*/
			#end
			// charCode = charCode + glyphCode;
			// trace(charCode.length);
			/*
				// Remix characters
				var charArray = charCode.split('');
				charArray.reverse();
				var charGlyph = '';
				for (i in charArray) {
					charGlyph = charGlyph + i;
				}
				charCode = charGlyph; */
		}
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
			isImageGlyph: isImageGlyph,
			glyphCode: glyphCode,
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
