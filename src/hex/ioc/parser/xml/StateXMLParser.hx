package hex.ioc.parser.xml;

import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.ContextNameList;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;

/**
 * ...
 * @author Francis Bourre
 */
class StateXMLParser extends AbstractXMLParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var iterator = this.getXMLContext().firstElement().elementsNamed( "state" );
		while ( iterator.hasNext() )
		{
			var node = iterator.next();
			this._parseNode( node );
			this.getXMLContext().firstElement().removeChild( node );
		}

		this._handleComplete();
	}
	
	function _parseNode( xml : Xml ) : Void
	{
		var applicationContext = this.getApplicationContext();
		var applicationAssembler = this.getApplicationAssembler();

		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			throw new ParsingException( this + " encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
		}
		
		var staticReference 		= XMLAttributeUtil.getStaticRef( xml );
		var instanceReference 		= XMLAttributeUtil.getRef( xml );
		var enterList 				= this._buildList( xml, ContextNameList.ENTER );
		var exitList 				= this._buildList( xml, ContextNameList.EXIT );
		
		var stateTransitionVO 		= new StateTransitionVO( identifier, staticReference, instanceReference, enterList, exitList );
		stateTransitionVO.ifList 	= XMLParserUtil.getIfList( xml );
		stateTransitionVO.ifNotList = XMLParserUtil.getIfNotList( xml );
		
		applicationAssembler.configureStateTransition( applicationContext, stateTransitionVO );
	}
	
	function _buildList( xml : Xml, nodeName : String ) : Array<CommandMappingVO>
	{
		var it = xml.elementsNamed( nodeName );
		var list : Array<CommandMappingVO> = [];
		while( it.hasNext() )
		{
			var item = it.next();
			list.push( { 
							commandClassName: XMLAttributeUtil.getCommandClass( item ), 
							fireOnce: XMLAttributeUtil.getFireOnce( item ), 
							contextOwner: XMLAttributeUtil.getContextOwner( item ) 
						} );
		}
		return list;
	}
}