package hex.ioc.parser.xml.mock;

import hex.control.payload.PayloadEvent;
import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;
import hex.module.Module;

/**
 * ...
 * @author Francis Bourre
 */
class MockModuleWithServiceCallback extends Module
{
	private var _floatValue 	: Float;
	private var _booleanValue 	: Bool;
	
	public function new() 
	{
		super();
		this._getDependencyInjector().mapToType( IMockDividerHelper, MockDividerHelper, "mockDividerHelper" );
	}
	
	public function onFloatServiceCallback( value : Float ) : Void
	{
		this._floatValue = value;
	}
	
	public function onBooleanServiceCallback( e : PayloadEvent ) : Void
	{
		this._booleanValue = e.getExecutionPayloads()[0].getData().value;
	}
	
	public function getFloatValue() : Float
	{
		return this._floatValue;
	}

	public function getBooleanValue() : Bool
	{
		return this._booleanValue;
	}
	
	override private function _getRuntimeDependencies() : IRuntimeDependencies
	{
		var rd : RuntimeDependencies = new RuntimeDependencies();
		rd.addServiceDependencies( [IMockStubStatefulService] );
		return rd;
	}
}