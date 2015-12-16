package hex.ioc.parser.xml.mock;

import hex.data.IParser;

/**
 * ...
 * @author Francis Bourre
 */
class MockXMLParser implements IParser
{
	public function new() 
	{
		
	}
	
	public function parse( serializedContent : Dynamic, target : Dynamic = null ) : Dynamic 
	{
		var collection : Array<MockFruitVO> = [];
		var xml : Xml = cast serializedContent ;
		
		var iterator = xml.firstElement().elements();
		while( iterator.hasNext() )
		{
			var item = iterator.next();
			collection.push( new MockFruitVO( item.firstChild().nodeValue ) );

		}
		return collection;
	}
}