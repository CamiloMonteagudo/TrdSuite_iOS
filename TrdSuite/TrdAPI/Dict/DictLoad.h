
#ifndef DICTLOAD_H
#define DICTLOAD_H

// INCLUDES
#include "WinUtil.h"
#include "DictTypes.h"
#include "DictIndex.h"
#include "DictError.h"


// CLASS DECLARATION
  
/**
 *  CDictLoad
 * 
 */
//
//
// Diccionario que carga todo en memoria, tiene un buffer con todo el fichero
class CDictLoad
	{

public:	
	CStringF iName;
	
protected:
	TInt   iCount;
	TInt 	 iLastIdx;
	bool	 iIsOpen;
	bool	 iNoHide;
	TInt 	 iFlags;
	bool   iLoadFromStream;	// indica si el diccionario y el indice deben cargarse desde un
													// stream o desde ficheros independientes
	TInt   iError;
	TDICC_HEADER iHeader;
	CDictIndex<FALSE>* iIndex;
	CMapSZ<LPCSTR> iHash;
	CStringA m_Buffer;
	LPCSTR   m_szBuffer;
	CStringA iMasterFileName;

public:
	CStringA iDebugName;
	//friend class CDictIndex;
	
	// Constructors and destructor
	CDictLoad(LPCSTR aName)
		{
		iDebugName = aName;
		iCount = 0;
		iLastIdx = 0;
		iIsOpen = FALSE;
		iNoHide = FALSE;
		iFlags = 0;
		iError = DICT_NO_ERROR;
		iIndex = NULL;
		iLoadFromStream = FALSE;
		m_szBuffer = NULL;
		}

	/**
	 * Destructor.
	 */
	~CDictLoad()
		{
		Close();
		}

	//bool Open(const CStringA& aFilePath, TInt aFlags = 0);
	bool Open(CFile* aFile, TInt aFlags = 0);
	bool Load(const CStringA& aFilePath, TInt aFlags = 0)
		{
		iName = aFilePath;
		CFile file(aFilePath, CFile::modeRead);

		return Open(&file, aFlags);
		};
	bool OpenFromFile(CArchive &ar);

	void Serialize(CArchive &ar, const CStringA& aDumpTxtFile)	
		{
		Serialize(ar, aDumpTxtFile.c_str());
		}

	void Serialize(CArchive &ar, LPCSTR aDumpTxtFile = NULL);

	bool Save(const CStringA& sFileName);
	bool Save(CArchive& ar, LPCSTR aIndexName, LPCSTR aDumpTxtFile);
	bool Save_(CArchive& ar, LPCSTR aIndexName, LPCSTR aDumpTxtFile);

	void Close();

  bool IsOpen() { return iIsOpen; }

	TUint32 GetHdrField(TInt aIdxField) const;
	CStringA GetHdrFieldS(TInt aIdxField) const;
  
  void SetNoHide(bool aNoHide) { iNoHide = aNoHide; }
  
  inline TInt GetCount() const { return iCount; }

	// Indica si una llave existe
  inline bool IsKey(const TDictKey& aKey)
  	{
		return iHash.Exists(aKey.c_str());

		/*int idx;
		return FindIndex(aKey, idx);*/
  	};

	bool FindSuffix(const TDictKey& sKey, LPCSTR& aData)
		{
		bool ret = FALSE;

		for(LPCSTR szKey = sKey.c_str(); *szKey != 0 && ret==FALSE; ++szKey)
  		ret = GetKey(szKey, aData);

		return ret;
		}

	bool FindPreffix(const TDictKey& sKey, LPCSTR& aData)
		{
		ASSERT( iIsOpen );                           // Existe diccionario principal

		CString tmp(sKey);
		LPSTR szTmp = (LPSTR)tmp.c_str();

		bool ret = FALSE;

		for( int i=sKey.GetLength(); i>0 && ret==FALSE; --i )
			{
			szTmp[i] = '\x0';

			ret = GetKey(szTmp, aData );
			}

		return ret;
		}
	
	bool GetKeyCS(LPCSTR aKey, CStringA& aData)
		{
		//COLLECT_INTERVAL("GetKey");
		LPCSTR szData;
		bool res = GetKey(aKey, szData);
		if (res)
			aData = szData;
		else
			aData.Empty();

		return res;
		}

	// Devuelve los datos de una llave
	bool GetKey(LPCSTR aKey, LPCSTR& aData)
		{
		bool res = iHash.Find(aKey, aData);
		return res;
		}

	class CDump
		{
		public:
		void Action(LPCSTR aKey, LPCSTR aValue)
			{
			TRACE("%s = %s", aKey, aValue);
			}
		};
		
	void Dump()
		{
		CDump a;
		TRACE("Hash Count = %d", iHash.GetCount());
		iHash.ForEach(a);
		}
		
	// Estos metodos o no se usan en la traduccion o no necesitarian ser publicos, pero lo son porque
	// se usan en el visualizador de diccionarios
  /*inline LPCSTR GetKeyAt(TInt aIdx)
  	{
		iLastIdx = aIdx;
		return GetFastKeyAtOffset(GetOffset(iLastIdx));
  	}

  inline LPCSTR GetDataAt(TInt aIdx)
  	{
		iLastIdx = aIdx;
		return GetActualData();
  	}*/
		
	// este metodo solo existe para que el compilador no de error pues nunca se usa,
	// se usaria solo al buscar por indice en un CDictLoad lo cual nunca se hace
  void GetKeyAt(TInt /*aIdx*/, TDictKey& aKey)
  	{ // nunca se usa
		ASSERT(FALSE);
		aKey.Empty();
  	}

	// Devuelve la clave y datos de un indice, actualiza la posicion actual
	inline bool GetAt(TInt aIdx, LPCSTR& aKey, LPCSTR& aData)
		{
		//iLastIdx = aIdx;
		WORD* pRecLen = (WORD*)(m_szBuffer + iIndex->GetOffset(aIdx) - sizeof(TDICC_HEADER));
		//if (*pRecLen == 0)
		//	TRACE("");
		aKey = (LPCSTR)(pRecLen + 1);

		aData = aKey + strlen(aKey) + 1;

		// chequear si los datos todavia estan ocultos
		if ((*pRecLen & 0x8000) == 0)
			{ 
			HideData(aData);
			*pRecLen |= 0x8000;
			}

		return TRUE;
		}
		
	// Devuelve el indice mas cercano de una llave y si existe o no,
	// No actualiza la llave actual
	inline bool FindIndex(const TDictKey& aName, TInt &aIndex)
		{
		return FindIndex(aName, aIndex, 0, iCount-1);
		}

	// no se usa
	/*inline LPCSTR GetKeyAtOffset(TUint32 aOffset)
		{
		return m_szBuffer + aOffset + sizeof(WORD);
		}*/

	inline LPCSTR GetFastKeyAtOffset(TUint32 aOffset)
		{
		return m_szBuffer + aOffset + (sizeof(WORD) - sizeof(TDICC_HEADER));
		}
		
protected:

	// estos se usan pero solo internamente dentro de CDict (son protegidos)
  /*inline LPCSTR GetActualKey()
  	{
		return GetFastKeyAtOffset(GetOffset(iLastIdx));
  	}
  
  inline LPCSTR GetActualData()
  	{
		LPCSTR szKey = GetFastKeyAtOffset(GetOffset(iLastIdx));
		
		return szKey + strlen(szKey) + 1;
  	}*/

	inline void HideData(LPCSTR aData)
	  {
		if (iNoHide == FALSE)
			{
			TUint8* sBuffer = (TUint8*)aData;
			for(; *sBuffer; sBuffer++)
				{
				*sBuffer = 255 - *sBuffer;
				}
			}
		}

	inline bool FindIndex(const TDictKey& aName, TInt &aIndex, TInt aStart, TInt aEnd)
		{
		return iIndex->Find(this, aName, &aIndex, aStart, aEnd);
		}
	
	TInt GetLastError() { return iError; };
	void ResetError() { iError = DICT_NO_ERROR; };

	bool CheckHeader(TUint aFileSize);
	
	inline TInt GetOffset(TInt aIdx) { return iIndex->GetOffset(aIdx); }

	};


//#include "DictLoadInl.h"

#endif // DICTLOAD_H
