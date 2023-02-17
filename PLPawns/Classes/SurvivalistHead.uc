///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class SurvivalistHead extends Head;

///////////////////////////////////////////////////////////////////////////////
// STUB all animations
///////////////////////////////////////////////////////////////////////////////
function PlayAnimDead();
function SetupAnims();
simulated function PlayLookLeft(float fRate, float BlendFactor);
simulated function PlayLookRight(float fRate, float BlendFactor);
simulated function PlayLookDown(float fRate, float BlendFactor);
simulated function PlayLookUp(float fRate, float BlendFactor);
function SetMood(EMood moodNew, float amount);
function Talk(float fDuration);
function SetChant(bool bNewChant);
function Yell(float fDuration);
function DisgustedSpitting(float fDuration);

///////////////////////////////////////////////////////////////////////////////
// Switch to a burned texture
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	if(class'P2Player'.static.BloodMode())
	{
		Skins[0] = BurnVictimHeadSkin;
		Skins[1] = BurnVictimHeadSkin;
	}
}
