class PL_DildoWeapon extends BatonWeapon;

var PL_Dildo Wre;


simulated function PostNetBeginPlay()
{
    local PlayerController PC;
	local Pawn P;

    Super.PostNetBeginPlay();

    P  = Pawn(Owner);
	PC = PlayerController(P.Controller);

   	if (P.IsLocallyControlled() && PC!=None && (!PC.bBehindView) )
	{
        Wre = Spawn(Class'PLInventory.PL_Dildo');
        AttachToBone( Wre, 'Wre' );
    }
	/*
   	else
	{
        if(Instigator != None)
	   {
		 if(Instigator.Mesh != None)

             Wre.Destroyed();
             Wre = None;
	   }
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////

function DropFrom(vector StartLocation)
{

   Super.DropFrom(StartLocation);

   if (Wre != None)
  {
    DetachFromBone(Wre);
    Wre.Destroy();
    Wre = None;
  }

}

simulated function Destroyed()
{
   Super.Destroyed();

  if( Wre != None )
  {
    DetachFromBone(Wre);
    Wre.Destroy();
    Wre = None;
  }
}


defaultproperties
{
     GroupOffset=23
     AmmoName=Class'PL_DildoAmmoInv'
     PickupClass=Class'PL_DildoPickup'
     AttachmentClass=Class'PL_DildoAttachment'
     Mesh=SkeletalMesh'MrD_PL_Anims.MP_LS_Dildo'
     Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     Skins(1)=Shader'MrD_PL_Tex.Weapons.fake'
	PawnHitMarkerMade=class'PawnDildoedMarker'
	ItemName="Dildo"
	bWeaponIsGross=true
	PlayerViewOffset=(X=1,Y=0,Z=-15)
}
