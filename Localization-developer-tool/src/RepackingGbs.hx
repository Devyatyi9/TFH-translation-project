package;

import haxe.Int32;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import haxe.ds.ObjectMap;
import format.gbs_otterui.GbsData;
import format.gbs_otterui.GbsReader;
import format.gbs_otterui.GbsWriter;
import format.gbs_otterui.Tools;
import haxe.io.Bytes;

using Lambda;
using format.gbs_otterui.Tools;

class RepackingGbs {
	public function new() {}

	public function processingMain() {
		//**MAIN**/

		// Load export gbs
		var atlases_export_main = "otterui-project/TheMiracle/Fonts";
		// путь с файлами до OtterExport - main-ui
		var fileList_export_main = recursiveDir("otterui-project/TheMiracle");
		//
		// путь с файлами до Import - main-ui
		var fileList_import_main = recursiveDir("otterui-project/Import");
		//
		// путь до Merged - main-ui
		var path_merged_main = "otterui-project/Merged";
		//

		// здесь проверяем массив сцен на наличие шрифтов
		fileList_import_main = arrayCheckFonts(fileList_import_main);

		if (fileList_export_main.length == 0 || fileList_import_main.length == 0) {
			trace('Warning! Export or Import main folder is empty.');
			return;
		}

		// Импортируемые игровые файлы
		var objectList_import_main = readGbsList(fileList_import_main);
		//***

		var objectList_export_main = readGbsList(fileList_export_main);
		fileList_export_main = [];

		var translatedFonts = fontsAllocate(objectList_export_main);
		objectList_export_main = [];
		var fromGameFonts = fontsComparingAllocate(translatedFonts, objectList_import_main);

		mergeFonts(fromGameFonts, translatedFonts);

		mapToObjects(fromGameFonts, objectList_import_main);

		calculateGbsLength(objectList_import_main);

		// write new gbs files
		writeMergedGbs(objectList_import_main, path_merged_main, fileList_import_main);
		fileList_import_main = [];

		renamingPng(atlases_export_main, path_merged_main, translatedFonts, fromGameFonts);
		fromGameFonts.clear();
		translatedFonts.clear();
		objectList_import_main = [];

		#if debug
		var location = "otterui-project/Merged/MainMenu.gbs";
		if (Tools.fileExists(location)) {
			var gi = sys.io.File.read(location);
			trace('Start of gbs file reading: "$location"');
			var myGBS = new GbsReader(gi).read();
			gi.checkOffsets;
			gi.close();
		}
		#end
	}

	public function processingMiracleFont() {
		//**MAIN**/

		// Load export gbs
		var atlases_export_main = "otterui-project/TheMiracle/Fonts";
		// путь с файлами до OtterExport - main-ui
		var fileList_export_main = recursiveDir("otterui-project/TheMiracle");
		//
		// путь с файлами до Import - main-ui
		var fileList_import_main = recursiveDir("otterui-project/Import");
		//
		// путь до Merged - main-ui
		var path_merged_main = "otterui-project/Merged";
		//

		// здесь проверяем массив сцен на наличие шрифтов
		fileList_import_main = arrayCheckFonts(fileList_import_main);

		if (fileList_export_main.length == 0 || fileList_import_main.length == 0) {
			trace('Warning! Export or Import main folder is empty.');
			return;
		}

		// Импортируемые игровые файлы
		var objectList_import_main = readGbsList(fileList_import_main);
		//***

		var objectList_export_main = readGbsList(fileList_export_main);
		fileList_export_main = [];

		var translatedFonts = fontsAllocate(objectList_export_main);
		objectList_export_main = [];

		// нормализация атлас индексов и фильтрация TheMiracle
		var fontResortMap = normalizeCharsIndex(translatedFonts, atlases_export_main);
		normalizeAtlasIndex(translatedFonts, atlases_export_main, fontResortMap);

		var fromGameFonts = fontsComparingAllocate(translatedFonts, objectList_import_main);

		mergeFonts(fromGameFonts, translatedFonts);

		mapToObjects(fromGameFonts, objectList_import_main);

		calculateGbsLength(objectList_import_main);

		// write new gbs files
		writeMergedGbs(objectList_import_main, path_merged_main, fileList_import_main);
		fileList_import_main = [];

		renamingPng(atlases_export_main, path_merged_main, translatedFonts, fromGameFonts);
		fromGameFonts.clear();
		translatedFonts.clear();
		objectList_import_main = [];

		#if debug
		var location = "otterui-project/Merged/MainMenu.gbs";
		if (Tools.fileExists(location)) {
			var gi = sys.io.File.read(location);
			trace('Start of gbs file reading: "$location"');
			var myGBS = new GbsReader(gi).read();
			gi.checkOffsets;
			gi.close();
		}
		#end
	}

