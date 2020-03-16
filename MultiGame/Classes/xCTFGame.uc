class xCTFGame extends CTFGame;

var RedFlag GameRedFlag;
var BlueFlag GameBlueFlag;

State MatchInProgress
{
	// Merged from ut2199, styled after bombing run, this replicates the two
	// flag positions all the time
	function Timer()
	{
        Super.Timer();

		if ( GameRedFlag == None 
			|| GameRedFlag.bDeleteMe)
			ForEach DynamicActors(class'RedFlag',GameRedFlag)
				break;
		if ( GameBlueFlag == None 
			|| GameBlueFlag.bDeleteMe)
			ForEach DynamicActors(class'BlueFlag',GameBlueFlag)
				break;

		if ( GameRedFlag != None )
			GameReplicationInfo.FlagPos[0] = GameRedFlag.Position().Location;
		if ( GameBlueFlag != None )
			GameReplicationInfo.FlagPos[1] = GameBlueFlag.Position().Location;
	}
}

State MatchOver
{
Begin:
	// Start party right away so nobody notices that there's only one chick
	PartyForTheWinner(EndGameFocus);
	Sleep(WaitForWinnerAnnouncement);
	PlayEndOfMatchMessage();
}

defaultproperties
{
	GoalScore=3

	HUDType="MultiGame.CTFHUD"
	ScoreBoardType="MultiGame.CTFScoreboard"
	MatchIntroClassName="MultiGame.TeamIntro"

	MapNameGameCode="s"	// must be lower case!
	MapListType="MultiGame.CTFmaplist"
	GameReplicationInfoClass=Class'MultiBase.CTFGameReplicationInfo'
	DeathMessageClass=class'MultiGame.xDeathMessage'
	MutatorClass="MultiGame.xMutator"
	LevelRulesClass=class'LevelGamePlay'

	GameBaseEquipment[0]=(weapclass=class'Inventory.UrethraWeapon')
	GameBaseEquipment[1]=(weapclass=class'Inventory.FootWeapon')
	GameBaseEquipment[2]=(weapclass=class'Inventory.BatonWeapon')
	GameBaseEquipment[3]=(weapclass=class'Inventory.PistolWeapon')
	GameBaseEquipment[4]=(weapclass=class'Inventory.MachinegunWeapon')
}