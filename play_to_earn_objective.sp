#include <sourcemod>
#include <play_to_earn>

public Plugin myinfo =
{
    name        = "Play To Earn",
    author      = "Gxsper",
    description = "Play to Earn for No More Room in Hell",
    version     = SOURCEMOD_VERSION,
    url         = "https://github.com/GxsperMain/nmrih_play_to_earn"
};

static int   lastPlayerScore[MAXPLAYERS];
static int   isDeadPlayer[MAXPLAYERS];
static int   objectivesCompleted          = 0;
static bool  objectiveInCooldown          = false;
static float objectiveCooldown            = 5.0;

static int   maxObjectives                = 15;
static char  objectiveRewards[15][20]     = { "200000000000000000", "20000000000000000", "300000000000000000",
                                         "300000000000000000", "400000000000000000", "400000000000000000",
                                         "500000000000000000", "500000000000000000", "500000000000000000",
                                         "500000000000000000", "500000000000000000", "500000000000000000",
                                         "500000000000000000", "500000000000000000", "500000000000000000" };
static char  objectiveRewardsShow[15][20] = { "0.2", "0.2", "0.3",
                                             "0.3", "0.4", "0.4",
                                             "0.5", "0.5", "0.5",
                                             "0.5", "0.5", "0.5",
                                             "0.5", "0.5", "0.5" };
static int   scorePoints[20]              = { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100 };
static char  scoreRewards[20][20]         = {
    "100000000000000000",
    "150000000000000000",
    "200000000000000000",
    "250000000000000000",
    "300000000000000000",
    "350000000000000000",
    "400000000000000000",
    "450000000000000000",
    "500000000000000000",
    "550000000000000000",
    "600000000000000000",
    "650000000000000000",
    "700000000000000000",
    "750000000000000000",
    "800000000000000000",
    "850000000000000000",
    "900000000000000000",
    "950000000000000000",
    "1000000000000000000",
    "1050000000000000000"
};
static char scoreRewardsShow[20][20] = { "0.1", "0.15", "0.2",
                                         "0.25", "0.3", "0.35",
                                         "0.4", "0.45", "0.5",
                                         "0.55", "0.6", "0.65", "0.7",
                                         "0.75", "0.8", "0.85",
                                         "0.9", "0.95", "1.0",
                                         "1.05" };

