package hex.compiler.parser.xml;

import hex.ioc.assembler.ApplicationAssembler;
import hex.core.IApplicationAssembler;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompilerBuildsTwoContext 
{
	var _applicationAssembler : IApplicationAssembler;
	
	public function new() 
	{
		
	}
	
	@Test( "test building String with assembler" )
	public function testBuildingStringWithAssembler() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
		
		assembleContext1();
		assembleContext2();
	}
	
	function assembleContext1() : Void
	{
		//XmlCompiler.readXmlFileWithAssembler( this._applicationAssembler, "context/simpleInstanceWithArguments.xml" );
	}

	static function assembleContext2() : Void
	{
		//XmlCompiler.readXmlFileWithAssembler( this._applicationAssembler, "context/referenceAnotherContext.xml" );
	}
	
}