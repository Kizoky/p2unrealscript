//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Preferences tab for the animation browser...
//  
 
class SkelPrefsEditProps extends Object
	native
	hidecategories(Object)	
	collapsecategories;

cpptext
{
	void PostEditChange();
}

var const int WBrowserAnimationPtr;

var(Import) int            LODStyle;
var(Interface) int         RootZero;

defaultproperties
{	
	LODStyle = 10;
	RootZero = 0;
}
