 /*
 * 该接口定义了检测引擎管理器的运行
 */
 /**
 * DetectionManagerI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
interface DetectionManagerI
{
	command bool engine_selected(uint8_t engine_no);//该命令实现对需要激活的检测引擎的选择，engine_no定义了引擎编号，如果成功返回TRUE
	command uint8_t enginesCount();                 //该命令返回所有检测引擎的数量
}