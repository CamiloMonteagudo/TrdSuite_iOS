#pragma once

//------------------------------------------------------------------------------------
// Bit que define la caracteristica de cada caracter en el arreglo
// de definicion de caracteres.
//------------------------------------------------------------------------------------
#define  C_INI      1
#define  C_END      2
#define  C_NUM      4
#define  C_UP       8
#define  C_LOW      16
#define  C_ALFA     (C_LOW|C_UP)
#define  C_ALFANUM  (C_ALFA|C_NUM)

#define PACK(i,e,n,u,l) (i|(e<<1)|(n<<2)|(u<<3)|(l<<4) )

#define isc_ini(c)      (Keys[(BYTE)(c)] & C_INI)
#define isc_end(c)      (Keys[(BYTE)(c)] & C_END)
#define isc_num(c)      (Keys[(BYTE)(c)] & C_NUM)
#define isc_up(c)       (Keys[(BYTE)(c)] & C_UP)
#define isc_low(c)      (Keys[(BYTE)(c)] & C_LOW)
#define isc_alfa(c)     (Keys[(BYTE)(c)] & C_ALFA)
#define isc_alfanum(c)  (Keys[(BYTE)(c)] & C_ALFANUM)

/*------------------------------------------------------------------------------------*/
// Define un Item del parse de oraciones, estos item se caracterizan por su tipo, 
// por el texto que lo representa, por se traducción en el caso del tipo 't' y por la
// posición donde comienza su definición en el texto.
//<!----------------------------------------------------------------------------------->
class CItem: public CMFCObject
{ 
public:
  BYTE      m_Type;
  CStringA   m_Text;
  CStringA   m_Trd;
    
  //CItem( LPCSTR s, BYTE t='t' ) : m_Text(s), m_Type(t) {}   
  CItem( const CStringA& s, BYTE t='t' ) : m_Type(t), m_Text(s) {}   
  CItem() : m_Type('t') {}
};

/*------------------------------------------------------------------------------------*/
// Implementa el proseceso completo de separación de un texto en oraciones, hasta ahora
// se soportan textos con formatos TXT, RTF y HTML.
//<!----------------------------------------------------------------------------------->
class CParseText
  {
  public:
    CParseText(void);
    ~CParseText(void);

    CObArray  m_Items;       // Contiene todos los items analizados

    LPCSTR    m_Txt;          // Puntero al texto que se va a analizar
    long      m_len;          // Cantidad de caracteres del texto

    void SetText(CStringA& Text);
    bool Parse();
    CStringA GetTrdText();

  private:
    void ClearSetting(void);

    bool SkipNoText       (long& _i);
    bool GetTextOra       (long& _i);
    bool IsBullet         (long ini, long& i, CStringA& Cascara);
    bool isFile           (long& _i, CStringA& Ora);
    bool IsExt(long i);
    bool IsAbr(long i);

    bool AddItem(BYTE Type, const CStringA& Text);
    //bool AddItem(BYTE Type, LPCSTR Text);
  };
