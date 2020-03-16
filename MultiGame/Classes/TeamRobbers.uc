class TeamRobbers extends MpTeamInfo;

defaultproperties
{
	TeamName="The Robbers"
	TeamDescription="Today they may know something, tomorrow they may know something else.  But yesterday they didn't know anything."

	TeamIcon=texture'Mp_Teams.icon_Robber'
	TeamTexture=texture'Mp_Teams.flag_Robber'
	TeamTextureNoMips=texture'Mp_Teams.flag_Robber_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamRobbersWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamRobbersScore'

	DefaultPlayerClass=class'MultiStuff.MpRobber'

	AllowedTeamMembers(0)=class'MultiStuff.MpRobber'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=RobberRosterEntryDefault
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robberx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'RobberRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=RobberRosterEntry0
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry1
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry2
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry3
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry4
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry5
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry6
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry7
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry8
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry9
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry10
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry11
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry12
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry13
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry14
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RobberRosterEntry15
		PawnClass=class'MultiStuff.MpRobber'
		PlayerName="Robber16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'RobberRosterEntry0',RosterEntry'RobberRosterEntry1',RosterEntry'RobberRosterEntry2',RosterEntry'RobberRosterEntry3',RosterEntry'RobberRosterEntry4',RosterEntry'RobberRosterEntry5',RosterEntry'RobberRosterEntry6',RosterEntry'RobberRosterEntry7',RosterEntry'RobberRosterEntry8',RosterEntry'RobberRosterEntry9',RosterEntry'RobberRosterEntry10',RosterEntry'RobberRosterEntry11',RosterEntry'RobberRosterEntry12',RosterEntry'RobberRosterEntry13',RosterEntry'RobberRosterEntry14',RosterEntry'RobberRosterEntry15')
}