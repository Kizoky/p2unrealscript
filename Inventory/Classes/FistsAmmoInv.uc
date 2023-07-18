///////////////////////////////////////////////////////////////////////////////
// Fists ammo
///////////////////////////////////////////////////////////////////////////////
class FistsAmmoInv extends InfiniteAmmoInv;

var() array<Sound> PunchSounds;						// Sounds made when punching
var() Sound PunchWall, HeadPunchSound;				// Sounds made when punching
var() int DamageJab;								// Damage caused by jab
var() int DamageUppercut;							// Damage caused by uppercut
var() int DamageDownward;							// Damage caused by downward punch
var() int DamageHeadPunch;							// Damage caused by enhanced-mode-only head punch
var() class<DamageType> DamageTypeInflictedNPC;		// Class of damage inflicted to NPCs, by the player (non-lethal damage for fists)
var() bool bAllowHeadPunch;							// True if we allow the head punch (false for fists because they're non-lethal)
var() float NonLethalDamageBoost;					// Damage multiplier when inflicting non-lethal damage (dealt by the player, to the NPCs)

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector mom;
	local float UseDamage;
	local bool bHeadPunch;
	local float PercentUpBody;
	local class<DamageType> UseDamageType;
	local float NonLethalDamageMod;
	const HEADPUNCH_PCT = 0.75;
	
	if (Instigator.Controller.bIsPlayer)
	{
		UseDamageType = DamageTypeInflictedNPC;
		NonLethalDamageMod = NonLethalDamageBoost;
	}
	else
	{
		UseDamageType = DamageTypeInflicted;
		NonLethalDamageMod = 1;
	}

	if ( Other == None )
		return;

	if(Pawn(Other) == None
		&& PeoplePart(Other) == None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-HitNormal);
		NewRot.Roll=(65536*FRand());

		smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',,,HitLocation, Rotator(HitNormal));
		if(FRand()<0.3)
		{
			dirt1 = Spawn(class'Fx.DirtClodsMachineGun',,,HitLocation, Rotator(HitNormal));
		}
		if(FRand()<0.15)
		{
			spark1 = Spawn(class'Fx.SparkHitMachineGun',,,HitLocation, Rotator(HitNormal));
		}
	}


	if ( (Other != self) && (Other != Owner) )
	{
		if (Pawn(Other) == None)
			Instigator.PlaySound(PunchWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		else if (P2MocapPawn(Other) != None)
			{
				if (P2MocapPawn(Other).MyRace < RACE_Automaton)
					Instigator.PlaySound(PunchSounds[Rand(PunchSounds.Length)], SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
					Instigator.PlaySound(PunchWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
					Instigator.PlaySound(PunchWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			}
		else
			Instigator.PlaySound(PunchSounds[Rand(PunchSounds.Length)], SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());

		PercentUpBody = (HitLocation.Z - Other.Location.Z) / Other.CollisionHeight;
		
		if (P2Weapon(W).bAltFiring)
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
            	mom = MomentumHitMag * VRand();
				mom += MomentumHitMag * Y;
				UseDamage = DamageDownward * NonLethalDamageMod;
				mom.z *= -0.2;
				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, mom, UseDamageType);
			}
		}
		else if(!FistsWeapon(W).bRightFist)
		{
			// Left
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
            	mom = MomentumHitMag * VRand();
				mom += MomentumHitMag * Y;
				switch (FistsWeapon(W).AnimPlayed)
				{
					case 0: // Left jab
						UseDamage = DamageJab * NonLethalDamageMod;
						break;

//					case 1: // Left downwards
//						UseDamage = DamageDownward;
//						mom.z *= -0.2;
//						break;

					case 1: // Left uppercut
						UseDamage = DamageUppercut * NonLethalDamageMod;
						mom.z *= 0.2;
						if (bAllowHeadPunch
							&& P2GameInfoSingle(Level.Game).VerifySeqTime()
							&& Pawn(Owner).Controller.bIsPlayer
							&& FRand() <= HEADPUNCH_PCT
							&& PercentUpBody > P2Pawn(Other).HEAD_RATIO_OF_FULL_HEIGHT)
						{
							bHeadPunch = true;
							UseDamage = DamageHeadpunch;
							UseDamageType = DamageTypeInflicted;
							mom.z += 50000;
							mom.z *= 2;
						}
						break;
				}
				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, mom, UseDamageType);
			}
		}
		else
		{
			// Right
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
            	mom = MomentumHitMag * VRand();
				mom -= MomentumHitMag * Y;

				switch (FistsWeapon(W).AnimPlayed)
				{
					case 0: // Right jab
						UseDamage = DamageJab * NonLethalDamageMod;
						break;

					case 1: // Right uppercut
						UseDamage = DamageUppercut * NonLethalDamageMod;
						mom.z *= 0.2;
						if (bAllowHeadPunch
							&& P2GameInfoSingle(Level.Game).VerifySeqTime()
							&& Pawn(Owner).Controller.bIsPlayer
							&& FRand() <= HEADPUNCH_PCT
							&& PercentUpBody > P2Pawn(Other).HEAD_RATIO_OF_FULL_HEIGHT)
						{
							bHeadPunch = true;
							UseDamage = DamageHeadpunch;
							UseDamageType = DamageTypeInflicted;
							mom.z += 50000;
							mom.z *= 2;
						}
						break;
				}

				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, mom, UseDamageType);
			}
		}
		
		// Knock their block off - Enhanced mode only
		if (bHeadPunch
			&& P2MoCapPawn(Other) != None
			&& P2Pawn(Other).bHasHead
			&& P2Pawn(Other).bHeadCanComeOff
			&& Pawn(Other).Health <= 0
			&& P2MoCapPawn(Other).MyHead != None
			)
		{
			// Make an extra squish sound
			P2MoCapPawn(Other).MyHead.PlaySound(HeadPunchSound, SLOT_None, 1.0,,TransientSoundRadius,0.5 * GetRandPitch());
			// Knock off head and send it flying
			P2MoCapPawn(Other).PopOffHead(HitLocation, mom * 3);
			// This kills you for sure
			P2MoCapPawn(Other).bSlomoDeath = True;
				
			// If it's a zombie just blow up the head
			if (Other.IsA('AWZombie'))
				P2MoCapPawn(Other).MyHead.TakeDamage(UseDamage, Pawn(Owner), HitLocation, mom, class'ShotgunBulletAmmoInv'.Default.DamageTypeInflicted);
		}
		
		// If we hit a pawn make the weapon a little bloody
		if ((W.Class == class'FistsWeapon')
			&& Pawn(Other) != None
			&& (P2MocapPawn(Other) == None
			|| P2MocapPawn(Other).MyRace < RACE_Automaton))
			P2BloodWeapon(W).DrewBlood();
	}
}

defaultproperties
{
	DamageJab=4
	DamageUppercut=8
	DamageDownward=15
	DamageHeadPunch=100
	bInstantHit=true
	Texture=Texture'AW7Tex.Icons.Icon_Weapon_Fists'
	DamageTypeInflicted=class'FistsDamage'
	DamageTypeInflictedNPC=class'FistsDamageNonLethal'
	MomentumHitMag=30000
	TransientSoundRadius=80
	PunchSounds(0)=Sound'AW7Sounds.Dusters.Punch1'
	PunchSounds(1)=Sound'AW7Sounds.Dusters.Punch2'
	PunchSounds(2)=Sound'AW7Sounds.Dusters.Punch3'
	PunchSounds(3)=Sound'AW7Sounds.Dusters.Punch4'
	PunchWall=Sound'AW7Sounds.Dusters.Punch_Wall2'
	HeadPunchSound=Sound'WeaponSounds.foot_kickhead'
	NonLethalDamageBoost=2
}
