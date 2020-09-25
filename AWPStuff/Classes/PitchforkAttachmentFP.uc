///////////////////////////////////////////////////////////////////////////////
// PitchforkAttachmentFP
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Attachment to put in the first-person hands
///////////////////////////////////////////////////////////////////////////////
class PitchforkAttachmentFP extends Actor;

defaultproperties
{
	// Change by NickP: MP fix
	RemoteRole=ROLE_None
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bBlockKarma=false
	bBlockPlayers=false
	bBlockNonZeroExtentTraces=false
	bBlockZeroExtentTraces=false
	bProjTarget=false
	// End

	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MRT_Holidays.Halloween.pitchfork_bolton'
}
