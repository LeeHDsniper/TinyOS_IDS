 /*
 * 该接口定义了监控组件应该具备哪些功能
 */
 /**
 * StatisticsMngrI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "StatisticsMngr.h"
interface StatisticsMngrI{
	command void startMonitoring(uint8_t num);
	event void startNonitoringDone(uint8_t num);
	
	command void stopMonitoring();
	
	command neighbor_t* getNode(uint8_t position);
	
	command uint8_t monitoredNodesNum();
	
	command void sort();
	event void sortDone();
	
	command void init();
	
	command void dump();
	
	command uint16_t incoming_msg();
	command uint16_t outgoing_msg();
	
	event message_t* sourceMonitored(message_t * msg,uint8_t len,uint8_t node_pos);
	event message_t* destinationMonitored(message_t * msg,uint8_t len,uint8_t node_pos);
}