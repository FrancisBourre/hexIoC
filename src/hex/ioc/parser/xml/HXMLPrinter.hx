package hex.ioc.parser.xml;

/**
 * ...
 * @author Francis Bourre
 */
class HXMLPrinter
{
	static public function print( xml : HXml, ?pretty = false ) 
	{
		var printer = new HXMLPrinter( pretty );
		printer.writeNode( xml, "" );
		return printer.output.toString();
	}

	var output	: StringBuf;
	var pretty	: Bool;

	function new( pretty ) 
	{
		output = new StringBuf();
		this.pretty = pretty;
	}

	function writeNode( value : HXml, tabs : String ) 
	{
		switch (value.nodeType) {
			case CData:
				write(tabs + "<![CDATA[");
				write(StringTools.trim(value.nodeValue));
				write("]]>");
				newline();
			case Comment:
				var commentContent:String = value.nodeValue;
				commentContent = ~/[\n\r\t]+/g.replace(commentContent, "");
				commentContent = "<!--" + commentContent + "-->";
				write(tabs);
				write(StringTools.trim(commentContent));
				newline();
			case Document:
				for (child in value) {
					writeNode(child, tabs);
				}
			case Element:
				write(tabs + "<");
				write(value.nodeName);
				for (attribute in value.attributes()) {
					write(" " + attribute + "=\"");
					write(StringTools.htmlEscape(value.get(attribute), true));
					write("\"");
				}
				if (hasChildren(value)) {
					write(">");
					newline();
					for (child in value) {
						writeNode(child, pretty ? tabs + "\t" : tabs);
					}
					write(tabs + "</");
					write(value.nodeName);
					write(">");
					newline();
				} else {
					write("/>");
					newline();
				}
			case PCData:
				var nodeValue:String = value.nodeValue;
				if (nodeValue.length != 0) {
					write(tabs + StringTools.htmlEscape(nodeValue));
					newline();
				}
			case ProcessingInstruction:
				write("<?" + value.nodeValue + "?>");
			case DocType:
				write("<!DOCTYPE " + value.nodeValue + ">");
		}
	}

	inline function write(input:String) 
	{
		output.add(input);
	}

	inline function newline() 
	{
		if (pretty) {
			output.add("");
		}
	}

	function hasChildren(value:HXml):Bool 
	{
		for (child in value) {
			switch (child.nodeType) {
				case HXml.Element, HXml.PCData:
					return true;
				case HXml.CData, HXml.Comment:
					if (StringTools.ltrim(child.nodeValue).length != 0) {
						return true;
					}
				case _:
			}
		}
		return false;
	}
}