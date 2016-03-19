package hex.ioc.control;

import hex.ioc.vo.BuildHelperVO;

/**
 * @author Francis Bourre
 */
interface IBuildCommand
{
	function execute( buildHelperVO : BuildHelperVO ) : Void;
}