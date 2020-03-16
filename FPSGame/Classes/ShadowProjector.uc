//
//	ShadowProjector
//

class ShadowProjector extends Projector;

var() Actor					ShadowActor;
var() vector				LightDirection;
var() float					LightDistance;
var ShadowBitmapMaterial	ShadowTexture;

//
//	PostBeginPlay
//

simulated event PostBeginPlay()
{
	// RWS CHANGE: don't call super because we don't want shadow projectors to be
	// affected by bUseProjectors
	// This is a copy from Engine.Projector
	AttachProjector();
	if( bLevelStatic )
	{
		AbandonProjector();
		Destroy();
	}
	if( bProjectActor )
	{
		SetCollision(True, False, False);
	}
	// end copy

	ShadowTexture = new(Level) class'ShadowBitmapMaterial';
	ProjTexture = ShadowTexture;

	Enable('Tick');
}

//
//	UpdateShadow
//

function UpdateShadow()
{
	local vector	ShadowLocation;
	local Plane		BoundingSphere;

	DetachProjector(true);
	SetCollision(false,false,false);

	if(ShadowActor != None && !ShadowActor.bHidden)
	{
		BoundingSphere = ShadowActor.GetRenderBoundingSphere();
		FOV = Atan(BoundingSphere.W * 2 / LightDistance) * 180 / PI + 5;

		if(ShadowActor.DrawType == DT_Mesh && ShadowActor.Mesh != None)
			ShadowLocation = ShadowActor.GetBoneCoords('').Origin;
		else
			ShadowLocation = ShadowActor.Location;

		SetLocation(ShadowLocation);
		SetRotation(Rotator(Normal(-LightDirection)));
		SetDrawScale(LightDistance * tan(0.5 * FOV * PI / 180) / (0.5 * ShadowTexture.USize));

		ShadowTexture.ShadowActor = ShadowActor;
		ShadowTexture.LightDirection = Normal(LightDirection);
		ShadowTexture.LightDistance = LightDistance;
		ShadowTexture.LightFOV = FOV;
		ShadowTexture.Dirty = true;

		AttachProjector();
		SetCollision(true,false,false);
	}
}

//
//	Tick
//

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	UpdateShadow();
}

//
//	Touch
//

event Touch( Actor Other )
{
	if(Other != ShadowActor && Other.bAcceptsProjectors && bProjectActor)
		AttachActor(Other);
}

//
//	Default properties
//

defaultproperties
{
	bProjectActor=False
	bProjectOnParallelBSP=True
	bProjectOnAlpha=True
	bClipBSP=True
	bGradient=True
	bStatic=False
}