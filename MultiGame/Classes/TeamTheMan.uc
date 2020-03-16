class TeamTheMan extends MpTeamInfo;

defaultproperties
{
	TeamName="The Man"
	TeamDescription="Now keeping EVERYBODY down."
	bHighlyHomogeneous=false

	TeamIcon=texture'Mp_Teams.icon_theman'
	TeamTexture=texture'Mp_Teams.flag_theman'
	TeamTextureNoMips=texture'Mp_Teams.flag_theman_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamTheManWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamTheManScore'

	DefaultPlayerClass=class'MultiStuff.MpCop'

	AllowedTeamMembers(0)=class'MultiStuff.MpCop'
	AllowedTeamMembers(1)=class'MultiStuff.MpSWAT'
	AllowedTeamMembers(2)=class'MultiStuff.MpMilitary'
	AllowedTeamMembers(3)=None

    Begin Object Class=RosterEntry Name=TheManRosterEntryDefault
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="MpCopx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'TheManRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=TheManRosterEntry0
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry1
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry2
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry3
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry4
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry5
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry6
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry7
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry8
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry9
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry10
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry11
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry12
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry13
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry14
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=TheManRosterEntry15
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="TheMan16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'TheManRosterEntry0',RosterEntry'TheManRosterEntry1',RosterEntry'TheManRosterEntry2',RosterEntry'TheManRosterEntry3',RosterEntry'TheManRosterEntry4',RosterEntry'TheManRosterEntry5',RosterEntry'TheManRosterEntry6',RosterEntry'TheManRosterEntry7',RosterEntry'TheManRosterEntry8',RosterEntry'TheManRosterEntry9',RosterEntry'TheManRosterEntry10',RosterEntry'TheManRosterEntry11',RosterEntry'TheManRosterEntry12',RosterEntry'TheManRosterEntry13',RosterEntry'TheManRosterEntry14',RosterEntry'TheManRosterEntry15')
}