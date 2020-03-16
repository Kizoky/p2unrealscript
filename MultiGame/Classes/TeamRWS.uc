class TeamRWS extends MpTeamInfo;

defaultproperties
{
	TeamName="Team RWS"
	TeamDescription="Who needs a gun when you've got hands and teeth?  -YOU do, unless you enjoy eating  Face-fulls of buckshot.  Moron."

	TeamIcon=texture'Mp_Teams.icon_rws'
	TeamTexture=texture'Mp_Teams.flag_rws'
	TeamTextureNoMips=texture'Mp_Teams.flag_rws_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamRWSWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamRWSScore'

	DefaultPlayerClass=class'MultiStuff.MpRWSVince'

	AllowedTeamMembers(0)=class'MultiStuff.MpRWSBryan'
	AllowedTeamMembers(1)=class'MultiStuff.MpRWSGeoff'
	AllowedTeamMembers(2)=class'MultiStuff.MpRWSJosh'
	AllowedTeamMembers(3)=class'MultiStuff.MpRWSMike'
	AllowedTeamMembers(4)=class'MultiStuff.MpRWSMikeJ'
	AllowedTeamMembers(5)=class'MultiStuff.MpRWSNathan'
	AllowedTeamMembers(6)=class'MultiStuff.MpRWSSteve'
	AllowedTeamMembers(7)=class'MultiStuff.MpRWSTimb'
	AllowedTeamMembers(8)=class'MultiStuff.MpRWSVince'
	AllowedTeamMembers(9)=None

    Begin Object Class=RosterEntry Name=RWSRosterEntryDefault
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWSx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'RWSRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=RWSRosterEntry0
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWS1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry1
		PawnClass=class'MultiStuff.MpRWSMikeJ'
		PlayerName="RWS2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry2
		PawnClass=class'MultiStuff.MpRWSMike'
		PlayerName="RWS3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry3
		PawnClass=class'MultiStuff.MpRWSSteve'
		PlayerName="RWS4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry4
		PawnClass=class'MultiStuff.MpRWSNathan'
		PlayerName="RWS5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry5
		PawnClass=class'MultiStuff.MpRWSBryan'
		PlayerName="RWS6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry6
		PawnClass=class'MultiStuff.MpRWSGeoff'
		PlayerName="RWS7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry7
		PawnClass=class'MultiStuff.MpRWSJosh'
		PlayerName="RWS8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry8
		PawnClass=class'MultiStuff.MpRWSTimb'
		PlayerName="RWS9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry9
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWS10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry10
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWS11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry11
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWS12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry12
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWS13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry13
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWS14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry14
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWS15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=RWSRosterEntry15
		PawnClass=class'MultiStuff.MpRWSVince'
		PlayerName="RWS16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'RWSRosterEntry0',RosterEntry'RWSRosterEntry1',RosterEntry'RWSRosterEntry2',RosterEntry'RWSRosterEntry3',RosterEntry'RWSRosterEntry4',RosterEntry'RWSRosterEntry5',RosterEntry'RWSRosterEntry6',RosterEntry'RWSRosterEntry7',RosterEntry'RWSRosterEntry8',RosterEntry'RWSRosterEntry9',RosterEntry'RWSRosterEntry10',RosterEntry'RWSRosterEntry11',RosterEntry'RWSRosterEntry12',RosterEntry'RWSRosterEntry13',RosterEntry'RWSRosterEntry14',RosterEntry'RWSRosterEntry15')
}

