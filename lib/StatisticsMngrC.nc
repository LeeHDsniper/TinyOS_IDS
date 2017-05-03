configuration StatisticsMngrC{
	provides
	{
		interface NeighListI;
		interface StatisticsMngrI;
	}
}
implementation{
	components StatisticsMngrM;
	NeighListI=StatisticsMngrM;
	StatisticsMngrI=StatisticsMngrM;
	components ForgedActiveMessageC;
	StatisticsMngrM.AMTapI->ForgedActiveMessageC;
	StatisticsMngrM.AMPacket->ForgedActiveMessageC;
	components TossimActiveMessageC;
   	StatisticsMngrM.TossimPacket -> TossimActiveMessageC.TossimPacket;
}