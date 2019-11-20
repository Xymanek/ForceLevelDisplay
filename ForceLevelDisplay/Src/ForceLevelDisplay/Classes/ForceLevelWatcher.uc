class ForceLevelWatcher extends Actor;

var protected int PreviousFL;
var protected XComHQPresentationLayer HQPres;

var localized string strForceLevelHeader;

event PostBeginPlay()
{
	local X2EventManager EventManager;
	local Object SelfObject;

	SaveCurrentFL();
	HQPres = `HQPRES;

	EventManager = `XEVENTMGR;
	SelfObject = self;

	EventManager.RegisterForEvent(SelfObject, 'UpdateResources', OnUpdateResources);
}

event Tick (float DeltaTime)
{
	if (PreviousFL != GetCurrentFL() && IsPlayerInGeoscape())
	{
		HQPres.m_kAvengerHUD.UpdateResources();
	}

	SaveCurrentFL();
}

protected function EventListenerReturn OnUpdateResources (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (IsPlayerInGeoscape())
	{
		HQPres.m_kAvengerHUD.AddResource(strForceLevelHeader, string(GetCurrentFL()));
	}

	return ELR_NoInterrupt;
}

protected function SaveCurrentFL ()
{
	PreviousFL = GetCurrentFL();
}

protected function int GetCurrentFL ()
{
	return class'UIUtilities_Strategy'.static.GetAlienHQ().ForceLevel;
}

protected function bool IsPlayerInGeoscape ()
{
	return HQPres.ScreenStack.GetCurrentScreen() == HQPres.StrategyMap2D;
}

event Destroyed ()
{
	local X2EventManager EventManager;
	local Object SelfObject;

	EventManager = `XEVENTMGR;
	SelfObject = self;

	EventManager.UnRegisterFromAllEvents(SelfObject);
}

defaultproperties
{
	PreviousFL = -1;

	// Make sure we tick after XGGeoscape, otherwise we might lag behind 1 frame on the update
	TickGroup = TG_PostAsyncWork
}