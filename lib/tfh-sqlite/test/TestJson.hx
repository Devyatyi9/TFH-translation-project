@:jsonParse(function(json) return new Item(json[0], json[1]))
class Item {
	public var status(default, null):String;
	public var value(default, null):String;

	public function new(status:String, value:String) {
		this.status = status;
		this.value = value;
	}
}
// root:Array<Array<Item>>
