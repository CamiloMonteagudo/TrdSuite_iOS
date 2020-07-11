
// PACK_CACHE hace que la cache ocupe menos memoria (4 bytes menos)
// pero es un poco mas lenta
#define PACK_CACHE

template<class DATA>
class CCachedItem
	{
	protected:
	DWORD mIndex;

#ifndef PACK_CACHE
	bool mFound;
#endif

	public:
	const DATA* mData;

	CCachedItem():mIndex(0),mData(NULL)
		{
		}

#ifdef PACK_CACHE
	CCachedItem(const DATA* aData, int aIndex, bool aFound):mIndex((aIndex << 1) | aFound),mData(aData)
#else
	CCachedItem(const DATA* aData, int aIndex, bool aFound):mIndex(aIndex),mFound(aFound),mData(aData)
#endif
		{	}

#ifdef PACK_CACHE
	CCachedItem(int aIndex, bool aFound):mIndex((aIndex << 1) | aFound),mData(NULL)
#else
	CCachedItem(int aIndex, bool aFound):mIndex(aIndex),mFound(aFound),mData(NULL)
#endif
		{	}

	~CCachedItem()
		{
		if (mData)
			delete mData;
		}

	inline bool found()
		{
#ifdef PACK_CACHE
		return mIndex & 1;
#else
		return mFound;
#endif
		}

	inline DWORD index()
		{
#ifdef PACK_CACHE
		return mIndex >> 1;
#else
		return mIndex;
#endif
		}
	};


//***************************************************************************
//*                                CDict                                    *
//***************************************************************************

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::Open(const CStringF& aName, TInt aFlags)
	{
	//DUMP_INTERVALS("CDict::Open");
	iCount = 0;
	iFlags = aFlags;
	iName = aName;
	
	if (!iLoadFromStream)
		{
		if (iFile == NULL)
			iFile = new CFile(aName, CFile::modeRead);

		if (!iFile->isOpen())
			{
	    iError = CAN_NOT_OPENFILE;
	    LOG_ERROR("Dictionary not found: %s", CS2SZ(iName));
	    //ASSERT(FALSE);
	    return FALSE;
			}
		}
	
	if (iFile == NULL || !iFile->isOpen())
		{
	  LOG_ERROR("CDict: can't open file");
    iError = CAN_NOT_OPENFILE;
    ASSERT(FALSE);
    return FALSE;
		}
	
	TInt nFileSize = iFile->GetLength();
	if (nFileSize < (TInt)sizeof(TDICC_HEADER))
		{
	  LOG_ERROR("CDict: header too small");
    iError = NO_CANT_READFILE;
    ASSERT(FALSE);
    return FALSE;
		}

	// Datos que contiene el header
  iFile->ReadBuffer(&iHeader, sizeof(TDICC_HEADER));
  
  if (!CheckHeader(nFileSize))
  	{
	  LOG_ERROR("CDict: Bad Header");
    ASSERT(FALSE);
    return FALSE;
  	}
	
  iNoHide = (GetHdrField(HDR_DIC_FLGS) & FLAG_NOHIDE) != 0;
  
  // abrir el indice
  
  // crearlo si no existe
  if (iIndex == NULL)
  	iIndex = new CDictIndex<TRUE>();
  
  if (iLoadFromStream)
  	{	// ir hasta el final del diccionario
  	iFile->Seek(iHeader.DatSize - sizeof(TDICC_HEADER), CFile::current);

  	// cargar el indice que esta a continuacion
		iError = iIndex->Open(iFile, iLoadFromStream);
		if (iError != DICT_NO_ERROR)
		  LOG_ERROR("CDict: Can't open index (1)");
  	}
  else
  	{ // cargar el indice que esta como un fichero aparte con extension .idx
    CFile* indexStream = new CFile();

	  CStringA indexName(aName);
		int iDot = indexName.ReverseFind('.');
		if (iDot > 0)
			indexName = indexName.Left(iDot) + ".idx";
	  
		if (!indexStream->Open(indexName))
			{
		  LOG_ERROR("CDict: Index do not exist: %s", indexName.c_str());
			iError = CAN_NOT_OPENFILE_IDX;
	    ASSERT(FALSE);
	    return FALSE;
			}
		
		iError = iIndex->Open(indexStream, iLoadFromStream);
		if (iError != DICT_NO_ERROR)
		  LOG_ERROR("CDict: Can't open index: %s", CS2SZ(indexName));
		
		indexStream->Close();
		delete indexStream;
  	}

  iIsOpen = (iError == DICT_NO_ERROR);
	if (iIsOpen)
		{
		iCount  = (iIndex) ? iIndex->GetNumRec() : iHeader.NumRec;
		iUseCache = TRUE;//iCount > 400;
		}
  
  if (iIsOpen)
  	{
		iCache.AfterLoad();

#ifdef ACTIVE_SAVE
		if (!iName.IsEmpty())
			{
			int p = iName.ReverseFind('\\');
			if (p != -1)
				TRACE("%s", iName.c_str() + p + 1)
			else
				TRACE("%s", iName.c_str());
			}
		//TRACE("count=%d", GetCount());
#endif

  	/*if (iName.Length() == 0)
  		TRACE1("SubDictionary loaded: %s", CS2SZ(iMasterFileName))
  	else
  		TRACE1("Dictionary loaded: %s", CS2SZ(iName));*/
  	}
  else
    ASSERT(FALSE);

	return iIsOpen;
	}

