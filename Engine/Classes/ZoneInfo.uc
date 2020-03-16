//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
	native
	placeable;

#exec Texture Import File=Textures\zoneinfo.bmp Name=S_ZoneInfo Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Zone properties.

var skyzoneinfo SkyZone; // Optional sky zone containing this zone's sky.
var() name ZoneTag;
// RWS CHANGE: Merged from UT2003
var() localized String LocationName; // gam

// RWS CHANGE: Merged killz from UT2003
var() float KillZ;		// any actor falling below this level gets destroyed
var() bool bSoftKillZ;	// 2000 units of grace unless land

//-----------------------------------------------------------------------------
// Zone flags.

var() const bool   bFogZone;			// Zone is fog-filled.
var()		bool   bTerrainZone;		// There is terrain in this zone.
var()		bool   bDistanceFog;		// There is distance fog in this zone.
var()		bool   bClearToFogColor;	// Clear to fog color if distance fog is enabled.

var const array<TerrainInfo> Terrains;

//-----------------------------------------------------------------------------
// Zone light.

var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;

var(ZoneLight) color DistanceFogColor;
var(ZoneLight) float DistanceFogStart;
var(ZoneLight) float DistanceFogEnd;

var(ZoneLight) const texture EnvironmentMap;
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;

// NOT USED
var/*(ZoneSound)*/ editinline I3DL2Listener ZoneEffect;

// New zonesound support
struct native ZoneSound
{
	var() const Sound Sound;					// Sound to play, if any. Specify a sound OR a song (NOT both!!)
	var() const String Song;					// Song to play, if any. Specify a sound OR a song (NOT both!!)
	var() const float Volume;					// Volume to play sound/song at
	var() const float FadeInTime;				// If >0, amount of time to fade in the sound/song when the player enters the volume/zone
	var() const float FadeOutTime;			// If >0, amount of time to fade out the sound/song when the player leaves the volume/zone
	var const transient int ID;					// ID of sound playing. Native use only
};

var(ZoneSound) const editinline array<ZoneSound> ZoneSounds;

// RWS Change 11/23/02
// True means this zone can have it's fog set dynamically to use the global or sniper fog.
var () bool bUseGlobalFog;
// RWS Change 11/23/02

//=============================================================================
// Iterator functions.

// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors( class<actor> BaseClass, out actor Actor );

simulated function LinkToSkybox()
{
	local skyzoneinfo TempSkyZone;

	// SkyZone.
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		SkyZone = TempSkyZone;
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		if( TempSkyZone.bHighDetail == Level.bHighDetailMode )
			SkyZone = TempSkyZone;
}

//=============================================================================
// Engine notification functions.

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// call overridable function to link this ZoneInfo actor to a skybox
	LinkToSkybox();
}

// When an actor enters this zone.
event ActorEntered( actor Other );

// When an actor leaves this zone.
event ActorLeaving( actor Other );

defaultproperties
{
     KillZ=-230000.0
     bStatic=True
     bNoDelete=True
     Texture=S_ZoneInfo
     AmbientSaturation=255
	 DistanceFogColor=(R=128,G=128,B=128,A=0)
	 DistanceFogStart=3000
	 DistanceFogEnd=8000
     TexUPanSpeed=+00001.000000
     TexVPanSpeed=+00001.000000
	 bUseGlobalFog=true
	DrawScale=0.25
}
