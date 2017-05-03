 /*
 * 该配置组件配置了DetectionManger如何工作
 */
 /**
 * DetectionMangerBrigeC组件
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "IDS.h"
configuration DetectionMangerBrigeC
{
	provides interface DetectionEngineI;
	provides interface DetectionManagerI;
	//provides interface StatisticsMngrI;
	//uses interface StatisticsMngrI;
	//uses interface ResponseI;
}
implementation
{
    
	components DetectionManagerBrigeM as BrigeM;
	components SelectiveForwardingEngineM as DetectionEngine1;
	components StatisticsMngrC;
	BrigeM.DetectionEngineI->DetectionEngine1.DetectionEngineI;
	BrigeM.StatisticsMngr->StatisticsMngrC;
	
	DetectionEngineI=BrigeM.DetectionEngine;
	DetectionManagerI=BrigeM.DetectionManager;
	//StatisticsMngrI=BrigeM.StatisticsMngrI;
	
	components new TimerMilliC() as Timer0;
	components ResponseC;
	components CtpPacketCacheC;
	components ForgedCtpPacketC;
	DetectionEngine1.Timer0->Timer0;
	DetectionEngine1.ResponseI->ResponseC;
	DetectionEngine1.PacketCacheI->CtpPacketCacheC;
	DetectionEngine1.ForgedCtpPacketI->ForgedCtpPacketC;
	DetectionEngine1.StatisticsMngrI-> BrigeM.StatisticsMngrI;
}