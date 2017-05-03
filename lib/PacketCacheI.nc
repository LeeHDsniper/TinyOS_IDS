 /*
 * 该接口定义了数据包缓存功能
 */
 /**
 * PacketCacheI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
interface PacketCacheI
{
	command uint8_t insert(message_t* msg,uint8_t node_pos);
	command bool check(message_t* msg,uint8_t node_pos);
	command void reset();
	command bool isEmpty();
	command uint8_t delFirst();
	command void dump();
}