///////////////////////////////////////////////////////////////////////////////
// MonsterBitchEarlyCheck
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Because of the Bitch's weird collision, this might not get all projectiles
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchEarlyCheck extends BossEarlyCheck;

var array<Actor> DelayedHitActor;

// Hack to get projectiles to hit the Bitch
event Timer()
{
	local int i;
	
	if (DelayedHitActor.Length > 0)
	{
		for (i = 0; i < DelayedHitActor.Length; i++)
			if (DelayedHitActor[i] != None && !DelayedHitActor[i].bDeleteMe)
			{
				//log("Delayed"@DelayedHitActor[i]@"touching"@Owner);
				Owner.Touch(DelayedHitActor[i]);
				DelayedHitActor[i].Touch(Owner);
			}
		DelayedHitActor.Length = 0;
	}	
}

///////////////////////////////////////////////////////////////////////////////
// Pass hit along to owner
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	if (Owner == None || Pawn(Owner) == None || Pawn(Owner).Controller == None)
		return;
		
	//log(self@"TOUCH"@Other);
		
	// If projectile hits area and it's the players, tell your owner about it
	if ((MonsterBitch(Owner) == None || MonsterBitch(Owner).GreatEye == None || MonsterBitch(Owner).GreatEye.bDeleteMe)
		&& (Other.Class == MonsterBitchController(Pawn(Owner).Controller).Spit_Rock_Class || Other.Class == MonsterBitchController(Pawn(Owner).Controller).Spit_Car_Class))
	{
		//log("Added delayed hit actor");
		DelayedHitActor.Insert(0,1);
		DelayedHitActor[0] = Other;
		if (DelayedHitActor.Length >= 1)
			SetTimer(0.1, false);
	}
	else if(Projectile(Other) != None
		&& Pawn(Other.Owner).Controller != None
		&& PlayerController(Pawn(Other.Owner).Controller) != None)
	{
		MonsterBitch(Owner).ProjectileComing(Other);
	}
	// Tell him also if a cat is coming that way (dervish or not)
	else if(AWCatPawn(Other) != None)
		MonsterBitch(Owner).DervishComing(Other);
	//Owner.Touch(Other);
}

defaultproperties
{
	CollisionRadius=800
	CollisionHeight=1224
}
