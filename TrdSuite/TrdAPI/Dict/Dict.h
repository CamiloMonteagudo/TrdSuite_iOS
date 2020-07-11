/*
 ============================================================================
 Name		: Dict.h
 Author	  : 
 Version	 : 1.0
 Copyright   : Your copyright notice
 Description : CDict declaration
 ============================================================================
 */

#ifndef DICT_H
#define DICT_H

// INCLUDES
#include "WinUtil.h"
#include "DictTypes.h"
#include "DictIndex.h"
#include "DictError.h"
#include "DictData.h"

// Chequea si una cadena es valida como clave de diccionario
inline bool CheckKey(LPCSTR aKey)
	{
	for(; *aKey != 0; aKey++)
		{
		if (((BYTE)*aKey) < 32)
			return FALSE;
		}

	return TRUE;
	}

template<class DATA>
class CCachedItem;


typedef struct TagDICC_HEADER
  {
  char  	ID[6];       // Identificador de los datos
  TUint32	Ver;         // Versión de la implentación del diccionario
  TUint32	Size;        // Tamaño de la estructura que mantiene los datos                  
  TInt32 	Src;         // Código (Postal) del idioma fuente                   
  TInt32	Dest;        // Código (Postal) del idioma destino                  
  TInt32 	Flgs;        // Banderas que definen los atributos
  TUint32	MaxSize;     // Tamaño máximo del fichero mapeado
  TUint32	DatSize;     // Tamaño de los datos
  TUint32	MemSize;     // Tamaño de la memoria reservada
  TUint32	NumRec;      // Número de record totales
  TUint32	DelRec;      // Número de record borrados
  TUint32	IdxKey1;     // Ultima modificación del índice clave1
  TUint32	IdxKey2;     // Ultima modificación del índice clave2
  char  	IdObj[20];   // Nombre del objeto (Para identificar si esta cargado)
  TUint32	Reserv1;     // Reservado para uso futuro
  TUint32	Reserv2;     // Reservado para uso futuro
  } TDICC_HEADER;
  

  //--------------------------------------------------------------------------
  // Valores de retorno para la función 'FindFrase'
  //--------------------------------------------------------------------------
  #define FRS_NOFOUND     0
  #define FRS_SEMIFOUND   1
  #define FRS_FULLFOUND   2


  //--------------------------------------------------------------------------
  // indices para GetHeaderField y SetHeaderField
  //--------------------------------------------------------------------------
  #define HDR_DIC_ID      1
  #define HDR_DIC_VER     2
  #define HDR_SIZE        3
  #define HDR_SRC_ID      4
  #define HDR_DEST_ID     5
  #define HDR_DIC_FLGS    6
  #define HDR_MAX_REC     7
  #define HDR_DAT_SIZE    8
  #define HDR_MEM_SIZE    9
  #define HDR_MUM_REC     10
  #define HDR_DEL_REC     11
  #define HDR_MOD_KEY1    12
  #define HDR_MOD_KEY2    13
  #define HDR_OBJ_ID      14
  #define HDR_ESP_ID      15
  #define HDR_TYPE_ID     16
  #define HDR_MODE        17

  #define HDR_MAX_FLD     17
  
#define FLAG_NOHIDE   0x00000010
/*
#define DICC_FILE				1
#define DICC_READONLY		2
#define DICC_MEM        4
#define DICC_LOADKEYS   32
#define DICC_CACHEKEYS  64
  */

class CActionPhrase;
/*template<class DATA, class CACHE>
class CDictT;*/

// Cache que guarda el indice mas cercano a cada elemento, si existe y los datos de la clave.
// Esta hecha para diccionarios que necesiten los indices aun cuando la clave no exista
// (por ejemplo en la busqueda de frases) y que no tengan todas las claves cargadas.
// Se guardan tanto las claves que existen, como las que no existen (para no leer de fichero
// cuando se pide repetidas veces una clave que no existe)
// Es la cache que usan los diccionarios por defecto.
template<class DATA>
class CIndexedCache: public CMap<CCachedItem<DATA>*>
	{
	public:
	typedef CCachedItem<DATA> ITEM;

	void AfterLoad()
		{
		}

	template<class DICT>
	inline bool IsKey(DICT* aDict, const CStringA& aKey)
		{
		int idx;
		return aDict->FindIndex(aKey, idx);
		}

	/*inline void Add(CStringA sKey, DATA* Data, int aIndex, bool aFound)
		{
		ITEM* cachedItem;
		cachedItem = new ITEM(Data, aIndex, aFound);

		Add(sKey, cachedItem);
		}*/
	};

