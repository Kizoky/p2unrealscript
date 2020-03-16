class TeamFanatics extends MpTeamInfo;

defaultproperties
{
	TeamName="The Taliban"
	TeamDescription="They're about to slap a Fatwa on your infidel ass SO BIG that your whole town will drown in a sea of their own blood.  Not to be confused with The Zealots."

	TeamIcon=texture'Mp_Teams.icon_fanatic'
	TeamTexture=texture'Mp_Teams.flag_fanatic'
	TeamTextureNoMips=texture'Mp_Teams.flag_fanatic_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamFanaticsWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamFanaticsScore'

	DefaultPlayerClass=class'MultiStuff.MpFanatic'

	AllowedTeamMembers(0)=class'MultiStuff.MpFanatic'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=FanaticRosterEntryDefault
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Talibanx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'FanaticRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=FanaticRosterEntry0
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry1
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry2
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry3
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry4
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry5
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry6
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry7
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry8
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry9
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry10
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry11
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry12
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry13
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry14
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=FanaticRosterEntry15
		PawnClass=class'MultiStuff.MpFanatic'
		PlayerName="Taliban16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'FanaticRosterEntry0',RosterEntry'FanaticRosterEntry1',RosterEntry'FanaticRosterEntry2',RosterEntry'FanaticRosterEntry3',RosterEntry'FanaticRosterEntry4',RosterEntry'FanaticRosterEntry5',RosterEntry'FanaticRosterEntry6',RosterEntry'FanaticRosterEntry7',RosterEntry'FanaticRosterEntry8',RosterEntry'FanaticRosterEntry9',RosterEntry'FanaticRosterEntry10',RosterEntry'FanaticRosterEntry11',RosterEntry'FanaticRosterEntry12',RosterEntry'FanaticRosterEntry13',RosterEntry'FanaticRosterEntry14',RosterEntry'FanaticRosterEntry15')
}