 /*
 * 该头文件配置了IDS运行时的参数
 */
 /**
 * IDS头文件
 *
 * @author 李浩
 * @date   2017-4-27
 */
#ifndef IDS_H
#define IDS_H

#define IDS_PERIOD 30000                 //定义IDS休眠周期
#define INIT_THRESHOLD 2048              //初始阈值
#define INIT_THRESHOLD_INCREASE 1024     //初始阈值步长

#define ROOTS_MOD 500                    //定义每500个节点中插入一个ROOT节点
#define ROOT_ID 1                        //定义节点ID mod 500 =1的节点为ROOT节点
#define IDS_ID_MOD 10
#define IDS_ID 5
#define DETECTION_QUEUE_SIZE 6           //入侵检测任务队列长度

#define MEMORY_MNGR_SIZE 100

typedef struct                           //入侵检测任务结构体
{
	uint8_t detection_engine;            //所需要的检测引擎
	uint8_t probability;                 //概率
}detection_t;

typedef nx_struct ids_msg
{
	nx_uint8_t alert_type;
	nx_uint16_t node_id;
}ids_msg;

enum
	{
    	SELECTIVE_FORWARDING = unique("DETECTION_ENGINE"),
    	ADVANCED_ENGINE = unique("DETECTION_ENGINE"),
    };
#endif /* IDS_H */
