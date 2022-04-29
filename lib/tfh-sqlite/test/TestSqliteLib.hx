import sys.db.*;
import sys.db.Types;

class User extends sys.db.Object {
	public var hiberlite_id:Int;
	public var shortname:String;
	public var bytecode:String;
}

class TestSqliteLib {
	var p:String;

	public function new(path) {
		this.p = path;
	}

	public function start() {
		// sys.db.Manager.initialize();
		// var db = Sqlite.open(p);
		// sys.db.Manager.
		var db = sys.db.Manager.cnx = sys.db.Sqlite.open(p);
		var sql = 'SELECT bytecode, hiberlite_id, shortname FROM ink_bytecode';
		var rows = db.request(sql);
		decodeFile(rows);
		trace('test.');
	}

	// Main decode function
	function decodeFile(rows:ResultSet) {
		var output = [];
		var keyNum = 0;
		var skipped = 0;
		// for (key in (rows : Iterator<TfhResult>)) {}
		// for (key in (rows : User)) {}
	}
}
