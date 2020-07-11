/*
 ============================================================================
 Name		: DictIndex.h
 Author	  : 
 Version	 : 1.0
 Copyright   : Your copyright notice
 Description : CDictUserIndex declaration
 ============================================================================
 */

#ifndef DICTUSERINDEX_H
#define DICTUSERINDEX_H

// INCLUDES
#include "DictTypes.h"
#include "DictError.h"


#define DICC_FILE				1
#define DICC_READONLY		2
#define DICC_MEM        4
#define DICC_LOADKEYS   32
#define DICC_CACHEKEYS  64

class CDictUserIndex
	{
private:
	CIntArray iIndex;

public:
	// Constructors and destructor

  //---------------------------------------------------------------------------------------------------------------------------
	CDictUserIndex():iIndex()
		{
		}

  //---------------------------------------------------------------------------------------------------------------------------
	~CDictUserIndex()
		{
    Close();
		}

  //---------------------------------------------------------------------------------------------------------------------------
  // Caga los indices desde un fichero
	TUint Load( CStringA& sFileName )
		{
		CFile File( sFileName, CFile::modeRead );                     // Abre el ficehro en modo lectura

		if( !File.isOpen() )                                          // Si no lo pudo abrir
      return CAN_NOT_OPENFILE_IDX;                                // Retorna error
	
		TInt nFileSize = File.GetLength();                            // Obtiene el tama–o de los datos en el fichero
		if( nFileSize < (TInt)sizeof(DWORD))                          // Si no tiene el menos el nœmero de llaves
			return BAD_OPENFILE_IDX;                                    // Retorna error

    DWORD nIndex;
		File.ReadBuffer(&nIndex, sizeof(DWORD));                      // Lee la cantidad de indices en el fichero
	
		if( nIndex> 0 )                                               // Si hay mas de uno indice
			{
			iIndex.SetSize( nIndex, FALSE );                            // Redimensiona el arreglo para recepcionar todos los indices
      
      UINT indexSize = nIndex * sizeof(DWORD);                    // Tama–o en memoria de los indices
			File.ReadBuffer(iIndex.GetBuffer(), indexSize);             // Lee contenido del fichero para el arreglo
			}

		return DICT_NO_ERROR;
		}

  //---------------------------------------------------------------------------------------------------------------------------
  // Libera todos los recursos usados por la clase
	void Close()
		{
		iIndex.Close();
		}

//  //---------------------------------------------------------------------------------------------------------------------------
//  // Guarda los indices que contiene la clase a un fichero dado por su nombre
//	bool Save(const CStringA& sFileName )
//		{
//		CFile File( sFileName, CFile::modeWrite );
//
//    DWORD nIndex = iIndex.GetSize();
//    
//    File.WriteBuffer( &nIndex, sizeof(DWORD) );
//    
//		File.WriteBuffer( iIndex.GetBuffer(), nIndex*sizeof(iIndex[0]));
//
//		return TRUE;
//		}
//
  //---------------------------------------------------------------------------------------------------------------------------
  // Reserva un tama–o en memoria para el arreglo
	void SetSize(TInt aNewSize, bool aFillZero = TRUE)
    {
		iIndex.PreAllocate( aNewSize );
    }
    
  //---------------------------------------------------------------------------------------------------------------------------
  // Inserta un elemento en el arreglo
	void InsertAt(TInt aIdx, const DWORD aValue)
		{ 
    iIndex.InsertAt( aIdx, aValue );
		}
	
  //---------------------------------------------------------------------------------------------------------------------------
  // Adiciona un elemento al final del arreglo
	void Add( const DWORD aValue)
		{ 
    iIndex.Add( aValue );
		}
	
  //---------------------------------------------------------------------------------------------------------------------------
  // Retorna el nœmero de elementos del indice
	int Count()
		{ 
    return iIndex.GetCount();                   // Nœmero de llaves en el indice
		}
	
  //---------------------------------------------------------------------------------------------------------------------------
  // Retorna el indice real en el diccionario del elemento con indice idx
  int IndexAt( int idx )
    {
    return iIndex[idx];
    }
  
  #define FindOpt    (NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
  //---------------------------------------------------------------------------------------------------------------------------
  // Busca una llave en el diccionario
	bool Find( CDict* aDict, NSString* aKey, TInt* aIdx )
		{
		CStringA  csKey;                                // Llave que se lee desde el diccionario en forma de CString
		NSString* sKey;                                 // Llave que se lee desde el diccionario en forma de NSString
		NSComparisonResult ret = 0;                     // Resultado de la comparaci—n
    int nRec = iIndex.GetCount();                   // Nœmero de llaves en el indice
    
		// metodo tradicional de busqueda binaria
		int lo = 0;                                     // Indice inferior de la busqueda
		int hi = nRec-1;                                // Indice superior de la busqueda
		int mid = 0;                                    // Indice en el medio del rengo de busqueda

		while( lo <= hi )                               // Mientras que exista un rango de busqueda valido
			{
			mid = (lo + hi) >> 1;                         // Tome el elemento que esta en el medio del rango

      int idx = iIndex[mid];                        // Toma su indice real en el diccionario
			aDict->GetKeyAt( idx, csKey );                // Obtiene la llave desde el diccionario
      
      // Comvierte la llave a la forma NSString
      sKey = [NSString stringWithCString:csKey.c_str() encoding:NSISOLatin1StringEncoding ];
      
      ret = [aKey compare:sKey options:FindOpt];    // Compara la llave buscada con la actual

			if( ret == NSOrderedAscending )               // La llave actual tiene un orden superior a la buscada
				hi = mid - 1;                               // Pone limite superior de la busqueda, a la llave anterior a la actual
			else if( ret == NSOrderedDescending )         // La llave actual tiene un orden inferior a la buscada
				lo = mid + 1;                               // Pone limite inferor de la busqueda, a la llave que le sigue a la actual
			else                                          // La dos llaves son iguales
				{
				*aIdx = mid;                                // Retorna el indice a la llave encontrada
				return TRUE;                                // Retorna verdadero
				}
			}

    // La llave no fue encontrada
		if( ret == NSOrderedDescending && mid < nRec )  // Si la llave buscada debia tener un orden supperior y no es la ultima
			mid++;                                        // Retorna la llave siquiente

		*aIdx = mid;                                    // Actualiza el indice donde deberia esta ubicada la llave
			
		return FALSE;                                   // Retorna que no la encontro
		}
	};

#endif // DICTUSERINDEX_H
