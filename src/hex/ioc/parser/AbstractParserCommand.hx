package hex.ioc.parser;

import hex.control.async.AsyncCommand;
import hex.control.Request;
import hex.error.NullPointerException;
import hex.error.VirtualMethodException;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractParserCommand extends AsyncCommand implements IParserCommand
{
	var _applicationAssembler 	: IApplicationAssembler;
	var _contextData 			: Dynamic;

	function new() 
	{
		super();
	}
	
	@final
	override public function execute( ?request : Request ) : Void 
	{
		if ( this._contextData != null )
		{
				this.parse();

		} else
		{
			throw new NullPointerException( this + ".execute() failed. Context data was null." );
		}
	}
	
	@final
	public function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void
	{
		this._applicationAssembler = applicationAssembler;
	}

	@final
	public function getApplicationAssembler() : IApplicationAssembler
	{
		return this._applicationAssembler;
	}

	@final
	public function getContextData() : Dynamic
	{
		return this._contextData;
	}

	public function parse() : Void
	{
		throw new VirtualMethodException( this + ".parse must be implemented in concrete class." );
	}

	public function setContextData( data : Dynamic ) : Void
	{
		throw new VirtualMethodException( this + ".setContextData must be implemented in concrete class." );
	}
	
	public function getApplicationContext( applicationContextClass : Class<AbstractApplicationContext> = null ) : AbstractApplicationContext
	{
		throw new VirtualMethodException( this + ".getApplicationContext must be implemented in concrete class." );
	}
}