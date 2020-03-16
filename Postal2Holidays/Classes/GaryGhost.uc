//=============================================================================
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class GaryGhost extends Bystander
	placeable;
	
function SetupHead()
{
	Super.SetupHead();
	
	// Krotchy doesn't really want a head, so scale the head way down so it isn't seen
	if (myHead != None)
		myHead.SetDrawScale(0.1);
}

// As a ghost, we ignore all damage.
// Ideally bullets and shit should pass through us but turning off trace collision might fuck up a bunch of other stuff
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	// If it's the dude, the controller wants to know about it
	if (InstigatedBy.Controller != None
		&& InstigatedBy.Controller.bIsPlayer
		&& GaryGhostController(Controller) != None)
		GaryGhostController(Controller).PawnSeen(InstigatedBy);
}

// We need to create our own localized colormodifier skins
// so they can be faded out individually, in case there are multiple Garys spawned (not likely, but still)
// EDIT: There can only be one Gary at a time now, so we don't need to do this (was causing crashes)
simulated event PostBeginPlay()
{
	local ColorModifier CM;
	local int i;
	
	for (i = 0; i < Skins.Length; i++)
	{
		/*
		CM = new class'ColorModifier';
		CM.Color.A = 128;
		CM.Color.R = 255;
		CM.Color.B = 255;
		CM.Color.G = 255;
		CM.RenderTwoSided = False;
		CM.AlphaBlend = True;
		CM.Material = Skins[i];
		Skins[i] = CM;
		CM = None;
		*/
		if (ColorModifier(Skins[i]) != None)
			ColorModifier(Skins[i]).Color.A = 128;
	}
	
	Super.PostBeginPlay();
}

// And those color modifiers have to be deleted properly
/*
simulated event Destroyed()
{
	local int i;
	
	for (i = 0; i < Skins.Length; i++)
	{
		if (ColorModifier(Skins[i]) != None)
		{
			//delete Skins[i];
			Skins[i] = None;
		}
	}
	
	Super.Destroyed();
}
*/

/*
function GaryDupeCheck()
{
	local GaryGhost G;

	// Abort if any other Gary Ghosts alive.
	foreach DynamicActors(class'GaryGhost', G)
		if (G != Self)
		{
			Destroy();
			return;
		}	
}

state Living
{
Begin:
	GaryDupeCheck();
}
*/

defaultproperties
{
	ActorID="Ghost"
	Begin Object Class=ColorModifier Name=WhitePlastic
		Color=(A=128,G=255,B=255,R=255)
		RenderTwoSided=False
		AlphaBlend=True
		Material=Texture'Halloweeen_Tex.white-plastic'
	End Object
	
	Begin Object Class=ColorModifier Name=GaryHead
		Color=(A=128,G=255,B=255,R=255)
		RenderTwoSided=False
		AlphaBlend=True
		Material=Texture'ChamelHeadSkins.Special.Gary'
	End Object
	
	Begin Object Class=ColorModifier Name=GaryBody
		Color=(A=128,G=255,B=255,R=255)
		RenderTwoSided=False
		AlphaBlend=True
		Material=Texture'ChameleonSkins.Special.Gary'
	End Object
	
	Mesh=Mesh'Halloweeen_Anims.GhostGary'
	Skins[0]=ColorModifier'WhitePlastic'
	Skins[1]=ColorModifier'GaryHead'
	Skins[2]=ColorModifier'GaryBody'
	HeadSkin=ColorModifier'GaryHead'
	HeadMesh=Mesh'Heads.Gary'
	bHeadCanComeOff=false

	CharacterType=CHARACTER_Mini

	CoreMeshAnim=MeshAnimation'Halloweeen_Anims.animMiniGhost'
	DialogClass=class'BasePeople.DialogGary'

	PeeBody=class'UrineSmallBodyDrip'
	GasBody=class'GasSmallBodyDrip'

	bRandomizeHeadScale=false
	bPersistent=true
	bHasRef=false
	bKeepForMovie=true
	bCanTeleportWithPlayer=false
	AnimGroupUsed=-1

	ControllerClass=class'GaryGhostController'
	HealthMax=550.0
	bStartupRandomization=false
	bNoDismemberment=true
	RandomizedBoltons(0)=None
    AW_SPMeshAnim=MeshAnimation'AWGary_Characters.animMini_AW'
	ExtraAnims(0)=MeshAnimation'MP_Gary_Characters.anim_GaryMP'
	ExtraAnims(1)=None
	ExtraAnims(2)=None
	ExtraAnims(3)=None
	ExtraAnims(4)=None
	ExtraAnims(5)=None
	ExtraAnims(6)=None
	bDoFootsteps=false
	HEAD_RATIO_OF_FULL_HEIGHT=0.1
}
