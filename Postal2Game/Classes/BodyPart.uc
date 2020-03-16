//=============================================================================
// BodyPart
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Any body part that attaches to a person, the distinction being that
// these parts are made of bones and tissue and probably bleed a lot.
//=============================================================================
class BodyPart extends PeoplePart
	abstract;

function Setup(Mesh NewMesh, Material NewSkin, Vector NewScale, byte NewAmbientGlow);

///////////////////////////////////////////////////////////////////////////////
// Make sure both the head and the both are independently running on the client
// after this. 
///////////////////////////////////////////////////////////////////////////////
simulated function TearOffNetworkConnection(class<DamageType> DamageType)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Set new scale
///////////////////////////////////////////////////////////////////////////////
simulated function SetScale(float NewScale);

// stub
function ZeroPukeFeeder(Fluid Caller);

defaultproperties
	{
	}
