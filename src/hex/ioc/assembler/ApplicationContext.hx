package hex.ioc.assembler;

import hex.control.macro.IMacroExecutor;
import hex.control.macro.MacroExecutor;
import hex.di.IBasicInjector;
import hex.error.IllegalArgumentException;
import hex.inject.Injector;
import hex.ioc.assembler.IApplicationAssembler;
import hex.log.Logger;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContext implements Dynamic<ApplicationContext>
{
	private var _name 					: String;
	private var _applicationAssembler 	: IApplicationAssembler;
	//private var _rootTarget 			: DisplayObjectContainer;
	
	private var _injector 				: IBasicInjector;
		
	@:allow(hex.ioc.assembler)
	private function new( applicationAssembler : IApplicationAssembler, name : String/*, rootTarget : DisplayObjectContainer = null*/ )
	{
		this._injector = new Injector();
		this._injector.mapToValue( IBasicInjector, this._injector );
		this._injector.mapToType( IMacroExecutor, MacroExecutor );

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
	}*/
	
	function resolve( field : String )
	{
		return this._applicationAssembler.getBuilderFactory( this ).getCoreFactory().locate( field );
	}

	public function addChild( applicationContext : ApplicationContext ) : Bool
	{
		//this._rootTarget.addChild( applicationContext.getRootTarget() );
		
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