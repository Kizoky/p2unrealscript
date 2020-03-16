///////////////////////////////////////////////////////////////////////////////
// DonutInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Donut inventory item.
//
//	You can eat donuts to get a little bit of health back. Or you can
//  throw them on the ground and lure pawns that have a high donut love.
//
///////////////////////////////////////////////////////////////////////////////

class DonutInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
// This is a stack of static meshes for the visual display of each donut we've
// picked up. We'll transfer this back to the pickup we drop, so it looks
// like we dropped the same donut we picked up. It's a stack so first doughnut
// in, will be last doughnut out.
var /*travel*/ array<StaticMesh> DonutMeshes;
var travel array<int> TaintedOnes;
var float HealingPct;	// Percentage of how much health you add

///////////////////////////////////////////////////////////////////////////////
// Generally used by QuickHealth player key to determine which powerup he
// should use next when healing himself.
///////////////////////////////////////////////////////////////////////////////
simulated function float RateHealingPower()
{
	local P2Pawn CheckPawn;

	CheckPawn = P2Pawn(Owner);
	if(CheckPawn != None)
	{
		return CheckPawn.HealthPctConversion*HealingPct;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add this in
// We can send in the skin of the new types being added.
///////////////////////////////////////////////////////////////////////////////
function AddAmount(int AddThis, 
				   optional Texture NewSkin, 
				   optional StaticMesh NewMesh,
				   optional int IsTainted)
{
	local int cur, i;

	// Add in the number
	Super.AddAmount(AddThis);

	if(AddThis > 0)
	{
		// Save the mesh, no matter if it's different or the same for the
		// donuts we have already, add it to the stack
		cur = DonutMeshes.Length;
		DonutMeshes.Insert(DonutMeshes.Length, AddThis);
		for(i=0; i < AddThis; i++)
		{
			if(NewMesh != None)
				DonutMeshes[cur + i] = NewMesh;
			else
				DonutMeshes[cur + i] = StaticMesh;
		}
		// Save our tainted state
		cur = TaintedOnes.Length;
		TaintedOnes.Insert(TaintedOnes.Length, AddThis);
		for(i=0; i < AddThis; i++)
		{
			TaintedOnes[cur + i] = IsTainted;
		}
		//log(self$" added "$NewMesh$" length "$DonutMeshes.Length);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add this in and save the mesh
///////////////////////////////////////////////////////////////////////////////
function ReduceAmount(int UseAmount, 
					  optional out Texture NewSkin, 
					  optional out StaticMesh NewMesh,
					  optional out int IsTainted,
					  optional bool bNoUsedUp)
{
	if(UseAmount > 1)
		Warn(self$" ReduceAmount can't drop more than one thing at a time");
	// Send the mesh back out.
	NewMesh = DonutMeshes[DonutMeshes.Length-1];
	if (NewMesh == None)
		NewMesh = StaticMesh;

	log(self$" removing "$NewMesh$" length "$DonutMeshes.Length);

	DonutMeshes.Remove(DonutMeshes.Length-1, 1);

	// Save tainted quality
	if(TaintedOnes.Length > 0)
	{
		IsTainted = TaintedOnes[TaintedOnes.Length-1];
		TaintedOnes.Remove(TaintedOnes.Length-1, 1);
	}

	Super.ReduceAmount(UseAmount, NewSkin, NewMesh, IsTainted, bNoUsedUp);
}

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	function bool EatIt()
	{
		local P2Pawn CheckPawn;
		local int IsTainted;

		CheckPawn = P2Pawn(Owner);

		IsTainted = TaintedOnes[TaintedOnes.Length-1];
		// if tainted == 1, we'll divide 2, otherwise, the normal amount will be granted.
		if(CheckPawn.AddHealthPct(HealingPct/(1 + IsTainted), IsTainted, , , , true))
		{
			TurnOffHints();	// When you use it, turn off the hints

			ReduceAmount(1);
			// Kamek 4-29
			// If they're wearing cop clothes reward them for it.
			if ((P2Player(CheckPawn.Controller) != None) && (class<ClothesInv>(P2Player(CheckPawn.Controller).CurrentClothes).Default.bIsCopUniform))
			{
				if(Level.NetMode != NM_DedicatedServer ) PlayerController(CheckPawn.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(CheckPawn.Controller),'DonutsEaten',1,True);
			}
				
			return true;
		}
		return false;
	}
Begin:
	EatIt();
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	HealingString="You ate a donut."
	HealingPct=3
	PickupClass=class'DonutPickup'
	Icon=Texture'Hudpack.icons.icon_inv_doughnut'
	StaticMesh=StaticMesh'Timb_mesh.fast_food.donut1_timb'
	DonutMeshes[0]=StaticMesh'Timb_mesh.fast_food.donut1_timb'
	InventoryGroup=100
	GroupOffset=4
	PowerupName="Donut"
	PowerupDesc="Good for what ails you. Pigs love 'em!"
	bEdible=true
	ExamineAnimType="Letter"
	ExamineDialog=Sound'DudeDialog.dude_ithinkineedthat'
	Hint1="Good for what ails you."
	}
