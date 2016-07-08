package hex.ioc.core;

import hex.collection.ILocator;
import hex.di.IDependencyInjector;
import hex.metadata.IAnnotationProvider;

/**
 * @author Francis Bourre
 */

interface ICoreFactory extends ILocator<String, Dynamic>
{
	function getInjector() : IDependencyInjector;
	function getAnnotationProvider() : IAnnotationProvider;
	function clear() : Void;
	function buildInstance( qualifiedClassName : String, ?args : Array<Dynamic>, ?factoryMethod : String, ?singletonAccess : String, ?instantiateUnmapped : Bool = false ) : Dynamic;
	function fastEvalFromTarget( target : Dynamic, toEval : String ) : Dynamic;
	function addProxyFactoryMethod( classPath : String, scope : Dynamic, factoryMethod : Dynamic ) : Void;
	function hasProxyFactoryMethod( className : String ) : Bool;
}