 /*
 * 该组件实现了IDS交换信息的功能
 */
 /**
 * IDS_SwapMsgM模块组件
 *
 * @author 李浩
 * @date   2017-4-27
 */

#include "IDS.h"
#include <AM.h>
module IDS_SwapMsgM
{
	provides interface IDS_SwapMsgI;
	uses interface AMSend ;
	uses interface AMPacket;
	uses interface Packet;
	uses interface Receive;
	uses interface SplitControl;
}
implementation
{
	message_t pkt;
	bool send_busy = FALSE;
	void send_alert(uint8_t alert_type,uint16_t node_id)
	{
		if(!send_busy)
		{
			ids_msg* msg=(ids_msg*)(call Packet.getPayload(&pkt, sizeof(ids_msg)));
			
			msg->alert_type=alert_type;
			msg->node_id=node_id;
			dbg("IDS-SwapMsg","Node: %d Broadcast Alert Message:[Node %d is likes a %d type attacker]\n",TOS_NODE_ID,node_id,alert_type);
			if (call AMSend.send(65536, &pkt, sizeof(ids_msg)) == SUCCESS) 
			{
      			send_busy = TRUE;
			}
		}
		else
		{
			dbg("IDS-SwapMsg","Node: %d Broadcast Alert Message didn't broadcast!\n",TOS_NODE_ID);
		}	
	}
	command void IDS_SwapMsgI.broadcastAlert(uint8_t alert_type, uint16_t node_id)
	{
		send_alert(alert_type,node_id);
	}

	event void AMSend.sendDone(message_t *msg, error_t error){
		if (&pkt == msg) 
		{
      		send_busy = FALSE;
    	}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		ids_msg * i_msg=(ids_msg*)payload;
		signal IDS_SwapMsgI.receiveAlert(i_msg->alert_type, i_msg->node_id);
		return msg;
	}

	event void SplitControl.startDone(error_t error){
	}

	event void SplitControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}
}