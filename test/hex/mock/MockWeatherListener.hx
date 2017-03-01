package hex.mock;

import hex.config.stateful.IStatefulConfig;
import hex.di.Dependency;
import hex.event.ITrigger;
import hex.module.Module;
import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;

/**
 * ...
 * @author Francis Bourre
 */
class MockWeatherListener extends Module
{
	public var temperature	: Int;
	public var weather		: String;
	
	public function new( config : IStatefulConfig ) 
	{
		super();
		
		this._addStatefulConfigs( [config] );

		//
		var temperatureTrigger = this._getDependency( new Dependency<ITrigger<Int->Void>>(), 'temperature' )
			.connect( this.setTemperature );
		
		var weatherTrigger = this._getDependency( new Dependency<ITrigger<String->Void>>(), 'weather' )
			.connect( this.setWeather );
	}
	
	override function _getRuntimeDependencies() : IRuntimeDependencies 
	{
		return new RuntimeDependencies();
	}
	
	public function setTemperature( temperature : Int ) : Void
	{
		this.temperature = temperature;
	}
	
	public function setWeather( weather : String ) : Void
	{
		this.weather = weather;
	}
}