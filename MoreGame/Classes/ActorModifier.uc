///////////////////////////////////////////////////////////////////////////////
// ActorModifier
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Trigger that changes display properties of another actor (usually a static mesh)
// WARNING: This class is obsolete, use DisplayManager instead. - Rick
///////////////////////////////////////////////////////////////////////////////
class ActorModifier extends Triggers
	notplaceable;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() name ActorTag;			// Tag of actor to modify
var() array<Material> NewSkins;	// Skins to apply to actor (NO CHANGE IS MADE IF EMPTY)
var() StaticMesh NewStaticMesh;	// Static Mesh to apply to actor (no change is made if None)
var() Material NewTexture;		// Texture to apply to actor (NOT SKINS - this is for sprites etc.)

///////////////////////////////////////////////////////////////////////////////
// Apply materials.
///////////////////////////////////////////////////////////////////////////////
event Trigger( Actor Other, Pawn EventInstigator )
{
	local Actor A;
	local int i;
	
	foreach AllActors(class'Actor', A, ActorTag)
	{
		if (StaticMesh != None)
			A.SetStaticMesh(NewStaticMesh);
			
		if (NewTexture != None)
			A.Texture = NewTexture;
			
		if (NewSkins.Length > 0)
		{
			A.Skins.Length = NewSkins.Length;
			for (i = 0; i < NewSkins.Length; i++)
				A.Skins[i] = NewSkins[i];
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	Texture=Texture'PostEd.Icons_256.tmaterialtrigger'
	DrawScale=0.25
	bObsolete=true
}