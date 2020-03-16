///////////////////////////////////////////////////////////////////////////////
// ACTION_P2Screen.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This action lets you control various screens.
//
//	History:
//		07/14/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_P2Screen extends P2ScriptedAction;

enum EScreens
	{
	EMapScreen,
	EVoteScreen,
	ENewsScreen,
	EPickScreen,
	EStatsScreen,
	};

var(Action) EScreens Screen;			// which screen
var(Action) bool bMapRevealErrands;		// map screen: whether to reveal new errand(s)
var(Action) bool bMapRevealHaters;		// map screen: whether to reveal new hater(s)

function bool InitActionFor(ScriptedController C)
	{
	local P2Player p2p;

	p2p = GetPlayer(C);
	if (p2p != None)
		{
		switch (Screen)
			{
			case EMapScreen:
				if (bMapRevealErrands)
					p2p.DisplayMapErrands();
				else if (bMapRevealHaters)
					p2p.DisplayMapHaters();
				else
					p2p.DisplayMap();
				break;

			case EVoteScreen:
				p2p.DisplayVote();
				break;

			case ENewsScreen:
				p2p.DisplayNews();
				break;

			case EPickScreen:
				p2p.DisplayPick();
				break;

			case EStatsScreen:
				p2p.DisplayStats();
				break;

			default:
				break;
			}
		}
	return false;
	}

function string GetActionString()
	{
	switch (Screen)
		{
		case EMapScreen:
			return ActionString@"MapScreen, bMapRevealErrands="$bMapRevealErrands$", bMapRevealHaters="$bMapRevealHaters;
			break;

		case EVoteScreen:
			return ActionString@"VoteScreen";
			break;

		case ENewsScreen:
			return ActionString@"NewsScreen";
			break;

		case EPickScreen:
			return ActionString@"PickScreen";
			break;

		default:
			break;
		}
	return ActionString@"unknown";
	}

defaultproperties
	{
	ActionString="P2Screen: "
	}