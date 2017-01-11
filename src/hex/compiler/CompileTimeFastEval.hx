package hex.compiler;

import hex.error.IllegalArgumentException;
import hex.ioc.assembler.ApplicationContext;
import hex.core.ICoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeFastEval
{
	function new() 
	{
		
	}
	
	static public function fromTarget( target : Dynamic, toEval : String, coreFactory : ICoreFactory ) : Dynamic
	{
		var members : Array<String> = toEval.split( "." );
		var result 	: Dynamic;
		
		while ( members.length > 0 )
		{
			var member : String = members.shift();
			result = Reflect.field( target, member );
			
			if ( result == null )
			{
				/*if ( Std.is( target, ApplicationContext ) && coreFactory.isRegisteredWithKey( member ) )
				{
					result = coreFactory.locate( member );
				}
				else
				{
					throw new IllegalArgumentException( "ObjectUtil.fastEvalFromTarget(" + target + ", " + toEval + ", " + coreFactory + ") failed." );
				}*/
			}
			
			target = result;
		}
		
		return target;
	}
}