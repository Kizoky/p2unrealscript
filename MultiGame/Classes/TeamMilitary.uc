class TeamMilitary extends MpTeamInfo;

defaultproperties
{
	TeamName="The Military"
	TeamDescription="Kicking the surrender fries right out of every enemy combatant's face for Uncle SAm!  They redefine FUN while leaving the spelling essentially the same."

	TeamIcon=texture'Mp_Teams.icon_military'
	TeamTexture=texture'Mp_Teams.flag_military'
	TeamTextureNoMips=texture'Mp_Teams.flag_military_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamMilitaryWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamMilitaryScore'

	DefaultPlayerClass=class'MultiStuff.MpMilitary'

	AllowedTeamMembers(0)=class'MultiStuff.MpMilitary'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=MilitaryRosterEntryDefault
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Militaryx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'MilitaryRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=MilitaryRosterEntry0
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry1
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry2
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry3
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry4
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry5
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry6
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry7
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry8
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry9
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry10
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry11
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry12
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry13
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry14
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=MilitaryRosterEntry15
		PawnClass=class'MultiStuff.MpMilitary'
		PlayerName="Military16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'MilitaryRosterEntry0',RosterEntry'MilitaryRosterEntry1',RosterEntry'MilitaryRosterEntry2',RosterEntry'MilitaryRosterEntry3',RosterEntry'MilitaryRosterEntry4',RosterEntry'MilitaryRosterEntry5',RosterEntry'MilitaryRosterEntry6',RosterEntry'MilitaryRosterEntry7',RosterEntry'MilitaryRosterEntry8',RosterEntry'MilitaryRosterEntry9',RosterEntry'MilitaryRosterEntry10',RosterEntry'MilitaryRosterEntry11',RosterEntry'MilitaryRosterEntry12',RosterEntry'MilitaryRosterEntry13',RosterEntry'MilitaryRosterEntry14',RosterEntry'MilitaryRosterEntry15')
}