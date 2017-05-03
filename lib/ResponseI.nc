 /*
 * 该接口定义了IDS的响应组件应当如何工作
 */
 /**
 * ResponseI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
interface ResponseI
{
	command void alert(uint8_t alert_type,uint16_t node_id);
}