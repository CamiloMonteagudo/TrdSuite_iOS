//
//  ProxyTrd.m
//  IdiomaXTranslator
//
//  Created by MacPC on 9/5/11.
//  Copyright 2011 IdiomaX. All rights reserved.
//

#import "ProxyTrd.h"
//#import "Languajes.h"

#import "WinUtil.h"
#import "ApiTrd.h"
#import "ParseText.h"

@implementation ProxyTrd

static HTRD _Trd    = NULL;
static int  _TrdSrc = -1;
static int  _TrdDes = -1;

//------------------------------------------------------------------------------------------------------
// Abre una direccion de traduccion
+(bool) OpenSrc: (int)src Des: (int)des
  {
  if( _Trd != NULL && _TrdSrc==src && _TrdDes==des )
    return TRUE;
  
  if( _Trd != NULL ) TDFree( _Trd );
  
  CStringA sPath = [[[NSBundle mainBundle] bundlePath] cStringUsingEncoding:NSISOLatin1StringEncoding];
  
  _Trd = TDNew();
  
  TDSetPath(_Trd, sPath, PATH_TRAD);
  TDSetPath(_Trd, sPath, PATH_LANG);
  
  bool res = TDOpen(_Trd, src, des );
  if( res ) 
    {
    _TrdSrc = src;
    _TrdDes = des;
    return TRUE;
    }
  else
    {
    TDFree( _Trd );
    _Trd = NULL;
    
    NSLog( @"No se puedo abrir la direccion de traduccion" );
    return FALSE;
    }
  }

//------------------------------------------------------------------------------------------------------
// Cierra la direccion de traduccion abierta
+(void) Close
  {
  if( _Trd != NULL ) TDFree( _Trd );
  
  _Trd    = NULL;
  _TrdSrc = -1;
  _TrdDes = -1;
  }    
  
//------------------------------------------------------------------------------------------------------
// Traduce un texto en la direccion actual
+(NSString *) TranslateText: (NSString *) Txt Prog: (UIProgressView *)Progress
  {
  if( _Trd == NULL ) return @"";
  
  HUTRD hUser = TDOpenUser((void*)_Trd);
  
  CStringA sSrcText = [Txt cStringUsingEncoding:NSISOLatin1StringEncoding ];
  CParseText ps;
  
  ps.SetText(sSrcText);
  ps.Parse();
  
  TInt     n = ps.m_Items.GetCount();                            // Obtiene numero de item en el parse
//  float step = 1.0 / n;
  for( TInt i=0; i<n; ++i )                                      // Recorre todos los items
    {
    CItem *Item = (CItem *)ps.m_Items[i];
    BYTE Type = Item->m_Type;
    
    if( Type=='t' )                                              // Es un item de traducción
      {
      TDSetSentence( hUser,  Item->m_Text);
      TDTranslate( hUser, 0 );
      
      Item->m_Trd = TDGetSentence( hUser );
      }
    
//    Progress.progress += step;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
    }
  
  CStringA sTrdText = ps.GetTrdText();  
  
  TDFreeUser(hUser);
  
//  Progress.progress = 1;
  return [NSString stringWithCString:sTrdText.c_str() encoding:NSISOLatin1StringEncoding ];
  }    

//------------------------------------------------------------------------------------------------------

@end
