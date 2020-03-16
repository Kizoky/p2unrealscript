class TeamZealots extends MpTeamInfo;

defaultproperties
{
	TeamName="The Zealots"
	TeamDescription="They're NOT zealots, and they'll blow up the house of anyone who says different."

	TeamIcon=texture'Mp_Teams.icon_Zealot'
	TeamTexture=texture'Mp_Teams.flag_Zealot'
	TeamTextureNoMips=texture'Mp_Teams.flag_Zealot_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamZealotsWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamZealotsScore'

	DefaultPlayerClass=class'MultiStuff.MpUncleDave'

	AllowedTeamMembers(0)=class'MultiStuff.MpUncleDave'
	AllowedTeamMembers(1)=class'MultiStuff.MpUncleDave'
	AllowedTeamMembers(2)=None

    Begin Object Class=RosterEntry Name=ZealotRosterEntryDefault
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealotx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'ZealotRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=ZealotRosterEntry0
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="UncleDave1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry1
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry2
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry3
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry4
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry5
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry6
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry7
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry8
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry9
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry10
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry11
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry12
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry13
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry14
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ZealotRosterEntry15
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="Zealot16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'ZealotRosterEntry0',RosterEntry'ZealotRosterEntry1',RosterEntry'ZealotRosterEntry2',RosterEntry'ZealotRosterEntry3',RosterEntry'ZealotRosterEntry4',RosterEntry'ZealotRosterEntry5',RosterEntry'ZealotRosterEntry6',RosterEntry'ZealotRosterEntry7',RosterEntry'ZealotRosterEntry8',RosterEntry'ZealotRosterEntry9',RosterEntry'ZealotRosterEntry10',RosterEntry'ZealotRosterEntry11',RosterEntry'ZealotRosterEntry12',RosterEntry'ZealotRosterEntry13',RosterEntry'ZealotRosterEntry14',RosterEntry'ZealotRosterEntry15')
}