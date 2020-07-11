/*
 ============================================================================
 Name		: DictData.cpp
 Author	  : 
 Version	 : 1.0
 Copyright   : Your copyright notice
 Description : CDictData implementation
 ============================================================================
 */

#include "DictData.h"


#define MEAN_SINTAXIS_ERROR   -1
#define MEAN_END              -2
#define MEAN_NEXT              1

TInt CDictData::ParseTxt(const TDictData& aData)
	{
  Clear();                                  // Limpia todos los datos

  int iFind = aData.Find("#E");
  if( iFind == -1 )
    return 0;

  return SetDat( aData.Mid(iFind+2), aData.Mid(2,iFind-2) );
	}

void CDictData::GetDataText(TDictData& aData)
	{
	aData.Empty();
  TDictData Data;
  TGramLongType cType;

  if( GetDat( Data, cType ) )
  	{
   	aData.Append(_L8("#T"));
  	aData.Append( cType);
  	aData.Append( _L8("#E"));
  	aData.Append( Data);
  	}
	}

/*void CDictData::GetDataXml(TDictData& aData)
	{
	}*/

TInt CDictData::GetTypesCount()
	{
	return GetNTypes();
	}

TInt CDictData::MeanCount(const CStringA& aType)
	{
  int idx = GetIdxType(aType);
  if( idx != -1 )
    return MeanCountAt(idx);
  
  return 0;
	}

TInt CDictData::MeanCountAt(TInt aIdxType)
	{
  if( aIdxType>=0 && aIdxType<iNTypes )
    return GetNMeans( aIdxType );
  else
    return 0;
	}

void CDictData::get_ActualCmds(CStringA& aCmds)
	{
  if( iIdxType>=0 && iIdxType<iNTypes )
  	aCmds = iTypes[iIdxType].iCmds;
  else
  	aCmds.Empty();
	}

void CDictData::get_ActualMean(CStringA& aMean)
	{
  if( iIdxType>=0 && iIdxType < iNTypes && 
      iIdxMean>=0 && iIdxMean < GetNMeans(iIdxType) )
  	aMean = iTypes[iIdxType].iMean[iIdxMean].isMean;
  else
  	aMean.Empty();
	}

void CDictData::get_ActualEsp(TGramEsp& aEsp)
	{
  if( iIdxType>=0 && iIdxType < iNTypes && 
      iIdxMean>=0 && iIdxMean < GetNMeans(iIdxType) )
  	aEsp = iTypes[iIdxType].iMean[iIdxMean].iEsp;
  else
  	aEsp.Empty();
	}

TText CDictData::get_ActualGen()
	{
  if( iIdxType<0 || iIdxType >= iNTypes || 
  		iIdxMean<0 || iIdxMean >= GetNMeans(iIdxType) )
    return 0;

  BYTE n = iTypes[iIdxType].iMean[iIdxMean].iGen;

  return (n==1)? 'f' : ((n==2)? 'n' : 'm' );
	}

TText CDictData::get_ActualNum()
	{
  if( iIdxType<0 || iIdxType >= iNTypes || 
      iIdxMean<0 || iIdxMean >= GetNMeans(iIdxType) )
    return 0;

  BYTE n = iTypes[iIdxType].iMean[iIdxMean].iNum;

  return (n==1)? 'p' : 's';
	}

TText CDictData::get_ActualRef()
	{
  if( iIdxType<0 || iIdxType >= iNTypes || 
      iIdxMean<0 || iIdxMean >= GetNMeans(iIdxType) )
    return 0;

  BYTE n = iTypes[iIdxType].iMean[iIdxMean].iRef;

  return (n==1)? 'y' : 'n';
	}

TText CDictData::get_ActualTerm()
	{
  if( iIdxType<0 || iIdxType >= iNTypes || 
      iIdxMean<0 || iIdxMean >= GetNMeans(iIdxType) )
    return 0;

  BYTE n = iTypes[iIdxType].iMean[iIdxMean].iTerm;

  return (n==1)? 'y' : 'n';
	}

/*------------------------------------------------------------------------------------*/
//<!----------------------------------------------------------------------------------->
TInt CDictData::get_ActualTypeIdx()
	{
  return iNTypes;
	}

