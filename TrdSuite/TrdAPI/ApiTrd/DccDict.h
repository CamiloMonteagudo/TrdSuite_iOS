#pragma once

#include "dict.h"

class CKeyWordEntry;
class CDccDict;

// Especializacion de la CSimpleCache para los CKeyWordEntry
template<>
class CSimpleCache<CKeyWordEntry>: public CMapSZ<CKeyWordEntry*>
	{
	public:

	typedef CKeyWordEntry ITEM;
	//typedef typename CMap<CKeyWordEntry*>::Const_Iterator Const_Iterator;
	
	// añade una clave a la cache indicando su indice (para cargar los datos despues
	// cuando haga falta)
	inline void Add(LPCSTR aKey, long aIndex)
		{
		CMapSZ<CKeyWordEntry*>::Add(aKey, (CKeyWordEntry*)(aIndex + 1)); // el +1 es para que 0 no se confunda con NULL
		}

#define KEYS_ONLY 1
#define KEYS_AND_DATA 2
	void Fill(int /*aWhat*/)
		{
		/*for(int i=0; i<m_Dict->GetCount(); i++)
			{
			CStringA sKey;
			DATA* Data = NULL;

			if (aWhat == KEYS_ONLY)
				{
				m_Dict->GetKeyAt(i, sKey);

				// inicialmente lo que se guarda en la cache es el indice de la clave
				Add(sKey, i);
				}
			else
				{
				CStringA sData;
				m_Dict->GetAt(i, &sKey, &sData);

				Data = new DATA(sData);
				CMap<DATA*>::Add(sKey, Data);
				}
			}*/
		}

	void AfterLoad()
		{
		//Fill(KEYS_ONLY);
		}

	inline bool IsKey(LPCSTR aKey) const
		{
		return CMapSZ<CKeyWordEntry*>::Exists(aKey);
		}

	bool GetKey(CDccDict* aDict, LPCSTR aKey, CKeyWordEntry* &aData);

	void DeleteAll()
		{
		/*for(Const_Iterator it = CMap<DATA*>::begin(); it != CMap<DATA*>::end(); it++)
			{
			DWORD index = (DWORD)it->second;
			if (index > INDEX_LIMIT)
				delete it->second;
			}*/

		CMapSZ<CKeyWordEntry*>::RemoveAll();
		}
	};

class CDccDict
	{
	int iCount;
	CFile* iFile;
	bool   iIsOpen;
	CSimpleCache<CKeyWordEntry> iCache;
	// en la cache se guarda el puntero a cada keyword, o el indice a este si no ha sido cargado
	CIntArray              m_arrKeyOff;     // desplazamiento en el fichero de cada keyword
	CPointerArray<CKeyWordEntry> m_arrKeyWord;    // puntero a cada keyword segun su indice, si el 
		// keyword aun no ha sido cargado entonces esta en NULL

	public:
	CDccDict(LPCSTR /*aName*/)
		{
		iCount = 0;
		iFile = NULL;
		iIsOpen = FALSE;
		}

	~CDccDict(void)
		{
		Close();
		}

	CStringA GetFileName()
		{
		return iFile->iFileName;
		}

	void Close()
		{
		// los KeyWord estan en el FastHeap y no hay que destruirlos
		m_arrKeyWord.RemoveAll();

		if (iIsOpen)
			{
			delete iFile;
			iFile = NULL;
			}

		iIsOpen = FALSE;
		}

	bool Load(const CStringA& aFileName);

	// Obtiene los datos de una clave
	inline bool GetKey(const TDictKey& aKey, CKeyWordEntry* &aData)
		{
		return iCache.GetKey(this, aKey.c_str(), aData);
		}

  CKeyWordEntry* GetDataAt(TInt aIdx);
	};

