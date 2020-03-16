class TexCoordSource extends TexModifier
	native
	editinlinenew
	collapsecategories;

var() int	SourceChannel;

cpptext
{
	void PostEditChange();
}

defaultproperties
{
	SourceChannel=0
	TexCoordSource=TCS_Stream0
}