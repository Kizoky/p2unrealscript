// ampHolyExplosion
// Explosion that causes ampHolyDamage

class HolyExplosion extends GrenadeExplosion;
/*

var vector BlowOffMom;

///////////////////////////////////////////////////////////////////////////////
// Given this index, cut off that limb
// Assumes it's there to cut
// Uses given momentum instead of pre-calculated momentum
///////////////////////////////////////////////////////////////////////////////
function CutThisLimb(P2MoCapPawn BlowOffPawn, Pawn instigatedBy, int cutindex, vector momentum, float DoSound,
				 float DoBlood)
{
	local coords usec, usec2;
	local Limb uselimb;
	local rotator LimbRot;
	local Stump usestump;
	local P2Emitter sblood;
	local vector hitlocation, usev;
	local Vector UseMom;

	log(BlowOffPawn$".CutThisLimb: Instigator"@InstigatedBy@"CutIndex"@CutIndex@"Momemtum"@Momentum@"DoSound"@DoSound@"DoBlood"@DoBlood);

	// We got something chopped off
	BlowOffPawn.bMissingLimbs=true;
	// Mark if it was a leg, specifically
	if(cutindex == BlowOffPawn.LEFT_LEG
		|| cutindex == BlowOffPawn.RIGHT_LEG)
		BlowOffPawn.bMissingLegParts=true;

	// Shrink bone just before it, completely
	BlowOffPawn.SetBoneScale(cutindex+1, 0.0, BlowOffPawn.SeverBone[cutindex+1]);
	// Mostly shrink the bone we've specified to keep some of the joint
	BlowOffPawn.SetBoneScale(cutindex, 0.2, BlowOffPawn.SeverBone[cutindex]);
	// Both bones are gone now
	BlowOffPawn.BoneArr[cutindex+1] = 0;
	BlowOffPawn.BoneArr[cutindex] = 0;

	// Generate limb cut off
	// Move hit location to bone joint of the next part down
	usec = BlowOffPawn.GetBoneCoords(BlowOffPawn.SeverBone[cutindex+1]);
	hitlocation = usec.origin;
	// momentum for limbs is different
	LimbRot=rotator(usec.Xaxis);
	// Move the limb forward a little too, because it's centered in the limb, but
	// we want the joints to look close.
	hitlocation = BlowOffPawn.MOVE_LIMB*vector(LimbRot) + hitlocation;
//	Momentum = LimbMomMag*(Normal(HitLocation - Location) + 0.01*VRand());// + Velocity*Mass;
	UseMom = Momentum + 300*VRand();
	uselimb = spawn(BlowOffPawn.LimbClass,BlowOffPawn,,HitLocation,Rotation);
	if(uselimb != None)
	{
		uselimb.SetupLimb(BlowOffPawn.Skins[0], BlowOffPawn.AmbientGlow, LimbRot, BlowOffPawn.bIsFat, BlowOffPawn.bIsFemale, BlowOffPawn.bPants);
		uselimb.GiveMomentum(Momentum);
		// Synch up your limbs to be dissolved the same as your body
//		if(AWZombie(self) != None)
//			uselimb.SetLimbToDissolve(TimeTillDissolve);
		if(cutindex < BlowOffPawn.RIGHT_ARM)
			uselimb.ConvertToLeftArm();
		else if(cutindex < BlowOffPawn.LEFT_LEG)
			uselimb.ConvertToRightArm();
		else if(cutindex < BlowOffPawn.RIGHT_LEG)
			uselimb.ConvertToLeftLeg();
		else
			uselimb.ConvertToRightLeg();
		// Make section you cut through explode
		usec2 = BlowOffPawn.GetBoneCoords(BlowOffPawn.SeverBone[cutindex]);
		// make it spawn about halfway between the two bones
		usev = (usec.origin + usec2.origin)/2;
	}

	if(FRand() < DoBlood)
		spawn(class'LimbExplode',BlowOffPawn,,usev);

	if(FRand() < DoSound)
		// play gross sound
		BlowOffPawn.PlaySound(BlowOffPawn.CutLimbSound,,,,,GetRandPitch());

	// Now add stump to the bone that was cut on the person
	usestump = spawn(BlowOffPawn.StumpClass,BlowOffPawn,,usec2.origin);
	BlowOffPawn.Stumps.Insert(BlowOffPawn.Stumps.Length, 1);
	BlowOffPawn.Stumps[BlowOffPawn.Stumps.Length-1] = usestump;
	BlowOffPawn.AttachToBone(usestump, BlowOffPawn.SeverBone[cutindex]);
	usestump.SetupStump(BlowOffPawn.Skins[0], BlowOffPawn.AmbientGlow, BlowOffPawn.bIsFat, BlowOffPawn.bIsFemale, BlowOffPawn.bPants, BlowOffPawn.bSkirt);
	if(cutindex < BlowOffPawn.RIGHT_ARM)
		usestump.ConvertToLeftArm();
	else if(cutindex < BlowOffPawn.LEFT_LEG)
		usestump.ConvertToRightArm();
	else if(cutindex < BlowOffPawn.RIGHT_LEG)
		usestump.ConvertToLeftLeg();
	else
		usestump.ConvertToRightLeg();
	// attach blood too
	sblood= spawn(BlowOffPawn.StumpBloodClass,BlowOffPawn,,usec2.origin);
	BlowOffPawn.AttachToBone(sblood, BlowOffPawn.SeverBone[cutindex]);

	// Tell the dude if he did it
	if(AWDude(InstigatedBy) != None)
		AWDude(InstigatedBy).CutLimb(BlowOffPawn);
}

///////////////////////////////////////////////////////////////////////////////
// Tear the torso from the extremities and send it flying backwards,
// while the limbs and head fall to the ground
// Must have all your limbs to start with
// Uses given momentum instead of precalculated momentum
///////////////////////////////////////////////////////////////////////////////
function BlowOffHeadAndLimbs(P2MoCapPawn BlowOffPawn, Pawn InstigatedBy, vector momentum)
{
	local int i;
	log(self@"BlowOffHeadAndLimbs start: Pawn"@BlowOffPawn@"Instigator"@InstigatedBy@"Momentum"@Momentum);

	// Tear off head

	if (BlowOffPawn.bHasHead && BlowOffPawn.MyHead != None)
	{
		log(BlowOffPawn$".PopOffHead");
		BlowOffPawn.PopOffHead(BlowOffPawn.Location, momentum);
		BlowOffPawn.PlaySound(BlowOffPawn.BladeCleaveNeckSound,,,,,BlowOffPawn.GetRandPitch());
	}

	// Tear off all limbs
	for(i=0; i<BlowOffPawn.SeverBone.Length; i+=2)
	{
		if (BlowOffPawn.BoneArr[i] == 1)
		{
			log(BlowOffPawn$".CutThisLimb");
			CutThisLimb(BlowOffPawn, InstigatedBy, i, momentum, 0.5, 0.5);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// CheckHurtRadius is final in normal explosion
///////////////////////////////////////////////////////////////////////////////
simulated function CheckHurtRadius2( float DamageAmount, float DamageRadius,
										 class<DamageType> DamageType, float MomMag, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local vector Momentum;
	local bool bDoHurt;
	local int FinalDamage;
	local vector UseBlowOffMom;

	foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (!Victims.bHidden)
			&& (Victims != self) 
			&& (Victims.Role == ROLE_Authority) )
		{
			// If it's a player pawn (main player in single, or anyone in multi)
			// then check to have explosions blocked by 'walls'.
			if(Pawn(Victims) != None
				&& PlayerController(Pawn(Victims).Controller) != None)
			{
				// solid check
				if(FastTrace(Victims.Location, Location))
					bDoHurt=true;
				else // something in the way, so don't do hurt this time
					bDoHurt=false;
			}
			else
				bDoHurt=true;

			if(bDoHurt)
			{
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				Momentum = (damageScale * MomMag * dir);
				// Create a fake momentum vector which emphasizes being thrown into the air
				if(dir.z > 0)
					Momentum.z += (MomMag*(1- dist/DamageRadius));

				FinalDamage = damageScale * DamageAmount;

				if (P2MoCapPawn(Victims) != None)
				{
					if (FinalDamage*(1-P2MoCapPawn(Victims).ARMOR_EXPLODED_BLOCK) >= P2MoCapPawn(Victims).Health)
					{
						UseBlowOffMom = BlowOffMom + 250 * (Victims.Location - Location) + 50 * VRand();
						log(self@"BlowOffHeadAndLimbs"@Victims);
						BlowOffHeadAndLimbs(P2MoCapPawn(Victims), Instigator, UseBlowOffMom);
					}
				}

				Victims.TakeDamage
				(
					FinalDamage,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					Momentum,
					DamageType
				);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
Begin:
	PlaySound(ExplodingSound,,1.0,,,,true);
	Sleep(DelayToHurtTime);
	CheckHurtRadius2(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, ForceLocation);
	Sleep(DelayToNotifyTime);
	NotifyPawns();
}
*/
defaultproperties
{
     GrenadeExplodeAir=Sound'AW7Sounds.Big-Ass-Explosion'
     GrenadeExplodeGround=Sound'AW7Sounds.Big-Ass-Explosion'
     ExplosionDamage=500.000000
     ExplosionRadius=900.000000
     MyDamageType=Class'HolyDamage'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter25
         MaxParticles=7
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.400000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=170.000000,Max=220.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.expl1color'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.500000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         Name="SpriteEmitter25"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter25'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter26
         Acceleration=(Z=-600.000000)
         MaxParticles=20
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.darkchunks'
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Max=500.000000))
         Name="SpriteEmitter26"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter26'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter53
         UseDirectionAs=PTDU_Up
         Acceleration=(Z=-1.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=100,G=120,R=160))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=100,G=100,R=128))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=100,G=100,R=128))
         FadeOut=True
         MaxParticles=12
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-50.000000,Max=-20.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.400000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Max=200.000000),Y=(Min=200.000000,Max=400.000000))
         InitialParticlesPerSecond=3000.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
         Texture=Texture'nathans.Skins.pour2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.200000,Max=2.700000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=220.000000,Max=320.000000))
         VelocityLossRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=1.500000,Max=1.500000))
         Name="SpriteEmitter53"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter53'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter54
         Acceleration=(Z=-600.000000)
         MaxParticles=20
         RespawnDeadParticles=False
         Disabled=True
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=35.000000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodchunks1'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=500.000000))
         Name="SpriteEmitter54"
     End Object
     Emitters(3)=SpriteEmitter'SpriteEmitter54'
     TransientSoundRadius=1400.000000
    // BlowOffMom=(Z=25000)
}
