package hex.ioc.parser.xml.mock;

import hex.collection.HashMap;
import hex.event.MessageType;

/**
 * ...
 * @author Francis Bourre
 */
class MockTranslationModule extends MockModule
{
	private var _map : HashMap<String, String> = new HashMap<String, String>();
	
	public static var TRANSLATION : MessageType = new MessageType( "onTranslation" );
	
	public function new() 
	{
		super();
		this._map.put( "Bonjour", "Hello" );
	}
	
	public function onSomethingToTranslate( textToTranslate : String ) : Void
	{
		var translation : String = this._map.get( textToTranslate );
		this.dispatchDomainEvent( MockTranslationModule.TRANSLATION, [ translation ] );
	}
	
	public function onTranslateWithTime( textToTranslate : String, date : Date ) : Void
	{
		this.dispatchDomainEvent( MockTranslationModule.TRANSLATION, [ this._map.get( textToTranslate ), date ] );
	}
	
}