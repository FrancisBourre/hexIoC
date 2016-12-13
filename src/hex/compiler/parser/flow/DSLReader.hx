package hex.compiler.parser.flow;

import haxe.macro.Context;
import haxe.macro.Expr;
import hex.ioc.assembler.ConditionalVariablesChecker;

/**
 * ...
 * @author Francis Bourre
 */
class DSLReader 
{
	public function new() 
	{
		
	}
	
	public function read( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker ) : Expr
	{
		//read file
		var dsl = this._readFile( fileName );

		//parse
		var expr = Context.parse( dsl.data, Context.currentPos() );
		trace( expr );
		
		return expr;
	}
	
	function _readFile( fileName : String ) : DSLData
	{
		try
		{
			//resolve
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			
			//read data
			var data = sys.io.File.getContent( path );
			
			//instantiate result
			var result = 	{ 	
								data: 				"{" + data + "}",
								length: 			data.length, 
								path: 				path,
							};
			
			return result;
		}
		catch ( error : Dynamic )
		{
			return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
	}
}