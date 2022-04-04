package format.gfs_revergelabs;

import format.gfs_revergelabs.Data;

class Writer {
	var o:haxe.io.Output;

	public function new(o) {
		this.o = o;
		o.bigEndian = true;
	}

	public function write(gfs) {
		writeHeader(gfs);
	}

	function writeHeader(gfs:GfsHeader) {
		o.writeInt32(gfs.data_offset);
		o.writeInt32(1);
		o.writeInt32(gfs.file_identifier_length);
		o.writeString(gfs.file_identifier);
		o.writeInt32(1);
		o.writeInt32(gfs.file_version_length);
		o.writeString(gfs.file_version);
		o.writeInt32(1);
		o.writeInt32(gfs.n_of_files);
	}
}
