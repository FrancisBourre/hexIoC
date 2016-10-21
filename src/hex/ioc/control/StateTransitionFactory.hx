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
	
	static public function build( vo : StateTransitionVO, contextFactory : IContextFactory ) : Void
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
			//throw new BuildingException( "StateTransitionFactory.build failed with value object '" + vo + "'" );
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
	}
}