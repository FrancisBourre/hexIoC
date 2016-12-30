package hex.factory;

import hex.ioc.vo.AssemblerVO;

/**
 * @author Francis Bourre
 */
interface IProxyFactory 
{
	function registerFactoryMethod<ArgumentType:AssemblerVO>( voClass: Class<ArgumentType>, factory: ArgumentType-> Void ) : Void;
	function buildElement<ArgumentType:AssemblerVO>( voClass: Class<ArgumentType>, assemblerVO : ArgumentType ) : Void;
}