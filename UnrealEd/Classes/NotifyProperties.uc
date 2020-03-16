class NotifyProperties extends Object
	native
	hidecategories(Object)
	collapsecategories;

cpptext
{
	void PostEditChange();
}

var int OldArrayCount;
var const int WBrowserAnimationPtr;

struct native NotifyInfo
{
	var() FLOAT NotifyFrame;
	var() editinlinenotify AnimNotify Notify;
	var INT OldRevisionNum;
};

var() Array<NotifyInfo> Notifys;
