//
//	Postal 2 ShadowProjector
//  Some bits adapted from NMShadow Patch.
//

class P2ShadowProjector extends Projector;

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

    InitShadow();
}

//
//	UpdateShadow
//

function UpdateShadow()
{
	local vector	ShadowLocation;
	//local Plane		BoundingSphere;
	//local float     oldDrawScale;

	if(Owner == none)
	   return;

    DetachProjector(true);
    // This kills the framerate (And also projectiles.)
	//SetCollision(false,false,false);

    // TODO - Find out how to stop emitter particles from displaying shadows.
	if((ShadowActor != none && !ShadowActor.bHidden) && (ShadowActor.DrawType != DT_Particle) && (Level.TimeSeconds - ShadowActor.LastRenderTime < 3) && (ShadowTexture != none))
	{
        if(ShadowTexture.Invalid)
		  Destroy();
		else
		{
            if(ShadowActor.DrawType == DT_Mesh && ShadowActor.Mesh != None)
		      	ShadowLocation = ShadowActor.GetBoneCoords('').Origin;
            else
			    ShadowLocation = ShadowActor.Location;

            SetLocation(ShadowLocation);
            SetRotation(Rotator(Normal(-LightDirection)));

            ShadowTexture.Dirty = true;

            AttachProjector();
		// This kills the framerate (And also projectiles.)
		//SetCollision(true,false,false);
		}
	}
}

// Taken from NMShadowProjector. (Thanks Russia!)
function InitShadow()
{
	local Plane	BoundingSphere;

	if(Owner == none)
	   return;

	if(ShadowActor != None)
	{
		BoundingSphere = ShadowActor.GetRenderBoundingSphere();
		FOV = Atan(BoundingSphere.W * 2 / LightDistance) * 180 / PI + 5;

        // Moved ObjectPool from P2GameInfo to LevelInfo to skip some steps.
		ShadowTexture = ShadowBitmapMaterial(Level.ObjectPool.AllocateObject(class'ShadowBitmapMaterial'));


		ProjTexture = ShadowTexture;

		if(ShadowTexture != None)
		{
			SetDrawScale(LightDistance * tan(0.5 * FOV * PI / 180) / (0.5 * ShadowTexture.USize));

			ShadowTexture.Invalid = False;
			ShadowTexture.ShadowActor = ShadowActor;
			ShadowTexture.LightDirection = Normal(LightDirection);
			ShadowTexture.LightDistance = LightDistance;
			ShadowTexture.LightFOV = FOV;
			// Not used in p2?
			//ShadowTexture.CullDistance = CullDistance;

			Enable('Tick');
		}
		else
			Log(Name$".InitShadow: Failed to allocate texture");
	}
	else
		Log(Name$".InitShadow: No actor");
}

//
//	Tick
//

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	UpdateShadow();
}

function Destroyed()
{
	// free shadow texture from the object pool
	if (ShadowActor != None)
	{
		ShadowActor = None;
    }


    if(!ShadowTexture.Invalid)
		Level.ObjectPool.FreeObject(ShadowTexture);


    if (ShadowTexture != none)
    {
		// must set to none
		ShadowTexture = None;
		ProjTexture = None;
	}
	Super.Destroyed();
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
    //CullDistance=2000.000000
	bClipBSP=True
	bGradient=True
	bStatic=False
}
