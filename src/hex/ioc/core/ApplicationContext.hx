package hex.ioc.core;
import hex.di.IDependencyInjector;
import hex.inject.Injector;
import hex.module.IModuleInjector;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContext
{
	private var _name 					: String;
	private var _applicationAssembler 	: ApplicationAssembler;
	//private var _rootTarget 			: DisplayObjectContainer;
	
	private var _injector 				: IModuleInjector = new Injector();
		
	public function new( applicationAssembler : ApplicationAssembler, name : String/*, rootTarget : DisplayObjectContainer = null*/ )
	{
		this._injector.mapToValue( IDependencyInjector, this._injector );
		this._injector.mapToValue( IModuleInjector, this._injector );

		this._name 					= name;
		this._applicationAssembler 	= applicationAssembler;
		//this._rootTarget 			= rootTarget ? rootTarget : new MovieClip();
	}

	public function getName() : String
	{
		return this._name;
	}

	public function getInjector() : IModuleInjector
	{
		return this._injector;
	}

	/*public function getRootTarget() : DisplayObjectContainer
	{
		return this._rootTarget;
	}

	override flash_proxy function callProperty(name:*,... rest):* {
		trace(name, rest);
	}

	override flash_proxy function hasProperty( name : * ) : Boolean
	{
		return this._applicationAssembler.getBuilderFactory( this ).getCoreFactory().isRegisteredWithKey( name );
	}

	override flash_proxy function getProperty( name : * ) : *
	{
		return this._applicationAssembler.getBuilderFactory( this ).getCoreFactory().locate( name );
	}*/

	public function addChild( applicationContext : ApplicationContext ) : Bool
	{
		//this._rootTarget.addChild( applicationContext.getRootTarget() );
		return this._applicationAssembler.getBuilderFactory( this ).getCoreFactory().register( applicationContext.getName(), applicationContext );
	}

}