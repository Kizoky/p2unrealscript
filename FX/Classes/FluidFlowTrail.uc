//=============================================================================
// Fluid trail that moves down slopes automatically
//=============================================================================
class FluidFlowTrail extends FluidTrail;

var FluidPuddle FPuddle;
var float QuantityPerHit;
var FluidFeeder FeederOwner;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
	if(FeederOwner != None
		&& FeederOwner.FFlowTrail == self)
		FeederOwner.FFlowTrail = None;

	Super.ToggleFlow(TimeToStop, bIsOn);

	// Check to get rid of other fluids of my type, in my puddle
	if(FPuddle != None)
	{
		FPuddle.CheckToDissolve();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function HandlePuddle(float DeltaTime)
{
	// We already have a puddle
	if(FPuddle != None
		&& !FPuddle.bDeleteMe)
	{
		FPuddle.AddQuantity(QuantityPerHit*DeltaTime, SuperSpriteEmitter(Emitters[0]).LineEnd, self);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	// if we have a puddle, then feed it as long as we're flowing
	if(!bStoppedFlow)
		HandlePuddle(DeltaTime);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CheckToSpawnParticles(vector Pos)
{
	SuperSpriteEmitter(Emitters[0]).SpawnParticleLength(SuperSpriteEmitter(Emitters[0]).LineStart, 
														Pos,
														Emitters[0].StartSizeRange.X.Min);
	LastEndPoint = SuperSpriteEmitter(Emitters[0]).LineEnd;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
	local color tempcolor;
	local vector usevect, usevect2;

	tempcolor.R=255;
	Canvas.DrawColor = tempcolor;
	Canvas.Draw3DLine(Location, LastEndPoint);

	tempcolor.B=255;
	Canvas.DrawColor = tempcolor;
	usevect = Location;
	usevect.z+=UseColRadius;
	usevect2 = Location;
	usevect2.z-=UseColRadius;
	Canvas.Draw3DLine(usevect, usevect2);
	tempcolor.B=255;
	Canvas.DrawColor = tempcolor;
	usevect = Location;
	usevect.x+=UseColRadius;
	usevect2 = Location;
	usevect2.x-=UseColRadius;
	Canvas.Draw3DLine(usevect, usevect2);
}

defaultproperties
{
	UseColRadius=90;
	QuantityPerHit=8
}