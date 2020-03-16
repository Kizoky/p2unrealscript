///////////////////////////////////////////////////////////////////////////////
// ShellHSliderControl.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// A control that adds the ability to display the value of the slider in the
// text area.
//
// History:
//	01/09/03 JMI	Started.
//
///////////////////////////////////////////////////////////////////////////////
// This class is simply to allow us to replace the update the slider text on
// every value change for the slider.
//
// Future enhancements:
//	- Tick marks to show granularity.
//
///////////////////////////////////////////////////////////////////////////////
class ShellHSliderControl extends UWindowHSliderControl;

const c_strValToken = "~1";	// Token that gets replaced.
var string strFormat;		// Text format including optional token where slider 
							// value will go.

///////////////////////////////////////////////////////////////////////////////
// Set the text.  Called by the user of the control to set the text including
// an optional token to indicate a spot to show the actual slider value.  This
// call stores this format string and sets the text.
// Internal calls should probably go directly to the base class.
///////////////////////////////////////////////////////////////////////////////
function SetText(string strNewFormatText)
{
	strFormat = strNewFormatText;

	UpdateText();
}

///////////////////////////////////////////////////////////////////////////////
// Update the text in the control with the current value of the slider.  
// For efficiency, we could remember whether the token is present but it's not
// that big a deal.
///////////////////////////////////////////////////////////////////////////////
function UpdateText() 
{
	local int	 iTokenPos;
	local int	 iTokenLen;
	local string strNewText;
	// Find the token.
	iTokenPos = InStr(strFormat, c_strValToken);
	if (iTokenPos > -1)
	{
		iTokenLen	= Len(c_strValToken);
		strNewText	= Left(strFormat, iTokenPos);
		strNewText  = strNewText $ Value;
		strNewText  = strNewText $ Right(strFormat, Len(strFormat) - (iTokenPos + iTokenLen) );
	}
	else
		// Let's go ahead and do this so we don't have to update all the strings.
		// Hey..if we wanted, we could always add it after if it's not specified.  For now,
		// it simply uses the text as is and ignores the value.
		strNewText = strFormat @ Value;

	Super.SetText(strNewText);
}

///////////////////////////////////////////////////////////////////////////////
// SetValue override to update the dialog control text.
///////////////////////////////////////////////////////////////////////////////
function SetValue(float NewValue, optional bool bNoNotify)
{
	// Perform the normal set.
	Super.SetValue(NewValue, bNoNotify);
	// Do the update of the text to reflect the change, if any.
	UpdateText();
}
