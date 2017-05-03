/*
 * 该头文件定义了Temperature程序运行所需的参数
 */
 /**
 * Temperature程序头文件
 *
 * @author 李浩
 * @date   2017-4-27
 */ 
#ifndef TEMPERATURE_H
#define TEMPERATURE_H
#include <AM.h>

typedef nx_struct NetworkMsg //Temperature程序发送消息的结构体定义
{
	 nx_am_addr_t source;
	 nx_uint16_t seqno;
	 nx_am_addr_t parent;
	 nx_uint16_t metric;
	 nx_uint16_t data;
	 nx_uint8_t hopcount;
	 nx_uint16_t sendCount;
	 nx_uint16_t sendSuccessCount;
	
}NetworkMsg;
enum
{
	COLLECTION_ID=0xee,     //所在汇聚树的ID
	TIME_PERIOD=2500,       //定时器周期，以该周期读取并发送数据
	//AM_RADIOMSG=0xEF        //发送
};
#endif /* TEMPERATURE_H */