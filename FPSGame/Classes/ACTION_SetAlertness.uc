class ACTION_SetAlertness extends ScriptedAction;

enum EAlertnessType
{
	ALERTNESS_IgnoreAll,			// ignore any damage, etc. (even the physics part)
	ALERTNESS_IgnoreEnemies,		// react normally, but don't try to fight or anything
	ALERTNESS_StayOnScript,			// stay on script, but fight when possible
	ALERTNESS_LeaveScriptForCombat	// leave script when acquire enemy
};

var(Action) EAlertnessType Alertness;

function bool InitActionFor(ScriptedController C)
{
	C.SetEnemyReaction(int(Alertness));
	return false;	
}

function string GetActionString()
{
	local String S;

	Switch(Alertness)
	{
		case ALERTNESS_IgnoreAll: S="Ignore all"; break;
		case ALERTNESS_IgnoreEnemies: S="Ignore enemies"; break;
		case ALERTNESS_StayOnScript: S="Stay on script"; break;
		case ALERTNESS_LeaveScriptForCombat: S="Leave script for combat"; break;
	}
	return ActionString@S;
}

defaultproperties
{
	Alertness=ALERTNESS_Normal
	ActionString="set alertness"
	bValidForTrigger=false
}
	
