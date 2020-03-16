class UTBrowserUpdateServerLink extends UBrowserUpdateServerLink;

function SetupURIs()
{
	local string Type;

	if(Level.IsDemoBuild())
		Type = "Demo";

	MaxURI = 3;
	URIs[3] = "/UpdateServer/p2"$Type$"motd"$Level.EngineVersion$".html";
	URIs[2] = "/UpdateServer/p2"$Type$"motdfallback.html";
	URIs[1] = "/UpdateServer/p2"$Type$"masterserver.txt";
	URIs[0] = "/UpdateServer/p2"$Type$"ircserver.txt";
}

defaultproperties
{
	UpdateServerAddress="updateserver.postal2.com"
}