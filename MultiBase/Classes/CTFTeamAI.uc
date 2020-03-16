class CTFTeamAI extends TeamAI;

var CTFFlag FriendlyFlag, EnemyFlag; 
var float LastGotFlag;

function SquadAI AddSquadWithLeader(Controller C, GameObjective O)
{
	local CTFSquadAI S;

	if ( O == None )
		O = EnemyFlag.HomeBase;
	S = CTFSquadAI(Super.AddSquadWithLeader(C,O));
	if ( S != None )
	{
		S.FriendlyFlag = FriendlyFlag;
		S.EnemyFlag = EnemyFlag;
	}
	return S;
}

defaultproperties
{
	SquadType=class'MultiBase.CTFSquadAI'
}