package hex.ioc.core;

import hex.ioc.assembler.ApplicationAssembler;
import hex.di.IBasicInjector;
import hex.inject.Injector;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContext
{
	private var _name 					: String;
	private var _applicationAssembler 	: ApplicationAssembler;
	//private var _rootTarget 			: DisplayObjectContainer;
	
	private var _injector 				: IBasicInjector;
		
	public function new( applicationAssembler : ApplicationAssembler, name : String/*, rootTarget : DisplayObjectContainer = null*/ )
	{
		this._injector = new Injector();
		this._injector.mapToValue( IBasicInjector, this._injector );

		this._name 					= name;
		this._applicationAssembler 	= applicationAssembler;
		//this._rootTarget 			= rootTarget ? rootTarget : new MovieClip();
	}

	public function getName() : String
	{
		return this._name;
	}

	public function getInjector() : IBasicInjector
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