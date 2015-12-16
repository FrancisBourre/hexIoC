package hex.ioc.parser.xml.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockServiceProvider
{
	private function new() 
	{
		
	}
	
	static private var _Instance : MockServiceProvider = null;

	private var _gateway : String;

	static public function getInstance() : MockServiceProvider
	{
		if ( MockServiceProvider._Instance == null )
		{
			MockServiceProvider._Instance = new MockServiceProvider();
		}
		return MockServiceProvider._Instance;
	}

	public function setGateway( gateway : String ) : Void
	{
		this._gateway = gateway;
	}

	public function getGateway() : String
	{
		return this._gateway;
	}
}