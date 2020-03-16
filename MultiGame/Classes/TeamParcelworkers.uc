class TeamParcelworkers extends MpTeamInfo;

defaultproperties
{
	TeamName="The Parcelworkers"
	TeamDescription="[Description removed by order of Liebowitz, Liebowitz, Zachary, Milhouse, Crock, Barnes, Smith, Shlomo, Perez, Lipshitz, Woskowykz, Bluto, Bartholomew, Pomoganate, Smith, Sass, Etcetera, Etcetera & Associates Law firm]"

	TeamIcon=texture'Mp_Teams.icon_parcelworker'
	TeamTexture=texture'Mp_Teams.flag_parcelworker'
	TeamTextureNoMips=texture'Mp_Teams.flag_parcelworker_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamParcelworkersWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamParcelworkersScore'

	DefaultPlayerClass=class'MultiStuff.MpParcelworker'

	AllowedTeamMembers(0)=class'MultiStuff.MpParcelworker'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntryDefault
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworkerx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'ParcelworkerRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry0
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry1
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry2
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry3
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry4
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry5
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry6
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry7
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry8
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry9
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry10
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry11
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry12
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry13
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry14
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=ParcelworkerRosterEntry15
		PawnClass=class'MultiStuff.MpParcelworker'
		PlayerName="Parcelworker16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'ParcelworkerRosterEntry0',RosterEntry'ParcelworkerRosterEntry1',RosterEntry'ParcelworkerRosterEntry2',RosterEntry'ParcelworkerRosterEntry3',RosterEntry'ParcelworkerRosterEntry4',RosterEntry'ParcelworkerRosterEntry5',RosterEntry'ParcelworkerRosterEntry6',RosterEntry'ParcelworkerRosterEntry7',RosterEntry'ParcelworkerRosterEntry8',RosterEntry'ParcelworkerRosterEntry9',RosterEntry'ParcelworkerRosterEntry10',RosterEntry'ParcelworkerRosterEntry11',RosterEntry'ParcelworkerRosterEntry12',RosterEntry'ParcelworkerRosterEntry13',RosterEntry'ParcelworkerRosterEntry14',RosterEntry'ParcelworkerRosterEntry15')
}