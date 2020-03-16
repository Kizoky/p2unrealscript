class ACTION_DisplayMessage extends ScriptedAction;

var(Action) string		Message;
var(Action) bool		bBroadcast;
var(Action) name		MessageType;

function bool InitActionFor(ScriptedController C)
{
	if ( bBroadCast )
		C.Level.Game.Broadcast(C.GetInstigator(), Message, MessageType); // Broadcast message to all players.
	else
		C.GetInstigator().ClientMessage( Message, MessageType ); 
	return false;	
}

function string GetActionString()
{
	return ActionString@Message;
}

defaultproperties
{
	ActionString="display message"
	MessageType=CriticalEvent
}