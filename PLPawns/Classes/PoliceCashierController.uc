class PoliceCashierController extends FFCashierController;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Somebody squirted on me while I was fighting
	///////////////////////////////////////////////////////////////////////////////
	function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
	{
		if(!MyPawn.IsTalking())
			MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);

		if(bPuke)
			// Definitely throw up from puke on me
			CheckToPuke(, true);

		// Check to wipe it off
		if(FRand() < 0.05)
			CheckWipeFace();
	}

	///////////////////////////////////////////////////////////////////////////////
	// During a fight, decide to stop fighting, if he sort of surrenders.
	///////////////////////////////////////////////////////////////////////////////
	function HandleSurrender(FPSPawn LookAtMe, out byte StateChange)
	{
		// If he's got nothing out, 
		// OR if he's got a melee weapon, but too far away to use it
		// then try to arrest him again, possibly
		if(P2Pawn(Attacker) != None
			&& Attacker == LookAtMe
			&& (Attacker.ViolentWeaponNotEquipped()
				|| (Attacker.Weapon != None
					&& Attacker.Weapon.bMeleeWeapon
					&& !TooCloseWithWeapon(Attacker, true)
					&& !Attacker.Weapon.IsFiring())))
		{
			// If he has his pants down, but is not actively pissing then give him 
			// a break
			if(!Attacker.HasPantsDown()
				|| (!Attacker.Weapon.IsFiring()
					&& (firecount == 0
						|| !MyPawn.Weapon.bMeleeWeapon)))
			{
				Enemy = None;
				firecount=0;
				StateChange=1;
				GotoStateSave('WatchThreateningPawn');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// We see our attacker, check his weapons
	///////////////////////////////////////////////////////////////////////////////
	function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
	{
		local byte WasOurGuy;

		HandleSurrender(LookAtMe, WasOurGuy);
		StateChange=WasOurGuy;

		// Continue on, if we didn't change states
		if(WasOurGuy == 0
			&& !FriendWithMe(LookAtMe))
			Super.ActOnPawnLooks(LookAtMe, StateChange);
	}
}
