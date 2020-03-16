class UTTDMSettingsSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTTDMSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}