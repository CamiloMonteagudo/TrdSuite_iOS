#ifndef CSTRING_H_
#define CSTRING_H_

#include <string>
#include <string.h>
#include <ctype.h>

#ifdef __STDC_WANT_SECURE_LIB__

#define sprintf_ sprintf_s
#define vsprintf_ vsprintf_s

#else

#define sprintf_ sprintf
#define vsprintf_ vsprintf

#endif

// variables solo usadas por TStringDataT, debian ser miembros estaticos de ella pero
// el GCC da error al compilar
extern TInt _CString_iExpand;

// Inicializa los buffers globales usados internamente por la CString
void InitCStringBuffers();
// Libera los buffers globales usados internamente por la CString
void FreeCStringBuffers();

#define AFTER_MODIFY

#define TEMP_BUFFER_SIZE 3000
#define MIN_STR_BUFF_SZIE 4

#include "UpLow.h"

// clases que contienen los tipos de datos de los strings para ansi y unicode
class STAnsi
	{
public:
	typedef std::string	_string;
	typedef char 				_char;
	
	// buffer para usos temporales
	static char iTempBuffer[TEMP_BUFFER_SIZE];
	//static TStringDataT<STAnsi>* m_pNullStrData;
	};

// forwards declarations

class CMFCString;

typedef CMFCString CMFCStringA;

extern CMFCStringA CANull;

#define STR_NULL ""

