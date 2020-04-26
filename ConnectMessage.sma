#include <amxmodx>
#include <json>

#pragma semicolon 1

#define GetRandomMessage(%0) ArrayGetString(MessagesList,random_num(0,ArraySize(MessagesList)-1),%0,charsmax(%0))
#define MAX_CHATMSG_LENGTH 187
#define Cvar(%1) Cvars[Cvar_%1]
#define GetLang(%1) fmt("%L",LANG_SERVER,%1)

#define MSG_DHUD_CHAN 7

enum E_Cvars{
    Float:Cvar_ShowMsgDelay,
    bool:Cvar_MsgsForBots,
    Cvar_MsgMode,
    Cvar_HudColor[16],
    Cvar_HudCoords[16],
    Float:Cvar_HudHoldTime,
    Float:Cvar_HudFadeTime,
}

enum E_Color{
    Cl_Red,
    Cl_Green,
    Cl_Blue,
}

enum E_HudCoords{
    Float:HC_X,
    Float:HC_Y,
}

new Array:MessagesList;
new Cvars[E_Cvars];
new Hud_Msg;

new const PLUG_NAME[] = "Connect Message";
new const PLUG_VER[] = "2.0.0";

public plugin_init(){
    register_plugin(PLUG_NAME, PLUG_VER, "ArKaNeMaN");

    register_dictionary("ConnectMessage.ini");
    Hud_Msg = CreateHudSyncObj();

    LoadMessages();
    InitCvars();

    server_print("[%s v%s] loaded.", PLUG_NAME, PLUG_VER);
}

public client_putinserver(UserId){
    if(is_user_bot(UserId) && !Cvar(MsgsForBots))
        return;

    set_task(Cvar(ShowMsgDelay), "Task_ShowMessage", UserId);
}

public Task_ShowMessage(const UserId){
    static Msg[MAX_CHATMSG_LENGTH]; GetRandomMessage(Msg);

    switch(Cvar(MsgMode)){
        case 0: {
            replace_all(Msg, charsmax(Msg), "%%Name%%", fmt("%L", LANG_PLAYER, "CHAT_NICK_TEMPLATE", UserId));
            client_print_color(0, print_team_default, "%L", LANG_PLAYER, "CHAT_MSG_TEMPLATE", Msg);
        }
        case 1: {
            replace_all(Msg, charsmax(Msg), "%%Name%%", fmt("%L", LANG_PLAYER, "HUD_NICK_TEMPLATE", UserId));
            new MsgColor[E_Color]; ParseColor(Cvar(HudColor), MsgColor);
            new HudCoords[E_HudCoords]; ParseHudCoords(Cvar(HudCoords), HudCoords);

            set_hudmessage(MsgColor[Cl_Red], MsgColor[Cl_Green] ,MsgColor[Cl_Blue], HudCoords[HC_X], HudCoords[HC_Y], 0, 0.0, Cvar(HudHoldTime), Cvar(HudFadeTime), Cvar(HudFadeTime));
            ShowSyncHudMsg(0, Hud_Msg, "%L", LANG_PLAYER, "HUD_MSG_TEMPLATE", Msg);
        }
        case 2: {
            replace_all(Msg, charsmax(Msg), "%%Name%%", fmt("%L", LANG_PLAYER, "HUD_NICK_TEMPLATE", UserId));
            new MsgColor[E_Color]; ParseColor(Cvar(HudColor), MsgColor);
            new HudCoords[E_HudCoords]; ParseHudCoords(Cvar(HudCoords), HudCoords);

            set_dhudmessage(MsgColor[Cl_Red], MsgColor[Cl_Green] ,MsgColor[Cl_Blue], HudCoords[HC_X], HudCoords[HC_Y], 0, 0.0, Cvar(HudHoldTime), Cvar(HudFadeTime), Cvar(HudFadeTime));
            show_dhudmessage(0, "%L", LANG_PLAYER, "HUD_MSG_TEMPLATE", Msg);
        }
    }
}

