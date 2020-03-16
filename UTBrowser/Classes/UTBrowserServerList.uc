class UTBrowserServerList extends UBrowserServerList;

var bool bNGWorldStatsActive;
var bool bNGWorldStats;
var string PasswordRequired;
var localized string RequiredText;

function bool DecodeServerProperties(string Data)
{
	local int i;

	i=InStr(Data, "\\worldlog\\");
	if(i >= 0 && Mid(Data, i+10, 4) ~= "true")
		bNGWorldStatsActive = True;

	i=InStr(Data, "\\wantworldlog\\");
	if(i >= 0 && Mid(Data, i+14, 4) ~= "true")
		bNGWorldStats = True;
	
	// RWS Change: include if password is needed
	i=InStr(Data, "\\password\\");
	if(i >= 0 && Mid(Data, i+10, 4) ~= "true")
		PasswordRequired = RequiredText;
	else if(i < 0)
		PasswordRequired = "?";
	else
		PasswordRequired = "";


	return Super.DecodeServerProperties(Data);
}

function UWindowList CopyExistingListItem(Class<UWindowList> ItemClass, UWindowList SourceItem)
{
	local UTBrowserServerList L;

	L = UTBrowserServerList(Super.CopyExistingListItem(ItemClass, SourceItem));
	L.bNGWorldStats	= UTBrowserServerList(SourceItem).bNGWorldStats;
	L.bNGWorldStatsActive = UTBrowserServerList(SourceItem).bNGWorldStatsActive;
	L.PasswordRequired = UTBrowserServerList(SourceItem).PasswordRequired;

	return L;
}

defaultproperties
{
	RequiredText="Required"
}