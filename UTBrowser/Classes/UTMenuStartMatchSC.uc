class UTMenuStartMatchSC extends UMenuStartMatchScrollClient;

function Created()
{
	ClientClass = class'UTMenuStartMatchCW';
	FixedAreaClass = None;
	Super(UWindowScrollingDialogClient).Created();
}