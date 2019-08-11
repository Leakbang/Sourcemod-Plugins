//Many thanks to Hexah and JoinedSenses for helping me with this code
#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

//Define a boolean variable to detect a player's selection later in the code
new Bool: Selection;

//Create Variables to store vector position and looking angles of players
float EPV[3];
float EAV[3];
float EPV2[3];
float EAV2[3];

//Define variables to store player objects
int Player1;
int Player2;

public Plugin myinfo = 
{
	name = "Body Swap",
	author = PLUGIN_AUTHOR,
	description = "Swap position of players",
	version = PLUGIN_VERSION,
	url = "https://github.com/Leakbang"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_swap", Swap, ADMFLAG_CHEATS, "Bring up Swapping menu");
	//The bots will mimic the player at the index of 100 but this number won't be probably reached unless you have 100 players on the server at which point the bots will mimic that player
	//This is required for bots otherwise after the body swap they won't look in the specified direction
	ServerCommand("bot_mimic 100");
}

public Action Swap (int client, int args) {
	//Display the menu for the admin who just executed this command
	CreateMainMenu().Display(client, MENU_TIME_FOREVER);
}

Menu CreateMainMenu() {
	//Create the main menu and assign the handler to it
	Menu MainMenu = new Menu(MainHandler);

	//Set the main menu title
	MainMenu.SetTitle("Body Swap Menu");

	//Add buttons to the menu
	MainMenu.AddItem("target1", "Select Player 1");
	MainMenu.AddItem("target2", "Select Player 2");
	MainMenu.AddItem("swap", "Swap Players");
	
	return MainMenu;
}

Menu CreateSelectMenu() {
	Menu SelectMenu = new Menu(SelectHandler);
	
	//Based on the variable value set the title accordingly
	if (Selection) SelectMenu.SetTitle("Select Target 2");
	else SelectMenu.SetTitle("Select Target 1");
	
	//Variables to store player name and userid
	char userid[6];
	char playerName[MAX_NAME_LENGTH];
	
	//Loop through all players
	for (int i = 1; i <= MaxClients; i++) {
		//Check if each player is valid
        if (IsClientInGame(i)) {
			//Get and store their name and userid in the variables
            FormatEx(userid, sizeof(userid), "%i", GetClientUserId(i));
            GetClientName(i, playerName, sizeof(playerName));
			//Add the player to the list
            SelectMenu.AddItem(userid, playerName);
        }
    }
	
	return SelectMenu;
}


public int MainHandler(Menu menu, MenuAction action, int param1, int param2) {
	
		if (action == MenuAction_Select)
		{
			char info[64];
			menu.GetItem(param2, info, sizeof(info));

			//If button 1 is selected...
			if (StrEqual(info, "target1"))
			{
				//Set the variable to false
				Selection = 0;
				//Display the selection menu
				CreateSelectMenu().Display(param1, MENU_TIME_FOREVER);
			}
			//If button 2 is selected...
			else if (StrEqual(info, "target2"))
			{
				//Set the variable to true
				Selection = 1;
				//Display the selection menu
				CreateSelectMenu().Display(param1, MENU_TIME_FOREVER);
			}
			//If button 3 is selected...
			else if (StrEqual(info, "swap"))
			{
				//Check if both players are valid and selected
				if (Player1 && Player2 == -1) {
					PrintToChat(param1, "Please select Player1 and Player2");
				}
				else SwapPosition();
				PrintToChat(param1, "Swapping players...");
				CreateMainMenu().Display(param1, MENU_TIME_FOREVER);
			}
		}
		//If quit button is selected...
		else if (action == MenuAction_End)
		{
			//Close the menu
			delete menu;
		}

	return 1;
}

public int SelectHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
			char info[64];
			menu.GetItem(param2, info, sizeof(info));
			//Get and store the player who was selected from the list
			int sPlayer = GetClientOfUserId(StringToInt(info));
			
			//Check if the selected player isn't valid
			if (!sPlayer) {
				return 0;
			}
			//Based on the variable value execute commands accordingly
			//This was done to keep things clean and instead of having 2 separate menus for selecting each player there can just be 1 menu
			if(Selection) {
				//Assign the selected player to [Player2] global variable so it can be read and modified from different parts of the code
				Player2 = sPlayer;
				PrintToChat(param1, "[Player2] %N Has been selected", Player2);
			}
			else {
				Player1 = sPlayer;
				PrintToChat(param1, "[Player1] %N Has been selected", Player1);
			}
			//After the player is selected, send the client back to the main menu
			CreateMainMenu().Display(param1, MENU_TIME_FOREVER);
			
	}
	//If quit button is selected...
	else if (action == MenuAction_Cancel) {
		//Send the client back to the main menu
		CreateMainMenu().Display(param1, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_End) {
		delete menu;
	}
}

public SwapPosition () {
	//Get and store vector position and looking angles of both players
	GetClientEyePosition(Player1, EPV);
	GetClientEyeAngles(Player1, EAV);
	
	GetClientEyePosition(Player2, EPV2);
	GetClientEyeAngles(Player2, EAV2);

	//Swap their positions and looking angles
	TeleportEntity(Player1, EPV2, EAV2, NULL_VECTOR);
	TeleportEntity(Player2, EPV, EAV, NULL_VECTOR);
}