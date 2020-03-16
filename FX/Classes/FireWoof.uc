//=============================================================================
// FireWoof. (mushroom cloud of fire that makes the sound 'WOOF')
//=============================================================================
class FireWoof extends Wemitter;
// Extends emitter because this thing doesn't actually cause damage, it just sets fires.

const PARTICLE_MAX_RATIO = 0.45;
const RADIUS_MAX_RATIO	 = 0.7;

const MAX_SHAKE_DIST		=	2000.0;
const SHAKE_ADD_RATIO		=	0.7;
const SHAKE_BASE_RATIO		=	0.3;
const SHAKE_CAMERA_MAX_MAG	=	200;

function AddNormalVelocity(vector HNormal)
{
	Emitters[0].StartVelocityRange.X.Max+=(HNormal.x*Emitters[0].StartVelocityRange.Z.Max);
	Emitters[0].StartVelocityRange.X.Min+=(HNormal.x*Emitters[0].StartVelocityRange.Z.Min);
	Emitters[0].StartVelocityRange.Y.Max+=(HNormal.y*Emitters[0].StartVelocityRange.Z.Max);
	Emitters[0].StartVelocityRange.Y.Min+=(HNormal.y*Emitters[0].StartVelocityRange.Z.Min);
}

function SetSize(float Radius)
{
	local float newmax;
	local float userad;

	newmax = Radius*PARTICLE_MAX_RATIO;
	userad = Radius*RADIUS_MAX_RATIO;
	// Decrease fire detail 
	newmax = P2GameInfo(Level.Game).ModifyByFireDetail(newmax);
	SuperSpriteEmitter(Emitters[0]).SetMaxParticles(newmax);
	Emitters[0].InitialParticlesPerSecond = 4*Emitters[0].MaxParticles;
	Emitters[0].StartLocationRange.X.Max = userad;
	Emitters[0].StartLocationRange.X.Min = -userad;
	Emitters[0].StartLocationRange.Y.Max = userad;
	Emitters[0].StartLocationRange.Y.Min = -userad;
	Emitters[0].StartLocationRange.Z.Max += Radius/8;
}

///////////////////////////////////////////////////////////////////////////////
// Expects mags under SHAKE_CAMERA_MAX_MAG for reasonable shakes
// Over 200 or so, and the camera shakes through the ground.
///////////////////////////////////////////////////////////////////////////////
function ShakeCamera(float Mag)
{
	local controller con;
	local float usemag, usedist;

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
			
			if(usedist > MAX_SHAKE_DIST)
				usedist = MAX_SHAKE_DIST;

			usemag = ((MAX_SHAKE_DIST - usedist)/MAX_SHAKE_DIST)*SHAKE_ADD_RATIO*Mag;
			usemag += SHAKE_BASE_RATIO*Mag;

			con.ShakeView((usemag * 0.2 + 1.0)*vect(1.0,1.0,3.0), 
               vect(1000,1000,1000),
               1.0 + usemag*0.02,
               (usemag * 0.3 + 1.0)*vect(1.0,1.0,2.0),
               vect(800,800,800),
               1.0 + usemag*0.02);
		}
	}
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter16
		SecondsBeforeInactive=0.0
         FadeInEndTime=0.300000
         FadeIn=True
         FadeOutStartTime=2.000000
         FadeOut=True
         MaxParticles=15
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-40.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=100.000000))
         InitialParticlesPerSecond=0.000000
         ParticlesPerSecond=0.000000
         AutomaticInitialSpawning=False
 		 DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=300.000000,Max=360.000000))
         VelocityLossRange=(X=(Min=0.750000,Max=0.750000))
         VelocityLossRange=(Y=(Min=0.750000,Max=0.750000))
         VelocityLossRange=(Z=(Min=0.650000,Max=0.650000))
         Name="SuperSpriteEmitter16"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter16'
     bDynamicLight=True
     LifeSpan=14.000000
	 AutoDestroy=true
}
