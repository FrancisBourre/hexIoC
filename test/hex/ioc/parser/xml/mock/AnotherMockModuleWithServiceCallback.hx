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
	var _floatValue 	: Float;
	
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
	
	#if debug
	override function _getRuntimeDependencies() : IRuntimeDependencies
	{
		return new RuntimeDependencies();
	}
	#end
}