///////////////////////////////////////////////////////////////////////////////
// MutNoCTFNoTouchReturns
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
//
///////////////////////////////////////////////////////////////////////////////
class MutCTFNoTouchReturns extends Mutator;

///////////////////////////////////////////////////////////////////////////////
// Make it so when the girl is dropped she can't be returned by touching--she
// only goes back after 20 seconds. This means that the guys that killed the
// guy to drop the girl must defend her for 20 seconds or else the other team
// can come to where she was dropped and just pick her back up again.
///////////////////////////////////////////////////////////////////////////////
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(CTFFlag(Other) != None)
	{
		CTFFlag(Other).bNoTouchReturns=true;
		CTFFlag(Other).MaxDropTime = 20;
	}
	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool MutatorIsAllowed()
{
	return true;
}

defaultproperties
{
	GroupName="CTFFlagReturn"
	FriendlyName="CTF No Touch Return"
	Description="Only for Snatch-CTF games.  Turns off being able to return a dropped chick by touching her.  Instead she'll stay there for 20 seconds and then automatically return.  This leaves her vulnerable to attack and forces her team to guard her."
}