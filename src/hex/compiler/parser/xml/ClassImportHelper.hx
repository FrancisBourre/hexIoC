package hex.compiler.parser.xml;

import haxe.macro.Context;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class ClassImportHelper
{
	static var _primType		: Array<String> = [	ContextTypeList.STRING,
													ContextTypeList.INT,
													ContextTypeList.UINT,
													ContextTypeList.FLOAT,
													ContextTypeList.BOOLEAN,
													ContextTypeList.NULL,
													ContextTypeList.OBJECT,
													ContextTypeList.XML,
													ContextTypeList.CLASS,
													ContextTypeList.FUNCTION,
													ContextTypeList.ARRAY
													];
													
	var _compiledClass : Array<String>;
													
	public function new() 
	{
		this._compiledClass = [];
	}
	
	#if macro
	public function forceCompilation( type : String ) : Bool
	{
		if ( type != null && ClassImportHelper._primType.indexOf( type ) == -1 && this._compiledClass.indexOf( type ) == -1 )
		{
			this._compiledClass.push( type );
			try
			{
				Context.getType( type );
			}
			catch ( e : Dynamic )
			{
				Context.error( e.message, e.pos );
			}
			
			return true;
		}
		else
		{
			return false;
		}
	}

	static public function getClassFullyQualifiedNameFromStaticRef( staticRef : String ) : String
	{
		var a : Array<String> = staticRef.split( "." );
		var type : String = a[ a.length - 1 ];
		a.splice( a.length - 1, 1 );
		return a.join( "." );
	}

	public function includeStaticRef( staticRef : String ) : Bool
	{
		if ( staticRef != null )
		{
			this.forceCompilation( ClassImportHelper.getClassFullyQualifiedNameFromStaticRef( staticRef ) );
			return true;
		}
		else
		{
			return false;
		}
	}

	public function includeClass( arg : Dynamic ) : Bool
	{
		if ( arg.type == ContextTypeList.CLASS )
		{
			this.forceCompilation( arg.value );
			return true;
		}
		else
		{
			return false;
		}
	}
	#end
}