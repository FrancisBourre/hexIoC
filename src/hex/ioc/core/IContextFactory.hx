package hex.ioc.core;

import hex.core.IApplicationContext;
import hex.ioc.vo.ConstructorVO;

/**
 * @author Francis Bourre
 */
interface IContextFactory
{
	function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic;
	
	function buildObject( id : String ) : Void;
	
	function getApplicationContext() : IApplicationContext;
}