public void OnPluginStart()
{
    char commandLine[128];
    if (GetCommandLine(commandLine, sizeof(commandLine)))
    {
        if (StrContains(commandLine, "-pteObjective 1") == -1)
        {
            PrintToServer("[PTE Objective] Will not be initialized, 'pteObjective' is not '1'");
            return;
        }
    }

    // Configuration Load
    {
        char configPath[] = "addons/sourcemod/configs/play_to_earn_objective.cfg";

        if (!FileExists(configPath))
        {
            Handle file = OpenFile(configPath, "w");
            if (file != null)
            {
                WriteFileLine(file, "\"PlayToEarn\"");
                WriteFileLine(file, "{");

                WriteFileLine(file, "    \"maxObjectives\"       \"15\"");
                WriteFileLine(file, "");

                WriteFileLine(file, "    \"objectiveRewards\"");
                WriteFileLine(file, "    {");
                WriteFileLine(file, "        \"0\"  \"100000000000000000\"");
                WriteFileLine(file, "        \"1\"  \"10000000000000000\"");
                WriteFileLine(file, "        \"2\"  \"100000000000000000\"");
                WriteFileLine(file, "        \"3\"  \"100000000000000000\"");
                WriteFileLine(file, "        \"4\"  \"200000000000000000\"");
                WriteFileLine(file, "        \"5\"  \"200000000000000000\"");
                WriteFileLine(file, "        \"6\"  \"200000000000000000\"");
                WriteFileLine(file, "        \"7\"  \"200000000000000000\"");
                WriteFileLine(file, "        \"8\"  \"200000000000000000\"");
                WriteFileLine(file, "        \"9\"  \"200000000000000000\"");
                WriteFileLine(file, "        \"10\" \"200000000000000000\"");
                WriteFileLine(file, "        \"11\" \"200000000000000000\"");
                WriteFileLine(file, "        \"12\" \"200000000000000000\"");
                WriteFileLine(file, "        \"13\" \"200000000000000000\"");
                WriteFileLine(file, "        \"14\" \"300000000000000000\"");
                WriteFileLine(file, "    }");
                WriteFileLine(file, "");

                WriteFileLine(file, "    \"objectiveRewardsShow\"");
                WriteFileLine(file, "    {");
                WriteFileLine(file, "        \"0\"  \"0.1\"");
                WriteFileLine(file, "        \"1\"  \"0.1\"");
                WriteFileLine(file, "        \"2\"  \"0.1\"");
                WriteFileLine(file, "        \"3\"  \"0.1\"");
                WriteFileLine(file, "        \"4\"  \"0.2\"");
                WriteFileLine(file, "        \"5\"  \"0.2\"");
                WriteFileLine(file, "        \"6\"  \"0.2\"");
                WriteFileLine(file, "        \"7\"  \"0.2\"");
                WriteFileLine(file, "        \"8\"  \"0.2\"");
                WriteFileLine(file, "        \"9\"  \"0.2\"");
                WriteFileLine(file, "        \"10\" \"0.2\"");
                WriteFileLine(file, "        \"11\" \"0.2\"");
                WriteFileLine(file, "        \"12\" \"0.2\"");
                WriteFileLine(file, "        \"13\" \"0.2\"");
                WriteFileLine(file, "        \"14\" \"0.3\"");
                WriteFileLine(file, "    }");
                WriteFileLine(file, "");

                WriteFileLine(file, "    \"scorePoints\"");
                WriteFileLine(file, "    {");
                WriteFileLine(file, "        \"0\"  \"5\"");
                WriteFileLine(file, "        \"1\"  \"10\"");
                WriteFileLine(file, "        \"2\"  \"15\"");
                WriteFileLine(file, "        \"3\"  \"20\"");
                WriteFileLine(file, "        \"4\"  \"25\"");
                WriteFileLine(file, "        \"5\"  \"30\"");
                WriteFileLine(file, "        \"6\"  \"35\"");
                WriteFileLine(file, "        \"7\"  \"40\"");
                WriteFileLine(file, "        \"8\"  \"45\"");
                WriteFileLine(file, "        \"9\"  \"50\"");
                WriteFileLine(file, "        \"10\" \"55\"");
                WriteFileLine(file, "        \"11\" \"60\"");
                WriteFileLine(file, "        \"12\" \"65\"");
                WriteFileLine(file, "        \"13\" \"70\"");
                WriteFileLine(file, "        \"14\" \"75\"");
                WriteFileLine(file, "        \"15\" \"80\"");
                WriteFileLine(file, "        \"16\" \"85\"");
                WriteFileLine(file, "        \"17\" \"90\"");
                WriteFileLine(file, "        \"18\" \"95\"");
                WriteFileLine(file, "        \"19\" \"100\"");
                WriteFileLine(file, "    }");
                WriteFileLine(file, "");

                WriteFileLine(file, "    \"scoreRewards\"");
                WriteFileLine(file, "    {");
                WriteFileLine(file, "        \"0\"  \"100000000000000000\"");
                WriteFileLine(file, "        \"1\"  \"150000000000000000\"");
                WriteFileLine(file, "        \"2\"  \"200000000000000000\"");
                WriteFileLine(file, "        \"3\"  \"250000000000000000\"");
                WriteFileLine(file, "        \"4\"  \"300000000000000000\"");
                WriteFileLine(file, "        \"5\"  \"350000000000000000\"");
                WriteFileLine(file, "        \"6\"  \"400000000000000000\"");
                WriteFileLine(file, "        \"7\"  \"450000000000000000\"");
                WriteFileLine(file, "        \"8\"  \"500000000000000000\"");
                WriteFileLine(file, "        \"9\"  \"550000000000000000\"");
                WriteFileLine(file, "        \"10\" \"600000000000000000\"");
                WriteFileLine(file, "        \"11\" \"650000000000000000\"");
                WriteFileLine(file, "        \"12\" \"700000000000000000\"");
                WriteFileLine(file, "        \"13\" \"750000000000000000\"");
                WriteFileLine(file, "        \"14\" \"800000000000000000\"");
                WriteFileLine(file, "        \"15\" \"850000000000000000\"");
                WriteFileLine(file, "        \"16\" \"900000000000000000\"");
                WriteFileLine(file, "        \"17\" \"950000000000000000\"");
                WriteFileLine(file, "        \"18\" \"1000000000000000000\"");
                WriteFileLine(file, "        \"19\" \"1050000000000000000\"");
                WriteFileLine(file, "    }");
                WriteFileLine(file, "");

                WriteFileLine(file, "    \"scoreRewardsShow\"");
                WriteFileLine(file, "    {");
                WriteFileLine(file, "        \"0\"  \"0.1\"");
                WriteFileLine(file, "        \"1\"  \"0.15\"");
                WriteFileLine(file, "        \"2\"  \"0.2\"");
                WriteFileLine(file, "        \"3\"  \"0.25\"");
                WriteFileLine(file, "        \"4\"  \"0.3\"");
                WriteFileLine(file, "        \"5\"  \"0.35\"");
                WriteFileLine(file, "        \"6\"  \"0.4\"");
                WriteFileLine(file, "        \"7\"  \"0.45\"");
                WriteFileLine(file, "        \"8\"  \"0.5\"");
                WriteFileLine(file, "        \"9\"  \"0.55\"");
                WriteFileLine(file, "        \"10\" \"0.6\"");
                WriteFileLine(file, "        \"11\" \"0.65\"");
                WriteFileLine(file, "        \"12\" \"0.7\"");
                WriteFileLine(file, "        \"13\" \"0.75\"");
                WriteFileLine(file, "        \"14\" \"0.8\"");
                WriteFileLine(file, "        \"15\" \"0.85\"");
                WriteFileLine(file, "        \"16\" \"0.9\"");
                WriteFileLine(file, "        \"17\" \"0.95\"");
                WriteFileLine(file, "        \"18\" \"1.0\"");
                WriteFileLine(file, "        \"19\" \"1.05\"");
                WriteFileLine(file, "    }");

                WriteFileLine(file, "}");
                CloseHandle(file);
                PrintToServer("[PTE] Configuration file created: %s", configPath);
            }
            else
            {
                PrintToServer("[PTE] Cannot create default file.");
                return;
            }
        }

        KeyValues kv = new KeyValues("PlayToEarn");
        if (!kv.ImportFromFile(configPath))
        {
            delete kv;
            PrintToServer("[PTE] Cannot load configuration file: %s", configPath);
        }
        // Loading from file
        else {
            maxObjectives = kv.GetNum("maxObjectives", 15);

            if (kv.JumpToKey("objectiveRewards"))
            {
                for (int i = 0; i < maxObjectives; i++)
                {
                    char key[8];
                    Format(key, sizeof(key), "%d", i);
                    char value[32];
                    kv.GetString(key, value, sizeof(value), "100000000000000000");
                    strcopy(objectiveRewards[i], sizeof(objectiveRewards[i]), value);
                }
                kv.GoBack();
                PrintToServer("[PTE] objectiveRewards Loaded!");
            }

            if (kv.JumpToKey("objectiveRewardsShow"))
            {
                for (int i = 0; i < maxObjectives; i++)
                {
                    char key[8];
                    Format(key, sizeof(key), "%d", i);
                    char value[32];
                    kv.GetString(key, value, sizeof(value), "0.1");
                    strcopy(objectiveRewardsShow[i], sizeof(objectiveRewardsShow[i]), value);
                }
                kv.GoBack();
                PrintToServer("[PTE] objectiveRewardsShow Loaded!");
            }

            if (kv.JumpToKey("scorePoints"))
            {
                for (int i = 0; i < 20; i++)
                {
                    char key[8];
                    Format(key, sizeof(key), "%d", i);
                    scorePoints[i] = kv.GetNum(key, 0);
                }
                kv.GoBack();
                PrintToServer("[PTE] scorePoints Loaded!");
            }

            if (kv.JumpToKey("scoreRewards"))
            {
                for (int i = 0; i < 20; i++)
                {
                    char key[8];
                    Format(key, sizeof(key), "%d", i);
                    char value[32];
                    kv.GetString(key, value, sizeof(value), "100000000000000000");
                    strcopy(scoreRewards[i], sizeof(scoreRewards[i]), value);
                }
                kv.GoBack();
                PrintToServer("[PTE] scoreRewards Loaded!");
            }

            if (kv.JumpToKey("scoreRewardsShow"))
            {
                for (int i = 0; i < 20; i++)
                {
                    char key[8];
                    Format(key, sizeof(key), "%d", i);
                    char value[32];
                    kv.GetString(key, value, sizeof(value), "0.1");
                    strcopy(scoreRewardsShow[i], sizeof(scoreRewardsShow[i]), value);
                }
                kv.GoBack();
                PrintToServer("[PTE] scoreRewardsShow Loaded!");
            }
        }
    }

    // Player connected
    HookEvent("player_connect", OnPlayerConnect, EventHookMode_Post);

    // Player disconnected
    HookEventEx("player_disconnect", OnPlayerDisconnect, EventHookMode_Post);

    // Player died
    HookEvent("player_death", OnPlayerDie, EventHookMode_Post);

    // Player spawn
    HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);

    // Objective started
    HookEventEx("objective_begin", OnObjectiveStart, EventHookMode_Post);

    // Objective completed
    HookEventEx("objective_complete", OnObjectiveComplete, EventHookMode_Post);

    // Practice ended
    HookEvent("nmrih_practice_ending", OnPracticeEnded, EventHookMode_PostNoCopy);

    // Round start
    HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);

    // Round start
    HookEvent("extraction_complete", OnExtractionComplete, EventHookMode_PostNoCopy);

    // Wallet command
    RegConsoleCmd("wallet", CommandRegisterWallet, "Set up your Wallet address");

    // ID command
    RegConsoleCmd("id", CommandViewSteamId, "View your steam id");

    // Menu command
    RegConsoleCmd("menu", CommandOpenMenu, "Open PTE menu");

    PrintToServer("[PTE Objective] Play to Earn plugin has been initialized");
}

