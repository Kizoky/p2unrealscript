class UBrowserUpdateServerTextArea extends UWindowHTMLTextArea;

var string StatusURL;

function LaunchUnrealURL(string URL)
{
	Super.LaunchUnrealURL(URL);

	GetParent(class'UWindowFramedWindow').Close();
	Root.ConsoleClose();
}

function BeforePaint(Canvas C, float X, float Y)
{
	StatusURL = "";
	Super.BeforePaint(C, X, Y);
}

function OverURL(string URL)
{
	StatusURL = URL;
}