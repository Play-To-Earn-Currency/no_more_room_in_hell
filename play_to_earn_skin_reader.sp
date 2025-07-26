// Based on the code of the plugin "Skins" by Grey83

#include <sdktools_functions>
#include <sdktools_stringtables>
#include <play_to_earn>

public Plugin myinfo =
{
    name        = "Skin Reader",
    description = "Read skins from a nmrih_skins database for each player",
    version     = SOURCEMOD_VERSION,
    author      = "GxsperMain",
    url         = "https://github.com/GxsperMain/nmrih_play_to_earn"
};

int  TotalSkins = 0;

bool bTPView[MAXPLAYERS + 1];

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);

    // Third Person command
    RegConsoleCmd("tps", ToggleView, "Enters in third person");

    enableSkinMenu = true;
    PrintToServer("[Skin Reader] Skin Reader plugin has been initialized");
}

public void OnMapStart()
{
    TotalSkins = 0;

    LoadSkinsToDownloadTable();
}

//
// Commands
//
stock Action ToggleView(int client, int args)
{
    if (IsFakeClient(client) || !IsPlayerAlive(client))
    {
        return Plugin_Handled;
    }

    if (bTPView[client])
    {
        bTPView[client] = false;
        SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", client);
        SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
        SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
        SetEntProp(client, Prop_Send, "m_iFOV", 90);
    }
    else
    {
        bTPView[client] = true;
        SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
        SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
        SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
        SetEntProp(client, Prop_Send, "m_iFOV", 70);
    }

    return Plugin_Handled;
}

//
// Events
//
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(1.0, Timer_Spawn, GetClientOfUserId(event.GetInt("userid")));
}

public Action Timer_Spawn(Handle timer, any client)
{
    Simple_EquippedSkin(client, OnReceiveEquippedSkin);
    return Plugin_Stop;
}

void OnReceiveEquippedSkin(int client, const char[] skinid)
{
    if (!IsValidClient(client))
    {
        PrintToServer("[Skin Reader] [OnReceiveEquippedSkin] Invalid client %d", client);
        return;
    }

    PrintToServer("[Skin Reader] [OnReceiveEquippedSkin] client %d received skinid: %s", client, skinid);

    UpdatePlayerSkin(client, skinid);
}

//
// Utils
//
stock void ApplyModel(const int client, const char[] model)
{
    SetEntityModel(client, model);
    SetEntityRenderColor(client);
}

stock void UpdatePlayerSkin(int client, const char[] skinid)
{
    int  steamId = GetSteamAccountID(client);

    char skinPath[PLATFORM_MAX_PATH];
    if (GetSkinModelPathBySkinID(skinid, skinPath, sizeof(skinPath)))
    {
        PrintToServer("[Skin Reader] [UpdatePlayerSkin] Changing player \"%d\" skin to: %s path: %s", steamId, skinid, skinPath);
        if (!IsModelPrecached(skinPath))
        {
            PrecacheModel(skinPath);
            ApplyModel(client, skinPath);
            TotalSkins++;
            PrintToServer("[Skin Reader] [UpdatePlayerSkin] TOTAL SKINS IN CACHE: %d", TotalSkins);
        }
        else {
            ApplyModel(client, skinPath);
        }
    }
}