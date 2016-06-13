package hex.ioc.error;
import hex.ioc.vo.AssemblerVO;
/**
 * @author Francis Bourre
 */

interface IAssemblingExceptionReporter 
{
	function throwValueException( message : String, vo : AssemblerVO ) : Void;
}