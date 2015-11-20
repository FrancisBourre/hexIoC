package hex.ioc.control;

import hex.control.command.ICommand;
import hex.ioc.vo.BuildHelperVO;

/**
 * @author Francis Bourre
 */
interface IBuildCommand extends ICommand
{
	function setHelper( buildHelperVO : BuildHelperVO ) : Void;
}