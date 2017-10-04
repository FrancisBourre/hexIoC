package hex.compiler.parser.flow;

import hex.compiler.parser.flow.FlowCompilerTest;
import hex.compiler.parser.flow.assembler.ApplicationAssemblerStateTest;
import hex.compiler.parser.flow.context.ApplicationContextBuildingTest;
import hex.compiler.parser.flow.state.StatefulStateMachineConfigTest;

/**
 * ...
 * @author Francis Bourre
 */
class CompilerFlowSuite
{
	@Suite( "Flow" )
    public var list : Array<Class<Dynamic>> = 
	[ 
		ApplicationAssemblerStateTest, 
		ApplicationContextBuildingTest, 
		//BuildTwoContextsWithStateTransitionsTest,
		//ExternalControllerTest,
		StatefulStateMachineConfigTest,
		StaticFlowCompilerTest,
		FlowCompilerTest
	];
}