
#include "WinUtil.h"


char STAnsi::iTempBuffer[TEMP_BUFFER_SIZE];

#ifndef STD_STRING_HAS_REFCOUNT

TStringDataT<STAnsi> NullStringDataT(ENullStrData);

TStringDataT<STAnsi>* STAnsi::m_pNullStrData = &NullStringDataT;

#endif

CStringA CANull;


TInt _CString_iExpand = 4;

void InitCStringBuffers()
	{
	}

void FreeCStringBuffers()
	{
	}
