/*
 * Temperature程序模块组件，实现了组建CTP树，并读取传感器数据以及定时发送
 */
 /**
 * Temperature模块
 *
 * @author 李浩
 * @date   2017-4-27
 */ 
 
#include "Timer.h"
#include "Temperature.h"

/*----------FOR SelectiveForwardingAttack TEST-------START----*/
#define ATTACKER_NUM 5
#define ATTACKERS_START_TIME 50000
/*----------FOR SelectiveForwardingAttack TEST--------END-----*/

module TemperatureM
{
	uses
	{
		interface Boot;
		interface SplitControl as RadioControl;
		interface SplitControl as SerialControl;
		interface StdControl as RoutingControl;
		
		interface Send;
		interface Receive;
		interface AMSend as SerialSend;
		interface CollectionPacket;
		interface RootControl;
		
		interface Timer<TMilli> as Timer0;
		interface Timer<TMilli> as AttackTimer;
		interface Read<uint16_t> as TempSensor;
		interface Leds;
		interface CtpInfo;
		interface CollectionDebug;

		/*----------FOR SelectiveForwardingAttack TEST-------START----*/
		interface Random;
		interface Intercept;
		/*----------FOR SelectiveForwardingAttack TEST--------END-----*/
		
	}
}
implementation
{
	bool sendBusy=FALSE;
	bool uartBusy=FALSE;
	message_t packet;
	message_t uartPacket;
	uint8_t msglen;
	uint16_t seqno;
	uint8_t uartLen;
	bool StartAttack=FALSE;

	task void uartEchoTask()
	{
		if(call SerialSend.send(0xffff, &uartPacket,uartLen)!=SUCCESS)
		{
			uartBusy=FALSE;
		}
	}
	
	/*----------FOR SelectiveForwardingAttack TEST----START-------*/
	uint16_t Attackers[ATTACKER_NUM]={6,20,42,62,90};
	bool isAttacker()
	{
		uint8_t i;
		for(i=0;i<ATTACKER_NUM;i++)
		{
			if(TOS_NODE_ID==Attackers[i])
			{
				return TRUE;
			}
		}
		return FALSE;
	}
	event bool Intercept.forward(message_t *msg, void *payload, uint8_t len)
	{	
		if(isAttacker() && StartAttack)
		{
			uint16_t ran=call Random.rand16();
			//dbg("ATTACK","node %d receive a message to forward!\n",TOS_NODE_ID);
			ran=ran %2;
			if(ran)
			{
				//dbg("ATTACK","node %d  droped a message!\n",TOS_NODE_ID);
				return FALSE;
			}
			else
			{
				//dbg("ATTACK","node %d normally forwarded a message!\n",TOS_NODE_ID);
				return TRUE;
			}
		}
		return TRUE;
	}
	/*----------FOR SelectiveForwardingAttack TEST-----END--------*/

	void send_Message(uint16_t data)
	{
		if(!sendBusy)
		{
			NetworkMsg* msg=(NetworkMsg*)(call Send.getPayload(&packet, sizeof(NetworkMsg)));
			
			uint16_t metric;
			am_addr_t parent=0;
			call CtpInfo.getParent(&parent);
			call CtpInfo.getEtx(&metric);
			
			msg->source=TOS_NODE_ID;
			msg->seqno=seqno;
			msg->data=data;
			msg->parent=parent;
			msg->hopcount=0;
			msg->metric=metric;
			if(call Send.send(&packet, sizeof(NetworkMsg))!=SUCCESS)
			{
				dbg("APP","[ APP ]:Failed to send packet with seqno %d to parent %d\n",msg->seqno,msg->parent);
			}
			else
			{
				dbg("APP","[ APP ]:Successed to send packet with seqno %d to parent %d\n",msg->seqno,msg->parent);
				sendBusy=TRUE;
				call Leds.led0On();
				seqno++;
			}
		}
	}
	
	event void Boot.booted()
	{
		call SerialControl.start();
		call RoutingControl.start();
		call AttackTimer.startOneShot(ATTACKERS_START_TIME);
	}

	event void SerialControl.startDone(error_t error)
	{
		call RadioControl.start();
	}
	
	event void RadioControl.startDone(error_t error)
	{
		if(error !=SUCCESS)
		{
			call RadioControl.start();
		}
		else
		{
			if((TOS_NODE_ID % 500) ==1)
			{
				call RootControl.setRoot();
			}
			else
			{
				call Timer0.startOneShot(TIME_PERIOD);
			}
		}
	}

	event void Timer0.fired()
	{
		call TempSensor.read();
		call Leds.led1On();
		call Timer0.startOneShot(TIME_PERIOD);
	}

	/*----------FOR SelectiveForwardingAttack TEST-------START----*/
	event void AttackTimer.fired()
	{
		if(isAttacker())
		{
			StartAttack=TRUE;
			dbg("ATTACK","node %d start Attack!\n",TOS_NODE_ID);
		}
	}
	/*----------FOR SelectiveForwardingAttack TEST---------END----*/

	event void TempSensor.readDone(error_t result, uint16_t val)
	{
		dbg("APP","[ APP ]:Read Sensor content is:0x%08x\n",val);
		send_Message(val);
		call Leds.led1Off();
	}

	event void Send.sendDone(message_t *msg, error_t error)
	{
		if(&packet == msg)
		{
			sendBusy=FALSE;
			call Leds.led0Off();
		}
	}
	
	event void RadioControl.stopDone(error_t error)
	{
		// TODO Auto-generated method stub
	}

	

	event void SerialControl.stopDone(error_t error)
	{
		// TODO Auto-generated method stub
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		dbg("APP","[ APP ]:Receive packet,content is:0x%08x\n",((NetworkMsg*)payload)->data);
		if(uartBusy==FALSE)
		{
			NetworkMsg * msg_in =(NetworkMsg*)payload;
			NetworkMsg * msg_out =(NetworkMsg*)call SerialSend.getPayload(&uartPacket,sizeof(NetworkMsg));
			if(msg_out==NULL)
			{
				return msg;
			}
			else
			{
				memcpy(msg_out,msg_in,sizeof(NetworkMsg));
			}
			uartBusy=TRUE;
			uartLen=sizeof(NetworkMsg);
			post uartEchoTask();
		}
		return msg;
	}

	event void SerialSend.sendDone(message_t *msg, error_t error)
	{
		uartBusy=FALSE;
	}


}