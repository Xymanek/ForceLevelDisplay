class UIListener_AvengerHUD extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	if (UIAvengerHUD(Screen) != none)
	{
		Screen.Spawn(class'ForceLevelWatcher');
	}
}

event OnRemoved (UIScreen Screen)
{
	local ForceLevelWatcher ForceLevelWatcher;
	
	if (UIAvengerHUD(Screen) != none)
	{
		foreach Screen.AllActors(class'ForceLevelWatcher', ForceLevelWatcher)
		{
			ForceLevelWatcher.Destroy();
		}
	}
}