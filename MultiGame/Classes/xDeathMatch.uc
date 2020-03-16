class xDeathMatch extends DeathMatch;

defaultproperties
{
	GoalScore=6

	HUDType="MultiGame.MpHUD"
	ScoreBoardType="MultiGame.DMScoreBoard"

	MapNameGameCode="d"	// must be lower case!
	MapListType="MultiGame.DMMapList"
	GameReplicationInfoClass=Class'MultiBase.MpGameReplicationInfo'
	DeathMessageClass=class'MultiGame.xDeathMessage'
	MutatorClass="MultiGame.xMutator"
	LevelRulesClass=class'LevelGamePlay'

	GameBaseEquipment[0]=(weapclass=class'Inventory.UrethraWeapon')
	GameBaseEquipment[1]=(weapclass=class'Inventory.FootWeapon')
	GameBaseEquipment[2]=(weapclass=class'Inventory.BatonWeapon')
	GameBaseEquipment[3]=(weapclass=class'Inventory.PistolWeapon')
}
