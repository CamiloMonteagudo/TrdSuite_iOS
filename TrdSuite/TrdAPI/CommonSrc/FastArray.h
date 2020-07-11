#ifndef FASTARRAY_H_
#define FASTARRAY_H_

#include <memory.h>

// Contiene Arrays que usan el FastHeap para pedir memoria

class CFastHeap
	{
protected:
	static CFastHeap* gFirstHeap;
	static CFastHeap* gCurrHeap;
	static bool gEnabled;

	CFastHeap* m_pNext;
	LPBYTE m_pData;
	TInt m_iOffset;
	TInt m_iSize;

	// Para los word se usa un buffer especifico pues el buffer general tiene que estar 
	// alineado en 4 bytes y si se usa para words se desperdiciaria memoria
	WORD* m_pWordData;
	TInt m_iWordOffset;
	TInt m_iWordSize;

protected:
	
	CFastHeap(TInt aSize, TInt aWordSize)
		{
		//COUNTER("CFastHeap_Count");
		Init(aSize, aWordSize);
		}
	
	~CFastHeap()
		{
		Free();
		}

	void Init(TInt aSize, TInt aWordSize)
		{
		m_pNext = NULL;

		m_iSize = aSize;
		m_pData = new BYTE[aSize];
		m_iOffset = 0;
		
		m_pWordData = new WORD[aWordSize];
		m_iWordSize = aWordSize;
		m_iWordOffset = 0;

		// inicializar en cero el buffer de words
		//memset(pWordData, 0, sizeof(WORD)*aWordSize);
//		TRACE("FastHeap created with %.1f Mbytes (%d bytes, %d words)", 
//			(aSize + aWordSize*2.0)/(1024.0*1024.0),
//			aSize, aWordSize);
		}

	// Crea un nuevo Heap y lo convierte en el actual
	static CFastHeap* NewHeap();

	void Free()
		{
		delete m_pData;
		m_pData = NULL;
		m_iOffset = 0;
		m_iSize = 0;

		delete m_pWordData;
		m_pWordData = NULL;
		m_iWordOffset = 0;
		m_iWordSize = 0;

		if (m_pNext)
			delete m_pNext;
		m_pNext = NULL;
		}
	
	void Reset()
		{
		m_iOffset = 0;

		// inicializar en cero el buffer de words (la parte que se uso)
		//memset(pWordData, 0, sizeof(WORD)*iWordOffset);

		m_iWordOffset = 0;

		if (m_pNext)
			m_pNext->Reset();
		}

	inline LPVOID _Get(TInt aSize)
		{
		int newSize = (aSize + 3) & ~3; // alinear a 4 bytes

		if (m_iOffset + newSize > m_iSize)
			{ // no cabe aqui, pedir la memoria en el proximo heap
			if (m_pNext == NULL)
				m_pNext = NewHeap();

			return m_pNext->_Get(aSize);
			}
		else
			{
			LPBYTE pRet = m_pData + m_iOffset;
			m_iOffset += newSize; // alinear a 4 bytes
			ASSERT(m_iOffset <= m_iSize);
			return (LPVOID)pRet;
			}
		}

	inline WORD* _GetWords(TInt aNumWords)
		{
		if (m_iWordOffset + aNumWords > m_iWordSize)
			{ // no cabe aqui, pedir la memoria en el proximo heap
			if (m_pNext == NULL)
				m_pNext = NewHeap();  // crear un heap nuevo

			return m_pNext->_GetWords(aNumWords);
			}
		else
			{
			WORD* pRet = m_pWordData + m_iWordOffset;
			m_iWordOffset += aNumWords;
			ASSERT(m_iWordOffset <= m_iWordSize);
			return pRet;
			}
		}

	void _CheckUse()
		{
		COLLECT("CFastHeap::ByteSize", m_iOffset);
		COLLECT("CFastHeap::WordSize", m_iWordOffset);
		if (m_pNext)
			m_pNext->_CheckUse();
		}
	
public:

	static bool isEnabled()
		{
		return gEnabled;
		}

	static void Enable()
		{
		gEnabled = TRUE;
		}

	static void Disable()
		{
		gEnabled = FALSE;
		}

	// Crea el FastHeap o los reinicializa
	static void CreateOrReset()
		{
		if (gCurrHeap == NULL)
			{
			gFirstHeap = NewHeap();
			}
		else
			{
			gFirstHeap->Reset();
			gCurrHeap = gFirstHeap;
			}

		Enable();
		}
	
	static void DeleteAll()
		{
		delete gFirstHeap;
		gFirstHeap = gCurrHeap = NULL;

		Disable();
		}

	static void CheckUse()
		{
		if (gFirstHeap)
			gFirstHeap->_CheckUse();
		}
	
	// Ejemplo de uso de los new:
	// CStringA* p = CFastHeap::New<CStringA>("pepe");

	template<class TYPE>
	static inline TYPE* New()
		{
		TYPE* p = (TYPE*)Get(sizeof(TYPE));

		::new( (void*)(p) ) TYPE;

		return p;
		};

	template<class TYPE, class TYPE1>
	static inline TYPE* New(TYPE1 arg1)
		{
		TYPE* p = (TYPE*)Get(sizeof(TYPE));

		::new( (void*)(p) ) TYPE(arg1);

		return p;
		};

	template<class TYPE, class TYPE1, class TYPE2>
	static inline TYPE* New(TYPE1 arg1, TYPE2 arg2)
		{
		TYPE* p = (TYPE*)Get(sizeof(TYPE));

		::new( (void*)(p) ) TYPE(arg1, arg2);

		return p;
		};

	static inline LPVOID Get(TInt aSize)
		{
		ASSERT(gCurrHeap != NULL);
		return gCurrHeap->_Get(aSize);
		}

	static inline WORD* GetWords(TInt aNumWords)
		{
		ASSERT(gCurrHeap != NULL);
		return gCurrHeap->_GetWords(aNumWords);
		}
	};

