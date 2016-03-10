package hex.ioc.parser.xml;

import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.ContextNameList;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.CommandMappingVO;

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
		var applicationContext : AbstractApplicationContext 		= this.getApplicationContext();
		var applicationAssembler : IApplicationAssembler 	= this.getApplicationAssembler();

		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			throw new ParsingException( this + " encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
		}
		
		var staticReference 	: String = XMLAttributeUtil.getStaticRef( xml );
		var instanceReference 	: String = XMLAttributeUtil.getRef( xml );
		
		// Build enter list
		var enterListIterator = xml.elementsNamed( ContextNameList.ENTER );
		var enterList : Array<CommandMappingVO> = [];
		while( enterListIterator.hasNext() )
		{
			var enterListItem = enterListIterator.next();
			enterList.push( new CommandMappingVO( XMLAttributeUtil.getCommandClass( enterListItem ), XMLAttributeUtil.getFireOnce( enterListItem ), XMLAttributeUtil.getContextOwner( enterListItem ) ) );
		}
		
		// Build exit list
		var exitListIterator = xml.elementsNamed( ContextNameList.EXIT );
		var exitList : Array<CommandMappingVO> = [];
		while( exitListIterator.hasNext() )
		{
			var exitListItem = exitListIterator.next();
			exitList.push( new CommandMappingVO( XMLAttributeUtil.getCommandClass( exitListItem ), XMLAttributeUtil.getFireOnce( exitListItem ), XMLAttributeUtil.getContextOwner( exitListItem ) ) );
		}
		
		applicationAssembler.configureStateTransition( applicationContext, identifier, staticReference, instanceReference, enterList, exitList );
	}
}