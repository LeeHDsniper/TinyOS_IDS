 /*
 * 该接口定义了Ctp数据包头文件信息的获取功能
 */
 /**
 * ForgedCtpPacketI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
interface ForgedCtpPacketI
{
	command uint8_t getType(message_t *msg);
	command am_addr_t getOrigin(message_t * msg);
	command uint16_t getEtx(message_t * msg);
	command uint8_t getSequenceNumber(message_t * msg);
	command uint8_t getThl(message_t * msg);
	command bool option(message_t* msg,uint8_t opt);
	command bool matchForwarded(message_t * msg_1,message_t * msg_2);
}