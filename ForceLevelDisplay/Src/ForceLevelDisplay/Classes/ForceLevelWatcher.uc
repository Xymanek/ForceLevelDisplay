class ForceLevelWatcher extends Actor config(UI);

enum EMaxForceLevelDisplayMode
{
	eMaxFLMode_Never,
	eMaxFLMode_IfNot20,
	eMaxFLMode_Always
};

var protected int PreviousFL;
var protected XComHQPresentationLayer HQPres;

var config EMaxForceLevelDisplayMode MAX_FL_MODE;
var config string VALUE_COLOUR;

var localized string strForceLevelHeader;

event PostBeginPlay()
{
	local X2EventManager EventManager;
	local Object SelfObject;

	SaveCurrentFL();
	HQPres = `HQPRES;

	EventManager = `XEVENTMGR;
	SelfObject = self;

	// Lower priority so that we show as "first", even if other mods add readings to that bar
	EventManager.RegisterForEvent(SelfObject, 'UpdateResources', OnUpdateResources, ELD_Immediate, 20);
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
	local string strValue;
	local bool bShowMax;
	local int MaxFL;

	if (IsPlayerInGeoscape())
	{
		MaxFL = class'XComGameState_HeadquartersAlien'.default.AlienHeadquarters_MaxForceLevel;
		strValue = string(GetCurrentFL());

		switch (MAX_FL_MODE)
		{
			case eMaxFLMode_IfNot20:
				bShowMax = MaxFL != 20;
			break;

			case eMaxFLMode_Always:
				bShowMax = true;
			break;
		}

		if (bShowMax)
		{
			strValue $= "/" $ MaxFL;
		}

		if (VALUE_COLOUR != "")
		{
			strValue = "<font color='#" $ VALUE_COLOUR $ "'>" $ strValue $ "</font>";
		}
		
		HQPres.m_kAvengerHUD.AddResource(strForceLevelHeader, strValue);
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