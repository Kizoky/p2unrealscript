///////////////////////////////////////////////////////////////////////////////
// MpGary
// He's all special and stuff, because he's so freakin small! ARggh.. we
// have to do special collision detection for head shots on him. 
// We can't just shrink his collision cylinder because of crazy engine
// level code that access Pawn.ucc sizes and nothing else. So changing his
// here won't work. 
///////////////////////////////////////////////////////////////////////////////
class MpGary extends xMpPawn;

var transient float PercentOfBody;	// temp variable


const BUFFER_Z							=	1.0;

const HEAD_RATIO_OF_FULL_HEIGHT_GARY	=	0.00;
const HEAD_RATIO_GARY					=	0.05;
const TOP_HEAD_RATIO_GARY				=	0.35;
const CROUCH_EYE_HEIGHT					=   18;
const GLARE_UP_GARY						=   0;


///////////////////////////////////////////////////////////////////////////////
// Normal characters accept all damage. Gary, for instance is smaller, and
// excludes some
///////////////////////////////////////////////////////////////////////////////
function bool AcceptHit(vector HitLocation, vector Momentum)
{
	// If you're shooting high up enough on the body then get a headshot, but
	// with gary, you can also shoot down on him and would normally be hitting
	// cylinder that doesn't let you hurt him. So we must include that also and
	// make it headshots
	// Momentum.z will be 0 to -1 if he's shooting down onto gary's head.
	// Save for later use.
	momentum = Normal(momentum);
	PercentOfBody = (hitlocation.z - Location.z)/CollisionHeight;
	if(Momentum.z < 0)
		PercentOfBody += (Momentum.z/2);
	//log(self$" PercentOfBody "$PercentOfBody$" diff "$hitlocation.z - Location.z$" hitz "$hitlocation.z$" locz "$Location.z);
	if(PercentOfBody >= TOP_HEAD_RATIO_GARY)
		return false;
	else
		return true;
}

