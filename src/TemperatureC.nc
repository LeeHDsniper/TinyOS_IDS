/*
 * Temperature程序配置组件
 */
 /**
 * Temperature配置
 *
 * @author 李浩
 * @date   2017-4-27
 */
#include "printf.h"
#include "Ctp.h"
#include "IDS.h"
configuration TemperatureC
{
}
implementation
{
	components TemperatureM,MainC,LedsC;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as AttackTimer;
	components new DemoSensorC() as Temp;
	components CollectionC as Collector;
	components ActiveMessageC;
	components new CollectionSenderC(COLLECTION_ID);
	components SerialActiveMessageC;
	components new SerialAMSenderC(COLLECTION_ID);
	components RandomC;
	
	TemperatureM.Boot->MainC.Boot;
	TemperatureM.Timer0->Timer0;
	TemperatureM.AttackTimer->AttackTimer;
	TemperatureM.Leds->LedsC;
	TemperatureM.TempSensor->Temp;
	TemperatureM.RadioControl->ActiveMessageC;
	TemperatureM.SerialControl->SerialActiveMessageC;
	TemperatureM.RoutingControl->Collector;
	TemperatureM.Send->CollectionSenderC;
	TemperatureM.RootControl->Collector;
	TemperatureM.CtpInfo->Collector;
	TemperatureM.CollectionPacket->Collector;
	TemperatureM.SerialSend-> SerialAMSenderC.AMSend;
	TemperatureM.Receive->Collector.Receive[COLLECTION_ID];
	TemperatureM.Random->RandomC;
	TemperatureM.Intercept->Collector.Intercept[COLLECTION_ID];
	components IDS_SchedulerC as IDS;
	
}