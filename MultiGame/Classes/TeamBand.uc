class TeamBand extends MpTeamInfo;

defaultproperties
{
	TeamName="The Band"
	TeamDescription="When not selling fudge bars to fund their drunken Band Camp trips, these gene-boosted Liberaces of bloodsport practice their skillz relentlessly.  They MUST be badasses to run around in uniforms like THOSE..."

	TeamIcon=texture'Mp_Teams.icon_band'
	TeamTexture=texture'Mp_Teams.flag_band'
	TeamTextureNoMips=texture'Mp_Teams.flag_band_nm'
	TeamWinSound=sound'MpAnnouncer.AnnouncerTeamBandWin'
	TeamScoreSound=sound'MpAnnouncer.AnnouncerTeamBandScore'

	DefaultPlayerClass=class'MultiStuff.MpBandmember'

	AllowedTeamMembers(0)=class'MultiStuff.MpBandmember'
	AllowedTeamMembers(1)=None

    Begin Object Class=RosterEntry Name=BandRosterEntryDefault
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Bandx"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
	DefaultRosterEntry=RosterEntry'BandRosterEntryDefault'
 
	Begin Object Class=RosterEntry Name=BandRosterEntry0
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band1"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry1
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band2"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry2
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band3"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry3
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band4"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry4
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band5"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry5
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band6"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry6
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band7"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry7
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band8"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry8
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band9"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry9
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band10"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry10
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band11"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry11
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band12"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry12
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band13"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry13
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band14"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry14
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band15"
		Orders=ORDERS_Defend
		SquadNumber=0
		bTaken=false
    End Object
    Begin Object Class=RosterEntry Name=BandRosterEntry15
		PawnClass=class'MultiStuff.MpBandmember'
		PlayerName="Band16"
		Orders=ORDERS_Attack
		SquadNumber=0
		bTaken=false
    End Object

	Roster=(RosterEntry'BandRosterEntry0',RosterEntry'BandRosterEntry1',RosterEntry'BandRosterEntry2',RosterEntry'BandRosterEntry3',RosterEntry'BandRosterEntry4',RosterEntry'BandRosterEntry5',RosterEntry'BandRosterEntry6',RosterEntry'BandRosterEntry7',RosterEntry'BandRosterEntry8',RosterEntry'BandRosterEntry9',RosterEntry'BandRosterEntry10',RosterEntry'BandRosterEntry11',RosterEntry'BandRosterEntry12',RosterEntry'BandRosterEntry13',RosterEntry'BandRosterEntry14',RosterEntry'BandRosterEntry15')
}