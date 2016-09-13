package hex.ioc.core;

import hex.collection.ILocator;
import hex.di.IDependencyInjector;
import hex.ioc.vo.ConstructorVODef;
import hex.metadata.IAnnotationProvider;

/**
 * @author Francis Bourre
 */

interface ICoreFactory extends ILocator<String, Dynamic>
{
	function getInjector() : IDependencyInjector;
	function getAnnotationProvider() : IAnnotationProvider;
	function clear() : Void;
	function buildInstance( constructorVO : ConstructorVODef ) : Dynamic;
	function fastEvalFromTarget( target : Dynamic, toEval : String ) : Dynamic;
	function addProxyFactoryMethod( classPath : String, scope : Dynamic, factoryMethod : Dynamic ) : Void;
	function removeProxyFactoryMethod( classPath : String ) : Bool;
	function hasProxyFactoryMethod( className : String ) : Bool;
}