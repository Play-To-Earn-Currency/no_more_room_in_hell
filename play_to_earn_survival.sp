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

static int  lastPlayerScore[MAXPLAYERS];
static int  isDeadPlayer[MAXPLAYERS];
static int  serverWave              = 0;

static int  maxWaves                = 15;
static char waveRewards[15][20]     = { "100000000000000000", "10000000000000000", "100000000000000000",
                                    "100000000000000000", "200000000000000000", "200000000000000000",
                                    "200000000000000000", "200000000000000000", "200000000000000000",
                                    "200000000000000000", "200000000000000000", "200000000000000000",
                                    "200000000000000000", "200000000000000000", "300000000000000000" };
static char waveRewardsShow[15][20] = { "0.1", "0.1", "0.1",
                                        "0.1", "0.2", "0.2",
                                        "0.2", "0.2", "0.2",
                                        "0.2", "0.2", "0.2",
                                        "0.2", "0.2", "0.3" };
static int  scorePoints[20]         = { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100 };
static char scoreRewards[20][20]    = {
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
char scoreRewardsShow[20][20] = { "0.1", "0.15", "0.2",
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
        if (StrContains(commandLine, "-pteSurvival 1") == -1)
        {
            PrintToServer("[PTE Survival] Will not be initialized, 'pteSurvival' is not '1'");
            return;
        }
    }

    // Configuration Load
    {
        char configPath[PLATFORM_MAX_PATH] = "addons/sourcemod/configs/play_to_earn_survival.cfg";

        if (!FileExists(configPath))
        {
            Handle file = OpenFile(configPath, "w");
            if (file != null)
            {
                WriteFileLine(file, "\"PlayToEarn\"");
                WriteFileLine(file, "{");

                WriteFileLine(file, "    \"maxWaves\"       \"15\"");
                WriteFileLine(file, "");

                WriteFileLine(file, "    \"waveRewards\"");
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

                WriteFileLine(file, "    \"waveRewardsShow\"");
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
            maxWaves = kv.GetNum("maxWaves", 15);

            if (kv.JumpToKey("waveRewards"))
            {
                for (int i = 0; i < maxWaves; i++)
                {
                    char key[8];
                    Format(key, sizeof(key), "%d", i);
                    char value[32];
                    kv.GetString(key, value, sizeof(value), "100000000000000000");
                    strcopy(waveRewards[i], sizeof(waveRewards[i]), value);
                }
                kv.GoBack();
                PrintToServer("[PTE] waveRewards Loaded!");
            }

            if (kv.JumpToKey("waveRewardsShow"))
            {
                for (int i = 0; i < maxWaves; i++)
                {
                    char key[8];
                    Format(key, sizeof(key), "%d", i);
                    char value[32];
                    kv.GetString(key, value, sizeof(value), "0.1");
                    strcopy(waveRewardsShow[i], sizeof(waveRewardsShow[i]), value);
                }
                kv.GoBack();
                PrintToServer("[PTE] waveRewardsShow Loaded!");
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

    // Wave Start
    HookEventEx("new_wave", OnWaveStart, EventHookMode_Post);

    // Survival Start
    HookEventEx("nmrih_round_begin", OnSurvivalStart, EventHookMode_PostNoCopy);

    // Extraction begin
    HookEvent("extraction_begin", OnExtractionBegin, EventHookMode_PostNoCopy);

    // Practice ended
    HookEvent("nmrih_practice_ending", OnPracticeEnded, EventHookMode_PostNoCopy);

    // Wallet command
    RegConsoleCmd("wallet", CommandRegisterWallet, "Set up your Wallet address");

    // ID command
    RegConsoleCmd("id", CommandViewSteamId, "View your steam id");

    // Menu command
    RegConsoleCmd("menu", CommandOpenMenu, "Open PTE menu");

    PrintToServer("[PTE Survival] Play to Earn plugin has been initialized");
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

public void OnWaveStart(Event event, const char[] name, bool dontBroadcast)
{
    if (serverWave > 0)
    {
        OnWaveFinish();
    }

    bool isSupply = event.GetBool("resupply");
    if (!isSupply)
    {
        serverWave++;
    }

    int onlinePlayers[MAXPLAYERS];
    GetOnlinePlayers(onlinePlayers, sizeof(onlinePlayers));
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        int client = onlinePlayers[i];
        if (client == 0) break;    // End of the list
        lastPlayerScore[onlinePlayers[i]] = 0;
    }

    PrintToServer("[PTE] Wave %d Started, supply: %b", serverWave, isSupply);
}

public void OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
    serverWave = 0;

    PrintToServer("[PTE] Survival Started");
}

public void OnPracticeEnded(Event event, const char[] name, bool dontBroadcast)
{
    PrintToServer("[PTE] Practice ended");
    PrintToChatAll("[PTE] Welcome to the official Play To Earn server, our discord: %s", DISCORD_INVITE);

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

public void OnWaveFinish()
{
    int indexReward = 0;
    if (serverWave > maxWaves)
    {
        indexReward = maxWaves - 1;
    }
    else {
        indexReward = serverWave - 1;
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

        // Wave survival reward
        {
            char currentEarning[20];
            char textToShow[20];
            strcopy(currentEarning, sizeof(currentEarning), waveRewards[indexReward]);
            strcopy(textToShow, sizeof(textToShow), waveRewardsShow[indexReward]);
            char outputText[32];
            Format(outputText, sizeof(outputText), "%s PTE", textToShow);

            IncrementWallet(client, currentEarning, outputText, ", for Surviving");
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

    PrintToServer("[PTE] Wave %d Finished", serverWave);
}

public void OnExtractionBegin(Event event, const char[] name, bool dontBroadcast)
{
    OnWaveFinish();
}

public void OnServerEnterHibernation()
{
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        lastPlayerScore[i] = 0;
        isDeadPlayer[i]    = false;
    }
    serverWave = 0;
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
    PrintToChat(client, "[PTE] Your steam id is: %d", GetSteamAccountID(client));

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
