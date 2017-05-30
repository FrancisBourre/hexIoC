package hex.ioc.control;

import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.error.PrivateConstructorException;
import hex.module.IContextModule;
import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.runtime.factory.ArgumentFactory;
import hex.runtime.factory.ReferenceFactory;
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
        throw new PrivateConstructorException();
    }

	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Dynamic
	{
		var result : Dynamic 	= null;
		var constructorVO 		= factoryVO.constructorVO;
		var coreFactory			= factoryVO.contextFactory.getCoreFactory();

		if ( constructorVO.ref != null )
		{
			result = ReferenceFactory.build( factoryVO );
		}
		else
		{
			//build arguments
			constructorVO.arguments = ArgumentFactory.build( factoryVO );
			
			//TODO Allows proxy classes
			if ( !coreFactory.hasProxyFactoryMethod( constructorVO.className ) )
			{
				var classReference = ClassUtil.getClassReference( constructorVO.className );
			
				var isModule : Bool = ClassUtil.classExtendsOrImplements( classReference, IContextModule );
				if ( isModule && constructorVO.ID != null && constructorVO.ID.length > 0 )
				{
					//concatenate domain's name with parent's domain
					var domainName = factoryVO.contextFactory.getApplicationContext().getDomain().getName() 
						+ '.' + constructorVO.ID;
					
					var moduleDomain = Domain.getDomain( domainName );
					
					DomainExpert.getInstance().registerDomain( moduleDomain );
				}
			}
			
			result = coreFactory.buildInstance( constructorVO );
		}
		
		return result;
	}
}