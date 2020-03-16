// ============================================================================
// Action Save Game
// Saves the game to the specified slot.
// ============================================================================
class ACTION_SaveGame extends P2ScriptedAction;

enum ESaveType
{
	SAVE_Auto,
	SAVE_Easy,
	SAVE_Checkpoint
};

var() ESaveType SaveSlot;

function bool InitActionFor(ScriptedController C)
{
	local P2Player OurPlayer;
	
	OurPlayer = GetPlayer(C);
	
	if (SaveSlot == SAVE_Auto)
		P2GameInfoSingle(OurPlayer.Level.Game).TryAutoSave(OurPlayer, true);
	else if (SaveSlot == SAVE_Easy)
		P2GameInfoSingle(OurPlayer.Level.Game).TryQuickSave(OurPlayer, true);
	else
		P2GameInfoSingle(OurPlayer.Level.Game).TryCheckpointSave(OurPlayer, true);
		
	return false;
}

function string GetActionString()
{
	if (SaveSlot == SAVE_Auto)
		return ActionString @ "AutoSave";
	else if (SaveSlot == SAVE_Easy)
		return ActionString @ "EasySave";
	else
		return ActionString @ "CheckpointSave";
}

defaultproperties
{
	ActionString="Save in slot"
}