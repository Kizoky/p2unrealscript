///////////////////////////////////////////////////////////////////////////////
// PLGameMod
// Copyright 2015, Running With Scissors, Inc.
//
// Base game mod for PL that handles PL specific things.
///////////////////////////////////////////////////////////////////////////////
class PLGameMod extends P2GameMod;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
{
	local PLZombieController Z;
	local ColeMen C;
	local PLFanatics F;
	local PLKumquat K;
	local PLPostalBabe B;
	local PLRWSFollower R;
	local PLRWSStaff S;
	
	foreach DynamicActors(class'PLZombieController', Z)
		Z.GameInfoIsNowValid();

	foreach DynamicActors(class'ColeMen', C)
		C.GameInfoIsNowValid();

	foreach DynamicActors(class'PLFanatics', F)
		F.GameInfoIsNowValid();

	foreach DynamicActors(class'PLKumquat', K)
		K.GameInfoIsNowValid();

	foreach DynamicActors(class'PLPostalBabe', B)
		B.GameInfoIsNowValid();

	foreach DynamicActors(class'PLRWSFollower', R)
		R.GameInfoIsNowValid();

	foreach DynamicActors(class'PLRWSStaff', S)
		S.GameInfoIsNowValid();

	Super.GameInfoIsNowValid();
}


///////////////////////////////////////////////////////////////////////////////
// Default properties required by all P2GameMods.
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
}