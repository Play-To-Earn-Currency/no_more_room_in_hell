#include <sourcemod>
#include <json>
#include <regex.inc>
#include <SteamWorks>

public Plugin myinfo =
{
    name        = "Play To Earn",
    author      = "Gxsper",
    description = "Play to Earn for No More Room in Hell",
    version     = SOURCEMOD_VERSION,
    url         = "https://github.com/GxsperMain/nmrih_play_to_earn"
};

static char httpServerIp[32] = "http://localhost:8000";
static char httpFrom[12]     = "nmrih";
static char onlinePlayers[MAXPLAYERS][512];
static int  onlinePlayersCount      = 0;

char        waveRewards[15][20]     = { "100000000000000000", "10000000000000000", "100000000000000000",
                             "100000000000000000", "200000000000000000", "200000000000000000",
                             "200000000000000000", "200000000000000000", "200000000000000000",
                             "200000000000000000", "200000000000000000", "200000000000000000",
                             "200000000000000000", "200000000000000000", "300000000000000000" };
const int   maxWaves                = 15;
char        waveRewardsShow[15][20] = { "0.1", "0.1", "0.1",
                                 "0.1", "0.2", "0.2",
                                 "0.2", "0.2", "0.2",
                                 "0.2", "0.2", "0.2",
                                 "0.2", "0.2", "0.3" };
int         scorePoints[20]         = { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100 };
char        scoreRewards[20][20]    = {
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
char        scoreRewardsShow[20][20] = { "0.1", "0.15", "0.2",
                                  "0.25", "0.3", "0.35",
                                  "0.4", "0.45", "0.5",
                                  "0.55", "0.6", "0.65", "0.7",
                                  "0.75", "0.8", "0.85",
                                  "0.9", "0.95", "1.0",
                                  "1.05" };

int         serverWave               = 0;
int         playerAlives             = 0;

Regex       regex;

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

    regex = CompileRegex("^0x[a-fA-F0-9]{40}$");
    if (regex == INVALID_HANDLE)
    {
        LogError("Failed to compile wallet regex.");
    }

    // Player connected
    HookEvent("player_connect", OnPlayerConnect, EventHookMode_Post);

    // Player disconnected
    HookEventEx("player_disconnect", OnPlayerDisconnect, EventHookMode_Post);

    // Wave Start
    HookEventEx("new_wave", OnWaveStart, EventHookMode_Post);

    // Survival Start
    HookEventEx("nmrih_round_begin", OnSurvivalStart, EventHookMode_PostNoCopy);

    // Player Started playing
    HookEvent("player_active", OnPlayerActive, EventHookMode_Post);

    // Player died
    HookEvent("player_death", OnPlayerDie, EventHookMode_Post);

    // Player spawn
    HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);

    // Extraction begin
    HookEvent("extraction_begin", OnExtractionBegin, EventHookMode_PostNoCopy);

    // Practice ended
    HookEvent("nmrih_practice_ending", OnPracticeEnded, EventHookMode_PostNoCopy);

    // Wallet command
    RegConsoleCmd("wallet", CommandRegisterWallet, "Set up your Wallet address");

    // ID command
    RegConsoleCmd("id", CommandViewSteamId, "View your steam id");

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
        JSON_Object playerObj = new JSON_Object();
        playerObj.SetString("playerName", playerName);
        playerObj.SetString("networkId", networkId);
        playerObj.SetString("address", address);
        playerObj.SetInt("userId", userId);
        playerObj.SetInt("index", index);
        playerObj.SetInt("walletStatus", -1);

        char userData[256];
        playerObj.Encode(userData, sizeof(userData));
        json_cleanup_and_delete(playerObj);

        onlinePlayers[onlinePlayersCount] = userData;
        onlinePlayersCount++;

        PrintToServer("[PTE] Player Connected: Name: %s | ID: %d | Index: %d | SteamID: %s | IP: %s | Bot: %d",
                      playerName, userId, index, networkId, address, isBot);

        PrintToServer("[PTE] Online Players: %d", onlinePlayersCount);
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
        removePlayerByUserId(userId);
        onlinePlayersCount--;
        PrintToServer("[PTE] Player Disconnected: Name: %s | ID: %d | SteamID: %s | Reason: %s | Bot: %d",
                      playerName, userId, networkId, reason, isBot);

        PrintToServer("[PTE] Online Players: %d", onlinePlayersCount);

        if (onlinePlayersCount <= 0)
        {
            cleanupOnlinePlayers();
        }
    }
}

