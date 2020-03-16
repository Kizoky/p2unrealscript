//=============================================================================
// Fluid splash for a stream of fluid pouring on a surface
//=============================================================================
class FluidSplashEmitter extends Fluid;

const VEL_MAX		=   100;
const MIN_SIZE		=	0.01;

function EnableSpawnAll(bool newstate)
{
	if(newstate)
	{
		TurnOnSplash();
	}
	else
	{
		TurnOffSplash();
	}
}

function TurnOnSplash()
{
	if(Emitters.Length > 0)
		SuperSpriteEmitter(Emitters[0]).Disabled=false;
}

function TurnOffSplash()
{
	if(Emitters.Length > 0)
		SuperSpriteEmitter(Emitters[0]).Disabled=true;
}

function FitToNormal(vector HNormal)
{
	if(Emitters.Length > 0)
	{
		Emitters[0].StartVelocityRange.X.Max=(HNormal.x+1)*VEL_MAX;
		Emitters[0].StartVelocityRange.X.Min=(HNormal.x-1)*VEL_MAX;
		Emitters[0].StartVelocityRange.Y.Max=(HNormal.y+1)*VEL_MAX;
		Emitters[0].StartVelocityRange.Y.Min=(HNormal.y-1)*VEL_MAX;
		Emitters[0].StartVelocityRange.Z.Max=(HNormal.z+1)*VEL_MAX;
		Emitters[0].StartVelocityRange.Z.Min=(HNormal.z-1)*VEL_MAX;
	}
}

defaultproperties
{
} 
