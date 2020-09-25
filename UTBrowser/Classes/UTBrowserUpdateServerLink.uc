class UTBrowserUpdateServerLink extends UBrowserUpdateServerLink;

function SetupURIs()
{
	// local string Type;

	// if(Level.IsDemoBuild())
		// Type = "Demo";

	MaxURI = 3;
	URIs[3] = "/p2mp/p2_motd.html";
	URIs[2] = "/p2mp/p2_motdfallback.html";
	URIs[1] = "/p2mp/p2_masterserver.txt";
	URIs[0] = "/p2mp/p2_ircserver.txt";
}

defaultproperties
{
	UpdateServerAddress="developerfuntime.com"
}