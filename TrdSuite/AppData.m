//
//  Langs.m
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//

#import "AppData.h"

//--------------------------------------------------------------------------------------------------------------------------------------------------------
int LGSrc = -1;
int LGDes = -1;
int iUser = 0;

float scrnWidth  = 320;           // Ancho de la pantalla
float EditMaxHeigth = 150;        // Altura máxima de los controles de edicción
float KbHeight = 0;               // Altura del teclado, si no esta desplegado es 0

TrdHistory *History;              // Oraciones ya traducidas para el idioma fuente seleccionado
UITextView* Responder;            // Vista donde se esta editando texto

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Matrix de direcciones de traduccion instaladas
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 1, 1, 0, 1 },
  /*En*/{ 1, 0, 1, 0, 1 },
  /*It*/{ 1, 1, 0, 0, 1 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 1, 1, 1, 0, 0 }
	};

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Abreviatura de de los idiomas segun el codigo ISO
static NSString *_AbrvLng[] = { @"Es", @"En", @"It", @"De", @"Fr" };

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Nombre de los idiomas de traduccion segun la interfaz de usuario
static NSString * _LngNames[5][5] =
  {  //Español  , Ingles     , Italiano      , Aleman     , Frances
    {@"Español" , @"Inglés"  , @"Italiano"   , @"Alemán"  , @"Francés"     },   // IUser Español
    {@"Spanish" , @"English" , @"Italian"    , @"German"  , @"French"      },   // IUser Inglés
    {@"Spagnolo", @"Inglese" , @"Italiano"   , @"Tedesco" , @"Francese"    },   // IUser Italiano
    {@"Spanisch", @"Englisch", @"Italienisch", @"Deustch" , @"Französisch" },   // IUser Alemán
    {@"Espagnol", @"Anglais" , @"Italien"    , @"Allemand", @"Français"    },   // IUser Francés
  };

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Tamaño de los botones para cada una de los idiomas
static int _LngSizes[5][5] =
  {// Español, Ingles, Italiano, Aleman, Frances
    { 53     , 40    , 48      , 80    , 53 },   // IUser Español
    { 53     , 47    , 40      , 80    , 45 },   // IUser Inglés
    { 63     , 48    , 48      , 80    , 60 },   // IUser Italiano
    { 71     , 66    , 82      , 80    , 85 },   // IUser Alemán
    { 60     , 48    , 40      , 80    , 55 },   // IUser Francés
  };

//--------------------------------------------------------------------------------------------------------------------------------------------------------
NSString* LGAbrv( int lng )
  {
  if( lng<0 || lng>4 ) return @"";

  return _AbrvLng[lng];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
NSString* LGName( int lng )
  {
  if( lng<0 || lng>4 ) return @"";

	return _LngNames[iUser][lng];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
int LGNameSz( int lng )
  {
  if( lng<0 || lng>4 ) return 0;

	return _LngSizes[iUser][lng];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
NSString* LGFlagFile( int lng, NSString* Suxfix )
  {
  if( lng<0 || lng>4 ) return @"";

  return [NSString stringWithFormat:@"Flag%@%@", _AbrvLng[lng], Suxfix];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si el lenguaje fuente 'lng' esta instalado
BOOL LGIsInstSrc( int lng )
  {
  if( lng<0 || lng>=LGCount ) return false;

  int *InstSrcs = _Inst[lng];
    
  for( int j=0; j<LGCount; ++j )
    if( InstSrcs[j] ) return TRUE;
  
  return FALSE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si el lenguaje destino 'lng' esta instalado para el idioma fuente actual
BOOL LGIsInstDes( int lng )
  {
  if( lng<0 || lng>LGCount || LGSrc<0 ) return false;

  int *InstSrcs = _Inst[LGSrc];
  
  return InstSrcs[ lng ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene un idioma destino inferido entre los idiomas instalados
int LGInferedDes( int srcOld )
  {
  if( LGSrc==LGDes && LGIsInstDes(srcOld) ) return srcOld;
  if( LGIsInstDes(LGDes) ) return LGDes;
  
  for( int j=0; j<LGCount; ++j )
    if( LGIsInstDes(j) ) return j;
    
  return -1;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Oculata el teclado si se esta mostrando
void HideKeyBoard()
  {
  if( Responder == nil ) return;
  
  [Responder resignFirstResponder];
  Responder = nil;
  }


//-------------------------------------------------------------------------------------------------------------------------------------------------------
// Identifica si el caracter 'i' de la cadena 'str' en una letra
BOOL IsLetter( NSInteger idx, NSString* Txt )
  {
  unichar c = [Txt characterAtIndex:idx];
  return [[NSCharacterSet alphanumericCharacterSet] characterIsMember:c];
  }

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el rectangulo 'rc' con bordes redondeados
void DrawRoundRect( CGRect rc, int Round, UIColor* ColBrd, UIColor* ColBody )
  {
  float RSup = (Round & R_SUP )? ROUND : 0;
  float RInf = (Round & R_INF )? ROUND : 0;
  
  float xIzq = rc.origin.x;
  float xDer = xIzq + rc.size.width;

  float ySup = rc.origin.y;
  float yInf = ySup + rc.size.height;
  
  float ycSup  = ySup + RSup;
  float xcSupI = xIzq + RSup;
  float xcSupD = xDer - RSup;

  float ycInf  = yInf - RInf;
  float xcInfI = xIzq + RInf;
  float xcInfD = xDer - RInf;
  
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
  CGContextSetStrokeColorWithColor(ct, ColBrd.CGColor);
  CGContextSetFillColorWithColor(ct, ColBody.CGColor);

  CGContextSetLineWidth(ct, BRD_W);
  
  CGContextBeginPath(ct);
  if( RInf == 0 )
    {
    CGContextMoveToPoint   (ct, xDer  , yInf  );
    CGContextAddLineToPoint(ct, xDer  , ycSup );
    CGContextAddArc        (ct, xcSupD, ycSup , RSup, 0      , -M_PI_2, 1 );
    CGContextAddLineToPoint(ct, xcSupI, ySup  );
    CGContextAddArc        (ct, xcSupI, ycSup , RSup, -M_PI_2, -M_PI  , 1 );
    CGContextAddLineToPoint(ct, xIzq  , yInf );
    }
  else
    {
    CGContextMoveToPoint   (ct, xcSupI, ySup  );
    CGContextAddArc        (ct, xcSupI, ycSup , RSup, -M_PI_2, -M_PI  , 1 );
    CGContextAddLineToPoint(ct, xIzq  , ycInf );
    CGContextAddArc        (ct, xcInfI, ycInf , RInf, -M_PI  ,  M_PI_2, 1 );
    CGContextAddLineToPoint(ct, xcInfD, yInf );
    CGContextAddArc        (ct, xcInfD, ycInf , RInf, M_PI_2 ,  0     , 1 );
    CGContextAddLineToPoint(ct, xDer  , ycSup );
    CGContextAddArc        (ct, xcSupD, ycSup , RSup, 0      , -M_PI_2, 1 );
  
    if( RSup>0 ) CGContextClosePath(ct);
    }
    
  CGContextDrawPath( ct, kCGPathFillStroke);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------------------
