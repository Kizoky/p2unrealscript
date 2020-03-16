class ACTION_SetAttitudeToPlayer extends ScriptedAction;

var(Action)		name		PawnTag;
var(Action)		bool 		bPlayerIsFriend;
var(Action)		bool 		bPlayerIsEnemy;
var(Action)		float		FriendDamageThresholdPct;

function bool InitActionFor(ScriptedController C)
{
	local FPSPawn fpawn;

	if(PawnTag != 'None')
	{
		ForEach C.AllActors(class'FPSPawn', fpawn, PawnTag)
		{
			fpawn.bPlayerIsFriend=bPlayerIsFriend;
			fpawn.bPlayerIsEnemy=bPlayerIsEnemy;
			fpawn.FriendDamageThreshold = FriendDamageThresholdPct*fpawn.HealthMax;
		}
	}

	return false;	
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="SetPlayerFriend"
	bPlayerIsFriend=true
	FriendDamageThresholdPct=0.1
}
