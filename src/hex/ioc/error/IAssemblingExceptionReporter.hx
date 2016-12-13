package hex.ioc.error;

import hex.ioc.vo.AssemblerVO;
import haxe.macro.Expr.Position;

/**
 * @author Francis Bourre
 */
interface IAssemblingExceptionReporter<T> 
{
	function throwMissingIDException( xml : T ) : Void;
	
	function throwMissingListeningReferenceException( parentNode : T, listenNode : T ) : Void;
	
	function throwMissingApplicationContextNameException( content : T ) : Void;
	
	function register( assemblerVO : AssemblerVO, content : T ) : AssemblerVO;

	function throwMissingTypeException( type : String, content : T, attributeName : String ) : Void;
	
	function getPosition( xml : T, ?additionalInformations : Dynamic ) : Position;
}