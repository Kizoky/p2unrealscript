//=============================================================================
// AWPostalDude.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class AWPostalDude extends AWDude
	placeable;
	
///////////////////////////////////////////////////////////////////////////////
// Public vars
///////////////////////////////////////////////////////////////////////////////
var() Material PreInjuryHeadSkin;
var() Material PostInjuryHeadSkin;
var() Mesh ExpectedHeadMesh;
var Mesh OldHeadMesh;
var Material GrenadeSuicideEnhanced;

///////////////////////////////////////////////////////////////////////////////
// Make a grenade in his hand
///////////////////////////////////////////////////////////////////////////////
function Notify_SpawnGrenadeHand()
{
	Super.Notify_SpawnGrenadeHand();
	if(usegrenade != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime())
		usegrenade.Skins[0] = GrenadeSuicideEnhanced;
}

///////////////////////////////////////////////////////////////////////////////
// Put the grenade in his head and open the mouth
///////////////////////////////////////////////////////////////////////////////
function Notify_SpawnGrenadeHead()
{
	Super.Notify_SpawnGrenadeHead();
	if(usegrenade != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime())
		usegrenade.Skins[0] = GrenadeSuicideEnhanced;
}

///////////////////////////////////////////////////////////////////////////////
// Die with a grenade in your mouth
// Can't get around this, even with God mode
///////////////////////////////////////////////////////////////////////////////
function GrenadeSuicide()
{
	local Controller Killer;
	local P2Explosion exp;
	local vector Exploc;
	local coords checkcoords;

	// Pick explosion point
	checkcoords = GetBoneCoords(BONE_NECK);
	Exploc = checkcoords.Origin;

	Exploc -= checkcoords.YAxis*GRENADE_FORWARD_MOVE;

	// remove the fake grenade from his head
	Notify_RemoveGrenadeHead();
	
	// Enhanced mode: nuclear fucking explosion
	if (P2GameInfoSingle(Level.Game).VerifySeqTime())
	{
		// Make a grenade explosion here
		exp = spawn(class'MiniNukeHeadExplosion',self,,Exploc);
		exp.ShakeCamera(3000);
	}
	else
	{
		// Make a grenade explosion here
		exp = spawn(class'GrenadeHeadExplosion',self,,Exploc);
		exp.ShakeCamera(300);
	}

	// We must be in blood mode to remove the head but still do
	// the explosion effect above
	if(class'P2Player'.static.BloodMode())
	{
		// Remove head
		ExplodeHead(Exploc, vect(0,0,0));
	}

	// Kill the pawn
	Health = 0;

	Died( Killer, class'Suicided', Location );
}

///////////////////////////////////////////////////////////////////////////////
// Called by AW7GameInfo
///////////////////////////////////////////////////////////////////////////////
function DudeCheckHeadSkin()
{
	// If it's not the weekend yet, use the normal (non-injured) dude head.
	if (!P2GameInfoSingle(Level.Game).IsWeekend())
	{
		//log(self@"swapping to pre-injury head skin",'Debug');
		MyHead.Skins[1] = PreInjuryHeadSkin;
	}
	else
	{
		//log(self@"swapping to post-injury head skin",'Debug');
		MyHead.Skins[1] = PostInjuryHeadSkin;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Switch to this new mesh
///////////////////////////////////////////////////////////////////////////////
function SwitchToNewMesh(Mesh NewMesh,
						 Material NewSkin,
						 Mesh NewHeadMesh,
						 Material NewHeadSkin,
						 optional Mesh NewCoreMesh)
{
	local bool bSwappedFromOldDude;

	// Setup body (true means "keep anim state")
	SetMyMesh(NewMesh, NewCoreMesh, true);
	SetMySkin(NewSkin);
	LinkAnims();
	PlayWaiting();

	// The clothes are wonky, so if they specify using the old dude head, use the new head instead and set
	// the bandage skin accordingly.
	if (NewHeadMesh == class'DudeClothesInv'.Default.HeadMesh && NewHeadSkin == class'DudeClothesInv'.Default.HeadSkin)
	{
		NewHeadMesh = ExpectedHeadMesh;
		NewHeadSkin = PreInjuryHeadSkin;
		bSwappedFromOldDude = True;
	}

	// Setup head
	MyHead.LinkMesh(NewHeadMesh, true);
	// Because our headmesh is screwey, ask the head what it wants to set
	if(AWDudeHead(MyHead) != None && NewHeadMesh == ExpectedHeadMesh)
		AWDudeHead(MyHead).SetMainSkin(NewHeadSkin);
	else
		MyHead.Skins[0] = NewHeadSkin;

	if (bSwappedFromOldDude)
		DudeCheckHeadSkin();
}

defaultproperties
{
    BaseEquipment(0)=(WeaponClass=Class'UrethraWeapon')
    BaseEquipment(1)=(WeaponClass=Class'FootWeapon')
    BaseEquipment(2)=(WeaponClass=Class'MatchesWeapon')
    BaseEquipment(3)=(WeaponClass=Class'CellPhoneWeapon')
    Skins(0)=Texture'ChameleonSkins.Special.Dude'
	ExpectedHeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	OldHeadMesh=SkeletalMesh'heads.AvgDude'
	PreInjuryHeadSkin=Texture'AW_Characters.Special.Dude_AW'
	PostInjuryHeadSkin=Texture'AW_Characters.Special.Dude_AW_Bandage'
    HeadClass=Class'AWDudeHead'
    HeadSkin=Texture'AW_Characters.Special.Dude_AW_Bandage'
    HeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	//Tag="PostalDude"

	Begin Object Class=ConstantColor Name=ConstantBlack
		Color=(R=0,G=0,B=0)
	End Object
	Begin Object Class=Combiner Name=BlackGrenade
		CombineOperation=CO_Subtract
		Material1=Texture'WeaponSkins.grenade3_timb'
		Material2=ConstantColor'ConstantBlack'
	End Object
	Begin Object Class=Shader Name=BlackGrenadeShader
		Diffuse=Combiner'BlackGrenade'
		Specular=TexEnvMap'AW7Tex.Cubes.CubeShineMap'
		SpecularityMask=TexEnvMap'AW7Tex.Cubes.CubeShineMap'
	End Object
	GrenadeSuicideEnhanced=Texture'AW7Tex.Nuke.nuclear_grenade'
}
