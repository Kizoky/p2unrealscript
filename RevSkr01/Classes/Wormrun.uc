//=============================================================================
// Wormrun.
//=============================================================================
class Wormrun extends PickupHitPuff;

const MAX_SHAKE_DIST		=	2500.0;
const SHAKE_ADD_RATIO		=	0.15;
const SHAKE_BASE_RATIO		=	0.15;
const SHAKE_CAMERA_MAX_MAG	=	200;

function postbeginplay()
{
 ShakeCamera(100);
}

function ShakeCamera(float Mag)
{
	local controller con;
	local float usemag, usedist;
	local vector Rotv, Offsetv;

	// Put a cap on the shake to make sure no one accidentally puts too much in
	if(Mag > SHAKE_CAMERA_MAX_MAG)
		Mag = SHAKE_CAMERA_MAX_MAG;

	// Shake the view from the big explosion!
	// Move this somewhere else?
	for(con = Level.ControllerList; con != None; con=con.NextController)
	{
		// Find who did it first, then shake them
		if(con.bIsPlayer && con.Pawn!=None
			&& con.Pawn.Physics != PHYS_FALLING)
		{
			usedist = VSize(con.Pawn.Location - Location);
			
			if(usedist < MAX_SHAKE_DIST)
			{
				usemag = ((MAX_SHAKE_DIST - usedist)/MAX_SHAKE_DIST)*SHAKE_ADD_RATIO*Mag;
				usemag += SHAKE_BASE_RATIO*Mag;
				// If you're actually hurt by the explosion bump up the shake a lot more

				  Rotv=vect(1.0,1.0,1.0);
				Offsetv=vect(1.0,1.0,1.0);


				con.ShakeView((usemag * 0.2 + 1.0)*Rotv, 
				   vect(1000,1000,1000),
				   1.0 + usemag*0.02,
				   (usemag * 0.3 + 1.0)*Offsetv,
				   vect(800,800,800),
				   1.0 + usemag*0.02);
			}
		}
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter59
         Acceleration=(Z=-1000.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=23,G=55,R=70))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=20,G=57,R=90))
         MaxParticles=13
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         StartSizeRange=(X=(Min=25.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
         Texture=Texture'nathans.Skins.pour2'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=10.000000,Max=500.000000))
         Name="SpriteEmitter59"
     End Object
	 Emitters(0)=SpriteEmitter'SpriteEmitter59'
     AmbientSound=Sound'LevelSoundsToo.Napalm.napalmVent1'
}