// Cache mas simple que no guarda los indices ni si el elemento existe o no.
// Esta hecha para caches que carguen todas las claves de una vez, asi lo que no
// exista en la cache, es que no existe en el diccionario tampoco, por tanto
// no se guardan las claves que no existen, lo que es mas rapido y consume menos memoria.
// Si los datos son NULL es que la clave no tiene datos.
// Si los datos son menores a un numero dado, es que aun no se ha cargado ese dato.
// y el numero es el indice del elemento del diccionario donde estan los datos.
template<class DATA>
class CSimpleCache: public CMap<DATA*>
	{
	public:
#define INDEX_LIMIT 50000

	typedef DATA ITEM;
	typedef typename CMap<DATA*>::Const_Iterator Const_Iterator;
	
	// añade una clave a la cache indicando su indice (para cargar los datos despues
	// cuando haga falta)
	inline void Add(const CStringA& aKey, int aIndex)
		{
		CMap<DATA*>::Add(aKey, (DATA*)(aIndex + 1)); // el +1 es para que 0 no se confunda con NULL
		}

#define KEYS_ONLY 1
#define KEYS_AND_DATA 2
	template<class DICT>
	void Fill(const DICT* aDict, int aWhat)
		{
		for(int i=0; i<aDict->GetCount(); i++)
			{
			CStringA sKey;
			DATA* Data = NULL;

			if (aWhat == KEYS_ONLY)
				{
				aDict->GetKeyAt(i, sKey);

				// inicialmente lo que se guarda en la cache es el indice de la clave
				Add(sKey, i);
				}
			else
				{
				CStringA sData;
				aDict->GetAt(i, &sKey, &sData);

				Data = new DATA(sData);
				CMap<DATA*>::Add(sKey, Data);
				}
			}
		}

	template<class DICT>
	void AfterLoad(const DICT* aDict)
		{
		Fill(aDict, KEYS_ONLY);
		}

	inline bool IsKey(const CStringA& aKey) const
		{
		return CMap<DATA*>::Exists(aKey);
		}

	template<class DICT>
	bool GetKey(const DICT* aDict, const CStringA& aKey, DATA* &aData)
		{
		DATA** pData = CMap<DATA*>::FindPtr(aKey);
		if (pData == NULL)
			{
			aData = NULL;
			return FALSE; // la clave no existe en la cache ni en el diccionario
			}

		// la clave existe en la cache
		if (*pData == NULL)
			{
			// la clave existe pero no tiene datos (esto puede ocurrir al menos en un dict de reduccion)
			aData = NULL;
			return TRUE;
			}

		DWORD index = (DWORD)*pData;
		if (index < INDEX_LIMIT)
			{ // es un indice, aun no se han cargado los datos
			TDictData sData;
			aDict->GetDataAt(index-1, sData);

			// crear el item y actualizar la cache
			*pData = new DATA(sData);
			}

		// devolver los datos
		aData = *pData;
				
		return TRUE;
		}

	void DeleteAll()
		{
		for(Const_Iterator it = CMap<DATA*>::begin(); it != CMap<DATA*>::end(); it++)
			{
			DWORD index = (DWORD)it->second;
			if (index > INDEX_LIMIT)
				delete it->second;
			}

		CMap<DATA*>::RemoveAll();
		}

	};


// CLASS DECLARATION
  
/**
 *  CDict
 * 
 */
