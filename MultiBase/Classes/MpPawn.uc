///////////////////////////////////////////////////////////////////////////////
// MpPawn.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Multiplayer pawn.
//
///////////////////////////////////////////////////////////////////////////////
class MpPawn extends P2MoCapPawn
	abstract;


var string VoiceType;

var	float	AttackSuitability;		// range 0 to 1, 0 = pure defender, 1 = pure attacker
var eDoubleClickDir CurrentDir;

var vector GameObjOffset;
var rotator GameObjRot;
var bool bOnlyGibs;						// Don't do ragdoll or animate on death--explode into giblets.
var float FlavinNum;
var float FlavinMult;


const HEAD_PITCH_RATIO	=	0.28;
const USE_HEAD_SIZE		=	9;


replication
{
	// functions server sends to client
	reliable if(Role == ROLE_Authority)
		ClientUpdateFlavin;
}


///////////////////////////////////////////////////////////////////////////////
// Destroy all inventory items
///////////////////////////////////////////////////////////////////////////////
function DestroyAllInventory( )
{
	local Inventory Inv, Next;
	local int count;

	Inv = Inventory;
	while ( Inv != None )
	{
		Next = Inv.Inventory;
		Inv.Destroy();
		Inv = Next;
		if ( Level.NetMode == NM_Client )
		{
			Count++;
			if ( Count > 5000 )
			break;
		}
	}
	Inventory = None;
	SelectedItem = None;
	Weapon = None;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	local Inventory Inv, Next;
	local int count;
	local Rotator userot;
	local vector X,Y,Z;

	if(Role == ROLE_Authority)
	{
		Inv = Inventory;
		// primarily used to make sure flavin is dropped by the guy that
		// quits a mp game suddenly (leaves game)
		while ( Inv != None )
		{
			Next = Inv.Inventory;
			if(P2PowerupInv(Inv) != None
				&& P2PowerupInv(Inv).bMustBeDropped)
			{
				userot = Rotation;
				// drop each one
				if(P2PowerupInv(Inv).bThrowIndividually)
				{
					// drop from X down to 1 one left
					while(P2PowerupInv(Inv).Amount > 1)
					{
						userot.Yaw = FRand()*65535;
						Inv.velocity = vector(userot)*P2PowerupInv(Inv).GetTossMag();
						// And make the ThisWeap align with the direction of the throw
						Inv.SetRotation(userot);
						GetAxes(userot,X,Y,Z);
						Inv.DropFrom(Location + 0.3 * CollisionRadius * X + CollisionRadius * Z);
					}
				}

				// Final drop for multiples, first and only drop for 'drop all at once' powerups
				userot.Yaw = FRand()*65535;
				Inv.velocity = vector(userot)*P2PowerupInv(Inv).GetTossMag();
				// And make the ThisWeap align with the direction of the throw
				Inv.SetRotation(userot);
				GetAxes(userot,X,Y,Z);
				Inv.DropFrom(Location + 0.3 * CollisionRadius * X + CollisionRadius * Z);
			}
			Inv = Next;
		}
	}

	Super.Destroyed();
}

/* IsInLoadout()
return true if InventoryClass is part of required or optional equipment
*/
function bool IsInLoadout(class<Inventory> InventoryClass)
{
	// RWS CHANGE: Not doing anything here because we do something very 
	// different in a higher-level class (PersonPawn) and I don't want
	// this to conflict with it.  However, note that UnrealPawn does
	// a whole lot of shit, some of it to do with replication, that
	// we may need to do as well.
	return true;
}

function AddDefaultInventory()
{
	// RWS CHANGE: Not doing anything here because we do something very 
	// different in a higher-level class (PersonPawn) and I don't want
	// this to conflict with it.  However, note that UnrealPawn does
	// a whole lot of shit, some of it to do with replication, that
	// we may need to do as well.
}

