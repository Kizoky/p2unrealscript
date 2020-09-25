class WeaponAttachment extends InventoryAttachment
	native
	nativereplication;

var		byte	FlashCount;			// when incremented, draw muzzle flash for current frame
var		bool	bAutoFire;			// When set to true.. begin auto fire sequence (used to play looping anims)
var		name	FiringMode;			// replicated to identify what type of firing/reload animations to play
var		float	FiringSpeed;		// used by human animations to determine the appropriate speed to play firing animations

// FIXME - should firingmode be compressed to byte?

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
		FlashCount, FiringMode, bAutoFire;
}

/* 
ThirdPersonEffects called by Pawn's C++ tick if FlashCount incremented
becomes true
OR called locally for local player
*/
simulated event ThirdPersonEffects()
{
	// spawn 3rd person effects

	// have pawn play firing anim
	if ( Instigator != None )
		Instigator.PlayFiring(1.0,FiringMode);
}

defaultproperties
{
	bReplicateInstigator=true
	FiringSpeed=+1.0

	// Change by NickP: fix
	CullDistance=0
	// End
}
