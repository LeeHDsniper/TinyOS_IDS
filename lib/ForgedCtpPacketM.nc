/*
 * 该组件实现了ForgedCtpPacketI接口，实现了对CTP数据包头文件的操作
 */
 /**
 * ForgedCtpPacketM模块组件
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "ForgedCtpPacket.h"
module ForgedCtpPacketM
{
	provides interface ForgedCtpPacketI;
	uses interface Packet;
}
implementation
{
	
	forged_packet_header_t * getHeader(message_t * msg)
	{
		return (forged_packet_header_t*)call Packet.getPayload(msg, sizeof(forged_packet_header_t));
	}

	command am_addr_t ForgedCtpPacketI.getOrigin(message_t *msg)
	{
		return getHeader(msg)->origin;
	}

	command uint16_t ForgedCtpPacketI.getEtx(message_t *msg)
	{
		return getHeader(msg)->etx;
	}

	command uint8_t ForgedCtpPacketI.getSequenceNumber(message_t *msg)
	{
		return getHeader(msg)->originSeqno;
	}

	command uint8_t ForgedCtpPacketI.getThl(message_t *msg)
	{
		return getHeader(msg)->thl;
	}

	command uint8_t ForgedCtpPacketI.getType(message_t *msg)
	{
		return getHeader(msg)->type;
	}
	
	command bool ForgedCtpPacketI.option(message_t *msg, uint8_t opt)
	{
		if((getHeader(msg)->options & opt)==opt)
		{
			return TRUE;
		}
		else
		{
			return FALSE;
		}
	}

	command bool ForgedCtpPacketI.matchForwarded(message_t *msg_1, message_t *msg_2)
	{
		return (call ForgedCtpPacketI.getOrigin(msg_1)==call ForgedCtpPacketI.getOrigin(msg_2) &&
			call ForgedCtpPacketI.getSequenceNumber(msg_1)==call ForgedCtpPacketI.getSequenceNumber(msg_2) &&
			call ForgedCtpPacketI.getThl(msg_1)== call ForgedCtpPacketI.getThl(msg_2) &&
			call ForgedCtpPacketI.getType(msg_1)==call ForgedCtpPacketI.getType(msg_2));
	}
}