///////////////////////////////////////////////////////////////////////////////
// CustomAnimAction
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// This is a sequence of animations for a pawn to play in PawnInitialState
// or InterestPoint. Also supports firing triggers at certain points and
// adding/removing boltons.
//
// Flexibility is limited because this is all intended to be used in
// PersonController. If you need a wider variety of actions you should be using
// an AI script instead.
///////////////////////////////////////////////////////////////////////////////
class CustomAnimAction extends Object
	editinlinenew
	hidecategories(Object);

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, etc.
///////////////////////////////////////////////////////////////////////////////
struct AnimAction
{
	var() name AnimName;		// Name of anim sequence to play
	var() float AnimRate;		// Rate to play at. If 0, defaults to 1.0
	var() float TweenTime;		// Time to tween anim. If 0, defaults to 0.15
	var() float Duration;		// How long to play. If 0, plays infinitely
	var() int LoopCount;		// Number of times to loop. If 0, loops infinitely
	var() name PreTrigger;		// Event to trigger when starting this action
	var() name PostTrigger;		// Event to trigger when completing this action
	var() bool bAddBolton;		// If true, adds temp bolton at the START of this action
	var() bool bDestroyBolton;	// If true, destroys temp bolton at the END of this action
};

struct IBoltOn
	{
	var() Name bone;								// Name of bone to attach to
	var() Mesh mesh;								// Mesh to use
	var() StaticMesh staticmesh;					// Static mesh to use
	var() Material skin;							// Skin to use (leave blank to use default skin)
	var() bool bAttachToHead;						// Whether or not this attaches to the head or the body
	var() float DrawScale;
	};

var() array<AnimAction> Actions;	// List of actions to take
var() IBoltOn Bolton;				// Define a bolton
var() int LoopCount;				// Number of times to loop this action. 0 = loop infinitely, -1 = loop infinitely AND pick random actions
var() name PreTrigger;				// Name of event to trigger before beginning entire set
var() name PostTrigger;				// Name of event to trigger after all sets are completed normally, before looping (if applicable)
var() name ExitTrigger;				// Name of event to trigger when exiting custom animation
var() name CollidingStaticMeshTag;		// Turns off collision for these static meshes while running
var() float CollidingStaticMeshRadius;	// Radius that must be cleared before collision is re-enabled
