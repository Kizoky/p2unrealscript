class xGrabBag extends GrabBagGame;

var int BagCheckTime;	// Handles how often we test bag count
var int ErrorCount;		// Counts how many times in a row there's an error--when it gets high enough
						// the error is corrected. 

const BAG_CHECK_TIME		=	5.0;
const BAG_CHECK_ERROR_TIME	=	2.0; // check more often when there's a possible error
const ERROR_MAX				=	3;


///////////////////////////////////////////////////////////////////////////////
// Check to make sure the number of bags in the level are equal to the number
// of original pickups placed in the level--should be 10 at all times.
///////////////////////////////////////////////////////////////////////////////
function MaintainBagCount()
{
	local FlavinPickup fp;
	local int GoalCount; 
	local int ActivePlacedPickups, ActiveDropPickups, TotalScore, MissingNum;
	local PlayerReplicationInfo pri;

	// only update every so many seconds
	BagCheckTime += Level.TimeDilation;

	if(BagCheckTime > BAG_CHECK_TIME)
	{
		BagCheckTime=0; // reset

		// Check all flavins in the level
		foreach DynamicActors(class'FlavinPickup', fp)
		{
			// Checks for placed ones
			if(!fp.bDropped)
			{
				GoalCount+=fp.AmountToAdd;;
				if(!fp.IsInState('Sleeping'))
					ActivePlacedPickups+=fp.AmountToAdd;
			}
			else // checks dropped ones
			{
				ActiveDropPickups+=fp.AmountToAdd;
			}
		}
		// Check for bags players have in their scores
		foreach DynamicActors(class'PlayerReplicationInfo', pri)
		{
			TotalScore += pri.Score;
		}

		// General warning for modders
		if(GoalScore != GoalCount)
			warn(" Number of bags ("$GoalCount$") in the level not equal to Goal Score for level ("$GoalScore$")");

		MissingNum = GoalCount - (TotalScore + ActivePlacedPickups + ActiveDropPickups);
		if(MissingNum > 0)
		{
			warn(" Missing "$MissingNum$" bags in this level");
			warn(self$" Total score "$TotalScore$" placed "$ActivePlacedPickups$" dropped "$ActiveDropPickups$" goal "$GoalCount);

			BagCheckTime = BAG_CHECK_TIME - BAG_CHECK_ERROR_TIME;
			ErrorCount++;
			if(ErrorCount == ERROR_MAX)
			{
				warn(" Too few bags in level for goal--correcting with this pickup ");
				ErrorCount = 0;
				BagCheckTime = 0;
				foreach DynamicActors(class'FlavinPickup', fp)
				{
					// Checks for placed ones that are sleeping and revive the necessary
					// number
					if(!fp.bDropped
						&& fp.IsInState('Sleeping'))
					{
						fp.GotoState('Pickup');
						MissingNum--;
						if(MissingNum == 0)
							return;
					}
				}
			}
		}
	}
}

defaultproperties
{
	GoalScore=10

	HUDType="MultiGame.GBHUD"
	ScoreBoardType="MultiGame.GBScoreBoard"

	MapNameGameCode="g"	// must be lower case!
	MapListType="MultiGame.GBMapList"
	GameReplicationInfoClass=Class'MultiBase.MpGameReplicationInfo'
	DeathMessageClass=class'MultiGame.xDeathMessage'
	MutatorClass="MultiGame.xMutator"
	LevelRulesClass=class'LevelGamePlay'

	GameBaseEquipment[0]=(weapclass=class'Inventory.UrethraWeapon')
	GameBaseEquipment[1]=(weapclass=class'Inventory.FootWeapon')
	GameBaseEquipment[2]=(weapclass=class'Inventory.BatonWeapon')
	GameBaseEquipment[3]=(weapclass=class'Inventory.PistolWeapon')
	GameBaseEquipment[4]=(weapclass=class'Inventory.RadarInv')

	MutList[0]="MultiGame.MutNoSavedHealth"
}
