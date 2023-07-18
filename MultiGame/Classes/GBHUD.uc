///////////////////////////////////////////////////////////////////////////////
// MpHUD.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Adds multiplayer elements to our singleplayer HUD.
//
///////////////////////////////////////////////////////////////////////////////
class GBHUD extends MpHUD
	config;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var Texture RadarStar;			// Starfish for grab bag radar


///////////////////////////////////////////////////////////////////////////////
// Draw bags for gb game
///////////////////////////////////////////////////////////////////////////////
simulated function DrawRadarBags(canvas Canvas, float radarx, float radary)
{
	local float dist;
	local float pheight, iconsize, fishx, fishy;
	local vector radarb;
	local vector dir;
	local MPPlayer mpp;
	local int i;

	mpp = MpPlayer(OurPlayer);

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = YellowColor;
	// Show bags on radar
	for(i = 0; i<mpp.FlavinSpots.Length; i++)
	{
		// convert 3d world coords to around the player in the radar coords
		radarb = mpp.FlavinSpots[i];
		dir = radarb - PawnOwner.Location;
		pheight = dir.z;
		
		CalcRadarDists(true, dir, dist);

		// if the flag is outside the radius, draw it at the max--special
		// for bags
		if(dist > MP_RADAR_RADIUS)
			dist = MP_RADAR_RADIUS;
		// If you're within the appropriate radius from the player, be drawn
		RadarFindFishLoc(dist, Scale, pheight, true, dir, fishx, fishy, iconsize);
		Canvas.SetPos(radarx + fishx, radary + fishy);

		// Draw the fish/bag
		Canvas.DrawIcon(RadarStar, iconsize);

	}
	Canvas.DrawColor = RedColor;
	// Show pawns carrying bags on radar--it's okay
	// that pawns/fish get drawn twice. This comes second and it's small and few
	// enough to not be a big processor hit.
	for(i = 0; i<mpp.FlavinPawns.Length; i++)
	{
		// Don't show ourselves on our own map
		if(PawnOwner != mpp.FlavinPawns[i])
		{
			// convert 3d world coords to around the player in the radar coords
			radarb = mpp.FlavinPawns[i].Location;
			dir = radarb - PawnOwner.Location;
			pheight = dir.z;
			
			CalcRadarDists(true, dir, dist);

			// Make sure to always show pawns with flavin, so cap their radius
			// like the bags if they're out too far
			if(dist > MP_RADAR_RADIUS)
				dist = MP_RADAR_RADIUS;

			RadarFindFishLoc(dist, Scale, pheight, true, dir, fishx, fishy, iconsize);
			Canvas.SetPos(radarx + fishx, radary + fishy);

			// Draw the fish/pawn
			Canvas.DrawIcon(RadarNPC, iconsize);
		}
	}
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = WhiteColor;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	RadarStar=Texture'MpHUD.Radar.StarFish'
}
