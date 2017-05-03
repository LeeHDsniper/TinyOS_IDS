 /*
 * 该组件实现了对邻居节点的看门狗监控
 */
 /**
 * DetectionEngineI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "StatisticsMngr.h"
#include "IDS.h"
module StatisticsMngrM
{
	provides
	{
		interface NeighListI;
		interface StatisticsMngrI;
	}
	
	uses interface AMTapI;
	uses interface AMPacket;
	uses interface TossimPacket;
}
implementation
{
	neighbor_t neighborsList[MAX_NEIGHBORS_NO];
	
	uint8_t activeNeighborsNum=0;
	
	uint8_t monitoredNodesNum=0;
	
	bool monitoring=FALSE;
	
	uint16_t outgoing_msg_count=0;
	uint16_t incoming_msg_count=0;
	
	//检查整个邻居节点表，如果存在的话返回该节点的位置
	uint8_t getPosById(uint16_t node_id)
	{
		uint8_t i;
		for (i=0;i<activeNeighborsNum;i++)
		{
			if(node_id == neighborsList[i].node_id)
			{
				break;
			}
		}
		return i;
	}
	
	event message_t * AMTapI.receive(am_id_t type, message_t *msg, uint8_t len, am_id_t id)
	{
		am_addr_t source = call AMPacket.source(msg);
        am_addr_t destination = call AMPacket.destination(msg);
        dbg("IDS-StatisticsMngr","Received packet from %d, destined to %d\n",source, destination);
        
        if(destination == 65535){
            dbg("IDS-StatisticsMngr","StatisticsManager: updating neighbor list\n");
            call NeighListI.update(source, call TossimPacket.strength(msg));       
        }else{
        	incoming_msg_count++;
        }
        
        if(call NeighListI.isNodeBeMonitored(source)){
        	msg = signal StatisticsMngrI.sourceMonitored(msg,len, getPosById(source));
        }
    	
    	
    	return msg;
	}

	event message_t * AMTapI.snoop(am_id_t type, message_t *msg, uint8_t len, am_id_t id)
	{
		am_addr_t source = call AMPacket.source(msg);
        am_addr_t destination = call AMPacket.destination(msg);
    	if(call NeighListI.isNodeBeMonitored(source))
    	{
    		if(TOS_NODE_ID==4&&source==0)
        	dbg("IDS-StatisticsMngrI","Snooped packet from %d, destined to %d\n",source, destination);
    	   	msg = signal StatisticsMngrI.sourceMonitored(msg,len, getPosById(source));
    	}
        
        if((call NeighListI.isNodeBeMonitored(destination))){
        	if(TOS_NODE_ID==4&&destination==0)
        	dbg("IDS-StatisticsMngrI","Snooped packet from %d, destined to %d\n",source, destination);
        	msg = signal StatisticsMngrI.destinationMonitored(msg,len, getPosById(destination));
        }
    	
    	return msg;
	}

	event message_t * AMTapI.send(am_id_t type, message_t *msg, uint8_t len, am_id_t id)
	{
		am_addr_t destination = call AMPacket.destination(msg);
		am_addr_t source = call AMPacket.source(msg);
    	dbg("IDS-StatisticsMngr","Send packet from %d, destined to %d\n",source, destination);
    	if(destination != 65535){
    		outgoing_msg_count++;
    	
	        if(call NeighListI.isNodeBeMonitored(destination)){
	            msg = signal StatisticsMngrI.destinationMonitored(msg,len, getPosById(destination));
	        }
        
        }
    	return msg;
	}
	
	bool isRoot(uint16_t node_id)
	{
		if((node_id % ROOTS_MOD)==ROOT_ID)
			return TRUE;
		else
			return FALSE;
	}
	task void reset()
	{
		uint8_t pos=0;
		while(pos < monitoredNodesNum && pos < activeNeighborsNum && neighborsList[pos].avg_rssi >= MONITORING_THRESHOLD && !isRoot(neighborsList[pos].node_id))
		{
			neighborsList[pos].normal_no=0;
			neighborsList[pos].abnormal_no=0;
			neighborsList[pos].congested_no=0;
			neighborsList[pos].detections_no++;
			pos++;
		}
		monitoredNodesNum=pos;
		monitoring=TRUE;
		
		signal StatisticsMngrI.startNonitoringDone(monitoredNodesNum);
	}
	task void sort_task()
	{
		//对邻居节点表进行排序
		uint8_t i,j;
		neighbor_t tmp;
		for (i=0;i<activeNeighborsNum;i++)
		{
			for(j=i;j<activeNeighborsNum;j++)
			{
				if(neighborsList[i].avg_rssi <= neighborsList[j].avg_rssi || isRoot(neighborsList[i].node_id))
				{
					atomic
					{
						memcpy(&tmp,&neighborsList[i],sizeof(neighbor_t));
						memcpy(&neighborsList[i],&neighborsList[j],sizeof(neighbor_t));
						memcpy(&neighborsList[j],&tmp,sizeof(neighbor_t));
					}
				}
			}
		}
		signal StatisticsMngrI.sortDone();
	}
	
	command void StatisticsMngrI.init()
	{
		activeNeighborsNum=0;
		monitoredNodesNum=0;
	}
	
	command void StatisticsMngrI.startMonitoring(uint8_t num)
	{
		monitoredNodesNum=num;
		post reset();
	}
	
	command void StatisticsMngrI.stopMonitoring()
	{
		monitoring=FALSE;
	}

	command neighbor_t * StatisticsMngrI.getNode(uint8_t position)
	{
		return &neighborsList[position];
	}
	
	command uint16_t StatisticsMngrI.outgoing_msg()
	{
		return outgoing_msg_count;
	}

	command uint16_t StatisticsMngrI.incoming_msg()
	{
		return incoming_msg_count;
	}

	command uint8_t StatisticsMngrI.monitoredNodesNum()
	{
		return monitoredNodesNum;
	}

	command void StatisticsMngrI.sort()
	{
		post sort_task();
	}

	
    command void StatisticsMngrI.dump()
    {
    	uint8_t pos;
    	dbg("IDS-StatisticsMngrDump","-----------------------Neighbor List-------------------------\n");
    	dbg("IDS-StatisticsMngrDump","node_id hello_num avg_rssi detections avg_error avg_traffic | normal  abnormal  congested\n");
        
        for(pos=0; pos < activeNeighborsNum; pos++)
        {
        	neighbor_t n = neighborsList[pos]; 
        	if(pos == monitoredNodesNum)
            {
                dbg("IDS-StatisticsMngrDump","------------------------------------------------------------------------------\n");
        	}  
            dbg_clear("IDS-StatisticsMngrDump","%14d%10d%10d%10d%10d%11d      |%4d%10d%10d\n",
                n.node_id, n.hello_no, n.avg_rssi, n.detections_no, n.avg_error,
                n.avg_traffic,n.normal_no,n.abnormal_no,n.congested_no);    
        } 
    }  


	command uint8_t NeighListI.size(){
		return activeNeighborsNum;
	}

	command neighbor_t * NeighListI.getNeighById(uint16_t node_id)
	{
		uint8_t pos=getPosById(node_id);
		if (pos != activeNeighborsNum)
		{
			return &neighborsList[pos];
		}
		else
		{
			return NULL;
		}
	}

	command neighbor_t * NeighListI.getNeighByPos(uint16_t position){
		return &neighborsList[position];
	}
	
	//如果已经存在的节点更新了其rssi，则更新邻居表
	command error_t NeighListI.update(uint16_t node_id, int16_t rssi){
		uint8_t pos=getPosById(node_id);
		if(rssi < MONITORING_THRESHOLD)
		{
			return FAIL;
		}
		if(pos == MAX_NEIGHBORS_NO)
		{
			//如果邻居节点表已经存满
			//1. 删除比这个节点增益更小的节点
			//2. 丢弃
		}
		else if(pos == activeNeighborsNum)
		{
			//如果是新节点，则新增一个节点记录
			dbg("IDS-NeighList","Find new neighbor,node_id is %d.Now %d Neighbors\n",node_id,activeNeighborsNum);
			atomic
			{
				neighborsList[pos].node_id=node_id;
				neighborsList[pos].hello_no=1;
				neighborsList[pos].avg_rssi=rssi;
				neighborsList[pos].detections_no=0;
				neighborsList[pos].avg_error=0;
				neighborsList[pos].avg_traffic=0;
				activeNeighborsNum++;
			}
		}
		else
		{
			//如果是已有节点，则更新节点数据
			atomic
			{
				int16_t old_rssi=neighborsList[pos].avg_rssi;
				int16_t old_hello_no=neighborsList[pos].hello_no;
				neighborsList[pos].hello_no++;
				//平均信号强度取20次中的平均值
				if(old_hello_no > 20)
				{
					neighborsList[pos].avg_rssi=(old_rssi*20+rssi)/(21);
				}
				else
				{
					neighborsList[pos].avg_rssi=(old_rssi*old_hello_no+rssi)/(old_hello_no+1);
				}
			}
		}
		
		return SUCCESS;
	}

	command bool NeighListI.isNodeBeMonitored(uint16_t node_id){
		
		uint8_t pos;
		if (!monitoring)
		{
			return FALSE;
		}
			
		for(pos=0;pos<monitoredNodesNum;pos++)
		{
			
			if(node_id == neighborsList[pos].node_id)
			{
				return TRUE;
			}
			
		}
		return FALSE;
	}
}