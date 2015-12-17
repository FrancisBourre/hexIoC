package hex.ioc.parser.xml.mock;

import hex.collection.HashMap;
import hex.control.payload.ExecutionPayload;
import hex.control.payload.PayloadEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MockTranslationModule extends MockModule
{
	private var _map : HashMap<String, String> = new HashMap<String, String>();
	
	public function new() 
	{
		super();
		this._map.put( "Bonjour", "Hello" );
	}
	
	public function onSomethingToTranslate( event : PayloadEvent ) : Void
	{
		var textToTranslate : String = event.getExecutionPayloads()[0].getData();
		var translation : String = this._map.get( textToTranslate );
		this.dispatchDomainEvent( new PayloadEvent( "onTranslation", this, [new ExecutionPayload( translation, String )] ) );
	}

	/*public function onAnotherTextInput( text : String, date : Date ) : Void
	{
		this.dispatchDomainEvent( new PayloadEvent( "onTranslation", this, [new ExecutionPayload( "hello", String ), new ExecutionPayload( date, Date )] ) );
	}*/
}