// DATA representa el tipo de dato de este diccionario, en caso de que se especifique 
// debe ser una clase que tenga un constructor que acepte un CStringA
// solo se usa en el metodo GetKeyT y en la cache, los demas siempre usan TDictData
//template<class DATA>
template<class DATA, class CACHE = CIndexedCache<DATA> >
class CDictT : public CMFCObject
	{

public:	
	CStringF iName;
	typedef typename CACHE::ITEM CACHE_ITEM;
	
protected:
	CFile* iFile;
	TInt   iCount;
	TInt 	 iLastIdx;
	bool	 iIsOpen;
	bool	 iNoHide;
	TInt 	 iFlags;
	bool   iLoadFromStream;	// indica si el diccionario y el indice deben cargarse desde un
													// stream o desde ficheros independientes
	TInt   iBaseOffset;				// desplazamiento dentro del stream donde comienza este diccionario
	TInt   iError;
	TDICC_HEADER iHeader;
	CDictIndex<TRUE>* iIndex;
	CStringA iMasterFileName;
	TInt    iDataLen;					// longitud de los datos del ultimo registro buscado

	int			iIdxXXXX_a;				// indice de la palabra "xxxx a"
	int			iIdxXXXXA;				// indice de la palabra "xxxxA"
	DWORD		iKeysPerChar;			// cantidad de claves por caracter en el rango "xxxx a"-"xxxxA"
	bool    iUseCache;
	CACHE   iCache;

public:
	CStringA iDebugName;
	//friend class CDictIndex;
	
	// Constructors and destructor
	CDictT(LPCSTR aName)
		{
		iDebugName = aName;
		iCount = 0;
		iLastIdx = 0;
		iIsOpen = FALSE;
		iNoHide = FALSE;
		iFlags = 0;
		iError = DICT_NO_ERROR;
		iIndex = NULL;
		iFile = NULL;
		iLoadFromStream = FALSE;
		iBaseOffset = 0;
		iIdxXXXX_a = iIdxXXXXA = -1;
		iKeysPerChar = 0;
		iDataLen = 0;
		iUseCache = FALSE;
		}

	/**
	 * Destructor.
	 */
	~CDictT()
		{
		Close();
		}

	bool Open(const CStringF& aName = CFNull, TInt aFlags = 0);
	bool Load(const CStringA& aName, TInt aFlags = 0)
		{ 
		return Open(aName, aFlags);
		};
	bool OpenFromFile(CArchive &ar);

	void Serialize(CArchive &ar, const CStringA& aDumpTxtFile)	
		{
		Serialize(ar, aDumpTxtFile.c_str());
		}

	void Serialize(CArchive &ar, LPCSTR aDumpTxtFile = NULL);

  void Free()		{ Close(); }
	void Close();

#ifdef ACTIVE_SAVE

	bool Save(const CStringA& sFileName);
	bool Save(CArchive& ar, LPCSTR aIndexName = NULL, LPCSTR aDumpTxtFile = NULL);
	bool Save_(CArchive& ar, LPCSTR aIndexName = NULL, LPCSTR aDumpTxtFile = NULL);

	bool SaveOpt(const CStringA& sFileName);
	bool SaveOpt(CArchive& ar);

	bool SaveDCX(CArray<CActionPhrase>& arrWords);

#endif

  void SetName(const CStringF& /*aName*/) {} // hace falta??
	
  bool IsOpen() { return iIsOpen; }

	static LPCSTR sss;
	/*static void CheckCache(CACHE_ITEM* item)
		{
		if (item->found())
			{
			CStringA s;//(sss);
			s += "_CacheItemFound";
			COUNTER(s.c_str());
			}
		else
			{
			CStringA s;//(sss);
			s += "_CacheItemNoFound";
			COUNTER(s.c_str());
			}
		}*/

	/*class CCheckCache
		{
		public:
		void Action(CACHE_ITEM* item)
			{
			if (item->found())
				{
				CStringA s;//(sss);
				s += "_CacheItemFound";
				COUNTER(s.c_str());
				}
			else
				{
				CStringA s;//(sss);
				s += "_CacheItemNoFound";
				COUNTER(s.c_str());
				}
			}
		};*/

	void ClearCache()
		{
		//TRACE("%s, count = %d, size = %d", iDebugName.c_str(), iCount, iHeader.DatSize);
		//sss = iDebugName.c_str();
		/*CCheckCache checkCache;
		if (iCount < 70000)
			//iCache.ForEach<CheckCache>();
			iCache.ForEach2(checkCache);*/

		iCache.DeleteAll();
		}

	TUint32 GetHdrField(TInt aIdxField) const;
	CStringA GetHdrFieldS(TInt aIdxField) const;
  
  void SetNoHide(bool aNoHide) { iNoHide = aNoHide; }
  
  inline TInt GetNumRec() const { return iCount; }
  inline TInt GetCount() const { return iCount; }

	// Indica si una llave existe
  inline bool IsKey(const TDictKey& aKey)
  	{
		return iCache.IsKey(this, aKey);
  	};

	bool FindSuffix(const TDictKey& s, TDictData& data);
	bool FindPreffix(const TDictKey& s, TDictData& data);
	//TInt FindFrase(const TDictKey& aName);
	//bool IsInitFrase(const TDictKey& Llave);
	bool FindInitFrase(const TDictKey& aName);
	TInt FindNextFrase(const TDictKey& aName);
	
	// Devuelve los datos de una llave
	bool GetKey(const TDictKey& aKey, TDictData& aData);

	bool GetKeyT(const TDictKey& aKey, DATA*& aData);

	// Estos metodos o no se usan en la traduccion o no necesitarian ser publicos, pero lo son porque
	// se usan en el visualizador de diccionarios
  inline void GetKeyAt(TInt aIdx, TDictKey& aKey)
  	{
		//COLLECT_INTERVAL("GetKeyAt");
    GetAt(aIdx, &aKey, NULL); 										// Busca la llave
  	}
		
	// Devuelve la clave y datos de un indice, actualiza la posicion actual
	bool GetAt(TInt aIdx, TDictKey* aName, TDictData* aData);

  virtual void GetDataAt(TInt aIdx, TDictData& aData)
  	{
		//COUNTER("GetRef_GetDataAt");
    GetAt(aIdx, NULL, &aData);   		  						// Obtiene los datos
  	}
		
	// Devuelve el indice mas cercano de una llave y si existe o no,
	// No actualiza la llave actual
	bool FindIndex(const TDictKey& aName, TInt &aIndex)
		{
		return FindIndex(aName, aIndex, 0, iCount-1);
		}

	void GetKeyAtOffset(TDictKey& key, TUint32 aOffset);
	LPCSTR GetFastKeyAtOffset(TUint32 aOffset);
		
protected:

	// los siguientes metodos no se usan en ninguna parte
	/*
	inline bool FindKey(const TDictKey& aName)
		{	return FindIndex(aName, iLastIdx); }

  inline TInt GetLastIndex() { return iLastIdx; }
  inline TInt GetActualPos() { return iLastIdx; }
  inline TInt GetPos() { return iLastIdx; }
  
	bool SetLastIndex(TInt aIdx)
		{ 
		if (aIdx >= 0 && aIdx < iCount)
			{
			iLastIdx = aIdx; 
			return TRUE;
			}
		else 
  		return FALSE;
		}
  inline bool SetActualPos(TInt aPos) { return SetLastIndex(aPos); }

  bool NextIndex()
		{ 
		if (iLastIdx < GetNumRec()-1)
			{
			++iLastIdx;

			return TRUE;
			}
		else 
  		return FALSE;
		}

  bool LastIndex()
		{ 
		if (iLastIdx > 0) 
			{
			--iLastIdx;
			return TRUE;
			}
		else
  		return FALSE;    
		}	

  inline bool Next() 			{ return NextIndex(); }
  inline bool Previous() 	{ return LastIndex(); }
  inline bool First() 		{ return SetLastIndex(0); }
  inline bool Last() 			{ return SetLastIndex(iCount-1); }

  inline bool IsLast() 		{ return (iIsOpen && iLastIdx == iCount-1); }
  inline bool IsFirst() 	{ return (iIsOpen && iLastIdx == 0); }
  
  inline TInt SetActualKey(const TDictKey& aKey)
  	{
    return FindIndex(aKey, iLastIdx) ? iLastIdx : -1;
  	}
		
	inline bool GetActual(TDictKey& aName, TDictData& aData)
		{ 
		return GetRef(&aName, &aData);
		};
	
  */

	// estos se usan pero solo internamente dentro de CDict (son protegidos)
  /*inline bool GetActualKey(TDictKey& aKey)
  	{
		return GetRef(&aKey, NULL);
  	}*/
  
  inline bool GetActualData(TDictData& aData)
  	{
		return GetRef(NULL, &aData);
  	}
  
	bool GetRef(TDictKey* aName, TDictData* aData);

	void HideData(TDictData& aDatos);

	bool FindIndex(const TDictKey& aName, TInt &aIndex, TInt aStart, TInt aEnd);
	
	TInt GetLastError() { return iError; };
	void ResetError() { iError = DICT_NO_ERROR; };

	bool CheckHeader(TUint aFileSize);
	
	inline TInt GetOffset(TInt aIdx) { return iIndex->GetOffset(aIdx); }

	// Devuelve los datos de la clave actual
	// IMPORTANTE!!!!!!!!!!!!
	// solo se puede llamar inmediatamente despues de FindIndex o iIndex->Find
	void GetDataFast(TDictData& aData)
		{
		if (iDataLen > 0)
			{
			GetStreamData(aData, iDataLen);
			HideData(aData);
			}
		}
	
	bool SetStreamOffset(TInt aOffset)
		{
		aOffset += iBaseOffset;
		TInt streamPos = iFile->Seek(aOffset, CFile::begin);
		ASSERT(streamPos == aOffset);
		return TRUE;
		}

	void GetStreamKey(TDictKey& key)
		{
		iFile->ReadAsSZString(key);
		}

	inline LPCSTR GetFastStreamKey()
		{
		return iFile->ReadFastAsSZString();
		}

	void GetStreamData(TDictData& aData, TInt aDataLen)
		{
		LPCSTR sData = aData.GetBuffer(aDataLen + 1);
		iFile->ReadBuffer((LPVOID)sData, aDataLen);

		if (sData[aDataLen-1] == '\x0')
			aDataLen--; // para no incluir el null terminator

		aData.ReleaseBuffer(aDataLen);
		}

	};


