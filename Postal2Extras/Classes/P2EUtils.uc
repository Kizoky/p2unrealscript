///////////////////////////////////////////////////////////////////////////////
// P2EUtils.uc
//
// A handy class for commonly used functions so no one has to keep redefining
// them in their own classes.
//
// Started by Steven on 4/15/2014
///////////////////////////////////////////////////////////////////////////////
class P2EUtils extends Object;

// Similar to UWindowBase.Region, this one allows scaling factors.
struct FloatRegion
{
	var() float X;
	var() float Y;
	var() float W;
	var() float H;
};

// Internal.
var private array<UWindowBase.Region>	DrawRegionStack;

///////////////////////////////////////////////////////////////////////////////
// Math functions.
///////////////////////////////////////////////////////////////////////////////
/** Returns a vector representing the offset using the given direction
 * @param Dir - rotation to base the offset calculation off of
 * @param Offset - offset values in the form of a vector
 * @return Location offset
 */
static function vector GetOffset(rotator Dir, vector Offset) {
    local vector X, Y, Z;

    GetAxes(Dir, X, Y, Z);

    return X*Offset.X + Y*Offset.Y + Z*Offset.Z;
}

/*
	Clamps a vector between min and max.
*/
static final function vector VClamp(vector V, vector VMin, vector VMax)
{
	V.X = FClamp(V.X, VMin.X, VMax.X);
	V.Y = FClamp(V.Y, VMin.Y, VMax.Y);
	V.Z = FClamp(V.Z, VMin.Z, VMax.Z);
	return V;
}

static final function vector VMin(vector A, vector B)
{
	A.X = FMin(A.X, B.X);
	A.Y = FMin(A.Y, B.Y);
	A.Z = FMin(A.Z, B.Z);
	return A;
}

static final function vector VMax(vector A, vector B)
{
	A.X = FMax(A.X, B.X);
	A.Y = FMax(A.Y, B.Y);
	A.Z = FMax(A.Z, B.Z);
	return A;
}

/*
	Normalizes a 360 degree rotation.
*/
static final function float Normalize360(float F)
{
	F = F % 360;

	if(F < 0)
		return (F + 360);

	return F;
}

///////////////////////////////////////////////////////////////////////////////
// String functions.
///////////////////////////////////////////////////////////////////////////////
/*
	Taken from one of the UWindow classes. Operates the same as InStr(),
	but skips past everything before Pos.

	Text:		String to be searched

	Match:		Substring to find

	Pos:		Old position retrieved by InStr() prior to calling
			this function.

	Like InStr(), this function returns the position of a substring if
	found. Otherwise -1 is returned.
*/
static final function int InStrAfter(string Text, string Match, int Pos)
{
	local int i;

	i = InStr(Mid(Text, Pos), Match);
	if(i != -1)
		return i + Pos;
	return -1;
}

static final function string FloatToString(float Value, optional int Precision)
{
	local float FloatPart;
	local int IntPart;
	local string IntString, FloatString;

	Precision = Clamp(Precision, 1, 6); // Only allow 6 decimal places for now.

	if(Value < 0)
	{
		IntString = "-";
		Value *= -1;
	}
	IntPart = int(Value);
	FloatPart = Value - IntPart;
	IntString = IntString $ string(IntPart);
	FloatString = string(int(FloatPart * 10 ** Precision));

	while(Len(FloatString) < Precision)
		FloatString = "0" $ FloatString;

	return IntString $ "." $ FloatString;
}

// Operator 14 uses the same internal name as EatString, so we can't define it as EatString in Object
// this function serves as an alias to the actual function, now renamed SplitStringSingle - Rick
function bool EatString(out string S, string Delim, out string Res)
{
	return SplitStringSingle(S, Delim, Res);
}

/*
	Returns the current map's filename minus the extension (*.fuk).

	PC:	Local player controller
*/
static final function string GetCurrentMapFilename(PlayerController PC)
{
	local string S;

	if((PC == None) || (Viewport(PC.Player) == None))
		return "";

	S = string(PC);
	return Left(S, InStr(S, "."));
}

///////////////////////////////////////////////////////////////////////////////
// Canvas-related functions.
///////////////////////////////////////////////////////////////////////////////
/*
	Gets the client resolution and stores it in a vector.
*/
static final function GetClientResolution(PlayerController PC, out vector Res)
{
	local int i;
	local string S;

	Res.X = 0.0;
	Res.Y = 0.0;

	if(PC == None)
		return;

	S = PC.ConsoleCommand("GETCURRENTRES");
	i = InStr(S, "x");
	Res.X = float(Left(S, i));
	Res.Y = float(Mid(S, i + 1));
}

/*
	Returns a scaling factor based on current resolution Y and YH. If YH is
	zero, the default value of 768 will be used.
*/
static final function float GetCanvasScale(PlayerController PC, optional float YH)
{
	local vector V;

	GetClientResolution(PC, V);

	if(YH == 0)
		return (V.Y / 768);

	return (V.Y / YH);
}

