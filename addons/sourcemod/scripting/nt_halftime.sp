#include <sourcemod>
#include <dhooks>
#include <neotokyo>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.0.1"

public Plugin myinfo =
{
	name		= "NT Half-Time",
	description = "Prevents side swap until halftime",
	author		= "Agiel",
	version		= PLUGIN_VERSION,
	url			= "https://github.com/Agiel/nt-halftime"
};

ConVar g_hRoundLimit;
ConVar g_hHalfTimeEnabled;
ConVar g_hHalftimeReset;

public void OnPluginStart()
{
	CreateDetour();

	CreateConVar("sm_nt_halftime_version", PLUGIN_VERSION, "NT Half-Time version", FCVAR_DONTRECORD);
	g_hHalfTimeEnabled = CreateConVar("sm_nt_halftime_enabled", "0", "Whether to enable half time", FCVAR_ARCHIVE, true, 0.0, true, 1.0);
	g_hHalftimeReset   = CreateConVar("sm_nt_halftime_reset", "1", "Whether to reset scores when swapping sides", FCVAR_ARCHIVE, true, 0.0, true, 1.0);
}

public void OnAllPluginsLoaded()
{
	g_hRoundLimit = FindConVar("sm_competitive_round_limit");
	if (!g_hRoundLimit)
	{
		SetFailState("This plugin should only be used together with nt_competitive");
	}
}

void CreateDetour()
{
	Handle gd = LoadGameConfigFile("neotokyo/halftime");
	if (gd == INVALID_HANDLE)
	{
		SetFailState("Failed to load GameData");
	}
	DynamicDetour dd = DynamicDetour.FromConf(gd, "Fn_StartNewRound");
	if (!dd)
	{
		SetFailState("Failed to create dynamic detour");
	}
	if (!dd.Enable(Hook_Pre, StartNewRound))
	{
		SetFailState("Failed to detour");
	}
	delete dd;
	CloseHandle(gd);
}

MRESReturn StartNewRound(Address pThis, DHookReturn hReturn)
{
	if (!g_hHalfTimeEnabled.BoolValue)
	{
		return MRES_Ignored;
	}

	int roundLimit	   = g_hRoundLimit.IntValue;
	int m_iRoundNumber = GameRules_GetProp("m_iRoundNumber");	 // 0 indexed because we haven't actually started the new round yet

	// Set the attacking team to the opposite of what we want. The real method will toggle.
	if (m_iRoundNumber < roundLimit / 2)
	{
		GameRules_SetProp("m_iAttackingTeam", TEAM_NSF);
	}
	else if (m_iRoundNumber < roundLimit)
	{
		GameRules_SetProp("m_iAttackingTeam", TEAM_JINRAI);
	}
	// else keep swapping every round during sudden death

	// Half-time reached
	if (m_iRoundNumber == roundLimit / 2)
	{
		PrintToChatAll("Half-time reached. Swapping sides...");
		if (g_hHalftimeReset.BoolValue)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					SetPlayerXP(i, 0);
				}
			}
		}
	}

	return MRES_Handled;
}
