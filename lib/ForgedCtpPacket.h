 /*
 * 该头文件定义了修改版的CtpPacket实现的参数
 */
 /**
 * ForgedCtpPacket头文件
 *
 * @author 李浩
 * @date   2017-4-27
 */
#ifndef FORGED_CTP_PACKET_H
#define FORGED_CTP_PACKET_H
typedef struct
{
	uint8_t options;
	uint8_t thl;
	uint16_t etx;
	am_addr_t origin;
	uint8_t originSeqno;
	uint8_t type;
	uint8_t (COUNT(0) data)[0];
}forged_packet_header_t;
#endif /* FORGED_CTP_PACKET_H */
