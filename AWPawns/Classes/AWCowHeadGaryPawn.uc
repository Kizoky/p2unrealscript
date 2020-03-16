//=============================================================================
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//	Warning!
//	Do not use any of the 'initial states' such as Attack Player or Panic with
// this character or he may do unpredictable things. He will not function as
// expected. Just place this guy and let him go for expected results.
//=============================================================================
class AWCowheadGaryPawn extends AWGary
	placeable;


///////////////////////////////////////////////////////////////////////////////
// P2Pawn TakeDamage sends the real damage value into the Notify so when 
// this gary gets hit by anthrax, he doesn't get hurt, but he's constantly
// trying to reassess his attacker. Since we know he ignores it, it's ugly
// but let's just override it through new code. No anthrax hurts him.
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if(ClassIsChildOf(damageType, class'AnthDamage'))
	{
		if(TakesAnthraxDamage <= 0.0)
			return;
	}
	else
	{
		// This always blows up your head and kills you
		if(ClassIsChildOf(damageType, class'HeadKillDamage'))
		{
			ExplodeHead(HitLocation, Momentum);
			Damage = Health;
		}

		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Setup and destroy head
///////////////////////////////////////////////////////////////////////////////
function SetupHead()
{
	Super.SetupHead();

	// rotate our cowhead carefully
	if(myHead != None)
	{
		//log(Self$" new head rot "$MyHead.default.RelativeRotation);
		MyHead.SetRelativeRotation(MyHead.default.RelativeRotation);
	}
}

///////////////////////////////////////////////////////////////////////////////
//	Don't allow the head to be popped off like normal, instead explode
// it even if they just cut the head off
///////////////////////////////////////////////////////////////////////////////
function PopOffHead(vector HitLocation, vector Momentum)
{
	ExplodeHead(HitLocation, Momentum);
}

defaultproperties
{
	HeadClass=Class'AWPawns.AWGaryHeadCow'
	HeadSkin=Texture'StuffSkins.Items.CowHead_new'
	Twitch=1.500000
	TakesAnthraxDamage=0.000000
	WeapChangeDist=0.000000
	dialogclass=Class'AWPawns.DialogCowHeadGary'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.ScissorsWeapon')
	BaseEquipment(1)=(WeaponClass=Class'AWInventory.AWGrenadeWeapon')
	HealthMax=150.000000
	ControllerClass=Class'AWPawns.AWCowHeadGaryController'
	Skins(0)=Texture'AW_Characters.Zombie_Skins.Pygmy_skin'
	//Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel10
	//	KSkeleton="Avg_Mini_Skel"
	//	KFriction=0.500000
	//	Name="KarmaParamsSkel10"
	//End Object
	//KParams=KarmaParamsSkel'AWPawns.KarmaParamsSkel10'
	CharacterType=CHARACTER_Mini
}
