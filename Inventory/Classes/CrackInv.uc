///////////////////////////////////////////////////////////////////////////////
// CrackInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Crack inventory item.
//
///////////////////////////////////////////////////////////////////////////////

class CrackInv extends P2PowerupInv;

var Sound InhaleSound;
var Sound ExhaleSound;	// sounds for smokin'!
var bool bWorked;
var vector SmokeColor;
var float AltHealingPct;

/*
replication
{
	reliable if(Role==ROLE_Authority)
		BlowingSmoke;
}
*/

///////////////////////////////////////////////////////////////////////////////
// Generally used by QuickHealth player key to determine which powerup he
// should use next when healing himself.
///////////////////////////////////////////////////////////////////////////////
simulated function float RateHealingPower()
{
	local P2MocapPawn CheckPawn;

	CheckPawn = P2MocapPawn(Owner);

	if(CheckPawn != None)
		return (CheckPawn.HealthMax*CheckPawn.CrackMaxHealthPercentage);
	else
		return 0;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function BlowingSmoke()
{
	local P2MocapPawn CheckPawn;
	local P2Player p2p;

	CheckPawn = P2MocapPawn(Owner);
	p2p = P2Player(CheckPawn.Controller);

	p2p.BlowSmoke(SmokeColor);
}

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	ignores Activate;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool SmokeIt()
	{
		local P2MocapPawn CheckPawn;
		local float HealingAmount;	// How much health you add

		CheckPawn = P2MocapPawn(Owner);

		TurnOffHints();	// When you use it, turn off the hints


		// calc how much we need to get to our max health goal		
		if (P2GameInfo(Level.Game).InVeteranMode())	// xPatch: In veteran mode it gives +25% health.
			HealingAmount = Min(CheckPawn.HealthPctConversion*AltHealingPct, (CheckPawn.HealthMax*CheckPawn.CrackMaxHealthPercentage - CheckPawn.Health));
		else
			HealingAmount = (CheckPawn.HealthMax*CheckPawn.CrackMaxHealthPercentage) - CheckPawn.Health;

		if(CheckPawn.AddHealth(HealingAmount,,,true, true))
		{
			Amount -= 1;	// Don't check just yet if we're used up
							// but do remove this one from the pile.
			return true;
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function CommentOnIt()
	{
		local P2MocapPawn CheckPawn;

		CheckPawn = P2MocapPawn(Owner);
		if(P2Player(CheckPawn.Controller) != None)
		{
			P2Player(CheckPawn.Controller).CommentOnCrackUse();
			if(P2GameInfoSingle(Level.Game) != None)
				P2GameInfoSingle(Level.Game).TheGameState.SmokedCrackPipe();
		}
	}

Begin:
	SmokeIt();
	BlowingSmoke();
	Owner.PlaySound(ExhaleSound);
	Sleep(Owner.GetSoundDuration(ExhaleSound));
	CommentOnIt();
	// Check now if we're out of these.
	if(Amount <= 0)
		UsedUp();

	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	HealingString="You smoked a health pipe."
	PickupClass=class'CrackPickup'
	Icon=Texture'HUDPack.Icon_Inv_Crack'
	InventoryGroup=100
	GroupOffset=1
	PowerupName="Health Pipe"
	PowerupDesc="Warning: Causes unnatural health boosts and severe addiction in laboratory animals."
	InhaleSound=Sound'WMaleDialog.wm_inhale'
	ExhaleSound=Sound'WMaleDialog.wm_exhale'
	Hint1="Press %KEY_InventoryActivate% to smoke this."
	Hint2="Warning: Causes unnatural health boosts"
	Hint3="and severe addiction in laboratory animals."
	SmokeColor=(X=255,Y=255,Z=255)
	AltHealingPct=30
	}
