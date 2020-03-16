class TeamGimp extends MpTeamInfo;

defaultproperties
{
	TeamName="Team Gimp"
	TeamDescription="The sharp patina of vinyl, soothed by the subtle bouquet of talc. An Intoxication of the Senses, Gene-Boosted.  A man in leather invests himself with water sports. People around him respond accordingly.  Pirates know this. Porn stars and U-boat captains know it. And the French, in their own way, know it, too."

	TeamIcon=texture'Mp_Teams.icon_gimp'
	TeamTexture=texture'Mp_Teams.flag_gimp'
	TeamTextureNoMips=texture'Mp_Teams.flag_gimp_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamGimpWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamGimpScore'

	DefaultPlayerClass=class'MultiStuff.MpGimp'

	AllowedTeamMembers(0)=class'MultiStuff.MpGimp'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=GimpRosterEntryDefault
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimpx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'GimpRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=GimpRosterEntry0
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry1
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry2
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry3
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry4
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry5
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry6
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry7
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry8
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry9
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry10
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry11
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry12
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry13
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry14
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=GimpRosterEntry15
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="Gimp16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'GimpRosterEntry0',RosterEntry'GimpRosterEntry1',RosterEntry'GimpRosterEntry2',RosterEntry'GimpRosterEntry3',RosterEntry'GimpRosterEntry4',RosterEntry'GimpRosterEntry5',RosterEntry'GimpRosterEntry6',RosterEntry'GimpRosterEntry7',RosterEntry'GimpRosterEntry8',RosterEntry'GimpRosterEntry9',RosterEntry'GimpRosterEntry10',RosterEntry'GimpRosterEntry11',RosterEntry'GimpRosterEntry12',RosterEntry'GimpRosterEntry13',RosterEntry'GimpRosterEntry14',RosterEntry'GimpRosterEntry15')
}