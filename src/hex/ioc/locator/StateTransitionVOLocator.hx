package hex.ioc.locator;

import hex.collection.HashMap;
import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.control.command.CommandMapping;
import hex.control.command.ICommand;
import hex.control.command.ICommandMapping;
import hex.di.IContextOwner;
import hex.ioc.core.IContextFactory;
import hex.ioc.core.ICoreFactory;
import hex.ioc.di.ContextOwnerWrapper;
import hex.ioc.error.BuildingException;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;
import hex.state.State;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class StateTransitionVOLocator extends Locator<String, StateTransitionVO>
{
	var _contextFactory : IContextFactory;
	var _stateUnmapper : HashMap<State, StateUnmapper>;

	public function new( contextFactory : IContextFactory )
	{
		super();
		
		this._contextFactory 	= contextFactory;
		this._stateUnmapper 	= new HashMap();
	}
	
	public function buildStateTransition( key : String ) : Void
	{
		if ( this.isRegisteredWithKey( key ) )
		{
			var vo : StateTransitionVO = this.locate( key );
			var coreFactory : ICoreFactory = this._contextFactory.getCoreFactory();
			
			var state : State = null;
			if ( vo.staticReference != null )
			{
				state = ClassUtil.getStaticReference( vo.staticReference );
			}
			else if ( vo.instanceReference != null )
			{
				state = coreFactory.locate( vo.instanceReference );
			}
			else 
			{
				throw new BuildingException( this + ".buildStateTransition failed with id '" + key + "'" );
			}
			
			var stateUnmapper : StateUnmapper = null;
			if ( !this._stateUnmapper.containsKey( state ) )
			{
				stateUnmapper = new StateUnmapper( state );
				this._stateUnmapper.put( state, stateUnmapper );
			}
			else
			{
				stateUnmapper = this._stateUnmapper.get( state );
			}
			
			if ( state == null )
			{
				throw new BuildingException( this + ".buildStateTransition failed with '" + vo + "'" );
			}
			
			var enterList : Array<CommandMappingVO> = vo.enterList;
			for ( enterVO in enterList )
			{
				var enterCommandClass : Class<ICommand> = cast ClassUtil.getClassReference( enterVO.commandClassName );
				var enterMapping = new CommandMapping( enterCommandClass );
				
				var enterContextOwner : IContextOwner = null;
				if ( enterVO.contextOwner != null )
				{
					enterContextOwner = new ContextOwnerWrapper( coreFactory, enterVO.contextOwner );
				}
				
				enterMapping.setContextOwner( enterContextOwner != null ? enterContextOwner : this._contextFactory.getApplicationContext() );
				if ( enterVO.fireOnce )
				{
					enterMapping.once();
				}
				state.addEnterCommandMapping( enterMapping );
				stateUnmapper.addEnterMapping( enterMapping  );
			}
			
			var exitList : Array<CommandMappingVO> = vo.exitList;
			for ( exitVO in exitList )
			{
				var exitCommandClass : Class<ICommand> = cast ClassUtil.getClassReference( exitVO.commandClassName );
				var exitMapping = new CommandMapping( exitCommandClass );
				
				var exitContextOwner : IContextOwner = null;
				if ( exitVO.contextOwner != null )
				{
					exitContextOwner = new ContextOwnerWrapper( coreFactory, exitVO.contextOwner );
				}
				
				exitMapping.setContextOwner( exitContextOwner != null ? exitContextOwner : this._contextFactory.getApplicationContext() );
				if ( exitVO.fireOnce )
				{
					exitMapping.once();
				}
				state.addExitCommandMapping( exitMapping );
				stateUnmapper.addExitMapping( exitMapping  );
			}
			
			this.unregister( key );
		}
	}
	
	override public function release() : Void
	{
		var stateUnmappers : Array<StateUnmapper> = this._stateUnmapper.getValues();
		for ( unmapper in stateUnmappers ) unmapper.unmap();
		super.release();
	}
	
	override function _dispatchRegisterEvent( key : String, element : StateTransitionVO ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.REGISTER, [ key, element ] );
	}
	
	override function _dispatchUnregisterEvent( key : String ) : Void 
	{
		this._dispatcher.dispatch( LocatorMessage.UNREGISTER, [ key ] );
	}
}

private class StateUnmapper
{
	var _state 			: State;
	var _enterMappings 	: Array<ICommandMapping> = [];
	var _exitMappings 	: Array<ICommandMapping> = [];
	
	public function new( state : State )
	{
		this._state = state;
	}
	
	public function unmap() : Void
	{
		for ( m in this._enterMappings ) this._state.removeEnterCommandMapping( m );
		for ( m in this._exitMappings ) this._state.removeEnterCommandMapping( m );
		
		this._state 		= null;
		this._enterMappings = null;
		this._exitMappings 	= null;
	}
	
	public function addEnterMapping( mapping : ICommandMapping ) : Void
	{
		this._enterMappings.push( mapping );
	}
	
	public function addExitMapping( mapping : ICommandMapping ) : Void
	{
		this._exitMappings.push( mapping );
	}
}