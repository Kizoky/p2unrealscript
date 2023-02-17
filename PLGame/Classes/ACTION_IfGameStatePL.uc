///////////////////////////////////////////////////////////////////////////////
// ACTION_IfGameStatePL
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Executes a section of actions only if the specified gamestate status is met.
// This class is deprecated, use ACTION_IfDynamicVariable instead
///////////////////////////////////////////////////////////////////////////////
class ACTION_IfGameStatePL extends ACTION_IfDynamicVariable
	noteditinlinenew;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
// DEPRECATED SHIT
enum ETest
	{
	ET_Cash4CatsSpawned,
	ET_WipeHousePriceHikes,
	ET_Yeeland_Crate1,
	ET_Yeeland_Crate2,
	ET_Yeeland_Crate3,
	ET_Yeeland_Crate4,
	ET_Yeeland_Crate5
	};

var deprecated ETest Test;
var deprecated bool Is;
var deprecated String Name;
