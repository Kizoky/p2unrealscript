//=============================================================================
// ACTION_SetActorHidden
// Erik Rossik
//=============================================================================
class ACTION_SetActorHidden extends ScriptedAction;

var(Action) Name ActorTag;
var(Action) bool bHidden;

function bool InitActionFor(ScriptedController C)
{
 local Actor a;

	if(ActorTag != 'None')
	{
		ForEach C.AllActors(class'Actor', a, ActorTag)
		{
		 if(a != none)
		 {
		  a.bHidden = bHidden;
	 	 }
		}
	}
	return false;	
}

defaultproperties
{
}
