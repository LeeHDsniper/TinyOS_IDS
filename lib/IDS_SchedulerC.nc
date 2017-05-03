 #include "IDS.h"
 /*
 * 该组件是IDS启动的配置组件
 */
 /**
 * IDS_Scheduler配置组件
 *
 * @author 李浩
 * @date   2017-4-27
 */
configuration IDS_SchedulerC
{
}
implementation
{
	components IDS_SchedulerM as IDS;
	components DetectionMangerBrigeC as BrigeC;
	components MainC;
	components new TimerMilliC() as Timer_IDS;
	components new TimerMilliC() as Timer_Detection;
	components RandomC;
	components new QueueC(detection_t,DETECTION_QUEUE_SIZE) as Queue;
	IDS -> MainC.Boot;
	IDS.Timer_IDS -> Timer_IDS;
	IDS.Timer_Detection -> Timer_Detection;
	IDS.Random -> RandomC;
	IDS.DetectionEngineI->BrigeC.DetectionEngineI;
	IDS.DetectionManagerI->BrigeC.DetectionManagerI;
	IDS.DetectionsQueue->Queue.Queue;
	
	
}
