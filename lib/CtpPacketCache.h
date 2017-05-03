 /*
 * 该头文件定义了CTP数据包的“签名”信息，实现了对数据包的压缩存储
 */
 /**
 * PacketCacheI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
#ifndef CTP_PACKET_CACHE_H
#define CTP_PACKET_CACHE_H

typedef struct
{
	uint8_t forwarder;
	am_addr_t origin;
	uint8_t seqno;
	uint8_t type;
	uint8_t thl;
	uint8_t retry;
} ctp_packet_sign_t;
#endif /* CTP_PACKET_CACHE_H */
