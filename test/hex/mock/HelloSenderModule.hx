package hex.mock;

import hex.config.stateful.IStatefulConfig;
import hex.module.ContextModule;

/**
 * ...
 * @author Francis Bourre
 */
class HelloSenderModule extends ContextModule
{
	public function new( config : IStatefulConfig ) 
	{
		super();

		this._map( SayHelloController );
		this._addStatefulConfigs( [config] );
	}
	
	public function sayHelloworldWithControllerInjection() : Void 
	{
		this._get( SayHelloController ).sayHelloWithControllerInjection();
	}
	
	public function sayHelloworldWithFunctionInjection() : Void 
	{
		this._get( SayHelloController ).sayHelloWithFunctionInjection();
	}
	
	public function sayHelloworldWithFunctionInjectionNamed() : Void 
	{
		this._get( SayHelloController ).sayHelloWithFunctionInjectionWithName();
	}
	
	public function sayHelloworldWithFunctionInjectionConstantName() : Void 
	{
		this._get( SayHelloController ).sayHelloWithFunctionInjectionWithConstantName();
	}
	
	public function sayHelloworldWithFunctionInjectionConstantNameFromOtherClass() : Void 
	{
		this._get( SayHelloController ).sayHelloWithFunctionInjectionWithConstantNameFromOtherClass();
	}
	
	public function sayHelloworldWithFunctionInjectionConstantNameFromOtherClassWithFQCN() : Void 
	{
		this._get( SayHelloController ).sayHelloWithFunctionInjectionWithConstantNameFromOtherClassWithFQCN();
	}
	
}