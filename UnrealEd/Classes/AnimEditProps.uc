//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Animation / Mesh editor object to expose/shuttle only selected editable 
//  parameters from UMeshAnim/ UMesh objects back and forth in the editor.
//  

class AnimEditProps extends Object
	hidecategories(Object)
	native;	

cpptext
{
	void PostEditChange();
}

var const int WBrowserAnimationPtr;
var(Compression) float   GlobalCompression;

defaultproperties
{	
	GlobalCompression=1.0
}