/*------------------------------------------------------------------------------------*/
// Establece el tipo gramatical 'Idx' como tipo actual, si 'Idx' no esta entre 0 y el
// número de tipos introducidos no hace nada
//<!----------------------------------------------------------------------------------->
void CDictData::put_ActualTypeIdx(TInt aIdx)
	{
  if( aIdx>=0 && aIdx<=iNTypes )
    {
    if( aIdx==iNTypes && iTypes[aIdx].iTipo.Length() == 0)
      return;

    iIdxType = aIdx;
    }
	}

/*------------------------------------------------------------------------------------*/
//<!----------------------------------------------------------------------------------->
TInt CDictData::get_ActualMeanIdx()
	{
  return iIdxMean;
	}

/*------------------------------------------------------------------------------------*/
// Dentro del tipo activo, establece el significado con indice 'IdxMean'como activo, 
// si 'IdxMean' esta fuera de rango o no hay tipo activo no hace nada
//<!----------------------------------------------------------------------------------->
void CDictData::put_ActualMeanIdx(TInt aIdxMean)
	{
  if( iIdxType>=0 && iIdxType<iNTypes )
    {
    if( aIdxMean>=0 && aIdxMean < iTypes[iIdxType].iMean.GetCount() )
      {
      iIdxMean = aIdxMean;
      }
    }
	}

/*------------------------------------------------------------------------------------*/
// Obtiene el código de dos letras que representa al tipo actual, si no se puede 
// establecer tipo actual, retorna cadena vacia.
//<!----------------------------------------------------------------------------------->
void CDictData::get_ActualType(CStringA& aType)
	{
	aType.Empty();
	
  if( iIdxType>=0 && iIdxType<iNTypes )
    aType = iTypes[iIdxType].iTipo;
	}


void CDictData::Clear()
	{
  for( int i=0; i<MAX_TYPES; ++i )
    {
    iTypes[i].iTipo.Empty();         // Borra el tipo
    iTypes[i].iCmds.Empty();         // Borra los comandos
    iTypes[i].iMean.RemoveAll();		// Borra todos los significados  
    }

  iNTypes = 0;                     // Pone el número de tipos a 0
	}

int CDictData::SetDat( const CStringA& aData, const CStringA& aType )
	{
  int Cond = 0;
  int len  = aData.Length();
  
  //CString cType( aType, 2 );
  TGramType cType(aType.Left(2));

  Clear();                                  // Limpia todos los datos

  for( int i=0; i<len; )
    {                                     
    if( aData[i]=='"' )                      // Parse para "...",....,"..."
      {   
      if( iTypes[iNTypes].iTipo.Length() == 0)
        {
        if( !GetDeafultType( cType ) )      // Determina el tipo por defecto
          return 0;
        }

      if( !CopyData( aData, aType, i ) )     // Copia para un tipo
        return 0;
      
      if( Cond==0 && i>=aData.Length() )        // Final cuando no condicion
        return iNTypes;                    // Retorna una sola traduccion

      // Verifica final de segunda fase de la condicion                                              
      if( Cond==3 && aData[i]=='}' && i+1==aData.Length() ) 
        return iNTypes;                    // Retorna # de traduccioines
                                                    
      // Verifica final de primera fase de la condicion                                              
      if( Cond==1 && aData[i]=='}' && aData[i+1]==':' )  
        {     
        Cond = 2;
        i += 2;                             // Salta }:
        continue;                           // Continua analizando
        } 
        
      return 0;                             // Hubo un error
      }
    else
      { 
      if( (Cond==0 || Cond==2) && IsCondition( aData, i ) )    
        {
        Cond = 1;                       // Fase inicial de la condicion
        continue;                       // Lee significados
        }
        
      if( Cond==2 && aData[i]=='{' )     // Abre segunda fase de la condicion
        {
        Cond = 3;                       // Fase final de la condicion
        ++i;                            // Salta llave
        continue;                       // Lee significados
        } 
      
      return 0;                         // Hubo error
      }        
    }    
    
  return 0;                               // Hubo error, no termino de analizar
	}

