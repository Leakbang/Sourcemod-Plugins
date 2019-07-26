#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
//To compile this plugin you need smlib because of the colored chat messages
#include <smlib>

//Create a boolean variable
new bool:NoSuicide;

//Create a variable to assign a console variable to them
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
	//Call the function when the match has started
	HookEvent("game_start", EventGameStart);
}

public EventGameStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	//Call the function when any of these commands are ran
	AddCommandListener(CommandBlocker, "kill");
	AddCommandListener(CommandBlocker, "explode");
}

public Action CommandBlocker(int client, const char[] command, int argc)
{
	//Hook the created boolean variables to the convars
	NoSuicide = GetConVarBool(h_NoSuicide);
	//Check the boolean value if true execute the following command(s)
	if (NoSuicide)
	{
		Client_PrintToChat(client, true, "{R}%s command is disabled during a match", command);
		//The command will not be processed
		return Plugin_Handled;
	}
	//Continue normally if the boolean value is false
	else return Plugin_Continue;
}