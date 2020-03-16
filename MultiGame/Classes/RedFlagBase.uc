class RedFlagBase extends xCTFBase
	placeable;

defaultproperties
{
	DefenderTeamIndex=0
	Skins(0)=Texture'Mp_Misc.Dancer_body_2_red'
	Skins(1)=Texture'Mp_Misc.Dancer_head_1'
	FlagType=class'MultiGame.RedFlag'
	// ObjectiveName="Red Flag Base" no objective name because it changes based on the actual team names
}