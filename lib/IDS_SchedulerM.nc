 /*
 * 该组件实现了IDS启动、休眠、运行等行为
 */
 /**
 * IDS_Scheduler模块组件
 *
 * @author 李浩
 * @date   2017-4-27
 */
 
#include "IDS.h"
module IDS_SchedulerM
{
  uses interface Boot;
  uses interface Timer<TMilli> as Timer_IDS;
  uses interface Timer<TMilli> as Timer_Detection;
  uses interface Queue<detection_t> as DetectionsQueue;
  uses interface Random;
  uses interface DetectionEngineI;
  uses interface DetectionManagerI;
}
implementation
{
	//定义IDS的三种状态休眠、初始化、运行
	enum
	{
		SLEEP,
		INITIALIZING,
		RUNNING
	};
	
	uint8_t IDS_State=SLEEP;
	
	detection_t Current_Detection;
	
	uint16_t Init_Threshold=INIT_THRESHOLD;
	
	void Auto_Execute()
	{
		if((call Random.rand16()) < Init_Threshold)
		{
			detection_t Auto_Detection;
			dbg("IDS-Scheduler","Auto execute detection \n");
			Auto_Detection.detection_engine=0;
			call DetectionsQueue.enqueue(Auto_Detection);
			Init_Threshold=INIT_THRESHOLD;
		}
		else
		{
			dbg("IDS_Scheduler","Increase Init_Threshold");
			Init_Threshold += INIT_THRESHOLD_INCREASE;
		}
	}
	
	void IDS_Control()
	{
		switch(IDS_State)
		{
			case SLEEP:
				if(call DetectionsQueue.empty()==FALSE)
				{
					IDS_State=INITIALIZING;
					Current_Detection=call DetectionsQueue.head();
					dbg("IDS-Scheduler","Initializing Detection %d \n",Current_Detection.detection_engine);
					call DetectionManagerI.engine_selected(Current_Detection.detection_engine);
					call DetectionEngineI.start();
				}
				break;
			case RUNNING:
				//进行评估
				call DetectionEngineI.stop();
				break;
		}
	}
	event void Boot.booted()
	{
		if((TOS_NODE_ID % IDS_ID_MOD)==IDS_ID)
		//if(TOS_NODE_ID==4)
		{
			dbg("IDS-Scheduler","IDS-Scheduler Booted at node: %d!\n",TOS_NODE_ID);
			call Timer_IDS.startPeriodic(IDS_PERIOD);
		}
		else
		{
			return;
		}
	}
	/*----------------测试代码-----------------
	 * 
	int i=-1;
	event void Timer_IDS.fired()
	{
		if((TOS_NODE_ID % 10)==i)
		{
			detection_t Auto_Detection;
			Auto_Detection.detection_engine=0;
			call DetectionsQueue.enqueue(Auto_Detection);
			if(i >= 1 && i <= 10)
			{
				detection_t Auto_Detection;
				Auto_Detection.detection_engine=2;
				call DetectionsQueue.enqueue(Auto_Detection);
			}
		}
		i++;
		if(IDS_State == SLEEP)
		{
			IDS_Control();
		}
	}
	*/
	//IDS主循环
	event void Timer_IDS.fired()
	{
		Auto_Execute();
		if(IDS_State == SLEEP)
		{
			IDS_Control();
		}
	}
	//检测定时器
	event void Timer_Detection.fired()
	{
		if(IDS_State==RUNNING)
		{
			IDS_Control();
		}
	}
	//检测引擎成功启动
	event void DetectionEngineI.startDone(uint16_t run_time)
	{
		if(run_time > 0)
		{
			IDS_State=RUNNING;
			call Timer_Detection.startOneShot(run_time);
			dbg("IDS-Scheduler","Detection engine started! \n");
		}
		else
		{
			call DetectionsQueue.dequeue();
			IDS_State=SLEEP;
			IDS_Control();
		}
	}
	//检测引擎停止
	event void DetectionEngineI.stopDone()
	{
		dbg("IDS-Scheduler","Detection engine stopped,starting evaluation. \n");
		call DetectionEngineI.evaluate();
	}
	//检测引擎评估完成
	event void DetectionEngineI.evaluateDone(uint8_t alerts_no)
	{
		dbg("IDS-Scheduler","Evalueation done,%d alerts. \n",alerts_no);
		call DetectionsQueue.dequeue();
		IDS_State=SLEEP;
		if(call DetectionsQueue.empty()==FALSE)
		{
			IDS_Control();
		}
	}
}

