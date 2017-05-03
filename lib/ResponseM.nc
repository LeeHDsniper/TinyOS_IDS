 /*
 * 该组件实现了Response接口以对IDS进行响应
 */
 /**
 * ResponseM组件
 *
 * @author 李浩
 * @date   2017-4-27
 */

#include "IDS.h"
module ResponseM{
	provides interface ResponseI;
	uses interface IDS_SwapMsgI;
	uses interface Queue<detection_t> as DetectionQueue;
}
implementation{

	command void ResponseI.alert(uint8_t alert_type,uint16_t node_id){
		dbg("IDS-Response","An attacker node %d found,broadcasting alert...\n",node_id);
		call IDS_SwapMsgI.broadcastAlert(alert_type, node_id);
	}

	event void IDS_SwapMsgI.receiveAlert(uint8_t alert_type, uint16_t node_id){
		detection_t new_detection;
		new_detection.detection_engine=alert_type;
		dbg("IDS-Response","Received network alert: node_id %d is likes a %d type attacker\n",node_id,alert_type);
		call DetectionQueue.enqueue(new_detection);
	}
}