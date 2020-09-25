class UWindowHSliderControl extends UWindowDialogControl;


var	float			MinValue;
var	float			MaxValue;
var	float			Value;
var	int				Step;		// 0 = continuous
					
var	float			SliderWidth;
var	float			SliderDrawX, SliderDrawY;
var float			TrackStart;
var float			TrackWidth;
var bool			bSliding;
var bool			bNoSlidingNotify;
var bool			bDisplayVal;	// RWS CHANGE: 01/15/03 JMI Added optional display of value.
var float			ValX;			// RWS CHANGE: 01/15/03 JMI Added optional display of value.
var float			ValY;			// RWS CHANGE: 01/15/03 JMI Added optional display of value.
var color			ValColor;		// RWS CHANGE: 01/15/03 JMI Added optional display of value.
var float			fTickLen;		// RWS CHANGE: 01/16/03 JMI Added optional display of tick marks.
var array<string>	astrVals;		// RWS CHANGE: 01/19/03 JMI Added optional array of strings to display for value next to slider.
var float			TrackHeight;	// RWS CHANGE: 02/06/03 MJR Added height
var float			LastNotifiedValue;	// RWS CHANGE: 02/06/03 JMI Record actual last value notified rather than guessing with bNoSlidingNotify.

function Created()
{
	Super.Created();
	SliderWidth = WinWidth / 2;
	TrackWidth = 10;	// RWS CHANGE: Increased width so coffee-drinking humans can drag the damn thing around
	TrackHeight = 14;	// RWS CHANGE: Set height to match height of other controls
}

function SetRange(float Min, float Max, int NewStep)
{
	MinValue = Min;
	MaxValue = Max;
	Step = NewStep;
	Value = CheckValue(Value);
}

function float GetValue()
{
	return Value;
}

function SetValue(float NewValue, optional bool bNoNotify)
{
	local float OldValue;

	OldValue = Value;

	Value = CheckValue(NewValue);

	if(Value != OldValue && !bNoNotify)
	{
		// Notify
		Notify(DE_Change);
	}	
}


function float CheckValue(float Test)
{
	local float TempF;
	local float NewValue;
	
	NewValue = Test;
	
	if(Step != 0)
	{
		TempF = NewValue / Step;
		NewValue = Int(TempF + 0.5) * Step;
	}

	if(NewValue < MinValue) NewValue = MinValue;
	if(NewValue > MaxValue) NewValue = MaxValue;

	return NewValue;
}


// RWS CHANGE: 01/15/03 JMI Added optional display of value.
function SetValColor(color NewColor)
{
	ValColor = NewColor;
}

// RWS CHANGE: 01/19/03 JMI Added optional array of strings to display for value next to slider.
function SetVals(/*out */array<string> astrNewVals)	// Could pass by ref but decided to go with the flow and pass by val for now.  Ref might be useful if we have dynamic values.
{
	astrVals = astrNewVals;
}

// RWS CHANGE: 01/19/03 JMI Added optional array of strings to display for value next to slider.
// RWS CHANGE: 01/19/03 JMI Only display value as float if in smooth sliding mode; otherwise, display as whole number.
//				Added function since this'll be used in two spots.
function string GetValText()
{
	if (Value >= 0 && Value < astrVals.Length)
	{
		// If this value fits within the bounds of the value array.  Use the provided values rounded to the nearest index.
		return astrVals[Value];
	}
	else
	{
		if (Step == 0)
			return ""$Value;
		else
			return ""$int(Value);
	}
}


function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	local float fValW, fValH;
	
	Super.BeforePaint(C, X, Y);
	
	TextSize(C, Text, W, H);
