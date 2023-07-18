///////////////////////////////////////////////////////////////////////////////
// RadarInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Radar inventory item.
//
// Radar used to show other people right around you (through walls, terrain)
// It looks like a fish finder.
//
// In SP it finds anyone on your floor (in a building) around you, moving or not.
//
// In MP it finds anyone, all the time, but only if they're moving.
//
///////////////////////////////////////////////////////////////////////////////

class RadarInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var float TimeSlice;		// How long a 'unit' of radar lasts when the radar is on.
var float BringupTime;
var float PoweringupTime;		// How long it takes to start up and cool down
var float PoweringdownTime;
var travel bool bOperating;	// Use this to know if, after a level transition, we should
							// automatically turn back on
var int		TimeMod;		// Every time this goes over BEEP_TIME, you make a noise
							// in MP to balance the power of the radar
var Sound BeepSound;		// Noise you make as you use the radar so it sort of let's
							// others close by know that you're using it.



const BEEP_TIME			= 4;

const PULSE_CHANGE		= 100;
const PULSE_MAX			= 80;

replication
{
	reliable if(Role == ROLE_Authority)
		ClientGotoState, ClientPulseRadar, ClientDropFrom;
}

///////////////////////////////////////////////////////////////////////////////
// If we were on before, and we transfered between levels, turn back on now.
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	Super.TravelPostAccept();
	
	// xPatch: No need to show amount in nightmare mode (it's infinite)
	if(P2GameInfoSingle(Level.Game).InNightmareMode()
		&& !P2GameInfoSingle(Level.Game).InVeteranMode())
		bDisplayAmount = False;	

	if(Amount <= 0)
		UsedUp();
	else if(bOperating)
		GotoState('TravelStartup');
}