bool CDictData::GetDat( TDictData& aData, CStringA& aType )
	{
	aData.Preallocate(1024);

  if( iNTypes<=0 )                        // Verifica qe existe información
    return FALSE; 
  
  if( !GetFullType( aType ) )
    return FALSE; 

  for( int i=0; i<iNTypes; ++i ) 
    {
    if( i>0 ) aData += ':'; 

    if( iNTypes>1 )
      {
      if( i<iNTypes-1 )
      	{
      	aData.Append(_L8("(W="));
      	aData.Append(iTypes[i].iTipo);
      	aData.Append(_L8(")?"));
      	}
//      else
//        Data += ':' ; 

      aData += '{'; 
      }

    int nMeans = (int)iTypes[i].iMean.GetCount();  // Obtiene el numero de significados

    for( int j=0; j<nMeans ; ++j )                  // Coje todos los significado
      {
      //TGramEsp Esp =  iTypes[i].iMean[j].iEsp;    // Coje especialidad
      CString Esp(iTypes[i].iMean[j].iEsp);         // Coje especialidad
      
      if( Esp.Length()!=2 ) Esp = _L8("GG");          // Si no hay, pone GG

      if( j>0 )																				// Si no es el primer significado
        aData += '@' + Esp ;                         // Adiciona la especilidad

      aData += '"';                                       // Abre comilla
      aData += iTypes[i].iMean[j].isMean;               // Pone significado
      aData += '"';                                       // Cierra comilla

      if( iTypes[i].iMean[j].iNum    ) aData += '$';    // Pone plurar
      if( iTypes[i].iMean[j].iGen==1 ) aData += '*';    // Pone femenino
      if( iTypes[i].iMean[j].iGen==2 ) aData += '-';    // Pone neutro
      if( iTypes[i].iMean[j].iRef    ) aData += '!';    // Pone reflexivo

      if( j<nMeans-1 ) aData += ',';                // Pone coma si no es el ultimo
      }         
      
    if( iTypes[i].iCmds.Length() > 0 )              // Si hay comandos
    	{
    	aData += ',';          							    // Los agrega al final
    	aData += iTypes[i].iCmds;            	  // Los agrega al final
    	}

    if( iNTypes>1 ) aData += '}';                  // Cierra llave, si mas de un tipo
    }                                               
  
  return TRUE;
  }

//---------------------------------------------------------------------------
// Esta funcion copia desde el indice 'i' de 'Data' a 'Str' todos los 
// caracteres desde el caracter inicial de 'Data' que debe ser '"' hasta un 
// caracter terminador que puede ser Null, o }, la cantidad de caracteres 
// maximos a copiar es 127, esta funcion tambien chequea que la cantidad de
// caracteres '"' esten macheados, si una de las dos condiciones anteriores
// no se cumple esta funcion returna -1, en otro caso retorna el indice al 
// ultimo caracter analizado ( caracter terminador ).
//---------------------------------------------------------------------------

bool CDictData::CopyData( const CStringA& aData, const CStringA& aType, int &i )
	{
  int UnMacth = 0;                        // 1- " Abierto 0- " Cerrado
 
  if( iNTypes<0 || iNTypes>=MAX_TYPES )  // Pueden ser hasta 4 traducciones 
    return FALSE;
       
  int j=i;
  for( ; i<aData.Length() && aData[i]!='}'; ++i )  // Busca hasta el final
    if( aData[i]=='"' ) UnMacth ^= 1;          // Registra el macheo de "
      
  if( UnMacth || j==i )                       // Chequea si hubo error
    return FALSE;
		
  if( !GetMeans( aData, aType, j, i-((i<aData.Length())? 1:0) ) )     // Coje todos los significados
    return FALSE;

  ++iNTypes;                                // Aumenta numero de tipos  
  return TRUE;
	}

