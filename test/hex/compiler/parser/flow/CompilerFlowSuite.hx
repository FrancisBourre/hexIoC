package hex.compiler.parser.flow;

import hex.compiler.parser.flow.FlowCompilerTest;
import hex.compiler.parser.flow.context.ApplicationContextBuildingTest;

/**
 * ...
 * @author Francis Bourre
 */
class CompilerFlowSuite
{
	@Suite( "Flow" )
    public var list : Array<Class<Dynamic>> = 
	[ 
		ApplicationContextBuildingTest, 
		FlowCompilerTest,
		StaticFlowCompilerTest
	];
}