//=============================================================================
// UWindowClientWindow - a blanked client-area window.
//=============================================================================
class UWindowClientWindow extends UWindowWindow;

#exec TEXTURE IMPORT NAME=Background FILE=Textures\Background.pcx GROUP="Icons" MIPS=OFF

// RWS CHANGE: Added various options for drawing client area
var bool	bNoClientBorder;	// used to hide standard border graphics
var Texture	ClientBg;			// background texture (or None)
var bool	bClientStretchBg;	// whether to strech background to fill client area
var int		ClientAlpha;		// 0 for normal draw style, 1 to 255 for alpha
// RWS CHANGE: end

function Close(optional bool bByParent)
{
	if(!bByParent)
		ParentWindow.Close(bByParent);

	Super.Close(bByParent);
}
