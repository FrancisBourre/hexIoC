package hex.factory;

import hex.ioc.vo.AssemblerVO;

/**
 * ...
 * @author Francis Bourre
 */
class ProxyFactory implements IProxyFactory
{
	var _factories : Map<String, Dynamic>;
	
	public function new() 
	{
		this._factories = new Map();
	}
	
	public function registerFactoryMethod<ArgumentType:AssemblerVO>( voClass: Class<ArgumentType>, factory: ArgumentType->Void ) : Void
	{
		var className = Type.getClassName( voClass );
		this._factories.set( className, factory );
	}
	
	public function buildElement<ArgumentType:AssemblerVO>( voClass: Class<ArgumentType>, assemblerVO : ArgumentType ) : Void
	{
		var className = Type.getClassName( voClass );
		this._factories.get( className )( assemblerVO );
	}
}