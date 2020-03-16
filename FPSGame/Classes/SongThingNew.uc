///////////////////////////////////////////////////////////////////////////////
// SongThingNew
// Copyright 2014, Running With Scissors, Inc.
//
// So, an attempt was made to fix the broken behavior of SongThings to not
// properly be occluded by BSP, static meshes, etc. We needed music to be
// localized to a particular building in PL, but it would play out in the
// streets too. Unfortunately after making the necessary changes in the
// engine code, it turned out that all of the original P2 SongThings were
// broken by this change. So, by default, all SongThings will use the old
// "broken" behavior, and this actor will use the new, "fixed" behavior.
///////////////////////////////////////////////////////////////////////////////
class SongThingNew extends SongThing;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bLegacy=false
}
