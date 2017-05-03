 /*
 * 该接口定义了在数据包存储过程中的简单的内存管理功能
 */
 /**
 * MemoryMngrI接口
 *
 * @author 李浩
 * @date   2017-4-27
 */
interface MemoryMngrI
{
	//该命令返回指向未格式化内存的指针
	command void* malloc(size_t size);
}