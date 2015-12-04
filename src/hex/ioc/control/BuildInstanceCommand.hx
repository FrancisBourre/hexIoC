package hex.ioc.control;

import hex.domain.DomainExpert;
import hex.ioc.vo.ConstructorVO;
import hex.domain.Domain;
import hex.error.Exception;
import hex.event.IEvent;
import hex.module.IModule;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
class BuildInstanceCommand extends AbstractBuildCommand
{
	override public function execute( ?e : IEvent ) : Void
	{
		var constructorVO : ConstructorVO = this._buildHelperVO.constructorVO;

		if ( constructorVO.ref != null )
		{
			var cmd : IBuildCommand = new BuildRefCommand();
			cmd.setHelper( this._buildHelperVO );
			cmd.execute( e );
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
						DomainExpert.getInstance().registerDomain( new Domain( constructorVO.ID ) );
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
				this._buildHelperVO.builderFactory.getApplicationContext().getInjector().mapToValue( classToMap, constructorVO.result, constructorVO.ID );
			}
		}
	}
}