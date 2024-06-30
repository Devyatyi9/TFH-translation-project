package;

import format.gbs_otterui.GbsData;
import format.gbs_otterui.GbsReader;
import format.gbs_otterui.GbsWriter;
import format.gbs_otterui.Tools;

class Test {
	static function main() {
		// new Main(); // 1

		// Creating an array using array syntax and explicit type definition Array<String>
		// var strings:Array<String> = ["Apple", "Pear", "Banana"];
		// trace(strings);

		// var chars = [for (c in 65...70) String.fromCharCode(c)];
		// trace(chars); // ['A','B','C','D','E']

		// For debugging
		#if (cpp && debug)
		Sys.setCwd("..");
		#end

		// Cross platform paths
		var location = "path/to/file.txt";
		var path = new haxe.io.Path(location);
		trace(path.dir); // path/to
		trace(path.file); // file
		trace(path.ext); // txt

		// combining path
		var directory = "path/to/";
		var file = "./file.txt";
		trace(haxe.io.Path.join([directory, file])); // path/to/file.txt
		trace('\n');

		// Check path
		trace("Program path: " + Sys.programPath());
		trace("Working directory: " + Sys.getCwd());

		// concatArray();
		// ArrayContains();

		// new PatchingGbs().processing();
		gbsTestReadWrite("test/ErrorWindows.gbs");
	}

	// 2
	// function new() {};
	// Read/Write Test GBS
	static function gbsTestReadWrite(location:String) {
		// GBS Read
		var gi = sys.io.File.read(location);
		trace('Start of gbs file reading: "$location"');
		var myGBS = new GbsReader(gi).read();
		gi.close();

		trace("Fonts count: " + myGBS.header.fontsCount);

		var fileInfo = Tools.fileExists(location);
		trace('$location:\nIs $fileInfo');

		// GBS Write
		var save_location = "test/TestLobby.gbs";
		//

		var go = sys.io.File.write(save_location);
		trace('Start of gbs file writing: "$save_location"');
		new GbsWriter(go).write(myGBS);
		go.close();

		// Checking written file
		var gi = sys.io.File.read(save_location);
		trace('Test start of gbs file reading: "$save_location"');
		var myGBS = new GbsReader(gi).read();
		// gi.checkOffsets;
		gi.close();
	}

	static function ArrayContains() {
		var a = [];
		a[5] = 'b';
		a[3] = "hello there";
		trace(a[5]);
		// trace(a);
		var s = a.contains('b');
		trace('array contains: ${s}');
		if (a[2] != null) {
			trace('success 2');
		}
		if (a[5] != null) {
			trace('success 5');
		}
	};

	static function concatArray() {
		var fontsBlock:GbsFont = {
			fontLength: 3900,
			fontID: 49,
			fontName: 'AccentMedWhite',
			fontSize: 30,
			atlasWidth: 256,
			atlasHeight: 256,
			maxTop: 26,
			atlasCount: 1,
			charsCount: 95,
			charsBlock: [
				{
					charCode: 'a',
					imageGlyph: no,
					charXOffset: 60,
					charYOffset: 27,
					charWidth: 26,
					charHeight: 20,
					charTop: 20,
					charAdvance: 22,
					charLeftBearing: -2,
					charAtlasIndex: 0
				}
			]
		};

		var charB:GbsChar = {
			charCode: 'b',
			imageGlyph: no,
			charXOffset: 78,
			charYOffset: 182,
			charWidth: 21,
			charHeight: 21,
			charTop: 21,
			charAdvance: 20,
			charLeftBearing: 0,
			charAtlasIndex: 0
		}

		var charB = [charB];

		var objectArray = {
			[fontsBlock];
		};

		trace(objectArray);
		trace(objectArray[0].fontName);
		trace(objectArray[0].charsBlock[0].charCode);

		// Конкатенация массивов
		objectArray[0].charsBlock = objectArray[0].charsBlock.concat(charB);
		trace(objectArray[0].charsBlock);

		trace(objectArray[0].charsBlock[1].charCode);

		trace(objectArray[0]);

		// Копирование массива
		var charsArray = objectArray[0].charsBlock.copy();
		trace(charsArray);
	}
}