	function normalizeCharsIndex(fontsMap:Map<Int, GbsFont>, atlasesPath:String) {
		atlasesPath = Path.addTrailingSlash(atlasesPath);
		var indexResortMap:Map<Int, Int> = []; // oldIndex newIndex for Characters table
		var fontResortMap:Map<Int, Int> = [];
		for (fontKey in fontsMap.keys()) {
			var currentFont = fontsMap[fontKey];
			var fontName = currentFont.fontName;
			var maxIndex = currentFont.atlasCount;
			var newIndex = 0;
			// перебираем атласы и проверяем с какого индекса существуют, заполняем resortMap
			for (oldIndex in 0...maxIndex) {
				var fs = sys.FileSystem;
				var nameDds = atlasesPath + fontName + '_${oldIndex}.dds';
				var namePng = atlasesPath + fontName + '_${oldIndex}.png';
				if ((fs.exists(nameDds) && !fs.isDirectory(nameDds)) || (fs.exists(namePng) && !fs.isDirectory(namePng))) {
					indexResortMap.set(oldIndex, newIndex);
					if (!fontResortMap.exists(fontKey)) {
						fontResortMap.set(fontKey, oldIndex);
					}
					newIndex++;
				}
			}
			// удаляем символы с индексом ниже первого oldIndex
			var newFontArray:Array<GbsChar> = [];
			var internalIndex = 0;
			for (index => charKey in fontsMap[fontKey].charsBlock) {
				var atlasIndex = charKey.charAtlasIndex;
				if (indexResortMap.exists(atlasIndex)) {
					// если нашло тогда меняем атлас индекс на новый
					charKey.charAtlasIndex = indexResortMap[atlasIndex];
					newFontArray[internalIndex] = charKey;
					internalIndex++;
				}
			}
			currentFont.charsBlock = newFontArray;
			currentFont.charsCount = newFontArray.length;
			currentFont.atlasCount = indexResortMap.count();
			indexResortMap.clear();
		}
		return fontResortMap;
	}

	function normalizeAtlasIndex(fontsMap:Map<Int, GbsFont>, atlasesPath:String, fontResortMap:Map<Int, Int>) {
		atlasesPath = Path.addTrailingSlash(atlasesPath);
		for (fontKey in fontResortMap.keys()) {
			var currentFont = fontsMap[fontKey];
			var fontName = currentFont.fontName;
			var oldIndex = fontResortMap.get(fontKey);
			for (i in 0...currentFont.atlasCount) {
				var fs = sys.FileSystem;
				var nameDds = atlasesPath + fontName + '_${oldIndex}.dds';
				var namePng = atlasesPath + fontName + '_${oldIndex}.png';
				if (fs.exists(nameDds) && !fs.isDirectory(nameDds)) {
					var newNameDds = atlasesPath + fontName + '_${i}.dds';
					fs.rename(nameDds, newNameDds);
				} else if ((fs.exists(namePng) && !fs.isDirectory(namePng))) {
					var newNamePng = atlasesPath + fontName + '_${i}.png';
					fs.rename(namePng, newNamePng);
				}
				oldIndex++;
			}
		}
	}

	function renamingPng(read_path:String, save_path:String, translated:Map<Int, GbsFont>, fromGame:Map<Int, GbsFont>) {
		// переименовать png файлы шрифтов под новое значение индексов
		// по количеству атласов в импорте и экспорте (импорт + экспорт + 1)
		var read_path = Path.addTrailingSlash(read_path);
		var save_path = Path.addTrailingSlash(save_path);
		for (key in translated.keys()) {
			var impFont = fromGame[key];
			var expFont = translated[key];
			if (expFont.atlasCount != 0) {
				var maxAtlasIndexImp = impFont.atlasCount - expFont.atlasCount - 1;
				for (i in 0...expFont.atlasCount) {
					var newIndex = maxAtlasIndexImp + i + 1;
					if (newIndex < 0) {
						throw 'Incorrect newIndex value format: ${newIndex}';
					} else {
						var name = expFont.fontName + '_${i}';
						// trace(i);
						// trace(newIndex);
						recursiveDir(read_path, name, save_path, newIndex);
					}
				}
			}
		}
	}

