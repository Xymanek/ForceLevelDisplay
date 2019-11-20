class UIListener_AvengerHUD extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	if (UIAvengerHUD(Screen) == none) return;

	Screen.Spawn(class'ForceLevelWatcher');
}