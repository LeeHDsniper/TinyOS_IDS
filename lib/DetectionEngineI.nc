 /*
 * 该接口定义了一个检测引擎应当包含哪些内容
 */
 /**
 * DetectionEngineI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
interface DetectionEngineI
{
	command void start();                      //启动检测引擎
	event void startDone(uint16_t run_time);   //当引擎启动完成后，触发该信号，run_time参数定义了引擎需要运行多长时间
	command void stop();                       //停止检测引擎
	event void stopDone();                     //当引擎停止时，触发该信号
	command bool isRunning();                  //如果引擎在运行，返回TRUE，否则返回FALSE
	command void evaluate();                   //启动评估过程
	event void evaluateDone(uint8_t alerts_no);//当评估完成后，触发该信号，alerts_no参数定义了由该引擎发出报警信号的次数
	
}
