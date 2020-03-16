///////////////////////////////////////////////////////////////////////////////
// VomitSplat
// what vomit projectiles leave on the ground after they hit
///////////////////////////////////////////////////////////////////////////////
class BoneSplat extends Splat;

const SPLAT_NUM	=	5;
var() Texture TexSprites[SPLAT_NUM];
var float sizerange;
var float sizestart;

simulated function BeginPlay()
{
	local int usecount;
	local float usescale;

	Super.BeginPlay();

	// pick a random texture from the four as one to display
	usecount = Rand(ArrayCount(TexSprites));
	ProjTexture = TexSprites[usecount];

	// Randomly pick size
	// Can only do this in single player since SetDrawScale can't be called on
	// the client
	if(Level.Game != None
		&& Level.Game.bIsSinglePlayer)
	{
		usescale = (sizerange*FRand() + sizestart);
		SetDrawScale(usescale);
	}
}

defaultproperties
{
     TexSprites(0)=FinalBlend'nathans.Skins.bloodsplatblend1'
     TexSprites(1)=FinalBlend'nathans.Skins.bloodsplatblend2'
     TexSprites(2)=FinalBlend'nathans.Skins.bloodsplatblend3'
     TexSprites(3)=FinalBlend'nathans.Skins.bloodsplatblend5'
     TexSprites(4)=FinalBlend'nathans.Skins.bloodsplatblend6'
     sizerange=0.250000
     sizestart=0.200000
     Lifetime=7.000000
     ProjTexture=FinalBlend'nathans.Skins.bloodsplatblend1'
     DrawScale=0.500000
}
