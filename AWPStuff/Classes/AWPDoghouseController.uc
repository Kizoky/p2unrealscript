class AWPDoghouseController extends DogController;

//const ATTACK_DEAD = 0.1;

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about this danger
///////////////////////////////////////////////////////////////////////////////
function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
								FPSPawn CreatorPawn, 
								Actor OriginActor,
								vector blipLoc,
								optional out byte StateChange)
{
	// If this thing doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses
		|| MyPawn.bIgnoresHearing)
		return;

	// If we have a hero, check to protect him
	if(Hero != None
		&& HeroLove > 0
		&& CreatorPawn != None)
	{
		// Someone is attacking our hero
		if((PersonController(CreatorPawn.Controller) != None
				&& PersonController(CreatorPawn.Controller).Attacker == Hero)
			|| (AnimalController(CreatorPawn.Controller) != None
				&& AnimalController(CreatorPawn.Controller).Attacker == Hero))
		{
			SetAttacker(CreatorPawn); 
			GotoStateSave('AttackTarget');
			return;
		}
		// Our hero is attacking someone
		else if(CreatorPawn == Hero)
		{
			if(PersonController(Hero.Controller) != None
					&& PersonController(Hero.Controller).Attacker != None
					&& PersonController(Hero.Controller).Attacker.Health > 0)
			{
				SetAttacker(PersonController(Hero.Controller).Attacker);
				GotoStateSave('AttackTarget');
				return;
			}
			// If the player has a live enemy, go after them
			else if(P2Player(Hero.Controller) != None
					&& FPSPawn(P2Player(Hero.Controller).Enemy) != None
					&& !FPSPawn(P2Player(Hero.Controller).Enemy).bPlayerIsFriend
					&& P2Player(Hero.Controller).Enemy.Health > 0)
			{
				SetAttacker(FPSPawn(P2Player(Hero.Controller).Enemy));
				GotoStateSave('AttackTarget');
				return;
			}
		}
		// If another dog friend of our hero is attacking someone, go help them
		// As long as he's not attacking the player, or a friend
		if(P2Player(Hero.Controller) != None
			&& P2Player(Hero.Controller).IsAnimalFriend(CreatorPawn)
			&& AnimalController(CreatorPawn.Controller) != None
			&& AnimalController(CreatorPawn.Controller).Attacker != None
			&& AnimalController(CreatorPawn.Controller).Attacker != Hero
			&& !AnimalController(CreatorPawn.Controller).Attacker.bPlayerIsFriend
			&& AnimalController(CreatorPawn.Controller).Attacker.Health > 0)
		{
			SetAttacker(AnimalController(CreatorPawn.Controller).Attacker); 
			GotoStateSave('AttackTarget');
			return;
		}
	}

	DangerPos = blipLoc;

	if(dangerhere.default.bCreatorIsAttacker
		&& MyPawn.bGunCrazy
		&& dangerhere != class'AnimalAttackMarker'
		&& CreatorPawn != None)
	// If we're insane, go attack them just for making a bad noise
	{
		SetAttacker(CreatorPawn); 
		GotoStateSave('AttackTarget');
	}
	else
		BarkOrStare(CreatorPawn);

	StateChange=1;
	return;
}