///////////////////////////////////////////////////////////////////////////////
// Check to hurt the head (I took the stupid logic of 'using the top of the collision volume'
// from Epic's code
// Check for special HEAD SHOTS
// True means whatever damage was dealt (either headshot--or even no damage from a perfect block
// dealt out by something like TakesPistolHeadShot == 0.))
///////////////////////////////////////////////////////////////////////////////
function bool HandleSpecialShots(int Damage, vector HitLocation, vector Momentum, out class<DamageType> ThisDamage,
							vector XYdir, Pawn InstigatedBy, out int returndamage, out byte HeadShot)
{
	local float ZDist, DistToMe;

	// Only let the player get special head shots
	// bullet weapons
	if(FPSPawn(InstigatedBy).bPlayer)
	{
		if(Health > 0)
		{
			if(ThisDamage == class'ShotgunDamage'
				|| ThisDamage == class'RifleDamage'
				|| ThisDamage == class'BulletDamage')
			{
				// For if no damage is done
				if(TakesShotgunHeadShot == 0.0
					|| TakesShotgunHeadShot == 0.0
					|| TakesPistolHeadShot == 0.0)
				{
					// Make a ricochet sound and puff out some smoke and sparks
					SparkHit(HitLocation, Momentum, 1);//Rand(2));
					DustHit(HitLocation, Momentum);
					returndamage = 0;
					return true;
				}

				// Check to see if we're in fake head shot range
				if(PercentOfBody > HEAD_RATIO_OF_FULL_HEIGHT_GARY)
				{
					DistToMe = VSize(XYdir);
					
					if((DistToMe < DISTANCE_TO_PUNCTURE_HEAD
							|| (P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
						&& ThisDamage == class'BulletDamage')
					// Is close enough with a pistol and behind them to puncture head with a pistol
					{
						// Check a little more accurately, if you actually hit the head or not
						// And check to make sure the guy got shot from behind, before we allow it.
						if(((Momentum dot vector(Rotation)) > 0
								&& CheckHeadForHit(HitLocation, ZDist))
							|| (P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
						{
							// We've hit the head, now reduce the damage, if necessary
							if(!(P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
								returndamage = TakesPistolHeadShot*HealthMax;
							else
								returndamage = HealthMax;
							// if this kills them, puncture the head
							if(returndamage >= Health
								&& bHeadCanComeOff
								&& !(P2GameInfo(Level.Game) != None
									&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
							{
								// record special kill
								if(P2GameInfoSingle(Level.Game) != None
									&& P2GameInfoSingle(Level.Game).TheGameState != None
									&& P2Pawn(InstigatedBy) != None
									&& P2Pawn(InstigatedBy).bPlayer)
								{
									P2GameInfoSingle(Level.Game).TheGameState.PistolHeadShot++;
								}

								if(class'P2Player'.static.BloodMode())
									PunctureHead(HitLocation, Momentum);
							}
							HeadShot = 1;
							return true;
						}
						// Over the head but not hitting the head means this guy won't take damage
						// If we had hit the head, the above would have returned already
						if(ZDist > 0) 
							return false;
					}
					else if(DistToMe < DISTANCE_TO_EXPLODE_HEAD
						&& ThisDamage == class'ShotgunDamage')
					// Is close enough with a shotgun to explode the head
					{
						// Check a little more accurately, if you actually hit the head or not
						if(CheckHeadForHit(HitLocation, ZDist))
						{
							// We've hit the head, now reduce the damage, if necessary
							if(!(P2GameInfo(Level.Game) != None
								&& P2GameInfo(Level.Game).PlayerGetsHeadShots()))
								returndamage = TakesShotgunHeadShot*HealthMax;
							else
								returndamage = HealthMax;

							// if this kills them, blow their head up
							if(returndamage >= Health
								&& bHeadCanComeOff)
							{
								// record special kill
								if(P2GameInfoSingle(Level.Game) != None
									&& P2GameInfoSingle(Level.Game).TheGameState != None
									&& P2Pawn(InstigatedBy) != None
									&& P2Pawn(InstigatedBy).bPlayer)
								{
									P2GameInfoSingle(Level.Game).TheGameState.ShotgunHeadShot++;
								}

								if(class'P2Player'.static.BloodMode())
								{
									ExplodeHead(HitLocation, Momentum);
								}
							}
							HeadShot = 1;
							return true;
						}
						// Over the head but not hitting the head means this guy won't take damage
						// If we had hit the head, the above would have returned already
						if(ZDist > 0)
							return false;
					}
					else if(ThisDamage == class'RifleDamage')
					// Sniper rifle round to the head punctures your head
					{
						// We've hit the head, now reduce the damage, if necessary
						//returndamage = TakesRifleHeadShot*HealthMax;
						returndamage = HealthMax;
						// if this kills them, puncture the head
						if(returndamage >= Health
								&& bHeadCanComeOff)
						{
							// record special kill
							if(P2GameInfoSingle(Level.Game) != None
								&& P2GameInfoSingle(Level.Game).TheGameState != None
								&& P2Pawn(InstigatedBy) != None
								&& P2Pawn(InstigatedBy).bPlayer)
							{
								P2GameInfoSingle(Level.Game).TheGameState.RifleHeadShot++;
							}

							if(class'P2Player'.static.BloodMode())
								PunctureHead(HitLocation, Momentum);
						}
						HeadShot = 1;
						return true;
					}
				}
				// continue on, if this didn't take
			}
			else if((P2GameInfo(Level.Game) != None
						&& P2GameInfo(Level.Game).PlayerGetsHeadShots())
					&& ThisDamage == class'MachinegunDamage')
				// Just for the silly head shots cheat
			{
				if(PercentOfBody > HEAD_RATIO_OF_FULL_HEIGHT_GARY)
				{
					// We've hit the head, now make it take two machine gun bullets
					// to down a guy when hit in the head.
					returndamage = 0.5*HealthMax;
					HeadShot = 1;
					return true;
				}
				// Over the head but not hitting the head means this guy won't take damage
				// If we had hit the head, the above would have returned already
				if(ZDist > 0) 
					return false;
			}
		}
	}

	// Melee
	if(ClassIsChildOf(ThisDamage, class'BludgeonDamage'))
	{
		if(CheckHeadForHit(HitLocation, ZDist, true))
		{
			// shovel's knock heads off
			if(ThisDamage == class'ShovelDamage')
			{
				// Decide randomly to knock the head off. If you're closer to
				// death, then be more likely to make the head pop off
				// Let the player take off heads, and let NPCs take off each
				// others heads
				if(bHeadCanComeOff
					&& (class'P2Player'.static.BloodMode())
					&& FRand() >= Health/HealthMax
					&& (P2Player(InstigatedBy.Controller) != None
						|| P2Player(Controller) == None))
				{
					// We've hit the head, now compound the damage, if necessary
					returndamage = TakesShovelHeadShot*HealthMax;
				}
				else
				{
					returndamage = Damage;
				}
				// If this kills them, pop off the head
				if(returndamage >= Health)
				{
					PopOffHead(HitLocation, Momentum);
					HeadShot = 1;
					PlaySound(ShovelCleaveHead,,,,,GetRandPitch());
				}
				else // Otherwise, they just get hit in the head, hard
					PlaySound(ShovelHitHead,,,,,GetRandPitch());
			}
			else if(ThisDamage == class'BatonDamage')
				// batons incapacitate people.
			{
				if(P2GameInfoSingle(Level.Game) != None
					&& P2GameInfoSingle(Level.Game).VerifySeqTime()
					&& P2Pawn(InstigatedBy) != None
					&& P2Pawn(InstigatedBy).bPlayer)
				{
					// We've hit the head, now reduce the damage, if necessary
					// use same version as shotgun explodes
					returndamage = TakesShotgunHeadShot*HealthMax;
					// if this kills them, explodes the head
					if(returndamage >= Health
							&& bHeadCanComeOff)
					{
						if(class'P2Player'.static.BloodMode())
						{
							ExplodeHead(HitLocation, Momentum);
						}
					}
					HeadShot = 1;
					return true;
				}
				else
					returndamage = Damage;
			}
			else if(ThisDamage == class'KickingDamage')
			{
				PlaySound(FootKickHead,,,,,GetRandPitch());
				// kicking to the face just draws blood
				returndamage = Damage;
			}
			else
			{
				returndamage = Damage;
			}
			return true;
		}
		else // if it was a bludgeon attack, but didn't hit the
			// face, then don't draw blood
		{
			if(ThisDamage == class'ShovelDamage')
			{
				PlaySound(ShovelHitBody,,,,,GetRandPitch());
			}
			else if(ThisDamage == class'KickingDamage')
			{
				PlaySound(FootKickBody,,,,,GetRandPitch());
			}
			// Cutting attacks always draw blood, but if not, at this point
			// we only want a dust hit, so change the damage type.
			if(!ClassIsChildOf(ThisDamage, class'CuttingDamage'))
				ThisDamage = class'BodyDamage';
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Lower the damage based on body location, closer to the center of the
// person, the closer to Damage it is
// Taking the incident angle and the angle from the hit to the center, 
// the more inline these two are, the closer the return damage is to Damage.
///////////////////////////////////////////////////////////////////////////////
function int ModifyDamageByBodyLocation( int Damage, Pawn InstigatedBy,
						  vector HitLocation, vector Momentum, 
						  out class<DamageType> ThisDamage,
						  out byte HeadShot)
{
	local int returndamage;
	local vector XYdir, MyRot;
	local float dotcheck;
	local float ZDist;

	if(Controller != None
		&& Controller.bGodMode)
		return 0;

	if(InstigatedBy == None
		|| InstigatedBy.Controller == None
		// Check to for two teams shooting each other--don't do anything if so
		|| (IsPlayerPawn()
			&& instigatedby.IsPlayerPawn()
			&& PlayerReplicationInfo.Team != None	// Make sure we're using teams
			&& PlayerReplicationInfo.Team == instigatedby.PlayerReplicationInfo.Team))
		return Damage;

	// Find the direction in the xy direction
	XYdir = HitLocation - InstigatedBy.Location;
	XYdir.z = 0;

	// Check to hurt the head (i took the stupid logic of 'using the top of the collision volume'
	// from Epic's code
	// Check for special HEAD SHOTS
	if(HandleSpecialShots(Damage, HitLocation, Momentum, ThisDamage, 
				XYdir, InstigatedBy, returndamage, HeadShot))
	{
		return returndamage;
	}

	if(ClassIsChildOf(ThisDamage, class'BulletDamage'))
	{
		// Test first for no machinegun damage
		if(ThisDamage == class'MachinegunDamage')
		{
			if(TakesMachinegunDamage == 0)
			{
				// Make a ricochet sound and puff out some smoke and sparks
				SparkHit(HitLocation, Momentum, 1);//Rand(2));
				DustHit(HitLocation, Momentum);
				returndamage = 0;
				return returndamage;
			}
			else
				Damage = TakesMachinegunDamage*Damage;
		}

		// Multiply damage from dude by a certain factor
		Damage = FPSPawn(InstigatedBy).DamageMult*Damage;

		//log(self$" check head shots "$Level.Game$" percent of body "$PercentOfBody$" greater than "$HEAD_RATIO_GARY);
		// If you shoot the head in MP, make it take off more damage. Don't do
		// any centering checks on the head.. any shot will do
		if((Level.Game == None
				|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
			&& IsMPHeadshot(hitlocation))
		{
			returndamage = P2Pawn(InstigatedBy).GetHeadShotDamageMP(ThisDamage, Damage);
			//returndamage = HEAD_SHOT_DAMAGE_MP*Damage;
			bReceivedHeadShot=true;
		}
		else // Make the shot take off more damage if it's closer to his center (but
			// not a head shot).
		{
			// Make the momentum be the vector from the hit point, to the pawn's center point. 
			Momentum = HitLocation - Location;
			Momentum.z = 0;
			Momentum = Normal(Momentum);

			// Now compare how inline with the hit vector is (the momentum) to the vector from the attacker
			// to the attacked. The more inline, the more damage done. 
			XYdir = Normal(XYdir);
			dotcheck = XYdir dot Momentum;

			returndamage = Damage*abs(dotcheck);
			//log(self$" second-- vect to target "$xydir$" hitpoint to center "$momentum$" dot "$dotcheck$" new damage "$returndamage);
		}


		// Check to ensure the damage takes at least one PERCENT off your health
		if(returndamage < OneUnitInHealth)
			returndamage = OneUnitInHealth;

		return returndamage;
	}
	// Reduce Shocker damage as necessary
	else if(ThisDamage == class'ElectricalDamage')
	{
		returndamage = Damage;
		if(TakesShockerDamage == 0.0)
		{
			returndamage = 0;
		}

		return returndamage;
	}
	// modify how much fire hurts us
	else if(ClassIsChildOf(ThisDamage, class'BurnedDamage')
		|| ClassIsChildOf(ThisDamage, class'OnFireDamage'))
	{
		returndamage = Damage*TakesOnFireDamage;
		return returndamage;
	}

	return Damage;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event StartCrouch(float HeightAdjust)
{
	If(!bUpdateEyeHeight)
		EyeHeight -= HeightAdjust;
	OldZ -= HeightAdjust;
	BaseEyeHeight = CROUCH_EYE_HEIGHT;
}

///////////////////////////////////////////////////////////////////////////////
// Make some glare from my sniper rifle
/////////////////////////////////////////////////////////////////////////////// 
//simulated 
function MakeSniperGlare()
{
	local vector useloc;

	useloc = Location;
	useloc += GLARE_FORWARD*vector(Rotation);
	useloc.z += GLARE_UP_GARY;
	// try to attach it to the weapon in third person because in MP nothing
	// sticks to anything very well
	spawn(class'RifleScopeGlare',Weapon.ThirdPersonActor,,useloc);
}

defaultproperties
	{
	Mesh=Mesh'MP_Gary_Characters.Mini_M_Jacket_Pants'
	CoreSPMesh=Mesh'Gary_Characters.Mini_M_Jacket_Pants'
	Skins[0]=Texture'ChameleonSkins.Special.Gary'
	HeadSkin=Texture'ChamelHeadSkins.Special.Gary'
	HeadMesh=Mesh'Heads.Gary'

	HandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_gary'
	FootTexture =Texture'ChameleonSkins.Special.Gary'

	CoreMPMeshAnim=MeshAnimation'MP_Gary_Characters.anim_GaryMP'

    //Begin Object Class=KarmaParamsSkel Name=GarySkel
	//	KSkeleton="Avg_Mini_Skel"
	//	KFriction=0.5
	//    KStartEnabled=False
    //    Name="GarySkel"
    //End Object
    //KParams=KarmaParamsSkel'GarySkel'
	CharacterType=CHARACTER_Mini

	DialogClass=class'BasePeople.DialogGary'
	DudeSuicideSound = Sound'GaryDialog.gary_makesuremyass'

	Menuname="Gary Coleman"

	BaseEyeHeight=+00025.000000
    EyeHeight=+00025.000000
	}
