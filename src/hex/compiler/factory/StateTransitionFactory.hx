package hex.compiler.factory;

import haxe.macro.Context;
import hex.control.command.CommandMapping;
import hex.ioc.core.IContextFactory;
import hex.ioc.di.ContextOwnerWrapper;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;
import hex.state.StateUnmapper;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class StateTransitionFactory
{
	function new()
	{

	}
	
	#if macro
	static public function build( vo : StateTransitionVO, contextFactory : IContextFactory ) : Void
	{
		if ( vo.staticReference != null )
		{
			//state = ClassUtil.getStaticVariableReference( vo.staticReference );
			var stateReference = MacroUtil.getStaticVariable( vo.staticReference );
			vo.expressions.push( macro @:mergeBlock { var state = $stateReference; } );
		}
		else if ( vo.instanceReference != null )
		{
			//TODO solve this bug
			//var exp = Context.parseInlineString( vo.instanceReference, Context.currentPos() );
			//vo.expressions.push( macro @:mergeBlock { var state = $exp; } );
			
			vo.expressions.push( macro @:mergeBlock { var state = coreFactory.locate( $v{ vo.instanceReference } ); } );
		}
		else 
		{
			Context.error( "StateTransitionFactory.build failed with value object '" + vo + "'", Context.currentPos() );
		}
		
		var StateUnmapperClass 			= MacroUtil.getPack( Type.getClassName( StateUnmapper )  );
		var ContextOwnerWrapperClass 	= MacroUtil.getTypePath( Type.getClassName( ContextOwnerWrapper )  );
		var CommandMappingClass 		= MacroUtil.getTypePath( Type.getClassName( CommandMapping )  );
		
		vo.expressions.push( macro @:mergeBlock { var stateUnmapper = $p { StateUnmapperClass } .register( state ); } );

		var enterList : Array<CommandMappingVO> = vo.enterList;
		for ( enterVO in enterList )
		{
			var enterCommandClassName = MacroUtil.getPack( enterVO.commandClassName );
			vo.expressions.push( macro @:mergeBlock { var enterMapping = new $CommandMappingClass( $p { enterCommandClassName } ); } );
			
			if ( enterVO.contextOwner != null )
			{
				vo.expressions.push( macro @:mergeBlock { enterMapping.setContextOwner( new $ContextOwnerWrapperClass( coreFactory, $v{ enterVO.contextOwner } ) ); } );
			}
			else
			{
				vo.expressions.push( macro @:mergeBlock { enterMapping.setContextOwner( __applicationContext ); } );
			}
			
			if ( enterVO.fireOnce )
			{
				vo.expressions.push( macro @:mergeBlock { enterMapping.once(); } );
			}
			
		vo.expressions.push( macro @:mergeBlock { state.addEnterCommandMapping( enterMapping ); } );
		vo.expressions.push( macro @:mergeBlock { stateUnmapper.addEnterMapping( enterMapping ); } );
		}
		
		var exitList : Array<CommandMappingVO> = vo.exitList;
		for ( exitVO in exitList )
		{
			var exitCommandClassName = MacroUtil.getPack( exitVO.commandClassName );
			vo.expressions.push( macro @:mergeBlock { var exitMapping = new $CommandMappingClass( $p { exitCommandClassName } ); } );
			
			if ( exitVO.contextOwner != null )
			{
				vo.expressions.push( macro @:mergeBlock { exitMapping.setContextOwner( new $ContextOwnerWrapperClass( coreFactory, $v{ exitVO.contextOwner } ) ); } );
			}
			else
			{
				vo.expressions.push( macro @:mergeBlock { exitMapping.setContextOwner( __applicationContext ); } );
			}
			
			if ( exitVO.fireOnce )
			{
				vo.expressions.push( macro @:mergeBlock { exitMapping.once(); } );
			}
			
			vo.expressions.push( macro @:mergeBlock { state.addExitCommandMapping( exitMapping ); } );
			vo.expressions.push( macro @:mergeBlock { stateUnmapper.addExitMapping( exitMapping ); } );
		}
	}
	#end
}