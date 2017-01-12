package hex.ioc.parser.xml.context;

import hex.core.IApplicationAssembler;
import hex.domain.ApplicationDomainDispatcher;
import hex.ioc.parser.xml.context.mock.MockApplicationContext;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextBuildingTest
{
	var _applicationAssembler : IApplicationAssembler;

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		if ( this._applicationAssembler != null )
		{
			this._applicationAssembler.release();
		}
	}
	
	@Test( "test applicationContext building" )
	public function testApplicationContextBuilding() : Void
	{
		this._applicationAssembler = XmlReader.readXmlFile( "context/applicationContextBuildingTest.xml" );

		var applicationContext = this._applicationAssembler.getApplicationContext( "applicationContext" );
		Assert.isNotNull( applicationContext, "applicationContext shouldn't be null" );
		Assert.isInstanceOf( applicationContext, MockApplicationContext, "applicationContext should be an instance of 'MockApplicationContext'" );
		Assert.equals( "Hola Mundo", applicationContext.getCoreFactory().locate( "test" ), "String values should be the same" );
	}
}