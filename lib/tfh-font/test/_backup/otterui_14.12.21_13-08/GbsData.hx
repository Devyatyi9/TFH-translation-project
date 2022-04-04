package otterui;

import haxe.Int32;

enum Tags {
	readFonts;
	readTextures;
	readSounds;
	readViews;
	readMessages;
}

// GGSC - Game Gui Scene
typedef GbsFile = {
	var header:GbsHeader;
	var fontsBlock:Array<GbsFont>;
	var textures:Null<haxe.io.Bytes>;
	var sounds:Null<haxe.io.Bytes>;
	var views:Null<haxe.io.Bytes>;
	var messages:Null<haxe.io.Bytes>;
}

typedef GbsHeader = {
	var fileSize:Int32;
	var dataVersion:Float;
	var sceneID:Int32;
	var fontsCount:Int32;
	var texturesCount:Int32;
	var soundsCount:Int32;
	var viewsCount:Int32;
	var messagesCount:Int32;
	var fontsOffset:Int32;
	var texturesOffset:Int32;
	var soundsOffset:Int32;
	var viewsOffset:Int32;
	var messagesOffset:Int32;
}

// GFNT - Gui Font
typedef GbsFont = {
	var fontLength:Int32;
	var fontID:Int32;
	var fontName:String;
	var fontSize:Int32;
	var atlasWidth:Int32;
	var atlasHeight:Int32;
	var maxTop:Int32;
	var atlasCount:Int32;
	var charsCount:Int32;
	var charsBlock:Array<GbsChar>;
}

enum ImageGlyph {
	yes;
	no;
}

typedef GbsChar = {
	var charCode:String;
	var imageGlyph:ImageGlyph;
	var charXOffset:Int32;
	var charYOffset:Int32;
	var charWidth:Int32;
	var charHeight:Int32;
	var charTop:Int32;
	var charAdvance:Int32;
	var charLeftBearing:Int32;
	var charAtlasIndex:Int32;
}
