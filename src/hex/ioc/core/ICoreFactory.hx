package hex.ioc.core;

import hex.collection.ILocator;
import hex.di.IDependencyInjector;

/**
 * @author Francis Bourre
 */

interface ICoreFactory extends ILocator<String, Dynamic>
{
	function getBasicInjector() : IDependencyInjector;
	function clear() : Void;
	function buildInstance( qualifiedClassName : String, ?args : Array<Dynamic>, ?factoryMethod : String, ?singletonAccess : String, ?instantiateUnmapped : Bool = false ) : Dynamic;
	function fastEvalFromTarget( target : Dynamic, toEval : String ) : Dynamic;
}