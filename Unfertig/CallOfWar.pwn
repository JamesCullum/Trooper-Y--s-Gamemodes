/*###########################################################################################
	Copyright (C) 2015 Nicolas Giese
	Contact for licensing only: http://goo.gl/hKGHFx

	This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	
	This work is licensed under a Creative Commons 
	Attribution-NonCommercial-ShareAlike 4.0 International License.
	You should have received a copy of the License
    along with this program. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
###########################################################################################*/

#include <a_samp>
#include <SII>
#include <Seifensive>
#include <sscanf>
#include <YSF>

#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_LIGHTRED 0xFF6347AA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_YELLOW2 0xF5DEB3AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_PURPLE 0xC2A2DAAA
#define COLOR_DBLUE 0x2641FEAA

#pragma unused Seif_GetPlayerMoney
#pragma unused Seif_GivePlayerMoney
#pragma unused Seif_ResetPlayerMoney
#pragma unused Seif_TakePlayerMoney


new loggedin[MAX_PLAYERS],player_name[MAX_PLAYERS],adminlevel[MAX_PLAYERS], ausbildung[MAX_PLAYERS],kills[MAX_PLAYERS];
new specdeath[MAX_PLAYERS],mission = 1,ausbildungscar[MAX_PLAYERS],Float:checkreadx[MAX_PLAYERS],Float:checkready[MAX_PLAYERS],Float:checkreadz[MAX_PLAYERS];
new antispam1[MAX_PLAYERS],antispam2[MAX_PLAYERS],antispam3[MAX_PLAYERS],antispam4[MAX_PLAYERS],antispamcount[MAX_PLAYERS];
new ausbildungsrace[MAX_PLAYERS],Float:health[MAX_PLAYERS],Float:armour[MAX_PLAYERS],ausbildungscount[MAX_PLAYERS];
new Float:checkreadx2[MAX_PLAYERS],Float:checkready2[MAX_PLAYERS],Float:checkreadz2[MAX_PLAYERS],austread[128];
new ausbildungstime[MAX_PLAYERS],ausbtimer[MAX_PLAYERS][128],ausbtimerid[MAX_PLAYERS],anticheattimer[MAX_PLAYERS],muted[MAX_PLAYERS];
new vote = 0,votes = 0,voted[MAX_PLAYERS],Text:counter,missionstarted = 0,timerstarted = 0,isinmission[MAX_PLAYERS];
new npcvehicle[10],streamednpc[20],missioncp = 0,Float:aimx[MAX_PLAYERS],Float:aimy[MAX_PLAYERS],Float:aimz[MAX_PLAYERS],Float:aima[MAX_PLAYERS],Float:aimdistance[MAX_PLAYERS];
new miss1pickup,missobjects[100],Float:tempx[MAX_PLAYERS],Float:tempy[MAX_PLAYERS],Float:tempz[MAX_PLAYERS],miss1trigger = 0;
new Menu:QuickChat;

Float:getwepdistance(playerid);
Float:GetDistanceBetweenPlayers(p1,p2);
forward killtorank(playerid);
forward clearchat(playerid);
forward anticheat(playerid);
forward play_mission(playerid);
forward ausbildungstimer(playerid);
forward spawn(playerid);
forward SetPlayerRank(playerid);
forward voteoff(playerid);
forward StartMission1();
forward npc_miss1_anflug(npc);
forward npc_miss1_abflug(npc);
forward Del_Kick(playerid);
forward Del_Spec(playerid,targetid);
forward mgfire(playerid);
forward IGText(playerid,text[]);

main()
{
}

public OnGameModeInit()
{
    Seifensive_OnInit();
    ShowNameTags(0);
	ShowPlayerMarkers(0);
	SetGameModeText("Call of War");
	AddServerRule("Mission","-");
	
	//-----------[menu
	QuickChat = CreateMenu(" ", 1, 5.0,170.0, 187.0, 0.0);
	SetMenuColumnHeader(QuickChat,0,"Quick Chat");
	AddMenuItem(QuickChat,0," Los Los Los");
	AddMenuItem(QuickChat,0," Deckung");
	AddMenuItem(QuickChat,0," Sammeln");
	AddMenuItem(QuickChat,0," Warten");
	
	counter = TextDrawCreate(83.000000,303.000000,"Zeit: ~n~5");
	TextDrawUseBox(counter,1);
	TextDrawBoxColor(counter,0x00000066);
	TextDrawTextSize(counter,-23.000000,110.000000);//110
	TextDrawAlignment(counter,2);
	TextDrawBackgroundColor(counter,0x000000ff);
	TextDrawFont(counter,3);
	TextDrawLetterSize(counter,0.399999,1.000000);
	TextDrawColor(counter,0xffffffff);
	TextDrawSetOutline(counter,1);
	TextDrawSetProportional(counter,1);
	TextDrawSetShadow(counter,1);
	print("------------------------------------------------");
	print("-------------Call of War loaded-----------------");
	print("------------------------------------------------");
	for(new init = 0;init<MAX_PLAYERS;init++) if(IsPlayerConnected(init)) Kick(init);
	return 1;
}

public OnGameModeExit()
{
	TextDrawDestroy(counter);
	for(new destr = 0;destr<=sizeof(missobjects);destr++) DestroyObject(missobjects[destr]);
	for(new init = 0;init<MAX_PLAYERS;init++) if(IsPlayerConnected(init)) Kick(init);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return 1;
	if(loggedin[playerid] == 0)
	{
		GameTextForPlayer(playerid,"Logge dich ein !",350,3);
	}
	else SpawnPlayer(playerid);
	SetPlayerCameraPos(playerid,1734.4269,1598.9740,20.2056);
	SetPlayerCameraLookAt(playerid, 1721.2367,1604.1365,21.6505);
	return 1;
}

