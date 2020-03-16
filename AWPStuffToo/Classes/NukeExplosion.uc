///////////////////////////////////////////////////////////////////////////////
// RocketExpl
//
// explosion for a rocket
///////////////////////////////////////////////////////////////////////////////
class NukeExplosion extends RocketExplosion;
/*
var vector BlowOffMom;

///////////////////////////////////////////////////////////////////////////////
// Given this index, cut off that limb
// Assumes it's there to cut
// Uses given momentum instead of pre-calculated momentum
///////////////////////////////////////////////////////////////////////////////
function CutThisLimb(AWPerson BlowOffPawn, Pawn instigatedBy, int cutindex, vector momentum, float DoSound,
				 float DoBlood)
{
	local coords usec, usec2;
	local Limb uselimb;
	local rotator LimbRot;
	local Stump usestump;
	local P2Emitter sblood;
	local vector hitlocation, usev;
	local Vector UseMom;

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
function BlowOffHeadAndLimbs(AWPerson BlowOffPawn, Pawn InstigatedBy, vector momentum)
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

				if (AWPerson(Victims) != None)
				{
					if (FinalDamage*(1-AWPerson(Victims).ARMOR_EXPLODED_BLOCK) >= AWPerson(Victims).Health)
					{
						UseBlowOffMom = BlowOffMom + 250 * (Victims.Location - Location) + 50 * VRand();
						BlowOffHeadAndLimbs(AWPerson(Victims), Instigator, UseBlowOffMom);
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
     ExplodingSound=Sound'AW7Sounds.Nuke'
     ExplosionMag=200000.000000
     ExplosionDamage=360.000000
     ExplosionRadius=1500.000000
     MyDamageType=Class'NukeDamage'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter27
         MaxParticles=150
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-900.000000,Max=20000.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=1000.000000,Max=1000.000000))
         InitialParticlesPerSecond=5000.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.expl1color'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=10.500000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=100.000000,Max=2000.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         Name="SpriteEmitter27"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter27'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter28
         UseDirectionAs=PTDU_Up
         FadeOutStartTime=0.500000
         FadeOut=True
         FadeInEndTime=0.500000
         FadeIn=True
         MaxParticles=20
         RespawnDeadParticles=False
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=100.000000,Max=300.000000)
         StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=200.000000
         AutomaticInitialSpawning=False
         Texture=Texture'nathans.Skins.softwhitedot'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRadialRange=(Min=900.000000,Max=1000.000000)
         VelocityLossRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=1.500000,Max=1.500000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         Name="SpriteEmitter28"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter28'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter29
         Acceleration=(Z=-600.000000)
         MaxParticles=25
         RespawnDeadParticles=False
         Disabled=True
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
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
         Name="SpriteEmitter29"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter29'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter30
         MaxParticles=150
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-45000.000000,Max=45000.000000),Y=(Min=-45000.000000,Max=45000.000000),Z=(Min=50000.000000,Max=65000.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5500.000000,Max=20000.000000))
         InitialParticlesPerSecond=1000.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.expl1color'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=8.000000
         LifetimeRange=(Min=8.000000,Max=12.500000)
         StartVelocityRange=(X=(Min=-100.000000,Max=500.000000),Y=(Min=-100.000000,Max=500.000000),Z=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=5.000000,Max=8.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         Name="SpriteEmitter30"
     End Object
     Emitters(3)=SpriteEmitter'SpriteEmitter30'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter31
         Acceleration=(Z=-600.000000)
         UseCollision=True
         DampingFactorRange=(X=(Min=0.500000,Max=0.900000),Y=(Min=0.500000,Max=0.900000),Z=(Min=0.500000,Max=0.900000))
         MaxParticles=600
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=90.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=10.000000)
         StartSizeRange=(X=(Min=0.500000,Max=70.000000))
         InitialParticlesPerSecond=300.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.darkchunks'
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.750000,Max=6.000000)
         StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Max=8000.000000))
         Name="SpriteEmitter31"
     End Object
     Emitters(4)=SpriteEmitter'SpriteEmitter31'
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter16
         LocationShapeExtend=PTLSE_Circle
         Acceleration=(Z=60.000000)
         ColorScale(1)=(Color=(B=180,G=240,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(G=41,R=137))
         FadeOut=True
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=20000.000000))
         SphereRadiusRange=(Max=200.000000)
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.030000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=1500.000000,Max=2000.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
//         Texture=Texture'nathans.Skins.firegroup4'
		Texture=Texture'nathans.Skins.Fireball1'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Max=13.000000)
         StartVelocityRange=(Z=(Min=150.000000,Max=200.000000))
         StartVelocityRadialRange=(Min=-150.000000,Max=-150.000000)
         VelocityLossRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.100000,Max=0.200000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         Name="SuperSpriteEmitter16"
     End Object
     Emitters(5)=SuperSpriteEmitter'SuperSpriteEmitter16'
     bAlwaysRelevant=True
     LifeSpan=12.000000
    // BlowOffMom=(Z=250000)
}
