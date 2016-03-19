package hex.ioc.assembler;

import hex.error.IllegalArgumentException;
import hex.ioc.error.BuildingException;
import hex.ioc.vo.CommandMappingVO;
import hex.ioc.vo.DomainListenerVOArguments;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeApplicationAssembler implements IApplicationAssembler
{
	var _conditionalProperties 		= new Map<String, Bool>();
	var _strictMode 						= true;

	public function new()
	{

	}

	public function release() : Void
	{

	}

	public function buildProperty 			(
		applicationContext 	: AbstractApplicationContext,
		ownerID 			: String,
		name 				: String = null,
		value 				: String = null,
		type 				: String = null,
		ref 				: String = null,
		method 				: String = null,
		staticRef 			: String = null,
		ifList 				: Array<String> = null,
		ifNotList 			: Array<String> = null
	) : Void
	{
		//
	}

	public function buildObject				(
		applicationContext 	: AbstractApplicationContext,
		ownerID 			: String,
		type 				: String = null,
		args 				: Array<Dynamic> = null,
		factory 			: String = null,
		singleton 			: String = null,
		injectInto 			: Bool = false,
		mapType 			: String = null,
		staticRef 			: String = null,
		ifList 				: Array<String> = null,
		ifNotList 			: Array<String> = null
	) : Void
	{
		//
	}

	public function buildMethodCall			(
		applicationContext 	: AbstractApplicationContext,
		ownerID 			: String,
		methodCallName 		: String,
		args 				: Array<Dynamic> = null,
		ifList 				: Array<String> = null,
		ifNotList 			: Array<String> = null
	) : Void
	{
		//
	}

	public function buildDomainListener 	(
		applicationContext 	: AbstractApplicationContext,
		ownerID 			: String,
		listenedDomainName 	: String,
		args 				: Array<DomainListenerVOArguments> = null,
		ifList 				: Array<String> = null,
		ifNotList 			: Array<String> = null
	) : Void
	{
		//
	}

	public function configureStateTransition(
		applicationContext 	: AbstractApplicationContext,
		ID 					: String,
		staticReference 	: String,
		instanceReference 	: String,
		enterList 			: Array<CommandMappingVO>,
		exitList 			: Array<CommandMappingVO>,
		ifList 				: Array<String> = null,
		ifNotList 			: Array<String> = null
	) : Void
	{

	}

	public function buildEverything() : Void
	{

	}

	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		return null;
	}


	public function setStrictMode( b : Bool ) : Void
	{
		this._strictMode = b;
	}

	public function isInStrictMode() : Bool
	{
		return this._strictMode;
	}

	public function addConditionalProperty( conditionalProperties : Map<String, Bool> ) : Void
	{
		var i = conditionalProperties.keys();
		var key : String;
		while ( i.hasNext() )
		{
			key = i.next();
			if ( !this._conditionalProperties.exists( key ) )
			{
				this._conditionalProperties.set( key, conditionalProperties.get( key ) );
			}
			else
			{
				throw new IllegalArgumentException( "addConditionalcontext fails with key'" + key + "', this key was already assigned" );
			}
		}
	}

	public function allowsIfList( ifList : Array<String> = null ) : Bool
	{
		if ( ifList != null )
		{
			for ( ifItem in ifList )
			{
				if ( this._conditionalProperties.exists( ifItem ) )
				{
					if ( this._conditionalProperties.get( ifItem ) )
					{
						return true;
					}
				}
				else if ( this._strictMode )
				{
					throw new BuildingException( "'" + ifItem + "' was not found in application assembler" );
				}
			}
		}
		else
		{
			return true;
		}

		return false;
	}

	public function allowsIfNotList( ifNotList : Array<String> = null ) : Bool
	{
		if ( ifNotList != null )
		{
			for ( ifNotItem in ifNotList )
			{
				if ( this._conditionalProperties.exists( ifNotItem ) )
				{
					if ( this._conditionalProperties.get( ifNotItem ) )
					{
						return false;
					}
				}
				else if ( this._strictMode )
				{
					throw new BuildingException( "'" + ifNotItem + "' was not found in application assembler" );
				}
			}
		}

		return true;
	}
}