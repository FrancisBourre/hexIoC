package hex.ioc.parser.xml;

/**
 * @author Francis Bourre
 */
typedef XMLRawData =
{
	public var data 			: String;
	public var length 			: UInt;
	public var path 			: String;
	
	public var parent			: XMLRawData;
	public var children			: Array<XMLRawData>;
	
	public var header 			: UInt;
	public var position 		: UInt;
	public var includePosition : { pos : Int, len : Int };
	
	public var absLength 		: UInt;
	public var absPosition 		: UInt;
	public var absIncludeLength : UInt;
}