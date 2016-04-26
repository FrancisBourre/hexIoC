package hex.ioc.control;

import hex.domain.Domain;
import hex.domain.DomainExpert;
import hex.domain.DomainUtil;
import hex.error.Exception;
import hex.error.NullPointerException;
import hex.ioc.vo.BuildHelperVO;
import hex.ioc.vo.ConstructorVO;
import hex.metadata.AnnotationProvider;
import hex.module.IModule;
import hex.util.ClassUtil;
import hex.util.MacroUtil;

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
				buildHelperVO.contextFactory.buildObject( key );
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
				#if macro
				var tp = MacroUtil.getPack( constructorVO.type );
				var idVar = constructorVO.ID;
				buildHelperVO.expressions.push( macro @:mergeBlock { var $idVar = Type.createInstance( $p { tp }, [] ); } );

				#else
				var classReference = buildHelperVO.coreFactory.getClassReference( constructorVO.type );
				
				var isModule : Bool = ClassUtil.classExtendsOrImplements( classReference, IModule );
				if ( isModule && constructorVO.ID != null && constructorVO.ID.length > 0 )
				{
					DomainExpert.getInstance().registerDomain( DomainUtil.getDomain( constructorVO.ID, Domain ) );
					AnnotationProvider.registerToDomain( buildHelperVO.contextFactory.getAnnotationProvider(), DomainUtil.getDomain( constructorVO.ID, Domain ) );
				}
				constructorVO.result = buildHelperVO.coreFactory.buildInstance( constructorVO.type, constructorVO.arguments, constructorVO.factory, constructorVO.singleton, constructorVO.injectInto );
				#end
			}

			if ( Std.is( constructorVO.result, IModule ) )
			{
				buildHelperVO.moduleLocator.register( constructorVO.ID, constructorVO.result );
			}

			if ( constructorVO.mapType != null )
			{
				var classToMap : Class<Dynamic> = Type.resolveClass( constructorVO.mapType );
				buildHelperVO.contextFactory.getApplicationContext().getBasicInjector().mapToValue( classToMap, constructorVO.result, constructorVO.ID );
			}
		}
	}
}