template<class DATA, class CACHE>
void CDictT<DATA,CACHE>::Serialize(CArchive &ar, LPCSTR
#ifdef ACTIVE_SAVE
		aDumpTxtFile
#endif
		)
  {
  if( ar.IsLoading() )                      // Guardar diccionario
    {
#ifdef ACTIVE_SAVE
		if (aDumpTxtFile)
			TRACE("%s", aDumpTxtFile);
#endif
    Free();                                 // Libera todos los diccionarios
    OpenFromFile(ar);                  // Carga uno desde la posición del fichero
    }
	else
		{
#ifdef ACTIVE_SAVE
		Save(ar, NULL, aDumpTxtFile);
#endif
		}
  }

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::OpenFromFile(CArchive &ar)
	{
	ar.UpdateStreamPosition();
	iFile = ar.GetFile();     					// Obtiene manipualdor del fichero
	iMasterFileName = iFile->iFileName;
	iBaseOffset = iFile->GetPosition();
	iLoadFromStream = TRUE;
	
	bool res = Open();
	if (res)
		{
		ar.UpdatePosition();
		}
	
	return res;
	}

//--------------------------------------------------------------------------
// Esta función chequea si el argumento 'Hdr' apunta a un encabezamiento de
// un fichero diccionario, en ese caso retorna TRUE, en caso contrario retorna
// FALSE y activa el error correspondiente.
//--------------------------------------------------------------------------

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::CheckHeader(TUint aFileSize)
  {
  // Verifica que el formato es correcto
  if (iHeader.ID[0] != 'D' || iHeader.ID[1] != 'I' || iHeader.ID[2] != 'C' || 
  		iHeader.ID[3] != 'C' || iHeader.ID[4] != 0 ||
  		iHeader.DatSize < sizeof(TDICC_HEADER) ||  
      iHeader.MemSize < iHeader.DatSize) 
    {
    iError = BAD_DICC_TYPE;
    return FALSE;
    }

  // Verifica que la versión sea la adecuada
  if( iHeader.Ver != 1000 || iHeader.Size != sizeof(TDICC_HEADER) ) 
    {
    iError = BAD_DICC_VERSION;
    return FALSE;
    }

  // Verifica que el fichero contiene todos los datos
  if( aFileSize != 0 && aFileSize < iHeader.DatSize )
    {
    iError = BAD_DICC_TYPE;
    return FALSE;
    }
  
  return TRUE;
  }

template<class DATA, class CACHE>
void CDictT<DATA,CACHE>::Close()
	{
	if (!iIsOpen)
		return;

	if (iIndex)
		{
		iIndex->Close();
		delete iIndex;
		iIndex = NULL;
		}
	
	if (iFile && iLoadFromStream == FALSE)
		{ // si se abre de un stream, el stream no nos pertenece y no podemos cerrarlo
		iFile->Close();
		delete iFile;
		iFile = NULL;
		}
	
	ClearCache();
		
	if (iIsOpen)
		{
		/*if (iName.Length() == 0)
			TRACE1("SubDictionary unloaded: %s", CS2SZ(iMasterFileName))
		else
			TRACE1("Dictionary unloaded: %s", CS2SZ(iName));*/
		}
	
	iIsOpen = FALSE;
	}

template<class DATA, class CACHE>
TUint32 CDictT<DATA,CACHE>::GetHdrField(TInt aIdxField) const
	{
  switch(aIdxField)
    {
    //case HDR_DIC_ID  : lstrcpy( sValor, m_Header->ID ); break;
    case HDR_DIC_VER : return iHeader.Ver;
    //case HDR_SIZE    : _itoa_s( m_Header->Size, sValor, 30, 10 ); break;
    case HDR_SRC_ID  : return iHeader.Src;
    case HDR_DEST_ID : return iHeader.Dest;
    case HDR_DIC_FLGS: return iHeader.Flgs;
    case HDR_MAX_REC : return iHeader.MaxSize;
    case HDR_DAT_SIZE: return iHeader.DatSize;
    case HDR_MEM_SIZE: return iHeader.MemSize;
    case HDR_MUM_REC : return iHeader.NumRec;
    case HDR_DEL_REC : return iHeader.DelRec;
    case HDR_MOD_KEY1: return iHeader.IdxKey1;
    case HDR_MOD_KEY2: return iHeader.IdxKey2;
    //case HDR_MODE    : _itoa_s( m_Mode, sValor, 30, 10 ); break;

    default:
      return 0;
    }
	}

