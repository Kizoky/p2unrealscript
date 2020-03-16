class UTTeamSettingsSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTTeamSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}