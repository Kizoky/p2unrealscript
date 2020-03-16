class TeamButchers extends MpTeamInfo;

defaultproperties
{
	TeamName="The Butchers"
	TeamDescription="Actually they're 'Slaughterers', a distinction they're very sensitive about.  That's why they call themselves 'The Butchers', because it really pisses them off.  Considering what they do for a living, you'd definitely rather they not be pissed off."

	TeamIcon=texture'Mp_Teams.icon_Butcher'
	TeamTexture=texture'Mp_Teams.flag_Butcher'
	TeamTextureNoMips=texture'Mp_Teams.flag_Butcher_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamButchersWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamButchersScore'

	DefaultPlayerClass=class'MultiStuff.MpButcher'

	AllowedTeamMembers(0)=class'MultiStuff.MpButcher'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=ButcherRosterEntryDefault
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcherx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'ButcherRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=ButcherRosterEntry0
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry1
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry2
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry3
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry4
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry5
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry6
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry7
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry8
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry9
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry10
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry11
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry12
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry13
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry14
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ButcherRosterEntry15
		PawnClass=class'MultiStuff.MpButcher'
		PlayerName="Butcher16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'ButcherRosterEntry0',RosterEntry'ButcherRosterEntry1',RosterEntry'ButcherRosterEntry2',RosterEntry'ButcherRosterEntry3',RosterEntry'ButcherRosterEntry4',RosterEntry'ButcherRosterEntry5',RosterEntry'ButcherRosterEntry6',RosterEntry'ButcherRosterEntry7',RosterEntry'ButcherRosterEntry8',RosterEntry'ButcherRosterEntry9',RosterEntry'ButcherRosterEntry10',RosterEntry'ButcherRosterEntry11',RosterEntry'ButcherRosterEntry12',RosterEntry'ButcherRosterEntry13',RosterEntry'ButcherRosterEntry14',RosterEntry'ButcherRosterEntry15')
}