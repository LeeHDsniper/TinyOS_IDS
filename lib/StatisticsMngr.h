 /*
 * 该头文件定义了StatisticsMngr组件运行参数
 */
 /**
 * StatisticsMngr头文件
 *
 * @author 李浩
 * @date   2017-4-27
 */
#ifndef STATISTICS_MNGR_H
#define STATISTICS_MNGR_H

#define MAX_NEIGHBORS_NO 32           //最大保存的邻居节点数量
#define MONITORING_THRESHOLD -86      //需要监听的节点的增益阈值

typedef struct
{
	uint16_t node_id;                 //节点ID
	uint16_t hello_no;                //捕获到该节点发出的hello消息的次数
	int16_t avg_rssi;                 //平均接收到hello消息的信号强度
	uint16_t detections_no;           //对该节点进行检测的次数
	uint8_t avg_error;                //平均出错次数
	uint8_t avg_traffic;              //在上次测试中平均转发的数据包
	/* 临时变量 */
	uint16_t normal_no;               //成功转发数据包时增加1
	uint16_t abnormal_no;             //转发数据包失败时增加1
	uint16_t congested_no;            //拥塞标志计数器
}neighbor_t;
#endif /* STATISTICS_MNGR_H */
