class SnipingVolume extends Volume;

var MpScriptedSequence SnipingPoints[16];

function AddDefensePoint(MpScriptedSequence S)
{
	local int i;

	for ( i=0; i<16; i++ )
		if ( SnipingPoints[i] == None )
		{
			SnipingPoints[i] = S;
			break;
		}
}

event Touch(Actor Other)
{
	local Pawn P;
	local int i;

	P = Pawn(Other);
	if ( (P == None) || !P.IsPlayerPawn() )
		return;
		
	for ( i=0; i<16; i++ )
	{
		if ( SnipingPoints[i] == None )
			break;
		else if ( Bot(SnipingPoints[i].CurrentUser) != None )
			Bot(SnipingPoints[i].CurrentUser).SetEnemy(P);
	}
}

			