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
					var moduleDomain = DomainUtil.getDomain( constructorVO.ID, Domain );
					DomainExpert.getInstance().registerDomain( moduleDomain );
					AnnotationProvider.registerToParentDomain( moduleDomain, factoryVO.contextFactory.getApplicationContext().getDomain() );
				}
			}
			
			constructorVO.result = factoryVO.coreFactory.buildInstance( constructorVO );

			if ( Std.is( constructorVO.result, IModule ) )
			{
				factoryVO.moduleLocator.register( constructorVO.ID, constructorVO.result );
			}

			if ( constructorVO.mapTypes != null )
			{
				var mapTypes = constructorVO.mapTypes;
				for ( mapType in mapTypes )
				{
					//Remove whitespaces
					mapType = mapType.split( ' ' ).join( '' );
					
					factoryVO.contextFactory.getApplicationContext().getInjector()
						.mapClassNameToValue( mapType, constructorVO.result, constructorVO.ID );
				}
			}
		}
	}
}