package hex.ioc.locator;

import hex.collection.ILocatorListener;
import hex.collection.Locator;
import hex.event.IEvent;
import hex.ioc.core.BuilderFactory;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.PropertyVO;
import hex.util.ObjectUtil;

/**
 * ...
 * @author Francis Bourre
 */
class PropertyVOLocator extends Locator<String, Array<PropertyVO>> implements ILocatorListener<String, Dynamic>
{
	static public inline var BUILD_PROPERTY:String = "buildProperty";

	var _builderFactory : BuilderFactory;

	public function new( builderFactory : BuilderFactory )
	{
		super();
		this._builderFactory = builderFactory;
	}

	public function setPropertyValue( property : PropertyVO, target : Dynamic ) : Void
	{
		var propertyName : String = property.name;
		if ( propertyName.indexOf(".") == -1 )
		{
			Reflect.setProperty( target, propertyName, this.getValue( property ) );
		}
		else
		{
			var props : Array<String> = propertyName.split( "." );
			propertyName = props.pop();
			var target : Dynamic = ObjectUtil.fastEvalFromTarget( target, props.join("."), this._builderFactory.getCoreFactory() );
			Reflect.setProperty( target, propertyName, this.getValue( property ) );
		}

	}

	public function getValue( property : PropertyVO ) : Dynamic
	{
		if ( property.method != null )
		{
			return this._builderFactory.build( new ConstructorVO( null, ContextTypeList.FUNCTION, [ property.method ] ) );

		} else if ( property.ref != null )
		{
			return this._builderFactory.build( new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, property.ref ) );

		} else if ( property.staticRef != null )
		{
			return this._builderFactory.getCoreFactory().getStaticReference( property.staticRef );

		} else
		{
			var type : String = property.type != null ? property.type : ContextTypeList.STRING;
			return this._builderFactory.build( new ConstructorVO( property.ownerID, type, [ property.value ] ) );
		}
	}

	public function deserializeArguments( arguments : Array<Dynamic> ) : Array<Dynamic>
	{
		var result : Array<Dynamic> = null;
		var length : Int = arguments.length;

		if ( length > 0 ) 
		{
			result = [];
		}

		for ( obj in arguments )
		{
			if ( Std.is( obj, PropertyVO ) )
			{
				result.push( this.getValue( cast obj ) );
			}
			else if ( Std.is( obj, MapVO ) )
			{
				var mapVO : MapVO = cast obj;
				mapVO.key = this.getValue( mapVO.getPropertyKey() );
				mapVO.value = this.getValue( mapVO.getPropertyValue() );
				result.push( mapVO );
			}
		}

		return result;
	}

	public function buildProperty(  ownerID 	: String,
									name    	: String = null,
									value   	: String = null,
									type    	: String = null,
									ref     	: String = null,
									method  	: String = null,
									staticRef  	: String = null  ) : PropertyVO
	{
		var propertyVO : PropertyVO = new PropertyVO( ownerID, name, value, type, ref, method, staticRef );
		this._dispatcher.dispatch( PropertyVOLocatorMessage.BUILD_PROPERTY, [this, propertyVO] );
		return propertyVO;
	}

	public function addProperty(    ownerID 	: String,
									name    	: String = null,
									value   	: String = null,
									type    	: String = null,
									ref     	: String = null,
									method  	: String = null,
									staticRef  	: String = null  ) : PropertyVO
	{
		var propertyVO : PropertyVO = this.buildProperty( ownerID, name, value, type, ref, method, staticRef );

		if ( this.isRegisteredWithKey( ownerID ) )
		{
			( this.locate( ownerID ) ).push( propertyVO );
		}
		else
		{
			this.register( ownerID, [ propertyVO ] );
		}

		return propertyVO;
	}
	
	public function handleEvent( e : IEvent ) : Void 
	{
		
	}
	
	public function onRegister( key : String, instance : Dynamic ) : Void
	{
		if ( this.isRegisteredWithKey( key ) )
		{
			var properties : Array<PropertyVO> = this.locate( key );
			for ( p in properties )
			{
				this.setPropertyValue( p, instance );
			}
		}
	}

    public function onUnregister( key : String ) : Void  {}
}