//=============================================================================
// RevivalGames.
// 23.09.11.
// ErikRossik.
//=============================================================================
class DynamicShadowInfo extends Info
	placeable;

var PlayerController PC;
var int MatNum;

///////////////////////////////////////////////////////

var SUNOBJ Sun1,Sun2,Sun3,Sun4,Sun5,Sun6;
var (ADLevelOptions)  vector SunPos;
var (ADLevelOptions)  Material Sun1Tex1,Sun1Tex2,Sun1Tex3,Sun1Tex4,Sun1Tex5,Sun1Tex6;
var (ADLevelOptions)  float Sun1Size1,Sun1Size2,Sun1Size3,Sun1Size4,Sun1Size5,Sun1Size6;
var (ADLevelOptions)  Bool SUNActive;


//=============================================================================
Function PostBeginPlay()
{
	local Actor A;
	
 If(SUNActive) InitSun();
 foreach DynamicActors(class'Actor', A, 'SunHere')
 {
	SunPos = A.Location;
	break;
 }
}

/////////////////////////////////////////////////////////////////////////////
Function InitSun()
{
 If(Sun1Tex1 != None)
 {
 Sun1 = Spawn(class'SunObj');
 Sun1.SetDrawScale(Sun1Size1);
 Sun1.Skins[0] = Sun1Tex1;

  If(Sun1Tex2 != None)
  {
  Sun2 = Spawn(class'SunObj');
  Sun2.SetDrawScale(Sun1Size2);
  Sun2.Skins[0] = Sun1Tex2;
  }
  If(Sun1Tex3 != None)
  {
  Sun3 = Spawn(class'SunObj');
  Sun3.SetDrawScale(Sun1Size3);
  Sun3.Skins[0] = Sun1Tex3;
  }
  If(Sun1Tex4 != None)
  {
  Sun4 = Spawn(class'SunObj');
  Sun4.SetDrawScale(Sun1Size4);
  Sun4.Skins[0] = Sun1Tex4;
  }
  If(Sun1Tex5 != None)
  {
  Sun5 = Spawn(class'SunObj');
  Sun5.SetDrawScale(Sun1Size5);
  Sun5.Skins[0] = Sun1Tex5;
  }
  If(Sun1Tex6 != None)
  {
  Sun6 = Spawn(class'SunObj');
  Sun6.SetDrawScale(Sun1Size6);
  Sun6.Skins[0] = Sun1Tex6;
  }
 }
}

/////////////////////////////////////////////////////////////////////////////
Function Tick (Float DeltaTime)
{ 
 Local PlayerController C;

 Super.Tick (DeltaTime);

 If(PC == none)
 {
  foreach allactors(class'PlayerController', C)
   {
    PC = C;
   }
 }
 SunControl();

// TestMassObjects();
}


Function SunControl()
{
 local vector SunLine,StartP,HitLoc,HitNorm;
 Local rotator ViewMax;
 Local Actor Pl;



 If(SUNActive && SUN1 != None)
 {
  Sun1.SetLocation(PC.ViewTarget.Location + SunPos);

  Pl = Trace(HitLoc, HitNorm, PC.ViewTarget.Location, PC.ViewTarget.Location + (SunPos*10),True);

   ViewMax = PC.GetViewRotation();
   StartP = PC.ViewTarget.Location+(vect(100,0,0) >> ViewMax);

   
   Sun1.Bcorona = True;

   SunLine = (Sun1.Location - StartP);

   If(SUN2 != None)
   {
   Sun2.SetLocation(StartP + SunLine/18);
   Sun2.SetBase(PC.ViewTarget);
   }
   If(SUN3 != None)
   {
   Sun3.SetLocation(StartP + SunLine/15);
   Sun3.SetBase(PC.ViewTarget);
   }
   If(SUN4 != None)
   {
   Sun4.SetLocation(StartP + SunLine/12);
   Sun4.SetBase(PC.ViewTarget);
   }
   If(SUN5 != None)
   {
   Sun5.SetLocation(StartP + SunLine/9);
   Sun5.SetBase(PC.ViewTarget);
   }
   If(SUN6 != None)
   {
   Sun6.SetLocation(StartP + SunLine/6);
   Sun6.SetBase(PC.ViewTarget);
   }


  If(Pl == PC.ViewTarget)
  {

   

   If(SUN2 != None)
   {
   Sun2.Bcorona = True;
   }
   If(SUN3 != None)
   {
   Sun3.Bcorona = True;
   }
   If(SUN4 != None)
   {
   Sun4.Bcorona = True;
   }
   If(SUN5 != None)
   {
   Sun5.Bcorona = True;
   }
   If(SUN6 != None)
   {
   Sun6.Bcorona = True;
   }


  }
  Else
  {

   Sun1.Bcorona = False;
   If(SUN2 != None)
   {
   Sun2.Bcorona = False;
   }
   If(SUN3 != None)
   {
   Sun3.Bcorona = False;
   }
   If(SUN4 != None)
   {
   Sun4.Bcorona = False;
   }
   If(SUN5 != None)
   {
   Sun5.Bcorona = False;
   }
   If(SUN6 != None)
   {
   Sun6.Bcorona = False;
   }
  }
 }
}

defaultproperties
{
     SunPos=(X=-3000.000000,Y=-4000.000000,Z=3000.000000)
     Sun1Size1=0.500000
     Sun1Size2=0.300000
     Sun1Size3=0.200000
     Sun1Size4=0.100000
     Sun1Size5=0.500000
     Sun1Size6=0.700000
     SUNActive=false
	 //MaxShadows16=30
	 //MaxShadows32=30
	 //MaxShadows64=20
	 //MaxShadows128=10
	 //MaxShadows256=5
	 //MaxShadows512=5
	 //ShadowDir=(X=-0.500000,Y=-1.000000,Z=2.000000)
	 //ShadowUpdateRate=0.05
	 //ShadowVisibilityRad=2000
	 //ShadowLightDist=170
	 //ShadowTraceDist=1000
	 //bUseGradient=false
	 bObsolete=true
}