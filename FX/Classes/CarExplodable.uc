///////////////////////////////////////////////////////////////////////////////
//
// CarExplodable
//
// Karma object that blows up when hit by somethings
// (it's filled with gasoline)
//
// Be nice if it could derive from PropBreakable, but it must be KActor.
//
///////////////////////////////////////////////////////////////////////////////
class CarExplodable extends KActorExplodable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var bool bCanHurtAgain;		// Gets reset if he's hurt something recently
var class<DamageType> SmashingDamage;

// xPatch: Classic Stuff
var StaticMesh PoliceStaticMesh, PoliceStaticMeshToo;
var StaticMesh OldStaticMesh, OldBrokenStaticMesh;

struct ReplaceSkinsStr
{
	var Material NewSkin;
	var Material OldSkin;
};
var array<ReplaceSkinsStr> ReplaceSkins;

struct ReplaceDamagedSkinsStr
{
	var Texture NewSkin;
	var Texture OldSkin;
};
var array<ReplaceDamagedSkinsStr> ReplaceDamagedSkins;
// End

//const COLLIDE_DAMAGE_SCALE = 0.1;
const HURT_AGAIN_TIME	= 0.5;
const MIN_HURT_SPEED = 50;


///////////////////////////////////////////////////////////////////////////////
// This is so things don't grind into other things as they move
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	bCanHurtAgain=true;
}

