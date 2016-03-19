package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;
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
class BuildInstanceCommand implements IBuildCommand
{
	public function new()
	{

	}

	public function execute( buildHelperVO : BuildHelperVO ) : Void
	{
		var constructorVO : ConstructorVO = buildHelperVO.constructorVO;

		if ( constructorVO.ref != null )
		{
			var key : String = constructorVO.ref;

			if ( key.indexOf(".") != -1 )
			{
				key = Std.string( ( key.split( "." ) ).shift() );
			}

			if ( !( buildHelperVO.coreFactory.isRegisteredWithKey( key ) ) )
			{
				buildHelperVO.builderFactory.buildObject( key );
			}

			constructorVO.result = buildHelperVO.coreFactory.locate( key );

			if ( constructorVO.ref.indexOf( "." ) != -1 )
			{
				var args : Array<String> = constructorVO.ref.split( "." );
				args.shift();
				constructorVO.result = buildHelperVO.coreFactory.fastEvalFromTarget( constructorVO.result, args.join( "." )  );
			}
		}
		else
		{
			if ( constructorVO.staticRef != null )
			{
				constructorVO.result = buildHelperVO.coreFactory.getStaticReference( constructorVO.staticRef );
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

				constructorVO.result = buildHelperVO.coreFactory.buildInstance( constructorVO.type, constructorVO.arguments, constructorVO.factory, constructorVO.singleton, constructorVO.injectInto );
			}

			if ( Std.is( constructorVO.result, IModule ) )
			{
				buildHelperVO.moduleLocator.register( constructorVO.ID, constructorVO.result );
			}

			if ( constructorVO.mapType != null )
			{
				var classToMap : Class<Dynamic> = Type.resolveClass( constructorVO.mapType );
				buildHelperVO.builderFactory.getApplicationContext().getBasicInjector().mapToValue( classToMap, constructorVO.result, constructorVO.ID );
			}
		}
	}
}