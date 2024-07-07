package;

class Main {
	static function main() {
		#if (cpp && debug)
		Sys.setCwd("..");
		#end

		trace("Program path: " + Sys.programPath());
		trace("Working directory: " + Sys.getCwd());

		new RepackingGbs().processingMiracleFont();
		// new RepackingGbs().processingMain();
		trace('The End.');
	}
}
