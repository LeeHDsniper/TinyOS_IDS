 /*
 * 该组件替代了ActiveMessageC组件，实现了ForgedActiveMessageC所提供的接口，
 * 将AMSender, AMReceiver, AMSnoop, AMSnoopingReceiver和ActiveMessageC进行
 * 连接
 */
 /**
 * ForgedActiveMessageM模块组件
 *
 * @author 李浩
 * @date   2017-4-27
 */

module ForgedActiveMessageM
{
  provides
  {
		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];
		interface Receive as Snoop[am_id_t id];
		interface AMTapI;
		
  }
  uses 
  {
    interface AMSend as ExtAMSend[am_id_t];
    interface Receive as ExtReceive[am_id_t];
    interface Receive as ExtSnoop[am_id_t];
    interface AMPacket;

    
  }
}

implementation 
{

  /********** AMSend ************************/
  command error_t 
  AMSend.send[am_id_t id](am_addr_t addr, message_t* msg, uint8_t len) 
  {
    am_id_t packet_type = call AMPacket.type(msg);
    msg = signal AMTapI.send(packet_type,msg,len,id);
    return call ExtAMSend.send[packet_type](addr,msg,len);
  }

  command error_t AMSend.cancel[am_id_t id](message_t* msg) 
  {
    return call ExtAMSend.cancel[id](msg);
  }

  command uint8_t AMSend.maxPayloadLength[uint8_t id]() 
  {
    return call ExtAMSend.maxPayloadLength[id]();
  }

  command void* AMSend.getPayload[am_id_t id](message_t* msg, uint8_t len) 
  {
    return call AMSend.getPayload[call AMPacket.type(msg)](msg,len);
  }
  
  event void ExtAMSend.sendDone[am_id_t id](message_t* msg, error_t error)
  {
  	signal AMSend.sendDone[call AMPacket.type(msg)](msg, error);
  }

  default event void AMSend.sendDone[am_id_t id](message_t* msg, error_t error)
  {
  }

  
  /********* AM RECEIVE ********************/
  event message_t* ExtReceive.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) 
  {
	am_id_t type = call AMPacket.type(msg);
    msg = signal AMTapI.receive(type,msg,len,id);
    return signal Receive.receive[type](msg, payload, len);
  }

  default event message_t* Receive.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) 
  {
    return msg;
  }
  
  /********* AM SNOOP **********************/
  event message_t* ExtSnoop.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) 
  {
    am_id_t type = call AMPacket.type(msg);
    msg = signal AMTapI.snoop(type,msg,len,id);
    return signal Snoop.receive[type](msg, payload, len);
  }

  default event message_t* Snoop.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) 
  {
    return msg;
  }


  /******************************************/
  default event message_t* AMTapI.receive(uint8_t type, message_t* msg, uint8_t len, uint8_t id)
  {
      return msg;
  }

  default event message_t* AMTapI.snoop(uint8_t type, message_t* msg, uint8_t len, uint8_t id)
  {
      return msg;
  }

  default event message_t* AMTapI.send(uint8_t type, message_t* msg, uint8_t len, uint8_t id)
  {
      return msg;
  }
}
