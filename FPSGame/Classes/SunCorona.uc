///////////////////////////////////////////////////////////////////////////////
// SunCorona
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Rewrite of RevStudios sunlight code
///////////////////////////////////////////////////////////////////////////////
class SunCorona extends Info
	native
	placeable
	showcategories(Movement);
	
cpptext
{
	void TickSpecial( FLOAT DeltaSeconds );
}
	
///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
struct LensFlare
{
	var() Material Texture;						// Texture of this corona
	var() float Size;							// Size of this corona
	var() float Dist;							// Distance of this corona along the "sun line" from the player to the main sun (1.0 = main sun, 0.0 = at player)
	var Actor Sun;								// Corona-drawing light actor
};

var() array<LensFlare> Coronas;					// List of sun coronas to render
var() float SunDist;							// Distance of main sun corona from player viewpoint
var() bool bActive;								// True if we should render our coronas

///////////////////////////////////////////////////////////////////////////////
// Set up our sun coronas
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	local int i;
	
	Super.PostBeginPlay();
	for (i = 0; i < Coronas.Length; i++)
	{
		Coronas[i].Sun = Spawn(class'RawActor');
		Coronas[i].Sun.bStasis = false;
		Coronas[i].Sun.Style = STY_None;
		Coronas[i].Sun.LightHue = 255;
		Coronas[i].Sun.LightSaturation = 255;
		Coronas[i].Sun.bCorona = true;
		Coronas[i].Sun.Skins[0] = Coronas[i].Texture;
		Coronas[i].Sun.SetDrawScale(Coronas[i].Size);
	}
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.Sunlight'
	bDirectional=True
	bActive=True
	DrawScale=0.25
	SunDist=2000
	
// It seems that RevSunTex causes crahes, let's see if removing it will fix it. 	
//	Coronas[0]=(Texture=Texture'GenFX.LensFlar.flare2',Size=0.5,Dist=1.0)
//	Coronas[1]=(Texture=Texture'RevSunTex.SunL1',Size=0.3,Dist=0.055556)
//	Coronas[2]=(Texture=Texture'RevSunTex.SunL2',Size=0.2,Dist=0.066667)
//	Coronas[3]=(Texture=Texture'RevSunTex.SunL3',Size=0.1,Dist=0.083333)
//	Coronas[4]=(Texture=Texture'RevSunTex.SunL4',Size=0.5,Dist=0.111112)
//	Coronas[5]=(Texture=Texture'RevSunTex.SunL5',Size=0.7,Dist=0.166667)	
}