// nunca llama a constructores ni destructores de TYPE
// usa memset para inicializar en 0
template<class TYPE>
class CFastArrayValue : public CMFCObject
	{
protected:
	TYPE* pData;
	TInt iCount;
	
public:
	CFastArrayValue()
		{
		pData = NULL;
		iCount = 0;
		}
	
	virtual ~CFastArrayValue()
		{
		RemoveAll();
		}
	
	inline TYPE* GetBuffer() { return pData; }
	
	inline TInt GetUpperBound() { return iCount - 1; }
	inline TInt GetCount() const { return iCount; }
	inline TInt GetSize() const { return iCount; }
	
	inline bool IsEmpty() const { return iCount == 0; }
	
	void SetSize(TInt aNewSize, bool aFillZero = TRUE)
		{
		ASSERT(iCount == 0);
		if (aNewSize == 0)
			return;
		
		pData = (TYPE*)CFastHeap::Get(sizeof(TYPE)*aNewSize);
		iCount = aNewSize;
				
		// inicializar en cero (hace falta para que los casos de CArray<DWORD> y 
		// similares se inicializen en 0) 
		if (aFillZero)
			memset(pData, 0, sizeof(TYPE)*aNewSize);
		}
	
	//inline TYPE operator[](TInt aIndex) const { return pData[aIndex]; };
	inline TYPE& operator[](TInt aIndex) const { return pData[aIndex]; };
	
	//inline TYPE GetAt(TInt aIdx) const { return (*this)[aIdx]; }
	inline const TYPE& GetAt(TInt aIdx) const { return (*this)[aIdx]; }
	inline TYPE* GetAtPtr(TInt aIndex) const { return pData + aIndex; }
	inline void SetAt(TInt aIdx, const TYPE& aValue) { pData[aIdx] = aValue; }
	
	TInt Find(const TYPE& aValue)
		{
		for(TInt i=0; i<iCount; i++)
			if (pData[i] == aValue)
				return i;
		
		return -1;
		}
	
	void RemoveAll()
		{
		iCount = 0;
		pData = NULL;
		}
	
	virtual void Serialize(CArchive &/*ar*/) 
		{
		ASSERT(FALSE);
		}
		
	void SerializeAsObArray(CArchive &ar);
		
	void SerializeAsObArrayMem(CArchiveMem &ar);

	template<class ARCHIVE>
	void Load(ARCHIVE &ar) 
		{
		SetSize(ar.ReadCount());
		for(int i=0; i<GetCount(); i++)
			GetAtPtr(i)->Load(ar);
		}

	template<class ARCHIVE>
	void LoadBurst(ARCHIVE &ar) 
		{
		SetSize(ar.ReadCount(), FALSE);
		ar.ReadBuffer(GetBuffer(), GetCount()*sizeof(GetAt(0)));
		}

#ifdef ACTIVE_SAVE
	void Save(CArchive &ar) const
		{
		ar.WriteCount(GetCount());
		for(int i=0; i<GetCount(); i++)
			GetAt(i).Save(ar);
		}
#endif
	};


