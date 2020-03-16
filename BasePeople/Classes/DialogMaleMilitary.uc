///////////////////////////////////////////////////////////////////////////////
// DialogMaleMilitary
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for Male Military and SWAT. Has lines in common with cops.
//
//	History:
//		07/11/02 NPF	Started.
//
///////////////////////////////////////////////////////////////////////////////
class DialogMaleMilitary extends DialogMaleCop;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lfollowme);
	Addto(lfollowme,							"WMaleDialog.wm_mil_gogogo", 1);
	Addto(lfollowme,							"WMaleDialog.wm_mil_moveout", 1);
	Addto(lfollowme,							"WMaleDialog.wm_mil_huthuthut", 2);

	Clear(lStayHere);
	Addto(lStayHere,							"WMaleDialog.wm_mil_securethearea", 1);

	Clear(lMil_MoveOut);
	AddTo(lMil_MoveOut,						"WMaleDialog.wm_mil_gogogo", 1);
	AddTo(lMil_MoveOut,						"WMaleDialog.wm_mil_moveout", 1);
	AddTo(lMil_MoveOut,						"WMaleDialog.wm_mil_huthuthut", 2);
	AddTo(lMil_MoveOut,						"WMaleDialog.wm_mil_go", 2);

	Clear(lMil_ManDown);
	AddTo(lMil_ManDown,						"WMaleDialog.wm_mil_mandown", 1);
	AddTo(lMil_ManDown,						"WMaleDialog.wm_mil_theykilled", 1);
	AddTo(lMil_ManDown,						"WMaleDialog.wm_mil_thelieutenant", 2);

	Clear(lMil_OverThere);
	AddTo(lMil_OverThere,						"WMaleDialog.wm_mil_theyreover", 1);
	AddTo(lMil_OverThere,						"WMaleDialog.wm_mil_theretheyare", 1);

	Clear(lMil_PickLeader);
	AddTo(lMil_PickLeader,						"WMaleDialog.wm_mil_someonesgotta", 1);

	Clear(lMil_NewLeader);
	AddTo(lMil_NewLeader,						"WMaleDialog.wm_mil_alrightilldoit", 1);
	AddTo(lMil_NewLeader,						"WMaleDialog.wm_mil_okaythatwould", 1);

	Clear(lMil_Commands);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_takethepoint", 1);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_coverourasses", 1);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_watchoutflank", 1);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_combtheperi", 2);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_takeemdown", 2);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_iwantthissit", 2);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_fireatwill", 3);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_retreat", 3);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_coverme", 3);
	AddTo(lMil_Commands,						"WMaleDialog.wm_mil_securethearea", 3);

	Clear(lMil_AcceptCommand);
	AddTo(lMil_AcceptCommand,						"WMaleDialog.wm_mil_Imonit", 1);
	AddTo(lMil_AcceptCommand,						"WMaleDialog.wm_mil_goodtogo", 1);
	AddTo(lMil_AcceptCommand,						"WMaleDialog.wm_mil_done", 1);

	Clear(lMil_FindCoward);
	AddTo(lMil_FindCoward,						"WMaleDialog.wm_mil_wevegothim", 1);
	AddTo(lMil_FindCoward,						"WMaleDialog.wm_mil_likearat", 1);
	AddTo(lMil_FindCoward,						"WMaleDialog.wm_mil_hesgoingnowhere", 2);
	AddTo(lMil_FindCoward,						"WMaleDialog.wm_mil_nowhereleftto", 2);

	Clear(lMil_RoomSecure);
	AddTo(lMil_RoomSecure,						"WMaleDialog.wm_mil_secure", 1);
	AddTo(lMil_RoomSecure,						"WMaleDialog.wm_mil_roomsclear", 1);
	AddTo(lMil_RoomSecure,						"WMaleDialog.wm_mil_allclear", 2);

	Clear(lMil_BystanderHelp);
	AddTo(lMil_BystanderHelp,						"WMaleDialog.wm_mil_heyhelpusout", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
