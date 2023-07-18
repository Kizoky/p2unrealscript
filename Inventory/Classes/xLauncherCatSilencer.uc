//=============================================================================
// xLauncherCatSilencer.uc
// Author: Nick Pilshikov "Evil"
// Email: Nick_Pv@mail.ru / EvilTheDark@gmail.com
// For: Postal 2 Happy Night
// Site: Set-Games.ru / Revival-Games.ru
// Revival Games Studios.
// 2013.
//=============================================================================

class xLauncherCatSilencer extends xCatSilencer;

var() bool bStateControl;

var() Name IdleAnim;

function PostBeginPlay()
{
	SetBoneScale( 2, 0.01, 'Bip01 tail' );
	SetBoneScale( 3, 0.01, 'Bip01 R Thigh' );
	SetBoneScale( 4, 0.01, 'Bip01 L Thigh' );
	Super.PostBeginPlay();
}

function PlayIdleAnim()
{
	LoopAnim(IdleAnim);
}

event AnimEnd(int Channel)
{
	Super.AnimEnd(Channel);
	if( !bStateControl )
		PlayIdleAnim();
}

function SetInvisible(float Time)
{
	bHidden = true;
	if( Time != 0.0 )
		SetTimer(Time ,false);
}

function Timer()
{
	bHidden = false;
}

defaultproperties
{
	 IdleAnim="stand"
	 DrawType=DT_Mesh
	 bCollideActors=false
	 bCollideWorld=false
	 Mesh=SkeletalMesh'Animals.meshCat'
}