	function writeMergedGbs(objectList:Array<GbsFile>, path:String, name:Array<String>) {
		var i = 0;
		while (i < objectList.length) {
			var save_location = path + '/' + name[i];
			if (FileSystem.exists(path)) {} else
				FileSystem.createDirectory(path);
			var go = sys.io.File.write(save_location);
			trace('Start of gbs file writing: "$save_location"');
			new GbsWriter(go).write(objectList[i]);
			go.close();
			i++;
		}
	}

	function calculateGbsLength(objectList:Array<GbsFile>) {
		for (gui in objectList) {
			// здесь суммируем длину всех шрифтов в объекте
			var allFontsLength = 0;
			var i = 0;
			while (i < gui.fontsBlock.length) {
				allFontsLength += gui.fontsBlock[i].fontLength;
				i++;
			}
			// calculating offsets
			var fileSize = gui.header.fileSize;
			var fontsOffset = gui.header.fontsOffset;
			var texturesOffset = gui.header.texturesOffset;

			var fontsToFileEnd = fileSize - (fontsOffset + 56);
			var texturesToFileEnd = fileSize - (texturesOffset + 56);

			var oldFontsLength = fontsToFileEnd - texturesToFileEnd;
			var currentOffset = allFontsLength - oldFontsLength;

			gui.header.texturesOffset = currentOffset + gui.header.texturesOffset;
			gui.header.soundsOffset = currentOffset + gui.header.soundsOffset;
			gui.header.viewsOffset = currentOffset + gui.header.viewsOffset;
			gui.header.messagesOffset = currentOffset + gui.header.messagesOffset;
			gui.header.fileSize = currentOffset + gui.header.fileSize;
		}
	}

	function mapToObjects(map:Map<Int, GbsFont>, objectList:Array<GbsFile>) {
		// objectList[0].fontsBlock[0].fontLength
		// objectList[0].fontsBlock[0].fontID
		// map[0].fontLength
		// map[0].fontID
		// fontID = key
		for (key in map.keys()) {
			var nGui = 0;
			while (nGui < objectList.length) {
				var nFont = 0;
				while (nFont < objectList[nGui].fontsBlock.length) {
					var id = objectList[nGui].fontsBlock[nFont].fontID;
					if (id == key) {
						var objectLength = objectList[nGui].fontsBlock[nFont].fontLength;
						var mapLength = map[key].fontLength;
						if (objectLength != mapLength) {
							objectList[nGui].fontsBlock[nFont] = map[key];
						}
					}
					nFont++;
				}
				nGui++;
			}
		}
	}

