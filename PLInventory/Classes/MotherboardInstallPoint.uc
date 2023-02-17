///////////////////////////////////////////////////////////////////////////////
// MotherboardInstallPoint
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Used to define points in the arcade where the player can install motherboards.
///////////////////////////////////////////////////////////////////////////////
class MotherboardInstallPoint extends Triggers;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////

// Dummied out - went with ActorModifiers instead
//var(Arcade) name AssociatedActor;		// Tag of actor to alter when installed
//var(Arcade) array<Material> NewSkins;	// New skins to apply when installed

var bool bInstalled;	// Set to true if a motherboard is installed here already

///////////////////////////////////////////////////////////////////////////////
// Attempt to install a motherboard here.
///////////////////////////////////////////////////////////////////////////////
function bool InstallMotherboard(Pawn EventInstigator)
{
	local Actor UseActor;
	local int i;
	
	if (!bInstalled)
	{
		// Install the item.
		bInstalled = True;
		// Set the arcade to installed
		/*
		foreach AllActors(class'Actor', UseActor, AssociatedActor)
		{
			log("change skins of"@UseActor);
			UseActor.Skins.Length = NewSkins.Length;
			for (i = 0; i < NewSkins.Length; i++)
				if (NewSkins[i] != None)
					UseActor.Skins[i] = NewSkins[i];
		}
		*/
		// Activate our trigger
		//log(self@"trigger"@Event@Self@EventInstigator);
		TriggerEvent(Event, self, EventInstigator);		
		// And report success
		return true;
	}
	// failed
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// When triggered, flag as installed
///////////////////////////////////////////////////////////////////////////////
event Trigger(Actor Other, Pawn EventInstigator)
{
	bInstalled = True;
}

///////////////////////////////////////////////////////////////////////////////
// Change their inventory to the Motherboard and give them a hint on how to
// use it.
///////////////////////////////////////////////////////////////////////////////
function Touch( Actor Other )
{
	local P2Player p2p;
	
	if (!bInstalled
		&& Pawn(Other) != None
		&& P2Player(Pawn(Other).Controller) != None)
	{
		// Switch to their motherboard and turn on its hints
		p2p = P2Player(Pawn(Other).Controller);
		p2p.SwitchToThisPowerup(class'MotherboardInv'.Default.InventoryGroup, class'MotherboardInv'.Default.GroupOffset);
		if (MotherboardInv(Pawn(Other).SelectedItem) != None)
		{
			MotherboardInv(Pawn(Other).SelectedItem).RefreshHints();
			p2p.UpdateHudInvHints();
		}
	}
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.motherboardpoint'
}