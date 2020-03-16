class DLCTabSC extends UTMenuStartMatchSC;

function Created()
{
	ClientClass = class'DLCTabCW';
	FixedAreaClass = None;
	Super(UWindowScrollingDialogClient).Created();
}