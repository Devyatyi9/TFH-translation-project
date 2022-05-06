package;

import sys.FileSystem;
import haxe.io.Path;
import format.sndwav_revergelabs.*;
import format.sndwav_revergelabs.Data;

class SndWavRepacker {
	var i:sys.io.FileInput;

	public function new() {}

	public function unpack(location:String, ?another_location = '', ?ignoreSfx = false) {
		// Reader
		// todo: добавить игнор лист для звуков в конкретных файлах (only character voice)
		var i = sys.io.File.read(location);
		trace('Start of file reading snd-wav: "$location"');
		var sndWavFile = new Reader(i).read();
		i.close();
		//
		var path = new haxe.io.Path(location);
		var fileName = path.file;
		if (another_location.length > 0) {
			if (FileSystem.exists(another_location)) {} else {
				FileSystem.createDirectory(another_location);
			}
			another_location = Path.normalize(another_location);
			another_location = Path.addTrailingSlash(another_location);
			path = new haxe.io.Path(another_location);
		} else
			FileSystem.createDirectory('${path.dir}/${fileName}');
		trace(path);
		trace(path.dir);
		var soundsInfo = [];
		var jsonSoundsArray = {
			soundsInfo: []
		};
		//
		var it = 0;
		while (it < sndWavFile.soundsCount) {
			var soundData = sndWavFile.soundsBlock[it].soundFile;
			var format = sndWavFile.soundsBlock[it].soundFormat;
			// location
			var name = '';
			if (another_location.length > 0) {
				name = '${path.dir}/${fileName}_${it + 1}.${format}';
			} else {
				name = '${path.dir}/${fileName}/${fileName}_${it + 1}.${format}';
			}
			sys.io.File.saveBytes(name, soundData);
			trace('${fileName}_${it + 1}.${format}');
			var object:SoundJson = {
				SoundNumber: it,
				SoundName: '${fileName}_${it + 1}.${format}',
				Description: ''
			};
			soundsInfo.push(object);
			it++;
		}
		jsonSoundsArray.soundsInfo = soundsInfo;
		var stringifyJson = haxe.Json.stringify(jsonSoundsArray, "\t");
		// if location
		var save_location;
		if (another_location.length > 0) {
			save_location = Path.withExtension('${path.dir}/${fileName}', "json");
		} else
			save_location = Path.withExtension('${path.dir}/${fileName}/${fileName}', "json");
		sys.io.File.saveContent(save_location, stringifyJson);
	}

	function repack() {}
}

// Read/Write Test
function sndwavReadWrite(location:String) {
	// Snd-wav Read
	var i = sys.io.File.read(location);
	trace('Start of file reading snd-wav: "$location"');
	var mySndWav = new Reader(i).read();
	trace(mySndWav.soundsCount);
	i.close();

	// Snd-wav Write
	var save_location = "test/TestLobby.snd-wav";
	var o = sys.io.File.write(save_location);
	trace('Start of file writing snd-wav: "$save_location"');
	new Writer(o).write(mySndWav);
	o.close();
}
