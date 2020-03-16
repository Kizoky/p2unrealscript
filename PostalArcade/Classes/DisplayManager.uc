///////////////////////////////////////////////////////////////////////////////
// DisplayManager
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Lets you change all kinds of properties about actors
///////////////////////////////////////////////////////////////////////////////
class DisplayManager extends Triggers
	hidecategories(Collision,Lighting,LightColor,Karma,Force,Shadow,Sound)
    placeable;
	
#exec TEXTURE IMPORT NAME=DisplayManagerIcon FILE=Textures\display_manager.bmp MASKED=1

struct ActorStruct
{
    var() name ActorTag;				// Tag of Actor to modify
    var() bool bActorHidden;			// New value for bHidden (Must be set)
    var() bool bNewCollideActors;		// New value for bCollideActors (Must be set)
    var() bool bNewBlockActors;			// New value for bBlockActors (Must be set)
    var() bool bNewBlockPlayers;		// New value for bBlockPlayers (Must be set)
	var() bool bNewBlockKarma;			// New value for bBlockKarma (Must be set)
    var() float NewCollisionHeight;		// New value for collision height (0 = don't change)
    var() float NewCollisionRadius;		// New value for collision radius (0 = don't change)
	var() array<Material> NewSkins;		// New skins to apply to actor (empty = don't change)
	var() StaticMesh NewStaticMesh;		// New StaticMesh to apply to actor (None = don't change). Does not change DrawType
	var() Material NewTexture;			// New Texture to apply to actor (None = don't change). Not to be confused with NewSkins
	var() EDrawType NewDrawType;		// New DrawType to apply to actor (DT_None = don't change)
};

var() array<ActorStruct> ActorInfo;

function Trigger(Actor Other, Pawn EventInstigator)
{
    local int i, j;
    local Actor TargetActor;

    for (i=0;i<ActorInfo.length;i++)
    {
        TargetActor = None;

        foreach AllActors(class'Actor', TargetActor, ActorInfo[i].ActorTag)
		{
			// Rick F update - draw type, static mesh, texture
			if (ActorInfo[i].NewDrawType != DT_None)
				TargetActor.SetDrawType(ActorInfo[i].NewDrawType);
				
			if (ActorInfo[i].NewStaticMesh != None)
				TargetActor.SetStaticMesh(ActorInfo[i].NewStaticMesh);
				
			if (ActorInfo[i].NewTexture != None)
				TargetActor.Texture = ActorInfo[i].NewTexture;
			
            TargetActor.bHidden = ActorInfo[i].bActorHidden;
            TargetActor.SetCollision(ActorInfo[i].bNewCollideActors, ActorInfo[i].bNewBlockActors, ActorInfo[i].bNewBlockPlayers);
			TargetActor.KSetBlockKarma(ActorInfo[i].bNewBlockKarma);

            if (ActorInfo[i].NewCollisionHeight > 0 && ActorInfo[i].NewCollisionRadius > 0)
                TargetActor.SetCollisionSize(ActorInfo[i].NewCollisionRadius, ActorInfo[i].NewCollisionHeight);
			
			// Rick F update - new skins.
			if (ActorInfo[i].NewSkins.Length > 0)
			{
				for (j = 0; j < ActorInfo[i].NewSkins.Length; j++)
					if (j < TargetActor.Skins.Length)
						TargetActor.Skins[j] = ActorInfo[i].NewSkins[j]; 
			}
		}
    }
}

defaultproperties
{
     bHidden=True
     bEdShouldSnap=True
	 Texture=Texture'DisplayManagerIcon'
	 DrawScale=0.25
}