//
// EVENTS
//
public void OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
    char playerName[32];
    char networkId[32];
    char address[32];
    int  index  = event.GetInt("index");
    int  userId = event.GetInt("userid");
    bool isBot  = event.GetBool("bot");

    event.GetString("name", playerName, sizeof(playerName));
    event.GetString("networkid", networkId, sizeof(networkId));
    event.GetString("address", address, sizeof(address));

    if (!isBot)
    {
        PrintToServer("[PTE] Player Connected: Name: %s | ID: %d | Index: %d | SteamID: %s | IP: %s | Bot: %d",
                      playerName, userId, index, networkId, address, isBot);
    }
}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    char playerName[64];
    char networkId[32];
    char reason[128];
    int  userId = event.GetInt("userid");
    bool isBot  = event.GetBool("bot");

    event.GetString("name", playerName, sizeof(playerName));
    event.GetString("networkid", networkId, sizeof(networkId));
    event.GetString("reason", reason, sizeof(reason));

    if (!isBot)
    {
        PrintToServer("[PTE] Player Disconnected: Name: %s | ID: %d | SteamID: %s | Reason: %s | Bot: %d",
                      playerName, userId, networkId, reason, isBot);
    }
}

public void OnObjectiveStart(Event event, const char[] name, bool dontBroadcast)
{
    int  objectiveId = event.GetInt("id");
    char objectiveName[32];
    event.GetString("name", objectiveName, sizeof(objectiveName));
    PrintToServer("[PTE] Objective started: %s : %d", objectiveName, objectiveId);

    int onlinePlayers[MAXPLAYERS];
    GetOnlinePlayers(onlinePlayers, sizeof(onlinePlayers));
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        int client = onlinePlayers[i];
        if (client == 0) break;    // End of the list
        lastPlayerScore[onlinePlayers[i]] = 0;
    }
}

