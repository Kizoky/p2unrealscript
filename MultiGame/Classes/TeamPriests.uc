class TeamPriests extends MpTeamInfo;

defaultproperties
{
	TeamName="The Clergy"
	TeamDescription="Holy warriors of gene-boosted morality who'll either save you from yourself, or kill you trying.  Little does Team Gimp know that the clergy's feelings for them are considerably less than hostile."

	TeamIcon=texture'Mp_Teams.icon_priest'
	TeamTexture=texture'Mp_Teams.flag_priest'
	TeamTextureNoMips=texture'Mp_Teams.flag_priest_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamPriestsWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamPriestsScore'

	DefaultPlayerClass=class'MultiStuff.MpPriest'

	AllowedTeamMembers(0)=class'MultiStuff.MpPriest'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=PriestRosterEntryDefault
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="ClergyX"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'PriestRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=PriestRosterEntry0
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry1
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry2
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry3
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry4
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry5
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry6
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry7
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry8
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry9
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry10
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry11
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry12
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry13
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry14
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=PriestRosterEntry15
		PawnClass=class'MultiStuff.MpPriest'
		PlayerName="Clergy16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'PriestRosterEntry0',RosterEntry'PriestRosterEntry1',RosterEntry'PriestRosterEntry2',RosterEntry'PriestRosterEntry3',RosterEntry'PriestRosterEntry4',RosterEntry'PriestRosterEntry5',RosterEntry'PriestRosterEntry6',RosterEntry'PriestRosterEntry7',RosterEntry'PriestRosterEntry8',RosterEntry'PriestRosterEntry9',RosterEntry'PriestRosterEntry10',RosterEntry'PriestRosterEntry11',RosterEntry'PriestRosterEntry12',RosterEntry'PriestRosterEntry13',RosterEntry'PriestRosterEntry14',RosterEntry'PriestRosterEntry15')
}