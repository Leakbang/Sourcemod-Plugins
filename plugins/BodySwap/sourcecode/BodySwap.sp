//Many thanks to Hexah and JoinedSenses for helping me with this code
#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

new Bool: Selection;

float EPV[3];
float EAV[3];
float EPV2[3];
float EAV2[3];

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
	ServerCommand("bot_mimic 100");
}

public Action Swap (int client, int args) {
	CreateMainMenu().Display(client, MENU_TIME_FOREVER);
}

Menu CreateMainMenu() {
	Menu MainMenu = new Menu(MainHandler);

	MainMenu.SetTitle("Body Swap Menu");
	
	MainMenu.AddItem("target1", "Select Player 1");
	MainMenu.AddItem("target2", "Select Player 2");
	MainMenu.AddItem("swap", "Swap Players");
	
	return MainMenu;
}

Menu CreateSelectMenu() {
	Menu SelectMenu = new Menu(SelectHandler);
	
	if (Selection) SelectMenu.SetTitle("Select Target 2");
	else SelectMenu.SetTitle("Select Target 1");
	
	char userid[6];
	char playerName[MAX_NAME_LENGTH];
	
	for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            FormatEx(userid, sizeof(userid), "%i", GetClientUserId(i));
            GetClientName(i, playerName, sizeof(playerName));
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


			if (StrEqual(info, "target1"))
			{
				Selection = 0;
				CreateSelectMenu().Display(param1, MENU_TIME_FOREVER);
			}
			else if (StrEqual(info, "target2"))
			{
				Selection = 1;
				CreateSelectMenu().Display(param1, MENU_TIME_FOREVER);
			}
			else if (StrEqual(info, "swap"))
			{
				if (Player1 && Player2 == -1) {
					PrintToChat(param1, "Please select Player1 and Player2");
				}
				else SwapPosition();
				PrintToChat(param1, "Swapping players...");
				CreateMainMenu().Display(param1, MENU_TIME_FOREVER);
			}
		}
		else if (action == MenuAction_End)
		{
			delete menu;
		}

	return 1;
}

public int SelectHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
			char info[64];
			
			menu.GetItem(param2, info, sizeof(info));
			
			int sPlayer = GetClientOfUserId(StringToInt(info));
			
			if (!sPlayer) {
				return 0;
			}
			
			if(Selection) {
				Player2 = sPlayer;
				PrintToChat(param1, "[Player2] %N Has been selected", Player2);
			}
			else {
				Player1 = sPlayer;
				PrintToChat(param1, "[Player1] %N Has been selected", Player1);
			}
			
			CreateMainMenu().Display(param1, MENU_TIME_FOREVER);
			
	}
	else if (action == MenuAction_Cancel) {
		CreateMainMenu().Display(param1, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_End) {
		delete menu;
	}
}

public SwapPosition () {
	GetClientEyePosition(Player1, EPV);
	GetClientEyeAngles(Player1, EAV);
	
	GetClientEyePosition(Player2, EPV2);
	GetClientEyeAngles(Player2, EAV2);

	TeleportEntity(Player1, EPV2, EAV2, NULL_VECTOR);
	TeleportEntity(Player2, EPV, EAV, NULL_VECTOR);
}