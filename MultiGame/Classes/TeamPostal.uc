class TeamPostal extends MpTeamInfo;

defaultproperties
{
	TeamName="Team Postal"
	TeamDescription="All your favorites together again for the first time.  Gene-boosted."
	bHighlyHomogeneous=false

	TeamIcon=texture'Mp_Teams.icon_postal'
	TeamTexture=texture'Mp_Teams.flag_postal'
	TeamTextureNoMips=texture'Mp_Teams.flag_postal_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamPostalWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamPostalScore'

	DefaultPlayerClass=class'MultiStuff.MpDude'

	AllowedTeamMembers(0)=class'MultiStuff.MpDude'
	AllowedTeamMembers(1)=class'MultiStuff.MpGimp'
	AllowedTeamMembers(2)=class'MultiStuff.MpGary'
	AllowedTeamMembers(3)=class'MultiStuff.MpPriest'
	AllowedTeamMembers(4)=class'MultiStuff.MpUncleDave'
	AllowedTeamMembers(5)=None

    Begin Object Class=RosterEntry Name=PostalRosterEntryDefault
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]DudeX"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'PostalRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=PostalRosterEntry0
		PawnClass=class'MultiStuff.MpGimp'
		PlayerName="[Postal]Gimp"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry1
		PawnClass=class'MultiStuff.MpGary'
		PlayerName="[Postal2]Gary"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry2
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="[Postal]Priest"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry3
		PawnClass=class'MultiStuff.MpUncleDave'
		PlayerName="[Postal]UncleDave"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry4
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry5
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry6
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry7
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry8
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry9
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry10
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry11
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry12
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry13
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry14
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PostalRosterEntry15
		PawnClass=class'MultiStuff.MpDude'
		PlayerName="[Postal]Dude16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'PostalRosterEntry0',RosterEntry'PostalRosterEntry1',RosterEntry'PostalRosterEntry2',RosterEntry'PostalRosterEntry3',RosterEntry'PostalRosterEntry4',RosterEntry'PostalRosterEntry5',RosterEntry'PostalRosterEntry6',RosterEntry'PostalRosterEntry7',RosterEntry'PostalRosterEntry8',RosterEntry'PostalRosterEntry9',RosterEntry'PostalRosterEntry10',RosterEntry'PostalRosterEntry11',RosterEntry'PostalRosterEntry12',RosterEntry'PostalRosterEntry13',RosterEntry'PostalRosterEntry14',RosterEntry'PostalRosterEntry15')
}