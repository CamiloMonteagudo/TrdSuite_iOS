/*
 ============================================================================
 Name		: DictIndex.h
 Author	  : 
 Version	 : 1.0
 Copyright   : Your copyright notice
 Description : CDictIndex declaration
 ============================================================================
 */

#ifndef DICTINDEX_H
#define DICTINDEX_H

// INCLUDES
#include "DictTypes.h"
#include "DictError.h"


#define DICC_FILE				1
#define DICC_READONLY		2
#define DICC_MEM        4
#define DICC_LOADKEYS   32
#define DICC_CACHEKEYS  64


// Header del indice
typedef struct TagIDX_HDR
  {
  char  	ID[6];       // Identificador de los datos
  TUint32 Ver;         // Versión de la implementación de los índices
  TUint32 Size;        // Tamaño de la estructura que mantiene los datos                  
  TUint32 Flgs;        // Banderas que definen los atributos
  TUint32 MaxSize;     // Tamaño máximo del fichero mapeado
  TUint32 DatSize;     // Tamaño de los datos
  TUint32 MemSize;     // Tamaño de la memoria reservada
  TUint32 NumRec;      // Número de record totales                        
  TUint32 IdxKey1;     // Clave 1 para la sincronización                  
  TUint32 IdxKey2;     // Clave 2 para la sincronización
  char  	IdObj[20];   // Nombre del objeto (Para identificar si esta cargado)
  TUint32 sIdx[256];   // SubIndice donde comienza cada letra          
  TUint32 Reserv1;     // Reservado para uso futuro
  TUint32 Reserv2;     // Reservado para uso futuro
  } TIDX_HDR;
  

// CLASS DECLARATION

/**
 *  CDictIndex
 * 
 */