public OnPlayerConnect(playerid)
{
	//sektion variabeln
	loggedin[playerid] = 0,adminlevel[playerid] = 0,ausbildung[playerid] = 0,kills[playerid] = 0,ausbildungsrace[playerid] = 0;
 	antispam1[playerid] = 0,antispam2[playerid] = 0,antispam3[playerid] = 0,antispam4[playerid] = 0,antispamcount[playerid] = 0;
	muted[playerid] = 0,voted[playerid] = 0,isinmission[playerid] = 0;
	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	if(IsPlayerNPC(playerid))
	{
		loggedin[playerid] = 1;
		SpawnPlayer(playerid);
		return 1;
	}
	clearchat(playerid);
	//effekte
	if(INI_Open("Users.ini"))
	{
    	new password[128];
		if (INI_ReadString(password, player_name[playerid], MAX_PLAYER_NAME)) // wenn string gefunden
		{
			ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Willkommen zurück","Da bist du ja endlich ! Wir brauchen dich dringend !\n Los, an die Front mit dir !\n\n Logge dich mit deinem Passwort ein:","Absenden","Verlassen");
		}
		else { ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen im Krieg, Kadett !\n Um deine Ausbildung zu beginnen, brauchen wir erstmal deine Daten.\n Gib nun bitte dein Passwort ein,\n mit dem du in Zukunft identifiziert werden willst :","Registrieren","Verlassen"); }
		INI_Close();
	}
	
	//join-message
	new output1[128];
	format(output1,sizeof(output1),"%s hat den Server betreten",player_name[playerid]);
    SendClientMessageToAll(COLOR_GREY,output1);
    
    
    Seifensive_OnPlayerConnect(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new name[64];
	GetPlayerName(playerid,name,64);
	isinmission[playerid] = 0;
	if(IsPlayerNPC(playerid)) return 1;
 /*
	if(IsPlayerNPC(playerid))
	{
		if(!strcmp(name,"miss1_anflug"))
		{
		    for(new disc=0;disc<=MAX_PLAYERS;disc++) if(ausbildung[disc] == 1 && isinmission[disc] == 1)
		    {
		        TogglePlayerSpectating(disc,0);
		        SetCameraBehindPlayer(disc);
		        TogglePlayerControllable(disc,1);
		    }
		    return 1;
		}
		else return 1;
	} */
	if(isinmission[playerid] == 1)
	{
	    new found = 0;
	    for(new check=0;check<=MAX_PLAYERS;check++)
	    {
	        if(IsPlayerConnected(check) && !IsPlayerNPC(check) && isinmission[check] == 1)
			{
			    found = 1;
			    break;
			}
	    }
	    if(found == 0)
	    {
	        for(new check2=0;check2<=MAX_PLAYERS;check2++)
		    {
		        if(IsPlayerConnected(check2) && IsPlayerNPC(check2))  Kick(check2);
		    }
		    GameTextForAll("~r~Mission fehlgeschlagen",3000,1);
		    mission = 1,missionstarted = 0;
		    SetServerRule("Mission","-");
		    for(new check3=0;check3<=MAX_PLAYERS;check3++)
		    {
		        if(IsPlayerConnected(check3) && !IsPlayerNPC(check3) && GetPlayerState(check3) == 9)
		        {
		            TogglePlayerSpectating(check3,0);
		            SpawnPlayer(check3);
		            SetCameraBehindPlayer(check3);
		            play_mission(check3);
				}
		    }
	  		return 0;
	    
	    }
	}
	new output2[128];
	switch(reason)
	{
    	case 0:format(output2,sizeof(output2),"%s hat den Server verlassen (Timeout)",player_name[playerid]);
		case 1:format(output2,sizeof(output2),"%s hat den Server verlassen ",player_name[playerid]);
		case 2:format(output2,sizeof(output2),"%s hat den Server verlassen (Kick/Ban)",player_name[playerid]);
	}
    SendClientMessageToAll(COLOR_GREY,output2);
    Seifensive_OnPlayerDisconnect(playerid, reason);
    DestroyVehicle(ausbildungscar[playerid]);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerHealth(playerid,5);
	new name[64];
	GetPlayerName(playerid,name,64);
	if(IsPlayerNPC(playerid))
	{
	    SetPlayerTeam(playerid,2);
		if(!strcmp(name,"miss1_anflug"))
		{
            SetPlayerVirtualWorld(playerid,0);
			SetPlayerSkin(playerid,287);
		    streamednpc[0] = playerid;
		    npcvehicle[0] = CreateVehicle(548,0,0,0,0,0,0,0);
		    PutPlayerInVehicle(playerid,npcvehicle[0],0);
		    SetTimerEx("npc_miss1_anflug",2000,0,"i",playerid);
            for(new start=0;start<MAX_PLAYERS;start++)
			{
			    if(IsPlayerConnected(start) && !IsPlayerNPC(start) && ausbildung[start] == 1)
				{
					isinmission[start] = 1;
					SetPlayerVirtualWorld(start,0);
                    GameTextForPlayer(start,"Besatzung entbehrlich - Prolog",2000,1);
                    SetTimerEx("Del_Spec",4500,0,"ii",start,playerid);
				}
		    }
		    return 1;
		}
		if(!strcmp(name,"miss1_abfahrt"))
		{
		    SetPlayerVirtualWorld(playerid,0);
		    SetPlayerSkin(playerid,287);
		    npcvehicle[0] = CreateVehicle(548,0,0,0,0,0,0,0);
		    streamednpc[0] = playerid;
		    PutPlayerInVehicle(playerid,npcvehicle[0],0);
		    SetTimerEx("npc_miss1_abflug",5000,0,"i",playerid);
		    return 1;
		}
		if(!strcmp(name,"miss1_npc") || !strcmp(name,"miss1_npc2"))
		{
			switch(random(6))
			{
			    case 0:SetPlayerSkin(playerid,111);
			    case 1:SetPlayerSkin(playerid,112);
			    case 2:SetPlayerSkin(playerid,120);
			    case 3:SetPlayerSkin(playerid,126);
			    case 4:SetPlayerSkin(playerid,124);
			    case 5:SetPlayerSkin(playerid,206);
			}
		    SetPlayerHealth(playerid,10);
		    if(!strcmp(name,"miss1_npc2")) streamednpc[1] = playerid;
		    else streamednpc[0] = playerid;
		    return 1;
		}
		return 1;
	}
	if(IsPlayerNPC(playerid)) return 1;
    Seifensive_OnPlayerSpawn(playerid);
    KillTimer(anticheattimer[playerid]);
    anticheattimer[playerid] = SetTimerEx("anticheat",5000,0,"i",playerid);
    
	if(loggedin[playerid] == 0)
	{
	    ForceClassSelection(playerid);
	    SetPlayerHealth(playerid,0);
	}
	SetPlayerTeam(playerid,1);
	play_mission(playerid);
 	SetPlayerRank(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	SetPlayerWorldBounds(playerid,20000.0000, -20000.0000, 20000.0000, -20000.0000);
	DisablePlayerCheckpoint(playerid);
	DisablePlayerRaceCheckpoint(playerid);
	isinmission[playerid] = 0;
	if(!IsPlayerNPC(playerid) && ausbildung[playerid] == 0) return play_mission(playerid);
	if(!IsPlayerNPC(playerid))
	{
		new found = 0;
	    for(new check1=0;check1<=MAX_PLAYERS;check1++)
	    {
	        if(IsPlayerConnected(check1) && !IsPlayerNPC(check1) && isinmission[check1] == 1)
	        {
	            found = 1;
	            break;
			}
	    }
	    if(found == 0)
	    {
	        for(new check2=0;check2<=MAX_PLAYERS;check2++)
		    {
		        if(IsPlayerConnected(check2) && IsPlayerNPC(check2))  Kick(check2);
		    }
		    GameTextForAll("~r~Mission fehlgeschlagen",3000,1);
		    mission = 1,missionstarted = 0;
		    SetServerRule("Mission","-");
		    for(new check3=0;check3<=MAX_PLAYERS;check3++)
		    {
		        if(IsPlayerConnected(check3) && !IsPlayerNPC(check3) && GetPlayerState(check3) == 9)
		        {
		            TogglePlayerSpectating(check3,0);
		            SpawnPlayer(check3);
		            SetCameraBehindPlayer(check3);
		            play_mission(check3);
				}
		    }
	  		return 0;
	    }
	    for(new check4=0;check4<=MAX_PLAYERS;check4++)
	    {
	        if(specdeath[check4] == playerid && GetPlayerState(check4) == 9)
	        {
	            new specid;
	        	for(new check5=0;check5<=MAX_PLAYERS;check5++)
	        	{
	        	    if(!IsPlayerConnected(check5) && GetPlayerState(check5) != 9)
	        	    {
						specid = check5;
						break;
					}
				}
				TogglePlayerSpectating(playerid,1);
				PlayerSpectatePlayer(playerid,specid);
				TogglePlayerSpectating(check4,1);
				PlayerSpectatePlayer(check4,specid);
	        }
	    }
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	for(new check=0;check<=MAX_PLAYERS;check++)
	{
	    if(vehicleid == ausbildungscar[check])
		{
			GameTextForPlayer(check,"~r~Pruefung erfolglos",3000,1);
		    KillTimer(ausbtimerid[check]);
		    TextDrawHideForPlayer(check,counter);
		    DestroyVehicle(ausbildungscar[check]);
		    isinmission[check] = 0;
		    play_mission(check);
		    return 1;
		}
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
    if(muted[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"Du bist gemuted !");
	if(isinmission[playerid] == 0 || ausbildung[playerid] == 0)
	{
	    new string[128],name[64];
	    GetPlayerName(playerid,name,64);
	    format(string,128,"[Spec-%s] %s",name,text);
	    for(new write=0;write<MAX_PLAYERS;write++)
	    {
	        if(adminlevel[write] != 0 || isinmission[write] == 0 || ausbildung[write] == 0)
	        {
				SendClientMessage(write,COLOR_GREY,string);
	        }
	    }
	    return 0;
	}
    antispamcount[playerid] = antispamcount[playerid] + 1;
	if(antispamcount[playerid] == 5) { antispamcount[playerid] = 1; }
	switch(antispamcount[playerid])
	{
	    case 1:antispam1[playerid] = strlen(text);
	    case 2:antispam2[playerid] = strlen(text);
	    case 3:antispam3[playerid] = strlen(text);
	    case 4:antispam4[playerid] = strlen(text);
	}
	if(antispamcount[playerid] == 4)
	{
	    if((antispam1[playerid] == antispam2[playerid]) && (antispam2[playerid] == antispam3[playerid]) && (antispam3[playerid] == antispam4[playerid]))
	    {
	        new kickname[MAX_PLAYERS],kickoutput[128];
	        GetPlayerName(playerid,kickname,sizeof(kickname));
	        format(kickoutput,sizeof(kickoutput),"%s wurde wegen Spammens gekickt !");
	        SendClientMessageToAll(COLOR_RED,kickoutput);
	        Kick(playerid);
	        return 0;
	    }
	}
	
	if(IsPlayerInAnyVehicle(playerid))
	{
	    new name[MAX_PLAYER_NAME], string[48],tlive,tlive2,rangname[128];
		GetPlayerName(playerid, name, sizeof(name));
		switch (killtorank(playerid))
		{
		    case 0:format(rangname,sizeof(rangname),"Anwärter");
		    case 1:format(rangname,sizeof(rangname),"Soldat");
		    case 2:format(rangname,sizeof(rangname),"Gefreiter");
		    case 3:format(rangname,sizeof(rangname),"Unteroffizier");
		    case 4:format(rangname,sizeof(rangname),"Feldwebel");
		    case 5:format(rangname,sizeof(rangname),"Leutnant");
		    case 6:format(rangname,sizeof(rangname),"Hauptmann");
		    case 7:format(rangname,sizeof(rangname),"Major");
		    case 8:format(rangname,sizeof(rangname),"Brigadegeneral");
		    case 9:format(rangname,sizeof(rangname),"General");
		}
		new Float:vehhealth = GetVehicleHealth(GetPlayerVehicleID(playerid),vehhealth);
		if(vehhealth <= 100.0)
		{
		    return SendClientMessage(playerid,COLOR_RED,"Das Funkgerät ist kaputt !");
		}
		else
		{
		    if(vehhealth < 950.0)
		    {
				tlive = random(floatround(floatdiv(vehhealth,100)*float(5)));
			    tlive2 = random(floatround(floatdiv(vehhealth,100)*float(3)));
				format(string,sizeof(string),"[%s]%s:%s *knack*",rangname,name,strdel(string,tlive,tlive+tlive2));
			}
			else format(string, sizeof(string), "[%s]%s:%s",rangname, name, text );
		}
		for(new v=0;v<=MAX_PLAYERS;v++)
		{
		    if(IsPlayerInAnyVehicle(v))
		    {
				SendClientMessage(v,COLOR_LIGHTBLUE,string);
				SetTimerEx("clearchat",3000,0,"i",v);
			}
		}
	}
	else
	{
		SetPlayerChatBubble(playerid,text,COLOR_LIGHTRED,15.0,3000);
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(IsPlayerNPC(playerid)) return 1;
	for(new check55;check55<sizeof(npcvehicle);check55++)
	{
		if(npcvehicle[check55] == vehicleid)
		{
		    TogglePlayerControllable(playerid,0);
		    TogglePlayerControllable(playerid,1);
		    return 0;
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(vehicleid == ausbildungscar[playerid])
	{
	    GameTextForPlayer(playerid,"~r~Pruefung erfolglos",3000,1);
	    TextDrawHideForPlayer(playerid,counter);
	    KillTimer(ausbtimerid[playerid]);
	    isinmission[playerid] = 0;
	    DestroyVehicle(ausbildungscar[playerid]);
	    play_mission(playerid);
	    return 1;
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(IsPlayerNPC(playerid)) return 0;
	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	if(isinmission[playerid] == 1 && ausbildung[playerid] == 1)
	{
	    if(mission == 1)
	    {
	        if(missioncp == 100)
	        {
	            DisablePlayerCheckpoint(playerid);
             	kills[playerid] += 5;
				SetPlayerScore(playerid,kills[playerid]);
				if(INI_Open("Users.ini"))
				{
					new tmpoutput[128];
					format(tmpoutput,128,"%skills",player_name[playerid]);
					INI_WriteInt(tmpoutput,kills[playerid]);
					INI_Save();
					INI_Close();
				}
				SetServerRule("Mission","-");
    			TogglePlayerSpectating(playerid,1);
				PlayerSpectateVehicle(playerid,npcvehicle[0]);
				mission += 1;
				for(new newmiss=0;newmiss<=MAX_PLAYERS;newmiss++)
				{
				    if(ausbildung[newmiss] == 1 && IsPlayerConnected(newmiss) && !IsPlayerNPC(newmiss))
				    {
				        GameTextForPlayer(newmiss,"~g~Mission erfolgreich",6000,0);
				        SetTimerEx("play_mission",6000,0,"i",newmiss);
				    }
				}
				return 1;
	        }
	        if(missioncp > 1 || missioncp >= 100) DestroyVehicle(npcvehicle[0]);
	        for(new set=0;set<MAX_PLAYERS;set++)
			{
		   		if(IsPlayerNPC(set) && missioncp != 1) Kick(set);
			}
	        new Float:readcpx,Float:readcpy,Float:readcpz,readstring[128];
	        if(missioncp >= 15)
	        {
	            miss1pickup = CreatePickup(1210,22,-2373.1677,1552.5616,2.1898,0);
	            return 1;
			}
	        if(INI_Open("mission1cp.ini"))
	        {
	            for(new con=0;con!=5;con++)
	            {
	                missioncp += 1;
	                format(readstring,128,"x%d",missioncp);
	                if(INI_KeyExist(readstring))
	                {
	                    readcpx = INI_ReadFloat(readstring);
					    format(readstring,128,"y%d",missioncp);
					    readcpy = INI_ReadFloat(readstring);
					    format(readstring,128,"z%d",missioncp);
					    readcpz = INI_ReadFloat(readstring);

					    format(readstring,128,"miss1_npc%d",missioncp);
					    ConnectNPC("miss1_npc",readstring);
	                }
	                for(new set=0;set<MAX_PLAYERS;set++)
					{
		   				if(IsPlayerNPC(set) && missioncp != 1) Kick(set);
						else if(missioncp > 1 || missioncp >= 100) DestroyVehicle(npcvehicle[0]);
						if(!IsPlayerNPC(set) && ausbildung[set] == 1 && isinmission[set] == 1 && IsPlayerConnected(set))
						{
					 		DisablePlayerCheckpoint(set);
						    SetPlayerCheckpoint(set,readcpx,readcpy,readcpz,3);
				  		}
					}
					if(missioncp >= 15)
			        {
			            miss1pickup = CreatePickup(1210,22,-2373.1677,1552.5616,2.1898,0);
			            return 1;
					}
	            }
	        }
	    }
	    return 1;
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(ausbildung[playerid] == 0 && ausbildungsrace[playerid] == 1)
	{
	    ausbildungstime[playerid] += 4;
	    RepairVehicle(GetPlayerVehicleID(playerid));
	    SetVehicleHealth(GetPlayerVehicleID(playerid),1000);
	    if(INI_Open("dodo.ini"))
        {
            format(austread,sizeof(austread),"%dx",ausbildungscount[playerid]);
			checkreadx[playerid] = INI_ReadFloat(austread);
			format(austread,sizeof(austread),"%dy",ausbildungscount[playerid]);
			checkready[playerid] = INI_ReadFloat(austread);
			format(austread,sizeof(austread),"%dz",ausbildungscount[playerid]);
			checkreadz[playerid] = INI_ReadFloat(austread);
			ausbildungscount[playerid] += 1;
			format(austread,sizeof(austread),"%dx",ausbildungscount[playerid]);
			
			if(INI_KeyExist(austread))
			{
	            checkreadx2[playerid] = INI_ReadFloat(austread);
	            format(austread,sizeof(austread),"%dy",ausbildungscount[playerid]);
				checkready2[playerid] = INI_ReadFloat(austread);
				format(austread,sizeof(austread),"%dz",ausbildungscount[playerid]);
				checkreadz2[playerid] = INI_ReadFloat(austread);
				ausbildungsrace[playerid] = 1;
	            SetPlayerRaceCheckpoint(playerid, 3, checkreadx[playerid], checkready[playerid], checkreadz[playerid],checkreadx2[playerid] ,checkready2[playerid] , checkreadz2[playerid], 10);
				INI_Close();
			}
   			else
	  		{
	  		    INI_Close();
	  		    KillTimer(ausbtimerid[playerid]);
	  		    DisablePlayerRaceCheckpoint(playerid);
	  		    ausbildungstime[playerid] = 8;
	  		    ausbtimerid[playerid] = SetTimerEx("ausbildungstimer",1000,0,"i",playerid);
	  		    DestroyVehicle(ausbildungscar[playerid]);
	  		    SetPlayerVirtualWorld(playerid,playerid+1);
		 	    ausbildungscar[playerid] = CreateVehicle(470,-1222.876953,54.051624,14.125999,44.6769,0,0,1);
		        SetVehicleVirtualWorld(ausbildungscar[playerid], playerid+1);
		        PutPlayerInVehicle(playerid,ausbildungscar[playerid],0);
		        if(INI_Open("barrack.ini"))
		        {
					checkreadx[playerid] = INI_ReadFloat("2x");
					checkready[playerid] = INI_ReadFloat("2y");
					checkreadz[playerid] = INI_ReadFloat("2z");
		            checkreadx2[playerid] = INI_ReadFloat("3x");
					checkready2[playerid] = INI_ReadFloat("3y");
					checkreadz2[playerid] = INI_ReadFloat("3z");
					ausbildungscount[playerid] = 3,ausbildungsrace[playerid] = 2;
					
		            SetPlayerRaceCheckpoint(playerid, 0, checkreadx[playerid], checkready[playerid], checkreadz[playerid],checkreadx2[playerid] ,checkready2[playerid] , checkreadz2[playerid], 10);
		            INI_Close();
		            GameTextForPlayer(playerid,"~g~Bestehe die Fahrpruefung",3000,0);
		            return 1;
				}
	  		
	  		}
			
            return 1;
		}
	}
	if(ausbildung[playerid] == 0 && ausbildungsrace[playerid] == 2)
	{
	    ausbildungstime[playerid] += 3;
	    RepairVehicle(GetPlayerVehicleID(playerid));
	    SetVehicleHealth(GetPlayerVehicleID(playerid),1000);
	    if(INI_Open("barrack.ini"))
        {
            format(austread,sizeof(austread),"%dx",ausbildungscount[playerid]);
			checkreadx[playerid] = INI_ReadFloat(austread);
			format(austread,sizeof(austread),"%dy",ausbildungscount[playerid]);
			checkready[playerid] = INI_ReadFloat(austread);
			format(austread,sizeof(austread),"%dz",ausbildungscount[playerid]);
			checkreadz[playerid] = INI_ReadFloat(austread);
			ausbildungscount[playerid] += 1;
			format(austread,sizeof(austread),"%dx",ausbildungscount[playerid]);
			if(INI_KeyExist(austread))
			{
	            checkreadx2[playerid] = INI_ReadFloat(austread);
	            format(austread,sizeof(austread),"%dy",ausbildungscount[playerid]);
				checkready2[playerid] = INI_ReadFloat(austread);
				format(austread,sizeof(austread),"%dz",ausbildungscount[playerid]);
				checkreadz2[playerid] = INI_ReadFloat(austread);
	            SetPlayerRaceCheckpoint(playerid, 0, checkreadx[playerid], checkready[playerid], checkreadz[playerid],checkreadx2[playerid] ,checkready2[playerid] , checkreadz2[playerid], 3);
				INI_Close();
			}
   			else
	  		{
	            INI_Close();
	            TextDrawHideForPlayer(playerid,counter);
	            DisablePlayerRaceCheckpoint(playerid);
	            DestroyVehicle(GetPlayerVehicleID(playerid));
	            ausbildung[playerid] = 1,isinmission[playerid] = 0;
	            GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	            if(INI_Open("Users.ini"))
	            {
	                KillTimer(ausbtimerid[playerid]);
	                new tmpoutput[128];
					format(tmpoutput,128,"%sausbildung",player_name[playerid]);
					GameTextForPlayer(playerid,"~g~Ausbildung bestanden",3000,0);
					INI_WriteInt(tmpoutput,1);
					format(tmpoutput,128,"%skills",player_name[playerid]);
					INI_WriteInt(tmpoutput,5);
					kills[playerid] = 5;
					INI_Save();
					INI_Close();
				}
				play_mission(playerid);
	            SetPlayerRank(playerid);
	            return 1;
	        }
		}
	}
	
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(muted[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"Du bist gemuted !");
	dcmd(kick, 4 , cmdtext);
	dcmd(ban, 3, cmdtext);
	dcmd(votekick, 8, cmdtext);
	dcmd(vote, 4, cmdtext);
	dcmd(waffe, 5, cmdtext);
	dcmd(fuckup,6,cmdtext);
	dcmd(spawn,5,cmdtext);
	dcmd(jump,4,cmdtext);
	dcmd(spec,4,cmdtext);
	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if(IsPlayerNPC(playerid)) return 0;
	
	if(pickupid == miss1pickup)
	{
	    CreateExplosion(-2377.646973, 1557.030273, 4.472926,11,1);
	    CreateExplosion(-2408.119629, 1557.006592, 4.205361,11,1);
		CreateExplosion(-2408.119629, 1557.006592, 4.205361,11,1);
	    DestroyPickup(miss1pickup);
	    DestroyObject(missobjects[16]);
		DestroyObject(missobjects[18]);
	    missobjects[19] = CreateObject(850, -2377.625000, 1556.945190, 4.153678, 0.0000, 283.5101, 90.2409);
		missobjects[20] = CreateObject(2960, -2378.901123, 1557.179565, 4.529061, 0.0000, 15.4699, 315.0000);
		missobjects[21] = CreateObject(850, -2377.819824, 1557.106201, 4.255359, 301.5583, 283.5101, 102.2730);
		missobjects[22] = CreateObject(9831, -2377.982178, 1555.987915, 2.896728, 0.0000, 0.0000, 191.2500);
		missobjects[23] = CreateObject(9831, -2378.491455, 1534.134644, -0.671154, 6.8755, 359.1406, 180.0000);
		missobjects[24] = CreateObject(9831, -2407.086182, 1536.279541, -0.621153, 6.8755, 359.1406, 90.0000);
		missobjects[25] = CreateObject(9831, -2373.604492, 1532.216553, -1.121149, 171.7832, 359.1406, 180.0000);
		missobjects[26] = CreateObject(9831, -2407.261230, 1532.541992, -1.146154, 171.7832, 359.1406, 180.0000);
		missobjects[27] = CreateObject(16501, -2438.118896, 1552.526611, 16.103621, 0.0000, 269.7591, 90.0000); //luke 1
		missobjects[28] = CreateObject(16501, -2438.118896, 1552.526611, 16.103621, 0.0000, 269.7591, 90.0000);//luke 2
		missobjects[29] = CreateObject(16501, -2438.118896, 1552.526611, 16.103621, 0.0000, 269.7591, 90.0000);//luke 3
		missobjects[30] = CreateObject(16501, -2438.118896, 1552.526611, 16.103621, 0.0000, 269.7591, 90.0000);//luke 4
        MoveObject(missobjects[27],-2438.093506, 1548.100098, 16.078594,1.0);
		MoveObject(missobjects[28],-2438.093262, 1543.716797, 16.086662,0.3);
		MoveObject(missobjects[29],-2438.079102, 1539.329102, 16.087978,0.3);
		MoveObject(missobjects[30],-2438.081787, 1534.917603, 16.092049,0.3);
		missobjects[31] = CreateObject(2934, -2427.169678, 1549.232056, 2.569107, 0.0000, 91.1003, 146.2500);
		missobjects[32] = CreateObject(850, -2408.119629, 1557.006592, 4.205361, 301.5583, 283.5101, 102.2730);
		missobjects[33] = CreateObject(9831, -2433.117920, 1541.909180, -0.746154, 6.8755, 359.1406, 112.5000);
		missobjects[34] = CreateObject(9831, -2441.286377, 1554.703979, 1.253850, 41.2530, 359.1406, 270.0000);
		missobjects[35] = CreateObject(9831, -2373.604492, 1532.216553, -1.121149, 171.7832, 359.1406, 180.0000);
		missobjects[36] = CreateObject(9831, -2414.186523, 1543.467163, -1.146154, 171.7832, 359.1406, 180.0000);
		missobjects[37] = CreateObject(2960, -2409.223145, 1557.038940, 2.621728, 0.0000, 329.0603, 319.2972);
		missobjects[38] = CreateObject(850, -2407.932617, 1556.775024, 3.425174, 0.0000, 283.5101, 90.2409);
		missobjects[39] = CreateObject(9831, -2408.249268, 1556.735962, 3.028847, 0.0000, 0.0000, 191.2500);
		missobjects[40] = CreateObject(9831, -2426.455811, 1552.069824, -1.146152, 171.7832, 359.1406, 56.2500);
		missobjects[41] = CreateObject(9831, -2429.333740, 1546.813232, -1.240195, 171.7832, 359.1406, 0.0000);
		missobjects[42] = CreateObject(9831, -2432.334961, 1535.996216, -0.596153, 6.8755, 359.1406, 180.0000);
		missobjects[43] = CreateObject(9831, -2436.331299, 1534.976318, -0.665195, 6.8755, 359.1406, 135.0000);
		missobjects[44] = CreateObject(9831, -2425.986816, 1544.447266, -0.621153, 6.8755, 359.1406, 225.0000);
		missobjects[45] = CreateObject(9831, -2431.093506, 1552.979248, -0.646153, 171.7832, 359.1406, 67.5000);
		missobjects[46] = CreateObject(9831, -2431.114258, 1548.580566, -0.496153, 171.7832, 359.1406, 281.2500);
		missobjects[47] = CreateObject(9831, -2432.666992, 1545.403320, -0.221153, 171.7832, 359.1406, 337.5001);
		missobjects[48] = CreateObject(2934, -2396.395020, 1554.931274, 2.569107, 0.0000, 58.4417, 98.6717);
		
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerNPC(i)) Kick(i);
			if(isinmission[i] == 1 && ausbildung[i] == 1 && IsPlayerConnected(i))
			{
				SetPlayerDrunkLevel(i,50000);
				GameTextForPlayer(i,"~r~Raus hier !",1000,1);
				clearchat(i);
				SendClientMessage(i,COLOR_GREY,"Das Schiff wurde beschossen !");
				SendClientMessage(i,COLOR_GREY,"Alle raus hier, bevor sich das Verdeck schließt !");
				ausbildungstime[i] = 48;
				ausbtimerid[i] = SetTimerEx("ausbildungstimer",1000,0,"i",playerid);
			}
		}
		
		
	}
	
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	new Menu:current;
    current = GetPlayerMenu(playerid);
    if(current == QuickChat)
    {
        switch(row)
        {
            case 0:
			{
				new RandomMSG = random(2);
				if(RandomMSG == 0) IGText(playerid,"Los Los Los!");
				else if(RandomMSG == 1) IGText(playerid,"Los Bewegung!");
			}
            case 1:
			{
				new RandomMSG = random(2);
				if(RandomMSG <= 0) IGText(playerid,"In Deckung!");
				else if(RandomMSG == 1) IGText(playerid,"Volle Deckung!");
			}
            case 2:
			{
				new RandomMSG = random(2);
				if(RandomMSG <= 0) IGText(playerid,"Team Sammeln!");
				else if(RandomMSG == 1) IGText(playerid,"Zusammen bleiben Team!");
			}
            case 3:
			{
				new RandomMSG = random(2);
				if(RandomMSG <= 0) IGText(playerid,"Stop,Team Warten!");
				else if(RandomMSG == 1) IGText(playerid,"Halt,Team Warten!");
			}
		}
	}
	return 1;
}

public IGText(playerid,text[])
{
	GetPlayerPos(playerid,tempx[playerid],tempy[playerid],tempz[playerid]);
    for(new start=0;start<MAX_PLAYERS;start++)
	{
		if(IsPlayerConnected(start) && IsPlayerInRangeOfPoint(start,10,tempx[playerid],tempy[playerid],tempz[playerid]))
		{
            SendClientMessage(start,COLOR_RED,text);
            SetTimerEx("clearchat",3000,0,"i",start);
		}
	}
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public mgfire(playerid)
{
	new mgf1,mgf2,mgf3;
	GetPlayerKeys(playerid,mgf1,mgf2,mgf3);
	if(mgf1 == 4 || mgf1 & 4) OnPlayerKeyStateChange(playerid, KEY_FIRE, 0);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (newkeys & KEY_WALK || newkeys == KEY_WALK)
 	{
    	ShowMenuForPlayer(QuickChat,playerid);
    	return 1;
	}
	if(newkeys == KEY_FIRE || newkeys == 4 || newkeys & 4 || newkeys & KEY_FIRE)
	{
		if(ausbildung[playerid] == 1 && !IsPlayerNPC(playerid) && isinmission[playerid] == 1)
		{
		    if(GetPlayerWeapon(playerid) > 10) SetTimerEx("mgfire",300,0,"i",playerid);
		    switch(mission)
		    {
		        case 1:
		        {
		            if(IsPlayerConnected(streamednpc[0]) && IsPlayerNPC(streamednpc[0]))
		            {
			            aimdistance[playerid] = GetDistanceBetweenPlayers(playerid,streamednpc[0]);
			            if(getwepdistance(playerid)<aimdistance[playerid]) return 1;
						GetPlayerPos(playerid,aimx[playerid],aimy[playerid],aimz[playerid]);
						GetPlayerFacingAngle(playerid,aima[playerid]);

	                    aimx[playerid] += (aimdistance[playerid] * floatsin(-aima[playerid], degrees));
						aimy[playerid] += (aimdistance[playerid] * floatcos(-aima[playerid], degrees));
						if(IsPlayerInRangeOfPoint(streamednpc[0],0.3,aimx[playerid],aimy[playerid],aimz[playerid]))
						{
						    kills[playerid] += 1;
							SetPlayerScore(playerid,kills[playerid]);
							GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
							if(INI_Open("Users.ini"))
				            {
				                new tmpoutput[128];
								format(tmpoutput,128,"%skills",player_name[playerid]);
								INI_WriteInt(tmpoutput,kills[playerid]);
								INI_Save();
								INI_Close();
							}
							else print("Fail open : Users.ini");
						    for(new apply=0;apply<2;apply++) ApplyAnimation(streamednpc[0],"fight_d","HitD_3",3,0,1,1,1,0);
						    SetTimerEx("Del_Kick",3000,0,"i",streamednpc[0]);
						}
					}
					if(IsPlayerConnected(streamednpc[1]) && IsPlayerNPC(streamednpc[1]))
		            {
			            aimdistance[playerid] = GetDistanceBetweenPlayers(playerid,streamednpc[1]);
			            if(getwepdistance(playerid)<aimdistance[playerid]) return 1;
						GetPlayerPos(playerid,aimx[playerid],aimy[playerid],aimz[playerid]);
						GetPlayerFacingAngle(playerid,aima[playerid]);

	                    aimx[playerid] += (aimdistance[playerid] * floatsin(-aima[playerid], degrees));
						aimy[playerid] += (aimdistance[playerid] * floatcos(-aima[playerid], degrees));
						if(IsPlayerInRangeOfPoint(streamednpc[1],0.3,aimx[playerid],aimy[playerid],aimz[playerid]))
						{
							kills[playerid] += 1;
							SetPlayerScore(playerid,kills[playerid]);
							GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
							if(INI_Open("Users.ini"))
				            {
				                new tmpoutput[128];
								format(tmpoutput,128,"%skills",player_name[playerid]);
								INI_WriteInt(tmpoutput,kills[playerid]);
								INI_Save();
								INI_Close();
							}
							else print("Fail open : Users.ini");
						    for(new apply=0;apply<2;apply++) ApplyAnimation(streamednpc[1],"fight_d","HitD_3",3,0,1,1,1,0);
						    SetTimerEx("Del_Kick",3000,0,"i",streamednpc[1]);
      					}
					}
					return 1;
		        }
		    }
	 	}
 	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
    if(!response && (dialogid == 1 || dialogid == 2)) return Kick(playerid);
    switch(dialogid)
    {
        case 1:
        {
            if(!strlen(inputtext)) { ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen im Krieg, Kadett !\n Um deine Ausbildung zu beginnen, brauchen wir erstmal deine Daten.\n Gib nun bitte dein Passwort ein,\n mit dem du in Zukunft identifiziert werden willst :","Registrieren","Verlassen"); }
            if(INI_Open("Users.ini"))
            {
				INI_WriteString(player_name[playerid], inputtext);
				new tmpoutput[128];
				format(tmpoutput,128,"%sadminlevel",player_name[playerid]);
				INI_WriteInt(tmpoutput,0);
				format(tmpoutput,128,"%sausbildung",player_name[playerid]);
				INI_WriteInt(tmpoutput,0);
				format(tmpoutput,128,"%skills",player_name[playerid]);
				INI_WriteInt(tmpoutput,0);
				INI_Save();
				INI_Close();
			}
			loggedin[playerid] = 1;
			SpawnPlayer(playerid);
			SetTimerEx("spawn",100,0,"i",playerid);
		}
		case 2:
		{
		    if(INI_Open("Users.ini")) // Users.ini 
			{
				new password[128];
				if (INI_ReadString(password, player_name[playerid], MAX_PLAYER_NAME)) // Wenn Benutzer registriert
				{
					if (strcmp(password, inputtext, false) == 0) // wenn parameter (=eingegebenes pw) = gespeichertes pw
					{
						loggedin[playerid] = 1;
						new tmpoutput[128];
						format(tmpoutput,128,"%sadminlevel",player_name[playerid]);
						adminlevel[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%sausbildung",player_name[playerid]);
						ausbildung[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%skills",player_name[playerid]);
						kills[playerid] = INI_ReadInt(tmpoutput);
						SetPlayerScore(playerid,kills[playerid]);
						if(adminlevel[playerid] >= 1) SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Administrator");

                        SpawnPlayer(playerid);
                        SetTimerEx("spawn",100,0,"i",playerid);
					}
					else { ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Falsches Passwort","Kamerad, das war falsch !\n\n Logge dich mit deinem Passwort ein:","Absenden","Verlassen"); }
				}
				INI_Close();
			}
		}
		case 3:
		{
		    SetCameraBehindPlayer(playerid);
			TextDrawShowForPlayer(playerid,counter);
			if(ausbildungsrace[playerid] == 1 || ausbildungsrace[playerid] == 0 )
			{
			    GameTextForPlayer(playerid,"~g~Bestehe den Flugtest",2000,0);
			    SetPlayerVirtualWorld(playerid,playerid+1);
		 	    ausbildungscar[playerid] = CreateVehicle(593,-1210.624877,282.902313,14.603020,312.5715,0,0,1);
		        SetVehicleVirtualWorld(ausbildungscar[playerid], playerid+1);
		        PutPlayerInVehicle(playerid,ausbildungscar[playerid],0);
		        ausbtimerid[playerid] = SetTimerEx("ausbildungstimer",2000,0,"i",playerid);
		        if(INI_Open("dodo.ini"))
		        {
					checkreadx[playerid] = INI_ReadFloat("2x");
					checkready[playerid] = INI_ReadFloat("2y");
					checkreadz[playerid] = INI_ReadFloat("2z");
		            checkreadx2[playerid] = INI_ReadFloat("3x");
					checkready2[playerid] = INI_ReadFloat("3y");
					checkreadz2[playerid] = INI_ReadFloat("3z");
					ausbildungscount[playerid] = 3,ausbildungsrace[playerid] = 1,ausbildungstime[playerid] = 8;
		            SetPlayerRaceCheckpoint(playerid, 0, checkreadx[playerid], checkready[playerid], checkreadz[playerid],checkreadx2[playerid] ,checkready2[playerid] , checkreadz2[playerid], 10);
		            INI_Close();
		            return 1;
				}
			}
			else if(ausbildungsrace[playerid] == 2)
			{
			    ausbildungstime[playerid] = 8;
	  		    ausbtimerid[playerid] = SetTimerEx("ausbildungstimer",1000,0,"i",playerid);
	  		    SetPlayerVirtualWorld(playerid,playerid+1);
		 	    ausbildungscar[playerid] = CreateVehicle(470,-1222.876953,54.051624,14.125999,44.6769,0,0,1);
		        SetVehicleVirtualWorld(ausbildungscar[playerid], playerid+1);
		        PutPlayerInVehicle(playerid,ausbildungscar[playerid],0);
		        if(INI_Open("barrack.ini"))
		        {
					checkreadx[playerid] = INI_ReadFloat("2x");
					checkready[playerid] = INI_ReadFloat("2y");
					checkreadz[playerid] = INI_ReadFloat("2z");
		            checkreadx2[playerid] = INI_ReadFloat("3x");
					checkready2[playerid] = INI_ReadFloat("3y");
					checkreadz2[playerid] = INI_ReadFloat("3z");
					ausbildungscount[playerid] = 3,ausbildungsrace[playerid] = 2;

		            SetPlayerRaceCheckpoint(playerid, 0, checkreadx[playerid], checkready[playerid], checkreadz[playerid],checkreadx2[playerid] ,checkready2[playerid] , checkreadz2[playerid], 10);
		            INI_Close();
		            GameTextForPlayer(playerid,"~g~Bestehe die Fahrpruefung",3000,0);
		            return 1;
				}
			
			}
		}
    }
	return 1;
}

public killtorank(playerid) //kills stehen für gamepunkte
{
 	if(ausbildung[playerid] == 0) return 0;
	if(kills[playerid] <= 50) return 1;
	if(kills[playerid] <= 100) return 2;
	if(kills[playerid] <= 200) return 3;
	if(kills[playerid] <= 350) return 4;
	if(kills[playerid] <= 550) return 5;
	if(kills[playerid] <= 800) return 6;
	if(kills[playerid] <= 1000) return 7;
	if(kills[playerid] <= 1300) return 8;
	if(kills[playerid] <= 1500) return 9;
	else return -1;
}

public clearchat(playerid)
{
	for(new clear=0;clear<15;clear++) SendClientMessage(playerid,COLOR_GREY," ");
	return 1;
}

public anticheat(playerid)
{
    GetPlayerHealth(playerid,health[playerid]);
	GetPlayerArmour(playerid,armour[playerid]);
	if((health[playerid] > 55.0 || armour[playerid] > 10) && adminlevel[playerid] == 0 && !IsPlayerNPC(playerid) && GetPlayerState(playerid) != 9)
	{
	    new kickname[MAX_PLAYERS],kickoutput[128];
	    GetPlayerName(playerid,kickname,sizeof(kickname));
	    clearchat(playerid);
	    format(kickoutput,sizeof(kickoutput),"%s wurde wegen Lebens-/Rüstungshacks gebannt !");
	    SendClientMessageToAll(COLOR_RED,kickoutput);
		BanEx(playerid,kickoutput);
	}
	else SetTimerEx("anticheat",5000,0,"i",playerid);
	return 1;
}

public play_mission(playerid)
{
	if(isinmission[playerid] == 1) return 1;
	if(ausbildung[playerid] == 0)
	{
	    isinmission[playerid] = 1;
	    SetPlayerVirtualWorld(playerid,playerid+1);
        SetPlayerCameraPos(playerid,1734.4269,1598.9740,20.2056);
		SetPlayerCameraLookAt(playerid, 1721.2367,1604.1365,21.6505);
	    ShowPlayerDialog(playerid,3,DIALOG_STYLE_MSGBOX,"Der Neue","Willkommen in der Armee.\nNachdem du nun die Ausbildung hinter dir hast,\nwird es Zeit, dein Können zu beweisen !\nWir brauchen keine Versager in der Armee !","Test","starten");
	    return 1;
	}
	TogglePlayerSpectating(playerid,0);
	SetPlayerVirtualWorld(playerid,0);
	SetPlayerDrunkLevel(playerid,0);
	TogglePlayerControllable(playerid,0);
	SetPlayerWeather(playerid,0);
	switch (mission)
	{
	    case 1:
	    {
			if(missionstarted == 1)
			{
			    for(new check3=0;check3<=MAX_PLAYERS;check3++)
			    {
			        if(IsPlayerConnected(check3) && !IsPlayerNPC(check3) && GetPlayerState(check3) != 9)
			        {
			            TogglePlayerSpectating(playerid,1);
			            PlayerSpectatePlayer(playerid,check3);
						SendClientMessage(playerid,COLOR_RED,"Du musst warten, bis die Mission beendet ist");
						return 1;
					}
			    }
			
			}
			else
			{
			    if(timerstarted == 0)
			    {
			        timerstarted = 1;
			        SetTimer("StartMission1",15000,0);
			        GameTextForAll("~w~Neue Mission startet in 15 Sekunden",15000,0);
			        SetPlayerCameraPos(playerid,1734.4269,1598.9740,20.2056);
					SetPlayerCameraLookAt(playerid, 1721.2367,1604.1365,21.6505);
			        return 1;
			    }
			    else
			    {
			        GameTextForPlayer(playerid,"~w~Die Mission startet bald",1000,0);
			        SetPlayerCameraPos(playerid,1734.4269,1598.9740,20.2056);
					SetPlayerCameraLookAt(playerid, 1721.2367,1604.1365,21.6505);
			        return 1;
			    }
			}
	    }
	}
	return 1;
}

public StartMission1()
{
    missionstarted = 1,timerstarted = 0,miss1trigger = 0,missioncp = 0;
    
    for(new destr = 0;destr!=sizeof(missobjects);destr++) if(IsValidObject(missobjects[destr])) DestroyObject(missobjects[destr]); //init
    
	missobjects[0] = CreateObject(3043, -2366.752930, 1552.566406, 2.575065, 0.0000, 0.0000, 0.0001);
	missobjects[1] = CreateObject(2934, -2371.860596, 1547.664795, 2.569107, 0.0000, 0.0000, 90.0000);
	missobjects[2] = CreateObject(2944, -2468.340576, 1547.937744, 24.258755, 0.0000, 0.0000, 0.0000);
	missobjects[3] = CreateObject(2669, -2371.959473, 1552.692383, 2.407460, 0.0000, 0.0000, 270.0000);
	missobjects[4] = CreateObject(964, -2370.162109, 1553.284302, 1.189813, 0.0000, 0.0000, 270.0000);
	missobjects[5] = CreateObject(964, -2370.039307, 1553.276489, 2.089813, 0.0000, 0.0000, 270.0000);
	missobjects[6] = CreateObject(1271, -2371.406738, 1553.702881, 1.489813, 0.0000, 0.0000, 0.0000);
	missobjects[7] = CreateObject(1271, -2372.318359, 1553.675049, 1.521411, 0.0000, 0.0000, 0.0000);
	missobjects[8] = CreateObject(3787, -2370.984131, 1552.057007, 1.681046, 0.0000, 0.0000, 0.0000);
	missobjects[9] = CreateObject(1210, -2372.167236, 1553.666748, 1.829218, 269.7591, 0.0000, 135.0000);
	missobjects[10] = CreateObject(2953, -2372.251709, 1553.420044, 1.859514, 0.0000, 0.0000, 348.7500);
	missobjects[11] = CreateObject(2934, -2384.435791, 1539.113892, 8.348795, 0.0000, 0.8595, 90.0000);
	missobjects[12] = CreateObject(2934, -2371.851563, 1541.414063, 8.364426, 0.0000, 0.8595, 90.0000);
	missobjects[13] = CreateObject(2934, -2405.863770, 1547.750000, 8.373795, 0.0000, 0.8595, 90.0000);
	missobjects[14] = CreateObject(2934, -2398.723389, 1542.176147, 8.373795, 0.0000, 0.8595, 90.0000);
	missobjects[15] = CreateObject(2934, -2384.399658, 1551.563721, 8.373795, 0.0000, 0.8595, 90.0000);
	missobjects[16] = CreateObject(2934, -2398.719727, 1550.869995, 8.373798, 0.0000, 0.8595, 90.0000); //cont1
	missobjects[17] = CreateObject(2934, -2427.293457, 1554.655518, 5.425357, 0.0000, 0.8595, 90.0000);
	missobjects[18] = CreateObject(2934, -2427.221191, 1554.665405, 8.332952, 0.0000, 0.8595, 90.0000); //cont3
	
    SetWorldTime(12);
	SetServerRule("Mission", "Besatzung entbehrlich - Prolog");
	for(new start=0;start<MAX_PLAYERS;start++)
	{
	    if(IsPlayerNPC(start)) Kick(start);
	    if(IsPlayerConnected(start) && !IsPlayerNPC(start) && isinmission[start] == 0 && ausbildung[start] == 1)
	    {
			SetPlayerWeather(start,08);
			//GameTextForPlayer(start,"Besatzung entbehrlich",2000,1);
			//SendClientMessage(start,COLOR_GREY,"Mission : Besatzung entbehrlich - Prolog");
			//SendClientMessage(start,COLOR_GREY," ");
			//SendClientMessage(start,COLOR_GREY,"Das Paket ist auf einem Frachtschiff mitten auf dem Meer");
			//SendClientMessage(start,COLOR_GREY,"Wir landen, sichern das Paket und verlassen das Schiff wieder !");
			//TogglePlayerControllable(start,1);
	    }
	}
	ConnectNPC("miss1_anflug","miss1_anfliegen");
	return 1;
}

public ausbildungstimer(playerid)
{
	TextDrawShowForPlayer(playerid,counter);
	ausbildungstime[playerid] -= 1;
	if(ausbildungstime[playerid] <= 0)
	{
	    if(ausbildung[playerid] == 0)
	    {
		    KillTimer(ausbtimerid[playerid]);
			GameTextForPlayer(playerid,"~r~Pruefung erfolglos",3000,1);
			DestroyVehicle(ausbildungscar[playerid]);
			TextDrawHideForPlayer(playerid,counter);
			isinmission[playerid] = 0;
			play_mission(playerid);
			ausbildungstime[playerid] = 5;
		}
		if(mission == 1 && isinmission[playerid] && ausbildung[playerid] == 1)
		{
		    KillTimer(ausbtimerid[playerid]);
            TextDrawHideForPlayer(playerid,counter);
			GetPlayerPos(playerid,tempx[playerid],tempy[playerid],tempz[playerid]);
			if(tempz[playerid] < 16.103621) CreateExplosion(tempx[playerid],tempy[playerid],tempz[playerid],0,5);
		    else
		    {
		        if(miss1trigger == 0)
		        {
					miss1trigger = 1;
					for(new destr = 0;destr!=sizeof(missobjects);destr++)
					{
						if((destr < 27 && destr > 30) && IsValidObject(missobjects[destr])) DestroyObject(missobjects[destr]);
			        }
			        for(new kicknpc = 0;kicknpc<=sizeof(streamednpc);kicknpc++) if(IsPlayerNPC(kicknpc)) Kick(kicknpc);
			        ConnectNPC("miss1_abfahrt","miss1_abfahrt");
				}
				missioncp = 100;
				GameTextForPlayer(playerid,"Warte auf Evakuirung",3000,1);
	 //markme
				//heli kommt angeflogen, checkpoint wird bei landung erstellt
		    }
		    
		}
		return 0;
	}
	format(ausbtimer[playerid],128,"Zeit: ~n~%d",ausbildungstime[playerid]);
    TextDrawSetString(counter,ausbtimer[playerid]);
    ausbtimerid[playerid] = SetTimerEx("ausbildungstimer",1000,0,"i",playerid);
	return 1;
}

public spawn(playerid)
{
	return SpawnPlayer(playerid);
}

public SetPlayerRank(playerid)
{
    ResetPlayerWeapons(playerid);
 	new spawn2 = killtorank(playerid);
// 	printf("SetPlayerRank { ID:%d - Rank : %d - NPC: %d - inmiss:%d }",playerid,spawn2,IsPlayerNPC(playerid),isinmission[playerid]);
 	switch (spawn2)
 	{
 	    case 0:
 	    {
 	        SetPlayerHealth(playerid,5);
 	        SetPlayerSkin(playerid,121);
 	    }
 	    case 1:
	 	{
	 	    SetPlayerSkin(playerid,287);
	 	    SetPlayerHealth(playerid,10);
		 	Seif_GivePlayerWeapon(playerid, 6, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 24, 100000);
  		}
  		case 2:
  		{
  		    SetPlayerSkin(playerid,287);
	 	    SetPlayerHealth(playerid,15);
	 	    Seif_GivePlayerWeapon(playerid, 6, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 24, 100000);
  		}
  		case 3:
  		{
  		    SetPlayerSkin(playerid,163);
	 	    SetPlayerHealth(playerid,20);
	 	    Seif_GivePlayerWeapon(playerid, 4, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 23, 100000);
		 	Seif_GivePlayerWeapon(playerid, 33, 100000);
  		}
  		case 4:
  		{
  		    SetPlayerSkin(playerid,163);
	 	    SetPlayerHealth(playerid,25);
	 	    Seif_GivePlayerWeapon(playerid, 4, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 23, 100000);
		 	Seif_GivePlayerWeapon(playerid, 33, 100000);
  		}
  		case 5:
  		{
  		    SetPlayerSkin(playerid,166);
	 	    SetPlayerHealth(playerid,30);
	 	    Seif_GivePlayerWeapon(playerid, 8, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 25, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 23, 100000);
		 	Seif_GivePlayerWeapon(playerid, 33, 100000);
  		}
  		case 6:
  		{
  		    SetPlayerSkin(playerid,285);
	 	    SetPlayerHealth(playerid,35);
	 	    Seif_GivePlayerWeapon(playerid, 8, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 25, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 23, 100000);
		 	Seif_GivePlayerWeapon(playerid, 34, 100000);
  		}
  		case 7:
  		{
  		    SetPlayerSkin(playerid,285);
	 	    SetPlayerHealth(playerid,40);
	 	    Seif_GivePlayerWeapon(playerid, 8, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 25, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 23, 100000);
		 	Seif_GivePlayerWeapon(playerid, 34, 100000);
  		}
  		case 8:
  		{
  		    SetPlayerSkin(playerid,286);
	 	    SetPlayerHealth(playerid,45);
	 	    Seif_GivePlayerWeapon(playerid, 8, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 25, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 23, 100000);
		 	Seif_GivePlayerWeapon(playerid, 33, 100000);
  		}
  		case 9:
  		{
  		    SetPlayerSkin(playerid,286);
	 	    SetPlayerHealth(playerid,50);
	 	    Seif_GivePlayerWeapon(playerid, 9, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 27, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 23, 100000);
		 	Seif_GivePlayerWeapon(playerid, 35, 2);
  		}
  		case 10:
  		{
  		    SetPlayerSkin(playerid,165);
	 	    SetPlayerHealth(playerid,55);
	 	    Seif_GivePlayerWeapon(playerid, 9, 1);
		 	Seif_GivePlayerWeapon(playerid, 29, 100000);
		 	Seif_GivePlayerWeapon(playerid, 27, 100000);
		 	Seif_GivePlayerWeapon(playerid, 31, 100000);
		 	Seif_GivePlayerWeapon(playerid, 46, 1);
		 	Seif_GivePlayerWeapon(playerid, 23, 100000);
		 	Seif_GivePlayerWeapon(playerid, 35, 100000);
  		}
 	}
 	if(isinmission[playerid] == 0) play_mission(playerid);
	return 1;
}

dcmd_jump(playerid, params[])
{
	new Float:jx,Float:jy,Float:jz;
	GetPlayerPos(strval(params),jx,jy,jz);
	SetPlayerPos(playerid,jx,jy,jz+1);
	return 1;
}

dcmd_spec(playerid, params[])
{
	TogglePlayerSpectating(playerid,1);
	if(IsPlayerInAnyVehicle(strval(params))) PlayerSpectateVehicle(playerid,GetPlayerVehicleID(strval(params)));
	else PlayerSpectatePlayer(playerid,strval(params));
	return 1;
}

dcmd_kick(playerid, params[])
{
	if(adminlevel[playerid] == 0) {return 0; }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /kick [playerid] [Grund]");
	}
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"Kein Spieler mit angegebener ID online");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	GetPlayerName(pID,ThePlayer,sizeof(ThePlayer));
	format(string,sizeof(string),"%s (ID %d) wurde vom Server gekickt,Grund: %s",ThePlayer,pID,sGrund[0] ? sGrund : "<Kein Grund>");
	SendClientMessageToAll(COLOR_GREY,string);
	printf(string);
	Kick(pID);
	return 1;
}

dcmd_fuckup(playerid, params[])
{
    GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
    if(adminlevel[playerid] != 3) {return 0; }
    new fuplayer;
    if(sscanf(params, "d",fuplayer))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /fuckup [playerid]");
	}
	if(!IsPlayerConnected(fuplayer)) return SendClientMessage(playerid,COLOR_RED,"Spieler nicht online !");
	new fuoutput[128],Float:fux,Float:fuy,Float:fuz;
	format(fuoutput,128,"%s`s Client wurde von Admin %s gecrasht !",player_name[fuplayer],player_name[playerid]);
	SendClientMessageToAll(COLOR_GREY,fuoutput);
	printf(fuoutput);
	GetPlayerPos(fuplayer,fux,fuy,fuz);
	SetPlayerVelocity(fuplayer,fux,fuy,fuz);

	return 1;
}

dcmd_ban(playerid, params[])
{
    GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	if(adminlevel[playerid] == 0) { return 0; }
	if(adminlevel[playerid] < 2) { return SendClientMessage(playerid,COLOR_RED,"Du benötigst Adminlevel 2 !"); }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /ban [playerid] [Grund]");
	}
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"Kein Spieler mit angegebener ID online");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	GetPlayerName(pID,ThePlayer,sizeof(ThePlayer));
	format(string,sizeof(string),"%s (ID %d) wurde vom Server gebannt,Grund: %s",ThePlayer,pID,sGrund[0] ? sGrund : "<Kein Grund>");
	SendClientMessageToAll(COLOR_GREY,string);
	BanEx(pID,sGrund);
	new name[46];
	GetPlayerName(playerid,name,46);
	printf("Admin %s : %s",name,string);
	return 1;
}

dcmd_vote(playerid,params[])
{
	#pragma unused playerid
	#pragma unused params
	if(vote == 0) { return 0; }
	if(voted[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"Du hast bereits gewählt");
	votes = votes + 1;
	voted[playerid] = 1;
    new name[46];
	GetPlayerName(playerid,name,46);
	printf("%s hat für einen Kick gestimmt",name,params);
	return 1;
}

dcmd_votekick(playerid, params[])
{
    GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	for(new a; a<MAX_PLAYERS; a++)
	{
	    if(IsPlayerConnected(a) && adminlevel[a] >= 1) { return SendClientMessage(playerid,COLOR_RED,"Admins sind online, frag diese bitte !"); }
	}
	if(vote == 1) { return SendClientMessage(playerid,COLOR_GREY,"Es läuft noch ein Voting !"); }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /votekick [playerid] [Grund]");
	}
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"Kein Spieler mit angegebener ID online");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	GetPlayerName(pID,ThePlayer,sizeof(ThePlayer));
	format(string,sizeof(string),"Votekick gegen %s (ID %d) aus dem Grund: %s",ThePlayer,pID,sGrund[0] ? sGrund : "<Kein Grund>");
	SendClientMessageToAll(COLOR_GREY,string);
	SendClientMessageToAll(COLOR_GREY,"Tippe /vote um ihn rauszuschmeißen !");
	vote = 1;
	votes = 0;
	SetTimerEx("voteoff",30000,0,"i",pID);
	new name[46],name2[46];
	GetPlayerName(playerid,name,46);
	GetPlayerName(pID,name2,46);
	printf("%s hat einen Votekick für Spieler %s gestartet ; Grund : %s",name,name2,sGrund);
	return 1;
}

public voteoff(playerid)
{
    GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	new maxplayers = 0;
    for(new vid; vid<MAX_PLAYERS; vid++)
    {
		if(IsPlayerConnected(vid) && !IsPlayerNPC(playerid))
		{
			maxplayers = maxplayers + 1;
			voted[vid] = 0;
			
		}
    }
    if(votes > maxplayers/2)
    {
        new
			ThePlayer[MAX_PLAYER_NAME],
		    string[128];
		GetPlayerName(playerid,ThePlayer,sizeof(ThePlayer));
		format(string,sizeof(string),"%s (ID %d) wurde vom Server gewählt !",ThePlayer,playerid);
		SendClientMessageToAll(COLOR_GREY,string);
		Kick(playerid);
		printf(string);
    }
    if(votes <= maxplayers)
    {
        SendClientMessageToAll(COLOR_GREY,"Nicht genügend Stimmen zum Votekick !");
        printf("Nicht genügend Stimmen zum Votekick");
    }
    votes = 0;
    vote = 0;
    return 1;
}

dcmd_spawn(playerid, params[])
{
	if(adminlevel[playerid] == 0) { return 0; }
	new Float:vx,Float:vy,Float:vz,car;
	GetPlayerPos(playerid,vx,vy,vz);
	car = CreateVehicle(strval(params),vx,vy,vz+2,0,0,0,1);
	PutPlayerInVehicle(playerid,car,0);
	new name[46];
	GetPlayerName(playerid,name,46);
	printf("Admin %s hat sich Vehikel Nr.%s geholt",name,params);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid,1);
	TogglePlayerSpectating(playerid,0);
	return 1;
}

dcmd_waffe(playerid, params[])
{
	if(adminlevel[playerid] == 0) { return 0; }
	Seif_GivePlayerWeapon(playerid,strval(params),500);
	new name[46];
	GetPlayerName(playerid,name,46);
	printf("Admin %s hat sich Waffe Nr.%s geholt",name,params);
	return 1;
}

public npc_miss1_anflug(npc)
{
	new Float:npcx,Float:npcy,Float:npcz;
	GetPlayerPos(npc,npcx,npcy,npcz);
	if(IsPlayerInRangeOfPoint(npc,5,-2316.7119,1546.2045,18.7734)) //markme
	{
	    for(new set=0;set<MAX_PLAYERS;set++)
	    {
	        if(GetPlayerState(set) == 9 && !IsPlayerNPC(set) && ausbildung[set] == 1 && isinmission[set] == 1)
	        {
	            TogglePlayerSpectating(set,0);
	            PlayerSpectatePlayer(set,set);
	            SetCameraBehindPlayer(set);
	            TogglePlayerControllable(set,1);
	            SetPlayerPos(set,-2316.5801,1550.4526,18.7734);
	            SetPlayerCheckpoint(set,-2337.2891,1533.7601,20.2344,2);
	            SetPlayerWorldBounds(set,-2263.0823,-2552.1814,1629.4528,1493.5063);
	        }
	    }
	
	}
	else SetTimerEx("npc_miss1_anflug",2000,0,"i",npc);
	return 1;
}

public npc_miss1_abflug(npc)
{
	new Float:npcx,Float:npcy,Float:npcz;
	GetPlayerPos(npc,npcx,npcy,npcz);
	if(IsPlayerInRangeOfPoint(npc,10,-2450.3015,1533.1659,28.9464))
	{
	    for(new set=0;set<MAX_PLAYERS;set++)
	    {
	        if(!IsPlayerNPC(set) && ausbildung[set] == 1 && isinmission[set] == 1)
	        {
	            SetPlayerCheckpoint(set,-2450.3015,1533.1659,28.9464,7);
	        }
	    }

	}
    else SetTimerEx("npc_miss1_abflug",2000,0,"i",npc);
	return 1;
}

Float:GetDistanceBetweenPlayers(p1,p2)
{
	new Float:x1,Float:y1,Float:z1,Float:x3,Float:y3,Float:z3;
	if (!IsPlayerConnected(p1) || !IsPlayerConnected(p2))
	{
		return -1.00;
	}
	GetPlayerPos(p1,x1,y1,z1);
	GetPlayerPos(p2,x3,y3,z3);
	return floatsqroot(floatpower(floatabs(floatsub(x3,x1)),2)+floatpower(floatabs(floatsub(y3,y1)),2)+floatpower(floatabs(floatsub(z3,z1)),2));
}

public Del_Kick(playerid)
{
	return Kick(playerid);
}

Float:getwepdistance(playerid)
{
	if(GetPlayerWeapon(playerid) < 10) return 1.0;
	else return 1000.0;
	/*
	switch(GetPlayerWeapon(playerid))
	{
		case 0: return 1.0;
		case 4: return 1.0;
        case 6: return 1.0;
        case 8: return 1.0;
        case 9: return 1.0;
        case 29: return 30.0;
        case 25: return 18.0;
        case 31: return 30.0;
        case 23: return 18.0;
        case 46: return 1.0;
        case 33: return 100.0;
        case 34: return 100.0;
        case 27: return 20.0;
        case 35: return 100.0;
	}
	*/
}

public Del_Spec(playerid,targetid)
{
    TogglePlayerSpectating(playerid,1);
	if(IsPlayerInAnyVehicle(targetid)) PlayerSpectateVehicle(playerid,GetPlayerVehicleID(targetid));
	else PlayerSpectatePlayer(playerid,targetid);
	if(mission == 1)
	{
	    clearchat(playerid);
        GameTextForPlayer(playerid,"Besatzung entbehrlich - Prolog",2000,1);
		SendClientMessage(playerid,COLOR_GREY,"Mission : Besatzung entbehrlich - Prolog");
		SendClientMessage(playerid,COLOR_GREY," ");
		SendClientMessage(playerid,COLOR_GREY,"Das Paket ist auf einem Frachtschiff mitten auf dem Meer");
		SendClientMessage(playerid,COLOR_GREY,"Wir landen, sichern das Paket und verlassen das Schiff wieder !");
		TogglePlayerControllable(playerid,1);
	}
	return 1;
}
