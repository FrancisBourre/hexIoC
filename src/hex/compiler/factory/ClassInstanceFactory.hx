package hex.compiler.factory;

#if macro
import haxe.macro.Expr;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();

	static inline function _domainExpert() return MacroUtil.getPack( Type.getClassName( hex.domain.DomainExpert ) );
	static inline function _domain() return MacroUtil.getPack( Type.getClassName( hex.domain.Domain ) );
	static inline function _implementsInterface( classRef, interfaceRef ) return  MacroUtil.implementsInterface( classRef, MacroUtil.getClassType( Type.getClassName( interfaceRef ) ) );

	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var f = function( typePath, args, id, vo ) 
		{
			var moduleExpr;
			if ( _implementsInterface( MacroUtil.getClassType( vo.className, vo.filePosition ), hex.module.IContextModule ) )
			{
				var applicationContextName = factoryVO.contextFactory.getApplicationContext().getName();
				//concatenate domain's name with parent's domain
				var domainName = factoryVO.contextFactory.getApplicationContext().getDomain().getName() + '.' + id;
				//TODO register for every instance (from staticCall and/or factory)
				moduleExpr = macro @:mergeBlock{ $p{ _domainExpert() } .getInstance().registerDomain( $p{_domain()}.getDomain( $v{domainName} ) ); } 
			}
			
			var exp = hex.compiletime.factory.ClassInstanceFactory.getResult( macro new $typePath( $a{ args } ), id, vo );
			//Check if the instance is an IContextModule
			return moduleExpr == null ? exp: macro @:pos( vo.filePosition ) @:mergeBlock { $moduleExpr; $exp; };
		}
		
		return hex.compiletime.factory.ClassInstanceFactory._build( factoryVO, f );
	}
}
#end