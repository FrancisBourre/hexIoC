package hex.ioc.error;

import haxe.macro.Expr.Position;

/**
 * @author Francis Bourre
 */
interface IAssemblingExceptionReporter<T> 
{
	function getPosition( content : T, ?additionalInformations : Dynamic ) : Position;
}