// RWS CHANGE - don't change window height (screws up our menu item spacing)
//	WinHeight = H+1;

	// RWS CHANGE: 01/15/03 JMI Added optional display of value.
	if (bDisplayVal)
		TextSize(C, " "$GetValText(), fValW, fValH);	// Note space so text is not elbowing slider.  If space is after, it's not considered in the size.

	switch(Align)
	{
	case TA_Left:
		//SliderDrawX = WinWidth - SliderWidth;
		SliderDrawX = WinWidth - SliderWidth - TrackWidth*0.5; // Change by NickP: fix
		TextX = 0;
		ValX = SliderDrawX - fValW;
		break;
	case TA_Right:
		SliderDrawX = 0;	
		TextX = WinWidth - W;
		ValX = SliderDrawX + SliderWidth;
		break;
	case TA_Center:
		SliderDrawX = (WinWidth - (fValW + SliderWidth) ) / 2;	// 01/16/03 JMI Not sure I get what they're doing here.
		TextX = (WinWidth - (W + fValW) ) / 2;
		ValX = SliderDrawX - fValW;
		break;
	}

	SliderDrawY = (WinHeight - 2) / 2;
	TextY = (WinHeight - H) / 2;
	ValY  = TextY;

	// RWS CHANGE: Center this thing properly
	TrackStart = SliderDrawX + (SliderWidth * ((Value - MinValue)/(MaxValue - MinValue))) - (TrackWidth / 2);
//	TrackStart = SliderDrawX + (SliderWidth - TrackWidth) * ((Value - MinValue)/(MaxValue - MinValue));
}


function Paint(Canvas C, float X, float Y)
{
	local Texture T;
	local Region R;
	local float fIter;
	local float fScale;
	local float fRange;
	local float	fSliderHeight;
	local float fTickHeight;
	local color OldColor;

	T = GetLookAndFeelTexture();

	if(Text != "")
	{
// RWS CHANGE: Let the LookAndFeel draw the text
		LookAndFeel.Control_DrawText(self, C);
//		C.DrawColor = TextColor;
//		ClipText(C, TextX, TextY, Text);
//		C.SetDrawColor(255,255,255);
	}
	
	R = LookAndFeel.HLine;
	fSliderHeight = R.H;
	DrawStretchedTextureSegment( C, SliderDrawX, SliderDrawY, SliderWidth, fSliderHeight, R.X, R.Y, R.W, R.H, T);
	
	// RWS CHANGE: 01/16/03 JMI Added optional display of tick marks.
	if (fTickLen != 0 && Step > 0)
	{
		fRange = (MaxValue - MinValue);
		// Do a sanity check.  If, at this scale, there's more than one tick per two pixels, there's no point.
		// If there's more than one tick per four pixels, it looks crowded.
		if (fRange / Step < SliderWidth / 4)
		{
			R = LookAndFeel.HLine;

			fScale = (SliderWidth - 1) / fRange;
			fTickHeight = fTickLen * 4;
			for (fIter = 0; fIter <= fRange; fIter += Step)
			{
				DrawStretchedTextureSegment( C, SliderDrawX + fIter * fScale, (SliderDrawY + fSliderHeight / 2) - (fTickHeight / 2), R.W, fTickHeight, R.X, R.Y, R.W, R.H, T);
			}
		}
	}

	// RWS CHANGE: Adjust Y position to take height into account
	DrawUpBevel(C, TrackStart, (SliderDrawY + fSliderHeight / 2) - (TrackHeight/2), TrackWidth, TrackHeight, T);

	// RWS CHANGE: 01/15/03 JMI Added optional display of value.
	if (bDisplayVal)
	{
		Oldcolor = C.DrawColor;
		C.DrawColor = ValColor;
		C.DrawColor.A = OldColor.A;

		// 01/19/03 JMI Only display value as float if in smooth sliding mode; otherwise, display as whole number.
		ClipText(C, ValX, ValY, GetValText() );
		C.DrawColor = OldColor;
//		C.SetDrawColor(255,255,255);
	}
}

