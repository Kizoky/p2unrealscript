//=============================================================================
// BodyEffects.
//=============================================================================
class BodyEffects extends P2Emitter;

var float ImpactRatio;

function SetRelativeMotion(vector Momentum, vector MakerVelocity)
{
	local int i, end;

	end = Emitters.Length-1;
	// all others move with owner
	for(i=0; i<end; i++)
	{
		Emitters[i].StartVelocityRange.X.Max += MakerVelocity.x;
		//Emitters[i].StartVelocityRange.X.Min = 	0;
		Emitters[i].StartVelocityRange.Y.Max += MakerVelocity.y;
		//Emitters[i].StartVelocityRange.Y.Min = 	0;
		Emitters[i].StartVelocityRange.Z.Max += MakerVelocity.z;
		//Emitters[i].StartVelocityRange.Z.Min = 	0;
	}
	// mist moves with blast
	Momentum*=ImpactRatio;
	//log(self$" momentum "$Momentum);
	Emitters[end].StartVelocityRange.X.Max = 	Momentum.x;
	Emitters[end].StartVelocityRange.X.Min = 	0;
	Emitters[end].StartVelocityRange.Y.Max = 	Momentum.y;
	Emitters[end].StartVelocityRange.Y.Min = 	0;
	Emitters[end].StartVelocityRange.Z.Max = 	Momentum.z;
	Emitters[end].StartVelocityRange.Z.Min = 	0;
}

defaultproperties
{
	ImpactRatio=0.02
	bReplicateMovement=true
}
