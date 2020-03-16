///////////////////////////////////////////////////////////////////////////////
// GaryHeadPickup
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////

class GaryHeadPickup extends OwnedPickup;

var class<P2Emitter> fireclass;
var P2Emitter MyFire;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function InitGH()
{
	local P2GameInfoSingle useinfo;

	useinfo = P2GameInfoSingle(Level.Game);
	if(useinfo != None)
	{
		// Keep trying to verify sequence time
		if (useinfo.TheGameState == None)
			return;
		//log("GH"@useinfo.VerifyGH()@"Seq"@useinfo.VerifySeqTime());
		if(!useinfo.VerifyGH()
			|| !useinfo.VerifySeqTime())
		{
			Destroy();
			return;
		}
	}

	// The burning bush, but not as holy, the book is engulfed in fire, yet not consumed
	if(fireclass != None)
	{
		MyFire = spawn(fireclass, self, , Location);
		MyFire.SetBase(self);
	}
	
	Disable('Tick');
}

event Tick(float dT)
{
	// Try to init until GameState is valid
	InitGH();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	Super.Destroyed();
	if(MyFire != None)
	{
		MyFire.Destroy();
		MyFire = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     FireClass=Class'AWEffects.GaryBookFire'
     InventoryType=Class'AWInventory.GaryHeadInv'
     PickupMessage="You picked up a Power-Infused Gary Autobiography!"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'stuff.stuff1.GaryBook'
}