public void OnObjectiveComplete(Event event, const char[] name, bool dontBroadcast)
{
    int objectiveId = event.GetInt("id");

    if (objectiveId == -1)
    {
        PrintToServer("[PTE] Invalid objective id, ignoring...");
        return;
    }

    if (objectiveInCooldown)
    {
        PrintToServer("[PTE] WARNING: Objective complete event called, but the 'objectiveInCooldown' is still true..., map did not set correctly the objectives");
        return;
    }
    objectiveInCooldown = true;
    CreateTimer(objectiveCooldown, Timer_ObjectiveStart);

    char objectiveName[32];
    event.GetString("name", objectiveName, sizeof(objectiveName));
    PrintToServer("[PTE] Objective completed: %s : %d", objectiveName, objectiveId);

    int indexReward = 0;
    if (objectivesCompleted > maxObjectives)
    {
        indexReward = maxObjectives - 1;
    }
    else {
        indexReward = objectivesCompleted;
    }

    int onlinePlayers[MAXPLAYERS];
    GetOnlinePlayers(onlinePlayers, sizeof(onlinePlayers));
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        int client = onlinePlayers[i];
        if (client == 0) break;    // End of the list

        if (isDeadPlayer[client])
        {
            char playerName[32];
            GetClientName(client, playerName, sizeof(playerName));
            PrintToServer("[PTE] Ignoring %s because he is dead", playerName);
            continue;
        }

        // Objective reward
        {
            char currentEarning[20];
            char textToShow[20];
            strcopy(currentEarning, sizeof(currentEarning), objectiveRewards[indexReward]);
            strcopy(textToShow, sizeof(textToShow), objectiveRewardsShow[indexReward]);
            char outputText[32];
            Format(outputText, sizeof(outputText), "%s PTE", textToShow);

            IncrementWallet(client, currentEarning, outputText, ", for Completing Objective");
        }

        // Score reward
        {
            int scoreDifference     = GetClientFrags(client) - lastPlayerScore[client];
            lastPlayerScore[client] = GetClientFrags(client);
            PrintToServer("[PTE] %d scored: %d, in this round, total: %d", client, scoreDifference, GetClientFrags(client));
            if (scoreDifference > 0)
            {
                int size = sizeof(scorePoints);
                int j;
                for (j = 0; j < size; j++)
                {
                    if (scorePoints[j] > scoreDifference)
                    {
                        break;
                    }
                }

                if (j > 0)
                {
                    char currentEarning[20];
                    char textToShow[20];
                    strcopy(currentEarning, sizeof(currentEarning), scoreRewards[j - 1]);
                    strcopy(textToShow, sizeof(textToShow), scoreRewardsShow[j - 1]);
                    char outputText[32];
                    Format(outputText, sizeof(outputText), "%s PTE", textToShow);

                    IncrementWallet(client, currentEarning, outputText, ", for Scoring");
                }
            }
        }
    }

    objectivesCompleted++;
}

