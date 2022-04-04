package tfhres;

import sys.db.*;
import haxe.Json;

class SQLImport {
	var p:String;

	public function new(path) {
		this.p = path;
	}

	public function start(?questions:Bool) {
		if (questions == true) {
			trace('test1');
			// jsonFileToQuestionMarks(json);
			return;
		}
		var db = Sqlite.open(p);
		// test(db);
		var sql = 'SELECT bytecode, hiberlite_id, shortname FROM ink_bytecode';
		var rows = db.request(sql);
		encodeFile(rows);
		db.close();
	}

	// Main encode function
	function encodeFile(rows:ResultSet) {
		// const temp = require('./pixel_overworld_dialog_rus.json'); // Encoding happens from a temp.json file
		// const stmt = db.prepare('UPDATE ink_bytecode SET bytecode = ? WHERE hiberlite_id = ?'); // sql again
	}

	function encodeStuff(json, temp, ?adress) {}

	function jsonFileToQuestionMarks(json) {}
}