template<class DATA, class CACHE>
CStringA CDictT<DATA,CACHE>::GetHdrFieldS(TInt aIdxField) const
	{
	CStringA res;
	
  switch(aIdxField)
    {
    case HDR_OBJ_ID  : res = iHeader.IdObj; break;
    case HDR_ESP_ID  : res.Append((LPCSTR)&iHeader.Reserv1, 2); break;
    case HDR_TYPE_ID : res.Append((LPCSTR)&iHeader.Reserv2, 2); break;
    }
  
  return res;
	}


template<class DATA, class CACHE>
void CDictT<DATA,CACHE>::HideData(TDictData& aData)
  {
  if (iNoHide == FALSE)
    {
    TUint8* sBuffer = (TUint8*)CS2SZ(aData);
	  for(; *sBuffer; sBuffer++)
		  {
		  *sBuffer = 255 - *sBuffer;
		  }
    }
  }

//--------------------------------------------------------------------------
// Esta función retorna la información sobre la llave cuyo índice es 'Idx',
// esta información es el contenido la llave y/o el contenido de los datos.
// Si no se desea obtener información sobre la llave 'Len1' debe ponerse a
// cero (En ese caso 'Name' puede ser NULL). 
// Si no se desea obtener información sobre los datos 'Len2' debe ponerse a
// cero (En ese caso 'Datos' puede ser NULL). 
// Esta función actualiza la referencia, el indice y la longitud de los datos,
// para el record encontrado, estos valores pueden ser recuperado mediante
// las funciones 'GetLastRef', 'GetLastIndex' y 'GetLastLen' respectivamente,
//--------------------------------------------------------------------------
template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::GetAt(TInt aIdx, TDictKey* aName, TDictData* aData)
  {
  if (iCount == 0 || aIdx < 0)
  	return FALSE;

	//COUNTER("GetRef_GetAt");
  if (aIdx >= iCount)  									// Si el indice es demasiado grande
    aIdx = iCount - 1;  								// Busca el último record
  
  iLastIdx = aIdx;                    	// Actualiza ultimo indice

  GetRef(aName, aData);    							// Copia llave y datos

  return TRUE;
  }

//--------------------------------------------------------------------------
// Esta función busca 'aName' por todo el diccionario, si la encuentra devuelve
// TRUE, en caso contrario retorna FALSE.
// Esta función actualiza la referencia, el indice y la longitud de los datos,
// para el record encontrado, estor valores pueden ser recuperado mediante
// las funciones 'GetLastRef', 'GetLastIndex' y 'GetLastLen' respectivamente.
// Si la palabra no es encontrada los datos anteriores serán actualizados, 
// para la palabra más cercana, si la busqueda se realiza con las llaves 
// ordenedas por orden alfabetico.
// Si no interesa obtener los datos, se debe poner 'MaxLen' igual a cero, en
// ese caso 'Datos' tambien se puede poner como NULL.
//--------------------------------------------------------------------------

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::GetKey(const TDictKey& aName, TDictData& aData)
  {
  aData.Empty();

	if (!iUseCache)
		{
		if (!iIndex->Find(this, aName, &iLastIdx))
  		return FALSE;
  
 		GetDataFast(aData);     								// Los datos para el buffer

		return TRUE;                          		// Encontro el nombre
		}
	else
		{
		CACHE_ITEM** cachedItem = NULL;
		if (iCache.FindAdd(aName, cachedItem))
			{ // la clave existe en la cache
			CACHE_ITEM* cachedItem1 = *cachedItem;
			iLastIdx = (int)cachedItem1->index();
			bool bFound = cachedItem1->found();

			if (bFound && cachedItem1->mData == NULL)
				{
				//COUNTER("ReadData2");
				// aun no se habian cargado los datos de la clave
				CString sData;
				GetRef(NULL, &sData);
				cachedItem1->mData = new DATA(sData);
				}

			if (cachedItem1->mData != NULL)
				aData = *cachedItem1->mData;

			return bFound;
			}
		else
			{ // la clave no existe en la cache, buscarla y añadirla
			DATA* data = NULL;
			//int iLastIdx;//xfx
			bool bFound = iIndex->Find(this, aName, &iLastIdx);

			if (bFound)
				{
				//GetDataAt(iLastIdx, aData);
				GetActualData(aData);
				//GetDataFast(aData);
				data = new DATA(aData);
				}

			*cachedItem = new CACHE_ITEM(data, iLastIdx, bFound);

			return bFound;
			}
		}
  }

//---------------------------------------------------------------------------------------
// Esta función es solo para compativilidad. se usa solo para diccionarios de sufijos
//---------------------------------------------------------------------------------------
template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::FindSuffix(const TDictKey& s, TDictData& data)              // Segura para MT
  {
  bool ret = FALSE;

  for( int i=0; i<(int)s.Length() && ret==FALSE; ++i )
  	ret = GetKey(s.Mid(i), data);

  //if( ret ) HideData( data );

  return ret;
  }

