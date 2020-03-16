class WorkshopStartGameWindow extends UMenuStartGameWindow;

function SaveConfigs()
{
	ClientArea.SaveConfig();
//	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	WindowTitle="Start Workshop Game"
	ClientClass=class'WorkshopStartGameCW'
}
