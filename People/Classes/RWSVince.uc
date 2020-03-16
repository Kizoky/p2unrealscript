//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class RWSVince extends RWSStaff
	placeable;

// Vince needs to not use the turning anims when using these anims

simulated function PlayLaughingAnim()
{
	ChangePhysicsAnimUpdate(false);
	PlayAnim(GetAnimLaugh(), 1.0, 0.15);
}
simulated function PlayYourFiredAnim()
{
	ChangePhysicsAnimUpdate(false);
	PlayAnim('s_fired', 1.0, 0.15);
}


// Let his tag be 'RWSVince'
defaultproperties
	{
	ActorID="Vince"
	bPersistent=true
	bKeepForMovie=true
	bCanTeleportWithPlayer=false

	//Skins[0]=Texture'ChameleonSkins.Special.RWS_Pants'
	//Mesh=Mesh'Characters.Avg_M_SS_Pants'
	HeadSkin=Texture'ChamelHeadSkins.Special.Vince'
	HeadMesh=Mesh'Heads.AvgMale'
	DialogClass=class'BasePeople.DialogVince'
	ControllerClass=class'VinceController'
	bStartupRandomization=false
	VoicePitch=1.0
	Rebel=1.0
	bNoChamelBoltons=true
	}
