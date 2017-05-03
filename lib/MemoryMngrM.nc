 /*
 * 该组件实现了MemoryMngrI接口以便对内存进行管理
 */
 /**
 * MemoryMngrM组件
 *
 * @author 李浩
 * @date   2017-4-27
 */
generic module MemoryMngrM(uint16_t mem_size)
{
	provides interface MemoryMngrI;
}
implementation
{
	size_t memory[mem_size];
	command void * MemoryMngrI.malloc(size_t size)
	{
		return memory;
	}
}