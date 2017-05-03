 /*
 * 该接口定义了邻居节点列表应当具备的功能
 */
 /**
 * NeighListI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "StatisticsMngr.h"
interface NeighListI{
	command error_t update(uint16_t node_id,int16_t rssi);
	command neighbor_t* getNeighByPos(uint16_t position);
	command neighbor_t* getNeighById(uint16_t node_id);
	command uint8_t size();
	command bool isNodeBeMonitored(uint16_t node_id);
}