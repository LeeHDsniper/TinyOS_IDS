/*
 * 该组件实现了PacketCacheI接口，提供了对Ctp数据包进行存储的功能
 */
 /**
 * CtpPacketCache模块组件
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "CtpPacketCache.h"
generic module CtpPacketCacheM(uint8_t size)//size = 100
{
	uses interface ForgedCtpPacketI as ForgedCtpPacket;
	uses interface MemoryMngrI;
	provides interface PacketCacheI;
}
implementation
{
	ctp_packet_sign_t* cache;
	uint8_t first;
	uint8_t count;
	//在已存储的消息中查找该消息，如果存在，则返回该消息的index
	uint8_t lookup(message_t* msg,bool forwarded_enabled,uint8_t node_pos)
	{
		uint8_t i;
		uint8_t msg_index;
		uint8_t thl= call ForgedCtpPacket.getThl(msg);
		if(forwarded_enabled)
		{
			thl--;
		}
		for(i=0;i<count;i++)
		{
			msg_index=i;
			if(node_pos == cache[msg_index].forwarder && call ForgedCtpPacket.getOrigin(msg)==cache[msg_index].origin &&
				call ForgedCtpPacket.getSequenceNumber(msg)==cache[msg_index].seqno &&
				thl==cache[msg_index].thl && call ForgedCtpPacket.getType(msg)==cache[msg_index].type)
			{
				break;
			}
		}
		return i;
	}
	void remove(uint8_t i)
	{
		uint8_t j;
		if(i>= count)
		{
			return;
		}
		if(i==0&&count<=1)
		{
			;
		}
		else
		{
			for (j=i;j<count;j++)
			{
				memcpy(&cache[j],&cache[j+1],sizeof(ctp_packet_sign_t));
			}
		}
		count--;
	}
	
	command void PacketCacheI.reset(){
		count=0;
		dbg("IDS-PacketCache","IDS-PacketCache initializing... \n");
		cache=call MemoryMngrI.malloc(sizeof(ctp_packet_sign_t)*size);
		dbg("IDS-PacketCache","IDS-PacketCache initializing Done! \n");
	}
	
	command uint8_t PacketCacheI.insert(message_t *msg, uint8_t node_pos){
		uint8_t ret_value=255;
		uint8_t retry=0;
		uint8_t i=lookup(msg,FALSE,node_pos);
		if(i<count)//消息已经存储过，对该消息的retry值进行更新
		{
			dbg("IDS-PacketCache","Update Packet info\n");
			cache[i].retry=cache[i].retry+1;
			return ret_value;
		}
		if(count==size)//数据包存储空间已满，如果需要将最早收到
		{
			dbg("IDS-PacketCache","PacketCache is Full!count is %d ,size is %d\n",count,size);
			ret_value=cache[0].forwarder;
			remove(0);
			return ret_value;
		}
		cache[i].forwarder =node_pos;
		cache[i].origin=call ForgedCtpPacket.getOrigin(msg);
		cache[i].seqno=call ForgedCtpPacket.getSequenceNumber(msg);
		cache[i].thl=call ForgedCtpPacket.getThl(msg);
		cache[i].type=call ForgedCtpPacket.getType(msg);
		cache[i].retry=retry;
		dbg("IDS-PacketCache","Insert packet with signature : %d %d %d %d %d %d \n",
			cache[i].forwarder,cache[i].origin,cache[i].seqno,
			cache[i].thl,cache[i].type,cache[i].retry);
		count++;
		return ret_value;
	}

	command bool PacketCacheI.check(message_t *msg, uint8_t node_pos){
		uint8_t i=lookup(msg,TRUE,node_pos);
		dbg("IDS-PacketCacheCheck","check signature: %d %d %d %d %d * \n",
			node_pos,call ForgedCtpPacket.getOrigin(msg),
			call ForgedCtpPacket.getSequenceNumber(msg),
			call ForgedCtpPacket.getThl(msg),call ForgedCtpPacket.getType(msg));
		if(i<count)
		{
			dbg("IDS-PacketCache","Remove packet with signature : %d %d %d %d %d %d \n",
			cache[i].forwarder,cache[i].origin,cache[i].seqno,
			cache[i].thl,cache[i].type,cache[i].retry);
			remove(i);
			//normal_no++;
			//dbg("test","**********count is %d\n",count);
			return TRUE;
		}
		//dbg("IDS-PacketCache","Check not Found!\n");
		return FALSE;
	}

	command bool PacketCacheI.isEmpty(){
		return (count==0)?TRUE:FALSE;
	}

	command uint8_t PacketCacheI.delFirst(){
		uint8_t ret_value=cache[0].forwarder;
		remove(0);
		return ret_value;
	}

	command void PacketCacheI.dump(){
		uint8_t msg_index;
		dbg("IDS-PacketCacheDump","---------------------PacketCache Dump---------------------\n");
		dbg("IDS-PacketCacheDump","forwarder  origin  seqno  thl  type  retry\n");
		if(count > 0)
		{
			for(msg_index=0;msg_index<count;msg_index++)
			{
				dbg("IDS-PacketCacheDump","%5d%11d%6d%7d%5d%6d\n",cache[msg_index].forwarder,
					cache[msg_index].origin,cache[msg_index].seqno,cache[msg_index].thl,
					cache[msg_index].type,cache[msg_index].retry);
			}
		}
		}
}