package;

import haxe.ds.ObjectMap;
import format.gbs_otterui.GbsData;
import format.gbs_otterui.GbsReader;
import format.gbs_otterui.GbsWriter;
import format.gbs_otterui.Tools;
// import format.wav.Reader;
import haxe.io.Bytes;

using format.gbs_otterui.Tools;

// import sys.FileSystem;
class RepackingGbs {
	public function new() {}

	public function processing() {
		// Cross platform paths
		var eLocation = "otterui-project/Import/Import-pixel-ui/BuckLobby.gbs";
		var ePath = new haxe.io.Path(eLocation);
		trace(ePath.dir); // path/to
		trace(ePath.file); // file
		trace(ePath.ext); // txt

		// var location = "test/BuckLobby.gbs";
		// var location = "test/Transitions.gbs";
		// var location = "test/my_file.txt";
		var location = "test/ImageGlyph-test.gbs";
		// var location = "otterui-project/Import/Import-pixel-ui/BuckLobby.gbs";
		// var location = "otterui-project/OtterExport/Export-pixel-ui/Scenes_pixel.gbs";

		// gbsTestReadWrite(location);

		//**PIXEL**/

		// Load export gbs
		var atlases_export_pixel = "otterui-project/OtterExport/Export-pixel-ui/Fonts";
		// путь с файлами до OtterExport - pixel-ui
		var fileList_export_pixel = recursiveDir("otterui-project/OtterExport/Export-pixel-ui");
		//
		// путь с файлами до Import - pixel-ui
		var fileList_import_pixel = recursiveDir("otterui-project/Import/Import-pixel-ui");
		//
		// путь до Merged - pixel-ui
		var path_merged_pixel = "otterui-project/Merged/pixel-ui-merged";
		//

		// здесь проверяем массив сцен на наличие шрифтов
		fileList_import_pixel = arrayCheckFonts(fileList_import_pixel);

		// Импортируемые игровые файлы
		var objectList_import_pixel = readGbsList(fileList_import_pixel);
		//***

		var objectList_export_pixel = readGbsList(fileList_export_pixel);
		fileList_export_pixel = [];

		trace(objectList_import_pixel[0].header.sceneID);
		trace(objectList_export_pixel[0].header.sceneID);

		#if debug
		trace("debug");
		#end

		// objectList_export_pixel - получаем отсюда (строковый массив) список названий шрифтов
		// objectList_import_pixel
		// после добавления символов в шрифт, увеличивать длину шрифта на количество добавленных шрифтов
		// 1 структура символа 40 байт

		// var fNames_export_main = getFontNames(objectList_export_main);
		// function (object_export:Array<GbsFile>, object_import:Array<GbsFile>)

		// saveAsJson(objectList_export_pixel);

		// mergeCycle(objectList_export_pixel, objectList_import_pixel);

		var translatedFonts = fontsAllocate(objectList_export_pixel);
		objectList_export_pixel = [];

		var fromGameFonts = fontsComparingAllocate(translatedFonts, objectList_import_pixel);
		trace('test');
		mergeFonts(fromGameFonts, translatedFonts, atlases_export_pixel);

		//**MAIN**/

		// Load export gbs
		var atlases_export_main = "otterui-project/OtterExport/Export-main-ui/Fonts";
		// путь с файлами до OtterExport - main-ui
		var fileList_export_main = recursiveDir("otterui-project/OtterExport/Export-main-ui");
		//
		// путь с файлами до Import - main-ui
		var fileList_import_main = recursiveDir("otterui-project/Import/Import-main-ui");
		//
		// путь до Merged - main-ui
		var path_merged_main = "otterui-project/Merged/main-ui-merged";
		//

		// здесь проверяем массив сцен на наличие шрифтов
		fileList_import_main = arrayCheckFonts(fileList_import_main);

		// Импортируемые игровые файлы
		var objectList_import_main = readGbsList(fileList_import_main);
		//***

		var objectList_export_main = readGbsList(fileList_export_main);

		trace(objectList_import_main[0].header.sceneID);
		trace(objectList_export_main[0].header.sceneID);
	}

