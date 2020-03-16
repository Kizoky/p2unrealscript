class TeamRednecks extends MpTeamInfo;

defaultproperties
{
	TeamName="The Rednecks"
	TeamDescription="SuuuEEEEEEEEEEE"

	TeamIcon=texture'Mp_Teams.icon_Redneck'
	TeamTexture=texture'Mp_Teams.flag_Redneck'
	TeamTextureNoMips=texture'Mp_Teams.flag_Redneck_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamRednecksWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamRednecksScore'

	DefaultPlayerClass=class'MultiStuff.MpRedneck'

	AllowedTeamMembers(0)=class'MultiStuff.MpRedneck'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=RedneckRosterEntryDefault
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneckx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'RedneckRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=RedneckRosterEntry0
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry1
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry2
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry3
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry4
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry5
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry6
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry7
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry8
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry9
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry10
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry11
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry12
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry13
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry14
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RedneckRosterEntry15
		PawnClass=class'MultiStuff.MpRedneck'
		PlayerName="Redneck16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'RedneckRosterEntry0',RosterEntry'RedneckRosterEntry1',RosterEntry'RedneckRosterEntry2',RosterEntry'RedneckRosterEntry3',RosterEntry'RedneckRosterEntry4',RosterEntry'RedneckRosterEntry5',RosterEntry'RedneckRosterEntry6',RosterEntry'RedneckRosterEntry7',RosterEntry'RedneckRosterEntry8',RosterEntry'RedneckRosterEntry9',RosterEntry'RedneckRosterEntry10',RosterEntry'RedneckRosterEntry11',RosterEntry'RedneckRosterEntry12',RosterEntry'RedneckRosterEntry13',RosterEntry'RedneckRosterEntry14',RosterEntry'RedneckRosterEntry15')
}