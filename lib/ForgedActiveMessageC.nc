 /*
 * 该组件替代了ActiveMessageC组件
 */
 /**
 * ForgedActiveMessageC配置组件
 *
 * @author 李浩
 * @date   2017-4-27
 */

configuration ForgedActiveMessageC
{
	provides
	{
		interface SplitControl;
		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];
		interface Receive as Snoop[am_id_t id];
		interface Packet;
		interface AMPacket;
		interface PacketAcknowledgements;
  		interface AMTapI;
	}

}

implementation
{
	components ActiveMessageC;
  	components ForgedActiveMessageM;
	
	//components IntrusionDetectionSystemC;

    //ForgedActiveMessageP.AMTapI = AMTapI;	
	//ForgedActiveMessageP.AMTapI -> IntrusionDetectionSystemC.AMTapI;
    AMTapI = ForgedActiveMessageM.AMTapI;
    //IntrusionDetectionSystemC.AMTapI -> ForgedActiveMessageP.AMTapI;
	
  	//forged components
  	AMSend       = ForgedActiveMessageM.AMSend;
  	Receive      = ForgedActiveMessageM.Receive;
	Snoop        = ForgedActiveMessageM.Snoop;
	
  	//defaults 
	SplitControl = ActiveMessageC;
 	Packet       = ActiveMessageC;
	AMPacket     = ActiveMessageC;
	PacketAcknowledgements	= ActiveMessageC;

	ForgedActiveMessageM.ExtAMSend -> ActiveMessageC.AMSend;
  	ForgedActiveMessageM.ExtReceive -> ActiveMessageC.Receive;
  	ForgedActiveMessageM.ExtSnoop -> ActiveMessageC.Snoop;
  	ForgedActiveMessageM.AMPacket -> ActiveMessageC.AMPacket;

}
