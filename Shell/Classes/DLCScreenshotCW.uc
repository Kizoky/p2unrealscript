class DLCScreenshotCW extends UMenuScreenshotCW;

function SetMap(LevelSummary L)
{
	local Texture T;
	// Hack: the level summary's "decotextname" is actually a String with the "map" screenshot	
	if(L != None)
	{
		MapTitle = "";
		MapAuthor = "";
		IdealPlayerCount = "";
		T = Texture(DynamicLoadObject(L.DecoTextName, class'Material'));
		if (T != None)
			Screenshot = T;
	}
	else
	{
		MapTitle = "";
		MapAuthor = "";
		IdealPlayerCount = "";
		Screenshot = None;
	}
}
