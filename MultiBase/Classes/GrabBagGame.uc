///////////////////////////////////////////////////////////////////////////////
// GrabBagGame
//
// The end of the game is generally reached with finding and holding
// all 10 flavins. Flavins make you more powerful, the more you have.
// Kills don't go toward your score, only collecting flavins/bags do.
//
///////////////////////////////////////////////////////////////////////////////
class GrabBagGame extends DeathMatch
	config;

///////////////////////////////////////////////////////////////////////////////
// Only count kills, score doesn't factor in kills
///////////////////////////////////////////////////////////////////////////////
function ScoreKill(Controller Killer, Controller Other)
{
	// Don't score suicides as anything (don't even log them as kills)
    if( (killer == Other) || (killer == None) )
	{
    	if (Other!=None)
        {
			//Other.PlayerReplicationInfo.Score -= 1;
			//ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
        }
	}
    else if ( killer.PlayerReplicationInfo != None )
	{
		// Kills on other players don't give you more score, they just up your kills
		//Killer.PlayerReplicationInfo.Score += 1;
		Killer.PlayerReplicationInfo.Kills++;
		//ScoreEvent(Killer.PlayerReplicationInfo,1,"frag");
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

    if ( (Killer != None) || (MaxLives > 0) )
		CheckScore(Killer.PlayerReplicationInfo);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ScoreBag(Controller Scorer, int Amount)
{
	Scorer.PlayerReplicationInfo.Score += Amount;
	//ScoreEvent(Scorer.PlayerReplicationInfo,Amount,"frag");
	if(PlayerController(Scorer) != None)
	{
		//log(self$" dropper "$Scorer.Pawn$" health "$Scorer.Pawn.Health$" score "$Scorer.PlayerReplicationInfo.Score$" amount "$Amount);
		if(Scorer.Pawn != None
			&& Scorer.Pawn.Health > 0)
		{
			if(Amount > 0)	// gained power
				PlayerController(Scorer).ReceiveLocalizedMessage( class'GBMessage', 5);
			else if(Scorer.PlayerReplicationInfo.Score > 0)	// lost power (dropped flavin) but still alive
				PlayerController(Scorer).ReceiveLocalizedMessage( class'GBMessage3', 5);
			else // You have one point left on the client and you're losing it--so you'll lose all your power
				PlayerController(Scorer).ReceiveLocalizedMessage( class'GBMessage2', 5);
		}
		else if(Scorer.PlayerReplicationInfo.Score==0)
			// dropped them all--dead (only send the message on the last one to get dropped
			// when your score is finally 0)
			PlayerController(Scorer).ReceiveLocalizedMessage( class'GBMessage2', 5);
	}

	CheckScore(Scorer.PlayerReplicationInfo);

    if ( bOverTime )
    {
		EndGame(Scorer.PlayerReplicationInfo,"timelimit");
    }
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	if ( (Killer == Other) || (Killer == None) )
        BroadcastLocalized(self,DeathMessageClass, 1, None, Other.PlayerReplicationInfo, damageType);
	else 
        BroadcastLocalized(self,DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
}
*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function MaintainBagCount()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Match in progress
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
State MatchInProgress
{
	function Timer()
	{
		MaintainBagCount();
		Super.Timer();
	}

}

defaultproperties
{
	GameName="Grab"
	BeaconName="GB"
	GoalScore=10
	bPlayersMustBeReady=true
	// Grab Bag Menu Settings Type
	SettingsMenuType="UTBrowser.UTGBSettingsSClient";
}
