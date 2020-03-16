class UTMenuMutatorSC extends UMenuStartMatchScrollClient;

function Created()
{
	ClientClass = class'UMenuMutatorCW';
	FixedAreaClass = None;
	Super(UWindowScrollingDialogClient).Created();
}