function HoldGameObject(GameObject gameObj, name GameObjBone)
{
	if ( GameObjBone == 'None' )
	{
		GameObj.SetPhysics(PHYS_Rotating);
		GameObj.SetLocation(Location);
		GameObj.SetBase(self);
		GameObj.SetRelativeLocation(vect(0,0,0));
	}	
	else
	{
		AttachToBone(gameObj,GameObjBone);
		gameObj.SetRelativeRotation(GameObjRot);
		gameObj.SetRelativeLocation(GameObjOffset);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get headshot damage based on weapon--defined in MpPawn
///////////////////////////////////////////////////////////////////////////////
function int GetHeadShotDamageMP(class<DamageType> ThisDamage, int Damage)
{
	// percentages of full health
	const MACHINEGUN_HEADSHOT = 0.17;
	const SHOTGUN_HEADSHOT = 0.2;
	const PISTOL_HEADSHOT = 0.5;

	// These are calculated in absolutes of the health max and ignore
	// the DamageMult (but do incorporate flavin vals)
	if(ThisDamage == class'MachinegunDamage')
		Damage = MACHINEGUN_HEADSHOT*HealthMax;
	else if(ThisDamage == class'ShotgunDamage')
		Damage = SHOTGUN_HEADSHOT*HealthMax;
	else if(ThisDamage != class'RifleDamage')
		Damage = PISTOL_HEADSHOT*HealthMax;

	if(FlavinNum > 0)
		Damage = Damage + ((Damage*FlavinNum)*FlavinMult);

	return Damage;
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if this is a headshot in MP games
// Compensates for any bobbing/changes in head height for animation
// for each weapon. 
// Also factors in motion of head from pitch. ViewPitch changes in head position
// aren't represented by GetBoneCoords values so we have to handle that seperately also.
///////////////////////////////////////////////////////////////////////////////
function bool IsMPHeadshot(vector hitlocation)
{
	local float dist;
	local vector headloc;
	local int viewpitchdist;

	if(MyHead != None)
	{
		// Get animated head position
		headloc = GetBoneCoords(BONE_HEAD).Origin;
		// Modify height based on viewpitch
		if(ViewPitch >=128)
			viewpitchdist = 256 - ViewPitch;
		else
			viewpitchdist = ViewPitch;
		headloc.z -= viewpitchdist*HEAD_PITCH_RATIO;
		// calc distance of shot to head 
		dist = headloc.z - hitlocation.z;

		if(abs(dist) < USE_HEAD_SIZE)
			return true;
	}
	return false; // STUB
}

///////////////////////////////////////////////////////////////////////////////
// Only changes flavin for messages on clients--doesn't actually change
// power. That's handled on the server
///////////////////////////////////////////////////////////////////////////////
simulated function ClientUpdateFlavin(float NewMult)
{
	FlavinMult = NewMult;
}

///////////////////////////////////////////////////////////////////////////////
// Change the flavin mult to increase power
///////////////////////////////////////////////////////////////////////////////
function MagnifyFlavinMult(float Mult)
{
	FlavinMult=Mult*default.FlavinMult;
	ClientUpdateFlavin(FlavinMult);
}

///////////////////////////////////////////////////////////////////////////////
// Cooperate with instagib
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local int OldDamage;

	// Increase for attacker with flavin
	if(MpPawn(instigatedBy) != None
		&& MpPawn(instigatedBy).FlavinNum > 0)
	{
		Damage = Damage + (Damage*MpPawn(instigatedBy).FlavinNum)*FlavinMult;
		momentum = momentum + (momentum*MpPawn(instigatedBy).FlavinNum)*FlavinMult;
	}

	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

	if ( Health <= 0 
		&& bOnlyGibs)
	{
		ChunkUp(0);
	}
}
///////////////////////////////////////////////////////////////////////////////
// Cooperate with instagib
///////////////////////////////////////////////////////////////////////////////
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	if(!bOnlyGibs)
		Super.PlayDying(DamageType, HitLoc);
	// Don't do anything otherwise, so you can be gibbed up.
}

///////////////////////////////////////////////////////////////////////////////
// MpPawn--do follow me
///////////////////////////////////////////////////////////////////////////////
simulated function DoFollowMe()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
    PlayAnim('s_followme', 1.4, 0.1, WEAPONCHANNEL);
	// shout it!
	if(myDialog != None)
		Say(myDialog.lFollowMe);
}

///////////////////////////////////////////////////////////////////////////////
// MpPawn--do stay here
///////////////////////////////////////////////////////////////////////////////
simulated function DoStayHere()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
    PlayAnim('s_stayhere', 1.0, 0.1, WEAPONCHANNEL);
	// shout it!
	if(myDialog != None)
		Say(myDialog.lStayHere);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dying
{
	function BeginState()
	{
		if ( (LastStartSpot != None) && (Level.TimeSeconds - LastStartTime < 7) )
			LastStartSpot.LastSpawnCampTime = Level.TimeSeconds;
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// State simply added to keep guys that scored on remote clients in CTF
// from walking off.
// Also now, becuase we're trying to hide him, his head/body seems to 
// blink in every once in a while during the end party. So move him
// up very high, out of the way.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GameOver
{
	simulated function Timer()
	{
		// If were moving, then it might have problems, so keep setting it
		if(VSize(Velocity) > 0
			&& !bHidden)
			SetTimer(1.0, false);
		// Now clear it
		Velocity = vect(0,0,0);
		SetPhysics(PHYS_None);
		StopAnimating();
	}

	simulated function BeginState()
	{
		local vector useloc;

		// Make sure things don't get wacky when on a ladder when the match is over.
		bCanClimbLadders=false;

		// Turn off everything in the final shot
		if(P2Weapon(Weapon) != None)
			P2Weapon(Weapon).ForceEndFire();

		if(Health > 0)
		{
			SetPhysics(PHYS_None);
			StopAnimating();
			Velocity = vect(0,0,0);
			//useloc = Location;
			//useloc.z+=5000;
			//SetLocation(useloc);
			Timer();
		}
	}
}

defaultproperties
{
	FlavinMult	= 0.25
}
