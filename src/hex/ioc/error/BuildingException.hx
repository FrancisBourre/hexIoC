package hex.ioc.error;

import haxe.PosInfos;
import hex.error.Exception;

/**
 * ...
 * @author Francis Bourre
 */
class BuildingException extends Exception
{
    public function new ( message : String, ?posInfos : PosInfos )
    {
        super( message, posInfos );
    }
}