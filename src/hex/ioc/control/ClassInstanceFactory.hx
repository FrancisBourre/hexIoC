package hex.ioc.control;

import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.DomainUtil;
import hex.error.PrivateConstructorException;
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
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		var result : Dynamic = null;
		var constructorVO = factoryVO.constructorVO;

		if ( constructorVO.ref != null )
		{
			result = ReferenceFactory.build( factoryVO );
		}
		else
		{
			//build arguments
			constructorVO.arguments = ArgumentFactory.build( factoryVO );
			
			//TODO Allows proxy classes
			if ( !factoryVO.coreFactory.hasProxyFactoryMethod( constructorVO.className ) )
			{
				var classReference = ClassUtil.getClassReference( constructorVO.className );
			
				var isModule : Bool = ClassUtil.classExtendsOrImplements( classReference, IModule );
				if ( isModule && constructorVO.ID != null && constructorVO.ID.length > 0 )
				{
					var moduleDomain = DomainUtil.getDomain( constructorVO.ID, Domain );
					DomainExpert.getInstance().registerDomain( moduleDomain );
					AnnotationProvider.registerToParentDomain( moduleDomain, factoryVO.contextFactory.getApplicationContext().getDomain() );
				}
			}
			
			result = factoryVO.coreFactory.buildInstance( constructorVO );

			if ( constructorVO.mapTypes != null )
			{
				var mapTypes = constructorVO.mapTypes;
				for ( mapType in mapTypes )
				{
					//Remove whitespaces
					mapType = mapType.split( ' ' ).join( '' );
					
					factoryVO.contextFactory.getApplicationContext().getInjector()
						.mapClassNameToValue( mapType, result, constructorVO.ID );
				}
			}
		}
		
		return result;
	}
}