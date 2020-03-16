class xDMRoster extends DMRoster;

defaultproperties
{
	TeamName="All Characters"
	TeamDescription="This is the default roster and it includes all the multiplayer characters."

	DefaultPlayerClass=class'MultiStuff.MpDude'

	AllowedTeamMembers(0)=class'MultiStuff.MpBandmember'
	AllowedTeamMembers(1)=class'MultiStuff.MpBum'
	AllowedTeamMembers(2)=class'MultiStuff.MpButcher'
	AllowedTeamMembers(3)=class'MultiStuff.MpCop'
	AllowedTeamMembers(4)=class'MultiStuff.MpDude'
	AllowedTeamMembers(5)=class'MultiStuff.MpFanatic'
	AllowedTeamMembers(6)=class'MultiStuff.MpGary'
	AllowedTeamMembers(7)=class'MultiStuff.MpGimp'
	AllowedTeamMembers(8)=class'MultiStuff.MpHabib'
	AllowedTeamMembers(9)=class'MultiStuff.MpMilitary'
	AllowedTeamMembers(10)=class'MultiStuff.MpParcelworker'
	AllowedTeamMembers(11)=class'MultiStuff.MpPriest'
	AllowedTeamMembers(12)=class'MultiStuff.MpRedneck'
	AllowedTeamMembers(13)=class'MultiStuff.MpRobber'
	AllowedTeamMembers(14)=class'MultiStuff.MpSWAT'
	AllowedTeamMembers(15)=class'MultiStuff.MpUncleDave'
	AllowedTeamMembers(16)=class'MultiStuff.MpRWSVince'
	AllowedTeamMembers(17)=class'MultiStuff.MpRWSMikeJ'
	AllowedTeamMembers(18)=class'MultiStuff.MpRWSMike'
	AllowedTeamMembers(19)=class'MultiStuff.MpRWSSteve'
	AllowedTeamMembers(20)=class'MultiStuff.MpRWSNathan'
	AllowedTeamMembers(21)=class'MultiStuff.MpRWSBryan'
	AllowedTeamMembers(22)=class'MultiStuff.MpRWSGeoff'
	AllowedTeamMembers(23)=class'MultiStuff.MpRWSJosh'
	AllowedTeamMembers(24)=class'MultiStuff.MpRWSTimb'
	AllowedTeamMembers(25)=None

    Begin Object Class=RosterEntry Name=DMRosterEntryDefault
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Grunt"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'DMRosterEntryDefault'

    Begin Object Class=RosterEntry Name=DMRosterEntry0
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="BandGuy"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry1
		PawnClass=class'MultiStuff.MpBum'
		PlayerName="Bum"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry2
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry3
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry4
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry5
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Fanatic"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry6
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry7
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry8
		PawnClass=class'MultiStuff.MpHabib'
		PlayerName="Habib"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry9
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry10
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry11
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Priest"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry12
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DMRosterEntry13
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object

    Begin Object Class=RosterEntry Name=DMRosterEntry14
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object

    Begin Object Class=RosterEntry Name=DMRosterEntry15
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'DMRosterEntry0',RosterEntry'DMRosterEntry1',RosterEntry'DMRosterEntry2',RosterEntry'DMRosterEntry3',RosterEntry'DMRosterEntry4',RosterEntry'DMRosterEntry5',RosterEntry'DMRosterEntry6',RosterEntry'DMRosterEntry7',RosterEntry'DMRosterEntry8',RosterEntry'DMRosterEntry9',RosterEntry'DMRosterEntry10',RosterEntry'DMRosterEntry11',RosterEntry'DMRosterEntry12',RosterEntry'DMRosterEntry13',RosterEntry'DMRosterEntry14',RosterEntry'DMRosterEntry15')
}