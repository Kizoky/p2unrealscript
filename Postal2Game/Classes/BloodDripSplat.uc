///////////////////////////////////////////////////////////////////////////////
// BloodDripSplat.
// Blood that drips out and splats on the ground (smaller)
///////////////////////////////////////////////////////////////////////////////
class BloodDripSplat extends Splat;

var() Texture BloodSprites[2];

const SIZE_RANGE	=	0.4;
const SIZE_START	=	0.2;

simulated function BeginPlay()
{
	local int usecount;
	local float usescale;

	Super.BeginPlay();

	// pick a random texture from the four as one to display
	usecount = (FRand()*2);
	ProjTexture = BloodSprites[usecount];

	// pick random size
	// Can only do this in single player since SetDrawScale can't be called on
	// the client
	if(Level.Game != None
		&& Level.Game.bIsSinglePlayer)
	{
		usescale = (SIZE_RANGE*FRand() + SIZE_START);
		SetDrawScale(usescale);
	}
}

defaultproperties
{
    BloodSprites(0)=FinalBlend'nathans.Skins.blooddripblend1'
    BloodSprites(1)=FinalBlend'nathans.Skins.blooddripblend2'
	ProjTexture=nathans.Skins.blooddripblend1
	Lifetime=5.0
	DrawScale=0.3
}