class CMFCString : public std::string
	{
	typedef std::string _string;
	typedef char _char;
	
public:
	
	CMFCString()
		{
		//ASSERT(_ST::m_pNullStrData != NULL);
		}
	
	explicit CMFCString(TInt aSize)
		{
		reserve(aSize);
		}
	
	CMFCString(const CMFCString& aStr):_string(aStr)
		{
		}

	CMFCString(const CMFCString& aStr, TInt aLen):_string(aStr, 0, aLen)
		{
		}
	
	// el explicit es para evitar conversiones automaticas a CMFCString
	// que usarian mas memoria de la necesaria
	explicit CMFCString(const _string& aDes):_string(aDes)
		{
		}
	
	// el explicit es para evitar conversiones automaticas a CMFCString
	// que usarian mas memoria de la necesaria
	// puede usarse sin explicit si se usa solo la cantidad minima imprescindible de 
	// CMFCString como parametros en los metodos de esta clase, en su lugar mejor es usar 
	// _TDesC, asi no se hacen conversiones automaticas de char* a CMFCString
	/*explicit*/ CMFCString(const _char* aStr)
		{
		if (aStr != NULL)
			assign(aStr);
		}

	explicit CMFCString(const _char* aStr, TInt aLen)
		{
		if (aStr != NULL && aLen > 0)
			assign(aStr, aLen);
		
		AFTER_MODIFY;
		}

	explicit CMFCString(const _char* aStr1, const _char* aStr2)
		{
		int len1 = (int)strlen(aStr1);
		int len2 = (int)strlen(aStr2);
		reserve(len1 + len2);
		assign(aStr1, len1);
		append(aStr2, len2);
		}

	explicit CMFCString(_char aCh, const _char* aStr2)
		{
		reserve(1 + strlen(aStr2));
		assign(1, aCh);
		append(aStr2);
		}
	
	~CMFCString()
		{
		//RELEASE_DATA;
		}
	
	enum TCopyMode { ECopy, ENoCopy};
	
public:

	// los operadores deben estar todos con CMFCString, const char * y TDesC 
	//inline bool operator==(const CMFCString& aStr) { return Compare(aStr) == 0; };
	inline bool operator==(const _string& aDes) const		{ return Compare(aDes) == 0; };
	inline bool operator==(const _char* aStr) 	const		{ return Compare(aStr) == 0; };
	inline bool operator==(const _char aChar) 	const		{ return Compare(aChar) == 0; };
	//inline bool operator!=(const CMFCString& aStr) { return Compare(aStr) != 0; };
	inline bool operator<(const _string& aDes) 	const	  { return Compare(aDes) < 0; };
	inline bool operator>(const _string& aDes) 	const	  { return Compare(aDes) > 0; };
	inline bool operator!=(const _string& aDes) const		{ return Compare(aDes) != 0; };
	inline bool operator!=(const _char* aStr) 	const		{ return Compare(aStr) != 0; };
	inline CMFCString& operator=(const CMFCString& aStr) { Copy(aStr); return *this; };
	inline CMFCString& operator=(const _string& aDes) 	 { Copy(aDes); return *this; };
	inline CMFCString& operator=(const _char* aStr) 		 { Copy(aStr); return *this; };
	inline CMFCString& operator=(const _char aChar) 		 { Empty(); AppendChar(aChar); return *this; };
	//inline CMFCString& operator+=(const CMFCString& aStr) { Append(aStr); return *this; };
	inline CMFCString& operator+=(const _string& aDes) 		{ Append(aDes); return *this; };
	inline CMFCString& operator+=(const _char* aStr) 			{ Append(aStr); return *this; };
	inline CMFCString& operator+=(_char aChar) 						{ AppendChar(aChar); return *this; };
	friend inline CMFCString operator+(const CMFCString& aStr1, const CMFCString& aStr2)
		{
		TInt len = aStr1.GetLength() + aStr2.GetLength();
		CMFCString res(len);
		res = aStr1;
		res.Append(aStr2);
		return res;
		}
	
	friend inline CMFCString operator+(const _char* aStr1, const CMFCString& aStr2)
		{
		TInt len = (int)(strlen(aStr1) + aStr2.GetLength());
		CMFCString res(len);
		res.Append(aStr1);
		res.Append(aStr2);
		return res;
		}
		
	friend inline CMFCString operator+(const CMFCString& aStr1, const _char* aStr2)
		{
		TInt len = (int)(aStr1.GetLength() + strlen(aStr2));
		CMFCString res(len);
		res.Append(aStr1);
		res.Append(aStr2);
		return res;
		}
	
	/*friend inline CMFCString operator+(const CMFCString& aStr1, const _string& aStr2)
		{
		TInt len = aStr1.GetLength() + aStr2.Length();
		CMFCString res(len);
		res = aStr1;
		res.Append(aStr2);
		return res;
		}*/
	
	friend inline CMFCString operator+(const CMFCString& aStr1, _char aChar)
		{
		TInt len = aStr1.GetLength() + 1;
		CMFCString res(len);
		res = aStr1;
		res.AppendChar(aChar);
		return res;
		}
		
	friend inline CMFCString operator+(_char aChar, const CMFCString& aStr2)
		{
		TInt len = 1 + aStr2.GetLength();
		CMFCString res(len);
		res.AppendChar(aChar);
		res.Append(aStr2);
		return res;
		}
	
	inline _char operator[](TInt aIndex) const { return at(aIndex); };
	inline _char& operator[](TInt aIndex) { return at(aIndex); };

	//inline operator const _string&() const { return *this; };
	// provoca error por redundancia
	//inline operator const _char*() const { return c_str(); };

	inline _char GetAt(TInt aIndex) const { return at(aIndex); };
	
	// Hace una copia del string pasado
	inline void Copy(const CMFCString& aStr)
		{
		if (this == &aStr) return;
		
		assign(aStr);
		
		AFTER_MODIFY;
		}

	inline void Copy(const _string& aStr)
		{
		if (this == &aStr) return;
		
		assign(aStr);
		
		AFTER_MODIFY;
		}
		
	inline void Copy(const _char* aStr)
		{
		assign(aStr);
		
		AFTER_MODIFY;
		}
	
public:	
// ************************************************	
// *         Funciones de solo lectura            *
// ************************************************
	
	inline TInt GetLength() const
		{
		return (int)length();
		}
	
	inline TInt Length() const
		{
		return (int)length();
		}
	
	/*inline TInt GetAllocLength() const
		{
		return GetDesC()->capacity();
		}*/

	inline bool IsEmpty() const
		{ 
		return empty(); 
		};

	inline bool IsNull() const
		{
		return (GetLength() == 0);
		}
	
	inline TInt Compare(int aStart, int aCount, const _string& aDes) const
		{
		return compare(aStart, aCount, aDes);
		}

	inline TInt Compare(const _string& aDes) const
		{
		return compare(aDes);
		}
	
	inline TInt Compare(const _char* aStr) const
		{
		return compare(aStr);
		}
	
	inline TInt Compare(const _char aChar) const
		{
		return length() == 1 && at(0) == aChar;
		}
	
	inline bool StartWith(const _string& aDes) const
		{
		return compare(0, aDes.length(), aDes) == 0;
		}

	inline bool StartWith(const _char* aStr) const
		{
		for(const _char* sThis = c_str(); *aStr != 0; aStr++, sThis++)
			if (*aStr != *sThis)
				return false;

		return true;
		}

	/*inline bool EndWith(const _string& aDes) const
		{
		return GetDesC()->compare(0, aDes.length(), aDes) == 0;
		}*/

	inline bool EndWith(const _char* aStr) const
		{
		int aLen = (int)strlen(aStr);
		if (aLen > GetLength())
			return false;

		const _char* sThis = c_str() + GetLength() - aLen;
		aLen--;
		for(; aLen >= 0; aLen--)
			if (aStr[aLen] != sThis[aLen])
				return false;

		return true;
		}
	
	inline TInt Find(const _char* aStr, TInt aStart = 0) const
		{
		return (int)find(aStr, aStart);
		};

	inline TInt Find(const _string& s, TInt aStart = 0) const
		{
		return (int)find(s, aStart);
		};
	
	inline TInt Find(const _char& aChar, TInt aStart = 0) const
		{
		return (int)find(aChar, aStart);
		};
	
	inline TInt ReverseFind(_char aChar) const	
		{ 
		return (int)rfind(aChar);
		};
	
	inline TInt FindOneOf(const _string& aCharSet) const
		{
		return (int)find_first_of(aCharSet);
		};
	
	inline TInt FindOneOf(const _char* aCharSet) const
		{
		return (int)find_first_of(aCharSet);
		};
	
	// asumiendo que esta cadena tiene el camino de un fichero, esta funcion devuelve 
	// el nombre del fichero
	CMFCString GetFileName() const
		{
		CMFCString res;
		int i = ReverseFind(FOLDER_SEP_CH);
		if (i >= 0)
			res = Mid(i+1);

		return res;
		}

	// asumiendo que esta cadena tiene el camino de un fichero, esta funcion devuelve 
	// el camino del directorio (incluyendo el \ final)
	CMFCString GetFileDir() const
		{
		CMFCString res;
		int i = ReverseFind(FOLDER_SEP_CH);
		if (i >= 0)
			res = Left(i+1);

		return res;
		}

	// devuelve un CString con el segmento especificado
	CMFCString Mid(TInt aPos, TInt aLen) const
		{
		if (aPos < 0)
			aPos = 0;
		if (aLen < 0)
			aLen = 0;

		TInt thisLen = GetLength();
		if (aPos + aLen > thisLen)
			aLen = thisLen - aPos; 
			
		if (aPos > thisLen || aLen == 0)
			{ // devolver cadena vacia
			CMFCString res;
			return res;
			}
		
		CMFCString res(substr(aPos, aLen));

		return res;
		}
	
	CMFCString Mid(TInt aPos) const
		{
		if (aPos < 0)
			aPos = 0;
		
		if (aPos > GetLength())
			{ // devolver cadena vacia
			CMFCString res;
			return res;
			}
		
		CMFCString res(substr(aPos));

		return res;
		}

	CMFCString Left(TInt aLen) const
		{
		if (aLen <= 0)
			return CANull;
		
		int thisLen = (int)length();
		if (aLen >= thisLen)
			{
			CMFCString res(*this);
			return res;
			}
		else
			{
			CMFCString res(substr(0, aLen));
			return res;
			}
		}

	CMFCString Right(TInt aLen) const
		{
		if (aLen <= 0)
			return CANull;
		
		TInt thisLen = (int)length();
		if (aLen >= thisLen)
			{
			CMFCString res(*this);
			return res;
			}
		else
			{
			CMFCString res(substr(thisLen - aLen, aLen));
			return res;
			}
		}
	
// ************************************************	
// *         Funciones de modificacion            *
// ************************************************	
	
	// Reserva el buffer de la cadena con la longitud especificada
	inline void Preallocate(TInt aNewLen)
		{
		reserve(aNewLen);
		}

	inline void Empty()
		{
		clear();
		}
	
	inline void Zero() { Empty(); }
	
	/*inline const _char* c_str() const
		{
		return iData.c_str();
		}*/

	inline void FreeExtra()
		{
		return reserve(0);
		}
	
	// Equivalente del GetBuffer de la CString, despues de llamar a esta funcion el CString 
	// no se puede modificar hasta que se llame a ReleaseBuffer, pero si no se modifica el
	// largo de la cadena el llamado a ReleaseBuffer es opcional
	_char* GetBuffer(TInt aLen)
	  {
	  Preallocate(aLen);
		resize(aLen, 0); //TODO: mejorar y averiguar porque hace falta esto, el Preallocate debia bastar
		_string::iterator iter = begin();
		return &(*iter);
	  }
	
	// Equivalente del ReleaseBuffer de la CString
	// No se puede llamar sin haber llamado antes a GetBuffer()
	void ReleaseBuffer(int nNewLength = -1)
		{
		if (nNewLength == -1)
			{
			TInt maxLen = (int)capacity();
			const _char* sText = c_str();
			// necesita buscar el null terminator para setear el nuevo tamaño de la cadena.		
			for(TInt i=0; i<maxLen; i++)
				if (sText[i] == 0)
					{ // se encontro el fin de la cadena
					Truncate(i);
					return;
					}
			
			TRACE("Null terminator not found");
			ASSERT(FALSE);     // no se encontro el null terminator
			}
		else
			{
			SetLength(nNewLength);
			}
		}
	
	// Trunca la cadena a una nueva longitud.
	// No se puede usar para hacer la cadena mas grande del tamaño reservado, para ese caso
	// usar PreAllocate()
	inline void Truncate(TInt aLen)
		{
		SetLength(aLen);
		}
	
	// Trunca la cadena a una nueva longitud.
	// No se puede usar para hacer la cadena mas grande del tamaño reservado, para ese caso
	// usar PreAllocate()
	inline void SetLength(TInt aLen)
		{
		resize(aLen);
		
		AFTER_MODIFY;
		}

	// Lee una cadena de un stream en el formato de C (null terminator)
	void ReadFromFileAsNullTerm(CFile& aFile);
	
	// Lee una linea de un fichero texto, no incluye los cambios de linea
	void ReadLine(FILE* aFile)
		{
		_char* pBuffer = STAnsi::iTempBuffer;
		if (fgets(pBuffer, sizeof(STAnsi::iTempBuffer), aFile) == NULL)
			{
			Empty();
			return;
			}

		int len = (int)strlen(STAnsi::iTempBuffer);

		// eliminar los cambios de linea
		if (len > 0 && (pBuffer[len-1] == 10 || pBuffer[len-1] == 13))
			len--;
		if (len > 0 && (pBuffer[len-1] == 10 || pBuffer[len-1] == 13))
			len--;
		pBuffer[len] = 0;

		Copy(STAnsi::iTempBuffer);//, nTotalLen);
	
		AFTER_MODIFY;
		}
		
	// Simula el format de la CString
	void FormatList(const _char* aFormat, va_list list)
		{
		vsprintf_(STAnsi::iTempBuffer, aFormat, list);
		Copy(STAnsi::iTempBuffer);
		}
	
	void Format(const _char* aFormat, ...)
		{
		va_list list;
		va_start(list, aFormat);
		
		FormatList(aFormat, list);
		}
	
	inline void SetAt(TInt aIndex, _char aChar) 
		{ 
		at(aIndex) = aChar;
		}
	
	void MakeLower()
		{
		for(_string::iterator iter = begin(); iter != end(); iter++)
			*iter = CharAnsiToLower(*iter);
		}

	void MakeUpper()
		{
		for(_string::iterator iter = begin(); iter != end(); iter++)
			*iter = CharAnsiToUpper(*iter);
		}
	
	inline void Append(const _string& aDes)
		{
		append(aDes);
		
		AFTER_MODIFY;
		}
	
	inline void Append(const _char* aStr)
		{
		append(aStr);
		
		AFTER_MODIFY;
		}
	
	inline void Append(const _char* aStr, TInt aLen)
		{
		append(aStr, aLen);
		
		AFTER_MODIFY;
		}

	inline void AppendChar(const _char aChar)
		{
		append(1, aChar);
		
		AFTER_MODIFY;
		}
	
	void Enclose(const _char aChar)
		{
		TInt len = GetLength() + 2;
		reserve(len);

		insert((size_type)0, (size_type)1, aChar);
		append((size_type)1, aChar);
		}

	inline void Insert(TInt aPos, const _string& aDes)
		{
		insert(aPos, aDes);
		
		AFTER_MODIFY;
		}

	inline void Insert(TInt aPos, const _char* aStr)
		{
		insert(aPos, aStr);
		
		AFTER_MODIFY;
		}

	inline void Delete(TInt aPos, TInt aLen = 1)
		{
		erase(aPos, aLen);
		
		AFTER_MODIFY;
		}

	TInt Remove(_char aChar)
		{
		ASSERT(aChar != 0);

		_char *sStart, *sFill, *sLook;
		sStart = sFill = sLook = (_char*)c_str();

		// buscar el primer caracter a eliminar
		for(; *sLook != 0; sLook++)
			if (*sLook == aChar)
				{
				sFill = sLook; // a partir de aqui se empieza a eliminar
				break;
				}

		if (*sLook == 0)
			return 0; // ningun caracter a eliminar

		sLook++;

		for(; *sLook != 0; sLook++)
			{
			if (*sLook != aChar)
				*(sFill++) = *sLook;
			}

		resize(sFill - sStart);
		AFTER_MODIFY;
		
		return (int)(sLook - sFill);
		}

	TInt Replace(_char aOld, _char aNew)
		{
		ASSERT(aNew != 0);
		
		TInt nReplaceCount = 0;

		for(_string::iterator iter = begin(); iter != end(); iter++)
			if (*iter == aOld)
				{
				*iter = aNew;
				nReplaceCount++;
				}
		
		AFTER_MODIFY;
		
		return nReplaceCount;
		}
	
	TInt Replace(const _char* aOld, const _char* aNew)
		{
		TInt count = 0;
		TInt pos = 0;
		TInt len = (int)(strlen(aOld));
		TInt newLen = (int)(strlen(aNew));
		
		while (true)
			{
			pos = Find(aOld, pos);
			if (pos >= 0)
				{
				Delete(pos, len);
				Insert(pos, aNew);
				pos += newLen;
				count++;
				}
			else
				break;
			
			}
		
		return count;
		}
	
	TInt Replace(const _string& aOld, const _string& aNew)
		{
		TInt count = 0;
		TInt pos = 0;
		TInt len = (int)aOld.length();
		TInt newLen = (int)aNew.length();
		
		while (true)
			{
			pos = Find(aOld, pos);
			if (pos >= 0)
				{
				Delete(pos, len);
				Insert(pos, aNew);
				pos += newLen;
				count++;
				}
			else
				break;
			
			}
		
		return count;
		}
	
	void TrimLeft(_char aChar = ' ') 
		{
		TInt len = Length();
		TInt i = 0;
		while(i < len && GetAt(i) == aChar) i++;
		
		if (i > 0)
			Delete(0, i);
		}
	
	void TrimLeft(const _char* aChars) 
		{
		TInt len = Length();
		TInt i = 0;
		
		while(i < len && strchr(aChars, GetAt(i)) != NULL) i++;
		
		if (i > 0)
			Delete(0, i);
		}

	void TrimRight(_char aChar = ' ') 
		{
		TInt len = Length();
		TInt i = len - 1;
		while(i >= 0 && GetAt(i) == aChar) i--;
		
		if (i != len-1)
			Truncate(i + 1);
		}	

	void TrimRight(const _char* aChars)
		{
		TInt len = Length();
		TInt i = len - 1;
		while(i >= 0 && strchr(aChars, GetAt(i)) != NULL) i--;
		
		if (i != len-1)
			Truncate(i + 1);
		}
	
	void Trim(_char aChar = ' ')
		{
		TrimRight(aChar);
		TrimLeft(aChar);
		}

	void Trim(const _char* aChars) 
		{
		TrimRight(aChars);
		TrimLeft(aChars);
		}
	

	void FromInt(int aValue)
		{
		if (aValue < 10)
			assign(1, '0' + aValue);
		else
			{
			int rest = aValue % 10;
			aValue /= 10;
			assign(1, '0' + rest);

			while (aValue > 0)
				{
				rest = aValue % 10;
				aValue /= 10;
				insert(0, 1, '0' + rest);
				}
			}
		}
	
	static _char* FromInt_(int aValue)
		{
		#define BUFF_LEN 15
		static _char sbuffer[15];
		sbuffer[BUFF_LEN - 1] = '\x0';

		if (aValue < 10)
			{
			sbuffer[BUFF_LEN - 2] = '0' + aValue;
			return sbuffer + BUFF_LEN - 2;
			}
		else
			{
			int rest = aValue % 10;
			aValue /= 10;
			int len = BUFF_LEN - 2;
			sbuffer[len] = '0' + rest;

			while (aValue > 0)
				{
				rest = aValue % 10;
				aValue /= 10;
				sbuffer[--len] = '0' + rest;
				}

			return sbuffer + len;
			}
		}

	TInt ToInt() const
		{
		TInt res = 0;
		TInt i = GetLength() - 1;
		TInt pow = 1;
		for(; i >= 0; i--)
			{
			char ch = at(i);
			if (ch < '0' || ch > '9')
				break;

			ch -= '0';
			res += ch*pow;
			pow *= 10;
			}
		
		return res;
		}
	};

typedef CMFCStringA CStringA;

#define CString CStringA
#define CStringW CStringA
#define CStringF CStringA

#define _CA (CStringA)

#define CWNull CANull
#define CFNull CANull

#endif /*CSTRING_H_*/
