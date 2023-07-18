///////////////////////////////////////////////////////////////////////////////
// CatGrenadePawn for xPatch 3.0
// by Man Chrzan
// 
// Same as CatPawn but it has a grenade stuck in it's ass, yeah.
//
///////////////////////////////////////////////////////////////////////////////
class CatGrenadePawn extends CatPawn
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var xCatGrenadeProjectile Grenade;

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	AddGrenade(0.9);
}

///////////////////////////////////////////////////////////////////////////////
// We can now insert a grenade into cat's ass, SICK!
///////////////////////////////////////////////////////////////////////////////
function AddGrenade(float GScale, optional Class<xCatGrenadeProjectile> MyGrenadeClass)
{
	if(MyGrenadeClass != None && Grenade != None)
	{
		Grenade.Destroy();
		Grenade = None;
	}
	
	if( Grenade == None)
	{
		if(MyGrenadeClass != None)
			Grenade = spawn(MyGrenadeClass,self);
		else
			Grenade = spawn(class'xCatGrenadeProjectile',self);
	}
	if( Grenade != None )
	{
		Grenade.SetCollision(false,false,false);
		Grenade.SetDrawScale(GScale);
		Grenade.SetPhysics(PHYS_None);
		AttachToBone(Grenade, BONE_PELVIS);
		Grenade.SetRelativeRotation(rot(16384,0,0));
		Grenade.SetRelativeLocation(vect(0,-2,0));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);	
	
	// Don't call at all if you didn't get hurt
	if(Damage < Health * 0.5)
		return;
	
	// xPatch: we have grenade inside, explode it
	if(Grenade != None)
		Grenade.ExplodeCat();
}


defaultproperties
{
     ControllerClass=Class'CatGrenadeController'
}
