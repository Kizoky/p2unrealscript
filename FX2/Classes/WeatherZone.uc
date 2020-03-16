///////////////////////////////////////////////////////////////////////////////
// WeatherZone
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// ZoneInfo that spawns a WeatherEffect when the dude enters, and despawns
// when he leaves.
///////////////////////////////////////////////////////////////////////////////
class WeatherZone extends ZoneInfo;

// STUBBED DEPRECATED CLASS, DO NOT USE
event PostBeginPlay()
{
	warn(self@"IS A DEPRECATED CLASS, DO NOT USE");
	assert(false);
}


///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
/*var(Weather) class<WeatherEffect> Weather;	// Class of Weather Effect to spawn
var(Weather) vector ViewOffset;				// Z value to offset from player viewpoint

var WeatherEffect MyWeather;*/

///////////////////////////////////////////////////////////////////////////////
// When an actor enters this zone.
///////////////////////////////////////////////////////////////////////////////
/*event ActorEntered( actor Other )
{
	if (Pawn(Other) != None
		&& Pawn(Other).Controller != None
		&& PlayerController(Pawn(Other).Controller) != None
		&& MyWeather == None)
	{
		MyWeather = spawn(Weather,,,Other.Location);
		if (MyWeather != None)
			MyWeather.ViewOffset = ViewOffset;
	}
}*/

///////////////////////////////////////////////////////////////////////////////
// When an actor leaves this zone.
///////////////////////////////////////////////////////////////////////////////
/*event ActorLeaving( actor Other )
{
	if (Pawn(Other) != None
		&& Pawn(Other).Controller != None
		&& PlayerController(Pawn(Other).Controller) != None
		&& MyWeather != None)
	{
		MyWeather.Destroy();
		MyWeather = None;
	}
}*/

///////////////////////////////////////////////////////////////////////////////
// Set default offset to high in the sky, so it rains down on the player
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
//	Weather=class'RainEffect'
//	ViewOffset=(Z=2000)
}
