package;

import format.gbs_otterui.*;
import haxe.ui.HaxeUIApp;

class Main {
	public static function main() {
		var app = new HaxeUIApp();

		var path = 'GuiScene_pixel.gbs';
		// var out = readGuiFile(path);
		var save_location = "TestGui_pixel.gbs";
		// writeGuiFile(save_location, out);

		app.ready(function() {
			app.addComponent(new MainView());

			app.start();
		});
	}

	static function readGuiFile(location:String) {
		var gi = sys.io.File.read(location);
		trace('Start of gbs file reading: "$location"');
		var gbs = new GbsReader(gi).read();
		gi.close();
		return gbs;
	}

	static function writeGuiFile(save_location, out:GbsData.GbsFile) {
		var go = sys.io.File.write(save_location);
		trace('Start of gbs file writing: "$save_location"');
		new GbsWriter(go).write(out);
		go.close();
	}
}
