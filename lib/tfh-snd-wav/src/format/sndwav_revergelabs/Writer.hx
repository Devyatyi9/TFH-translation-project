package format.sndwav_revergelabs;

import haxe.io.Bytes;

class Writer {
	var o:haxe.io.Output;

	public function new(o) {
		this.o = o;
		o.bigEndian = false;
	}

	public function write() {}
}
