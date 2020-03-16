class AnthraxHack extends Info;

var LambController MyController;

const ANTHRAX_RUN_TIME = 5.00;

function SetupBy(LambController LC)
{
	MyController = LC;
	SetTimer(ANTHRAX_RUN_TIME, false);
}

event Timer()
{
	if (MyController != None)
		MyController.GotoNextState();
	Destroy();
}
