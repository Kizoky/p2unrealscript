class UBrowserGSpyFact extends UBrowserServerListFactory;

var UBrowserGSpyLink Link;

var() config string		MasterServerAddress;	// Address of the master server
var() config int		MasterServerTCPPort;	// Optional port that the master server is listening on
var() config int 		ServerRegion;			// Region of the game server
var() config int		MasterServerTimeout;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	Super.Query(bBySuperset, bInitial);

	Link = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserGSpyLink');

	Link.MasterServerAddress = MasterServerAddress;
	Link.MasterServerTCPPort = MasterServerTCPPort;
	Link.ServerRegion = ServerRegion;
	Link.MasterServerTimeout = MasterServerTimeout;
	Link.OwnerFactory = Self;
	Link.Start();
}

function QueryFinished(bool bSuccess, optional string ErrorMsg)
{
	Link.Destroy();
	Link = None;

	Super.QueryFinished(bSuccess, ErrorMsg);	
}

function Shutdown(optional bool bBySuperset)
{
	if(Link != None)
		Link.Destroy();
	Link = None;
	Super.Shutdown(bBySuperset);
}

defaultproperties
{
	MasterServerAddress=""
	ServerRegion=0
	MasterServerTCPPort=28900
	MasterServerTimeout=10
}