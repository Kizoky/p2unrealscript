class MpMenuPawn extends MpDude;

///////////////////////////////////////////////////////////////////////////////
// Set this pawn's mesh
///////////////////////////////////////////////////////////////////////////////
simulated function SetMyMesh(Mesh NewMesh, optional Mesh NewCoreMesh, optional bool bKeepAnimState)
	{
	if (NewMesh != Mesh)
		{
		CoreSPMesh = NewCoreMesh;
		LinkMeshAndAnims(NewMesh, bKeepAnimState);
		}
	}

function SetCharacter(class<xMpPawn> CharacterClass)
{
	local int i;

	// Set new mesh, skin and head mesh/skin
	SwitchToNewMesh(
		CharacterClass.Default.Mesh,
		CharacterClass.Default.Skins[0],
		CharacterClass.Default.HeadMesh,
		CharacterClass.Default.HeadSkin,
		CharacterClass.Default.CoreSPMesh
	);

	// Set new boltons
	DestroyBoltons();
	for(i = 0; i < ArrayCount(CharacterClass.Default.Boltons); i++)
		Boltons[i] = CharacterClass.Default.Boltons[i];
	SetupBoltons();

	// Make everything unlit
	bUnlit = true;
	MyHead.bUnlit = true;
	for(i = 0; i < ArrayCount(Boltons); i++)
	{
		if(Boltons[i].part != None)
			Boltons[i].part.bUnlit = true;
	}
}

function JumpOffPawn()
{
}

///////////////////////////////////////////////////////////////////////////////
// Don't allow any ragdoll stuff with these pawns
///////////////////////////////////////////////////////////////////////////////
function bool AllowRagdoll(class<DamageType> DamageType)
{
	return false;
}

function GetKarmaSkeleton()
{
	// STUB
}

defaultproperties
	{
	CollisionRadius=0
	CollisionHeight=0
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	Physics=PHYS_None
	bHidden=true
	}
