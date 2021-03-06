package;

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
		// sys.io.File.saveContent('src/my_file.json', content);

		// For debugging
		#if (cpp && debug)
		Sys.setCwd("..");
		#end

		// Cross platform paths
		var location = "test/dbsqlite/Test_old_resources_prod.tfhres";
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
		trace("File location: " + Sys.getCwd() + location);

		// SQLite export
		// new tfhres.SQLExport(location).start();
		// new TestSqliteLib(location).start();
		var jsonLocation = 'test/story_prologue_default_start_8.json';
		jsonTest(jsonLocation);
	}

	// function new() {};

	static function jsonTest(path) {
		var i = sys.io.File.getContent(path);
		var o:{root:Array<Dynamic>} = tink.Json.parse(i);
		// var o:{root:Array<Array<Item>>} = tink.Json.parse(i);
		trace(o.root[2]); // .root[2]
	}
}
