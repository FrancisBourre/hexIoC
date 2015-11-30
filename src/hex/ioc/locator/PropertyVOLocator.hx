package hex.ioc.locator;

import hex.collection.Locator;
import hex.ioc.core.BuilderFactory;
import hex.ioc.core.ContextTypeList;
import hex.ioc.core.ICoreFactoryListener;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
class PropertyVOLocator  extends Locator<String, Array<PropertyVO>> implements ICoreFactoryListener
{
	private var _builderFactory : BuilderFactory;

	public function PropertyVOLocator( builderFactory : BuilderFactory )
	{
		super();
		this._builderFactory = builderFactory;
	}

	public function setPropertyValue( property : PropertyVO, target : Dynamic ) : Void
	{
		var propertyName : String = property.name;
		if ( propertyName.indexOf(".") == -1 )
		{
			target[ propertyName ] = this.getValue( property );
		}
		else
		{
			var props : Array<String> = propertyName.split( "." );
			propertyName = props.pop();
			var target : Dynamic = ObjectUtil.evalFromTarget( target, props.join("."), this._builderFactory.getCoreFactory() );
			target[ propertyName ] = this.getValue( property );
		}

	}

	public function getValue( property : PropertyVO ) : Dynamic
	{
		if ( property.method )
		{
			return this._builderFactory.build( new ConstructorVO( null, ContextTypeList.FUNCTION, [ property.method ] ) );

		} else if ( property.ref )
		{
			return this._builderFactory.build( new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, property.ref ) );

		} else if ( property.staticRef )
		{
			return this._builderFactory.getCoreFactory().getStaticReference( property.staticRef );

		} else
		{
			var type : String = property.type ? property.type : ContextTypeList.STRING;
			return this._builderFactory.build( new ConstructorVO( property.ownerID, type, [ property.value ] ) );
		}
	}

	public function deserializeArguments( arguments : Array<Dynamic> ) : Array<Dynamic>
	{
		var result : Array<Dynamic>;
		var length : Int = arguments.length;

		if ( length > 0 ) result = [];

		for ( var i : int = 0; i < length; i++ )
		{
			var obj : Dynamic = arguments[i];
			if ( Std.is( obj, PropertyVO ) )
			{
				result.push( this.getValue( cast obj ) );
			}
			else if ( Std.is( obj, MapVO ) )
			{
				var mapVO : MapVO = cast obj;
				mapVO.key = this.getValue( mapVO.propertyKey );
				mapVO.value = this.getValue( mapVO.propertyValue );
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
		this.getHub().sendNote( PropertyVOLocatorNote.BUILD_PROPERTY, null, propertyVO );
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

	public function onRegisterInstance( key : String, instance : Dynamic ) : Void
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

	public function onUnRegisterInstance( key : String, instance : Dynamic ) : Void  {}
}