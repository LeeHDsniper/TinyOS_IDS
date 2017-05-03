configuration IDS_SwapMsgC{
	provides interface IDS_SwapMsgI;
}
implementation{
	components IDS_SwapMsgM;
    components new AMSenderC(0x77) as AMSend;
    components new AMReceiverC(0x77) as AMReceive;
    components ActiveMessageC;

	IDS_SwapMsgI=IDS_SwapMsgM;
	
    IDS_SwapMsgM.AMPacket->AMSend;
    IDS_SwapMsgM.Packet->AMSend;
    IDS_SwapMsgM.AMSend -> AMSend;
    
    IDS_SwapMsgM.SplitControl -> ActiveMessageC;

    IDS_SwapMsgM.Receive -> AMReceive;
}