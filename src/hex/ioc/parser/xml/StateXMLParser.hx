package hex.ioc.parser.xml;

import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;
import hex.ioc.vo.TransitionVO;

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
		var iterator = this.getContextData().firstElement().elementsNamed( "state" );
		while ( iterator.hasNext() )
		{
			var node = iterator.next();
			this._parseNode( node );
			this.getContextData().firstElement().removeChild( node );
		}
	}
	
	function _parseNode( xml : Xml ) : Void
	{
		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			throw new ParsingException( this + " encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
		}
		
		var staticReference 		= XMLAttributeUtil.getStaticRef( xml );
		var instanceReference 		= XMLAttributeUtil.getRef( xml );
		var enterList 				= this._buildList( xml, ContextNameList.ENTER );
		var exitList 				= this._buildList( xml, ContextNameList.EXIT );
		var transitionList 			= this._getTransitionList( xml, ContextNameList.TRANSITION );
		
		var stateTransitionVO 		= new StateTransitionVO( identifier, staticReference, instanceReference, enterList, exitList, transitionList );
		stateTransitionVO.ifList 	= XMLParserUtil.getIfList( xml );
		stateTransitionVO.ifNotList = XMLParserUtil.getIfNotList( xml );
		
		this._requestFactory.build( STATE_TRANSITION( stateTransitionVO ) );
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
							contextOwner: XMLAttributeUtil.getContextOwner( item ),
							methodRef: XMLAttributeUtil.getMethod( item )
						} );
		}
		
		return list;
	}
	
	function _getTransitionList( xml : Xml, nodeName : String ) : Array<TransitionVO>
	{
		var iterator = xml.elementsNamed( nodeName );
		var list : Array<TransitionVO> = [];
		while( iterator.hasNext() )
		{
			var transition = iterator.next();
			var message = transition.elementsNamed( ContextNameList.MESSAGE ).next();
			var state = transition.elementsNamed( ContextNameList.STATE ).next();
			
			var vo = new TransitionVO();
			vo.messageReference = message.get( ContextAttributeList.REF ) != null ?
													message.get( ContextAttributeList.REF ):
														message.get( ContextAttributeList.STATIC_REF );
														
			vo.stateReference = state.get( ContextAttributeList.REF ) != null ?
													state.get( ContextAttributeList.REF ):
														state.get( ContextAttributeList.STATIC_REF );
			list.push( vo );
		}
		
		return list;
	}
}