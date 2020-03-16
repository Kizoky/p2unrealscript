class ACTION_ChangeLoggingStatus extends ScriptedAction;

var(Action) bool bAllowLogging;

function bool InitActionFor(ScriptedController C)
{
    local ScriptedSequence S;

    foreach C.AllActors(Class'ScriptedSequence', S)
        S.bLoggingEnabled = bAllowLogging;

    return false;
}

defaultproperties
{
     ActionString="disables logging"
}
