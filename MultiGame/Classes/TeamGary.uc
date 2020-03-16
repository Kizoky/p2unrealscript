class TeamGary extends MpTeamInfo;

defaultproperties
{
	TeamName="Team Gary"
	TeamDescription="And lo, the sixth seal was opened. The sun became as sackcloth and a plague of Garys descended upon the earth, devouring everything in their path until all was barren and sorrow was upon the land."

	TeamIcon=texture'Mp_Teams.icon_gary'
	TeamTexture=texture'Mp_Teams.flag_gary'
	TeamTextureNoMips=texture'Mp_Teams.flag_gary_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamGaryWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamGaryScore'

	DefaultPlayerClass=class'MultiStuff.MpGary'

	AllowedTeamMembers(0)=class'MultiStuff.MpGary'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=GaryRosterEntryDefault
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Garyx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'GaryRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=GaryRosterEntry0
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry1
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry2
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry3
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry4
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry5
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry6
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry7
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry8
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry9
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry10
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry11
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry12
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry13
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry14
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GaryRosterEntry15
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="Gary16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'GaryRosterEntry0',RosterEntry'GaryRosterEntry1',RosterEntry'GaryRosterEntry2',RosterEntry'GaryRosterEntry3',RosterEntry'GaryRosterEntry4',RosterEntry'GaryRosterEntry5',RosterEntry'GaryRosterEntry6',RosterEntry'GaryRosterEntry7',RosterEntry'GaryRosterEntry8',RosterEntry'GaryRosterEntry9',RosterEntry'GaryRosterEntry10',RosterEntry'GaryRosterEntry11',RosterEntry'GaryRosterEntry12',RosterEntry'GaryRosterEntry13',RosterEntry'GaryRosterEntry14',RosterEntry'GaryRosterEntry15')
}