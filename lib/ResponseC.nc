#include "IDS.h"
configuration ResponseC{
	provides interface ResponseI;
}
implementation{
	components ResponseM;
	ResponseI=ResponseM;
	components new QueueC(detection_t,DETECTION_QUEUE_SIZE) as Queue;
	components IDS_SwapMsgC;
	ResponseM.IDS_SwapMsgI->IDS_SwapMsgC;
	ResponseM.DetectionQueue->Queue;
}