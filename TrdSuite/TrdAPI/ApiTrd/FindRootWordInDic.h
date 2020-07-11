// FindRootWordInDic.h: interface for the CFindRootWordInDic class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_FINDROOTWORDINDIC_H__2FD52A24_24C6_11D3_8926_0060972DBBB5__INCLUDED_)
#define AFX_FINDROOTWORDINDIC_H__2FD52A24_24C6_11D3_8926_0060972DBBB5__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "TranslationDataObject.h"
#include "ListOfRoots.h"

class CFindRootWordInDic : public CTranslationDataObject  
{
private:
    CStringA m_sDirectPronoun;
    CStringA m_sIndirectPronoun;
    
protected:
    LPCWORD m_ptrWord;
    CPtrArray m_ListOfRoot;

    bool UpdateList(void);

    void SetDirectPronoun(const CStringA& sDirectPronoun)
        {m_sDirectPronoun = sDirectPronoun;}

    void SetIndirectPronoun(const CStringA& sIndirectPronoun)
        {m_sIndirectPronoun = sIndirectPronoun;}

	CDict *GetDictionary()
		{
		//return GetPtrTranslationData()->GetPtrTranslationDic();
		return GetTranslationUserPtr()->GetPtrTranslationDic();
		}
public:
    CFindRootWordInDic(CTranslationUser *ptrTranslationUser, LPCWORD ptrWord):CTranslationDataObject(ptrTranslationUser)
        {
        ASSERT(ptrWord != NULL);
        m_ptrWord = ptrWord;
        }

    ~CFindRootWordInDic()
        {
        m_ListOfRoot.RemoveAll();
        }

    bool UpdateWordData();

    CStringA &GetDirectPronoun()
        {return m_sDirectPronoun;}

    CStringA &GetIndirectPronoun()
        {return m_sIndirectPronoun;}
};

#endif // !defined(AFX_FINDROOTWORDINDIC_H__2FD52A24_24C6_11D3_8926_0060972DBBB5__INCLUDED_)
