package hex.ioc.control;

import hex.control.command.CommandMapping;
import hex.control.command.ICommand;
import hex.di.IContextOwner;
import hex.ioc.core.IContextFactory;
import hex.ioc.core.ICoreFactory;
import hex.ioc.di.ContextOwnerWrapper;
import hex.ioc.error.BuildingException;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;
import hex.ioc.vo.TransitionVO;
import hex.state.State;
import hex.state.StateUnmapper;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class StateTransitionFactory
{
	function new()
	{

	}
	
	static public function build( vo : StateTransitionVO, contextFactory : IContextFactory ) : Array<TransitionVO>
	{
		var coreFactory : ICoreFactory = contextFactory.getCoreFactory();
		
		var state : State;
		if ( vo.staticReference != null )
		{
			state = ClassUtil.getStaticVariableReference( vo.staticReference );
		}
		else if ( vo.instanceReference != null )
		{
			state = coreFactory.locate( vo.instanceReference );
		}
		else 
		{
			state = new State( vo.ID );
			coreFactory.register( vo.ID, state );
		}
		
		var stateUnmapper = StateUnmapper.register( state );
		
		if ( state == null )
		{
			throw new BuildingException( "StateTransitionFactory.build failed with value object '" + vo + "'" );
		}
		
		var enterList : Array<CommandMappingVO> = vo.enterList;
		for ( enterVO in enterList )
		{
			if ( enterVO.methodRef != null )
			{
				if ( enterVO.fireOnce )
				{
					throw new BuildingException( "transition's method callback cannot be fired once" );
				}
				
				var refs 		= enterVO.methodRef.split( "." );
				var ref 		= refs.shift();
				var methodName 	= refs.shift();
				
				state.addEnterHandler( function ( s : State )
				{ 
					var target = coreFactory.locate( ref );
					Reflect.callMethod( target, Reflect.field( target, methodName ), [ s ] ); 
				} );
			}
			else
			{
				var enterCommandClass : Class<ICommand> = cast ClassUtil.getClassReference( enterVO.commandClassName );
				var enterMapping = new CommandMapping( enterCommandClass );
				
				var enterContextOwner : IContextOwner = null;
				if ( enterVO.contextOwner != null )
				{
					enterContextOwner = new ContextOwnerWrapper( coreFactory, enterVO.contextOwner );
				}
				
				enterMapping.setContextOwner( enterContextOwner != null ? enterContextOwner : contextFactory.getApplicationContext() );
				if ( enterVO.fireOnce )
				{
					enterMapping.once();
				}
				state.addEnterCommandMapping( enterMapping );
				stateUnmapper.addEnterMapping( enterMapping  );
			}
		}
		
		var exitList : Array<CommandMappingVO> = vo.exitList;
		for ( exitVO in exitList )
		{
			if ( exitVO.methodRef != null )
			{
				if ( exitVO.fireOnce )
				{
					throw new BuildingException( "transition's method callback cannot be fired once" );
				}
				
				var refs 		= exitVO.methodRef.split( "." );
				var ref 		= refs.shift();
				var methodName 	= refs.shift();
				
				state.addExitHandler( function ( s : State )
				{ 
					var target = coreFactory.locate( ref );
					Reflect.callMethod( target, Reflect.field( target, methodName ), [ s ] ); 
				} );
			}
			else
			{
				var exitCommandClass : Class<ICommand> = cast ClassUtil.getClassReference( exitVO.commandClassName );
				var exitMapping = new CommandMapping( exitCommandClass );
				
				var exitContextOwner : IContextOwner = null;
				if ( exitVO.contextOwner != null )
				{
					exitContextOwner = new ContextOwnerWrapper( coreFactory, exitVO.contextOwner );
				}
				
				exitMapping.setContextOwner( exitContextOwner != null ? exitContextOwner : contextFactory.getApplicationContext() );
				if ( exitVO.fireOnce )
				{
					exitMapping.once();
				}
				state.addExitCommandMapping( exitMapping );
				stateUnmapper.addExitMapping( exitMapping  );
			}
		}
		
		var transitions : Array<TransitionVO> = vo.transitionList;
		for ( transition in transitions )
		{
			transition.stateVarName = vo.ID;
		}
		
		return transitions;
	}
	
	static public function flush( coreFactory : ICoreFactory, transitions : Array<TransitionVO> ) : Void
	{
		for ( transition in transitions )
		{
			var state : State = coreFactory.locate( transition.stateVarName );
			state.addTransition
			( 
				coreFactory.locate( transition.messageReference ), 
				coreFactory.locate( transition.stateReference ) 
			); 
		}
	}
}