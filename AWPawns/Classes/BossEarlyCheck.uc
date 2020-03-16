///////////////////////////////////////////////////////////////////////////////
// Tells owner about touches
///////////////////////////////////////////////////////////////////////////////
class BossEarlyCheck extends Keypoint;

///////////////////////////////////////////////////////////////////////////////
// Pass hit along to owner
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	// If projectile hits area and it's the players, tell your owner about it
	if(Projectile(Other) != None
		&& AWDude(Other.Owner) != None)
	{
		AWCowBossPawn(Owner).ProjectileComing(Other);
	}
	// Tell him also if a cat is coming that way (dervish or not)
	else if(AWCatPawn(Other) != None)
		AWCowBossPawn(Owner).DervishComing(Other);
}

defaultproperties
{
     bStatic=False
     DrawScale=5.000000
     CollisionRadius=250.000000
     CollisionHeight=225.000000
     bCollideActors=True
}
