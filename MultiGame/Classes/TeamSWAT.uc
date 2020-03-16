class TeamSWAT extends MpTeamInfo;

defaultproperties
{
	TeamName="Team SWAT"
	TeamDescription="Because nothing says 'victory' like not losing."

	TeamIcon=texture'Mp_Teams.icon_swat'
	TeamTexture=texture'Mp_Teams.flag_swat'
	TeamTextureNoMips=texture'Mp_Teams.flag_swat_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamSWATWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamSWATScore'

	DefaultPlayerClass=class'MultiStuff.MpSWAT'

	AllowedTeamMembers(0)=class'MultiStuff.MpSWAT'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=SwatRosterEntryDefault
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWATx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'SwatRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=SwatRosterEntry0
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry1
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry2
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry3
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry4
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry5
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry6
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry7
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry8
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry9
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry10
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry11
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry12
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry13
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry14
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=SwatRosterEntry15
		PawnClass=class'MultiStuff.MpSWAT'
		PlayerName="SWAT16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'SwatRosterEntry0',RosterEntry'SwatRosterEntry1',RosterEntry'SwatRosterEntry2',RosterEntry'SwatRosterEntry3',RosterEntry'SwatRosterEntry4',RosterEntry'SwatRosterEntry5',RosterEntry'SwatRosterEntry6',RosterEntry'SwatRosterEntry7',RosterEntry'SwatRosterEntry8',RosterEntry'SwatRosterEntry9',RosterEntry'SwatRosterEntry10',RosterEntry'SwatRosterEntry11',RosterEntry'SwatRosterEntry12',RosterEntry'SwatRosterEntry13',RosterEntry'SwatRosterEntry14',RosterEntry'SwatRosterEntry15')
}