	function mergeFonts(importMap:Map<Int, GbsFont>, exportMap:Map<Int, GbsFont>, atlases_export:String) {
		for (key in importMap.keys()) {
			trace('ключ ${key}');
			var exportVal = exportMap[key];
			var importVal = importMap[key];

			// перебор по translated символам (exported)
			var nCharE = 0;
			while (nCharE < exportVal.charsBlock.length) {
				// trace('***');
				// перебор по fromGame символам (imported)
				var nCharI = 0;
				while (nCharI < importVal.charsCount) {
					var charCodeExp = exportVal.charsBlock[nCharE].charCode;
					var charCodeImp = importVal.charsBlock[nCharI].charCode;
					// trace('char translated: ${charCodeExp}');
					// trace('char from game: ${charCodeImp}');
					// сначала проверяется наличие таких же символов, одинаковые символы удаляются из translated
					// после все уникальные символы добавляются в конец массива fromGame
					#if utf16
					if ((charCodeExp == charCodeImp) || (charCodeExp == '?')) { // '?'
					#elseif !utf16
					if ((charCodeExp == charCodeImp) || (charCodeExp == '?\x00')) { // '?\x00'
					#end
						var charExpObj = exportVal.charsBlock[nCharE];
						exportVal.charsBlock.remove(charExpObj);
						nCharI = 0;
						trace('removed character ${charExpObj.charCode} from array');
						// trace('length: ${exportVal.charsBlock.length}');
						continue;
					}
					nCharI++;
				}
				var charCodeExp = exportVal.charsBlock[nCharE].charCode;
				// trace('character translated: ${charCodeExp}');
				nCharE++;
			}
			trace('characters has been filtrated');
			// скорректировать число атласов и индексы атласов у символов
			// здесь добавляем символы из exported в imported
			var impCount = importVal.charsCount - 1;
			var impIndex = importVal.charsBlock[impCount].charAtlasIndex;
			nCharE = 0;
			while (nCharE < exportVal.charsBlock.length) {
				var expIndex = exportVal.charsBlock[nCharE].charAtlasIndex;
				// trace(expIndex);
				var curIndex = impIndex + expIndex + 1;
				exportVal.charsBlock[nCharE].charAtlasIndex = curIndex;
				// trace('curIndex: ${curIndex} expIndex: ${expIndex}');
				nCharE++;
			}
			// не забыть переименовать png файлы шрифтов под новое значение индексов
			var expIndex = exportVal.charsBlock[0].charAtlasIndex;
			trace(expIndex);
			trace('nCharE: ${nCharE}');
			// atlases_export;
		}

		// сравнение по MaxTop
		// сравнение по длине шрифта
		// сравнение по количеству атласов
		// сравнение по количеству символов
		// сравнение символов по индексам
		// пересчитать длину шрифта
	}

	function fontsAllocate(o:Array<GbsFile>) {
		var fontsMap:Map<Int, GbsFont> = [];
		var nScene = 0;
		while (nScene < o.length) {
			var nFont = 0;
			while (nFont < o[nScene].header.fontsCount) {
				var content = o[nScene].fontsBlock[nFont];
				var idFont = o[nScene].fontsBlock[nFont].fontID;
				// trace('scene number: ${nScene}');
				// trace('font number: ${nFont}');
				// trace('font id: ${idFont}');
				fontsMap.set(idFont, content);
				nFont++;
			}
			nScene++;
		}
		// var h = fontsMap.exists(55);
		// trace('exist id: ${h}');
		return fontsMap;
	}

	function fontsComparingAllocate(map:Map<Int, GbsFont>, o:Array<GbsFile>) {
		var objectsMap:Map<Int, GbsFont> = [];
		var nScene = 0;
		while (nScene < o.length) {
			var nFont = 0;
			while (nFont < o[nScene].header.fontsCount) {
				var idFont = o[nScene].fontsBlock[nFont].fontID;
				if (map.exists(idFont)) {
					// trace('scene number: ${nScene}');
					// trace('font number: ${nFont}');
					// trace('font id: ${idFont}');
					var content = o[nScene].fontsBlock[nFont];
					objectsMap.set(idFont, content);
				}
				nFont++;
			}
			nScene++;
		}
		return objectsMap;
	}

	function saveAsJson(o) {
		// var o = {name: "Mark", age: 31};
		var test:String = haxe.Json.stringify(o, "\t");
		sys.io.File.saveContent('my_file.json', test);
	}

	function fusionCycle(object_export:Array<GbsFile>, object_import:Array<GbsFile>) {}
} function getChars(array:Array<GbsFile>, fN:Int) {
	var tmp = [];
	var i = 0;
	while (i < array[0].fontsBlock[fN].charsCount) {
		var o = array[0].fontsBlock[fN].charsBlock[i];
		tmp.push(o);
		i++;
	}
	return tmp;
}

function getFontNames(array:Array<GbsFile>) {
	var tmp = [];
	var i = 0;
	while (i < array[0].header.fontsCount) {
		var o = array[0].fontsBlock[i].fontName;
		tmp.push(o);
		i++;
	}
	return tmp;
}

function readGbsList(array:Array<String>) {
	var tmp = [];
	var i = 0;
	while (i < array.length) {
		var o = readGuiFile(array[i]);
		tmp.push(o);
		i++;
	}
	return tmp;
}

function readGuiFile(location:String) {
	var gi = sys.io.File.read(location);
	trace('Start of gbs file reading: "$location"');
	var gbs = new GbsReader(gi).read();
	gi.close();
	return gbs;
}

// Recursive loop through all directories / files
function recursiveDir(directory:String) {
	var paths = [];
	if (sys.FileSystem.exists(directory)) {
		trace("Reading directory: " + directory);
		for (file in sys.FileSystem.readDirectory(directory)) {
			var path = haxe.io.Path.join([directory, file]);
			if (!sys.FileSystem.isDirectory(path)) {
				var fileExt = new haxe.io.Path(path);
				if (fileExt.ext == "gbs" && Tools.fileExists(path) == true) {
					// trace('Gbs file found: $file');
					paths.push(path);
				}
			}
		}
	} else {
		trace('Unable to scan directory: "$directory"');
	}
	return paths;
}

function arrayCheckFonts(array:Array<String>) {
	var tmp = [];
	var i = 0;
	while (i < array.length) {
		if (Tools.checkFonts(array[i]) == true) {
			tmp.push(array[i]);
		}
		i++;
	}
	return array = tmp;
}

function objectCheckOffsets(array:Array<GbsFile>, n:Int) {
	var fileSize = array[n].header.fileSize;
	var fontsOffset = array[n].header.fontsOffset;
	var texturesOffset = array[n].header.texturesOffset;
	var soundsOffset = array[n].header.soundsOffset;
	var viewsOffset = array[n].header.viewsOffset;
	var messagesOffset = array[n].header.messagesOffset;

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
}

// Read/Write Test GBS
function gbsTestReadWrite(location:String) {
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
}
