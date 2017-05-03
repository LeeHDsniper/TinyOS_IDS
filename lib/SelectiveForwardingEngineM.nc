/*
 * 该组件实现了普通选择性转发攻击检测引擎
 */
 /**
 * SelectiveForwardingEngine模块组件
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "IDS.h"
#define SELECTIVE_FORWARDING_THRESHOLD 110
#define SELECTIVE_FORWARDING_MONITORED_NEIGHBORS 10
#define STOP_DELAY 1000
module SelectiveForwardingEngineM
{
	uses
	{
		interface PacketCacheI;
		interface ForgedCtpPacketI;
		interface ResponseI;
		interface Timer<TMilli> as Timer0;
		interface StatisticsMngrI[uint8_t id];
	}
	provides interface DetectionEngineI[uint8_t id];
	
}
implementation{
	uint8_t engine_id=SELECTIVE_FORWARDING;
	task void evaluate();
	task void clearCtpPacketCache();
	
	uint8_t processed_node =0;
	uint8_t alerts=0;
	neighbor_t * nei_node;
	enum
	{
		SLEEP,
		RUNNING,
		STOPPING
	};
	int8_t state=SLEEP;
	
	command void DetectionEngineI.start[uint8_t id]()
	{
		dbg("IDS-DetectionEngine","SelectiveForwadingDetectionEngine initializing... \n");
		call StatisticsMngrI.sort[engine_id]();
		call PacketCacheI.reset();
	}
	
	event void StatisticsMngrI.sortDone[uint8_t id]()
	{
		call StatisticsMngrI.startMonitoring[engine_id](SELECTIVE_FORWARDING_MONITORED_NEIGHBORS);
	}
	
	event void StatisticsMngrI.startNonitoringDone[uint8_t id](uint8_t num)
	{
		dbg("IDS-DetectionEngine","SelectiveForwardingEngine:monitoring started,monitoring %d nodes\n",num);
		state=RUNNING;
		signal DetectionEngineI.startDone[engine_id](30000);
	}
	
	command void DetectionEngineI.stop[uint8_t id]()
	{
		state=STOPPING;
		dbg("IDS-DetectionEngine","SelectiveForwadingEngine:stopping engine...\n");
		call Timer0.startOneShot(1000);
	}
	event void Timer0.fired()
	{
		state=SLEEP;
		dbg("IDS-DetectionEngine","SelectiveForwardingEngine:stopping monitoring...\n");
		call StatisticsMngrI.stopMonitoring[engine_id]();
		signal DetectionEngineI.stopDone[engine_id]();
	}

	command bool DetectionEngineI.isRunning[uint8_t id]()
	{
		return (state == RUNNING || state == STOPPING)?TRUE:FALSE;
	}
	
	command void DetectionEngineI.evaluate[uint8_t id]()
	{
		processed_node =0;
		alerts=0;
		dbg("IDS-DetectionEngine","SelectiveForwardingEngine:start evaluating...\n");
		post clearCtpPacketCache();
		post evaluate();
	}
	task void evaluate()
	{
		if(processed_node >= call StatisticsMngrI.monitoredNodesNum[engine_id]())
		{
			dbg("IDS-DetectionEngine","SelectiveForwardingEngine:all nodes has been evaluated!\n");
			signal DetectionEngineI.evaluateDone[engine_id](alerts);
			return;
		}
		nei_node=call StatisticsMngrI.getNode[engine_id](processed_node);
		if((nei_node->normal_no > 0 || nei_node->abnormal_no >0) && (nei_node->normal_no+nei_node->abnormal_no) > 3)
		{
			//计算错误率
			uint8_t error_rate =((nei_node -> abnormal_no*255)/(nei_node->normal_no+nei_node->abnormal_no));
			//if(nei_node->congested_no ==0 || error_rate <20)
			//{
				//dbg_clear("TEST","node %d has error_rate %d\n",nei_node->node_id,error_rate);
			//}
			dbg("IDS-DetectionEngine","node %d error_rate is %d\n",nei_node->node_id,error_rate);
			nei_node->avg_traffic=(nei_node->normal_no+nei_node->abnormal_no+nei_node->avg_traffic* (nei_node->detections_no-1))/(nei_node->detections_no);
			if(error_rate >= SELECTIVE_FORWARDING_THRESHOLD && nei_node->congested_no ==0)
			{
				dbg("IDS-DetectionEngine","Call Response module to broadcast alert\n");
				dbg_clear("TEST","%d_%d ",nei_node->node_id,error_rate);
				alerts++;
				call ResponseI.alert(engine_id, nei_node->node_id);
				nei_node->avg_error=SELECTIVE_FORWARDING_THRESHOLD;	
			}
			
			else
			{
				nei_node->avg_error=(nei_node->avg_error * (nei_node->detections_no-1) + error_rate)/(nei_node->detections_no);
			}
		}

		processed_node++;
		post evaluate();
		
	}
	task void clearCtpPacketCache()
	{
		while((call PacketCacheI.isEmpty()) == FALSE){
    		uint8_t node_pos = call PacketCacheI.delFirst();
    		(call StatisticsMngrI.getNode[engine_id](node_pos))->abnormal_no++;
    		dbg("IDS_DetectionEngine","SelectiveForwarding: Removing unprocessed packet \n");
    	}
	}
	//正在监控的节点对外发送数据包
	event message_t * StatisticsMngrI.sourceMonitored[uint8_t id](message_t *msg, uint8_t len, uint8_t node_pos)
	{
		if(state==RUNNING || state == STOPPING)
		{
			bool receiver=call PacketCacheI.check(msg, node_pos);
			call PacketCacheI.dump();
			if(receiver == TRUE)
			{
				if(state== STOPPING)
				{
					dbg("IDS-DetectionEngine","SelectiveForwardingEngine:node %d is sending packet\n",(call StatisticsMngrI.getNode[engine_id](node_pos))->node_id);	
				}
				(call StatisticsMngrI.getNode[engine_id](node_pos))->normal_no++;
			}
			if(call ForgedCtpPacketI.option(msg, 0x40))
			{
				(call StatisticsMngrI.getNode[engine_id](node_pos))->congested_no++;
			}
		}
		return msg;
	}
	//正在监控的数据包收到数据包
	event message_t * StatisticsMngrI.destinationMonitored[uint8_t](message_t *msg, uint8_t len, uint8_t node_pos)
	{
		if(state ==RUNNING)
		{
			uint8_t receiver=call PacketCacheI.insert(msg, node_pos);
			if(receiver!= 255)
			{
				(call StatisticsMngrI.getNode[engine_id](receiver))-> abnormal_no++;
			}
		}
		return msg;
	}

	

	
}