///////////////////////////////////////////////////////////////////////////////
// RifleScopeGlare
// 
// Glare from the sniper rifle scope in third person.
// 
///////////////////////////////////////////////////////////////////////////////
class RifleScopeGlare extends P2Emitter;

simulated function PostNetBeginPlay()
{
	local int i;

	Super.PostNetBeginPlay();

	// Don't make this effect on the client's machine that created it (so he's
	// not blinded by his own effect)
	if(Owner!= None
		&& Owner.Owner != None
		&& Owner.Owner.Owner != None
		&& ViewPort(PlayerController(Owner.Owner.Owner).Player) != None)
	{
		for(i=0; i<Emitters.Length; i++)
			Emitters[i].Disabled=true;
	}
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter58
        UseDirectionAs=PTDU_Up
        FadeOut=True
        MaxParticles=4
		RespawnDeadParticles=false
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartLocationOffset=(Z=50.000000)
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=2.000000,Max=30.000000),Y=(Min=100.000000,Max=180.000000))
        InitialParticlesPerSecond=5.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Translucent
        Texture=Texture'nathans.Skins.blast1'
        LifetimeRange=(Min=0.500000,Max=0.600000)
        StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-50.000000,Max=50.000000))
        Name="SpriteEmitter58"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter58'
 	 Begin Object Class=SpriteEmitter Name=SpriteEmitter10
		MaxParticles=5
        RespawnDeadParticles=false
        StartLocationOffset=(Z=50.000000)
		UseSizeScale=true
		UseRegularSizeScale=false
		SizeScale(0)=(RelativeSize=0.300000)
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		StartSizeRange=(X=(Min=25.000000,Max=60.000000))
        InitialParticlesPerSecond=5.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Translucent
        Texture=Texture'nathans.Skins.softwhitedot'
		LifetimeRange=(Min=0.500000,Max=0.700000)
		Name="SpriteEmitter10"
	 End Object
	 Emitters(1)=SpriteEmitter'SpriteEmitter10'
	LifeSpan=3.0
    bTrailerSameRotation=True
    Physics=PHYS_Trailer
    AutoDestroy=true
	bReplicateMovement=true
	Mass=-80
}
