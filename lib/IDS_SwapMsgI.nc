 /*
 * 该接口定义了IDS进行信息交换的接口具备的功能
 */
 /**
 * IDS_SwapMsgI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
interface IDS_SwapMsgI
{
	command void broadcastAlert(uint8_t alert_type,uint16_t node_id);
	event void receiveAlert(uint8_t alert_type,uint16_t node_id);
}