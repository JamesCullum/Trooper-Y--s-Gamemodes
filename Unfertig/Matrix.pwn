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
#include <stocks>

#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_ORANGE 0xFF9900FF
#define COLOR_BLUE 0x0000FF00
/*dialog ids
1&2 = login & register
3=Skin speichern ?
4 = Levelupgrade
*/


new loggedin[MAX_PLAYERS],player_name[MAX_PLAYERS],adminlevel[MAX_PLAYERS],muted[MAX_PLAYERS],vote,votes,level[MAX_PLAYERS],skin[MAX_PLAYERS];
new exp[MAX_PLAYERS],Text:BoxOben,Text:BoxUnten,pickups[50],keyrequest[MAX_PLAYERS];
new laufbahn1[MAX_PLAYERS],laufbahn2[MAX_PLAYERS],bots[40][MAX_PLAYERS],Text:Blackout,requirelevel[100],Text:fokusbar[MAX_PLAYERS],Text:expbalken[MAX_PLAYERS];
new health[MAX_PLAYERS],attacke[MAX_PLAYERS],verteidigung[MAX_PLAYERS],fokus[MAX_PLAYERS],tfokus[MAX_PLAYERS]; //skills
new checkpointschecked[100][MAX_PLAYERS],npcrufer = -1;

forward DisappearPickup(pickupid);
forward voteoff(playerid);
forward KickID(playerid);
forward ClearChat(playerid);
forward Timed_Msg(playerid,param1,param2);
forward GiveExp(playerid,Erfahrung);
forward Mission(playerid,missionsid);
forward keyreq(playerid);
forward botcatchplayer(playerid,param);
forward OnBotConnect(playerid);
forward failmiss(playerid,param);

