class TeamDude extends MpTeamInfo;

defaultproperties
{
	TeamName="Team Dude"
	TeamDescription="Surprisingly they're not related, they all just happen to have the same brooding, disaffected, individualistic sense of style.  Go figure."

	TeamIcon=texture'Mp_Teams.icon_dude'
	TeamTexture=texture'Mp_Teams.flag_dude'
	TeamTextureNoMips=texture'Mp_Teams.flag_dude_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamDudeWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamDudeScore'

	DefaultPlayerClass=class'MultiStuff.MpDude'

	AllowedTeamMembers(0)=class'MultiStuff.MpDude'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=DudeRosterEntryDefault
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dudex"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'DudeRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=DudeRosterEntry0
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry1
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry2
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry3
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry4
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry5
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry6
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry7
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry8
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry9
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry10
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry11
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry12
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry13
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry14
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=DudeRosterEntry15
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="Dude16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'DudeRosterEntry0',RosterEntry'DudeRosterEntry1',RosterEntry'DudeRosterEntry2',RosterEntry'DudeRosterEntry3',RosterEntry'DudeRosterEntry4',RosterEntry'DudeRosterEntry5',RosterEntry'DudeRosterEntry6',RosterEntry'DudeRosterEntry7',RosterEntry'DudeRosterEntry8',RosterEntry'DudeRosterEntry9',RosterEntry'DudeRosterEntry10',RosterEntry'DudeRosterEntry11',RosterEntry'DudeRosterEntry12',RosterEntry'DudeRosterEntry13',RosterEntry'DudeRosterEntry14',RosterEntry'DudeRosterEntry15')
}