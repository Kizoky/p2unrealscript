//=============================================================================
// Emitter: An Unreal Emitter Actor.
//=============================================================================
class Emitter extends Actor
	native
	placeable;

#exec Texture Import File=Textures\emitter.bmp  Name=S_Emitter Mips=Off MASKED=1 


var()	export	editinline	array<ParticleEmitter>	Emitters;

var		(Global)	bool				AutoDestroy;
var		(Global)	bool				AutoReset;
var		(Global)	bool				DisableFogging;
var		(Global)	rangevector			GlobalOffsetRange;
var		(Global)	range				TimeTillResetRange;

var		transient	int					Initialized;
var		transient	box					BoundingBox;
var		transient	float				EmitterRadius;
var		transient	float				EmitterHeight;
var		transient	bool				ActorForcesEnabled;
var		transient	vector				GlobalOffset;
var		transient	float				TimeTillReset;
var		transient	bool				UseParticleProjectors;
var		transient	ParticleMaterial	ParticleMaterial;
var		transient	bool				DeleteParticleEmitters;

// shutdown the emitter and make it auto-destroy when the last active particle dies.
native function Kill();

function Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;
	for( i=0; i<Emitters.Length; i++ )
	{
		if( Emitters[i] != None )
			Emitters[i].Disabled = !Emitters[i].Disabled;
	}

}

defaultproperties
{
	Style=STY_Particle
	DrawType=DT_Particle
	Texture=S_Emitter
	bNoDelete=true
	bUnlit=true
	DrawScale=0.25
	CullDistance=12000.0
}