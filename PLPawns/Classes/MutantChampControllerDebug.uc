// Debug version of Mutant Champ that just idles (so we can adjust its collision boxes without it trying to kill us)
class MutantChampControllerDebug extends MutantChampController;

function DecideNextMove() {
	gotoState('Idle');
}
