///////////////////////////////////////////////////////////////////////////////
// Big McWillis.
///////////////////////////////////////////////////////////////////////////////
class BigMcWillis extends Bystander
	placeable;
	
const MCWILLIS_SKEL = 'McwillisRagdoll';	

//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Anims
// Bare minimum to get this guy working in testmap-pl
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
simulated function name GetAnimStand()
{
	return 'Idle1';
}
simulated function name GetAnimClimb()
{
	return 'Walk';
}
simulated function name GetAnimKick() // a low kick (aimed at a prone body)
{
	return 'Gesture_Angry';
}
simulated function name GetAnimShocked() // electrocuted by a Shocker
{
	//return 'cb_takehit1';
}
simulated function name GetAnimDazed()
{
	//return 'cb_takehit2';
}
simulated function name GetAnimKickedInTheBalls()
{
	//return 'cb_takehit2';
}
simulated function name GetAnimClapping()
{
	//return 'cb_laugh';
}
simulated function name GetAnimDancing()
{
	//return 'cb_uttershoot';
}
simulated function name GetAnimLaugh()
{
	//return 'cb_laugh';
}
simulated function name GetAnimTellThemOff()
{
	return 'Gesture_Point';
}
simulated function name GetAnimFlipThemOff()
{
	switch (Rand(2))
	{
		case 0:
			return 'Gesture_Fist';
			break;
		case 1:
			return 'Gesture_Angry';
			break;
	}
}
simulated function name GetAnimRestStanding()
{
	return 'Idle1';
}
simulated function name GetAnimIdle()
{
	return 'Idle1';
}
simulated function name GetAnimIdleQ()
{
	return 'Idle1';
}
simulated function PlayMoving()
{
	if ((Physics == PHYS_None) || ((Controller != None) && Controller.bPreparingMove) )
	{
		// Controller is preparing move - not really moving
		PlayWaiting();
	}
	else if (bIsWalking)
		SetAnimWalking();
	else
		SetAnimRunning();
}	
simulated function SetAnimStanding()
{
	LoopIfNeeded(GetAnimStand(), 1.0);
}
simulated function SetAnimWalking()
{
	TurnLeftAnim = 'Walk';
	TurnRightAnim = 'Walk';
	MovementAnims[0] = 'Walk';
	MovementAnims[1] = 'Walk';
	MovementAnims[2] = 'Walk';
	MovementAnims[3] = 'Walk';
}
simulated function SetAnimRunning()
{
	TurnLeftAnim = 'Walk';
	TurnRightAnim = 'Walk';
	MovementAnims[0] = 'Walk';
	MovementAnims[1] = 'Walk';
	MovementAnims[2] = 'Walk';
	MovementAnims[3] = 'Walk';
}
// Cannot crouch or deathcrawl
simulated function SetAnimStartCrouching();
simulated function SetAnimCrouching();
simulated function SetAnimEndCrouching();
simulated function SetAnimCrouchWalking();
simulated function SetAnimStartDeathCrawling();
simulated function SetAnimEndDeathCrawling();
simulated function SetAnimDeathCrawlWait();
simulated function SetAnimStartKnockOut();
simulated function SetAnimEndKnockOut();
simulated function SetAnimKnockedOut();
simulated function SetAnimDeathCrawling();

///////////////////////////////////////////////////////////////////////////////
// GetKarmaSkeleton
// Use a lawman ragdoll
///////////////////////////////////////////////////////////////////////////////
function GetKarmaSkeleton()
{
	local P2GameInfo checkg;
	local name skelname;
	local P2Player p2p, cont;
	
	skelname=MCWILLIS_SKEL;

	if(Level.NetMode != NM_DedicatedServer)
	{
		// Go through all the player controllers till you find the one on
		// your computer that has a valid viewport and has your ragdolls
		foreach DynamicActors(class'P2Player', Cont)
		{
			if (ViewPort(Cont.Player) != None)
			{
				p2p = Cont;
				break;
			}
		}
		if(p2p != None
			&& KParams == None)
		{
			KParams = p2p.GetNewRagdollSkel(self, skelname);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Big McWillis ignores all damage, he only appears in cutscenes and the only
// time the Dude interacts with him, he needs to use the ensmallen cure on him
// so we simply ignore damage and pee calls.
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	Super.TakeDamage(0, InstigatedBy, HitLocation, Momentum, DamageType);
}

defaultproperties
{
	ActorID="BigMcWillis"

	bKeepForMovie=True
	bRandomizeHeadScale=False
	bStartupRandomization=False
	Mesh=SkeletalMesh'PLCharacters.Big_McWillis'
	Skins(0)=Texture'PLCharacterSkins.Big_McWillis_Body.mcwillis_torso'
	Skins(1)=Texture'PLCharacterSkins.Big_McWillis_Body.mcwillis_jeans'
	Skins(2)=Texture'PLCharacterSkins.Big_McWillis_Body.mcwillis_boots'
	Skins(3)=Texture'PLCharacterSkins.Big_McWillis_Body.mcwillis_straps'
	HeadClass=Class'BigMcWillisHead'
	bPersistent=True
	//ExtraAnims(0)=MeshAnimation'PLCharacters.animMcWillis'
	bCanBeBaseForPawns=True
	bNoChamelBoltons=True
	RandomizedBoltons(0)=None
	Gang="ColeMen"
	ControllerClass=class'BigMcWillisController'
	AmbientGlow=30
	bCellUser=false
	bNoRadar=true
	bNoDismemberment=True
	TakesShotgunHeadShot=0.1
}
