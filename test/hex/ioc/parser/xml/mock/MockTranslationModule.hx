package hex.ioc.parser.xml.mock;

import hex.collection.HashMap;
import hex.control.payload.ExecutionPayload;
import hex.control.payload.PayloadEvent;
import hex.inject.dependencyproviders.FallbackDependencyProvider;

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
		var payloads : Array<ExecutionPayload> = event.getExecutionPayloads();
		var textToTranslate : String = payloads[0].getData();
		var translation : String = this._map.get( textToTranslate );
		
		payloads[0] = new ExecutionPayload( translation, String );
		this.dispatchDomainEvent( new PayloadEvent( "onTranslation", this, payloads ) );
	}
	
	public function onTranslateWithTime( textToTranslate : String, date : Date ) : Void
	{
		var payloads : Array<ExecutionPayload> = [];
		payloads.push( new ExecutionPayload( this._map.get( textToTranslate ), String ) );
		payloads.push( new ExecutionPayload( date, Date ) );
		
		this.dispatchDomainEvent( new PayloadEvent( "onTranslation", this, payloads ) );
	}
	
}