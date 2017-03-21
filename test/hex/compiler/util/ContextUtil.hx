package hex.compiler.util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.TypeTools;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
@:final 
class ContextUtil 
{

	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	#if macro
	public static function instantiateContextDefinition( definition : TypeDefinition ) : Expr
	{
		Context.defineType( definition );
		var typePath = MacroUtil.getTypePath( definition.pack.join( '.' ) + '.' + definition.name );
		return { expr: MacroUtil.instantiate( typePath ), pos: Context.currentPos() };
	}
	
	public static function buildContextDefintion( assemblerID : Int, contextName : String ) : TypeDefinition
	{
		var className = "ContextNamed_" + contextName + "_WithAssemblerID_" + assemblerID;
		var classExpr = macro class $className
		{ 
			public function new()
			{}
		};
		
		classExpr.pack = [ "hex", "compiler", "util" ];
		return classExpr;
	}
	
	public static function buildInstanceField( instanceID : String, instanceClassName : String ) : Field
	{
		var newField : Field = 
		{
			name: instanceID,
			pos: Context.currentPos(),
			kind: null,
			access: [ APublic ]
		}
		
		var type = Context.getType( instanceClassName );
		var complexType = TypeTools.toComplexType( type );
		newField.kind = FVar( complexType );
		
		return newField;
	}
	
	public static function buildContextExecution( fileName : String ) : ContextExecution
	{
		var newField : Field = 
		{
			name: fileName,
			pos: Context.currentPos(),
			kind: null,
			access: [ APublic ]
		}
		
		var ret : ComplexType 			= null;
		var args : Array<FunctionArg> 	= [];
		
		var body = 
		macro 
		{
			trace( $v{ fileName } );
		};
							
		newField.kind = FFun( 
			{
				args: args,
				ret: ret,
				expr: body
			}
		);
		
		return { field: newField, body: body, fileName: fileName };
	}
	
	public static function appendContextExecution( contextExecution : ContextExecution, expr : Expr ) : Void
	{
		var e = contextExecution.body;
		
		switch( e.expr )
		{
			case EBlock( exprs ):
				exprs.push( expr );
				
			case _:
				
		}
	}
	#end
	
}