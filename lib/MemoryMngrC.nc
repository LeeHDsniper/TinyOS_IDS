#include "IDS.h"
configuration MemoryMngrC{
	provides interface MemoryMngrI;
}
implementation{
	components new MemoryMngrM(MEMORY_MNGR_SIZE / 7) as MemoryMngr;
	MemoryMngrI = MemoryMngr;
}