///////////////////////////////////////////////////////////////////////////////
// Check to hurt this pawn if we we're going fast enough
///////////////////////////////////////////////////////////////////////////////
function CollideWithPawn(FPSPawn Other)
{
	local float usemag;

	usemag = VSize(Velocity);

	if(bCanHurtAgain
		&& usemag > MIN_HURT_SPEED
		&& !Other.bPlayer)
	{
		Other.TakeDamage(
				Other.Health,
				None, 
				Other.Location - Other.CollisionHeight* Normal(Velocity),
				Velocity*Mass,
				SmashingDamage);
		bCanHurtAgain=false;
		SetTimer(HURT_AGAIN_TIME, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Hurt NPC's when you hit them (not the player)
///////////////////////////////////////////////////////////////////////////////
event bool EncroachingOn( actor Other )
{
	if(FPSPawn(Other) != None)
		CollideWithPawn(FPSPawn(Other));
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Broken
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Broken
{
	///////////////////////////////////////////////////////////////////////////////
	// If we have a mesh, then also throw in a trailing fire effect
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local TrailingFireEmitter tfe;
		// Swap the mesh to the broken mesh if you have one
		if(BrokenStaticMesh != None)
		{
			SetDrawType(DT_StaticMesh);
			SetStaticMesh(BrokenStaticMesh);
			if(DamageSkin != None)
			{
				if(Skins.Length < 1)
					Skins.Insert(Skins.Length, 1);
				Skins[0]=DamageSkin;
			}
			tfe = spawn(class'TrailingFireEmitter',,,Location);
			tfe.SetBase(self);
		}
		else	// If we don't have a broken mesh, they don't want to
				// see it anymore, so just destroy it
			Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Classic Mode - swap to old mesh
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	local int i;
	local bool bSwapOK;
	
	Super.PostBeginPlay();
	
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).GetClassicCars())
	{
		if(StaticMesh == PoliceStaticMesh || StaticMesh == PoliceStaticMeshToo)
		{
			// Set new (old) default skin
			if(Skins[2] == None)
			{
				Skins[0] = ReplaceSkins[0].OldSkin;
				bSwapOK=True;
			}
			else // Check custom skin
			{
				for(i=0; i<ReplaceSkins.Length; i++)
				{
					if(Skins[2] == ReplaceSkins[i].NewSkin)
					{
						Skins[0] = ReplaceSkins[i].OldSkin;
						bSwapOK=True;
					}
				}
			}
			
			if(!bSwapOK)
				return;
			
			for(i=0; i<ReplaceSkins.Length; i++)
			{
				if(DamageSkin == ReplaceDamagedSkins[i].NewSkin)
					DamageSkin=ReplaceDamagedSkins[i].OldSkin;
			}
			
			if(DamageSkin == None)
				DamageSkin=ReplaceDamagedSkins[0].OldSkin;
			
			SetDrawType(DT_StaticMesh);
			SetStaticMesh(OldStaticMesh);
			BrokenStaticMesh=OldBrokenStaticMesh;
		}
	}
}



defaultproperties
{
    Begin Object Class=KarmaParams Name=KarmaParams0
        Name="KarmaParams0"
        KFriction=0.970000
	   KImpactThreshold=600
    End Object
    KParams=KarmaParams'KarmaParams0'

	ImpactSounds[0]=Sound'MiscSounds.Props.CarHitsGround'
	ImpactSounds[1]=Sound'MiscSounds.Props.CarHitsGround'

	Mass=100
	Health=24
	DamageThreshold=4
	DamageFilter=class'BludgeonDamage'
	bBlockFilter=true
	CollisionRadius=100
	CollisionHeight=100
	ExplosionMag=100000
	BurningEmitterClass=class'FireSizeableEmitter'
	ExplosionEmitterClass=class'SizeableWoof'
	WoofConversion=0.004
    
	StaticMesh=StaticMesh'Timb_mesh.cars.car_smocklar_timb'
	Skins[0]=Texture'Timb.cars.smocklar_new_timb'
	BrokenStaticMesh=StaticMesh'Timb_mesh.cars.car_smocklar_husk_timb'
	DamageSkin=Texture'Timb.cars.smocklar_burnt_silver'

	bCanHurtAgain=true
	SmashingDamage=class'SmashDamage'
	bBulletsMoveMe=false
	bUseCylinderCollision=false
	
	// xPatch: Classic Mode
	PoliceStaticMesh=StaticMesh'P2_Vehicles.cars.PoliceCar_New'
	PoliceStaticMeshToo=StaticMesh'P2R_Meshes_D.cars.PoliceCar_New'
	OldStaticMesh=StaticMesh'Timb_mesh.cars.cop_car2_timb'
	OldBrokenStaticMesh=StaticMesh'Timb_mesh.cars.cop_car2_burnt_timb'
	ReplaceSkins[0]=(NewSkin=Shader'P2R_Tex_D.cars.police_car_d_shad',OldSkin=Texture'Timb.cars.car_copcar_new')
	ReplaceSkins[1]=(NewSkin=Shader'P2R_Tex_D.cars.security_car_shader',OldSkin=Texture'Timb.cars.cop_car_security')
	ReplaceSkins[2]=(NewSkin=Shader'P2R_Tex_D.cars.security_car_vandalized_shader',OldSkin=Texture'Timb.cars.cop_car_security_vandalized')
	ReplaceSkins[3]=(NewSkin=Texture'P2R_Tex_D.cars.police_car_d',OldSkin=Texture'Timb.cars.car_copcar_new')
	ReplaceSkins[4]=(NewSkin=Texture'P2R_Tex_D.cars.security_car',OldSkin=Texture'Timb.cars.cop_car_security')	
	ReplaceSkins[5]=(NewSkin=Texture'P2R_Tex_D.cars.security_car_vandalized',OldSkin=Texture'Timb.cars.cop_car_security_vandalized')
	ReplaceSkins[6]=(NewSkin=Shader'JW_textures.cars.polarbear_shader',OldSkin=Texture'Zo_Industrial.Other.zo_polarbear_car')
	ReplaceDamagedSkins[0]=(NewSkin=Texture'P2R_Tex_D.cars.police_car_d_burnt',OldSkin=Texture'Timb.cars.car_copcar_new_burnt')
	ReplaceDamagedSkins[1]=(NewSkin=Texture'P2R_Tex_D.cars.security_car_burnt',OldSkin=Texture'Timb.cars.car_copcar_security_burnt')
	ReplaceDamagedSkins[2]=(NewSkin=Texture'P2R_Tex_D.cars.security_car_vandalized_burnt',OldSkin=Texture'Timb.cars.car_copcar_security_vandalized_burnt')
	ReplaceDamagedSkins[3]=(NewSkin=Texture'JW_textures.cars.zo_polarbear_car_burnt_new',OldSkin=Texture'Timb.cars.car_copcar_new_burnt')
}