// Array de clases usando el FastHeap, puede opcionalmente llamar al constructor y 
// destructor de las clases
template <class TYPE>
class CFastArray: public CMFCObject
	{
	private:
		TYPE* pData;
		TInt iCount;
		
	public:
	CFastArray()
		{
		pData = NULL;
		iCount = 0;
		}
		
	virtual ~CFastArray()
		{
		RemoveAll(TRUE);
		}
		
	inline TYPE* GetBuffer() { return pData; }
		
	inline TInt GetUpperBound() { return iCount - 1; }
	inline TInt GetCount() const { return iCount; }
	inline TInt GetSize() const { return iCount; }
		
	inline bool IsEmpty() const { return iCount == 0; }
		
	// en los FastArray el SetSize solo se puede llamar una vez		
	void SetSize(TInt aNewSize, bool aCallConstructor = FALSE)
		{
		ASSERT(iCount == 0);
		if (aNewSize == 0)
			return;
			
		pData = (TYPE*)CFastHeap::Get(sizeof(TYPE)*aNewSize);
		iCount = aNewSize;
					
		// llamar al constructor
		if (aCallConstructor)
			{
			for(TInt i=0; i<aNewSize; i++)
				::new( (void*)(pData + i) ) TYPE;
			}
		else
			// inicializar en cero 
			memset((void*)pData, 0, sizeof(TYPE)*aNewSize);
		}
		
	//inline TYPE operator[](TInt aIndex) const { return pData[aIndex]; };
	inline const TYPE& operator[](TInt aIndex) const { return pData[aIndex]; };
		
	inline const TYPE& GetAt(TInt aIdx) const { return (*this)[aIdx]; }
	//inline TYPE& GetAt(TInt aIdx) { return (*this)[aIdx]; }
	inline TYPE* GetAtPtr(TInt aIndex) const { return pData + aIndex; }

	/*void SetAt(TInt aIdx, const TYPE& aValue)
		{
		TYPE* pType = pData + aIdx;
		pType->~TYPE();		// destruir el elemento viejo
			
		// llamar al copy constructor
		::new( (void*)( pType ) ) TYPE(aValue);
		}*/
		
	TInt Find(const TYPE& aValue)
		{
		for(TInt i=0; i<iCount; i++)
			if (pData[i] == aValue)
				return i;
			
		return -1;
		}
		
	void RemoveAll(bool aCallDestructor = TRUE)
		{
		if (aCallDestructor)
			for(TInt i=0; i<iCount; i++)
				pData[i].~TYPE();				// llamar al destructor
			
		iCount = 0;
		pData = NULL;
		}
		
	virtual void Serialize(CArchive &/*ar*/) 
		{
		ASSERT(FALSE);
		}
	
	void SerializeAsObArray(CArchive &ar);
		
	void SerializeAsObArrayMem(CArchiveMem &ar);

	void Load(CArchiveMem &ar);

#ifdef ACTIVE_SAVE
	void Save(CArchive &ar) const
		{
		ar.WriteCount(GetCount());
		for(int i=0; i<GetCount(); i++)
			GetAt(i).Save(ar);
		}
#endif
	};


class CFastWordArray
	{
protected:
	WORD* pData;
	TInt iCount;
	
public:
	CFastWordArray()
		{
		pData = NULL;
		iCount = 0;
		}
	
	virtual ~CFastWordArray()
		{
		RemoveAll();
		}
	
	inline WORD* GetBuffer() const { return pData; }
	
	inline TInt GetUpperBound() { return iCount - 1; }
	inline TInt GetCount() const { return iCount; }
	inline TInt GetSize() const { return iCount; }
	
	inline bool IsEmpty() const { return iCount == 0; }
	
	void SetSize(TInt aNewSize) 
		{
		ASSERT(iCount == 0);
		
		if (aNewSize == 0)
			return;
		
		pData = CFastHeap::GetWords(aNewSize);
		iCount = aNewSize;
				
		// inicializar en cero (hace falta para que los casos de CArray<DWORD> y 
		// similares se inicializen en 0) 
		//memset(pData, 0, sizeof(WORD)*aNewSize);
		}
	
	//inline WORD operator[](TInt aIndex) const { return pData[aIndex]; };
	inline WORD& operator[](TInt aIndex) const { return pData[aIndex]; };
	
	//inline WORD GetAt(TInt aIdx) const { return (*this)[aIdx]; }
	inline const WORD& GetAt(TInt aIndex) const { return pData[aIndex]; }
	inline void SetAt(TInt aIdx, WORD aValue) { pData[aIdx] = aValue; }
	
	TInt Find(WORD aValue)
		{
		for(TInt i=0; i<iCount; i++)
			if (pData[i] == aValue)
				return i;
		
		return -1;
		}
	
  void RemoveAll()
		{
		pData = NULL;
		iCount = 0;
		}
	
  virtual void Serialize(CArchive &ar);
  virtual void SerializeMem(CArchiveMem &ar);

	template<class ARCHIVE>
	void Load(ARCHIVE &ar)
		{
		TInt nCount = ar.ReadCount();
		SetSize(nCount);
	
		if (nCount > 0)
			ar.ReadBuffer(pData, nCount*2);
		}

#ifdef ACTIVE_SAVE
	void Save(CArchive &ar) const;
#endif
	};


class CFastStrArray
	{
	LPCSTR m_pBuffer;		// buffer donde se guardan todas la cadenas de manera consecutiva
	CFastArrayValue<LPCSTR> m_Offset;		// array de cada una de la cadenas
	public:

	CFastStrArray()
		{
		m_pBuffer = NULL;
		}

	void Load(CArchive &ar);

	inline TInt GetCount() { return m_Offset.GetCount(); }

	inline LPCSTR GetAt(TInt aIndex) const
		{
		return m_Offset[aIndex];
		}

	inline LPCSTR operator[](TInt aIndex) const
		{ return GetAt(aIndex); }
	};


#endif /*FASTARRAY_H_*/
