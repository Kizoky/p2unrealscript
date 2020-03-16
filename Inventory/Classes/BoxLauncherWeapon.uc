class BoxLauncherWeapon extends LauncherWeapon;
///////////////////////////////////////////////////////////////////////////////
var texture RedIcon;
var int ColorCount;   
var array<Sound> DudeCommentaryFire, DudeCommentaryHit;
var travel bool bCommentedOnFire, bCommentedOnHit;
var ConstantColor CurrentColor;
var Sound SwitchSound;
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	ToggleMode();
}
///////////////////////////////////////////////////////////////////////////////
// Skip the charge, go straight to the fire
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}

	bAltFiring=false;
	ShootIt();
	ClientShootIt();
	
	if (!bCommentedOnFire
		&& P2Player(Instigator.Controller) != None)
		bCommentedOnFire = P2Player(Instigator.Controller).SayCustomLine(DudeCommentaryFire[rand(DudeCommentaryFire.Length)]);
}
simulated function MadeContact()
{
	if (!bCommentedOnHit
		&& P2Player(Instigator.Controller) != None)
		bCommentedOnHit = P2Player(Instigator.Controller).SayCustomLine(DudeCommentaryHit[rand(DudeCommentaryHit.Length)]);
}
//////////////////////////////////////////////////////////////////////////////  
simulated function ToggleMode()
{
	if(ColorCount % 2 == 0)
		BoxLauncherAmmoInv(AmmoType).Texture = RedIcon;
	else
		BoxLauncherAmmoInv(AmmoType).Texture = BoxLauncherAmmoInv(AmmoType).Default.Texture;	
	ColorCount++;
	Instigator.PlaySound(SwitchSound, SLOT_Misc, 1.0);
	//Skins[2] = BoxLauncherAmmoInv(AmmoType).Texture;
	//Skins[3] = BoxLauncherAmmoInv(AmmoType).Texture;
	
	/*
	CurrentColor.Color.R = Rand(256);
	CurrentColor.Color.G = Rand(256);
	CurrentColor.Color.B = Rand(256);
	Skins[2] = CurrentColor;
	Skins[3] = CurrentColor;
	*/
}
function HSVtoRGB(float h, float s, float v, out byte rr, out byte gg, out byte bb)
{
	local int i;
	local float f, p, q, t, r, g, b;
    
	i = int(h * 6.0);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);

    switch(i % 6){
        case 0: r = v; g = t; b = p; break;
        case 1: r = q; g = v; b = p; break;
        case 2: r = p; g = v; b = t; break;
        case 3: r = p; g = q; b = v; break;
        case 4: r = t; g = p; b = v; break;
        case 5: r = v; g = p; b = q; break;
    }
	rr = byte(255.0 * r);
	gg = byte(255.0 * g);
	bb = byte(255.0 * b);
	//log("hsv "@h@s@v@rr@gg@bb);
}

function SwapColors()
{
	// Make a new color
	CurrentColor = new class'ConstantColor';
	HSVtoRGB(FRand(), 1.0, 1.0, CurrentColor.Color.R, CurrentColor.Color.G, CurrentColor.Color.B);
	Skins[2] = CurrentColor;
	Skins[3] = CurrentColor;
	ThirdPersonActor.Skins[2] = CurrentColor;
	ThirdPersonActor.Skins[3] = CurrentColor;	
}
///////////////////////////////////////////////////////////////////////////////
function Notify_ShootLauncher()
{
	local vector StartTrace, X,Y,Z, HitNormal, HitLocation;
	local actor HitActor;
	local BoxLauncherProjectile SP;

        if(!Instigator.Controller.bIsPlayer)
	        return;
		
        GetAxes(Instigator.GetViewRotation(),X,Y,Z);
        StartTrace = GetFireStart(X,Y,Z); 
        AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
        ShootStyleChanger = 0;
        HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
        
        if(HitActor == None || (!HitActor.bStatic && !HitActor.bWorldGeometry) )
        {
                if(ColorCount % 2 == 0)
                        SP = spawn(class'BoxLauncherProjectile', , , StartTrace, AdjustedAim);
                else
                        SP = spawn(class'BoxLauncherProjectile2', , , StartTrace, AdjustedAim);
                
                if(SP != None)
                {
					SP.Skins[0] = CurrentColor;
			            P2AmmoInv(AmmoType).UseAmmoForShot(1);
                        SP.SetupShot();
                        SP.AddRelativeVelocity(Normal(Instigator.Velocity) * VSize(Instigator.Velocity) / 2);
						SP.Launcher = Self;
                
                        if(HitActor != None)
                                 HitActor.Bump(SP);
								 
					SwapColors();
				}
        }
}
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	AmmoUseRate=0.250000
	InitialAmmoCost=0.500000
	AmmoName=Class'BoxLauncherAmmoInv'
	PickupClass=Class'BoxLauncherPickup'
	ItemName="Box Launcher"  
	GroupOffset=103
	Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins(1)=Texture'AW7Tex.AMN.BLauncher'
	Skins(2)=Texture'AW7Tex.AMN.bluebox'
	Skins(3)=Texture'AW7Tex.AMN.bluebox'
	AttachmentClass=Class'BoxLauncherAttachment' 
	RedIcon=Texture'AW7Tex.AMN.redbox' 
	FireSound=Sound'AW7Sounds.MiscWeapons.Boingy'
	WeaponSpeedShoot1=3.0
	WeaponSpeedLoad=2.000000
	WeaponSpeedIdle=0.300000  
	bNoHudReticle=true   
	HudHint1="Press %KEY_AltFire% to toggle box cameras."
	HudHint2=""
	DudeCommentaryFire[0]=Sound'DudeDialog.dude_vote_whatmoron'
	DudeCommentaryFire[1]=Sound'AWDialog.Dude.Dude_LostMind'
	DudeCommentaryHit[0]=Sound'DudeDialog.dude_fascinating'
	DudeCommentaryHit[1]=Sound'DudeDialog.dude_ididntexpectthat'
	DudeCommentaryHit[2]=Sound'DudeDialog.dude_sothatswhatthat'
	Begin Object Class=ConstantColor Name=BoxColor
		Color=(A=255,B=255,R=0,G=0)
	End Object
	CurrentColor=ConstantColor'BoxColor'
	SwitchSound=Sound'MiscSounds.Radar.PluginActivate'
}
