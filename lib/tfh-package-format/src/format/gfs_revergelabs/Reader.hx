package format.gfs_revergelabs;

import haxe.io.Bytes;
import haxe.Int32;
import format.gfs_revergelabs.Data;

class Reader {
	var i:sys.io.FileInput;

	public function new(i) {
		this.i = i;
		i.bigEndian = true;
	}

	public function read() {
		var header = parseHeader();
		var metaInfBlock = [];
		var _ = 0;
		while (_ < header.n_of_files) {
			metaInfBlock.push(fileInfo());
			_++;
		}
		// переписать код, убрав блок для данных
		// сделать получение данных файлов по запросу (опциональный параметр)
		var dataBlock = [];
		var running_offset = header.data_offset;
		/*
			_ = 0;
			while (_ < header.n_of_files) {
				var fileDataInstance = fileData(_, running_offset, metaInfBlock);
				dataBlock.push(fileDataInstance.fData);
				running_offset = fileDataInstance.running_offset;
				_++;
			}
		 */
		// GfsMetadataEntry:
		// local_path
		// offset
		// size

		trace('Gfs file has been read.');
		return {
			header: header,
			metaInfBlock: metaInfBlock,
			dataBlock: dataBlock
		}
	}

	function parseHeader():GfsHeader {
		var data_offset = i.readInt32();
		if (data_offset < 48)
			throw 'Gfs file header is too short.';
		i.readInt32();
		var file_identifier_length = i.readInt32();
		var file_identifier = i.readString(file_identifier_length);
		if (file_identifier != 'Reverge Package File')
			throw 'File is not a valid gfs file.';
		i.readInt32();
		var file_version_length = i.readInt32();
		var file_version = i.readString(file_version_length);
		i.readInt32();
		var n_of_files = i.readInt32();

		return {
			data_offset: data_offset,
			file_identifier_length: file_identifier_length,
			file_identifier: file_identifier,
			file_version_length: file_version_length,
			file_version: file_version,
			n_of_files: n_of_files
		}
	}

	function fileInfo():GfsFileInfo {
		i.readInt32();
		var file_path_length = i.readInt32();
		var reference_path = i.readString(file_path_length);
		i.readInt32();
		var reference_length = i.readInt32();
		var reference_alignment = i.readInt32();

		return {
			file_path_length: file_path_length,
			reference_path: reference_path,
			reference_length: reference_length,
			reference_alignment: reference_alignment
		}
	}

	function fileData(it:Int32, running_offset:Int32, metaInfBlock) {
		running_offset += (metaInfBlock[it].reference_alignment - (running_offset % metaInfBlock[it].reference_alignment)) % metaInfBlock[it].reference_alignment;
		trace(running_offset);
		// skip empty space (alignment)
		i.read(running_offset);
		var size = metaInfBlock[it].reference_length;
		var fData = Bytes.alloc(0);
		if (size > 0) {
			fData = i.read(size);
		}
		trace(fData);
		return {
			running_offset: running_offset += metaInfBlock[it].reference_length,
			fData: fData
		};
	}
}
