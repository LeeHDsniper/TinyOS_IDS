#include "IDS.h"
configuration CtpPacketCacheC{
	provides interface PacketCacheI;
}
implementation{
	components new CtpPacketCacheM(MEMORY_MNGR_SIZE) as CtpPacketCache;
	PacketCacheI=CtpPacketCache;
	components ForgedCtpPacketC;
	components MemoryMngrC;
	//CtpPacketCache.Packet -> ActiveMessage.Packet;
	CtpPacketCache.ForgedCtpPacket -> ForgedCtpPacketC;
	CtpPacketCache.MemoryMngrI->MemoryMngrC;
}