main()
{
	print("------ Matrix Online Zeta 0.1 loaded------");
	SetWeather(43);
 	Blackout = TextDrawCreate(1.000000,1.000000,":");
	TextDrawUseBox(Blackout,1);
	TextDrawBoxColor(Blackout,0x000000FF);
	TextDrawTextSize(Blackout,641.000000,10.000000);
	TextDrawAlignment(Blackout,0);
	TextDrawBackgroundColor(Blackout,0x00000000);
	TextDrawFont(Blackout,3);
	TextDrawLetterSize(Blackout,1.000000,51.000000);
	TextDrawColor(Blackout,0x000000AA);
	TextDrawSetOutline(Blackout,1);
	TextDrawSetProportional(Blackout,1);
	TextDrawSetShadow(Blackout,1);
	
	BoxOben = TextDrawCreate(645.000000,101.000000,"___");
	BoxUnten = TextDrawCreate(1.000000,328.000000,"____");
	TextDrawUseBox(BoxOben,1);
	TextDrawBoxColor(BoxOben,0x000000ff);
	TextDrawTextSize(BoxOben,-260.000000,17.000000);
	TextDrawUseBox(BoxUnten,1);
	TextDrawBoxColor(BoxUnten,0x000000ff);
	TextDrawTextSize(BoxUnten,680.000000,0.000000);
	TextDrawAlignment(BoxOben,0);
	TextDrawAlignment(BoxUnten,0);
	TextDrawBackgroundColor(BoxOben,0x000000ff);
	TextDrawBackgroundColor(BoxUnten,0x000000ff);
	TextDrawFont(BoxOben,3);
	TextDrawLetterSize(BoxOben,1.000000,-14.000000);
	TextDrawFont(BoxUnten,3);
	TextDrawLetterSize(BoxUnten,1.000000,20.000000);
	TextDrawColor(BoxOben,0xffffffff);
	TextDrawColor(BoxUnten,0xffffffff);
	TextDrawSetOutline(BoxOben,1);
	TextDrawSetOutline(BoxUnten,1);
	TextDrawSetShadow(BoxOben,1);
	TextDrawSetShadow(BoxUnten,1);
	
	//pickups
	pickups[0] = AddStaticPickup(1273,23,246.5630,108.8160,1003.2188);
	
	SetGameModeText("Matrix - Online");
	AddPlayerClass(123, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //freemind
	AddPlayerClass(104, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(47, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(115, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(143, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(169, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(185, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(242, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(192, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //" (frau)
/*
	AddPlayerClass(33, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //agent
	AddPlayerClass(163, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(165, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
	AddPlayerClass(234, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); //"
*/
}

public OnGameModeInit()
{
    for(new leveldefine=1;leveldefine<=sizeof(requirelevel);leveldefine++) requirelevel[leveldefine] = leveldefine * 1500; //level 1 braucht 1500 exp, 2 = 3000 and so on
	for(new playerid=0;playerid<=MAX_PLAYERS;playerid++)
	{
	    fokusbar[playerid] = TextDrawCreate(498, 112, "");
		TextDrawAlignment(fokusbar[playerid], 1);
		TextDrawFont(fokusbar[playerid], 0);
		TextDrawLetterSize(fokusbar[playerid], 0.1, 0.1);
		TextDrawColor(fokusbar[playerid], 0xFFFF00FF);
		TextDrawUseBox(fokusbar[playerid], 1);
		TextDrawTextSize(fokusbar[playerid],0.1, 0.1);

		expbalken[playerid] = TextDrawCreate(208, 457, "");
		TextDrawAlignment(expbalken[playerid], 1);
		TextDrawFont(expbalken[playerid], 0);
		TextDrawLetterSize(expbalken[playerid], 0.1, 0.1);
		TextDrawColor(expbalken[playerid], 0x000000FF);
		TextDrawUseBox(expbalken[playerid], 1);
		TextDrawTextSize(expbalken[playerid],0.1, 0.1);
	}
	return 1;
}

public failmiss(playerid,param)
{
	ClearChat(playerid);
    GameTextForPlayer(playerid,"~rMission fehlgeschlagen",3000,0);
	switch(param)
	{
		case 1:
		{
		    SendClientMessage(playerid,COLOR_RED,"Du wurdest gesehen");
		    for(new botkick=0;botkick<7;botkick++)
			{
			    if(bots[botkick][playerid] != -1 && IsPlayerConnected(bots[botkick][playerid]))
			    {
				    GetPlayerName(bots[botkick][playerid],player_name[bots[botkick][playerid]],MAX_PLAYER_NAME);
					if(!strcmp(player_name[bots[botkick][playerid]],"miss1_walking1") || !strcmp(player_name[bots[botkick][playerid]],"miss1_walking2") || !strcmp(player_name[bots[botkick][playerid]],"miss1_walking3") || !strcmp(player_name[bots[botkick][playerid]],"miss1_walking4")
					 || !strcmp(player_name[bots[botkick][playerid]],"idle1_miss1") || !strcmp(player_name[bots[botkick][playerid]],"idle2_miss1") || !strcmp(player_name[bots[botkick][playerid]],"idle3_miss1") || !strcmp(player_name[bots[botkick][playerid]],"miss1_agent"))
					{
						Kick(bots[botkick][playerid]);
					}
				}

			}
		    ClearAnimations(playerid);
		    checkpointschecked[0][playerid] = -1;
            ForceClassSelection(playerid);
	    	SetPlayerHealth(playerid,0);
		}


	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	//sektion variabeln
	loggedin[playerid] = 0,adminlevel[playerid] = 0,laufbahn1[playerid] = 0,laufbahn2[playerid] = 0,muted[playerid] = 0,level[playerid] = 0;
	skin[playerid] = -1,exp[playerid] = 0,health[playerid] = 5,attacke[playerid] = 2,verteidigung[playerid] = 2,fokus[playerid] = 0,tfokus[playerid] = 0;
	keyrequest[playerid] = 0;
	for(new wipe=0;wipe<=10;wipe++) checkpointschecked[wipe][playerid] = 1;
	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	if(IsPlayerNPC(playerid))
	{
	    OnBotConnect(playerid);
	    return 1;
	}
	//effekte
	if(INI_Open("Users.ini"))
	{
    	new password[128];
		if (INI_ReadString(password, player_name[playerid], MAX_PLAYER_NAME)) // wenn string gefunden
		{
			ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Willkommen zurück","Wie ich sehe, hast du keine Angst vor der Wahrheit !\n Es wird Zeit für eine neue Lektion !\n\n Verrate mir dein geheimes Passwort :","Absenden","Verlassen");
		}
		else { ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen in der Matrix!\n Bist du mutig genug, der Wahrheit ins Auge zu blicken ?\n\n Wählst du die rote Pille, führe ich dich in die tiefsten Tiefen des Kaninchenbaus,\n wählst du die Blaue, ist alles vorbei.\n Wenn du die rote Pille wählst, brauchst du ein geheimes Passwort.","Rote Pille","Blaue Pille"); }
		INI_Close();
	}
	//join-message
	new output1[128];
	format(output1,sizeof(output1),"%s hat den Server betreten",player_name[playerid]);
    SendClientMessageToAll(COLOR_GREY,output1);
    
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    TextDrawHideForPlayer(playerid,Blackout);
    TextDrawHideForPlayer(playerid,fokusbar[playerid]);
    TextDrawHideForPlayer(playerid,expbalken[playerid]);
    
    if(IsPlayerNPC(playerid)) return 1;
    
	for(new wipe=0;wipe<=40;wipe++)
	{
	    GetPlayerName(bots[wipe][playerid],player_name[bots[wipe][playerid]],MAX_PLAYER_NAME);
		if(!strcmp(player_name[bots[wipe][playerid]],"miss1_walking1") || !strcmp(player_name[bots[wipe][playerid]],"miss1_walking2") || !strcmp(player_name[bots[wipe][playerid]],"miss1_walking3") || !strcmp(player_name[bots[wipe][playerid]],"miss1_walking4")
		|| !strcmp(player_name[bots[wipe][playerid]],"idle1_miss1") || !strcmp(player_name[bots[wipe][playerid]],"idle2_miss1") || !strcmp(player_name[bots[wipe][playerid]],"idle3_miss1") || !strcmp(player_name[bots[wipe][playerid]],"miss1_agent"))
		{
			Kick(bots[wipe][playerid]);
		}
	}
	if(npcrufer == playerid) npcrufer = -1;
    new output2[128];
	switch(reason)
	{
    	case 0:format(output2,sizeof(output2),"%s hat den Server verlassen (Timeout)",player_name[playerid]);
		case 1:format(output2,sizeof(output2),"%s hat den Server verlassen ",player_name[playerid]);
		case 2:format(output2,sizeof(output2),"%s hat den Server verlassen (Kick/Ban)",player_name[playerid]);
	}
    SendClientMessageToAll(COLOR_GREY,output2);
	return 1;
}

public OnGameModeExit()
{
    TextDrawDestroy(Blackout);
    for(new playerid=0;playerid<=MAX_PLAYERS;playerid++)
    {
        TextDrawDestroy(fokusbar[playerid]);
        TextDrawDestroy(expbalken[playerid]);
    }
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid,973.2206,8.1626,1001.1484);
	SetPlayerInterior(playerid,3);
	SetPlayerFacingAngle(playerid, 182.2034);
	SetPlayerCameraPos(playerid,972.7090,-2.7833,1001.1484);
	SetPlayerCameraLookAt(playerid,973.2206,8.1626,1001.1484);
	if(skin[playerid] != 1) SpawnPlayer(playerid);
	return 1;
}

public OnBotConnect(playerid)
{
	if(npcrufer == -1)
	{
		Kick(playerid);
        return printf("%s wurde von anonym gespawnt. Bug !",player_name[playerid]);
	}
	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	//miss1
	if(!strcmp(player_name[playerid],"miss1_walking1")) bots[0][npcrufer] = playerid;
	if(!strcmp(player_name[playerid],"miss1_walking2")) bots[1][npcrufer] = playerid;
    if(!strcmp(player_name[playerid],"miss1_walking3")) bots[2][npcrufer] = playerid;
    if(!strcmp(player_name[playerid],"miss1_walking4")) bots[3][npcrufer] = playerid;
    if(!strcmp(player_name[playerid],"idle1_miss1")) bots[4][npcrufer] = playerid;
    if(!strcmp(player_name[playerid],"idle2_miss1")) bots[5][npcrufer] = playerid;
    if(!strcmp(player_name[playerid],"idle3_miss1")) bots[6][npcrufer] = playerid;
    if(!strcmp(player_name[playerid],"miss1_agent")) bots[7][npcrufer] = playerid;

	if(bots[0][npcrufer] == playerid || bots[1][npcrufer] == playerid || bots[2][npcrufer] == playerid || bots[3][npcrufer] == playerid || bots[4][npcrufer] == playerid || bots[5][npcrufer] == playerid || bots[6][npcrufer] == playerid)
	{
		SetPlayerSkin(playerid,281);
	}
	if(bots[4][npcrufer] == playerid)
	{
		SetPlayerPos(playerid,253.7956,117.5233,1003.2188);
		SetPlayerFacingAngle(playerid,90.0162);
	}
	if(bots[5][npcrufer] == playerid)
	{
		SetPlayerPos(playerid,266.7434,114.0906,1008.8130);
		SetPlayerFacingAngle(playerid,356.3523);
	}
	if(bots[6][npcrufer] == playerid)
	{
		SetPlayerPos(playerid,259.6378,114.4199,1004.4822);
		SetPlayerFacingAngle(playerid,266.7849);
	}
	if(bots[7][npcrufer] == playerid)
	{
		SetPlayerSkin(playerid,165);
	}
    
	return 1;
}

public ClearChat(playerid)
{
    for(new clear=0;clear<=10;clear++) SendClientMessage(playerid,COLOR_GREY," ");
	return 1;
}

public Timed_Msg(playerid,param1,param2)
{
	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
    new formatmsg[128];
	switch(param2)
	{
	    case 1:format(formatmsg,128,"***Telefon klingelt***");
	    case 2:format(formatmsg,128,"%s : Hallo ?",player_name[playerid]);
		case 3:format(formatmsg,128,"Hallo %s. Weißt du, wer hier ist ?",player_name[playerid]);
		case 4:format(formatmsg,128,"%s : Morpheus !",player_name[playerid]);
		case 5:format(formatmsg,128,"Ja. Ich habe nach dir gesucht, %s.",player_name[playerid]);
		case 6:format(formatmsg,128,"Ich weiß nicht, ob du bereit bist für das, was ich dir zeigen will.");
		case 7:format(formatmsg,128,"Leider haben wir grade wenig Zeit. Sie kommen, und ich weiß nicht, was sie wollen.");
		case 8:format(formatmsg,128,"%s : Wer kommt ?",player_name[playerid]);
		case 9:format(formatmsg,128,"Schau zur Türe !!!");
		case 10:format(formatmsg,128,"%s : Was wollen die von mir ?",player_name[playerid]);
		case 11:format(formatmsg,128,"Ich weiß es nicht. Und wenn du es nicht herausfinden willst,");
		case 12:format(formatmsg,128,"schlage ich vor, du verschwindest.");
	}
	switch(param2)
	{
	    case 1:SetTimerEx("Timed_Msg",5000,0,"iii",playerid,0,param2+1);
	    case 2:SetTimerEx("Timed_Msg",5000,0,"iii",playerid,2,param2+1);
	    case 3:SetTimerEx("Timed_Msg",5000,0,"iii",playerid,0,param2+1);
	    case 4:SetTimerEx("Timed_Msg",5000,0,"iii",playerid,2,param2+1);
	    case 5:SetTimerEx("Timed_Msg",5000,0,"iii",playerid,0,param2+1);
	    case 6:SetTimerEx("Timed_Msg",5000,0,"iii",playerid,0,param2+1);
	    case 7:SetTimerEx("Timed_Msg",5000,0,"iii",playerid,0,param2+1);
	    case 8:SetTimerEx("Timed_Msg",6000,0,"iii",playerid,3,param2+1);
	    case 9:SetTimerEx("Timed_Msg",2000,0,"iii",playerid,0,param2+1);
	    case 10:SetTimerEx("Timed_Msg",2000,0,"iii",playerid,2,param2+1);
	    case 11:SetTimerEx("Timed_Msg",1500,0,"iii",playerid,4,param2+1);
	    //12 wird ausgelassen
	}
	ClearChat(playerid);
	SendClientMessage(playerid,COLOR_ORANGE,formatmsg);
	SendClientMessage(playerid,COLOR_ORANGE," ");
	SendClientMessage(playerid,COLOR_ORANGE," ");
	SendClientMessage(playerid,COLOR_ORANGE," "); //die hier, damit das in den bereich der schwarzen balken rutscht
	switch(param1) //um auch custom aktionen auszuführen
	{
//      case 0: hier kommt garnix hin, 0 ist sozusagen default
	    case 1: ApplyAnimation(playerid,"ped","phone_in",4,0,0,0,1,0);
	    case 2: ApplyAnimation(playerid,"ped","phone_talk",4,1,0,0,1,0);
		case 3: ConnectNPC("miss1_agent","miss1_agent");
		case 4:
		{
		    SetTimerEx("botcatchplayer",1000,0,"ii",playerid,1);
		    TextDrawHideForPlayer(playerid,BoxOben);
		    TextDrawHideForPlayer(playerid,BoxUnten);
		    ApplyAnimation(playerid,"ped","phone_out",4,0,0,0,0,0);
			GameTextForPlayer(playerid,"Duck dich",500,1);
			keyrequest[playerid] = KEY_CROUCH,checkpointschecked[0][playerid] = 0,npcrufer = -1;
		}
	}
	return 1;
}

public botcatchplayer(playerid,param)
{
	new Float:checkx,Float:checky,Float:checkz;
	GetPlayerPos(playerid,checkx,checky,checkz);
	switch(param)
	{
		case 1:
		{
		    if(IsPlayerInRangeOfPoint(playerid,5,239.3377,117.3594,1003.2188)) return failmiss(playerid,1);
		}
	}
	SetTimerEx("botcatchplayer",1000,0,"ii",playerid,param);
	return 1;
}

public keyreq(playerid)
{
	switch(keyrequest[playerid])
	{
		case KEY_CROUCH:
		{
		    if(laufbahn1[playerid] == 0 && checkpointschecked[0][playerid] == 0)
		    {
		        keyrequest[playerid] = 0,checkpointschecked[0][playerid] = 1;
		        SetPlayerCheckpoint(playerid,214.1714,111.2409,1003.2188,1);
		        return GameTextForPlayer(playerid,"Versteck dich hinter der Box",1000,1);
		    }
		}

	}
	return 1;
}

public Mission(playerid,missionsid)
{
	switch(missionsid)
	{
		case 1:
		{
		    SetPlayerInterior(playerid,10);
		    SetPlayerPos(playerid,218.3792,111.3305,1003.2188);
		    SetPlayerFacingAngle(playerid,350);
			TextDrawShowForPlayer(playerid,BoxOben);
			TextDrawShowForPlayer(playerid,BoxUnten);
			ClearChat(playerid);
			ApplyAnimation(playerid,"INT_OFFICE","OFF_Sit_Type_Loop",4,1,0,0,1,0);
			if(npcrufer != -1) while(npcrufer != 1) GameTextForPlayer(playerid,"Warte kurz....",3000,1);

       		SetTimerEx("Timed_Msg",5000,0,"iii",playerid,1,1); //erstes = aktion, zweites = nachricht
       		
       		npcrufer = playerid;
       		new found = 0;
       		for(new checkif=0;checkif<=MAX_PLAYERS;checkif++)
       		{
       		    if(IsPlayerConnected(checkif))
       		    {
       		        GetPlayerName(checkif,player_name[checkif],MAX_PLAYER_NAME);
       		    	if(!strcmp(player_name[checkif],"miss1_walking3"))
       		    	{
       		    	    found = 1;
       		    	    break;
       		    	}
       		    }
       		}
       		if(found == 0)
       		{
			    ConnectNPC("miss1_walking1","miss1_walking1");
			    ConnectNPC("miss1_walking2","miss1_walking2");
			    ConnectNPC("miss1_walking3","miss1_walking3");
			    ConnectNPC("miss1_walking4","miss1_walking4");
			    ConnectNPC("idle1_miss1","npcidle");
			    ConnectNPC("idle2_miss1","npcidle");
			    ConnectNPC("idle3_miss1","npcidle");
   }
		    //weitere aktionen unter TimedMsg ;)
		    
		    return 1;
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
    if(skin[playerid] != -1) SetPlayerSkin(playerid,skin[playerid]);
    SetPlayerHealth(playerid,health[playerid]);
    
	if(loggedin[playerid] == 0)
	{
	    ForceClassSelection(playerid);
	    SetPlayerHealth(playerid,0);
	}
	if(laufbahn1[playerid] == 0 && skin[playerid] == -1)
	{
	    TogglePlayerControllable(playerid,0);
	    ShowPlayerDialog(playerid,3,DIALOG_STYLE_MSGBOX,"Dein Aussehen","Soll dies dauerhaft dein Charakter sein ?","Ja","Nein");
	}
	else if(laufbahn1[playerid] == 0 && skin[playerid] != -1)
	{
		Mission(playerid,1);
	}
	return 1;
}

public KickID(playerid)
{
	Kick(playerid);
	return print("Kicked-ID");
}

public OnPlayerRequestSpawn(playerid)
{
	if(skin[playerid] != -1 && laufbahn1[playerid] != 0) SetPlayerInterior(playerid,0);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	//befehle
	dcmd(fuckup,6,cmdtext);
	dcmd(mute,4,cmdtext);
	dcmd(unmute,6,cmdtext);
	dcmd(kick,4,cmdtext);
	dcmd(ban,3,cmdtext);
	dcmd(vtw,3,cmdtext);
	dcmd(unvtw,6,cmdtext);
	dcmd(bug,3,cmdtext);
	//textbefehle
 	if(muted[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"Du bist gemuted !");
 	dcmd(report,6,cmdtext);
 	dcmd(votekick,8,cmdtext);
 	dcmd(vote,4,cmdtext);
 	
	return 0;
}

dcmd_bug(playerid,params[])
{
	#pragma unused params
	if(adminlevel[playerid] != 3) return 0;
	TogglePlayerControllable(playerid,1);
	ClearAnimations(playerid);
	return 1;
}

dcmd_ban(playerid, params[])
{
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
	Kick(pID);
	return 1;
}

dcmd_vtw(playerid, params[])
{
	if(adminlevel[playerid] < 2) { return SendClientMessage(playerid,COLOR_RED,"Du benötigst Adminlevel 2 !"); }
	if(!params[0]) { return SendClientMessage(playerid,COLOR_RED,"Syntax: /vtw [playerid]"); }
 	if(!IsPlayerConnected(params[0])) { return SendClientMessage(playerid,COLOR_RED,"ID nicht online"); }
 	if(!IsPlayerInAnyVehicle(params[0])) { SetPlayerVirtualWorld(params[0],5); }
 	new veh = GetPlayerVehicleID(params[0]);
 	if(IsPlayerInAnyVehicle(params[0])) { SetVehicleVirtualWorld(veh,5); }
 	SendClientMessage(playerid,COLOR_GREY,"Spieler in Welt 5 geschickt !");
 	return 1;
}

dcmd_vote(playerid,params[])
{
	#pragma unused playerid
	#pragma unused params
	if(vote == 0) { return 0; }
	votes = votes + 1;
	return 1;
}

dcmd_unvtw(playerid, params[])
{
	if(adminlevel[playerid] < 2) { return SendClientMessage(playerid,COLOR_RED,"Du benötigst Adminlevel 2 !"); }
 	if(!params[0]) { return SendClientMessage(playerid,COLOR_RED,"Syntax: /unvtw [playerid]"); }
 	if(!IsPlayerConnected(params[0])) { return SendClientMessage(playerid,COLOR_RED,"ID nicht online"); }
 	if(!IsPlayerInAnyVehicle(params[0])) { SetPlayerVirtualWorld(params[0],0); }
 	new veh = GetPlayerVehicleID(params[0]);
 	if(IsPlayerInAnyVehicle(params[0])) { SetVehicleVirtualWorld(veh,0); }
 	SendClientMessage(playerid,COLOR_GREY,"Spieler zurückgeholt !");
 	return 1;
}

public voteoff(playerid)
{
	if(!IsPlayerConnected(playerid))
	{
	        votes = 0;
   	 		vote = 0;
   	 		return SendClientMessageToAll(COLOR_RED,"Der Spieler, der gekickt werden sollte, ist schon freiwillig gegangen !");
	}
	new maxplayers = 0;
    for(new vid; vid<MAX_PLAYERS; vid++)
    {
		if(IsPlayerConnected(vid)) { maxplayers = maxplayers + 1; }
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
    }
    if(votes <= maxplayers)
    {
        SendClientMessageToAll(COLOR_GREY,"Nicht genügend Stimmen zum Votekick !");
    }
    votes = 0;
    vote = 0;
    return 1;
}

dcmd_votekick(playerid, params[])
{
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
	return 1;
}

dcmd_report(playerid, params[])
{
	if(muted[playerid] == 1) { return SendClientMessage(playerid,COLOR_RED,"Du bist gemuted !"); }
	new reportoutput[128];
	format(reportoutput,sizeof(reportoutput),"Spieler %s hat reportet: %s",player_name[playerid],params);
	new reportfound = 0;
	for(new rid; rid<MAX_PLAYERS; rid++)
	{
	    if(IsPlayerConnected(rid) && adminlevel[rid] != 0)
	    {
		 	reportfound = 1;
	        SendClientMessage(rid,COLOR_RED,reportoutput);
	    }
	}
	if(reportfound == 0) { return SendClientMessage(playerid,COLOR_RED,"Keine Admins online !"); }
	SendClientMessage(playerid,COLOR_GREEN,"Report gesendet");
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
	Kick(pID);
	return 1;
}

dcmd_unmute(playerid, params[])
{
	if(adminlevel[playerid] == 0) {return 0; }
	new
		pID;
	if(sscanf(params, "d",pID))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /unmute [playerid]");
	}
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"Kein Spieler mit angegebener ID online");
	}
	if(muted[pID] == 0) return SendClientMessage(playerid,COLOR_RED,"Spieler wurde nicht gemutet");
	SendClientMessage(pID,COLOR_GREEN,"Du bist nicht mehr gemutet");
	muted[pID] = 0;
	return 1;
}

dcmd_fuckup(playerid, params[])
{
    if(adminlevel[playerid] == 0) {return 0; }
    new fuplayer;
    if(sscanf(params, "d",fuplayer))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /fuckup [playerid]");
	}
	if(!IsPlayerConnected(fuplayer)) return SendClientMessage(playerid,COLOR_RED,"Spieler nicht online !");
	new fuoutput[128],Float:fux,Float:fuy,Float:fuz;
	format(fuoutput,128,"%s`s Client wurde von Admin %s gecrasht !",player_name[fuplayer],player_name[playerid]);
	SendClientMessageToAll(COLOR_GREY,fuoutput);
	GetPlayerPos(fuplayer,fux,fuy,fuz);
	SetPlayerVelocity(fuplayer,fux,fuy,fuz);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	DisablePlayerCheckpoint(playerid);

	return 1;
}

public GiveExp(playerid,Erfahrung)
{
	if(INI_Open("Users.ini"))
	{
	    new tmpoutput2[128];
	    exp[playerid] += Erfahrung;
	    format(tmpoutput2,128,"%sexp",player_name[playerid]);
	    INI_WriteInt(tmpoutput2,exp[playerid]);
		format(tmpoutput2,128,"Erfahrung: %d/%d",exp[playerid],requirelevel[level[playerid]]);
		TextDrawSetString(expbalken[playerid],tmpoutput2);
		if(exp[playerid] >= requirelevel[level[playerid]]) //also wenn die erfahrung >= die benötigte Erfahrung des aktuellen levels
		{
            exp[playerid] -= requirelevel[level[playerid]];
		    level[playerid] += 1;
		    format(tmpoutput2,128,"%sexp",player_name[playerid]);
	   	 	INI_WriteInt(tmpoutput2,exp[playerid]);
	   	 	
		    format(tmpoutput2,128,"Erfahrung: %d/%d",exp[playerid],requirelevel[level[playerid]]);
			TextDrawSetString(expbalken[playerid],tmpoutput2);
			GameTextForPlayer(playerid,"+ Level",2000,3);
		    format(tmpoutput2,128,"%slevel",player_name[playerid]);
		    INI_WriteInt(tmpoutput2,level[playerid]);
		    ShowPlayerDialog(playerid,4,DIALOG_STYLE_LIST,"Skillpunkt setzen","Leben\nAngriff\nVerteidigung\nFokus","Upgrade","Upgrade");
		}
  		INI_Save();
	    INI_Close();
	}
	return 1;
}

dcmd_mute(playerid, params[])
{
	if(adminlevel[playerid] == 0) {return 0; }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /mute [playerid] [Grund]");
	}
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"Kein Spieler mit angegebener ID online");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	format(string,sizeof(string),"Du wurdest gemutet, Grund: %s",ThePlayer,pID,sGrund[0] ? sGrund : "<Kein Grund>");
	SendClientMessage(pID,COLOR_RED,string);
	muted[pID] = 1;
	return 1;
}

public DisappearPickup(pickupid)
{
	DestroyPickup(pickupid);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
/*
	new output[128];
	format(output,128,"newkeys:%d",newkeys);
	SendClientMessage(playerid,0xAFAFAFAA,output);
*/
	if(keyrequest[playerid] != 0)
	{
	    if(newkeys & keyrequest[playerid] || newkeys == keyrequest[playerid]) keyreq(playerid);
	}
	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
    if(!response && (dialogid == 1 || dialogid == 2))
	{
	    for(new clear=0;clear<10;clear++) SendClientMessage(playerid,COLOR_GREY," ");
	    SendClientMessage(playerid,COLOR_GREY,"Es scheint, als habe ich mich in dir getäuscht...");
		return Kick(playerid);
	}
    switch(dialogid)
    {
        case 1:
        {
            if(!strlen(inputtext)) { ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen in der Matrix!\n Bist du mutig genug, der Wahrheit ins Auge zu blicken ?\n\n Wählst du die rote Pille, führe ich dich in die tiefsten Tiefen des Kaninchenbaus,\n wählst du die Blaue, ist alles vorbei.\n Wenn du die rote Pille wählst, brauchst du ein geheimes Passwort.","Rote Pille","Blaue Pille"); }
            if(INI_Open("Users.ini"))
            {
				INI_WriteString(player_name[playerid], inputtext);
				new tmpoutput[128];
				format(tmpoutput,128,"%sadminlevel",player_name[playerid]);
				INI_WriteInt(tmpoutput,0);
				format(tmpoutput,128,"%slaufbahn1",player_name[playerid]);
				INI_WriteInt(tmpoutput,0);
				format(tmpoutput,128,"%slaufbahn2",player_name[playerid]);
				INI_WriteInt(tmpoutput,0);
				format(tmpoutput,128,"%slevel",player_name[playerid]);
				INI_WriteInt(tmpoutput,1);
				format(tmpoutput,128,"%sexp",player_name[playerid]);
				INI_WriteInt(tmpoutput,0);
				format(tmpoutput,128,"%shealth",player_name[playerid]);
				INI_WriteInt(tmpoutput,5);
				format(tmpoutput,128,"%sattack",player_name[playerid]);
				INI_WriteInt(tmpoutput,2);
				format(tmpoutput,128,"%sverteidigung",player_name[playerid]);
				INI_WriteInt(tmpoutput,2);
				format(tmpoutput,128,"%sfokus",player_name[playerid]);
				INI_WriteInt(tmpoutput,0);
				
				INI_Save();
				INI_Close();
			}
			SetPlayerScore(playerid,1);
			loggedin[playerid] = 1;
		}
		case 2:
		{
		    if(INI_Open("Users.ini")) // Users.ini öffnen
			{
				new password[128];
				if (INI_ReadString(password, player_name[playerid], MAX_PLAYER_NAME)) // Wenn Benutzer registriert
				{
					if (strcmp(password, inputtext, false) == 0) // wenn parameter (=eingegebenes pw) = gespeichertes pw
					{
						new tmpoutput[128];
						format(tmpoutput,128,"%sadminlevel",player_name[playerid]);
						adminlevel[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%slaufbahn1",player_name[playerid]);
						laufbahn1[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%slaufbahn2",player_name[playerid]);
						laufbahn2[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%slevel",player_name[playerid]);
						level[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%sskin",player_name[playerid]);
						skin[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%sexp",player_name[playerid]);
						exp[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%shealth",player_name[playerid]);
						health[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%sattack",player_name[playerid]);
						attacke[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%sverteidigung",player_name[playerid]);
						verteidigung[playerid] = INI_ReadInt(tmpoutput);
						format(tmpoutput,128,"%sfokus",player_name[playerid]);
						fokus[playerid] = INI_ReadInt(tmpoutput);
						tfokus[playerid] = fokus[playerid];
						if(adminlevel[playerid] >= 1) SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Administrator");
						
						loggedin[playerid] = 1;
						SetPlayerScore(playerid,level[playerid]);
						format(tmpoutput,128,"Erfahrung: %d/%d",exp[playerid],requirelevel[level[playerid]]);
						TextDrawSetString(expbalken[playerid],tmpoutput);
						format(tmpoutput,128,"Fokus: %d/%d",fokus[playerid],fokus[playerid]);
						TextDrawSetString(fokusbar[playerid],tmpoutput);
						
						TextDrawShowForPlayer(playerid,fokusbar[playerid]);
						TextDrawShowForPlayer(playerid,expbalken[playerid]);
						
						if(skin[playerid] != -1)
						{
							SpawnPlayer(playerid);
							SetPlayerSkin(playerid,skin[playerid]);
							if(laufbahn1[playerid] == 0) Mission(playerid,1);
						}
					}
					else { ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Falsches Passwort","Du bist offensichtlich nicht der, der du zu sein scheinst !\n Ich muss sicher sein, dass du es bist, bevor ich dich in die Matrix schicke,\n also sag mir jetzt dein Passwort :","Absenden","Verlassen"); }
				}
				INI_Close();
			}
		}
		case 3:
		{
		    if(response == 0)
		    {
		        ForceClassSelection(playerid);
		        TogglePlayerControllable(playerid,1);
		        SetPlayerHealth(playerid,0);
		        SendClientMessage(playerid,COLOR_GREY,"Wählen nun dein richtiges Aussehen");
		    }
		    else
		    {
		        new tskin = GetPlayerSkin(playerid);
		        new tmpoutput[128];
		        if(INI_Open("Users.ini"))
		        {
      				format(tmpoutput,128,"%sskin",player_name[playerid]);
					INI_WriteInt(tmpoutput,GetPlayerSkin(playerid));
					skin[playerid] = tskin;
		        }
		        INI_Save();
		        INI_Close();
		        TogglePlayerControllable(playerid,1);
		        SendClientMessage(playerid,COLOR_ORANGE,"Skin gespeichert");
		        Mission(playerid,1);
		    }
		}
		case 4:
		{
		    if(INI_Open("Users.ini"))
		    {
		        new tmpoutput3[128];
		        switch(listitem)
		        {
		            case 0:
		            {
		                health[playerid] += 15;
		                format(tmpoutput3,128,"%shealth",player_name[playerid]);
		                INI_WriteInt(tmpoutput3,health[playerid]);
						SetPlayerHealth(playerid,health[playerid]);
		            }
		            case 1:
		            {
		                attacke[playerid] += 1;
		                format(tmpoutput3,128,"%sattack",player_name[playerid]);
		                INI_WriteInt(tmpoutput3,attacke[playerid]);
		            }
		            case 2:
		            {
		                verteidigung[playerid] += 1;
		                format(tmpoutput3,128,"%sverteidigung",player_name[playerid]);
		                INI_WriteInt(tmpoutput3,verteidigung[playerid]);
		            }
		            case 3:
		            {
		                fokus[playerid] += 25;
		                format(tmpoutput3,128,"%sfokus",player_name[playerid]);
		                INI_WriteInt(tmpoutput3,INI_ReadInt(tmpoutput3)+25);
						format(tmpoutput3,128,"Fokus: %d/%d",tfokus[playerid],fokus[playerid]);
						TextDrawSetString(expbalken[playerid],tmpoutput3);
		            }
		        }
		        GameTextForPlayer(playerid,"Skill verbessert",2000,3);
		        INI_Save();
		        INI_Close();
		    }
		}
    }
	return 1;
}