//---------------------------------------------------------------------------------------
// Esta función es solo para compativilidad. se usa solo para diccionarios de prefijos
//---------------------------------------------------------------------------------------
template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::FindPreffix(const TDictKey& s, TDictData& data)
  {
  ASSERT( iIsOpen );                           // Existe diccionario principal

  CString tmp(s);

  bool ret = FALSE;

  for( int i=s.GetLength(); i>0 && ret==FALSE; --i )
    {
    tmp.Truncate(i);

    ret = GetKey( tmp, data );
    }

//  if( ret ) HideData( data );

  return ret;
  }

//---------------------------------------------------------------------------------------
// Esta función se utiliza para comenzar el proceso de busqueda de una frase. Debe de 
// utilizarse para buscar la primera palabra de la frase y preparar el mecanismo para 
// buscar el resto de la frase, si existe.
//---------------------------------------------------------------------------------------
template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::FindInitFrase(const TDictKey& aFrase)
  {
	//TRACE("FindInitFrase: \"%s\"", aFrase.c_str());
	bool res = FindIndex(aFrase, iLastIdx);
  if (res == FALSE)
		{
		/*if (aFrase.EndWith(" "))
			{
			//TRACE("");
			//return FALSE;
			}*/
		LPCSTR szKey = iIndex->GetKeyAt(this, iLastIdx);
		int len = aFrase.GetLength();
		res = strncmp(szKey, aFrase.c_str(), len) == 0 && szKey[len] == ' ';
		}

  return res;
  }

//---------------------------------------------------------------------------------------
// Esta función se utiliza para continuar el proceso de busqueda de una frase,
// de forma tal que la frase encontrada sea la más grande posible.
// Esta función puede retornar 3 valores diferentes:
//
// FRS_NOFOUND - Este valor se retorna para terminar la busqueda de la frase
//               ya que no se encuentra en el diccionario ninguna llave que
//               comience con la frase buscada.
//
// FRS_FULLFOUND - Este valor indica que la frase fue encontrada en el
//                 diccionario, y se debe comenzar a probar con una frase
//                 más larga.
//
// FRS_SEMIFOUND - Este valor indica que la frase no fue encontrada pero se
//                encontro una llave que comienza con la frase buscada, por
//                tanto se debe probar con una frase más larga.
//---------------------------------------------------------------------------------------

