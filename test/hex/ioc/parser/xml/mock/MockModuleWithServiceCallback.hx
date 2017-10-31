package hex.ioc.parser.xml.mock;

import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;
import hex.module.Module;

/**
 * ...
 * @author Francis Bourre
 */
class MockModuleWithServiceCallback extends Module
{
	var _floatValue 	: Float;
	var _booleanValue 	: Bool;
	
	public function new() 
	{
		super();
		this._getDependencyInjector().mapToType( IMockDividerHelper, MockDividerHelper, "mockDividerHelper" );
	}
	
	public function onFloatServiceCallback( value : Float ) : Void
	{
		this._floatValue = value;
	}
	
	public function onBooleanServiceCallback( mockBooleanVO : MockBooleanVO ) : Void
	{
		this._booleanValue = mockBooleanVO.value;
	}
	
	public function getFloatValue() : Float
	{
		return this._floatValue;
	}

	public function getBooleanValue() : Bool
	{
		return this._booleanValue;
	}
	
	#if debug
	override function _getRuntimeDependencies() : IRuntimeDependencies
	{
		return new RuntimeDependencies();
	}
	#end
}