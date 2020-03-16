///////////////////////////////////////////////////////////////////////////////
// SteamEmitter. 
//
// For putting out fires.
///////////////////////////////////////////////////////////////////////////////
class SteamEmitter extends TimedEmitter;

var Sound SteamSound;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Steaming
{
Begin:
	PlaySound(SteamSound,,1.0,,1.0);
	Sleep(GetSoundDuration(SteamSound));
	Goto('Begin');
}

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter11
		SecondsBeforeInactive=0.0
        FadeOutStartTime=0.800000
        FadeOut=True
        MaxParticles=15
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=50.000000,Max=90.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.200000,Max=1.500000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=90.000000,Max=130.000000))
        Name="SuperSpriteEmitter11"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter11'

	SteamSound = Sound'WeaponSounds.steam_loop'

	PlayTime=2.0
	FinishUpTime=1.5
    AutoDestroy=true
}