template<class DATA, class CACHE>
TInt CDictT<DATA,CACHE>::FindNextFrase(const TDictKey& aFrase)
  {
	//TRACE("FindNextFrase: \"%s\"", aFrase.c_str());
	if (iIdxXXXX_a == -1)
		{
		FindIndex("xxxx a", iIdxXXXX_a);
		FindIndex("xxxxA", iIdxXXXXA);
		// cuantas claves hay por caracter como promedio en el rango 'a'...'z'
		iKeysPerChar = ((iIdxXXXXA - iIdxXXXX_a) /*<< 16*/) / ('z'-'a');
		if (iKeysPerChar <= 0)
			iKeysPerChar = 1;
		}
  ASSERT( iIsOpen );        			// Existe diccionario principal

	LPCSTR szFrase = aFrase.c_str();
  int lenFrase = aFrase.GetLength();                      // Longitud a comparar

	// hacer una iteracion simple a ver si encuentra el resultado
	// pedir la clave de la posicion actual
	LPCSTR szKey = iIndex->GetKeyAt(this, iLastIdx);
	int ret = strncmp(szKey, szFrase, lenFrase);
	if (ret == 0)
		{	// la parte izquierda de esta clave coincide con la frase a buscar
		if (szKey[lenFrase] == '\x0')
			return FRS_FULLFOUND;    // Es la llave

		if (szKey[lenFrase] == ' ')
			return FRS_SEMIFOUND;    // Le sigue otra palabra

		//nos pasamos de la frase a buscar y no se encontro nada
		return FRS_NOFOUND;
		}
	else if (ret > 0) // nos pasamos de la frase a buscar y no se encontro nada
		return FRS_NOFOUND;

	// iLastIdx esta antes de la frase a buscar

	int nIter = 0;
	int idxEnd = -1;
	int delta = 4;
	
	if (*((DWORD*)szFrase) == 0x78787878 && szFrase[4] == ' ')
		{ // la frase empieza con "xxxx "
		BYTE ch5 = (BYTE)szFrase[5];
		if (ch5 < (BYTE)'a' || ch5 > (BYTE)'z')
			{
			delta = 512;//(idxXXXX_a - idxXXXX) / 4;
			}
		else // szFrase[5] esta en el intervalo 'a'...'z'
			{ // la frase empieza con "xxxx a" o superior
			if (iLastIdx < iIdxXXXX_a)
				iLastIdx = iIdxXXXX_a;

			// si la frase tiene dos espacios al menos, usar un delta pequeño, ya que se supone
			// que estemos mas cerca del objetivo
			for(int i=6; ; i++)
				{
				char ch = szFrase[i];
				if (ch == '\x0')
					break;
				else if (ch == ' ')
					{
					delta = 64;
					break;
					}
				}

			if (delta != 64)
				{
				// tratar de adivinar la posicion de la frase asumiendo una distribucion uniforme
				delta = (int)(iKeysPerChar << 0);
				int hintPos = int(iIdxXXXX_a + iKeysPerChar * (ch5 - (BYTE)'a'));
				szKey = iIndex->GetKeyAt(this, hintPos);
				ret = strcmp(szKey, szFrase);
				if (ret < 0) // la clave esta antes de la frase
					{ // avanzar hasta encontrar o pasarse de la frase
					iLastIdx = hintPos;
					idxEnd = hintPos + delta;

					for(; ; nIter++)
						{
						szKey = iIndex->GetKeyAt(this, idxEnd);
						ret = strcmp(szKey, szFrase);

						if (ret < 0)
							idxEnd += delta;
						else if (ret > 0)
							break;
						else
							{ // se encontro la frase
							iLastIdx = idxEnd;
							return FRS_FULLFOUND;
							}
						}
					}
				else if (ret > 0) // la clave esta despues de la frase
					{ // retroceder hasta encontrar o pasarse de la frase
					idxEnd = hintPos;
					iLastIdx = idxEnd - delta;

					for(; ; nIter++)
						{
						szKey = iIndex->GetKeyAt(this, iLastIdx);
						ret = strcmp(szKey, szFrase);

						if (ret > 0)
							iLastIdx -= delta;
						else if (ret < 0)
							break;
						else
							return FRS_FULLFOUND; // se encontro la frase
						}

					}
				else
					{
					iLastIdx = hintPos;
					return FRS_FULLFOUND; // se encontro la frase
					}

				clamp(iLastIdx, iIdxXXXX_a, iIdxXXXXA);
				clamp(idxEnd, iLastIdx, iIdxXXXXA);
				}
			}
		}
		
	if (idxEnd == -1)
		{
		idxEnd = iLastIdx + delta;
		if (idxEnd >= iCount)
			idxEnd = iCount-1;

		for(;;)
			{
			nIter++;
			szKey = iIndex->GetKeyAt(this, idxEnd);
			ret = strcmp(szKey, szFrase);
			//ret = memcmp(szKey, szFrase, lenFrase);
			//ret = strFastCompare(szKey, szFrase, lenFrase);
			if (ret < 0)
				{
				//estamos antes de la frase, ajustar el rango y seguir buscando
				delta <<= 1;
				iLastIdx = idxEnd;
				if (iLastIdx >= iCount)
					return FRS_NOFOUND;

				idxEnd = iLastIdx + delta;
				if (idxEnd >= iCount)
					idxEnd = iCount-1;
				}
			else if (ret == 0 && szKey[lenFrase] == '\x0')
				{	// se encontro la frase exacta
				iLastIdx = idxEnd;
				return FRS_FULLFOUND;    // Es la llave
				}
			else
				// nos pasamos de la frase, el intervalo a buscar es [iLastIdx, idxEnd]
				break;
			}
		}

	// buscar la clave usando los indices en un intervalo a partir de la posicion actual
	//int idxStart = iLastIdx;

	bool res = FALSE;
	if (iLastIdx != idxEnd)
		res = FindIndex(aFrase, iLastIdx, iLastIdx, idxEnd);
	//res = FindIndex(aFrase, iLastIdx, iLastIdx, iLastIdx + 50000);//2000);
	/*if (byhint)
	if (aFrase.StartWith("xxxx"))
		{
		TRACE("from: %s", szKey);
		CStringA s;
		s.Format("iter %d", nIter);
		COUNTER(s.c_str());
		TRACE("FindNextFrase: \"%s\", \t\t iter %d delta (%d) \t%d", szFrase, nIter, idxEnd-idxStart, iLastIdx - idxStart);
		}*/

	if (res)
		{
		//TRACE("Phrase found: %s", szFrase);
    return FRS_FULLFOUND;    // Es la llave
		}

	// la clave buscada no existe (ya no se puede devolver FRS_FULLFOUND)
	szKey = iIndex->GetKeyAt(this, iLastIdx);
	if (strncmp(szKey, szFrase, lenFrase) == 0 && szKey[lenFrase] == ' ')
		// la parte izquierda de esta clave coincide con la clave a buscar
		return FRS_SEMIFOUND;    // Le sigue otra palabra

  // No se encuentra
	return FRS_NOFOUND;
  }

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::FindIndex(const TDictKey& aName, TInt &aIndex, TInt aStart, TInt aEnd)
	{
	if (!iUseCache)
		return iIndex->Find(this, aName, &aIndex, aStart, aEnd);
	else
		{
		CACHE_ITEM** cachedItem = NULL;
		if (iCache.FindAdd(aName, cachedItem))
			{ // la clave existe en la cache
			//COUNTER("CacheHit");
			aIndex = (int)(*cachedItem)->index();
			return (*cachedItem)->found();
			}
		else
			{ // la clave no existe en la cache
			//COUNTER("CacheMiss");
			bool bFound = iIndex->Find(this, aName, &aIndex, aStart, aEnd);
			// los datos no se piden ahora porque podrian no hacer falta
			*cachedItem = new CACHE_ITEM(aIndex, bFound);

			return bFound;
			}
		}
	};

