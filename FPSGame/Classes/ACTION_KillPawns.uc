class ACTION_KillPawns extends ScriptedAction;

var() class<DamageType>		 DamageType;	// Damage type to use in the kill
var() name KillTag;							// Actors matching this Tag will be killed
var() bool bExplodeHead;					// If the actor has a head, explode it too

function bool InitActionFor(ScriptedController C)
{
	local Pawn Killed;
	
	foreach C.DynamicActors(class'Pawn', Killed, KillTag)
	{
		Killed.Died( None, DamageType, C.Instigator.Location );
		if (bExplodeHead && FPSPawn(Killed) != None)
			FPSPawn(Killed).ExplodeHead(vect(0,0,0), vect(0,0,0));
	}
	return false;	
}

function string GetActionString()
{
	return ActionString@DamageType;
}

defaultproperties
{
	 DamageType=class'Engine.Crushed'
	 ActionString="Kill tagged"
}