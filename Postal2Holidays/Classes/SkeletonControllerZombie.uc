///////////////////////////////////////////////////////////////////////////////
// PLZombieController
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class SkeletonControllerZombie extends AWZombieController;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Based on the difficulty settings, change the zombie's attributes
///////////////////////////////////////////////////////////////////////////////
function RampDifficulty()
{
	local float gamediff, diffoffset;

	gamediff = P2GameInfo(Level.Game).GetGameDifficulty();
	diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
	if (SkeletonBase(Pawn) != None)
		diffoffset += SkeletonBase(Pawn).GenDifficultyMod;

	if(diffoffset != 0)
	{
		// Make zombies slightly faster animating as the difficulty increases
		ZPawn.GenAnimSpeed+= (diffoffset*DIFF_CHANGE_ANIM_SPEED);
		ZPawn.DefAnimSpeed = ZPawn.GenAnimSpeed;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AttackTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackTarget
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DecideAttack()
	{
		local float dist, vomitf, userand;
		local bool bswiped;
		local byte StateChange;
		local float SmashChance;
		
		if (SkeletonBase(Pawn) == None)
			SmashChance = 0.333;
		else
			SmashChance = SkeletonBase(Pawn).AttackChanceSmash;

		if(Attacker != None
			&& !Attacker.bDeleteMe
			&& Attacker.Health > 0)
		{
			if(ZPawn.bFloating)
				FindGroundAgain(StateChange);
			if(StateChange == 0)
			{
				dist = VSize(Attacker.Location - ZPawn.Location);
				if(dist < ZPawn.AttackRange.Max)
				{
					if(dist < ZPawn.AttackRange.Min)
					{
						userand = FRand();

						// Can do big smash either with legs
						// or floating, and has both arms
						if((!ZPawn.bMissingLegParts
								|| ZPawn.bFloating)
							&& ZPawn.HasBothArms()
							&& userand < SmashChance)
						{
							GotoStateSave('BigSmash');
							bSwiped=true;
						}
						// single arm swung, melee attack
						else if(userand < 0.5
							&& ZPawn.HasLeftArm())
						{
							GotoStateSave('SwipeLeft');
							bSwiped=true;
						}
						else if(ZPawn.HasRightArm())
						{
							GotoStateSave('SwipeRight');
							bSwiped=true;
						}
					}

					// Too far, tourette, spit, run or walk again
					if(!bSwiped)
					{
						// If you're very close to swiping range, be less likely to attack
						// by spitting, unless you don't have arms
						if(dist < 2*ZPawn.AttackRange.Min
							&& ZPawn.HasLeftArm()
							&& ZPawn.HasRightArm())
							vomitf = CLOSE_VOMIT_RATIO*ZPawn.VomitFreq;
						else
							vomitf = ZPawn.VomitFreq;

						// ranged attack
						if(FRand() <= vomitf)
						{
							GotoStateSave('VomitAttack');
						}
						// If we're a tourette, hang out for a moment
						else if(ZPawn.PawnInitialState == ZPawn.EPawnInitialState.EP_Turret)
						{
							SetNextState('AttackTarget');
							GotoStateSave('TurretWait');
						}
						else // check how to move there
						{
							SetNextState('AttackTarget');
							SetEndGoal(Attacker, DEFAULT_END_RADIUS);

							if(ZPawn.bIsDeathCrawling
								|| ZPawn.bWantsToDeathCrawl
								|| ZPawn.bMissingLegParts)
								GotoStateSave('CrawlToAttacker');
							else if(FRand() < ZPawn.ChargeFreq)
								GotoStateSave('RunToAttacker');
							else
								GotoStateSave('WalkToAttacker');
						}
					}

				}
				else
				{
					SetNextState('AttackTarget');
					if(ZPawn.PawnInitialState == ZPawn.EPawnInitialState.EP_Turret)
					{
						GotoStateSave('TurretWait');
					}
					else
					{
						SetEndGoal(Attacker, DEFAULT_END_RADIUS);
						if(ZPawn.bIsDeathCrawling
							|| ZPawn.bWantsToDeathCrawl
							|| ZPawn.bMissingLegParts)
							GotoStateSave('CrawlToAttacker');
						else
							GotoStateSave('WalkToAttacker');
					}
				}
			}
		}
		else
		{
			SetAttacker(None);
			if(ZPawn.PawnInitialState == ZPawn.EPawnInitialState.EP_Turret)
			{
				GotoStateSave('ActAsTurret');
			}
			else
				GotoStateSave('Thinking');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// VomitAttack
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state VomitAttack
{
	/*
	event BeginState()
	{
		Super.BeginState();
		Pawn.TurnLeftAnim=ZPawn.GetAnimVomitAttack();
		Pawn.TurnRightAnim=ZPawn.GetAnimVomitAttack();
		Focus = Attacker;
	}
	event EndState()
	{
		Pawn.TurnLeftAnim=Pawn.MovementAnims[0];
		Pawn.TurnRightAnim=Pawn.MovementAnims[0];
		Focus = None;
	}
	*/
Begin:
	ZPawn.PlayAnimVomitAttack();
}
