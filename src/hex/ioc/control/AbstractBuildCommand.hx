package hex.ioc.control;

import hex.control.Request;
import hex.control.payload.ExecutionPayload;
import hex.error.VirtualMethodException;
import hex.ioc.vo.BuildHelperVO;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractBuildCommand implements IBuildCommand
{
	private var _buildHelperVO 	: BuildHelperVO;
	private var _owner 			: IModule;
	
	private function new() 
	{
		
	}

	public function execute( ?request : Request ) : Void
	{
		throw new VirtualMethodException( this + ".execute should be overridden" );
	}

	public function setHelper( buildHelperVO : BuildHelperVO ) : Void
	{
		this._buildHelperVO = buildHelperVO;
	}

	public function getResult() : Array<Dynamic>
	{
		return [ this._buildHelperVO ];
	}
	
	public function getReturnedExecutionPayload() : Array<ExecutionPayload>
	{
		return null;
	}

	public function getOwner() : IModule
	{
		return this._owner;
	}

	public function setOwner( owner : IModule ) : Void
	{
		if ( this._owner != null )
		{
			this._owner = owner;
		}
	}
}