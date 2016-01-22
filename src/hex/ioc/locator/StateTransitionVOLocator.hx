package hex.ioc.locator;

import hex.collection.HashMap;
import hex.collection.Locator;
import hex.collection.LocatorMessage;
import hex.control.command.CommandMapping;
import hex.control.command.ICommand;
import hex.control.command.ICommandMapping;
import hex.ioc.di.ContextOwnerWrapper;
import hex.di.IBasicInjector;
import hex.di.IContextOwner;
import hex.ioc.core.BuilderFactory;
import hex.ioc.core.CoreFactory;
import hex.ioc.error.BuildingException;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.StateTransitionVO;
import hex.state.State;

/**
 * ...
 * @author Francis Bourre
 */
class StateTransitionVOLocator extends Locator<String, StateTransitionVO>
{
	private var _builderFactory : BuilderFactory;
	private var _stateUnmapper : HashMap<State, StateUnmapper>;

	public function new( builderFactory : BuilderFactory )
	{
		super();
		
		this._builderFactory 	= builderFactory;
		this._stateUnmapper 	= new HashMap();
	}
	
	public function build() 
	{
		var keys : Array<String> = this.keys();
		for ( key in keys )
		{
			this.buildStateTransition( key );
		}
	}
	
	public function buildStateTransition( key : String ) : Void
	{
		if ( this.isRegisteredWithKey( key ) )
		{
			var vo : StateTransitionVO = this.locate( key );
			var coreFactory : CoreFactory = this._builderFactory.getCoreFactory();
			
			
			var state : State = null;
			if ( vo.staticReference != null )
			{
				state = coreFactory.getStaticReference( vo.staticReference );
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
				var enterCommandClass : Class<ICommand> = cast coreFactory.getClassReference( enterVO.commandClassName );
				var enterMapping : ICommandMapping = new CommandMapping( enterCommandClass );
				
				var enterContextOwner : IContextOwner = null;
				if ( enterVO.contextOwner != null )
				{
					enterContextOwner = new ContextOwnerWrapper( coreFactory, enterVO.contextOwner );
				}
				
				enterMapping.setContextOwner( enterContextOwner != null ? enterContextOwner : this._builderFactory.getApplicationContext() );
				state.addEnterCommandMapping( enterMapping );
				stateUnmapper.addEnterMapping( enterMapping  );
			}
			
			var exitList : Array<CommandMappingVO> = vo.exitList;
			for ( exitVO in exitList )
			{
				var exitCommandClass : Class<ICommand> = cast coreFactory.getClassReference( exitVO.commandClassName );
				var exitMapping : ICommandMapping = new CommandMapping( exitCommandClass );
				
				var exitContextOwner : IContextOwner = null;
				if ( exitVO.contextOwner != null )
				{
					exitContextOwner = new ContextOwnerWrapper( coreFactory, exitVO.contextOwner );
				}
				
				exitMapping.setContextOwner( exitContextOwner != null ? exitContextOwner : this._builderFactory.getApplicationContext() );
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
	private var _state 			: State;
	private var _enterMappings 	: Array<ICommandMapping> = [];
	private var _exitMappings 	: Array<ICommandMapping> = [];
	
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