//----------------------------------------------------------------------------------------
// Esta funcion obtiene el tipo por defecto basandose en la lista de definicion de tipos 
// y los tipos determinados hasta ese momento.
//----------------------------------------------------------------------------------------
bool CDictData::GetDeafultType( const TGramType& Type )
  {                    
  CComplexTypes Tipos;                                // Objeto para manejar tipos

  for( int j=0; j<iNTypes; ++j )                      // Recorre todos los tipos 
    Tipos.AddSingleType( iTypes[j].iTipo );          	// Los adiciona al objeto

  TGramType sType;
  Tipos.GetDeafultType(sType, Type );        					// Busca tipos que falta
  if( sType.Length() == 0)                            // No lo pudo encontar
    return FALSE;

  iTypes[iNTypes].iTipo = sType;                    	// Asigna tipo por defecto

  return TRUE;                                        // Todo OK
  }

//---------------------------------------------------------------------------
// Esta funcion determina si la cadena 's' a partir del caracter 'i'
// tiene el formato (W=??)?{ en ese caso retorna TRUE, los caracteres ??
// son copiados a 'sType' y el indice 'i' es adelantado hasta el caracter
// siguiente al patron antes señalado.
//---------------------------------------------------------------------------

bool CDictData::IsCondition( const CStringA& s, int &j )
	{
  if( iNTypes<0 || iNTypes>=MAX_TYPES )  
    return FALSE;
    
  if( s.Length() < j+8 )       // No quedan las letras necesarias
    return FALSE;
               
  int k = 0;
               
  // Verifica el patron (W=??)?{                   
  if( s[j]=='(' || s[j+1]=='W' || s[j+2]=='=' || s[j+5]==')' )
		{
		k = 6;
	
		if( s[j+6]==' ' )
	      ++k;
	
		if( s[j+k]!='?' || s[j+k+1]!='{'  )
		  return FALSE;     
		}
  else
  	return FALSE;     
       
  TGramType Tipo(s.Mid(j+3, 2));
  
  //Tipo[0]= s[j+3]; Tipo[1]= s[j+4];// Tipo[2]= '\0';

  iTypes[iNTypes].iTipo = Tipo;
            
  j += k + 2;
                
  return TRUE;
	}

//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
bool CDictData::GetMeans( const CStringA& aData, const CStringA& aType, int ini, int fin )
  {

  for(;;)
    {
    int Ret = AddMean( aData, aType, ini, fin );

    if( Ret == MEAN_SINTAXIS_ERROR )
      return FALSE;

    if( Ret == MEAN_END )
      {
      if( ini<fin )  // El resto son los comandos
        iTypes[iNTypes].iCmds = aData.Mid(ini, fin-ini);// CString( aData+ini, fin-ini );
      break;
      }
    }

  return TRUE;
  }


//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
int CDictData::AddMean( const CStringA& aData, const CStringA& aType, int &i, int fin )
	{
  CMean Mean;

//  int Idx = (int)m_Types[m_nTypes].m_Mean.GetSize();  // Numero del significado     
  int lenData = aData.Length();

  if( i<lenData && aData[i] == '"' /*&& Idx==0*/ )                    // Si empieza con " 
    {
    ++i;                                                // Salta "
    }
  else if( i+4<fin && aData[i]=='@' && aData[i+3]=='"' )  // Verifica que empiece con @??"
    {
    Mean.iEsp = aData.Mid(i+1, 2);// CString( &aData[i+1], 2 );              // Copia la especialidad

    i +=4 ;                                             // Salta @??"

    // Determina un termino de esa especialidad
    //CStringA sTerm;
    //sTerm.Format(";%s:%s", Mean.iEsp., &iTypes[iNTypes].iTipo); // Forma cadena
    CString sTerm = ";" + Mean.iEsp + ":" + iTypes[iNTypes].iTipo ; // Forma cadena

    //Mean.iTerm = ( strstr( aType, sTerm ) != NULL );   // Esta en el tipo?... es termino
    Mean.iTerm = (aType.Find(sTerm) != -1);           // Esta en el tipo?... es termino
    }
  else if( i+2<fin && aData[i]=='@' && aData[i+1]=='[' )  // Verifica que empiece con @[
    {
    for( ; i<fin && i<lenData && aData[i]!=']'; ++i ) {};
	  if( i<lenData && aData[i]==']' && aData[i+1]=='"' )
	    i +=2;
    }
  else
    return MEAN_END;                                    // Puede ser un comando
  
  // Busca la palabra hasta que encuentre la " final.    
  int j=i;
  for(;j<fin && j<lenData && aData[j]!='"'; ++j ) {};

  if( j>=lenData || aData[j]!='"' )                     // Si termino en " y la salta
    return MEAN_SINTAXIS_ERROR;                         // Retorna error, no termino en "

  Mean.isMean = aData.Mid(i, j-i );              				// Copia el significado

  i = j+1;                                              // Salta la comilla final

  // Coje la marca de genero, numero y reflexivo    
  for( j=0; j<3 && i<lenData && (aData[i]=='$' || aData[i]=='*' || aData[i]=='-'  || aData[i]=='!'); ++j )
    { 
    if( aData[i]=='$' ) Mean.iNum=1;
    if( aData[i]=='*' ) Mean.iGen=1;
    if( aData[i]=='-' ) Mean.iGen=2;
    if( aData[i]=='!' ) Mean.iRef=1;

    ++i;    
    }

  if( i<lenData && aData[i]==',' ) ++i;                               // Si tremino en , la saltar.

  iTypes[iNTypes].iMean.Add( Mean );                 // Adiciona el significado     
                                      
  return MEAN_NEXT;                                       // Retorna buscar proxima acepcion
	}

