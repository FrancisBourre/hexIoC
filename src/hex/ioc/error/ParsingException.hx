package hex.ioc.error;

import hex.error.Exception;

/**
 * ...
 * @author Francis Bourre
 */
class ParsingException extends Exception
{
    public function new ( message : String, ?posInfos : PosInfos )
    {
        super( message, posInfos );
    }
}