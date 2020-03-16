//=============================================================================
// CharacterWindow - a window which displays a P2 character in the middle of the screen
//=============================================================================
class CharacterWindow extends UWindowWindow;

var float MinWidth, MinHeight;	// minimum heights for layout control

var		MpMenuPawn		Character;
var		string			CurrentCharacter;
var		float			CharacterScale;
var		rotator			Rotation;

var		bool			bPlayRandomAnims;
var		float			AnimChangeInterval;
var		array<name>		AnimNames;

var		float			CurrentTime;
var		float			NextAnimTime;

function Created()
{
	local PlayerController PC;

	PC = root.ViewportOwner.Actor;
	if(Character == None)
		Character = PC.Spawn(class<MpMenuPawn>(DynamicLoadObject("MultiStuff.MpMenuPawn", class'class')), PC);
	Character.LoopAnim('s_base1');
	NextAnimTime = CurrentTime + AnimChangeInterval;
}

function SetCharacter(string CharacterClassName)
{
	local class<xMpPawn> CharacterClass;
	local int i;

	if(CharacterClassName ~= "" || CharacterClassName ~= CurrentCharacter)
		return;

	CurrentCharacter = CharacterClassName;
	CharacterClass = class<xMpPawn>(DynamicLoadObject(CharacterClassName, class'class'));
	Character.SetCharacter(CharacterClass);
	SetScale(CharacterScale);
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if (Character != None)
	{
		Character.Destroy();
		Character = None;
	}
}

function SetScale(float newScale)
{
	local int i;

	CharacterScale = newScale;
	if(Character == None)
		return;
	Character.SetDrawScale(CharacterScale);
	Character.MyHead.SetDrawScale(CharacterScale);
	for (i = 0; i < ArrayCount(Character.boltons); i++)
	{
		if (!Character.boltons[i].bInActive && Character.boltons[i].part != None)
			Character.boltons[i].part.SetDrawScale(CharacterScale);
	}
}

function Paint(Canvas C, float X, float Y)
{
	local PlayerController PC;
	local Actor ViewTarget;
	local rotator CameraRotation;
	local vector CameraLocation;

	Super.Paint(C,X,Y);

	if (Character != None && P2RootWindow(Root).IsMenuShowing())
	{
		// Set draw style
		C.Style = 1; //ERenderStyle.STY_Normal;
		C.SetDrawColor(255, 255, 255);

		// 65535 32768 16384

		PC = root.ViewportOwner.Actor;
		PC.PlayerCalcView(ViewTarget, CameraLocation, CameraRotation);

		CameraRotation.Pitch += 150;
		Character.SetLocation(CameraLocation + 6.8*vector(CameraRotation));

		CameraRotation.Yaw += 32768;
		CameraRotation.Pitch = -CameraRotation.Pitch;
		Character.SetRotation(CameraRotation + Rotation);

		C.DrawActor(Character, false);
	}
//	else
//		Warn("Character is None!");
}

function PlayNextAnim()
{
	local name NewAnimName;

	if(Character == None || AnimNames.Length == 0)
		return;

	NewAnimName = AnimNames[Rand(AnimNames.Length)];
	Character.PlayAnim(NewAnimName, 1.0, 0.25); 

	NextAnimTime = CurrentTime + AnimChangeInterval;
}

function Tick(float Delta)
{
	//Rotation.Yaw += 64;
	//Rotation.Yaw = Rotation.Yaw & 65535;

	CurrentTime += Delta;

	// If desired, play some random animations
	if(bPlayRandomAnims && CurrentTime >= NextAnimTime)
	{
		PlayNextAnim();
	}
}



defaultproperties
{
	bPlayRandomAnims=true

	AnimChangeInterval=20.0;

	AnimNames(0)=s_base1
	AnimNames(1)=s_dance3
	AnimNames(2)=s_idle_crotch
	AnimNames(3)=s_idle_survey
	AnimNames(4)=s_idle_watch
	AnimNames(5)=s_idle_stretch
	AnimNames(6)=s_idle_shoe
	AnimNames(7)=s_scream
	AnimNames(8)=s_nothing
	AnimNames(9)=s_angry
}