public Action Timer_ObjectiveStart(Handle timer, any data)
{
    PrintToServer("[PTE] Objective cooldown reseted...");
    objectiveInCooldown = false;
    return Plugin_Stop;
}

public void OnPlayerDie(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");

    int client = GetClientOfUserId(userid);
    if (!IsValidClient(client))
    {
        PrintToServer("[PTE] Player %d is not valid, ignoring...", userid);
        return;
    }

    lastPlayerScore[client] = GetClientFrags(client);

    isDeadPlayer[client]    = true;

    PrintToServer("[PTE] Player died %d", userid);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");

    int client = GetClientOfUserId(userid);
    if (!IsValidClient(client))
    {
        PrintToServer("[PTE] Player %d is not valid, ignoring...", userid);
        return;
    }

    isDeadPlayer[client] = false;

    PrintToServer("[PTE] Player spawned %d", userid);
}

public void OnPracticeEnded(Event event, const char[] name, bool dontBroadcast)
{
    PrintToServer("[PTE] Practice ended");
    PrintToChatAll("[PTE] Welcome to the official Play To Earn server, our discord: %s", DISCORD_INVITE);
    objectivesCompleted = 0;

    int onlinePlayers[MAXPLAYERS];
    GetOnlinePlayers(onlinePlayers, sizeof(onlinePlayers));
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        int client = onlinePlayers[i];
        if (client == 0) break;    // End of the list

        lastPlayerScore[client] = 0;
        RegisterPlayer(client);
        ShowMenu(client);
    }
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    PrintToServer("[PTE] Round start");
    objectivesCompleted = 0;
}

