///////////////////////////////////////////////////////////////////////////////
// SuperChamp
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Invincible version of Champ that follows the player around and protects him
///////////////////////////////////////////////////////////////////////////////
class SuperChamp extends DogPawn;

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
// SuperChamp visibly takes hits and sometimes gets hurt but never
// takes any real damage and cannot be killed
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;
	local int returnDamage;
	local vector OrigMomentum;
	local byte HeadShot;
	local LambController lambc;
	local int OldDamage;

	lambc = LambController(Controller);

	// Wake them from stasis now that we've been hit
	if(Controller.bStasis)
		lambc.ComeOutOfStasis(false);

	// Don't call at all if you didn't get hurt
	if(Damage <= 0)
		return;

	// If I'm already on fire, don't take any more damage from fire
	if(MyBodyFire != None
		&& ClassIsChildOf(damageType, class'BurnedDamage'))
		return;

	// Used for debugging.
	if(NO_ONE_DIES != 0)
		return;

	DamageInstigator = instigatedBy;
	// Modify the damage based on our attribute
	OldDamage = Damage;
	Damage = TakeDamageModifier*Damage;
	// Make sure if it's supposed to cause damage, it causes at least a little
	if(OldDamage > 0
		&& Damage <=0)
		Damage = 1;
	// Calc the damage based on the body location for the hit
	Damage = ModifyDamageByBodyLocation(Damage, InstigatedBy, HitLocation, momentum, DamageType, HeadShot);

	// Save the momentum because for some reason it has to be squished and saved.
	OrigMomentum = momentum;

	//////////
	// The following is mostly the original TakeDamage from Engine.Pawn but I had to change
	// a few idiotic things like the momentum getting randomly modified.
	//////////
	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	// Don't make things shoot you up into the air unless it's specific damage types
	if(class<P2Damage>(damageType) == None
			|| !class<P2Damage>(damageType).default.bAllowZThrow)
	{
		if(Physics == PHYS_Walking)
			momentum.z=0;
	}

	// he needs to catch on fire because this was a real fire (not just a match)
	if(ClassIsChildOf(damageType, class'BurnedDamage'))
	{
		if(lambc != None)
			lambc.CatchOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));
		else
			SetOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));
	}

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	// Don't actually take any damage
	//Health -= actualDamage;
	
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( bAlreadyDead )
	{
		// Added in level thing here because Warn is particular to the engine i think.
		Level.Warn(self$" took regular damage "$damagetype$" from "$instigatedby$" while already dead at "$Level.TimeSeconds);
		ChunkUp(-1 * Health);
		return;
	}

	// Send the real momentum to this function, please
	PlayHit(actualDamage, hitLocation, damageType, OrigMomentum);
	if ( Health <= 0 )
	{
		// If fire has killed me,
		// or we're on fire and we died,
		// then swap to my burn victim mesh
		if(damageType == class'OnFireDamage'
			|| ClassIsChildOf(damageType, class'BurnedDamage')
			|| MyBodyFire != None)
			SwapToBurnVictim();

		// Check to chunk if we're killed by a certain thing or group
		TryToChunk(Instigator, DamageType);

		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.Controller; //FIXME what if killer died before killing you
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = momentum;
		Died(Killer, damageType, HitLocation);		
	}
	else
	{
		AddVelocity( momentum ); 
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}

	MakeNoise(1.0); 

	// Don't get infected by chem damage, it never goes away and can be a pain for the dude to deal with
	
	/*
	// If you're infected, be infected even in death
	if(damageType == class'ChemDamage')
	{
		SetInfected(FPSPawn(instigatedBy));
		return;
	}
	*/

	// If I'm on fire and it's the fire on me, that's hurting me, then
	// darken me, based on how much life I have left
	if(damageType == class'OnFireDamage')
	{
		AmbientGlow = (Health*default.AmbientGlow)/HealthMax; // because 255 is insane pulsing
	}
	
	/*
	// This animal needs to shake a lot from getting electricuted.
	if(damageType == class'ElectricalDamage'
		&& LambController(Controller) != None)
	{
		LambController(Controller).GetShocked(P2Pawn(instigatedBy), HitLocation);
		return;
	}
	*/
	
	// Kamek 4-23
	// If the dude kicks us, record it and give them an achievement.
	if (ClassIsChildOf(DamageType, class'KickingDamage') && PlayerController(InstigatedBy.Controller) != None && !bKickedByPlayer && Controller.IsA('DogController'))
	{
		bKickedByPlayer = true;	// Record it so they don't get points for kicking us again
		if( Level.NetMode != NM_DedicatedServer ) 	PlayerController(InstigatedBy.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InstigatedBy.Controller),'DogsKicked',1,true);
	}
}

defaultproperties
{
	Skins[0]=Texture'AnimalSkins.Dog'
	ControllerClass=class'SuperChampController'
	HealthMax=9999
	GroundSpeed=650
	CatchProjFreq=0.900000
	bNoDismemberment=true
	HeroTag="AWPostalDude"
}