public void OnWaveStart(Event event, const char[] name, bool dontBroadcast)
{
    PrintToServer("[PTE] Online Players: %d", onlinePlayersCount);

    if (serverWave > 0)
    {
        OnWaveFinish();
    }

    bool isSupply = event.GetBool("resupply");
    if (!isSupply)
    {
        serverWave++;
    }

    int length = onlinePlayersCount;
    for (int i = 0; i < length; i += 1)
    {
        JSON_Object playerObj = json_decode(onlinePlayers[i]);
        if (playerObj == null)
        {
            PrintToServer("[PTE] [OnWaveStart] ERROR: %d (online index) have any invalid player object: %s", i, onlinePlayers[i]);
            continue;
        }

        int client = GetClientOfUserId(playerObj.GetInt("userId"));
        if (!IsClientInGame(client) || IsFakeClient(client))
        {
            continue;
        }

        int playerScore = GetClientFrags(client);
        playerObj.SetInt("lastScore", playerScore);

        updateOnlinePlayerByUserId(playerObj.GetInt("userId"), playerObj);
        json_cleanup_and_delete(playerObj);
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
    PrintToChatAll("[PTE] Welcome to the official Play To Earn server, our discord: discord.gg/vGHxVsXc4Q");
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

    int length = onlinePlayersCount;
    for (int i = 0; i < length; i += 1)
    {
        JSON_Object playerObj = json_decode(onlinePlayers[i]);
        if (playerObj == null)
        {
            PrintToServer("[PTE] [OnWaveFinish] ERROR: %d (online index) have any invalid player object: %s", i, onlinePlayers[i]);
            continue;
        }

        int client = GetClientOfUserId(playerObj.GetInt("userId"));
        if (IsFakeClient(client) || !IsClientInGame(client))
        {
            continue
        }

        char playerName[32];
        playerObj.GetString("playerName", playerName, sizeof(playerName));

        if (playerObj.GetBool("dead", true))
        {
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
        int scoreDifference = GetClientFrags(client) - playerObj.GetInt("lastScore");
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

        json_cleanup_and_delete(playerObj);
    }

    PrintToServer("[PTE] Wave %d Finished", serverWave);
}

public void OnPlayerActive(Event event, const char[] name, bool dontBroadcast)
{
    int         userId    = event.GetInt("userid");

    JSON_Object playerObj = getPlayerByUserId(userId);
    if (playerObj == null)
    {
        PrintToServer("[PTE] [OnPlayerActive] ERROR: %d have any invalid player object", userId);
        return;
    }

    RegisterPlayer(GetSteamAccountID(GetClientOfUserId(userId)));

    json_cleanup_and_delete(playerObj);

    PrintToServer("[PTE] Player started playing %d", userId);
}

public void OnPlayerDie(Event event, const char[] name, bool dontBroadcast)
{
    int userId = event.GetInt("userid");

    playerAlives--;
    PrintToServer("[PTE] Player died %d, Total Alive: %d", userId, playerAlives);

    JSON_Object playerObj = getPlayerByUserId(userId);
    if (playerObj == null)
    {
        // Is invalid always when a player disconnects, because disconnect function is called before the dead function
        // PrintToServer("[PTE] [OnPlayerDie] ERROR: %d have any invalid player object", userId);
        return;
    }

    playerObj.SetBool("dead", true);

    int playerScore = GetClientFrags(GetClientOfUserId(userId));
    playerObj.SetInt("lastScore", playerScore);

    updateOnlinePlayerByUserId(userId, playerObj);
    json_cleanup_and_delete(playerObj);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int userId = event.GetInt("userid");

    playerAlives++;
    PrintToServer("[PTE] Player spawned %d, Total Alive: %d", userId, playerAlives);

    JSON_Object playerObj = getPlayerByUserId(userId);
    if (playerObj == null)
    {
        PrintToServer("[PTE] [OnPlayerSpawn] ERROR: %d have any invalid player object", userId);
        return;
    }

    playerObj.SetBool("dead", false);

    int playerScore = GetClientFrags(GetClientOfUserId(userId));
    playerObj.SetInt("lastScore", playerScore);

    updateOnlinePlayerByUserId(userId, playerObj);
    json_cleanup_and_delete(playerObj);
}

public void OnExtractionBegin(Event event, const char[] name, bool dontBroadcast)
{
    OnWaveFinish();
}

public void OnServerEnterHibernation()
{
    cleanupOnlinePlayers();
}
//
//
//

//
// Commands
//
public Action CommandRegisterWallet(int client, int args)
{
    if (!IsClientConnected(client) || IsFakeClient(client))
    {
        return Plugin_Handled;
    }

    if (args < 1)
    {
        PrintToChat(client, "You can set your wallet in your discord: discord.gg/vGHxVsXc4Q");
        PrintToChat(client, "Or you can setup using !wallet 0x123...");
        return Plugin_Handled;
    }
    char walletAddress[256];
    GetCmdArgString(walletAddress, sizeof(walletAddress));

    if (ValidAddress(walletAddress))
    {
        JSON_Object playerObj = getPlayerByUserId(GetClientUserId(client));
        if (playerObj == null)
        {
            PrintToServer("[PTE] [CommandRegisterWallet] ERROR: %d have any invalid player object", client);
            return Plugin_Handled;
        }

        int  steamId = GetSteamAccountID(client);

        char url[256];
        Format(url, sizeof(url), "%s/updatewallet", httpServerIp);
        Handle requestHandle = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPUT, url);

        if (requestHandle == INVALID_HANDLE)
        {
            PrintToServer("[PTE] Error while creating the http request.");
            return Plugin_Handled;
        }

        SteamWorks_SetHTTPRequestContextValue(requestHandle, client);
        SteamWorks_SetHTTPCallbacks(requestHandle, OnCommandRegisterWalletRequest);

        JSON_Object body = new JSON_Object();
        body.SetString("walletaddress", walletAddress);
        body.SetInt("uniqueid", steamId);
        char bodyStr[256];
        body.Encode(bodyStr, sizeof(bodyStr));

        SteamWorks_SetHTTPRequestHeaderValue(requestHandle, "Content-Type", "application/json");
        SteamWorks_SetHTTPRequestHeaderValue(requestHandle, "from", httpFrom);
        SteamWorks_SetHTTPRequestRawPostBody(requestHandle, "application/json", bodyStr, strlen(bodyStr));

        SteamWorks_SendHTTPRequest(requestHandle);

        json_cleanup_and_delete(playerObj);
    }
    else {
        PrintToChat(client, "The wallet address provided is invalid, if you need help you can ask in your discord: discord.gg/vGHxVsXc4Q");
    }

    return Plugin_Handled;
}

public OnCommandRegisterWalletRequest(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data1, any data2)
{
    int client = data1;

    if (eStatusCode != k_EHTTPStatusCode200OK)
    {
        PrintToChat(client, "[PTE] Cannot register your address, contact server owner on: discord.gg/vGHxVsXc4Q");
    }
    else {
        PrintToChat(client, "[PTE] Wallet changed!");
    }
}

public Action CommandViewSteamId(int client, int args)
{
    if (IsClientConnected(client) && !IsFakeClient(client))
    {
        PrintToChat(client, "[PTE] Your steam id is: %d", GetSteamAccountID(client));
    }

    return Plugin_Handled;
}
//
//
//

//
// Utils
//
char incrementWalletRequestBodies[MAXPLAYERS][256];
void IncrementWallet(
    int client,
    char[] valueToIncrement,
    char[] valueToShow = "0 PTE",
    char[] reason      = ", for Playing")
{
    int steamId = GetSteamAccountID(client);

    if (steamId == 0)
    {
        PrintToServer("[PTE] Invalid client when incrementing wallet");
        return;
    }

    char url[256];
    Format(url, sizeof(url), "%s/increment", httpServerIp);
    Handle requestHandle = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPUT, url);

    if (requestHandle == INVALID_HANDLE)
    {
        PrintToServer("[PTE] Error while creating the http request.");
        return;
    }

    SteamWorks_SetHTTPCallbacks(requestHandle, OnIncrementRequest);

    JSON_Object body = new JSON_Object();
    body.SetString("quantity", valueToIncrement);
    body.SetString("valueToShow", valueToShow);
    body.SetString("reason", reason);
    body.SetInt("uniqueid", steamId);
    char bodyStr[256];
    body.Encode(bodyStr, sizeof(bodyStr));

    SteamWorks_SetHTTPRequestHeaderValue(requestHandle, "Content-Type", "application/json");
    SteamWorks_SetHTTPRequestHeaderValue(requestHandle, "from", httpFrom);
    SteamWorks_SetHTTPRequestRawPostBody(requestHandle, "application/json", bodyStr, strlen(bodyStr));
    SteamWorks_SetHTTPRequestContextValue(requestHandle, client);

    IncrementWalletStartRequestWaitTimer(requestHandle, client, bodyStr);
}

