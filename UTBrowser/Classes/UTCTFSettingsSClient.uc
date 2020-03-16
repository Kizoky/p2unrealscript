class UTCTFSettingsSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTCTFSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}