template<class DATA, class CACHE>
void CDictT<DATA,CACHE>::GetKeyAtOffset(TDictKey& key, TUint32 aOffset)
	{
	key.Empty();
	if (!SetStreamOffset(aOffset))
		return;

  TInt Len = iFile->ReadInt16L(); 			// Longitud del record

	GetStreamKey(key);
  TInt keyLen = key.Length() + 1;

	// calcular la longitud de los datos
  iDataLen = Len - sizeof(TInt16) - keyLen;	// Actualiza longitud del ultimo dato
	//if (iDataLen <= 0)
	//	LOG_ERROR("iDataLen <= 0, key: %s, Dict: %s", CS2SZ(key), CS2SZ(iMasterFileName));
	}

template<class DATA, class CACHE>
LPCSTR CDictT<DATA,CACHE>::GetFastKeyAtOffset(TUint32 aOffset)
	{
	if (!SetStreamOffset(aOffset))
		return NULL;

  /*TInt Len = */iFile->ReadInt16L(); 			// Longitud del record

	return GetFastStreamKey();
	}

//--------------------------------------------------------------------------
// Esta función según el ultimo record referenciado, obtiene el contenido de
// la llave y/o el contenido de los datos, esto valores los coloca en los
// buffers 'Name' y 'Datos' repectivamente.
// Si se quiere ignorar alguno de estos datos se puede poner la longitud
// correspondiente 'Len1' o 'Len2' igual a 0, solo en ese caso se puede
// poner el puntero al buffer igual a NULL.
// Si el tamaño del buffer no es suficiente el dato correspondiente será
// truncado y se colocará en la varible global _Error_ la constante
// TRUNCATE_KEY o TRUNCATE_DATA para si se quiere consultarla.
// Si la ultima referencia es incorrecta los resultados de esta función son
// impredesibles
//--------------------------------------------------------------------------

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::GetRef(TDictKey* aName, TDictData* aData)
  {
  //COLLECT_INTERVAL("CDict::GetRef");
  
  if (!SetStreamOffset(GetOffset(iLastIdx)))
  	return FALSE;
  
  TInt recordLen = iFile->ReadInt16L(); 			// Longitud del record
  TInt keyLen = 0;

  if (aName)
  	{
  	GetStreamKey(*aName);
  	keyLen = aName->Length() + 1;
  	}
  else
  	{
  	TDictKey key;
  	GetStreamKey(key);
  	keyLen = key.Length() + 1;
  	}
  
  iDataLen = recordLen - sizeof(TInt16) - keyLen;	// Actualiza longitud del ultimo dato
  if (aData && iDataLen > 0)
  	{
  	GetStreamData(*aData, iDataLen);
  	HideData(*aData);
  	}
  
  return TRUE;
  }

#ifdef ACTIVE_SAVE

// Salva el diccionario con el formato viejo
template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::Save(const CStringA& sFileName)
	{
	CFile file(sFileName, CFile::modeWrite);
	CArchive ar(&file, CArchive::store);

	TRACE("Saving Dict: %s", sFileName.GetFileName().c_str());

	CStringA sIndexName(sFileName);
	StrPutFileExt(sIndexName, ".idx");

	CStringA txtDumpFile(sFileName);
	StrPutFileExt(txtDumpFile, ".txt");
	LPCSTR szDumpFile = txtDumpFile.GetFileName.c_str();

	bool res = Save_(ar, sIndexName.c_str(), szDumpFile);

	return res;
	}

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::Save(CArchive& ar, LPCSTR aIndexName, LPCSTR aDumpTxtFile)
	{
	//TRACE("Adding Dict to: %s", ar.m_strFileName.GetFileName().c_str());
	TRACE("Saving %s into %s", iDebugName.c_str(), ar.m_strFileName.GetFileName().c_str());
	return Save_(ar, aIndexName, aDumpTxtFile);
	}

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::Save_(CArchive& ar, LPCSTR aIndexName, LPCSTR aDumpTxtFile)
	{
	bool res = TRUE;
	CFile* file = ar.GetFile();
	int offStart = file->GetPosition();

	ar.WriteBuffer(&iHeader, sizeof(iHeader));

	CFile txtFile;
	
	aDumpTxtFile = NULL; // desactivar la creacion de los txt
	if (aDumpTxtFile != NULL)
		txtFile.Open(StrGetDir(file->iFileName) + aDumpTxtFile, CFile::modeWrite);

	int datSize = 0; // tamaño de los datos
	int keysLen = 0;
	int* arrIndexs = new int[iCount];
	for(int i=0; i<iCount; i++)
		{
		CStringA sKey, sData;
		GetAt(i, &sKey, &sData);

		if (!CheckKey(sKey.c_str()))
			{
			CStringA s(sKey);
			s.Replace('\x0A', ' ');
			s.Replace('\x0D', ' ');
			TRACE("Bad key: %s", s.c_str());
			}

		if (aDumpTxtFile != NULL)
			{
			CStringA sTxt;
			sTxt.Format("%s: %s", sKey.c_str(), sData.c_str());
			sTxt.Replace('\x0A', ' ');
			sTxt.Replace('\x0D', ' ');
			sTxt += '\n';
			txtFile.WriteStringSZ(sTxt.c_str(), FALSE);
			}

		HideData(sData);

		// sData tiene un 0x0 como parte de la cadena, seguida del null terminator
		WORD recordLen = sizeof(WORD) + sKey.GetLength() + 1 + sData.GetLength();
		keysLen += sKey.GetLength() + 1;
		arrIndexs[i] = file->GetPosition() - offStart;
		ar << recordLen;
		ar << sKey.c_str();
		ar.WriteBuffer((LPVOID)sData.c_str(), sData.GetLength());

		datSize += recordLen;
		}

	// arreglar el header (debido a los possibles registros borrados que fueron eliminados)
	iHeader.DelRec = 0;
	iHeader.DatSize = sizeof(iHeader) + datSize;
	iHeader.MemSize = iHeader.DatSize;

	file->Seek(offStart);
	ar.WriteBuffer(&iHeader, sizeof(iHeader));

	file->Seek(0, CFile::end);

	//TRACE("keysLen = %d", keysLen);
	if (aIndexName != NULL)
		res = iIndex->Save(aIndexName, arrIndexs);
	else
		res = iIndex->Save(ar, arrIndexs);

	delete[] arrIndexs;
	return res;
	}

