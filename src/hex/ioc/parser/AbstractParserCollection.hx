package hex.ioc.parser;

import hex.error.VirtualMethodException;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractParserCollection
{
	private var _index 						: Int;
	private var _parserCommandCollection 	: Array<AbstractParserCommand>;

	private function new()
	{
		this._index = -1;
		this._parserCommandCollection = [];
		this.buildParserList();
	}

	private function _buildParserList() : void
	{
		throw new VirtualMethodException( this + ".setParserList() must be implemented in concrete class." );
	}

	public function next() : IParserCommand
	{
		return _parserCommandCollection[ ++this._index ];
	}

	public function hasNext() : Bool
	{
		return _parserCommandCollection.length > this._index + 1;
	}

	public function reset() : Void
	{
		this._index = -1;
	}
}