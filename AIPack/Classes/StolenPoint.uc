///////////////////////////////////////////////////////////////////////////////
// Checks pawns that pass through it for inventory items that they 
// might have stolen. Alerts the legal owners of them being stolen
//
// Also triggers the owner of the Event tag.
//
// Multiples of these points can point to the same cashier.
///////////////////////////////////////////////////////////////////////////////
class StolenPoint extends KeyPoint;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// External variables

var ()name  LegalOwnerTag;		// tag for the legal owner
var ()class	InvClassToCheck;	// Inventory items that of this class will be checked
								// for a paid status

// Internal variables
var P2Pawn LegalOwner;			//	Guy who legal owns the powerups in question


///////////////////////////////////////////////////////////////////////////////
// match this tag to its actor
///////////////////////////////////////////////////////////////////////////////
function UseTagToNearestActor(Name UseTag, out Actor UseActor, float randval, 
							  optional bool bDoRand, optional bool bSearchPawns)
{
	local Actor CheckA, LastValid;
	local float dist, keepdist;
	local class<Actor> useclass;

	if(UseTag != 'None')
	{
		dist = 65535;
		keepdist = dist;
		UseActor = None;

		if(bSearchPawns)
			useclass = class'FPSPawn';
		else
			useclass = class'Actor';

		ForEach AllActors(useclass, CheckA, UseTag)
		{
			// don't allow it to pick you, even if your tag is valid
			if(CheckA != self
				&& !CheckA.bDeleteMe)
			{
				LastValid = CheckA;
				dist = VSize(CheckA.Location - Location);
				if(dist < keepdist
					&& (!bDoRand ||	FRand() <= randval))
				{
					keepdist = dist;
					UseActor = CheckA;
				}

			}
		}

		if(UseActor == None)
			UseActor = LastValid;

		if(UseActor == None)
			log("ERROR: could not match with tag "$UseTag);
	}
	else
		UseActor = None;	// just to make sure
}

///////////////////////////////////////////////////////////////////////////////
// See what passed through us
///////////////////////////////////////////////////////////////////////////////
function CheckHitter(Actor Other)
{
	local P2Pawn p2p;
	local Inventory inv;
	local PersonController Personc;
	local OwnedPickup ownedp;

	p2p = P2Pawn(Other);

	// If a guy with an inventory walked through us
	if(p2p != None)
	{
		if(LegalOwner != None)
			Personc = PersonController(LegalOwner.Controller);

		if(Personc != None)
		{
			inv = Personc.HasYourProduct(p2p, LegalOwner);

			if(inv != None)
			{
				//log("AND IT'S STOLEN!!");

				// Tell the one who stole things
				Personc.PersonStoleSomething(p2p, OwnedInv(inv));

				// Trigger your event
				TriggerEvent(Event, self, p2p);
			}
		}
	}
	else // check for someone throwing owned pickups through me
	{
		ownedp = OwnedPickup(Other);

		if(ownedp != None)
		{
			if(LegalOwner != None)
				Personc = PersonController(LegalOwner.Controller);
			if(Personc != none)
			{
				log("someone threw a pickup outside!!!");
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Something has activated me
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	CheckHitter(Other);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Init things that require the game going first before we can depend on them
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Init
{
	function BeginState()
	{
		local Actor Other;
		log("stolen point instance-------------: "$self);

		UseTagToNearestActor(LegalOwnerTag, Other, 1.0, , true);
		LegalOwner = P2Pawn(Other);
		if(LegalOwner == None)
			log("ERROR: Legal Owner Tag must be set: No one owns this thing being stolen! "$self);

		log("my tag "$Tag);
		log("concerned classes name "$InvClassToCheck.Name);
		log("owner tag "$LegalOwnerTag);
		log("owner actor "$LegalOwner);
	}

Begin:
	GotoState('');
}

defaultproperties
{
	 bStatic=False
     bCollideActors=True
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
	 CollisionRadius=256
	 CollisionHeight=128
	 InvClassToCheck=class'OwnedInv'
	 Texture=Texture'PostEd.Icons_256.StolenPoint'
	DrawScale=0.25
}
