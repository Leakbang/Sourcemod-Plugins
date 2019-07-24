#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <smlib>

new bool:NoSuicide;

new Handle:h_NoSuicide = INVALID_HANDLE;

public Plugin myinfo = 
{
	name = "Suicide Blocker",
	author = PLUGIN_AUTHOR,
	description = "Prevents players from committing suicide with console commands",
	version = PLUGIN_VERSION,
	url = "https://github.com/Leakbang"
};

public void OnPluginStart()
{
	h_NoSuicide = CreateConVar("sm_blocksuicides", "1", "Use values 1/0 to enable suicide blocker on this server");
	HookEvent("game_start", EventGameStart);
}

public EventGameStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	AddCommandListener(CommandBlocker, "kill");
	AddCommandListener(CommandBlocker, "explode");
}

public Action CommandBlocker(int client, const char[] command, int argc)
{
	NoSuicide = GetConVarBool(h_NoSuicide);
	if (NoSuicide)
	{
		Client_PrintToChat(client, true, "{R}%s command is disabled during a match", command);
		return Plugin_Handled;
	}
	else return Plugin_Continue;
}