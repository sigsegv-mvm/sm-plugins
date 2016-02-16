#include <sourcemod>
#include <tf2>
#include <tf2_stocks>


// this plugin pretty much just intercepts a couple of MvM usermessages and
// resends them over the reliable stream, because they can easily overflow the
// unreliable stream


public Plugin myinfo = {
	name        = "[MvM] UserMessage buffer overflow fix",
	author      = "sigsegv",
	description = "Fix for the 'Disconnect: Buffer overflow in net message' error",
	version     = "20160215",
	url         = "https://github.com/sigsegv-mvm/sm-plugins",
};


UserMsg ID_MVMLocalPlayerUpgradesClear = INVALID_MESSAGE_ID;
UserMsg ID_MVMLocalPlayerUpgradesValue = INVALID_MESSAGE_ID;


public void OnPluginStart()
{
	ID_MVMLocalPlayerUpgradesClear = GetUserMessageId("MVMLocalPlayerUpgradesClear");
	if (ID_MVMLocalPlayerUpgradesClear == INVALID_MESSAGE_ID) {
		SetFailState("Can't get UserMessage ID for MVMLocalPlayerUpgradesClear");
	}
//	PrintToServer("MVMLocalPlayerUpgradesClear = %d", ID_MVMLocalPlayerUpgradesClear);
	
	ID_MVMLocalPlayerUpgradesValue = GetUserMessageId("MVMLocalPlayerUpgradesValue");
	if (ID_MVMLocalPlayerUpgradesValue == INVALID_MESSAGE_ID) {
		SetFailState("Can't get UserMessage ID for MVMLocalPlayerUpgradesValue");
	}
//	PrintToServer("MVMLocalPlayerUpgradesValue = %d", ID_MVMLocalPlayerUpgradesValue);
	
	HookUserMessage(ID_MVMLocalPlayerUpgradesClear, UserMsgHook, true, UserMsgHookPost);
	HookUserMessage(ID_MVMLocalPlayerUpgradesValue, UserMsgHook, true, UserMsgHookPost);
}


bool      resend = false;
UserMsg   resend_id = INVALID_MESSAGE_ID;
ArrayList resend_data = null;
ArrayList resend_players = null;

public Action UserMsgHook(UserMsg msg_id, BfRead msg, int[] players, int playersNum, bool reliable, bool init)
{
//	PrintToServer("UserMsgHook %d %s", msg_id, (reliable ? "reliable" : "unreliable"));
	if (!reliable) {
		resend = true;
		resend_id = msg_id;
		
		if (resend_data == null) resend_data = new ArrayList();
		resend_data.Clear();
		while (msg.BytesLeft != 0) {
			resend_data.Push(msg.ReadByte());
		}
		
		if (resend_players == null) resend_players = new ArrayList();
		resend_players.Clear();
		for (int i = 0; i < playersNum; ++i) {
			resend_players.Push(players[i]);
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

// SM bug: the "sent" parameter is a lie
public void UserMsgHookPost(UserMsg msg_id, bool sent)
{
//	PrintToServer("UserMsgHookPost %d %s", msg_id, (sent ? "sent" : "blocked"));
	
	if (resend) {
		int[] players = new int[resend_players.Length];
		for (int i = 0; i < resend_players.Length; ++i) {
			players[i] = resend_players.Get(i);
		}
		
		BfWrite newmsg = StartMessageEx(resend_id, players, resend_players.Length, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
		if (newmsg != INVALID_HANDLE) {
			for (int i = 0; i < resend_data.Length; ++i) {
				newmsg.WriteByte(resend_data.Get(i));
			}
			EndMessage();
		}
		
		resend = false;
	}
}
