package hex.factory;

/**
 * @author Francis Bourre
 */
interface IRequestFactory<RequestType> 
{
	function build( request : RequestType ) : Void;
}