	function mergeFonts(importMap:Map<Int, GbsFont>, exportMap:Map<Int, GbsFont>) {
		for (key in importMap.keys()) {
			trace('merging font key: ${key}');
			var exportVal = exportMap[key];
			var importVal = importMap[key];

			// перебор по translated символам (exported)
			var nCharE = 0;
			while (nCharE < exportVal.charsBlock.length) {
				// перебор по fromGame символам (imported)
				var nCharI = 0;
				while (nCharI < importVal.charsBlock.length) {
					var charCodeExp = exportVal.charsBlock[nCharE].charCode;
					var charCodeImp = importVal.charsBlock[nCharI].charCode;
					#if utf16
					if ((charCodeExp == charCodeImp) || (charCodeExp == '?')) { // '?'
					#else
					if ((charCodeExp == charCodeImp) || (charCodeExp == '?\x00')) { // '?\x00'
					#end
						var charExpObj = exportVal.charsBlock[nCharE];
						exportVal.charsBlock.remove(charExpObj);
						// trace('indexI ${nCharI}');
						trace('removed character ${charExpObj.charCode} from array');
						if (nCharE == exportVal.charsBlock.length) {
							break;
						}
						nCharI = 0;
						// trace('length: ${exportVal.charsBlock.length}');
						// trace('indexE ${nCharE}');
					}
					nCharI++;
				}
				nCharE++;
				// var charCodeExp = exportVal.charsBlock[nCharE].charCode;
				// trace('character translated: ${charCodeExp}');
			}
			trace('characters in map has been filtrated');
			if (exportVal.charsCount > 0 && exportVal.charsBlock.length > 0) {
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
				// var expIndex = exportVal.charsBlock[0].charAtlasIndex;
				// trace(expIndex);
				// trace('nCharE: ${nCharE}');
				var atlasSum = exportVal.atlasCount + importVal.atlasCount;
				importVal.atlasCount = atlasSum;
				if (exportVal.maxTop > importVal.maxTop)
					importVal.maxTop = exportVal.maxTop;
				for (char in exportVal.charsBlock) {
					importVal.charsBlock.push(char);
				}
				exportVal.charsBlock = [];
				importVal.charsCount = importVal.charsBlock.length;
				importVal.fontLength = importVal.charsCount * 40 + 100;
				// trace(importVal.fontLength);
			} else
				exportVal.atlasCount = 0;
		}

		// сравнение по MaxTop
		// сравнение по длине шрифта
		// сравнение по количеству атласов
		// сравнение по количеству символов
		// сравнение символов по индексам
		// пересчитать длину шрифта
		// после добавления символов в шрифт, увеличивать длину шрифта на количество добавленных шрифтов
		// 1 структура символа 40 байт
		// заголовок шрифта 100 байт
	}

	function fontsAllocate(obj:Array<GbsFile>) {
		var fontsMap:Map<Int, GbsFont> = [];
		var idFontCache:Array<Int> = [];
		var nScene = 0;
		while (nScene < obj.length) {
			var nFont = 0;
			while (nFont < obj[nScene].header.fontsCount) {
				var idFont = obj[nScene].fontsBlock[nFont].fontID;
				if (idFontCache.contains(idFont)) {
					nFont++;
					continue;
				} else {
					var content:GbsFont = obj[nScene].fontsBlock[nFont];
					// trace('scene number: ${nScene}');
					// trace('font number: ${nFont}');
					// trace('font id: ${idFont}');
					fontsMap.set(idFont, content);
					idFontCache.push(idFont);
				}
				nFont++;
			}
			nScene++;
		}
		idFontCache = [];
		// var h = fontsMap.exists(55);
		// trace('exist id: ${h}');
		return fontsMap;
	}

	function fontsComparingAllocate(map:Map<Int, GbsFont>, obj:Array<GbsFile>) {
		var objectsMap:Map<Int, GbsFont> = [];
		var nScene = 0;
		while (nScene < obj.length) {
			var nFont = 0;
			while (nFont < obj[nScene].header.fontsCount) {
				var idFont = obj[nScene].fontsBlock[nFont].fontID;
				if (map.exists(idFont)) {
					// trace('scene number: ${nScene}');
					// trace('font number: ${nFont}');
					// trace('font id: ${idFont}');
					var content = obj[nScene].fontsBlock[nFont];
					objectsMap.set(idFont, content);
				}
				nFont++;
			}
			nScene++;
		}
		return objectsMap;
	}

	function readGbsList(array:Array<String>) {
		var tmp = [];
		var i = 0;
		while (i < array.length) {
			var o = readGuiFile(array[i]);
			tmp.push(o);
			var path = haxe.io.Path.withoutDirectory(array[i]);
			array[i] = path;
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
	function recursiveDir(directory:String, ?pngName:String, ?savePath:String, ?newIndex:Int) {
		var fs = sys.FileSystem;
		var paths = [];
		if (fs.exists(directory)) {
			trace("Reading directory: " + directory);
			for (file in fs.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				if (!fs.isDirectory(path)) {
					var fileExt = new haxe.io.Path(path);
					if (fileExt.ext == "gbs" && Tools.fileExists(path) == true) {
						// trace('Gbs file found: $file');
						paths.push(path);
					}
					if (fileExt.ext == "png" || fileExt.ext == "dds") {
						// здесь будет переименовывание файлов по индексам
						var fileName = fileExt.file;
						if (pngName == fileName) {
							var newName = fileExt.file.split('_');
							var dstPath = savePath + 'Fonts' + '/' + newName[0] + '_${newIndex}.' + fileExt.ext;
							// dstPath = Path.normalize(dstPath); //for unix-systems maybe
							if (fs.exists(savePath + 'Fonts')) {} else
								fs.createDirectory(savePath + 'Fonts');
							File.copy(path, dstPath);
							trace('${fileExt.file} has been copied');
						}
					}
				}
			}
		} else {
			trace('Unable to scan directory: "$directory"');
			fs.createDirectory(directory);
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

		// Checking written file
		var gi = sys.io.File.read(save_location);
		trace('Test start of gbs file reading: "$save_location"');
		var myGBS = new GbsReader(gi).read();
		gi.checkOffsets;
		gi.close();
	}
}
