class UTDMSettingsSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTDMSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}