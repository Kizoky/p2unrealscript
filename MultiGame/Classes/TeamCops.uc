class TeamCops extends MpTeamInfo;

defaultproperties
{
	TeamName="The Cops"
	TeamDescription="You have the right to have the crap kicked out of you.  If you refuse that right, it'll only be more fun when we kick the crap out of you."

	TeamIcon=texture'Mp_Teams.icon_police'
	TeamTexture=texture'Mp_Teams.flag_police'
	TeamTextureNoMips=texture'Mp_Teams.flag_police_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamCopsWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamCopsScore'

	DefaultPlayerClass=class'MultiStuff.MpCop'

	AllowedTeamMembers(0)=class'MultiStuff.MpCop'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=CopRosterEntryDefault
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Copx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'CopRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=CopRosterEntry0
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry1
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry2
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry3
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry4
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry5
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry6
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry7
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry8
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry9
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry10
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry11
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry12
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry13
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry14
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=CopRosterEntry15
		PawnClass=class'MultiStuff.MpCop'
		PlayerName="Cop16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'CopRosterEntry0',RosterEntry'CopRosterEntry1',RosterEntry'CopRosterEntry2',RosterEntry'CopRosterEntry3',RosterEntry'CopRosterEntry4',RosterEntry'CopRosterEntry5',RosterEntry'CopRosterEntry6',RosterEntry'CopRosterEntry7',RosterEntry'CopRosterEntry8',RosterEntry'CopRosterEntry9',RosterEntry'CopRosterEntry10',RosterEntry'CopRosterEntry11',RosterEntry'CopRosterEntry12',RosterEntry'CopRosterEntry13',RosterEntry'CopRosterEntry14',RosterEntry'CopRosterEntry15')
}