///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class TWPDudePlayer extends AWDudePlayer;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////

var bool bUsingMountedWeapon;
var bool bStillTalkingCorey;

// Sell item hints
var localized string SellHint1, SellHint2;

// Gears of War style third person shooting camera offset thingy!
var vector ThirdPersonCameraOffset;

const DOUBLE_DEUCE_CHANCE = 0.05;		// Percent chance to do a "double deuce" instead of a single deuce when telling people to fuck off

///////////////////////////////////////////////////////////////////////////////
// Functions for Mounted Weapon
///////////////////////////////////////////////////////////////////////////////
exec function PrevWeapon()
{
	// Ignore while on the minigun
	if (bUsingMountedWeapon)
	    return;
	else
		Super.PrevWeapon();
}
exec function NextWeapon()
{
	// Ignore while on the minigun
	if (bUsingMountedWeapon)
	    return;
	else
		Super.NextWeapon();
}
exec function SwitchWeapon(byte F)
{
	if (bUsingMountedWeapon)
	    return;
	else
		Super.SwitchWeapon(F);
}
function ClientToggleToHands(optional bool bForce)
{
    if (!bUsingMountedWeapon)
        super.ClientToggleToHands(bForce);
}

exec function UseZipper( optional float F )
{
    if (!bUsingMountedWeapon)
        super.UseZipper(F);
}

