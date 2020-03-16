///////////////////////////////////////////////////////////////////////////////
// Everything feeder has, except this supports a long collision line
// through which the fluid may move. It's the fake arc we make for collision
///////////////////////////////////////////////////////////////////////////////
class FluidPosFeeder extends FluidFeeder;

// fake arc
var array<vector> ArcPos;		// These are dynamic and allocated at postbeginplay
var array<vector> ArcVel;		// so each stream can have the fewest necessary to save
								// processor time.
var int ArcMax;					// Number of segments. Each one more is very expensive.
								// Make this as low as possible. Things like the player's
								// urine is high to give him lots of range, while things
								// like a neck blood spout is small
// MAKE SURE that any feeder that is for the player's urine, uses all the same number. So
// urine, bloodyurine, and gonorrhea for starters. (8 is the current default. Update as necessary)

var int LastArcIndex;
var vector CollisionVelocity;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function InitFlow()
{
	local int i;

	Super.InitFlow();

	// Destroy old
	if(ArcPos.Length > 0)
		ArcPos.Remove(0, ArcPos.Length);
	if(ArcVel.Length > 0)
		ArcVel.Remove(0, ArcVel.Length);

	// Allocate anew
	ArcPos.Insert(0,ArcMax);
	ArcVel.Insert(0,ArcMax);
	// Prep
	for(i=0; i<ArcPos.Length; i++)
	{
		ArcPos[i] = Location;
	}
	//log(self$" ARCMAX "$ArcMax$" length "$ArcPos.Length);
}

///////////////////////////////////////////////////////////////////////////////
// Check for collisions and move particles
///////////////////////////////////////////////////////////////////////////////
simulated function Tick(float DeltaTime)
{
	local vector vel;
	local int i, k, j;
	local bool tracehit;
//	local vector HitLocation, HitNormal;

	if(Level.NetMode != NM_Client)
	{
		// remove quantity if it's been used
		if(!bInfiniteQuantity
			&& Quantity > 0)
		{
			Quantity -= QuantityPerHit*DeltaTime;
			if(Quantity < 0)
			{
				ToggleFlow(0, false);
			}
		}

		// Advance time
		EmitTime+=DeltaTime;
	//	vel = 
	//	vel = vector(StartRotation + rotator(MyOwner.Velocity))
		while(EmitTime > SpawnDripTime)
		{
			LastArcIndex--;
			if(LastArcIndex < 0)
				LastArcIndex = ArcPos.Length-1;
			ArcPos[LastArcIndex] = CollisionStart;
			ArcVel[LastArcIndex] = CollisionVelocity;
			EmitTime-=SpawnDripTime;
		}

		for(i=0; i<ArcPos.Length; i++)
		{
			ArcVel[i]+=(DeltaTime*Emitters[0].Acceleration);
			ArcPos[i]+=(DeltaTime*(ArcVel[i]));// + FliudOwner.Velocity));
		}

		// perform collisions
		j=LastArcIndex;
		if(FSplash != None)
			FSplash.TurnOffSplash();

		// check section between spout and owner first
		if(!FeederTrace(CollisionStart, ArcPos[j], CollisionVelocity, DeltaTime, j))
		{
			//log(self$" checked at "$-1$" from "$CollisionStart$" to "$ArcPos[j]);
			for(i=0; i<ArcPos.Length-1; i++)
			{
				k=j+1;
				if(k==ArcPos.Length)
					k=0;
				//log(self$" checking at "$j$" from "$ArcPos[j]$" to "$ArcPos[k]);
				if(FeederTrace(ArcPos[j], ArcPos[k], ArcVel[j], DeltaTime, j))
				{
					//log(self$" hit something at "$LastHitPos);
					tracehit = true;
					break;
				}
				j=k;
			}
		}
		else
		{
			LastHitPos = ArcPos[j];
			//log(self$" hitting first off at "$-1$" from "$CollisionStart$" to "$ArcPos[j]);
			//hit hte ground but not making any effects
		}

		if(tracehit == false)
			LastHitPos = ArcPos[k];
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
	local color tempcolor;
	local vector usevect, usevect2;
	local int i;

	tempcolor.R=255;
	tempcolor.G=255;
	//Canvas.DrawColor = tempcolor;
	//Canvas.Draw3DLine(CollisionStart, LastEndPoint);

	tempcolor.B=255;
	for(i=0; i<ArcPos.Length-1; i++)
	{
		Canvas.DrawColor = tempcolor;
		usevect = ArcPos[i];
		usevect2 = ArcPos[i+1];
		Canvas.Draw3DLine(usevect, usevect2);
	}
}

defaultproperties
{
	ArcMax=8
}
