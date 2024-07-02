package;

import format.gbs_otterui.GbsReader;
import format.gbs_otterui.Tools;
import format.gbs_otterui.GbsData;

using format.gbs_otterui.Tools;

class Main {
	static function main() {
		#if (cpp && debug)
		Sys.setCwd("..");
		#end

		trace("Program path: " + Sys.programPath());
		trace("Working directory: " + Sys.getCwd());

		new RepackingGbs().processingMain();
		trace('The End.');
	}
}
