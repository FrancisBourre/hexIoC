package hex.ioc.parser.xml.mock;

import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;
import hex.module.Module;

/**
 * ...
 * @author Francis Bourre
 */
class AnotherMockModuleWithServiceCallback extends Module
{
	private var _floatValue 	: Float;
	
	public function new() 
	{
		super();
	}
	
	public function onFloatServiceCallback( value : Float ) : Void
	{
		this._floatValue = value;
	}
	
	public function getFloatValue() : Float
	{
		return this._floatValue;
	}
	
	override private function _getRuntimeDependencies() : IRuntimeDependencies
	{
		var rd : RuntimeDependencies = new RuntimeDependencies();
		rd.addServiceDependencies( [IMockStubStatefulService] );
		return rd;
	}
}