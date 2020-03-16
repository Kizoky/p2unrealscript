//=============================================================================
//=============================================================================
class SuperSpriteEmitter extends SpriteEmitter
	native;

enum EParticleStartLocationShapeExtend
{
	PTLSE_None,
	PTLSE_Line,
	PTLSE_Circle,
//	PTLSE_FillCircle
};

enum EParticleCoordinateSystemExtend
{
	PTCSE_None,
	PTCSE_Relative_Location,
};

var (Location)          vector                          LineStart;
var (Location)          vector                          LineEnd;
var (Location)			EParticleStartLocationShapeExtend LocationShapeExtend;

var (General)			EParticleCoordinateSystemExtend CoordinateSystemExtend;

//var (Location)          bool                            UseLine;
//var (Location)			bool							UseCircle;
//var (Location)			bool							UseFillCircle;

//var (Size)		        bool                            ScaleAlongLine;
//var (Size)				array<float>					LineSizeScale;

var	(Local)				bool							AllowParticleSpawn;


native simulated final function SetProjectionNormal(vector NewNormal);
native simulated final function SetMaxParticles(int NewMaxParticles);
native simulated final function SetLiveParticleTimes(float NewTime);
native simulated final function SpawnParticleLength(vector StartP, vector OrigEndP, float UseSize);

defaultproperties
{
	AllowParticleSpawn=true;
}