bool CDictData::GetComplexType( CStringA& aType )
	{
  CComplexTypes Tipos;

  for( int j=0; j<iNTypes; ++j )   
    Tipos.AddSingleType( iTypes[j].iTipo );
  
  return Tipos.GetComplexType( aType );
	}

bool CDictData::GetFullType( CStringA& aType )
	{
	aType.Empty();

  CStringA cType;
  if (!GetComplexType( cType ))
    return FALSE; 

  aType = cType;

  for( int i=0; i<iNTypes; ++i ) 
    for( int j=0; j<iTypes[i].iMean.GetCount() ; ++j ) 
      {
      if( iTypes[i].iMean[j].iTerm )
        {
        CStringA* Esp = &iTypes[i].iMean[j].iEsp;

        if( Esp->Length()==2 )
        	{
          aType += _L8(';');
          aType += *Esp;
          aType += _L8(':');
          aType += iTypes[i].iTipo;
        	}
        }
      }

  return TRUE;
  }

int CDictData::GetIdxType( const CStringA& aType )
	{
  for( int i=0; i<iNTypes; ++i )
    if( iTypes[i].iTipo == aType)
      return i;

  return -1;
	}

CStringA* CDictData::GetSingleType( int aNType )
	{
  ASSERT( aNType>=0 && aNType<iNTypes );

  return &iTypes[aNType].iTipo;
	}

CStringA* CDictData::GetTypeCmds( int aNType )
	{
  ASSERT( aNType>=0 && aNType<iNTypes );

  return &iTypes[aNType].iCmds;
	}

CStringA* CDictData::GetMean( int aNType, int aNMean )
	{
  ASSERT( aNMean>=0 && aNMean<GetNMeans(aNType) );

  return &iTypes[aNType].iMean[aNMean].isMean;
	}

CStringA* CDictData::GetEsp( int aNType, int aNMean )
	{
  ASSERT( aNMean>=0 && aNMean<GetNMeans(aNType) );

  return &iTypes[aNType].iMean[aNMean].iEsp;
	}

bool CDictData::GetGen( int aNType, int aNMean )
	{
  ASSERT( aNMean>=0 && aNMean<GetNMeans(aNType) );

  return iTypes[aNType].iMean[aNMean].iGen != 0;
	}

bool CDictData::GetNum( int aNType, int aNMean )
	{
  ASSERT( aNMean>=0 && aNMean<GetNMeans(aNType) );

  return iTypes[aNType].iMean[aNMean].iNum != 0;
	}

bool CDictData::GetRef( int aNType, int aNMean )
	{
  ASSERT( aNMean>=0 && aNMean<GetNMeans(aNType) );

  return iTypes[aNType].iMean[aNMean].iRef != 0;
	}

bool CDictData::GetTerm( int aNType, int aNMean )
	{
  ASSERT( aNMean>=0 && aNMean<GetNMeans(aNType) );

  return iTypes[aNType].iMean[aNMean].iTerm != 0;
	}
