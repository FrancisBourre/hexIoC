package hex.ioc.control;

import hex.control.Request;
import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.DomainUtil;
import hex.error.Exception;
import hex.ioc.vo.ConstructorVO;
import hex.module.IModule;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class BuildInstanceCommand extends AbstractBuildCommand
{
	override public function execute( ?request : Request ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		if ( constructorVO.ref != null )
		{
			var cmd : IBuildCommand = new BuildRefCommand();
			cmd.setHelper( this._buildHelperVO );
			cmd.execute( request );
		}
		else
		{
			if ( constructorVO.staticRef != null )
			{
				constructorVO.result = this._buildHelperVO.coreFactory.getStaticReference( constructorVO.staticRef );
			}
			else
			{
				try
				{
					var isModule : Bool = ClassUtil.classExtendsOrImplements( Type.resolveClass( constructorVO.type ), IModule );
					if ( isModule && constructorVO.ID != null && constructorVO.ID.length > 0 )
					{
						DomainExpert.getInstance().registerDomain( DomainUtil.getDomain( constructorVO.ID, Domain ) );
					}

				} catch ( err : Exception )
				{
					// do nothing as expected
				}

				constructorVO.result = this._buildHelperVO.coreFactory.buildInstance( constructorVO.type, constructorVO.arguments, constructorVO.factory, constructorVO.singleton );
			}

			if ( Std.is( constructorVO.result, IModule ) )
			{
				this._buildHelperVO.moduleLocator.register( constructorVO.ID, constructorVO.result );
			}

			if ( constructorVO.mapType != null )
			{
				var classToMap : Class<Dynamic> = Type.resolveClass( constructorVO.mapType );
				this._buildHelperVO.builderFactory.getApplicationContext().getBasicInjector().mapToValue( classToMap, constructorVO.result, constructorVO.ID );
			}
		}
	}
}