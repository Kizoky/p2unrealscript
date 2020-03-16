class BoltonDef extends Object
	editinlinenew;

// The OtherBoltons struct was getting too big for its own good, so I made it
// into an Object class so that it could be defined better inline.

// An array of miscellaneous boltons that are good for any pawn in this class

// Lifestyles that can hold this bolton
enum ELifestyle
{
	Lifestyle_Any,
	Lifestyle_Straight,
	Lifestyle_Gay
};

// Date-limit this bolton based on user's computer date (seasonal DLC)
struct DateRange
{
	var() int YearMin, YearMax, MonthMin, MonthMax, DayMin, DayMax;
};

// Special flags to be set when this bolton is assigned
struct SpecialFlagStruct
{
	var() bool bLargeAndBulky;	// True if this should prevent the pawn from using anything other than the basic "walking around" anims until boltons are dropped
	var() name SpecialHoldWalkAnim;	// If non-empty, the pawn should use a special walk animation
	var() name SpecialHoldStandAnim;// If non-empty, pawn should use a special stand anim
	var() bool bValentine;		// True if for Valentine's Day, turns on Valentines Day interactions with other pawns
	var() bool bHalloween;		// True if a Halloween costume (Dude will make special remark when killing)
	var() bool bCigarette;		// True if this item is a cigarette, cigar, blunt, or some other object that can be smoked
	var() bool bIsHelmet;		// True if this is a sturdy helmet that protects you from sledgehammer whacks and reduces headshot damage
};

// Combine the various enums to restrict boltons to different types of people.
// For example, if you want a bolton that only fat gay males would wear, set Gender to Gender_Male, BodyType to Body_Fat, and Lifestyle to Lifestyle_Gay.
// Anything left to default (Any) will not play a factor in selection.

var() editinline array<P2MoCapPawn.SBoltOn> Boltons;	// Actual bolton record to be implemented. If more than one is specified, it picks randomly.
var() float UseChance;						// Chance of this bolton being added to any pawn.
var() FPSPawn.EGender Gender;				// Gender_Any, Gender_Male, or Gender_Female
var() FPSPawn.EBody BodyType;				// Body_Any, Body_Avg, or Body_Fat
var() FPSPawn.ERace Race;					// Race_Any, Race_White, Race_Black, Race_Mexican, Race_Asian, Race_Hindu, Race_Fanatic
var() ELifestyle Lifestyle;					// Any, Straight, or Gay
var() editinline array<Mesh> AllowedHeads;	// List of heads allowed to wear this bolton. If empty, assumes all heads
var() editinline array<Mesh> ExcludedHeads;	// List of heads excluded from wearing this bolton.
//var() bool bNoFemLH;						// True if long-hair females cannot wear (hair clips through bolton)
//var() bool bLargeAndBulky;					// True if this bolton should prevent the pawn from using complex animations
											// (briefcases and shit)
//var() bool bForceSmallHead;					// True if we want the chameleon to force the smallest possible head so the hat will fit.
var() name Tag;								// Bolton tag for exclusion										
var() name RareTag;							// Only one of any rare tag will spawn per map.
var() array<Name> ExcludeTags;				// If set, this bolton will not appear alongside other boltons with this tag.
var() array<Name> IncludeTags;				// If set, and the pawn is wearing another bolton matches this tag, it will wear this bolton as well (assuming the above criteria are met)
var() array<Mesh> IncludedMeshes;			// Only these meshes will be considered for this bolton.
var() array<Mesh> ExcludedMeshes;			// These meshes will be excluded from this bolton.
var() array<Material> IncludeSkins;			// Only these skins will be considered for this bolton.
var() array<Material> ExcludeSkins;			// These skins will be excluded from this bolton.
var() Material BodySkin;					// If specified, replaces the body skin with this material. (Halloween costumes) Careful - does not change the race, gender, mesh, etc
var() Material HeadSkin;					// If specified, replaces the head skin with this material. (Halloween costumes) Careful - does not change race, gender, mesh, etc
var() Mesh HeadMesh;						// If specified, replaces the head mesh with this mesh. (Halloween costumes) Intended for use with HeadSkin, be careful when using
var() DateRange ValidDates;					// Bolton only valid during these dates (seasonal decorations)
var() Name ValidHoliday;					// Bolton only valid during this holiday.
var() Name InvalidHoliday;					// Bolton invalid during this holiday.
var() SpecialFlagStruct SpecialFlags;		// Special flags to be set on the pawn

defaultproperties
{
}