///////////////////////////////////////////////////////////////////////////////
// Server uses this to force client into NewState
///////////////////////////////////////////////////////////////////////////////
simulated function ClientGotoState(name NewState, optional name NewLabel)
{
	if(Role != ROLE_Authority)
	    GotoState(NewState,NewLabel);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PickupFunction(Pawn Other)
{
	Super.PickupFunction(Other);

	// Autoactivate in grab bag games only
	if (GrabBagGame(Level.Game) != None) 
	{
		Amount = 1; // don't need any more than this since it's infinite
		Activate();
	}
	
	// xPatch: No need to show amount in nightmare mode (it's infinite)
	if(P2GameInfoSingle(Level.Game).InNightmareMode() 
		&& !P2GameInfoSingle(Level.Game).InVeteranMode())
		bDisplayAmount = False;	
}

///////////////////////////////////////////////////////////////////////////////
// Check to turn it on
///////////////////////////////////////////////////////////////////////////////
simulated function Activate()
{
	TurnOffHints();

	if(Amount == 0)
		UsedUp();
	else
	{
		// Kamek 4-22
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(Instigator.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Instigator.Controller),'Fishy');
		GotoState('Poweringup');
		ClientGotoState('Poweringup');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Only in MP does the radar work backwards. Most of the time it's more efficient
// to have the pawn do it (in SP games) but here it's easier from this direction
// in MP games.
///////////////////////////////////////////////////////////////////////////////
simulated function FindPlayersEtc()
{
	local P2Pawn checkpawn;
	local P2Player p2p;
	local MpPlayer mpp;
	local FlavinPickup fp;
	local FlavinMesh fm;
	local int i;

	if(Instigator != None
		&& Instigator.Health > 0
		&& PlayerController(Instigator.Controller) != None
		&& (Role < ROLE_Authority
			|| (Level.NetMode == NM_ListenServer
				&& Role == ROLE_Authority
				&& ViewPort(PlayerController(Instigator.Controller).Player) != None)))
	{
		p2p = P2Player(Instigator.Controller);

		if(p2p != None)
		{
			// Get pawns first
			if(p2p.RadarPawns.Length > 0)
				p2p.RadarPawns.Remove(0, p2p.RadarPawns.Length);

			foreach DynamicActors(class'P2Pawn', checkpawn)
			{
				// If not me
				if(checkpawn != Instigator
					// if still alive (and not dying)
					&& checkpawn.Health > 0
					&& !checkpawn.bDeleteMe
					// and he's moving
					&& VSize(checkpawn.Velocity) > 0)
				{
					// Record them for the radar (players and NPCs)
					p2p.RadarPawns.Insert(p2p.RadarPawns.Length, 1.0);
					p2p.RadarPawns[p2p.RadarPawns.Length-1] = checkpawn;
				}
			}

			mpp = MpPlayer(p2p);
			if(mpp != None)
			{
				// check for flavin
				if(mpp.FlavinSpots.Length > 0)
					mpp.FlavinSpots.Remove(0, mpp.FlavinSpots.Length);
				foreach DynamicActors(class'FlavinPickup', fp)
				{
					// Only record bags that aren't hidden (ready to be picked up)
					if(!fp.bHidden)
					{
						// Record them for the radar
						mpp.FlavinSpots.Insert(mpp.FlavinSpots.Length, 1.0);
						mpp.FlavinSpots[mpp.FlavinSpots.Length-1] = fp.Location;
						i++;
					}
				}
				// check for pawns carrying flavin
				if(mpp.FlavinPawns.Length > 0)
					mpp.FlavinPawns.Remove(0, mpp.FlavinPawns.Length);
				foreach DynamicActors(class'FlavinMesh', fm)
				{
					// Check for meshes with their owners-record the owners
					if(fm.Owner != None)
					{
						// Record them for the radar
						mpp.FlavinPawns.Insert(mpp.FlavinPawns.Length, 1.0);
						mpp.FlavinPawns[mpp.FlavinPawns.Length-1] = MpPawn(fm.Owner);
						i++;
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make it glow bright then lower again
///////////////////////////////////////////////////////////////////////////////
simulated function ClientPulseRadar()
{
	P2Player(Instigator.Controller).PulseGlowChange=PULSE_CHANGE;
	P2Player(Instigator.Controller).PulseGlow=1;
}

///////////////////////////////////////////////////////////////////////////////
// Getting ready to turn off
///////////////////////////////////////////////////////////////////////////////
simulated state Poweringup
{
	ignores Activate;
Begin:
	// fix for nightmare mode cinematic - wait until player possesses the pawn
	if(Instigator != None && P2Player(Instigator.Controller) == None)
	{
		Sleep(1.0);
		Goto('Begin');
	}
	
	FindPlayersEtc();
	bOperating=true;
	if(Instigator != None && P2Player(Instigator.Controller) != None)
		P2Player(Instigator.Controller).BringupRadar();
	Sleep(BringupTime);
	if(Instigator != None && P2Player(Instigator.Controller) != None)
		P2Player(Instigator.Controller).WarmupRadar();
	Sleep(PoweringupTime);

	GotoState('Operating');
}
///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
simulated state Operating
{
	///////////////////////////////////////////////////////////////////////////////
	// Only pulse in MP games
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		local P2Player p2p;

		if(Instigator != None)
		{
			p2p = P2Player(Instigator.Controller);
			if(p2p != None)
			{
				// Only do this in MP games but not on dedicated servers (clients and listen servers)
				if((Level.Game == None
						|| (!Level.Game.bIsSinglePlayer
							&& Level.NetMode != NM_DedicatedServer))
					&& p2p.PulseGlowChange != 0)
				{
			
					p2p.PulseGlow+=p2p.PulseGlowChange*DeltaTime;

					if(p2p.PulseGlow > PULSE_MAX)
					{
						p2p.PulseGlow = PULSE_MAX;
						p2p.PulseGlowChange = -PULSE_CHANGE;
					}
					else if(p2p.PulseGlow <= 0)
					{
						p2p.PulseGlow = 0;
						p2p.PulseGlowChange = 0;
					}
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Turn it back off
	///////////////////////////////////////////////////////////////////////////////
	function Activate()
	{
		GotoState('Poweringdown');
		ClientGotoState('Poweringdown');
	}
	function BeginState()
	{
	}
Begin:
	if(Amount > 0)
	{
		if(Instigator != None 
			&& P2Player(Instigator.Controller) != None)
		{
			if(P2Player(Instigator.Controller).BoostRadar(Amount))
			{
				FindPlayersEtc();
				// Every so often, make a beeping noise in MP, so you can hint to other
				// players that this guy has radar
				if(Level.Game != None
					&& !Level.Game.bIsSinglePlayer)
				{
					TimeMod++;
					if(TimeMod >= BEEP_TIME)
					{
						// Don't make noise becuase it's annoying and everyone already has radar so it's even
						if (GrabBagGame(Level.Game) == None) 
							Instigator.PlaySound(BeepSound, SLOT_Misc, 1.0,,TransientSoundRadius);
						ClientPulseRadar();
						TimeMod = 0;
					}
				}

				// Don't use juice in grab bag--unlimited
				// Don't use in Nightmare either
				if (GrabBagGame(Level.Game) == None
					&& !P2GameInfoSingle(Level.Game).InNightmareMode() 
					|| P2GameInfoSingle(Level.Game).InVeteranMode())
					ReduceAmount(1,,,,true);	// For each TimeSlice, it uses on radarinv unit
			}
		}
Waiting:
		Sleep(TimeSlice);
		Goto('Begin');
	}
	else
		GotoState('Poweringdown');
}

///////////////////////////////////////////////////////////////////////////////
// Getting ready to turn off
///////////////////////////////////////////////////////////////////////////////
simulated state Poweringdown
{
	ignores Activate;
Begin:
	bOperating=false;
	if(Instigator != None && P2Player(Instigator.Controller) != None)
		P2Player(Instigator.Controller).DropDownRadar();
	Sleep(TimeSlice);
	if(Instigator != None && P2Player(Instigator.Controller) != None)
		P2Player(Instigator.Controller).ShutoffRadar();

	if(Amount == 0)
		UsedUp();

	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// TravelStartup: Wait a moment to get going again after a level travel to
// ensure the gamestate is active.
///////////////////////////////////////////////////////////////////////////////
state TravelStartup
{
Begin:
	Sleep(0.5);

	// If it's the first day of a level, turn off our radar
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& P2GameInfoSingle(Level.Game).TheGameState.bFirstLevelOfDay)
	{
		bOperating=false;
		GotoState('');
	}
	else // Start up the radar on level travel
		Activate();
}

///////////////////////////////////////////////////////////////////////////////
// clean up after tossing this item out.
///////////////////////////////////////////////////////////////////////////////
simulated function ClientDropFrom()
{
	// If your item gets taken, turn off radar early
	bOperating=false;
	if(Instigator != None && P2Player(Instigator.Controller) != None)
		P2Player(Instigator.Controller).ShutoffRadar();
}

///////////////////////////////////////////////////////////////////////////////
// Toss this item out.
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	// Don't drop radars on grab bag levels becuase everyone starts with them 
	// and has infinite amounts of radar so it's fine.
	if(GrabBagGame(Level.Game) == None
		&& Instigator.Health > 0)
	{
		ClientDropFrom();
		// If your item gets taken, turn off radar early
		bOperating=false;
		if(Instigator != None && P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).ShutoffRadar();

		Super.DropFrom(StartLocation);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	bOperating=false;
	if(Instigator != None && P2Player(Instigator.Controller) != None)
		P2Player(Instigator.Controller).ShutoffRadar();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bReplicateInstigator=true
	PickupClass=class'RadarPickup'
	Icon=Texture'Hudpack.icons.icon_inv_Bass_Sniffer'
	InventoryGroup=101
	GroupOffset=6
	PowerupName="Bass Sniffer"
	PowerupDesc="Maybe it can find more than just bass..."
	ExamineAnimType="Letter"
	ExamineDialog=Sound'DudeDialog.dude_ithinkineedthat'
	PoweringupTime=1.0
	BringupTime=1.0
	TimeSlice=1.0
	PoweringdownTime=1.0
	bThrowIndividually=false
	Hint1="Press %KEY_InventoryActivate% to turn radar on and off."
	Hint2="Maybe it can find more than just fish."
	BeepSound=Sound'MpSounds.radar.radarping'
	TransientSoundRadius=100.0
	}