public void OnExtractionComplete(Event event, const char[] name, bool dontBroadcast)
{
    int indexReward = 0;
    if (objectivesCompleted > maxObjectives)
    {
        indexReward = maxObjectives - 1;
    }
    else {
        indexReward = objectivesCompleted;
    }

    int onlinePlayers[MAXPLAYERS];
    GetOnlinePlayers(onlinePlayers, sizeof(onlinePlayers));
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        int client = onlinePlayers[i];
        if (client == 0) break;    // End of the list

        if (IsPlayerAlive(client))
        {
            char playerName[32];
            GetClientName(client, playerName, sizeof(playerName));
            PrintToServer("[PTE] Ignoring %s because he is dead", playerName);
            continue;
        }

        // Objective reward
        {
            char currentEarning[20];
            char textToShow[20];
            strcopy(currentEarning, sizeof(currentEarning), objectiveRewards[indexReward]);
            strcopy(textToShow, sizeof(textToShow), objectiveRewardsShow[indexReward]);
            char outputText[32];
            Format(outputText, sizeof(outputText), "%s PTE", textToShow);

            IncrementWallet(client, currentEarning, outputText, ", for Completing Objective");
        }

        // Score reward
        {
            int scoreDifference     = GetClientFrags(client) - lastPlayerScore[client];
            lastPlayerScore[client] = GetClientFrags(client);
            PrintToServer("[PTE] %d scored: %d, in this round, total: %d", client, scoreDifference, GetClientFrags(client));
            if (scoreDifference > 0)
            {
                int size = sizeof(scorePoints);
                int j;
                for (j = 0; j < size; j++)
                {
                    if (scorePoints[j] > scoreDifference)
                    {
                        break;
                    }
                }

                if (j > 0)
                {
                    char currentEarning[20];
                    char textToShow[20];
                    strcopy(currentEarning, sizeof(currentEarning), scoreRewards[j - 1]);
                    strcopy(textToShow, sizeof(textToShow), scoreRewardsShow[j - 1]);
                    char outputText[32];
                    Format(outputText, sizeof(outputText), "%s PTE", textToShow);

                    IncrementWallet(client, currentEarning, outputText, ", for Extraction");
                }
            }
        }
    }
}

public void OnServerEnterHibernation()
{
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        lastPlayerScore[i] = 0;
        isDeadPlayer[i]    = false;
    }
    objectivesCompleted = 0;
}
//
//
//

//
// Commands
//
public Action CommandRegisterWallet(int client, int args)
{
    if (args < 1)
    {
        PrintToChat(client, "[PTE] You can set your wallet using !wallet 0x123");
        return Plugin_Handled;
    }

    char walletAddress[256];
    GetCmdArgString(walletAddress, sizeof(walletAddress));

    UpdateWallet(client, walletAddress);

    return Plugin_Handled;
}

public Action CommandViewSteamId(int client, int args)
{
    if (!IsValidClient(client))
    {
        PrintToChat(client, "[PTE] Your steam id is: %d", GetSteamAccountID(client));
    }

    return Plugin_Handled;
}

public Action CommandOpenMenu(int client, int args)
{
    ShowMenu(client);

    return Plugin_Handled;
}
//
//
//