package hex.ioc.control;

import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.DomainUtil;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.metadata.AnnotationProvider;
import hex.module.IModule;
import hex.util.ClassUtil;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	function new()
	{

	}

	static public function build( factoryVO : FactoryVO ) : Void
	{
		var constructorVO : ConstructorVO = factoryVO.constructorVO;

		if ( constructorVO.ref != null )
		{
			trace( constructorVO );
			ReferenceFactory.build( factoryVO );
		}
		else
		{
			if ( constructorVO.staticRef != null )
			{
				constructorVO.result = ClassUtil.getStaticReference( constructorVO.staticRef );
			}
			else
			{
				#if macro
				var tp = MacroUtil.getPack( constructorVO.type );
				var idVar = constructorVO.ID;
				var idArgs = idVar + "Args";
				var varIDArgs = macro $i{ idArgs };
				factoryVO.expressions.push( macro @:mergeBlock { var $idVar = Type.createInstance( $p { tp }, $varIDArgs ); } );

				#else
				var classReference = ClassUtil.getClassReference( constructorVO.type );
				
				var isModule : Bool = ClassUtil.classExtendsOrImplements( classReference, IModule );
				if ( isModule && constructorVO.ID != null && constructorVO.ID.length > 0 )
				{
					DomainExpert.getInstance().registerDomain( DomainUtil.getDomain( constructorVO.ID, Domain ) );
					AnnotationProvider.registerToDomain( factoryVO.contextFactory.getAnnotationProvider(), DomainUtil.getDomain( constructorVO.ID, Domain ) );
				}
				constructorVO.result = factoryVO.coreFactory.buildInstance( constructorVO.type, constructorVO.arguments, constructorVO.factory, constructorVO.singleton, constructorVO.injectInto );
				#end
			}

			if ( Std.is( constructorVO.result, IModule ) )
			{
				factoryVO.moduleLocator.register( constructorVO.ID, constructorVO.result );
			}

			if ( constructorVO.mapType != null )
			{
				var classToMap : Class<Dynamic> = Type.resolveClass( constructorVO.mapType );
				factoryVO.contextFactory.getApplicationContext().getBasicInjector().mapToValue( classToMap, constructorVO.result, constructorVO.ID );
			}
		}
	}
}