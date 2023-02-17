///////////////////////////////////////////////////////////////////////////////
// LawmenBase
// Copyright 2014, Running With Scissors, Inc.
//
// Base class for Lawmen characters, the police of PL.
//
// TODO: fill in with Lawmen-specific boltons
///////////////////////////////////////////////////////////////////////////////
class LawmenBase extends Police;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var(Character) array<Name> ChamelJacketSkins;	// Array of skins for the Lawmen's longcoat.
//var vector RagdollHeadOffset;

const MESH_HANDS_INDEX = 2;		// Index of hand skin, since it's separate from the body
const MESH_JACKET_INDEX = 1;	// Index of longcoat skin

//const LAWMAN_SKEL = 'LawmenRagdoll';

// We don't use gunbelts
function TurnOffPistol();
function TurnOnPistol();

///////////////////////////////////////////////////////////////////////////////
// Swap out to our burned mesh
// Lawmen need to burn their longcoat and hand skins too.
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	if(class'P2Player'.static.BloodMode())
	{
		// Set my body skin
		Skins[MESH_HANDS_INDEX] = BurnSkin;
		if (Skins[MESH_JACKET_INDEX] != None)
			Skins[MESH_JACKET_INDEX] = BurnSkin;
	}
	
	Super.SwapToBurnVictim();
}


///////////////////////////////////////////////////////////////////////////////
// Setup appearance
// Call super plus set up our longcoat skin (if any) and hands skin
///////////////////////////////////////////////////////////////////////////////
function SetupAppearance()
{
	local Chameleon cham;
	local int i, usemax;
	local Material JacketSkin;

	Super.SetupAppearance();

	// If chameleon feature is enabled then pick a random longcoat
	if (bChameleon && P2GameInfo(Level.Game) != None)
	{
		cham = P2GameInfo(Level.Game).GetChameleon();
		if (cham != None)
		{
			Skins[MESH_HANDS_INDEX] = Skins[0];
			for (i = 0; i < ChamelJacketSkins.Length; i++)
				if (ChamelJacketSkins[i] == 'End')
					usemax = i;
			if (usemax == 0)
				usemax = ChamelJacketSkins.Length;
			i = int(cham.MyRand() * usemax);
			JacketSkin = Material(DynamicLoadObject(String(ChamelJacketSkins[i]), class'Material'));
			if (JacketSkin == None)
				warn(self@"could not load jacket skin"@ChamelJacketSkins[i]);
			else
				Skins[MESH_JACKET_INDEX] = JacketSkin;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
}

///////////////////////////////////////////////////////////////////////////////
// Set dialog class
///////////////////////////////////////////////////////////////////////////////
function SetDialogClass()
{
	DialogClass=class'DialogMaleLawmen';
}

///////////////////////////////////////////////////////////////////////////////
// GetKarmaSkeleton
// Use a lawman ragdoll
///////////////////////////////////////////////////////////////////////////////
/*
function GetKarmaSkeleton()
{
	local P2GameInfo checkg;
	local name skelname;
	local P2Player p2p, cont;
	
	skelname=LAWMAN_SKEL;

	if(Level.NetMode != NM_DedicatedServer)
	{
		// Go through all the player controllers till you find the one on
		// your computer that has a valid viewport and has your ragdolls
		foreach DynamicActors(class'P2Player', Cont)
		{
			if (ViewPort(Cont.Player) != None)
			{
				p2p = Cont;
				break;
			}
		}
		if(p2p != None
			&& KParams == None)
		{
			KParams = p2p.GetNewRagdollSkel(self, skelname);
		}
	}
}
*/

defaultproperties
{
	ActorID="Lawman"

	Gang="Lawmen"
	Boltons[0]=(bone="cop_badge",staticmesh=staticmesh'PLCharacterMeshes.IAmTheLaw.Cowboy_Badge',bCanDrop=false)
	Boltons[1]=(bInActive=true)
	//ADJUST_RELATIVE_HEAD_X=6
	//ExtraAnims(2)=MeshAnimation'PLCharacters.animLawman_MP'
	StumpClass=class'StumpLawmen'
	LimbClass=class'LimbLawmen'
	StumpAdjust=(X=5)
	AmbientGlow=30
	bCellUser=false
	Begin Object Class=BoltonDef Name=BoltonDefHat_LawmanHat
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.IAmTheLaw.cowboyHAT_HART',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
}
