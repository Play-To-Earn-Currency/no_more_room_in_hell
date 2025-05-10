# No More Room in Hell Play To Earn
Base template for running a server with play to earn support

## Functionality
- Surviving rounds will earn PTE
- The more rounds the player survive the more PTE he will earn
- Setup wallet as command ``!wallet 0x123...``

## Configuring
To configure you will need to manually change some values inside the file before compiling

## Using
- Download [No More Room in Hell](https://nomoreroominhell.fandom.com/wiki/Dedicated_Server_Setup) server files
- Install [sourcemod](https://www.sourcemod.net/downloads.php) and [metamod](https://www.sourcemm.net/downloads.php/?branch=stable)
- Install [sm_json](https://github.com/clugg/sm-json) for [sourcemod](https://www.sourcemod.net/downloads.php), just place the addons folder inside NoMoreRoomInHell/nmrih
- Install a database like mysql or mariadb
- Create a user for the database: GRANT ALL PRIVILEGES ON pte_wallets.* TO 'pte_admin'@'localhost' IDENTIFIED BY 'supersecretpassword' WITH GRANT OPTION; FLUSH PRIVILEGES;
- Create a table named ``nmrih``:
```sql
CREATE TABLE nmrih (
    uniqueid VARCHAR(255) NOT NULL PRIMARY KEY,
    walletaddress VARCHAR(255) DEFAULT null,
    value DECIMAL(50, 0) NOT NULL DEFAULT 0
);
```
- Copy the play_to_earn_survival_db.sp inside NoMoreRoomInHell/nmrih/addons/sourcemod/scripting
- Inside the NoMoreRoomInHell/nmrih/addons/sourcemod/scripting should be a file to compile, compile it giving the play_to_earn_survival_db.sp as parameter
- The file should be in NoMoreRoomInHell/nmrih/addons/sourcemod/scripting/compiled folder, copy the file compiled and place it in NoMoreRoomInHell/nmrih/addons/sourcemod/plugins folder
- Now you need to configure your database, go to NoMoreRoomInHell/nmrih/addons/sourcemod/databases.cfg, and add the database credentials
- Run the server normally, players should register their wallets using the command ``!wallet 0x123...``
- For survival servers use: ``-pteSurvival 1`` and for objective servers: ``-pteObjective 1`` as commandline parameter, otherwise the PTE plugin will not be initialized

# Skin Reader
This plugin will automatically check players equipped skin in ``nmrih_skins`` table, if you plan to make a official PTE skin you should take a look at [PTE Community Manager](https://github.com/Play-To-Earn-Currency/community_manager), the official PTE NMRIH is: [0x6FFd600e030B44ba5A0C4B9242229a420533d467](https://polygonscan.com/token/0x6FFd600e030B44ba5A0C4B9242229a420533d467)

Players can use the command ``!tps`` to view themselves in third person

How ID's works? ``??-??`` the firsts numbers is the skin rarity, the second is the skin uniqueid

The ``walletaddress`` and ``nftid`` on database table is necessary to verify if the player is owner of the selected skin

## Using
Create a new table for storing player skins and selections
```sql
CREATE TABLE nmrih_skins (
    uniqueid VARCHAR(255) NOT NULL PRIMARY KEY,
    walletaddress VARCHAR(255) DEFAULT null,
    skinid VARCHAR(255) NOT NULL,
    nftid DECIMAL(78, 0) NOT NULL
);
```
Copy ``skins_reader`` folder inside ``nmrih/addons/sourcemod/configs

Now you can add your skins in ``skins_id.init`` and ``downloads_list.ini`` to setup ingame skins

Necessary to have a FastDL system setup you can check [here](https://forums.alliedmods.net/showthread.php?p=1225670) a simple tutorial

Everthing should work now, you can edit your database table ``nmrih_skins`` to handle player skins

If you need the entire skin source for generating your own NMRIH server, you should take a look in the PTE NMRIH official discord server

## Web Skin
A template website for running a skin selector

# Recomendations
- [Anti Server Lag Exploits](https://forums.alliedmods.net/showthread.php?p=2788390)
- [Health and Stamina Display](https://forums.alliedmods.net/showthread.php?t=318836)
- [Round Timers](https://github.com/Play-To-Earn-Currency/no_more_room_in_hell/blob/main/utils/round_timer.sp)
- [Kit Starter](https://github.com/Play-To-Earn-Currency/no_more_room_in_hell/blob/main/utils/kit_starter.sp)
