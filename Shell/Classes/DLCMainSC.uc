class DLCMainSC extends UTMenuStartMatchSC;

function Created()
{
	ClientClass = class'DLCMainCW';
	FixedAreaClass = None;
	Super(UWindowScrollingDialogClient).Created();
}