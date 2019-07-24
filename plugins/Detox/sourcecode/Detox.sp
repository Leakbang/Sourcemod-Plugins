#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "0.1"

#include <sourcemod>
#include <sdktools>
//To compile this plugin you need smlib because of the colored chat messages
#include <smlib>

//Create boolean variables
//Create a variable for each player
new DetoxON[MAXPLAYERS + 1];
new bool:DebugOn;

//Create a variable to assign a console variable to them
new Handle:h_DebugOn = INVALID_HANDLE;

public Plugin myinfo = 
{
	name = "Detox",
	author = PLUGIN_AUTHOR,
	description = "Detoxicator for use in hazardous environments",
	version = PLUGIN_VERSION,
	url = "https://github.com/Leakbang"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_detox", Detox, "Toggles detoxicator on and off. For use in hazardous areas");
	//Call the function when the match has started
	HookEvent("game_start", EventGameStart);
}


public EventGameStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	//Call the function when someone dies
	HookEvent("player_death", EventPlayerDeath);
}

public Action Detox(int client, int args)
{
	//Check if player is a valid client
	if (client == 0)
	{
		//The server command will not be processed
		return Plugin_Handled;
	}
	//If extra parameters were used with the command notify the player
	if(args != 0)
	{
		ReplyToCommand(client, "Usage: sm_detox | Toggles detoxicator on and off. For use in hazardous environments");
		return Plugin_Handled;
	}
	//Check the variable for the player if true change it to false and vice versa
	if (DetoxON[client] == 1)
	{
		DetoxON[client] = 0;
		PrintToChat(client, "Detox Toggled Off");
	}
	else
	{
		DetoxON[client] = 1;
		PrintToChat(client, "Detox Toggled On");
	}
	return Plugin_Handled;
}

public EventPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	//Find who was killed and store them in the variable
	new player = GetClientOfUserId(GetEventInt(event, "userid"));
	//Find who was the killer and store them in the variable
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (DetoxON[player] == 1)
	{
		if (GetClientTeam(player) == GetClientTeam(attacker)) //Team kill
		{
			//Find a random number between the given min and max amounts and assign it to the newly created variable
			new rng = GetRandomInt(1, 5);
			//Based on the randomly generated number execute a command
			switch (rng)
			{
				case 1: { Client_PrintToChat(player, true, "{G}Oof"); }
				case 2: { Client_PrintToChat(player, true, "{G}Now this sucks"); }
				case 3: { Client_PrintToChat(player, true, "{G}Have I ever told you the definition of insanity?"); }
				case 4: { Client_PrintToChat(player, true, "{G}Someone did an oopsie!"); }
				case 5: { Client_PrintToChat(player, true, "{G}He was never really on your side");}
			}
		}
		else if (GetClientTeam(player) != GetClientTeam(attacker)) //Normal kill
		{
			new rng = GetRandomInt(1, 4);
			switch (rng)
			{
				case 1: { Client_PrintToChat(player, true, "{G}Check THOSE corners -Cpt Price"); }
				case 2: { Client_PrintToChat(player, true, "{G}Well at least nobody saw that"); }
				case 3: { Client_PrintToChat(player, true, "{G}Hey don't worry! I still love you"); }
				case 4: { Client_PrintToChat(player, true, "{G}It was lag, probably..."); }
			}
		}
		else
		{
			new rng = GetRandomInt(1, 3); //Suicide
			switch (rng)
			{
				case 1: { Client_PrintToChat(player, true, "{G}Well I guess killing yourself works as well"); }
				case 2: { Client_PrintToChat(player, true, "{G}Taking the easy way out huh?"); }
				case 3: { Client_PrintToChat(player, true, "{G}Does the enemy team scare you that much?"); }
			}
		}
	}
}