// RWS CHANGE: 02/06/03 JMI Now we note what the value was when we notify of a change.  This way, later, we can tell
//							if we have or have not notified of that/those particular value change(s).  Otherwise, and
//							this is all speculation but, in the LMouseDown it seems they had to assume to always notify 
//							b/c it was possible the LMouseUp was missed if the cursor left the area.  Additionally, they
//							couldn't blindly ignore all LMouseUps in case there was a sliding value change while 
//							bNoSlidingNotify was set to true, in which case the LMouseUp is the last chance to update
//							the notifyee.  However, it does seem that, if that worked, the LMouseUp was clearly being
//							processed or we would have never received an update if the user dragged out of the area.
//							Okay, I just verified the above.  With bNoSlidingNotify = true, if you pass bNoSlidingNotify 
//							to the SetValues in LMouseDown and then click and drag outside of the slider, you never get
//							the LMouseUp and, therefore, never update the notifyee about the change resulting in the
//							slider and the caller being out of synch.
//							With this new technique, it's not all guesswork--we can positively tell when we have not
//							yet updated the notifyee.  It also simplifies the code in that there's no need to
//							go checking if it's okay to call Notify() in the non-sliding spots.  Of course, in the
//							sliding code, MouseMove(), we'd still need these checks so we'll keep SetValue taking
//							the bNoNotify value but I believe that should be the -only- spot.
function Notify(byte E)
{
	switch (E)
	{
	case DE_Change:
		if (LastNotifiedValue != Value)
		{
			super.Notify(E);
			LastNotifiedValue = Value;
		}
		break;
	default:
		super.Notify(E);
		break;
	}
}

function LMouseUp(float X, float Y)
{
	Super.LMouseUp(X, Y);

	Notify(DE_Change);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);
	// RWS CHANGE - let LookAndFeel do feedback
	LookAndFeel.Control_Click(self);

	/*
	if((X >= TrackStart) && (X <= TrackStart + TrackWidth)) {
		bSliding = True;
		Root.CaptureMouse();
	}

	if(X < TrackStart && X > SliderDrawX)
	{
		if(Step != 0)
			SetValue(Value - Step);
		else
			SetValue(Value - 1);
	}
	
	if(X > TrackStart + TrackWidth && X < SliderDrawX + SliderWidth)
	{
		if(Step != 0)
			SetValue(Value + Step);
		else
			SetValue(Value + 1);
	}
	*/
	// Screw this shit... just go sliding
	SetValue((((X - SliderDrawX) / (SliderWidth - TrackWidth)) * (MaxValue - MinValue)) + MinValue, bNoSlidingNotify);
	bSliding = True;
	Root.CaptureMouse();
}

function MouseMove(float X, float Y)
{
	Super.MouseMove(X, Y);
	if(bSliding && bMouseDown)
	{
		SetValue((((X - SliderDrawX) / (SliderWidth - TrackWidth)) * (MaxValue - MinValue)) + MinValue, bNoSlidingNotify);
	}
	else
		bSliding = False;
}

// RWS CHANGE - let LookAndFeel do feedback
function MouseEnter()
{
	Super.MouseEnter();
	LookAndFeel.Control_MouseEnter(self);
}

// RWS CHANGE - let LookAndFeel do feedback
function MouseLeave()
{
	Super.MouseLeave();
	LookAndFeel.Control_MouseLeave(self);
}

function KeyDown(int Key, float X, float Y)
{
	local Interaction C;

	C = GetPlayerOwner().Player.Console;

	switch (Key)
	{
	case C.EInputKey.IK_Left:
		if(Step != 0)
			SetValue(Value - Step);
		else
			SetValue(Value - 1);

		break;
	case C.EInputKey.IK_Right:
		if(Step != 0)
			SetValue(Value + Step);
		else
			SetValue(Value + 1);

		break;
	case C.EInputKey.IK_Home:
		SetValue(MinValue);
		break;
	case C.EInputKey.IK_End:
		SetValue(MaxValue);
		break;
	default:
		Super.KeyDown(Key, X, Y);
		break;
	}
}