class WorkshopStartMatchSC extends UTMenuStartMatchSC;

function Created()
{
	ClientClass = class'WorkshopStartMatchCW';
	FixedAreaClass = None;
	Super(UWindowScrollingDialogClient).Created();
}