class UTGBSettingsSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTGBSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}