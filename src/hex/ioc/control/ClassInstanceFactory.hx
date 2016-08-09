package hex.ioc.control;

import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.DomainUtil;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.metadata.AnnotationProvider;
import hex.module.IModule;
import hex.util.ClassUtil;

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
			ReferenceFactory.build( factoryVO );
		}
		else
		{
			//TODO Allows proxy classes
			if ( !factoryVO.coreFactory.hasProxyFactoryMethod( constructorVO.type ) )
			{
				var classReference = ClassUtil.getClassReference( constructorVO.type );
			
				var isModule : Bool = ClassUtil.classExtendsOrImplements( classReference, IModule );
				if ( isModule && constructorVO.ID != null && constructorVO.ID.length > 0 )
				{
					DomainExpert.getInstance().registerDomain( DomainUtil.getDomain( constructorVO.ID, Domain ) );
					AnnotationProvider.registerToDomain( factoryVO.contextFactory.getAnnotationProvider(), DomainUtil.getDomain( constructorVO.ID, Domain ) );
				}
			}
			
			constructorVO.result = factoryVO.coreFactory.buildInstance( constructorVO.type, constructorVO.arguments, constructorVO.factory, constructorVO.singleton, constructorVO.injectInto );

			if ( Std.is( constructorVO.result, IModule ) )
			{
				factoryVO.moduleLocator.register( constructorVO.ID, constructorVO.result );
			}

			if ( constructorVO.mapTypes != null )
			{
				var mapTypes = constructorVO.mapTypes;
				for ( mapType in mapTypes )
				{
					var classToMap : Class<Dynamic> = Type.resolveClass( mapType );
					factoryVO.contextFactory.getApplicationContext().getInjector().mapToValue( classToMap, constructorVO.result, constructorVO.ID );
				}
			}
		}
	}
}