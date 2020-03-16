class Projector extends Actor
	placeable
	native
	config	// RWS CHANGE: Added config var
	hidecategories(Force,Karma,LightColor,Lighting,Shadow,Sound);

#exec Texture Import File=Textures\projector.bmp Name=Proj_Icon Mips=Off MASKED=1
#exec Texture Import file=Textures\GRADIENT_Fade.tga Name=GRADIENT_Fade Mips=Off UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP
#exec Texture Import file=Textures\GRADIENT_Clip.tga Name=GRADIENT_Clip Mips=Off UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP


// Projector blending operation.

enum EProjectorBlending
{
	PB_None,
	PB_Modulate,
	PB_AlphaBlend,
	PB_Add
};

var() EProjectorBlending	MaterialBlendingOp,		// The blending operation between the material being projected onto and ProjTexture.
							FrameBufferBlendingOp;	// The blending operation between the framebuffer and the result of the base material blend.

// Projector properties.

var() Material	ProjTexture;
var() int		FOV;
var() int		MaxTraceDistance;
var() bool		bProjectBSP;
var() bool		bProjectTerrain;
var() bool		bProjectStaticMesh;
var() bool		bProjectParticles;
var() bool		bProjectActor;
var() bool		bLevelStatic;
var() bool		bClipBSP;
var() bool		bProjectOnUnlit;
var() bool		bGradient;
var() bool		bProjectOnAlpha;
var() bool		bProjectOnParallelBSP;
var() name		ProjectTag;
var() Texture	GradientTexture;


// Internal state.

// RWS CHANGE: Moved this here from GameInfo so it's available even in multiplayer games
var config bool bUseProjectors;

// RWS Change 02/20/02	If you've projected once, save that you have, but stay around, so that on
// a reload, we can come back, reproject, and then wait again. Reprojecting on a reload is okay, because actors
// that store us projecting on them use transient variables, so nothing is saved. Thus, we must reproject
// after a load.
var bool bReprojectAfterLoad;

var const transient plane FrustumPlanes[6];
var const transient vector FrustumVertices[8];
var const transient Box Box;
var const transient ProjectorRenderInfoPtr RenderInfo;
var transient Matrix GradientMatrix;
var transient Matrix Matrix;
var transient Vector OldLocation;

// Native interface.

native function AttachProjector();
native function DetachProjector(optional bool Force);
native function AbandonProjector(optional float Lifetime);

native function AttachActor( Actor A );
native function DetachActor( Actor A );

event PostBeginPlay()
{
	// RWS Change 01/22/03 If the game specifies no projectors, kill them right here, now
	if(!bUseProjectors)
	{
		Destroy();
	}
	else
	{
		AttachProjector();
		if( bLevelStatic )
		{
			AbandonProjector();
			// Save that we projected and are waiting for a reload to reproject. 
			// Don't destroy us though. We must be saved, in order to come back
			bReprojectAfterLoad=true;
		}
		else if( bProjectActor )
		{
			SetCollision(True, False, False);
			// GotoState('ProjectActors');  //FIXME - state doesn't exist
		}
	}
}

// RWS Change 02/20/02
// Reproject after the load if we need to
event PostLoadGame()
{
	Super.PostLoadGame();

	// Reproject now
	AttachProjector();
	if( bLevelStatic )
	{
		AbandonProjector();
		// Save that we projected and are waiting for a reload to reproject. 
		// Don't destroy us though. We must be saved, in order to come back
		bReprojectAfterLoad=true;
	}
	else
		bReprojectAfterLoad=false;
}

// RWS Change
// epic fix
// fixes projectors on static meshes now
// 02/27/02
// http://mail.epicgames.com/listarchive/showpost.php?list=unedit&id=9026
simulated event Touch( Actor Other )
{
	if( Other.bAcceptsProjectors && (ProjectTag=='' || Other.Tag==ProjectTag)
	&& (bProjectStaticMesh || Other.StaticMesh == None) )
		AttachActor(Other);
}
/*
event Touch( Actor Other )
{
	//if( Other.bAcceptsProjectors && (ProjectTag=='' || Other.Tag==ProjectTag) )
		AttachActor(Other);
}
*/
// epic fix
// RWS Change
event Untouch( Actor Other )
{
	DetachActor(Other);
}

defaultproperties
{
	MaterialBlendingOp=PB_None
	FrameBufferBlendingOp=PB_Modulate
	FOV=0
	bDirectional=True
	Texture=Proj_Icon
	MaxTraceDistance=1000
	bProjectBSP=True
	bProjectTerrain=True
	bProjectStaticMesh=True
	bProjectParticles=True
	bProjectActor=True
	bClipBSP=False
	bLevelStatic=False
	bProjectOnUnlit=False
	bHidden=True
	bStatic=True
	GradientTexture=GRADIENT_Fade
	bUseProjectors=true
}