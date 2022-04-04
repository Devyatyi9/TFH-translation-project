package tfhres;

import sys.db.*;
import cpp.Object;
import haxe.Json;

using Lambda;

typedef TfhResult = {
	hiberlite_id:Int,
	shortname:String,
	bytecode:Object
}

class SQLExport {
	var p:String;

	public function new(path) {
		this.p = path;
	}

	public function start() {
		var db = Sqlite.open(p);
		// test(db);
		var sql = 'SELECT bytecode, hiberlite_id, shortname FROM ink_bytecode';
		var rows = db.request(sql);
		decodeFile(rows);
		db.close();
	}

	var ignoreSceneID = [
		'ari_outercave1-anutrainingsession_talktome_78', 'blanktest_start_1', 'prompt_test_doortdest1_119', 'prompt_test_door_test_120',
		'prompt_test_dummyrock_123', 'prompt_test_othertrigger_113', 'prompt_test_testinteract1_117', 'prompt_test_walktrigger_111',
		'prompt_test_walk_talk_test_106', 'testroomd_deer1_187', 'testroomd_defaultstart_168', 'testroomd_rockinteract1_169', 'testroomd_snake1_175',
		'testroomd_snake2_186', 'testroomd_snakechest1_174', 'testroomd_wof1_202', 'testroome_blackness_destination_179', 'trade_test_defaultstart_28',
		'trade_test_madison_73', 'trade_test_thinking_statue_2_61', 'trade_test_thinking_statue_3_62', 'trade_test_thinking_statue_56'
	];

	// Main decode function
	function decodeFile(rows:ResultSet) {
		var output = [];
		var keyNum = 0;
		var skipped = 0;
		for (key in (rows : Iterator<TfhResult>)) {
			var sceneName = key.shortname;
			// database:/example.inkc
			sceneName = sceneName.split('database:/')[1].split('.inkc')[0];
			if (ignoreSceneID.contains(sceneName)) {
				skipped++;
				continue; // continue to next key in rows
			}

			var dialogues = Json.parse(key.bytecode).root[2]; // Root 2 contains dialogue related content
			output.push({
				hiberlite_id: key.hiberlite_id,
				scene: sceneName,
				text: {}
			}); // Creating header template so that decodeStuff has base to work with
			var elementNumber = keyNum - skipped;
			decodeStuff(dialogues, output[elementNumber].text);
			keyNum++;

			// dummy
			trace(dialogues);
			trace(key.hiberlite_id);
			trace(key.shortname);
			break;
		}
		var map1:Map<Int, String> = [1 => "one", 2 => "two"];
		trace(map1.get(2));

		// while() {}
		// return output;
	}

	var ignoreKeys = ['on_create'];
	// Every string starts with a '^' and is NOT followed by ':'
	var regExp = ~/^\^(?!:)/;

	// Recursive function that iterates over object copying its hierarchy and saving text from it
	function decodeStuff(dialogues:Map<String, String>, outputText) {
		for (key in dialogues) {
			if (ignoreKeys.contains(key))
				continue;
			var val = dialogues[key];
		}
	}

	/* 
		// Save file
		var saveOutput = (path, obj) -> {
			(Json.stringify(obj, null, 4) = sys.io.File.write(path), 'utf8', (err) -> {
				if (err)
					throw err;
				trace('Saved!');
			});
		}
	 */
	//
	// junk
	function test(db:sys.db.Connection) {
		// var sql = 'SELECT bytecode, hiberlite_id, shortname FROM ink_bytecode';
		// trace(db.dbName());
		// trace(db.sqlTest);
		// var sqllog = db.request(sqlTest);
		// trace(sqllog);
		// var sqllog2 = db.request(sqlTest);
		// trace(sqllog2);
		// trace(db);
		// db.close();
		//
		// var driver = new Sqlite();
		// var db = driver.open(p);
		// var sqlTest = 'SELECT * FROM citys;';
		var rsExample = db.request('SELECT * FROM artists_backup;');

		trace('-- SELECT * FROM artists_backup');
		for (record in (rsExample : Iterator<ArtistsBackupRecord>)) {
			trace('${record.artistid}) ${record.name} --> ${haxe.Json.stringify(record)}');
		}
	}
}

typedef ArtistsBackupRecord = {
	artistid:Int,
	name:String
}
