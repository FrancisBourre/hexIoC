package hex.mock;

import hex.di.Dependency;
import hex.di.mapping.IDependencyOwner;
import hex.di.mapping.MappingDefinition;
import hex.event.ITrigger;
import hex.module.ContextModule;
import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;

/**
 * ...
 * @author Francis Bourre
 */
@Dependency( var temperature : ITrigger<Int->Void> )
@Dependency( var weather : ITrigger<String->Void> )
class MockWeatherListenerWithMappingDefinition extends ContextModule implements IDependencyOwner
{
	public var temperature	: Int;
	public var weather		: String;
	
	public function new( mapping : Array<MappingDefinition> ) 
	{
		super();

		@AfterMapping
		var temperatureTrigger = this._getDependency( new Dependency<ITrigger<Int->Void>>(), 'temperature' )
			.connect( this.setTemperature );
		
		var weatherTrigger = this._getDependency( new Dependency<ITrigger<String->Void>>(), 'weather' )
			.connect( this.setWeather );
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