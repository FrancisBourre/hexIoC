package hex.ioc.locator;

import hex.event.BasicEvent;
import hex.ioc.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
class PropertyVOLocatorEvent extends BasicEvent
{
	var _propertyVO : PropertyVO;
	
	public function new( type : String, target : PropertyVOLocator, propertyVO : PropertyVO ) 
	{
		super( type, target );
		this._propertyVO = propertyVO;
	}
	
	public function getPropertyVO() : PropertyVO
	{
		return this._propertyVO;
	}
}