/*
 ============================================================================
 Name		: DictData.h
 Author	  : 
 Version	 : 1.0
 Copyright   : Your copyright notice
 Description : CDictData declaration
 ============================================================================
 */

#ifndef DICTDATA_H
#define DICTDATA_H

// INCLUDES
#include "ComplexTypes.h"


#define MAX_TYPES 6

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

class CMean  
  {
  public:
    CMean()
      { iGen=iNum=iRef=iTerm=0; }

  void Copy( CMean &M)
    {
    iGen   = M.iGen  ;
    iNum   = M.iNum  ;
    iRef   = M.iRef  ;
    iTerm  = M.iTerm ;
    iEsp   = M.iEsp  ;
    isMean = M.isMean;
    }

  public:
  BYTE    	iGen;
  BYTE    	iNum;
  BYTE    	iRef;
  BYTE    	iTerm;
  TGramEsp 	iEsp;
  TGramMean isMean;
  };

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

class CType  
  {
  public:

  TGramType  iTipo;
  CStringA   iCmds;
  CArray<CMean> iMean;
  
  CType() {}
  ~CType() { iMean.Close(); }
  };


// CLASS DECLARATION

/**
 *  CDictData
 * 
 */
class CDictData
	{
public:
	// Constructors and destructor

	CDictData()
  	{
	  iIdxMean = -1;
	  iIdxType = -1;
  	}

	/**
	 * Destructor.
	 */
	~CDictData()
		{
		}

  TInt ParseTxt(const TDictData& aData);
  void GetDataText(TDictData& aData);
  //void GetDataXml(TDictData& aData);
  TInt GetTypesCount();
  TInt MeanCount(const CStringA& aType);
  TInt MeanCountAt(TInt aIdxType);
  void get_ActualCmds(CStringA& aCmds);
  void get_ActualMean(CStringA& aMean);
  void get_ActualEsp(TGramEsp& aEsp);
  TText get_ActualGen();
  TText get_ActualNum();
  TText get_ActualRef();
  TText get_ActualTerm();
  //void GetComplexType(TDes8& aType);
  TInt get_ActualTypeIdx();
  void put_ActualTypeIdx(TInt aIdx);
  TInt get_ActualMeanIdx();
  void put_ActualMeanIdx(TInt aIdx);
  void get_ActualType(CStringA& aType);
	
private:
  CType iTypes[ MAX_TYPES ];
  int   iNTypes;
  int		iIdxMean;
  int		iIdxType;

  void  	Clear();

  int    	SetDat( const CStringA& aData, const CStringA& aType );
  bool   	GetDat( TDictData& aData, CStringA& aType );

  bool   	GetComplexType( CStringA& aType );
  bool   	GetFullType   ( CStringA& aType );
  int    	GetIdxType    ( const CStringA& aType );
  
  CStringA* GetSingleType( int aNType );
  CStringA* GetTypeCmds  ( int aNType );

  CStringA* GetMean( int aNType, int aNMean );
  CStringA* GetEsp ( int aNType, int aNMean );
  bool   	GetGen ( int aNType, int aNMean );
  bool   	GetNum ( int aNType, int aNMean );
  bool   	GetRef ( int aNType, int aNMean );
  bool   	GetTerm( int aNType, int aNMean );

  bool 		GetDeafultType( const TGramType& Type );
  bool 		IsCondition( const CStringA& s, int &j );
  bool 		CopyData( const CStringA& aData, const CStringA& aType, int &i );
  bool 		GetMeans( const CStringA& aData, const CStringA& aType, int ini, int fin );
  int 		AddMean( const CStringA& aData, const CStringA& aType, int &i, int fin );


  inline int GetNTypes()
    {
    return iNTypes;
    }

  inline int GetNMeans( int nType )
    {
    ASSERT( nType>=0 && nType<iNTypes );

    return (int)iTypes[nType].iMean.GetCount();
    }
  
	};

#endif // DICTDATA_H
