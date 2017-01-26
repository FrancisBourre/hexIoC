package hex.compiler.factory;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiler.core.CompileTimeContextFactory;
import hex.control.command.CommandMapping;
import hex.ioc.di.ContextOwnerWrapper;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;
import hex.ioc.vo.TransitionVO;
import hex.state.State;
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
	static public function build( vo : StateTransitionVO, contextFactory : CompileTimeContextFactory ) : Array<TransitionVO>
	{
		var stateExp : Expr = null;
		if ( vo.staticReference != null )
		{
			stateExp = MacroUtil.getStaticVariable( vo.staticReference, vo.filePosition );
		}
		else if ( vo.instanceReference != null )
		{
			stateExp = macro coreFactory.locate( $v{ vo.instanceReference } );
		}
		else 
		{
			var StateClass = MacroUtil.getTypePath( Type.getClassName( State )  );
			stateExp = macro new $StateClass( $v{ vo.ID } );
		}

		var stateVarName = vo.ID;
		vo.expressions.push( macro @:mergeBlock { var $stateVarName = $stateExp; coreFactory.register( $v { vo.ID }, $i{stateVarName} ); } );
		
		var StateUnmapperClass 			= MacroUtil.getPack( Type.getClassName( StateUnmapper )  );
		var ContextOwnerWrapperClass 	= MacroUtil.getTypePath( Type.getClassName( ContextOwnerWrapper )  );
		var CommandMappingClass 		= MacroUtil.getTypePath( Type.getClassName( CommandMapping )  );
		
		vo.expressions.push( macro @:pos( vo.filePosition ) @:mergeBlock { var stateUnmapper = $p { StateUnmapperClass } .register( $i{stateVarName} ); } );
		
		var enterList : Array<CommandMappingVO> = vo.enterList;
		for ( enterVO in enterList )
		{
			if ( enterVO.methodRef != null )
			{
				if ( enterVO.fireOnce )
				{
					Context.error( "transition's method callback cannot be fired once", enterVO.filePosition );
				}
				
				var refs 		= enterVO.methodRef.split(".");
				var ref 		= refs.shift();
				var methodName 	= refs.shift();
				
				var methodCall = macro function ( s : State )
				{
					coreFactory.locate( $v{ref} ).$methodName( s );
				}
				vo.expressions.push( macro @:mergeBlock { $i{stateVarName}.addEnterHandler( $methodCall ); } );
			}
			else
			{
				var enterCommandClassName = MacroUtil.getPack( enterVO.commandClassName );
				vo.expressions.push( macro @:pos( enterVO.filePosition ) @:mergeBlock { var enterMapping = new $CommandMappingClass( $p { enterCommandClassName } ); } );
				
				if ( enterVO.contextOwner != null )
				{
					vo.expressions.push( macro @:pos( enterVO.filePosition ) @:mergeBlock { enterMapping.setContextOwner( new $ContextOwnerWrapperClass( coreFactory, $v{ enterVO.contextOwner } ) ); } );
				}
				else
				{
					vo.expressions.push( macro @:pos( enterVO.filePosition ) @:mergeBlock { enterMapping.setContextOwner( applicationContext ); } );
				}
				
				if ( enterVO.fireOnce )
				{
					vo.expressions.push( macro @:pos( enterVO.filePosition ) @:mergeBlock { enterMapping.once(); } );
				}
				
				vo.expressions.push( macro @:mergeBlock { $i{stateVarName}.addEnterCommandMapping( enterMapping ); } );
				vo.expressions.push( macro @:mergeBlock { stateUnmapper.addEnterMapping( enterMapping ); } );
			}
		}
		
		var exitList : Array<CommandMappingVO> = vo.exitList;
		for ( exitVO in exitList )
		{
			if ( exitVO.methodRef != null )
			{
				if ( exitVO.fireOnce )
				{
					Context.error( "transition's method callback cannot be fired once", exitVO.filePosition );
				}
				
				var refs 		= exitVO.methodRef.split(".");
				var ref 		= refs.shift();
				var methodName 	= refs.shift();
				
				var methodCall = macro function ( s : State )
				{
					coreFactory.locate( $v{ref} ).$methodName( s );
				}
				vo.expressions.push( macro @:mergeBlock { $i{stateVarName}.addExitHandler( $methodCall ); } );
			}
			else
			{
				var exitCommandClassName = MacroUtil.getPack( exitVO.commandClassName );
				vo.expressions.push( macro @:pos( exitVO.filePosition ) @:mergeBlock { var exitMapping = new $CommandMappingClass( $p { exitCommandClassName } ); } );
				
				if ( exitVO.contextOwner != null )
				{
					vo.expressions.push( macro @:pos( exitVO.filePosition ) @:mergeBlock { exitMapping.setContextOwner( new $ContextOwnerWrapperClass( coreFactory, $v{ exitVO.contextOwner } ) ); } );
				}
				else
				{
					vo.expressions.push( macro @:pos( exitVO.filePosition ) @:mergeBlock { exitMapping.setContextOwner( applicationContext ); } );
				}
				
				if ( exitVO.fireOnce )
				{
					vo.expressions.push( macro @:pos( exitVO.filePosition ) @:mergeBlock { exitMapping.once(); } );
				}
				
				vo.expressions.push( macro @:mergeBlock { $i{stateVarName}.addExitCommandMapping( exitMapping ); } );
				vo.expressions.push( macro @:mergeBlock { stateUnmapper.addExitMapping( exitMapping ); } );
			}
		}
		
		var transitions : Array<TransitionVO> = vo.transitionList;
		for ( transition in transitions )
		{
			transition.stateVarName = stateVarName;
		}
		
		return transitions;
	}
	
	static public function flush( expressions : Array<Expr>, transitions: Array<TransitionVO> ) : Void
	{
		for ( transition in transitions )
		{
			var stateVarName = transition.stateVarName;

			expressions.push( macro @:mergeBlock 
			{ 
				$i{stateVarName}.addTransition
				( 
					$i{transition.messageReference}, 
					$i{transition.stateReference} 
				); 
			} );
		}
	}
	#end
}