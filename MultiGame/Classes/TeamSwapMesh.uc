///////////////////////////////////////////////////////////////////////////////
// TeamSwapMesh
//
// In ctf, waits till the team flag texture is replicated, then it goes through
// it's textures and swap the one placeholder for the new team that it represents
//
// Skins must be filled out before this will work!
// Put the dummy texture for blue for instance, and put it on the static mesh
// somewhere, using the Skins array. This will then replace that with the texture
// for the team that is the 'blue' team.
///////////////////////////////////////////////////////////////////////////////

class TeamSwapMesh extends Prop
	notplaceable;

var() bool bRed;			// if you're red or blue

const SWAP_INDEX = 0;		// always this index that we put the flag texture into
							// client doesn't know about any changed variables in the editor
							// so we must extend this class with red/blue and put things in default properties.
const WAIT_TIME = 1.0;		// how often we try (waiting on rep team info)

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Waiting
{
	///////////////////////////////////////////////////////////////////////////////
	// Check to see if the teams have been replicated yet, if so, swap textures
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		local int i;
		local GameReplicationInfo gri;
		local P2Player p2p;

		if(Level.NetMode != NM_DedicatedServer)
		{
			foreach DynamicActors(class'P2Player', p2p)
			{
				if(Viewport(p2p.Player) != None
					&& p2p.GameReplicationInfo != None
					&& gri == None)
					gri = p2p.GameReplicationInfo;
			}
			if(gri != None
				&& gri.Teams[0] != None
				&& gri.Teams[1] != None
				&& MPTeamInfo(gri.Teams[0]).TeamTexture != None)
			{
				// if you find the matching team texture, replace it with the correct team texture
				if(bRed)
					Skins[SWAP_INDEX] = MPTeamInfo(gri.Teams[0]).TeamTexture;
				else
					Skins[SWAP_INDEX] = MPTeamInfo(gri.Teams[1]).TeamTexture;
				if(Level.NetMode != NM_ListenServer)
					RemoteRole=ROLE_DumbProxy;
			}
			else
				SetTimer(WAIT_TIME, false);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Begin waiting for team data
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		Timer();
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bStasis=false
	bStatic=false
	DrawType=DT_StaticMesh
	StaticMesh = StaticMesh'Zo_Timber.CTF.ctf_hangingbanner'
	bOrientOnSlope=false
	bShouldBaseAtStartup=false
	Skins[0]=None
	Skins[1]=None
	Skins[2]=None
	Skins[3]=None
	Skins[4]=None
	Skins[5]=None
	Skins[6]=None
	Skins[7]=None
	Skins[8]=None
	Skins[9]=None
}

