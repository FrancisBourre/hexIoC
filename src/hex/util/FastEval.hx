package hex.util;

import hex.error.IllegalArgumentException;
import hex.ioc.assembler.ApplicationContext;
import hex.runtime.basic.IRunTimeCoreFactory;

/**
 * ...
 * @author Francis Bourre
 */
class FastEval
{
	function new() 
	{
		
	}
	
	static public function fromTarget( target : Dynamic, toEval : String, coreFactory : IRunTimeCoreFactory ) : Dynamic
	{
		var members : Array<String> = toEval.split( "." );
		var result 	: Dynamic;
		
		while ( members.length > 0 )
		{
			var member : String = members.shift();
			result = Reflect.field( target, member );
			
			if ( result == null )
			{
				if ( Std.is( target, ApplicationContext ) && coreFactory.isRegisteredWithKey( member ) )
				{
					result = coreFactory.locate( member );
				}
				#if js
				else if ( Std.is( target, js.html.Element ) )
				{
					result = cast( target, js.html.Element).getElementsByClassName(member)[0];
				}
				#end
				else
				{
					throw new IllegalArgumentException( "ObjectUtil.fastEvalFromTarget(" + target + ", " + toEval + ", " + coreFactory + ") failed." );
				}
			}
			
			target = result;
		}
		
		return target;
	}
	
}