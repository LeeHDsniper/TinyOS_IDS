 /*
 * 该接口由ForgedActiveMessageC提供，由StatisticsManager使用。
 */
 /**
 * AMTapI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
interface AMTapI 
{
  
  /* 收到数据包 */
  event message_t* receive(am_id_t type, message_t* msg, uint8_t len, am_id_t id);
  
  /* 嗅探到数据包 */
  event message_t* snoop(am_id_t type, message_t* msg, uint8_t len, am_id_t id);
 
  /* 发送数据包 */
  event message_t* send(am_id_t type, message_t* msg, uint8_t len, am_id_t id);

}
