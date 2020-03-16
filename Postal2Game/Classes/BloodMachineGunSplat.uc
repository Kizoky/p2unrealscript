///////////////////////////////////////////////////////////////////////////////
// BloodMachineGunSplat.
// Blood shoots out of a guy, onto a surface, from a machine gun hit
///////////////////////////////////////////////////////////////////////////////
class BloodMachineGunSplat extends Splat;

const SPLAT_NUM	=	5;
var() Texture BloodSprites[SPLAT_NUM];
var float sizerange;
var float sizestart;

simulated function BeginPlay()
{
	local int usecount;
	local float usescale;

	Super.BeginPlay();

	// pick a random texture from the four as one to display
	usecount = Rand(ArrayCount(BloodSprites));
	ProjTexture = BloodSprites[usecount];

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
    BloodSprites(0)=FinalBlend'nathans.Skins.bloodsplatblend1'
    BloodSprites(1)=FinalBlend'nathans.Skins.bloodsplatblend2'
    BloodSprites(2)=FinalBlend'nathans.Skins.bloodsplatblend3'
    BloodSprites(3)=FinalBlend'nathans.Skins.bloodsplatblend5'
    BloodSprites(4)=FinalBlend'nathans.Skins.bloodsplatblend6'
	ProjTexture=nathans.Skins.bloodsplatblend1
	Lifetime=7.0
	sizerange=0.25
	sizestart=0.2
	DrawScale=0.4
}