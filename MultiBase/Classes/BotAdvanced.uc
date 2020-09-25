///////////////////////////////////////////////////////////////////////////////
// BotAdvanced.uc
// Copyright 2019 Running With Scissors.  All Rights Reserved.
// by NickP, nickp@gopostal.com
//
// Advanced bot controller.
//
///////////////////////////////////////////////////////////////////////////////
class BotAdvanced extends Bot;

enum EMoanType
{
	MOAN_Hurt,
	MOAN_Angry
};

var bool bCanBotMoan;
var float BotMoanTimeLast;
var float BotMoanFiringTime;

function bool FireWeaponAt(Actor A)
{
	if( FRand() > 0.8 )
		PerformBotMoan(MOAN_Angry);
	return Super.FireWeaponAt(A);
}

function DamageAttitudeTo(Pawn Other, float Damage)
{
	PerformBotMoan(MOAN_Hurt);
	Super.DamageAttitudeTo(Other, Damage);
}

function float PlayBotMoan(EMoanType MoanType)
{
	local float fSayTime;
	local P2Pawn usePawn;

	if( P2Pawn(Pawn) == None || P2Pawn(Pawn).myDialog == None )
		return 0;
	usePawn = P2Pawn(Pawn);

	switch( MoanType )
	{
		case MOAN_Hurt:
			fSayTime = usePawn.Say(usePawn.myDialog.lgothit) + (0.1*FRand());
			break;
		case MOAN_Angry:
			BotMoanFiringTime = default.BotMoanFiringTime*FRand();
			fSayTime = usePawn.Say(usePawn.myDialog.lGetDownMP);//ldefiantline
			break;
		default:
			break;
	}
	return fSayTime;
}

function PerformBotMoan(EMoanType MoanType)
{
	if( !bCanBotMoan || Level.TimeSeconds < BotMoanTimeLast )
		return;

	if( MoanType == MOAN_Angry && Level.TimeSeconds < BotMoanTimeLast + BotMoanFiringTime )
		return;

	BotMoanTimeLast = Level.TimeSeconds+PlayBotMoan(MoanType);
}

defaultproperties
{
	bCanBotMoan=true
	BotMoanFiringTime=2.0
}
