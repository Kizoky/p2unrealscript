class WorkshopScreenshotCW extends UMenuScreenshotCW;

function SetMap(LevelSummary L)
{
	if(L != None)
	{
		MapTitle = L.Title;
		MapAuthor = L.Author;
		IdealPlayerCount = "";
		Screenshot = Texture(L.Screenshot);
	}
	else
	{
		MapTitle = "";
		MapAuthor = "";
		IdealPlayerCount = "";
		Screenshot = None;
	}
}