#endif

struct TDictKeyWordOptHeader
	{
	int count;  			// cantidad de claves
	int numKeyWords;  // cantidad de keywords unicos
	int keySize;			// tamaño total de todas las claves
	int offIndex;     // offset donde empieza el indice
	};

#ifdef ACTIVE_SAVE

template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::SaveDCX(CArray<CActionPhrase>& arrWords)
	{
	CStringA name(iName);
	name.Replace(".dcc", EXT_DCC);
	CFile file(name, CFile::modeWrite);

	TRACE("Saving DCX: %s", name.c_str());
	//TRACE("%s : %d %d", name.c_str(), header.count, header.numKeyWords);

	CArchive ar(&file, CArchive::store);

	int offStart = file.GetPosition();

	// escribir el header (despues tendra que ser reescrito)
	TDictKeyWordOptHeader header;
	header.count = GetCount();
	file.WriteBuffer(&header, sizeof(header));

	// escribir las claves
	for(int i=0; i<GetCount(); i++)
		{
		CStringA key;
		GetKeyAt(i, key);

		ar << key.c_str();
		}

	header.keySize = file.GetPosition() - sizeof(header);

	// escribir los datos y guadar el offset de cada uno, este offset se usa tambien
	// para saber el tamaño de cada dato por lo cual hay uno extra para saber el
	// tamaño del ultimo dato
	CWordArray arrKeyIndexs; // indice del KeyWord asociado a una clave segun su indice
	CArray<CKeyWordEntry*> arrKeyWord;

	CIntArray arrKeyOff;
	for(int i=0; i<GetCount(); i++)
		{
		CStringA sData;
		GetDataAt(i, sData);

		CKeyWordEntry* keyWord = new CKeyWordEntry(sData);

		keyWord->RemoveDuplicates();

		CStringA key;
		GetKeyAt(i, key);

		int idxYaExiste = -1;

		for(int j=0; j<arrKeyWord.GetCount(); j++)
			{
			if (keyWord->IsEqual(*arrKeyWord[j]))
				{
				idxYaExiste = j;
				break;
				}
			}

		if (idxYaExiste == -1)
			{
			//TRACE("------------------------");
			//TRACE("key = %s", key.c_str());
			idxYaExiste = arrKeyWord.Add(keyWord);

			// guardar el offset de cada keyword
			int posa = file.GetPosition();
			arrKeyOff.Add(posa);

			// escribir el keyword al fichero
			keyWord->Save(ar, arrWords);
			}
		//else
		//	TRACE("key = %s", key.c_str());

		// guardar indice de cada clave
		arrKeyIndexs.Add(idxYaExiste);//m_arrKeyOff.GetCount() - 1);

		//file.WriteBuffer((LPVOID)data.c_str(), data.GetLength() + 1);
		//sum += data.GetLength() + 1;
		}

	// escribir todos los KeyWords y sus datos en el log
	/*for(int i=0; i<arrKeyWord.GetCount(); i++)
		{
		TRACE("--------------");
		for(int j=0; j<arrKeyIndexs.GetCount(); j++)
			{
			if (arrKeyIndexs[j] == i)
				{
				CStringA key;
				GetKeyAt(j, key);
				TRACE(key.c_str());
				}
			}

		arrKeyWord[i]->Dump();
		}*/

	// cantidad de keywords
	header.numKeyWords = arrKeyOff.GetCount();

	// guardar el final del ultimo keyword y el inicio de los indices
	int pos = file.GetPosition();
	arrKeyOff.Add(pos);
	header.offIndex = pos;

	// escribir el array de las posiciones de cada dato
	for(int i=0; i<arrKeyOff.GetCount(); i++)
		{
		ar << arrKeyOff[i];
		}

	// escribir el array de los indices de cada clave en el array de las posiciones de los datos
	for(int i=0; i<arrKeyIndexs.GetCount(); i++)
		{
		ar << arrKeyIndexs[i];
		}

	// reescribir el header
	file.Seek(offStart, CFile::begin);

	file.WriteBuffer(&header, sizeof(header));

	file.Close();

	return TRUE;
	}

