//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class Kumquat extends Bystander
 	placeable;

// Kamek 5-21
// If they die by grenade head explosion, award the player for juxtaposition
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local P2Player P;
	
	if (damageType == class'ExplodedDamage'
		&& P2Player(Killer) != None
		&& P2Player(Killer).bCommitedSuicide)
	// This may or may not work, Killer might be invalid after the dude commits suicide.
	{
		if(Level.NetMode != NM_DedicatedServer ) P2Player(Killer).GetEntryLevel().EvaluateAchievement(P2Player(Killer),'ReversePsychology');
	}
		
	Super.Died(Killer, DamageType, HitLocation);
}

defaultproperties
	{
	ActorID="Terrorist"
	Skins[0]=Texture'ChameleonSkins.Special.Kumquat'
	Mesh=Mesh'Characters.Fem_LS_Skirt'
	HeadSkin=Texture'ChamelHeadSkins.Special.Kumquat'
	HeadMesh=Mesh'Heads.FemSHcropped'
	bRandomizeHeadScale=false
	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	ControllerClass=class'KumquatController'
	Gang="Kumquat"
	bIsFemale=true
	bIsHindu=true
	TalkWhileFighting=0.0
	Boltons[0]=(bone="NODE_Parent",staticmesh=staticmesh'boltons.Burka_Mask_Sara',bCanDrop=false,bAttachToHead=true)
	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
	}
