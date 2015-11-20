package hex.ioc.vo;

/**
 * ...
 * @author Francis Bourre
 */
class ServiceLocatorVO extends MapVO
{
	public var mapName : String;
	
	public function new( key : PropertyVO, value : PropertyVO, ?mapName : String )
	{
		super( key, value );
		this.mapName = mapName;
	}
}