void IncrementWalletStartRequestWaitTimer(Handle requestHandle, int client, const char[] bodyStr)
{
    DataPack pack = new DataPack();
    pack.WriteCell(client);
    pack.WriteCell(requestHandle);
    pack.WriteString(bodyStr);

    CreateTimer(0.5, IncrementWalletWaitForEmptyQueue, pack, TIMER_REPEAT);
}

public Action IncrementWalletWaitForEmptyQueue(Handle timer, DataPack pack)
{
    pack.Reset();

    int    client        = pack.ReadCell();
    Handle requestHandle = pack.ReadCell();
    char   bodyStr[256];
    pack.ReadString(bodyStr, sizeof(bodyStr));

    if (incrementWalletRequestBodies[client][0] == EOS)
    {
        delete pack;
        strcopy(incrementWalletRequestBodies[client], sizeof(incrementWalletRequestBodies[]), bodyStr);
        SteamWorks_SendHTTPRequest(requestHandle);
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

public OnIncrementRequest(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data1, any data2)
{
    int         client                      = data1;

    JSON_Object bodySended                  = json_decode(incrementWalletRequestBodies[client]);
    incrementWalletRequestBodies[client][0] = EOS;

    if (eStatusCode != k_EHTTPStatusCode200OK)
    {
        PrintToChat(client, "[PTE] Cannot increment your wallet, contact server owner on: discord.gg/vGHxVsXc4Q");
        return;
    }

    if (bodySended == null)
    {
        PrintToChat(client, "[PTE] Cannot increment your wallet, contact server owner on: discord.gg/vGHxVsXc4Q");
        PrintToServer("[PTE] [Increment] ERROR: %d (bodySended index) have any invalid bodySended object: %s", client, incrementWalletRequestBodies[client]);
        return;
    }

    char valueToShow[32];
    bodySended.GetString("valueToShow", valueToShow, sizeof(valueToShow));
    char reason[32];
    bodySended.GetString("reason", reason, sizeof(reason));

    PrintToChat(client, "[PTE] You received: %s%s", valueToShow, reason);
}

bool ValidAddress(const char[] address)
{
    return regex.Match(address) > 0;
}

void RegisterPlayer(const int steamId)
{
    char url[256];
    Format(url, sizeof(url), "%s/register", httpServerIp);
    Handle requestHandle = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, url);

    if (requestHandle == INVALID_HANDLE)
    {
        PrintToServer("[PTE] Error while creating the http request.");
        return;
    }

    SteamWorks_SetHTTPCallbacks(requestHandle, OnRegisterPlayerRequest);

    JSON_Object body = new JSON_Object();
    body.SetInt("uniqueid", steamId);
    char bodyStr[256];
    body.Encode(bodyStr, sizeof(bodyStr));

    SteamWorks_SetHTTPRequestHeaderValue(requestHandle, "Content-Type", "application/json");
    SteamWorks_SetHTTPRequestHeaderValue(requestHandle, "from", httpFrom);
    SteamWorks_SetHTTPRequestRawPostBody(requestHandle, "application/json", bodyStr, strlen(bodyStr));    

    SteamWorks_SendHTTPRequest(requestHandle);
}

public OnRegisterPlayerRequest(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data1, any data2)
{
}

JSON_Object getPlayerByUserId(int userId)
{
    for (int i = 0; i < onlinePlayersCount; i++)
    {
        if (strlen(onlinePlayers[i]) > 0)
        {
            JSON_Object playerObj = json_decode(onlinePlayers[i]);
            if (playerObj == null)
            {
                PrintToServer("[PTE] [getPlayerByUserId] ERROR: %d (online index) have any invalid player object: %s", i, onlinePlayers[i]);
                continue;
            }

            if (playerObj.GetInt("userId") == userId)
            {
                return playerObj;
            }
        }
    }
    return null;
}

void removePlayerByUserId(int userId)
{
    // Getting player index to remove
    int playerIndex = -1;
    for (int i = 0; i < onlinePlayersCount; i++)
    {
        if (strlen(onlinePlayers[i]) > 0)
        {
            JSON_Object playerObj = json_decode(onlinePlayers[i]);
            if (playerObj == null)
            {
                PrintToServer("[PTE] [removePlayerByUserId] ERROR: %d (online index) have any invalid player object: %s", i, onlinePlayers[i]);
                continue;
            }

            if (playerObj.GetInt("userId") == userId)
            {
                playerIndex = i;
                break;
            }
        }
    }
    if (playerIndex == -1)
    {
        PrintToServer("[PTE] [removePlayerByUserId] ERROR: %d player index no longer exists", userId);
        return;
    }

    // Moving values to back
    for (int i = playerIndex; i < onlinePlayersCount - 1; i++)
    {
        strcopy(onlinePlayers[i], onlinePlayersCount, onlinePlayers[i + 1]);
    }

    // Cleaning last element
    onlinePlayers[onlinePlayersCount - 1][0] = '\0';
}

stock JSON_Object getPlayerByClient(int client)
{
    for (int i = 0; i < onlinePlayersCount; i++)
    {
        if (strlen(onlinePlayers[i]) > 0)
        {
            JSON_Object playerObj = json_decode(onlinePlayers[i]);
            if (playerObj == null)
            {
                PrintToServer("[PTE] [getPlayerByClient] ERROR: %d (online index) have any invalid player object: %s", i, onlinePlayers[i]);
                continue;
            }

            if (playerObj.GetInt("index") == client)
            {
                return playerObj;
            }
        }
    }
    return null;
}

void updateOnlinePlayerByUserId(int userId, JSON_Object updatedPlayerObj)
{
    for (int i = 0; i < onlinePlayersCount; i++)
    {
        if (strlen(onlinePlayers[i]) > 0)
        {
            JSON_Object playerObj = json_decode(onlinePlayers[i]);
            if (playerObj == null)
            {
                PrintToServer("[PTE] [updateOnlinePlayerByUserId] ERROR: %d (online index) have any invalid player object: %s", i, onlinePlayers[i]);
                continue;
            }

            if (playerObj.GetInt("userId") == userId)
            {
                char encodedPlayer[256];
                updatedPlayerObj.Encode(encodedPlayer, sizeof(encodedPlayer));
                onlinePlayers[i] = encodedPlayer;
            }
        }
    }
}

void cleanupOnlinePlayers()
{
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        strcopy(onlinePlayers[i], 256, "");
        onlinePlayers[i][0] = EOS;
    }
    onlinePlayersCount = 0;
}
//
//
//