///////////////////////////////////////////////////////////////////////////////
// GetSellItemHints
///////////////////////////////////////////////////////////////////////////////
function bool GetSellItemHints(out String str1, out String str2)
{
	if (InterestPawn != None
		&& InterestPawn.Controller != None
		&& ReverseCashierController(InterestPawn.Controller) != None
		&& MoneyInv(MyPawn.SelectedItem) == None)
	{
		str1 = SellHint1;
		str2 = SellHint2;
		return true;
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Yell when hurt, set up flashy hurt bars, etc.
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	// If the dude is dumbass enough to walk into their own flashbang (or gets hit by an enemy flashbang)
	if (ClassIsChildOf(DamageType, class'FlashBangDamage'))
		//PLHud(MyHud).HitByFlashBang();
		TWPHud(MyHud).HitByFlashBang();

	Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

// debug for test
exec function FlashMe()
{
	//PLHud(MyHud).HitByFlashBang();
	TWPHud(MyHud).HitByFlashBang();
}

exec function CoreyMe()
{
	SaidCoreyLine(1.0);
}


///////////////////////////////////////////////////////////////////////////////
// Dude is asking for money to be donated to him or a charity
///////////////////////////////////////////////////////////////////////////////
function DudeAskForMoney(vector AskPoint, float AskRadius,
						 actor HitActor,		// actor we hit with our test forward.. dude's aiming at this guy
						 bool bIsForCharity)
{
	local FPSPawn CheckP, KeepP;
	local float keepdist, checkdist, usedot;
	local byte StateChange;
	local int useline;
	local LambController lambc;
	local PersonController personc;

	// Check to see if we lost our interest
	if (InterestPawn != None
		&& (InterestPawn.IsInState('Dying')
			|| !InterestPawn.Controller.IsInState('CheckToDonate')
		)
		)
		InterestPawn = None;

	// Don't even try this if you're already talking to someone
	if(InterestPawn != None
		|| bDealingWithCashier)
		return;

	keepdist = 2*AskRadius;

	// Check if we were aiming at someone in particular
	CheckP = FPSPawn(HitActor);
	if(CheckP != None)
	{
		if(CheckP != MyPawn									// not me
			&& CheckP.Health > 0)							// live people are listening
			KeepP = FPSPawn(HitActor);
	}

	if(KeepP == None)	// we weren't aiming at anyone in particular so look for someone
	{
		// Do a collision test in this area, where you would have stopped the trace
		ForEach VisibleCollidingActors(class'FPSPawn', CheckP, AskRadius, AskPoint)
		{
			if(CheckP != MyPawn									// not me
				&& CheckP.Health > 0							// live people are listening
				&& FastTrace(MyPawn.Location, CheckP.Location)  // not on the other side of a wall
				&& ((Normal(CheckP.Location - MyPawn.Location) Dot vector(MyPawn.Rotation)) > PETITION_FOV))
				// and generally in front of the dude
			{
				checkdist = VSize(CheckP.Location - AskPoint);

				if(keepdist > checkdist)
				{
					keepdist = checkdist;
					KeepP = CheckP;
				}
			}
		}
	}

	if (PhotoWeapon(Pawn.Weapon) != None)
	{
		if (useline == -2)
			// Person's dealing with me, so leave early
			return;

		// For the photo weapon, the Dude gets more and more frustrated as he asks more people
		// His current ammo count reflects the number of people he's asked.

		switch (Pawn.Weapon.AmmoType.AmmoAmount)
		{
			case 1:
				SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude1);
				break;
			case 2:
				SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude2);
				break;
			case 3:
				SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude3);
				break;
			case 4:
				SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude4);
				break;
			case 5:
				SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude5);
				break;
			case 6:
				SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude6);
				break;
			case 7:
				SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude7);
				break;
			default:
				SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude8);
				break;
		}

		/*
		// If this is the last guy, bust out our biggest line
		if (Pawn.Weapon.AmmoType.AmmoAmount >= Pawn.Weapon.AmmoType.MaxAmmo - 1)
			SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_DudeLast);
		// Otherwise, line depends on how frustrated the Dude is
		else if (Pawn.Weapon.AmmoType.AmmoAmount <= Pawn.Weapon.AmmoType.MaxAmmo * 0.2)
			SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude1);
		else if (Pawn.Weapon.AmmoType.AmmoAmount <= Pawn.Weapon.AmmoType.MaxAmmo * 0.4)
			SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude2);
		else if (Pawn.Weapon.AmmoType.AmmoAmount <= Pawn.Weapon.AmmoType.MaxAmmo * 0.6)
			SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude3);
		else
			SayTime = MyPawn.Say(MyPawn.MyDialog.lPhoto_Dude4);
		*/
	}
	else
	{
		if(KeepP != None)
		{
			personc = PersonController(KeepP.controller);
			if(personc != None)
				useline = personc.DonatedBotherCount;
		}

		// Say to give me money/signatures
		switch(useline)
		{
			case -2:
				// Person's dealing with me so leave early
				return;
			case -1:
			case 0:
				//log("-----------------------dude dialogue: please sign this");
				if (CanWeapon(Pawn.Weapon) != None)
					SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Can1);
				else
					SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Petition1);
			break;
			case 1:
				//log("-----------------------dude dialogue: sign it now!");
				if (CanWeapon(Pawn.Weapon) != None)
					SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Can2);
				else
					SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Petition2);
			break;
			case 2:
				//log("-----------------------dude dialogue: sign it or i kill you");
				if (CanWeapon(Pawn.Weapon) != None)
					SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Can3);
				else
					SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Petition3);
			break;
		}
	}
	SetTimer(SayTime + 1.0, false);
	bStillTalking=true;


	// Tell them who's talking to me
	if(KeepP != None)
	{
		lambc = LambController(KeepP.Controller);
	}

	if(lambc != None)
	{
		lambc.RespondToTalker(MyPawn, None, TALK_askformoney, StateChange);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make the dude reach out and grab money
///////////////////////////////////////////////////////////////////////////////
function GrabMoneyPutInCan(int MoneyToGet)
{
	local ClipboardWeapon canweap;
	local P2GameInfoSingle checkg;

	canweap = ClipboardWeapon(Pawn.Weapon);
	//log(canweap@"grab money put in can"@moneytoget);

	// Handle photograph
	if (PhotoWeapon(CanWeap) != None)
	{
		CanWeap.CauseAltFire();
	}
	else if(canweap != None)
	{
		// play anim on clipboard to get signature
		canweap.CauseAltFire();
		// set how many sigs to give the dude, probably just 1
		canweap.PendingMoney = MoneyToGet;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Said a Corey Line
// Do AW head effects for the duration of the line
///////////////////////////////////////////////////////////////////////////////
function SaidCoreyLine(float Duration)
{
	// Skip these if we're in dual-wield mode, that pops up the head injury overlay
	if (DualWieldUseTime == 0)
	{
		//AWDude(Pawn).HasHeadInjury=1;
		//P2Hud(myHUD).DoWalkHeadInjury();
		TWPHud(myHUD).DoCoreyHeadInjury();
		bStillTalkingCorey=True;
	}
	SetTimer(Duration, false);
}

///////////////////////////////////////////////////////////////////////////////
// Turn off head effects
///////////////////////////////////////////////////////////////////////////////
event Timer()
{
	// Call super to stop the talking if necessary
	Super.Timer();
	
	// Turn off P3 Dude talking effects
	if (bStillTalkingCorey)	
	{
		//AWDude(Pawn).HasHeadInjury=0;
		//P2Hud(myHUD).StopHeadInjury();
		TWPHud(myHUD).StopCoreyHeadInjury();
		bStillTalkingCorey=False;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Overriden so we can aim up and down when we're in third person
///////////////////////////////////////////////////////////////////////////////
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
    if (bBehindView)
        return Rotation;

    return super.AdjustAim(FiredAmmunition, projStart, aimerror);
}

///////////////////////////////////////////////////////////////////////////////
// Wrote this while testing out third person stuff, decided we might as well
// keep this better looking third person view
///////////////////////////////////////////////////////////////////////////////
/*
function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    local vector HitLocation, HitNormal, EndTrace, StartTrace;

	// FIX: this broke the viewclass debug cheat - Rick
	if (ViewTarget == Pawn)
	{
		StartTrace = ViewTarget.Location;
		EndTrace = StartTrace + class'P2EMath'.static.GetOffset(CameraRotation, ThirdPersonCameraOffset);

		if (Trace(HitLocation, HitNormal, EndTrace, StartTrace, false) != none)
			CameraLocation = HitLocation;
		else
			CameraLocation = EndTrace;
	}
	else
		Super.CalcBehindView(CameraLocation, CameraRotation, Dist);
}*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Player Movement States
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerWalking
{
	// PlayerWalking. Not overriding the rest of these, we pretty much use just Walking,
	// if the player is in another movement state they're probably cheating anyway ;)
	function PlayerMove( float DeltaTime )
	{
		// Prevent all movement if the player is milking a cow.
		if ((BucketWeapon(Pawn.Weapon) == None || Pawn.Weapon.IsInState('Idle'))
			&& (EnsmallenWeapon(Pawn.Weapon) == None || !Pawn.Weapon.IsInState('Inject')))
			Super.PlayerMove(DeltaTime);
	}
}

// Player scored a nutshot, tell the gameinfo.
function ScoredNutShot(P2Pawn Victim)
{
	if (PLGameState(P2GameInfoSingle(Level.Game).TheGameState) != None)
	{
		PLGameState(P2GameInfoSingle(Level.Game).TheGameState).NutShots++;
	}
	if(Level.NetMode != NM_DedicatedServer ) GetEntryLevel().GetAchievementManager().UpdateStatInt(self, 'PLNutshots', 1, true);
}

// Made a dual wield kill, tell the achievement manager.
function MadeDualWieldKill(P2Pawn Victim)
{
	if(Level.NetMode != NM_DedicatedServer ) GetEntryLevel().GetAchievementManager().UpdateStatInt(self, 'PLDualWieldKills', 1, true);
}

// Player should use the ensmallen cure, NOW! Helpfully switch their weapon to drive the point home
function ShouldUseCure()
{
	SayTime = MyPawn.Say(MyPawn.MyDialog.lDude_ShouldUseCure);
	SwitchToThisWeapon(class'EnsmallenWeapon'.default.InventoryGroup, class'EnsmallenWeapon'.default.GroupOffset);
}

///////////////////////////////////////////////////////////////////////////////
// called after a level travel
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	Super.TravelPostAccept();
	
	// Restore funzerking
	if (PLGameState(P2GameInfoSingle(Level.Game).TheGameState).bFunzerking)
		RestoreCheat("FunzerkingKicksAss");
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
    CheatClass=Class'TWPCheatManager'
	//SissyText="Jokes on you, this will not work."
}
