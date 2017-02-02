package hex.compiler.factory;

import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.core.ContextTypeList;
import hex.ioc.core.IContextFactory;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
class PropertyFactory 
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }

	#if macro
	static public function build( factory : IContextFactory, property : PropertyVO ) : Expr
	{
		var e 				: Expr 		= null;
		var value 			: Dynamic 	= null;
		var id							= property.ownerID;
		var propertyName				= property.name;
		
		if ( property.method != null )
		{
			var constructorVO 			= new ConstructorVO( null, ContextTypeList.FUNCTION, [ property.method ], null, null, false, null, null, null );
			constructorVO.filePosition 	= property.filePosition;
			value 						= factory.buildVO( constructorVO );
			e 							= macro $i{ id }.$propertyName = $value;

		} else if ( property.ref != null )
		{
			var constructorVO 			= new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, property.ref, null, null );
			constructorVO.filePosition 	= property.filePosition;
			value 						= factory.buildVO( constructorVO );
			e 							= macro $i{ id }.$propertyName = $i{ property.ref };

		} else if ( property.staticRef != null )
		{
			var constructorVO 			= new ConstructorVO( null, ContextTypeList.STATIC_VARIABLE, null, null, null, false, null, null,  property.staticRef );
			constructorVO.filePosition 	= property.filePosition;
			value 						= factory.buildVO( constructorVO );
			e 							= macro $i{ id }.$propertyName = $value;

		} else
		{
			var type 					= property.type != null ? property.type : ContextTypeList.STRING;
			var constructorVO 			= new ConstructorVO( property.ownerID, type, [ property.value ], null, null, false, null, null, null );
			constructorVO.filePosition 	= property.filePosition;
			value 						= factory.buildVO( constructorVO );
			e 							= macro $p{ ( id + "." + propertyName ).split( '.' ) } = $value;
		}
		
		return e;
	}
	#end
}