bool:ParseColor(const Str[], OutPut[E_Color]){
    new ColorStr[E_Color][4];
    if(parse(Str,
        ColorStr[Cl_Red], charsmax(ColorStr[]),
        ColorStr[Cl_Green], charsmax(ColorStr[]),
        ColorStr[Cl_Blue], charsmax(ColorStr[])
    ) < 3) return false;

    OutPut[Cl_Red] = str_to_num(ColorStr[Cl_Red]);
    OutPut[Cl_Green] = str_to_num(ColorStr[Cl_Green]);
    OutPut[Cl_Blue] = str_to_num(ColorStr[Cl_Blue]);
    return true;
}

bool:ParseHudCoords(const Str[], OutPut[E_HudCoords]){
    new CoordsStr[E_HudCoords][8];
    if(parse(Str,
        CoordsStr[HC_X], charsmax(CoordsStr[]),
        CoordsStr[HC_Y], charsmax(CoordsStr[])
    ) < 2) return false;

    OutPut[HC_X] = str_to_float(CoordsStr[HC_X]);
    OutPut[HC_Y] = str_to_float(CoordsStr[HC_Y]);
    return true;
}

LoadMessages(){
    if(MessagesList != Invalid_Array)
        ArrayDestroy(MessagesList);
    MessagesList = ArrayCreate(MAX_CHATMSG_LENGTH, 8);

    new File[PLATFORM_MAX_PATH];
    get_localinfo("amxx_configsdir", File, charsmax(File));
    add(File, charsmax(File), "/plugins/ConnectMessage/Messages.json");
    if(!file_exists(File)){
        set_fail_state("[ERROR] Config file '%s' not found", File);
        return;
    }
    
    new JSON:List = json_parse(File, true);
    if(!json_is_array(List)){
        json_free(List);
        set_fail_state("[ERROR] Invalid config structure. File '%s'.", File);
        return;
    }

    new Msg[MAX_CHATMSG_LENGTH];
    for(new i = 0; i < json_array_get_count(List); i++){
        json_array_get_string(List, i, Msg, charsmax(Msg));
        ArrayPushString(MessagesList, Msg);
    }
    json_free(List);
}

InitCvars(){

    bind_pcvar_float(create_cvar(
        "ConnectMessages_ShowMsgDelay",
        "1.0", FCVAR_NONE,
        GetLang("CVAR_SHOW_MSG_DELAY"),
        true, 0.0
    ), Cvar(ShowMsgDelay));

    bind_pcvar_num(create_cvar(
        "ConnectMessages_MsgsForBots",
        "1", FCVAR_NONE,
        GetLang("CVAR_MSGS_FOR_BOTS"),
        true, 0.0, true, 1.0
    ), Cvar(MsgsForBots));

    bind_pcvar_num(create_cvar(
        "ConnectMessages_MsgMode",
        "0", FCVAR_NONE,
        GetLang("CVAR_MSG_MODE"),
        true, 0.0, true, 2.0
    ), Cvar(MsgMode));

    bind_pcvar_string(create_cvar(
        "ConnectMessages_HudColor",
        "0 255 0", FCVAR_NONE,
        GetLang("CVAR_HUD_COLOR")
    ), Cvar(HudColor), charsmax(Cvar(HudColor)));

    bind_pcvar_string(create_cvar(
        "ConnectMessages_HudCoords",
        "-1.0 0.2", FCVAR_NONE,
        GetLang("CVAR_HUD_COORDS")
    ), Cvar(HudCoords), charsmax(Cvar(HudColor)));

    bind_pcvar_float(create_cvar(
        "ConnectMessages_HudHoldTime",
        "2.0", FCVAR_NONE,
        GetLang("CVAR_HUD_HOLD_TIME"),
        true, 0.0
    ), Cvar(HudHoldTime));

    bind_pcvar_float(create_cvar(
        "ConnectMessages_HudFadeTime",
        "0.2", FCVAR_NONE,
        GetLang("CVAR_HUD_FADE_TIME"),
        true, 0.0
    ), Cvar(HudFadeTime));

    AutoExecConfig(true, "Cvars", "ConnectMessage");
}