
#include "WinUtil.h"


#define GENERAL_HEAP_BIG 3000*1024
#define WORD_HEAP_BIG     500*1024

#define GENERAL_HEAP_MEDIUM 1500*1024
#define WORD_HEAP_MEDIUM     300*1024

CFastHeap* CFastHeap::gFirstHeap = NULL;
CFastHeap* CFastHeap::gCurrHeap = NULL;
bool CFastHeap::gEnabled = FALSE;

CFastHeap* CFastHeap::NewHeap()
	{
	// El primer heap se crea grande, los demas son mas pequeños
	if (gFirstHeap == NULL)
		gCurrHeap = new CFastHeap(GENERAL_HEAP_BIG, WORD_HEAP_BIG);
	else
		gCurrHeap = new CFastHeap(GENERAL_HEAP_MEDIUM, WORD_HEAP_MEDIUM);

	return gCurrHeap;
	}
