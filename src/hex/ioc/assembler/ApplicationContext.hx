package hex.ioc.assembler;

import hex.config.stateful.IStatefulConfig;
import hex.config.stateless.IStatelessConfig;
import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.domain.DomainUtil;
import hex.error.IllegalArgumentException;
import hex.event.IDispatcher;
import hex.event.MessageType;
import hex.inject.Injector;
import hex.ioc.assembler.IApplicationAssembler;
import hex.log.Logger;
import hex.metadata.IMetadataProvider;
import hex.metadata.MetadataProvider;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContext implements Dynamic<ApplicationContext>
{
	private var _name 					: String;
	private var _applicationAssembler 	: IApplicationAssembler;
	private var _dispatcher 			: IDispatcher<{}>;
	private var _injector 				: Injector;
	private var _metadataProvider 		: IMetadataProvider;
		
	@:allow( hex.ioc.assembler )
	private function new( applicationAssembler : IApplicationAssembler, name : String )
	{
		var domain : Domain = DomainUtil.getDomain( name, Domain );
		this._dispatcher = ApplicationDomainDispatcher.getInstance().getDomainDispatcher( domain );
		
		this._injector = new Injector();
		this._injector.mapToValue( IBasicInjector, this._injector );
		this._injector.mapToValue( IDependencyInjector, this._injector );
		this._injector.mapToType( IMacroExecutor, MacroExecutor );
		
		this._metadataProvider 		= MetadataProvider.getInstance( this._injector );
		this._name 					= name;
		this._applicationAssembler 	= applicationAssembler;
	}
	
	@:allow( hex.ioc.assembler )
	private function _dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		this._dispatcher.dispatch( messageType, data );
	}
	
	/**
	 * Add collection of module configuration classes that 
	 * need to be executed before initialisation's end
	 * @param	configurations
	 */
	private function _addStatelessConfigClasses( configurations : Array<Class<IStatelessConfig>> ) : Void
	{
		var i : Int = configurations.length;
		while ( --i > -1 )
		{
			var configurationClass : Class<IStatelessConfig> = configurations[ i ];
			var configClassInstance : IStatelessConfig = this._injector.instantiateUnmapped( configurationClass );
			configClassInstance.configure();
		}
	}
	
	/**
	 * Add collection of runtime configurations that 
	 * need to be executed before initialisation's end
	 * @param	configurations
	 */
	private function _addStatefulConfigs( configurations : Array<IStatefulConfig> ) : Void
	{
		var i : Int = configurations.length;
		while ( --i > -1 )
		{
			var configuration : IStatefulConfig = configurations[ i ];
			if ( configuration != null )
			{
				configuration.configure( this._injector, this._dispatcher, null );
			}
		}
	}

	public function getName() : String
	{
		return this._name;
	}

	public function getInjector() : IBasicInjector
	{
		return this._injector;
	}
	
	function resolve( field : String )
	{
		return this._applicationAssembler.getBuilderFactory( this ).getCoreFactory().locate( field );
	}

	public function addChild( applicationContext : ApplicationContext ) : Bool
	{
		try
		{
			return this._applicationAssembler.getBuilderFactory( this ).getCoreFactory().register( applicationContext.getName(), applicationContext );
		}
		catch ( ex : IllegalArgumentException )
		{
			#if debug
			Logger.ERROR( "addChild failed with applicationContext named '" + applicationContext.getName() + "'" );
			#end
			return false;
		}
	}
}