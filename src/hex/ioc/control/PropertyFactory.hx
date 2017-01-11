package hex.ioc.control;

import hex.error.PrivateConstructorException;
import hex.ioc.core.ContextTypeList;
import hex.ioc.core.IContextFactory;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.PropertyVO;
import hex.util.ClassUtil;

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

	static public function build( factory : IContextFactory, property : PropertyVO, target : Dynamic ) : Dynamic
	{
		var propertyName = property.name;
		if ( propertyName.indexOf( '.' ) == -1 )
		{
			Reflect.setProperty( target, propertyName, PropertyFactory._getValue( factory, property ) );
		}
		else
		{
			var props 		= propertyName.split( "." );
			propertyName 	= props.pop();
			var target 		= factory.getCoreFactory().fastEvalFromTarget( target, props.join( '.' ) );
			Reflect.setProperty( target, propertyName, PropertyFactory._getValue( factory, property ) );
		}

		return _getValue( factory, property );
	}
	
	static function _getValue( factory : IContextFactory, property : PropertyVO ) : Dynamic
	{
		if ( property.method != null )
		{
			return factory.buildVO( new ConstructorVO( null, ContextTypeList.FUNCTION, [ property.method ] ) );

		} else if ( property.ref != null )
		{
			return factory.buildVO( new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, property.ref ) );

		} else if ( property.staticRef != null )
		{
			return ClassUtil.getStaticVariableReference( property.staticRef );

		} else
		{
			var type = property.type != null ? property.type : ContextTypeList.STRING;
			return factory.buildVO( new ConstructorVO( property.ownerID, type, [ property.value ] ) );
		}
	}
}