/*
	Gets the approprate font scaling factor for use with Canvas.FontScaleX
	and Canvas.FontScaleY.

	Size:		Desired font size in points. Note that this function
			converts to 96 PPI.

	MaxSize:	Represents the point size that was used when importing
			the font (e.g. P2Fonts.Fancy48 was imported at 48 points).
			Always assumes 72 PPI.

	CanvasScale:	Scales the return value by this amount (e.g. Y of client
			resolution divided by 768).
*/
static final function float GetFontScale(int Size, int MaxSize, float CanvasScale)
{
	return ((float(Size) * (96.0 / 72.0)) / MaxSize) * CanvasScale;
}

/*
	Sets the font scaling variables in Canvas.

	C:		Canvas reference
	Scale:		Scaling factor
*/
static final function SetFontScale(Canvas C, float Scale)
{
	C.FontScaleX = Scale;
	C.FontScaleY = Scale;
}

/*
	Resets the font scaling variables in Canvas.

	C:		Canvas reference
*/
static final function ResetFontScale(Canvas C)
{
	C.FontScaleX = C.Default.FontScaleX;
	C.FontScaleY = C.Default.FontScaleY;
}

/*
	Returns the drawing region stack.
*/
static final function array<UWindowBase.Region> GetDrawRegionStack()
{
	return Default.DrawRegionStack;
}

/*
	Sets a clipping region in Canvas and remembers the old region. Returns true
	if drawing region has been set.

	C:		Canvas object
	NewOrgX:	Value to be set in C.OrgX
	NewOrgX:	Value to be set in C.OrgY
	NewClipX:	Value to be set in C.ClipX
	NewClipY:	Value to be set in C.ClipY
*/
static final function bool SetDrawingRegion(Canvas C, float NewOrgX, float NewOrgY, float NewClipX, float NewClipY/*, optional float Border*/)
{
	local int i;

	Default.DrawRegionStack.Length = Default.DrawRegionStack.Length + 1;
	i = Default.DrawRegionStack.Length - 1;
	Default.DrawRegionStack[i].X = C.OrgX;
	Default.DrawRegionStack[i].Y = C.OrgY;
	Default.DrawRegionStack[i].W = C.ClipX;
	Default.DrawRegionStack[i].H = C.ClipY;

	NewClipX -= FMax(0, Default.DrawRegionStack[i].X - NewOrgX);
	NewClipY -= FMax(0, Default.DrawRegionStack[i].Y - NewOrgY);

	C.OrgX = FClamp(NewOrgX, Default.DrawRegionStack[i].X, Default.DrawRegionStack[i].X+Default.DrawRegionStack[i].W);
	C.OrgY = FClamp(NewOrgY, Default.DrawRegionStack[i].Y, Default.DrawRegionStack[i].Y+Default.DrawRegionStack[i].H);
	C.ClipX = FMin((Default.DrawRegionStack[i].X+Default.DrawRegionStack[i].W) - NewOrgX, NewClipX);
	C.ClipY = FMin((Default.DrawRegionStack[i].Y+Default.DrawRegionStack[i].H) - NewOrgY, NewClipY);
	return true;
}

/*
	Restores the last clipping region in the region stack. Returns true if
	the last region has been restored.

	C:		Canvas object.
*/
static final function bool UnsetDrawingRegion(Canvas C)
{
	local int i;

	if(Default.DrawRegionStack.Length == 0)
		return false;

	i = Default.DrawRegionStack.Length - 1;
	C.OrgX = Default.DrawRegionStack[i].X;
	C.OrgY = Default.DrawRegionStack[i].Y;
	C.ClipX = Default.DrawRegionStack[i].W;
	C.ClipY = Default.DrawRegionStack[i].H;
	Default.DrawRegionStack.Remove(i, 1);
	return true;
}

/*
	Special version of Canvas.SetPos() that does not take drawing origins
	into account. Needed for drawing inside clipping regions.
*/
static final function SetPos(Canvas C, float X, float Y)
{
	C.SetPos(X - C.OrgX, Y - C.OrgY);
}

///////////////////////////////////////////////////////////////////////////////
// Actor-related functions.
///////////////////////////////////////////////////////////////////////////////
/*
	Universal function for retrieving a percentage of ammo amount.

	W:		Weapon actor

	Returns ammo amount divided my max ammo. Otherwise if the weapon has no
	ammo type or has infinite ammo, a value of -1.0 is returned.
*/
static final function float GetAmmoPercent(Weapon W)
{
	if((W == None) || (P2AmmoInv(W.AmmoType) == None) || (P2AmmoInv(W.AmmoType).bInfinite))
		return -1.0;
		
	//ErikFOV Change: Fix problem
		/*if(P2GameInfoSingle(W.Level.Game) != None)
			return FClamp(float(P2AmmoInv(W.AmmoType).AmmoAmount) / P2AmmoInv(W.AmmoType).MaxAmmo, 0.0, 1.0);

		return FClamp(float(P2AmmoInv(W.AmmoType).AmmoAmount) / P2AmmoInv(W.AmmoType).MaxAmmoMP, 0.0, 1.0);*/
	return FClamp(float(P2AmmoInv(W.AmmoType).AmmoAmount) / P2AmmoInv(W.AmmoType).MaxAmmo, 0.0, 1.0);
	//End
}
