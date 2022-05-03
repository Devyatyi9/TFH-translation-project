package;

import format.gfs_revergelabs.Reader;

class Main {
	static function main() {
		// Creating an array using array syntax and explicit type definition Array<String>
		// var strings:Array<String> = ["Apple", "Pear", "Banana"];
		// trace(strings);

		// var chars = [for (c in 65...70) String.fromCharCode(c)];
		// trace(chars); // ['A','B','C','D','E']

		// Save file to disk
		// var user = {name: "Mark", age: 31};
		// var content:String = haxe.Json.stringify(user);
		// sys.io.File.saveContent('test/my_file.json', content);

		// Cross platform paths
		// var location = "test/empty-container-04.gfs";
		// var location = "test/empty-container-04-aligned.gfs";
		var location = "test/test-failik.gfs";
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
		trace("File location: " + location);
		trace("Program path: " + Sys.programPath());
		trace("Working directory: " + Sys.getCwd());
		// Start
		gfsTestReadWrite(location);
	}

	// function new() {};
	static function gfsTestReadWrite(location:String) {
		// GFS Read
		var gi = sys.io.File.read(location);
		trace('Start of gfs file reading: "$location"');
		var myGFS = new Reader(gi).read();
		trace(myGFS.header);
		gi.seek(0, SeekBegin);
		var testFile2 = new Reader(gi).getFile(6); // 'test-file.txt'
		trace(testFile2.data);
		gi.seek(0, SeekBegin);
		var testFile1 = new Reader(gi).getFile('AI/combos/cow/Cow_3_WORK.ini'); // 'test-file2.txt'
		trace(testFile1.data);
		gi.close();

		/*
			// GFS Write
			var save_location = "test/TestLobby.gbs";
			//

			var go = sys.io.File.write(save_location);
			trace('Start of gbs file writing: "$save_location"');
			new GbsWriter(go).write(myGBS);
			go.close();
		 */
	}
}