#endif
//***************************************************************************
//*                                CSimpleDict                              *
//***************************************************************************

struct TDictOptHeader
	{
	int count;  			// cantidad de claves
	int keySize;			// tamaño total de todas las claves
	int offIndex;     // offset donde empieza el indice
	};

/*template<class DATA>
bool CSimpleDict<DATA>::LoadOpt(const CStringA& aFileName)
	{
	//COLLECT_INTERVAL("LoadOpt");
	
	CStringA name(aFileName);
	name.Replace(".dcc", EXT_DCC);
	CDictT<DATA,CSimpleCache<DATA>>::iFile = new CFile(name, CFile::modeRead);

	int offStart = CDictT<DATA,CSimpleCache<DATA>>::iFile->GetPosition();

	// leer el header
	TDictOptHeader header;
	CDictT<DATA,CSimpleCache<DATA>>::iFile->ReadBuffer(&header, sizeof(header));

	CDictT<DATA,CSimpleCache<DATA>>::iCount = header.count;

	// leer las claves
	int sum = 0;
	CStringA sKeys(header.keySize);

	{
	//COLLECT_INTERVAL("read_comodin");
	CDictT<DATA,CSimpleCache<DATA>>::iFile->ReadBuffer((LPVOID)sKeys.c_str(), header.keySize);

	// leer las posiciones de cada dato
	iArrDataOff = new int[CDictT<DATA,CSimpleCache<DATA>>::iCount + 1];
	CDictT<DATA,CSimpleCache<DATA>>::iFile->Seek(header.offIndex, CFile::begin);
	CDictT<DATA,CSimpleCache<DATA>>::iFile->ReadBuffer((LPVOID)iArrDataOff, (CDictT<DATA,CSimpleCache<DATA>>::iCount + 1)*sizeof(iArrDataOff[0]));
  }

	// guardar las claves en la cache
	{
	COLLECT_INTERVAL("create_cache"); // cuesta mas este que leer las claves
	CDictT<DATA,CSimpleCache<DATA>>::iCache.Reserve(CDictT<DATA,CSimpleCache<DATA>>::iCount);
	LPCSTR pKeys = sKeys.c_str();
	for(int i=0; i<CDictT<DATA,CSimpleCache<DATA>>::iCount; i++)
		{	
		CDictT<DATA,CSimpleCache<DATA>>::iCache.Add(pKeys, i);
		for(pKeys++ ; *pKeys != 0; pKeys++);
		pKeys++;
		//int len = strlen(pKeys);
		//pKeys += len + 1;
		}
	}

	iIsOpen = TRUE;

	return iIsOpen;
	}*/

#ifdef ACTIVE_SAVE

/*template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::SaveOpt(const CStringA& aFileName)
	{
	CStringA name(aFileName);
	name.Replace(".dic",".dix");
	CFile file(name, CFile::modeWrite);

	CArchive ar(&file, 0);

	return SaveOpt(ar);
	}*/
	
template<class DATA, class CACHE>
bool CDictT<DATA,CACHE>::SaveOpt(CArchive& ar)
	{
	CFile* file = ar.GetFile();

	int offStart = file->GetPosition();

	// escribir el header (despues tendra que ser reescrito)
	TDictOptHeader header;
	header.count = GetCount();
	file->WriteBuffer(&header, sizeof(header));

	int offKeys = file->GetPosition();

	// escribir las claves
	for(int i=0; i<GetCount(); i++)
		{
		CStringA key;
		GetKeyAt(i, key);

		ar << key.c_str();
		}

	header.keySize = file->GetPosition() - offKeys;

	// escribir los datos y guadar el offset de cada uno, este offset se usa tambien
	// para saber el tamaño de cada dato por lo cual hay uno extra para saber el
	// tamaño del ultimo dato
	int* arrDataOff = new int[GetCount() + 1];
	for(int i=0; i<GetCount(); i++)
		{
		CStringA sData;
		GetDataAt(i, sData);

		int posa = file->GetPosition();
		arrDataOff[i] = posa;

		//file.WriteBuffer((LPVOID)data.c_str(), data.GetLength() + 1);
		file->WriteCString(sData);
		//DATA* data = new DATA(sData);
		//data->SaveOpt(ar);
		//delete data;

		int posb = file->GetPosition();
		}
		
	header.offIndex = file->GetPosition();
	arrDataOff[GetCount()] = header.offIndex;

	// escribir las posiciones de cada dato
	for(int i=0; i<GetCount()+1; i++)
		{
		ar << arrDataOff[i];
		}

	delete[] arrDataOff;
	arrDataOff = NULL;

	// reescribir el header
	file->Seek(offStart, CFile::begin);

	file->WriteBuffer(&header, sizeof(header));

	return TRUE;
	}
	
#endif	
