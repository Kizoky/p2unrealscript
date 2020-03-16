//=============================================================================
// BlockingVolume:  a bounding volume
// used to block certain classes of actors
// primary use is to provide collision for non-zero extent traces around static meshes 

//=============================================================================

class BlockingVolume extends Volume
	native;
	
cpptext
{
    virtual UBOOL ShouldTrace(AActor *SourceActor, DWORD TraceFlags);
}
	
var() bool bClassBlocker;					// If true, acts as a class-blocker, and blocks the listed classes in BlockedClasses
var() bool bAllowOnlySpecifiedClasses;		// If true and bClassBlocker is true, blocks all classes EXCEPT those listed in BlockedClasses
var() bool bExactClassesOnly;				// If true, checks for exact class match (does not match subclasses)
var() array< class<Actor> > BlockedClasses;	// List of classes to be blocked (or exempted from being blocked)

defaultproperties
{
	 bBlockZeroExtentTraces=false
	 bWorldGeometry=true
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}