typedef CDictT<TDictData> CDict;

// CSimpleDict, clase usada para casos donde no haga falta acceder al diccionario por indice
// ni que este tenga el concepto de palabra actual, ademas las claves se cargan completamente
// en memoria, todo esto unido hace que el diccionario sea muy eficiente.
// Los accesos a las claves y datos deben ser unicamente a traves de los metodos IsKey y GetKey
// el uso de otros metodos debe dar error de compilacion
/*template<class DATA>
class CSimpleDict : public CDictT<DATA,CSimpleCache<DATA>> 
	{ 
	protected:
	CIntArray iArrDataOff;

	public:
	// Obtiene los datos de una clave
	inline bool GetKey(const TDictKey& aKey, DATA* &aData)
		{
		return CDictT<DATA,CSimpleCache<DATA>>::iCache.GetKey(this, aKey, aData);
		}

  virtual void GetDataAt(TInt aIdx, TDictData& aData)
  	{
		if (CDictT<DATA,CSimpleCache<DATA>>::iIndex == NULL)
			{
			int start = iArrDataOff[aIdx];
			int size = iArrDataOff[aIdx+1] - start;
			CDictT<DATA,CSimpleCache<DATA>>::iFile->Seek(start);
			CDictT<DATA,CSimpleCache<DATA>>::iFile->ReadBufferAsCString(aData, size);
			}
		else
			CDictT<DATA,CSimpleCache<DATA>>::GetAt(aIdx, NULL, &aData);   		  						// Obtiene los datos
  	}

	//bool LoadOpt(const CStringA& aFileName);

#ifdef ACTIVE_SAVE
	bool SaveOpt();
#endif

	};*/


template<class DATA, class CACHE>
LPCSTR CDictT<DATA,CACHE>::sss;

#include "DictInl.h"

#endif // DICT_H
