configuration ForgedCtpPacketC{
	provides interface ForgedCtpPacketI;
}

implementation{
	components ForgedCtpPacketM;
	components ActiveMessageC as ActiveMessage;
	ForgedCtpPacketI=ForgedCtpPacketM;
	ForgedCtpPacketM.Packet->ActiveMessage.Packet;
}