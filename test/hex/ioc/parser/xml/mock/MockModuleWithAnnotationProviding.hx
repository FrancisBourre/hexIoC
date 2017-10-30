package hex.ioc.parser.xml.mock;

import hex.metadata.AnnotationProvider;
import hex.metadata.MockObjectWithAnnotation;
import hex.metadata.MockWithoutIAnnotationParsableImplementation;
import hex.module.Module;
import hex.module.dependency.IRuntimeDependencies;
import hex.module.dependency.RuntimeDependencies;

/**
 * ...
 * @author Francis Bourre
 */
class MockModuleWithAnnotationProviding extends Module
{
	public var mockObjectWithMetaData 			: MockObjectWithAnnotation;
	public var anotherMockObjectWithMetaData 	: MockWithoutIAnnotationParsableImplementation;
		
	public function new() 
	{
		super();
		
		this._getDependencyInjector().mapToType( MockObjectWithAnnotation, MockObjectWithAnnotation );
		this._getDependencyInjector().mapToType( MockWithoutIAnnotationParsableImplementation, MockWithoutIAnnotationParsableImplementation );
	}
	
	public function getAnnotationProvider() : AnnotationProvider
	{
		return cast this._annotationProvider;
	}
	
	#if debug
	override function _getRuntimeDependencies() : IRuntimeDependencies 
	{
		return return new RuntimeDependencies();
	}
	#end
	
	public function buildComponents() : Void 
	{
		this.mockObjectWithMetaData 		= this._getDependencyInjector().getInstance( MockObjectWithAnnotation );
		this.anotherMockObjectWithMetaData 	= this._getDependencyInjector().getInstance( MockWithoutIAnnotationParsableImplementation );
	}
}