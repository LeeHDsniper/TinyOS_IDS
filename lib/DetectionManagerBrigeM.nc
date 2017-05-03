 /*
 * 该模块组件提供了DetectionEngine接口和DetectionManager接口
 * IDS_Scheduler组件将通过该组件为桥梁，连接到DetectionEngine和DetectionManager
 */
 /**
 * DetetionManagerBrigeM组件
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "IDS.h"
module DetectionManagerBrigeM{
	provides interface DetectionEngineI as DetectionEngine;
	provides interface DetectionManagerI as DetectionManager;
	provides interface StatisticsMngrI [uint8_t id];
	uses interface DetectionEngineI[uint8_t id];
	uses interface StatisticsMngrI as StatisticsMngr;
}
implementation{
	uint8_t engine_id =0;
	uint8_t enginesCount = uniqueCount("DETECTION_ENGINE");
	
	command uint8_t DetectionManager.enginesCount()
	{
		return enginesCount;
	}

	command bool DetectionManager.engine_selected(uint8_t engine_no)
	{
		if(engine_no < enginesCount)
		{
			engine_id = engine_no;
		  	return TRUE;
	    }
	    return FALSE;
	}
	
	
	command void DetectionEngine.start()
	{
		dbg("IDS-DetectionBrige","DetectionEngine start!\n");
		call DetectionEngineI.start[engine_id]();
	}
	command void DetectionEngine.stop()
	{
		dbg("IDS-DetectionBrige","DetectionEngine stop!\n");
		call DetectionEngineI.stop[engine_id]();
	}
	
	command bool DetectionEngine.isRunning()
	{
		return call DetectionEngine.isRunning();
	}

	command void DetectionEngine.evaluate()
	{
		call DetectionEngineI.evaluate[engine_id]();
	}

	event void DetectionEngineI.evaluateDone[uint8_t id](uint8_t alerts_no)
	{
		//call StatisticsMngr.dump();
		signal DetectionEngine.evaluateDone(alerts_no);
	}

	event void DetectionEngineI.startDone[uint8_t id](uint16_t run_time)
	{
		signal DetectionEngine.startDone(run_time);
	}

	event void DetectionEngineI.stopDone[uint8_t id]()
	{
		signal DetectionEngine.stopDone();
	}

	command void StatisticsMngrI.init[uint8_t id]()
	{
		call StatisticsMngr.init();
	}
	command uint16_t StatisticsMngrI.outgoing_msg[uint8_t id]()
	{
		return (call StatisticsMngr.outgoing_msg());
	}

	command uint16_t StatisticsMngrI.incoming_msg[uint8_t id]()
	{
		return (call StatisticsMngr.incoming_msg());
	}

	command void StatisticsMngrI.dump[uint8_t id]()
	{
		call StatisticsMngr.dump();
	}

	

	command void StatisticsMngrI.startMonitoring[uint8_t id](uint8_t num)
	{
		call StatisticsMngr.startMonitoring(num);
	}

	command void StatisticsMngrI.stopMonitoring[uint8_t id]()
	{
		call StatisticsMngr.stopMonitoring();
	}

	command neighbor_t * StatisticsMngrI.getNode[uint8_t id](uint8_t position)
	{
		return (call StatisticsMngr.getNode(position));
	}

	command uint8_t StatisticsMngrI.monitoredNodesNum[uint8_t id]()
	{
		return (call StatisticsMngr.monitoredNodesNum());
	}

	command void StatisticsMngrI.sort[uint8_t id]()
	{
		call StatisticsMngr.sort();
	}

	event message_t * StatisticsMngr.sourceMonitored(message_t *msg, uint8_t len, uint8_t node_pos){
		msg=signal StatisticsMngrI.sourceMonitored[engine_id](msg,len, node_pos);
		return msg;
	}

	event message_t * StatisticsMngr.destinationMonitored(message_t *msg, uint8_t len, uint8_t node_pos){
		msg=signal StatisticsMngrI.destinationMonitored[engine_id](msg, len,  node_pos);
		return msg;
	}

	event void StatisticsMngr.startNonitoringDone(uint8_t num)
	{
		signal StatisticsMngrI.startNonitoringDone[engine_id](num);
	}

	event void StatisticsMngr.sortDone()
	{
		signal StatisticsMngrI.sortDone[engine_id]();
	}
}