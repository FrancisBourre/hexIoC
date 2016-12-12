package hex.compiler.parser.xml;

import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
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
class CompileTimeStateParser 
{
	var _assembler 		: IApplicationAssembler;
	var _importHelper 	: ClassImportHelper;
	
	public function new( assembler : IApplicationAssembler, importHelper : ClassImportHelper ) 
	{
		this._assembler 	= assembler;
		this._importHelper 	= importHelper;
	}
	
	public function parseNode( 	applicationContext : AbstractApplicationContext, 
								xml : Xml, 
								exceptionReporter : XmlAssemblingExceptionReporter 
							) : Void
	{
		var identifier = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			exceptionReporter.throwMissingIDException( xml );
		}
		
		var staticReference 		= xml.get( ContextAttributeList.STATIC_REF );
		var instanceReference 		= xml.get( ContextAttributeList.REF );
		
		var enterList 				= this._getCommandList( xml, ContextNameList.ENTER, exceptionReporter );
		var exitList 				= this._getCommandList( xml, ContextNameList.EXIT, exceptionReporter );
		var transitionList 			= this._getTransitionList( xml, exceptionReporter );
		
		var stateTransitionVO 		= new StateTransitionVO( identifier, staticReference, instanceReference, enterList, exitList, transitionList );
		stateTransitionVO.ifList 	= XMLParserUtil.getIfList( xml );
		stateTransitionVO.ifNotList = XMLParserUtil.getIfNotList( xml );
		
		stateTransitionVO.filePosition 	= exceptionReporter._positionTracker.makePositionFromNode( xml );
		this._assembler.configureStateTransition( applicationContext, stateTransitionVO );
	}
	
	function _getCommandList( xml : Xml, elementName : String, exceptionReporter : XmlAssemblingExceptionReporter ) : Array<CommandMappingVO>
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
				exceptionReporter.throwMissingTypeException( commandClass, item, ContextAttributeList.COMMAND_CLASS );
			}

			var commandMappingVO = 	{ 	commandClassName: commandClass, 
										fireOnce: item.get( ContextAttributeList.FIRE_ONCE ) == "true", 
										contextOwner: item.get( ContextAttributeList.CONTEXT_OWNER ),
										methodRef: methodRef,
										filePosition: exceptionReporter._positionTracker.makePositionFromNode( item )
									};

			list.push( commandMappingVO );
		}
		
		return list;
	}
	
	function _getTransitionList( xml : Xml, exceptionReporter : XmlAssemblingExceptionReporter ) : Array<TransitionVO>
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