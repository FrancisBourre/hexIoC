package hex.compiler.parser.xml;

import haxe.macro.Context;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.parser.xml.XMLParserUtil;
import hex.ioc.parser.xml.XmlAssemblingExceptionReporter;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;
import hex.ioc.vo.TransitionVO;

/**
 * ...
 * @author Francis Bourre
 */
class StateParser extends AbstractXmlParser 
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var applicationContext 	= this.getApplicationAssembler().getApplicationContext( this._getRootApplicationContextName() );
		var iterator 			= this.getContextData().firstElement().elementsNamed( "state" );
		
		while ( iterator.hasNext() )
		{
			var node = iterator.next();
			this._parseNode( applicationContext, node );
			this.getContextData().firstElement().removeChild( node );
		}
	}
	
	function _parseNode( applicationContext : AbstractApplicationContext, xml : Xml ) : Void
	{
		var identifier = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			Context.error
			( 
				"Parsing error with '" + xml.nodeName + 
				"' node, 'id' attribute not found.", 
				this._exceptionReporter.getPosition( xml ) );
		}
		
		var staticReference 		= xml.get( ContextAttributeList.STATIC_REF );
		var instanceReference 		= xml.get( ContextAttributeList.REF );
		
		var enterList 				= this._getCommandList( xml, ContextNameList.ENTER );
		var exitList 				= this._getCommandList( xml, ContextNameList.EXIT );
		var transitionList 			= this._getTransitionList( xml );
		
		var stateTransitionVO 		= new StateTransitionVO( identifier, staticReference, instanceReference, enterList, exitList, transitionList );
		stateTransitionVO.ifList 	= XMLParserUtil.getIfList( xml );
		stateTransitionVO.ifNotList = XMLParserUtil.getIfNotList( xml );
		
		stateTransitionVO.filePosition 	= this._exceptionReporter.getPosition( xml );
		this._applicationAssembler.configureStateTransition( applicationContext, stateTransitionVO );
	}
	
	function _getCommandList( xml : Xml, elementName : String ) : Array<CommandMappingVO>
	{
		var iterator = xml.elementsNamed( elementName );
		var list : Array<CommandMappingVO> = [];
		while( iterator.hasNext() )
		{
			var item = iterator.next();
			var commandClass = item.get( ContextAttributeList.COMMAND_CLASS );
			var methodRef = item.get( ContextAttributeList.METHOD );
			try
			{
				this._importHelper.forceCompilation( commandClass );
			}
			catch ( e : String )
			{
				this._throwMissingTypeException( commandClass, item, ContextAttributeList.COMMAND_CLASS );
			}

			var commandMappingVO = 	{ 	commandClassName: commandClass, 
										fireOnce: item.get( ContextAttributeList.FIRE_ONCE ) == "true", 
										contextOwner: item.get( ContextAttributeList.CONTEXT_OWNER ),
										methodRef: methodRef,
										filePosition: this._exceptionReporter.getPosition( item )
									};

			list.push( commandMappingVO );
		}
		
		return list;
	}
	
	function _getTransitionList( xml : Xml ) : Array<TransitionVO>
	{
		var iterator = xml.elementsNamed( ContextNameList.TRANSITION );
		var list : Array<TransitionVO> = [];
		
		while( iterator.hasNext() )
		{
			var transition = iterator.next();
			var message = transition.elementsNamed( ContextNameList.MESSAGE ).next();
			var state = transition.elementsNamed( ContextNameList.STATE ).next();

			var vo = new TransitionVO();
			vo.messageReference = message.get( 	ContextAttributeList.REF ) != null ?
													message.get( ContextAttributeList.REF ):
														message.get( ContextAttributeList.STATIC_REF );
														
			vo.stateReference = state.get( 	ContextAttributeList.REF ) != null ?
												state.get( ContextAttributeList.REF ):
													state.get( ContextAttributeList.STATIC_REF );
			list.push( vo );
		}
		
		return list;
	}
	
}