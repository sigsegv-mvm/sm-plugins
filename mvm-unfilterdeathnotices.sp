#include <sourcemod>
#include <tf2>
#include <tf2_stocks>


public Plugin myinfo = {
	name        = "[MvM] Unfilter death notices",
	author      = "sigsegv",
	description = "Show death notices for all kills in MvM",
	version     = "20151230",
	url         = "https://github.com/sigsegv-mvm/sm-plugins",
};


#define TF_DEATHFLAG_MINIBOSS (1 << 9)


ConVar g_cvar_enabled = null;


stock bool IsMannVsMachineMode()
{
	return (GameRules_GetProp("m_bPlayingMannVsMachine") != 0);
}


public void OnPluginStart()
{
	g_cvar_enabled = CreateConVar("sm_mvm_unfilter_deathnotices", "1",
		"Show death notices for all kills in MvM");
	
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (IsMannVsMachineMode() && g_cvar_enabled.BoolValue) {
		int death_flags = event.GetInt("death_flags");
		if ((death_flags & TF_DEATHFLAG_MINIBOSS) == 0) {
			event.SetInt("death_flags", (death_flags | TF_DEATHFLAG_MINIBOSS));
		}
	}
	
	return Plugin_Continue;
}