template<bool USE_CACHE>
class CDictIndex
	{
private:
	TIDX_HDR iHeader;
	CIntArray iIndex;
	CArrayValue<LPCSTR> m_Keys;		// array de las claves para cada indice, se llena en demanda
																// solo se usa si USE_CACHE == TRUE

public:
	// Constructors and destructor

	CDictIndex():iIndex()
		{
		}

	~CDictIndex()
		{
		}

	TUint Open(CFile* aIndexFile, bool aLoadFromStream)
		{
		if (aIndexFile == NULL || !aIndexFile->isOpen())
			{
			return CAN_NOT_OPENFILE_IDX;
			}
	
		TInt nFileSize = aIndexFile->GetLength();
		if (nFileSize < (TInt)sizeof(TIDX_HDR))
			{
			TRACE("BAD_OPENFILE_IDX_1");
			return BAD_OPENFILE_IDX;
			}

		// Datos que contiene el header
		aIndexFile->ReadBuffer(&iHeader, sizeof(TIDX_HDR));
	
		TUint result = CheckHeader(nFileSize);
		if (result)
			return result;

		if (aLoadFromStream)
			{
			TInt pos = aIndexFile->GetPosition();
			if (pos + (TInt)iHeader.DatSize - (TInt)sizeof(iHeader) > nFileSize)
				{
				TRACE("BAD_OPENFILE_IDX_2");
				return BAD_OPENFILE_IDX;
				}		
			}
		else if ((TInt)iHeader.DatSize != nFileSize)
			{
			TRACE("BAD_OPENFILE_IDX_3");
			return BAD_OPENFILE_IDX;
			}
	
		// Leer todo el indice a memoria
		TUint32 indexSize = iHeader.DatSize - sizeof(TIDX_HDR);
		if (indexSize > 0)
			{
			//COLLECT_INTERVAL("READ_INDEX"); //0.27 al desconectar unidad
			TInt numItems = indexSize/4;
			iIndex.SetSize(numItems, FALSE);
			aIndexFile->ReadBuffer(iIndex.GetBuffer(), indexSize);

			if (USE_CACHE)
				m_Keys.SetSize(numItems, TRUE);
			}

		return result;
		}

	void Close()
		{
		m_Keys.Close();
		iIndex.Close();
		}

#ifdef ACTIVE_SAVE

	bool Save(const CStringA& sFileName, int* arrIndexs)
		{
		CFile file(sFileName, CFile::modeWrite);
		CArchive ar(&file, CArchive::store);

		return Save(ar, arrIndexs);
		}

	bool Save(CArchive& ar, int* arrIndexs)
		{
		ar.WriteBuffer(&iHeader, sizeof(iHeader));

		ar.WriteBuffer(arrIndexs, iHeader.NumRec*sizeof(arrIndexs[0]));

		return TRUE;
		}

#endif

	// retorna la llave de indice aIndex, primero la busca en la cache y si no esta la
	// busca en el diccionario
	template<class DICT>
	inline LPCSTR GetKeyAt(DICT* aDict, int aIndex)
		{
		ASSERT(CFastHeap::isEnabled());

		if (!USE_CACHE)
			return aDict->GetFastKeyAtOffset(iIndex[aIndex]);
		else
			{
			LPCSTR szKey = m_Keys[aIndex];
			if (szKey == NULL)
				szKey = m_Keys[aIndex] = aDict->GetFastKeyAtOffset(iIndex[aIndex]);
			ASSERT(szKey != NULL);
			return szKey;
			}
		}

	template<class DICT>
	inline bool Find(DICT* aDict, const TDictKey& aKey, TInt* aIdx)
		{
		return Find(aDict, aKey, aIdx, 0, iHeader.NumRec - 1);
		}

	template<class DICT>
	bool Find(DICT* aDict, const TDictKey& aKey, TInt* aIdx, int aLowerBound, int aUpperBound)
		{
		//COLLECT_INTERVAL("Index::Find");

		if (aUpperBound >= (int)iHeader.NumRec)
			aUpperBound = (int)iHeader.NumRec - 1;

		if (aLowerBound > aUpperBound)
			{ // rango vacio
			*aIdx = -1;
			return FALSE;
			}

		CStringA csKey;  // solo se usa cuando no esta activo el FastHeap
		LPCSTR szKey;
		int ret = 0;
		//*aIdx    = -1;

	#if 1  
		// metodo tradicional de busqueda binaria
		int lo = aLowerBound;
		int hi = aUpperBound;
		int mid = 0;
		//int aLen = aKey.GetLength();
		LPCSTR szaKey = aKey.c_str();

		while (lo <= hi)
			{
			mid = (lo + hi) >> 1;

			if (CFastHeap::isEnabled())
				szKey = GetKeyAt(aDict, mid);
			else
				{
				aDict->GetKeyAt(mid, csKey);
				szKey = csKey.c_str();
				}

			//ret = strFastCompare(szaKey, szKey, aLen);
			ret = strcmp(szaKey, szKey);
			//ret = memcmp(szaKey, szKey, aLen);
			//ret = aKey.Compare(szKey);

			if (ret < 0) // la llave buscada es menor que la central
				hi = mid - 1;
			else if (ret > 0) // la llave buscada es mayor que la central
				lo = mid + 1;
			else
				{ // se encontro la llave
				*aIdx = mid;

				return TRUE;
				}
			}

		// si llega aqui es que la clave no existe, en este caso la llave retornada debe ser 
		// la inmediata mayor que la buscada, a menos que la buscada sea mayor que la ultima
		if (ret > 0 && mid < (int)iHeader.NumRec - 1)
			mid++; 

		*aIdx = mid;
			
		return FALSE;

	#endif

		/*
		//int num  = hi - lo + 1;
		//int half; 
		while (lo <= hi)
			{
			half = num/2;
			if (half != 0)
				{
				mid = lo + (num & 1 ? half : (half - 1));

				iDict->GetKeyAtOffset(key, iIndex[mid]);
				ret = aKey.Compare(key);

				if (ret < 0) // la llave buscada es menor que la actual
					{
					hi = mid - 1;
					num = num & 1 ? half : half-1;
					}
				else if (ret > 0)  // la llave buscada es mayor que la actual
					{
					lo = mid + 1;
					num = half;
					}
				else
					{ // se encontro la llave
					*aIdx = mid;
					if (iDict->iFlags & DICC_CACHEKEYS)
						iCachedKeys.Add(aKey, *aIdx | CACHE_KEY_FOUND);

					return TRUE;
					}
				}
			else if (num != 0)
				{ // solo queda una clave en el indice para chequear
				iDict->GetKeyAtOffset(key, iIndex[lo]);

				ret = aKey.Compare(key);
			
				*aIdx = ( ret<=0 )? lo : lo+1;

				if (iDict->iFlags & DICC_CACHEKEYS)
					{
					TInt idx = *aIdx;
					iCachedKeys.Add(aKey, (ret == 0) ? idx | CACHE_KEY_FOUND : idx);
					}
			
				return (ret == 0);
				}
			else
				break;
			}

		// devolver el indice mas cercano
		*aIdx = mid;
  
		if (iDict->iFlags & DICC_CACHEKEYS)
  		iCachedKeys.Add(aKey, *aIdx);
  
		return FALSE;*/
		}	

	inline TInt GetOffset(TInt aIdx)
		{
		if (aIdx >= (TInt)iHeader.NumRec)               // Indice muy grande
			return 0;
		
		return iIndex[aIdx];
		}
	
  inline TInt GetNumRec()       // Obtiene el número de records
    { 
    return iHeader.NumRec;
    }

private:

	TUint CheckHeader(int nb)
		{
		// Verifica que el formato es correcto
		if (
			iHeader.ID[0] != 'I' || iHeader.ID[1] != 'D' || iHeader.ID[2] != 'X' || 
			iHeader.ID[3] != '_' || iHeader.ID[4] != 'D' || iHeader.ID[5] != 0   ||
			nb < (TInt)sizeof(TIDX_HDR) || 
			iHeader.DatSize < sizeof(TIDX_HDR) ||  
			iHeader.MemSize < iHeader.DatSize) 
			{
			TRACE("BAD_IDX_TYPE: nb=%d, iHeader.DatSize=%d, iHeader.MemSize=%d, sizeof(TIDX_HDR)=%d", nb, iHeader.DatSize, iHeader.MemSize, sizeof(TIDX_HDR));
			return BAD_IDX_TYPE;
			}

		// Verifica que la versión sea la adecuada
		if (iHeader.Ver != 1000 || iHeader.Size != sizeof(TIDX_HDR)) 
			{
			TRACE("BAD_IDX_VERSION");
			return BAD_IDX_VERSION;
			}

		return DICT_NO_ERROR;
		}

	};

#endif // DICTINDEX_H
