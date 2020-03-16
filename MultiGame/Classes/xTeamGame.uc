class xTeamGame extends TeamGame;

defaultproperties
{
	GoalScore=12

	HUDType="MultiGame.TeamHUD"
	ScoreBoardType="MultiGame.TDMScoreBoard"
	MatchIntroClassName="MultiGame.TeamIntro"

	MapNameGameCode="t"	// must be lower case!
	MapListType="MultiGame.TDMMapList"
	GameReplicationInfoClass=Class'MultiBase.MpGameReplicationInfo'
	DeathMessageClass=class'MultiGame.xDeathMessage'
	MutatorClass="MultiGame.xMutator"
	LevelRulesClass=class'LevelGamePlay'

	GameBaseEquipment[0]=(weapclass=class'Inventory.UrethraWeapon')
	GameBaseEquipment[1]=(weapclass=class'Inventory.FootWeapon')
	GameBaseEquipment[2]=(weapclass=class'Inventory.BatonWeapon')
	GameBaseEquipment[3]=(weapclass=class'Inventory.PistolWeapon')
}