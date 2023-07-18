///////////////////////////////////////////////////////////////////////////////
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Postal babes in bed for the winners of CTF games.
///////////////////////////////////////////////////////////////////////////////
class CheerleadersBlue extends Cheerleaders;

defaultproperties
{
	// Change by NickP: MP fix
	// Skins(0)=Texture'Mp_Misc.Dancer_body_2_blue'
	// Skins(1)=Texture'Mp_Misc.Dancer_head_1'
	// Mesh=Mesh'MP_Strippers.MP_PostalBabe_Jeans'
	// CheerSound = Sound'AmbientSounds.phonesex'

	Mesh=SkeletalMesh'MP_Strippers.MP_PostalBabe_Thong'
	Skins(0)=Texture'Mp_Misc.Characters.Dancer_head_2'
	Skins(1)=Texture'Mp_Misc.Characters.Dancer_body_1'
	CheerSound=Sound'AmbientSounds.phoneSex'
	SoundVolume=16
	// End
}