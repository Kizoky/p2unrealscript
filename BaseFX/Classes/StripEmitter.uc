//=============================================================================
//=============================================================================
class StripEmitter extends ParticleEmitter
	native;

enum EStripDirectionUsage
{
	STDU_None,
	STDU_Normal
};

var transient		indexbuffer					OrderedIndices;
var transient		int							RealActiveParticles;
var transient		vector						RealProjectionNormal;

var (Strip)			EStripDirectionUsage		UseDirectionAs;
var (Strip)			vector						ProjectionNormal;
var					vector						LineEnd;

var	(Local)			bool						AllowParticleSpawn;

native simulated final function ForceInit();
native simulated final function ForceSpawn(int NewNormal, float NewDeltaTime);
native simulated final function SetProjectionNormal(vector NewNormal);
native simulated final function SetMaxParticles(int NewMaxParticles);

defaultproperties
{
	AllowParticleSpawn=true;
}
