class ChangeViewTrigger extends Triggers;

var() enum EChangeViewType
{
	VT_SingleActorView,	// view changes to actor designated by ViewTag
	VT_MultipleActorView,	// view cycles through all actors designated by ViewTag
	VT_CurrentLeaderView,	// view changes to current leader
	VT_TeammateView,	// view changes to some non-jailed teammate
} NewView;

var() float CameraChangeTime;	// how long to wait before finding the next actor with this tag
var() name ViewTag;	// view changes to actor with this tag
var() string BeginViewingMessage;
var() string EndViewingMessage;	// tell the player they're done viewing

var array<PlayerController> ViewingList;
var Actor CurrentView;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	CurrentView=GetSingleActorView();
	SetTimer(CameraChangeTime, true);
}

event Timer()
{
	local int i;

	CurrentView = GetNextView(CurrentView);
	if (CurrentView != None)
		for (i=0; i<ViewingList.Length; i++)
		{
			ViewingList[i].ClientSetViewTarget(CurrentView);
			ViewingList[i].SetViewTarget(CurrentView);
		}
}

function Actor GetNextView(Actor Other)
{
	local Actor A, NextView;
	local bool bNextActor;
	local int count;

	NextView = None;
	count = 0;
	bNextActor=false;
	while (NextView == None && count < 5000)
	{
		count++;
		foreach AllActors(class'Actor', A, ViewTag)
		{
			if (bNextActor)
			{
				NextView = A;
				break;
			}
			else if (A == Other)
				bNextActor=true;
		}
	}

	return NextView;
}

function AddToViewingList(PlayerController P)
{
	local int i;
	for (i=0; i<ViewingList.Length; i++)
		if (ViewingList[i] == P)
			return;

	ViewingList.Insert(0,1);
	ViewingList[0] = P;
}

function RemoveFromViewingList(PlayerController P)
{
	local int i;
	for (i=0; i<ViewingList.Length; i++)
		if (ViewingList[i] == P)
		{
			ViewingList.Remove(i,1);
			break;
		}	
}

function actor GetSingleActorView()
{
	local Actor A;

	foreach AllActors(class'Actor', A, ViewTag)
		return A;
}

function actor GetCurrentLeaderView()
{
	local Controller C;
	local int CScore;
	local Controller CHigh;

	CScore=-9999;
	CHigh=None;

	C = Level.ControllerList;
	while (C != None)
	{
		if (C.PlayerReplicationInfo.Score > CScore && C.Pawn != None)
			if (C.Pawn.Health > 0)
			{
				CScore = C.PlayerReplicationInfo.Score;
				CHigh = C;
			}
		C = C.NextController;
	}

	if (CHigh != None)
		if (CHigh.Pawn != None)
			return CHigh.Pawn;

	return None;
}

function actor GetTeammateView(TeamInfo WhatTeam)
{
	local Controller C;
	local int CScore;
	local Controller CHigh;

	CScore=-9999;
	CHigh=None;

	C = Level.ControllerList;
	while (C != None)
	{
		if (C.PlayerReplicationInfo.Score > CScore && C.PlayerReplicationInfo.Team == WhatTeam && C.Pawn != None)
			if (C.Pawn.Health > 0)
			{
				CScore = C.PlayerReplicationInfo.Score;
				CHigh = C;
			}
		C = C.NextController;
	}

	if (CHigh != None)
		if (CHigh.Pawn != None)
			return CHigh.Pawn;

	return None;
}

event Touch(Actor Other)
{
	local PlayerController P;
	local Actor A;

	if (Pawn(Other) == None)
		return;

	if (PlayerController(Pawn(Other).Controller) == None)
		return;

	P = PlayerController(Pawn(Other).Controller);

	if (BeginViewingMessage != "")
		// Send a string message to the toucher.
		P.ClientMessage(BeginViewingMessage);

	switch NewView
	{
		case VT_SingleActorView:
			A = GetSingleActorView();
			break;
		case VT_MultipleActorView:
			AddToViewingList(P);
			A = CurrentView;
			break;
		case VT_CurrentLeaderView:
			A = GetCurrentLeaderView();
			P.ClientSetBehindView(true);
			P.bBehindView=true;
			break;
		case VT_TeammateView:
			A = GetTeammateView(P.PlayerReplicationInfo.Team);
			P.ClientSetBehindView(true);
			P.bBehindView=true;
			break;
	}
	P.ClientSetViewTarget(A);
	P.SetViewTarget(A);
}

event UnTouch(Actor Other)
{
	local PlayerController P;

	if (Pawn(Other) == None)
		return;

	if (PlayerController(Pawn(Other).Controller) == None)
		return;

	P = PlayerController(Pawn(Other).Controller);

	if (EndViewingMessage != "")
		// Send a string message to the toucher.
		P.ClientMessage(EndViewingMessage);

	P.ClientSetViewTarget(P.Pawn);
	P.SetViewTarget(P.Pawn);
	P.ClientSetBehindView(false);
	P.bBehindView=false;
}
