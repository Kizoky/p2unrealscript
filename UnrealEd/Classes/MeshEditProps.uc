//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Animation / Mesh editor object to expose/shuttle only selected editable 
//  parameters from UMeshAnim/ UMesh objects back and forth in the editor.
//  
 
class MeshEditProps extends Object
	hidecategories(Object)
	native;	

cpptext
{
	void PostEditChange();
}

struct native LODLevel
{
	var() float   DistanceFactor;
	var() float   ReductionFactor;	
	var() float   Hysteresis;
	var() int     MaxInfluences;
	var() bool    SwitchRedigest;
};

struct native AttachSocket
{
	var() vector  A_Translation;
	var() rotator A_Rotation;
	var() name AttachAlias;	
	var() name BoneName;		
	var() float      Test_Scale;
	var() mesh       TestMesh;
	var() staticmesh TestStaticMesh;	
};

var const int WBrowserAnimationPtr;
var(Mesh) vector			 Scale;
var(Mesh) vector             Translation;
var(Mesh) rotator            Rotation;
var(Mesh) vector             MinVisBound;
var(Mesh) vector			 MaxVisBound;
var(Mesh) vector             VisSphereCenter;
var(Mesh) float              VisSphereRadius;

var(Redigest) int            LODStyle; //Make drop-down box w. styles...
var(Animation) MeshAnimation DefaultAnimation;

var(Skin) array<Material>					Material;

// To be implemented: - material order specification to re-sort the sections (for multiple translucent materials )
// var(RenderOrder) array<int>					MaterialOrder;
// To be implemented: - originalmaterial names from Maya/Max
// var(OriginalMaterial) array<name>			OrigMat;

var(LOD) float            LOD_Strength;
var(LOD) array<LODLevel>  LODLevels;


var(Attach) array<AttachSocket>   Sockets;  // Sockets, with or without adjustment coordinates / bone aliases.
var(Attach) bool  ApplyNewSockets;			// Explicit switch to apply changes 
var(Attach) bool  ContinuousUpdate;			// Continuous updating (to adjust socket angles interactively)

defaultproperties
{	
	Scale=(X=1,Y=1,Z=1)
	Rotation=(Pitch=0,Yaw=0,Roll=0)
	Translation=(X=0,Y=0,Z=0)
	ApplyNewSockets = false;
	ContinuousUpdate = false;
}
