package hex.ioc.core;

import hex.collection.ILocator;
import hex.di.IBasicInjector;

/**
 * @author Francis Bourre
 */

interface ICoreFactory extends ILocator<String, Dynamic>
{
	function getBasicInjector() : IBasicInjector;
	function clear() : Void;
	function getClassReference( qualifiedClassName : String ) : Class<Dynamic>;
	function getStaticReference( qualifiedClassName : String ) : Dynamic;
	function buildInstance( qualifiedClassName : String, ?args : Array<Dynamic>, ?factoryMethod : String, ?singletonAccess : String, ?instantiateUnmapped : Bool = false ) : Dynamic;
}