//
//  Langs.m
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//

#import "AppData.h"
#import "ColAndFont.h"

//--------------------------------------------------------------------------------------------------------------------------------------------------------
NSString *const RefreshNotification = @"RefreshNotification";

//--------------------------------------------------------------------------------------------------------------------------------------------------------
int LGSrc = -1;
int LGDes = -1;
int iUser = 0;
BOOL iPad = FALSE;
int  iOS  = 7;

float EditMaxHeigth = 150;        // Altura máxima de los controles de edicción
float KbHeight = 0;               // Altura del teclado, si no esta desplegado es 0

UITextView* Responder;            // Vista donde se esta editando texto

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Matrix de direcciones de traduccion instaladas
#ifdef TrdSuiteEn
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 1, 0, 0, 0 },
  /*En*/{ 1, 0, 1, 0, 1 },
  /*It*/{ 0, 1, 0, 0, 0 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 0, 1, 0, 0, 0 }
	};

NSString* sPack = @"En";
#endif
#ifdef TrdSuiteEnEs
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 1, 0, 0, 0 },
  /*En*/{ 1, 0, 0, 0, 0 },
  /*It*/{ 0, 0, 0, 0, 0 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 0, 0, 0, 0, 0 }
	};

NSString* sPack = @"EnEs";
#endif
#ifdef TrdSuiteEnIt
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 0, 0, 0, 0 },
  /*En*/{ 0, 0, 1, 0, 0 },
  /*It*/{ 0, 1, 0, 0, 0 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 0, 0, 0, 0, 0 }
	};

NSString* sPack = @"EnIt";
#endif
#ifdef TrdSuiteEnFr
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 0, 0, 0, 0 },
  /*En*/{ 0, 0, 0, 0, 1 },
  /*It*/{ 0, 0, 0, 0, 0 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 0, 1, 0, 0, 0 }
	};

NSString* sPack = @"EnFr";
#endif
#ifdef TrdSuiteEs
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 1, 1, 0, 1 },
  /*En*/{ 1, 0, 0, 0, 0 },
  /*It*/{ 1, 0, 0, 0, 0 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 1, 0, 0, 0, 0 }
	};

NSString* sPack = @"Es";
#endif
#ifdef TrdSuiteEsIt
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 0, 1, 0, 0 },
  /*En*/{ 0, 0, 0, 0, 0 },
  /*It*/{ 1, 0, 0, 0, 0 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 0, 0, 0, 0, 0 }
	};

NSString* sPack = @"EsIt";
#endif
#ifdef TrdSuiteEsFr
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 0, 0, 0, 1 },
  /*En*/{ 0, 0, 0, 0, 0 },
  /*It*/{ 0, 0, 0, 0, 0 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 1, 0, 0, 0, 0 }
	};

NSString* sPack = @"EsFr";
#endif
#ifdef TrdSuiteIt
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 0, 1, 0, 0 },
  /*En*/{ 0, 0, 1, 0, 0 },
  /*It*/{ 1, 1, 0, 0, 1 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 0, 0, 1, 0, 0 }
	};

NSString* sPack = @"It";
#endif
#ifdef TrdSuiteItFr
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 0, 0, 0, 0 },
  /*En*/{ 0, 0, 0, 0, 0 },
  /*It*/{ 0, 0, 0, 0, 1 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 0, 0, 1, 0, 0 }
	};

NSString* sPack = @"ItFr";
#endif
#ifdef TrdSuiteFr
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 0, 0, 0, 1 },
  /*En*/{ 0, 0, 0, 0, 1 },
  /*It*/{ 0, 0, 0, 0, 1 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 1, 1, 1, 0, 0 }
	};

NSString* sPack = @"Fr";
#endif
#ifdef TrdSuiteAll
static int _Inst[LGCount][LGCount] =
	{
  //     Es,En,It,De,Fr
  /*Es*/{ 0, 1, 1, 0, 1 },
  /*En*/{ 1, 0, 1, 0, 1 },
  /*It*/{ 1, 1, 0, 0, 1 },
  /*De*/{ 0, 0, 0, 0, 0 },
  /*Fr*/{ 1, 1, 1, 0, 0 }
	};

NSString* sPack = @"All";
#endif

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
// Tamaño de los botones de los diferentes idiomas
static int _LngSizes[LGCount] = { 53, 40, 48, 80, 53 };
//--------------------------------------------------------------------------------------------------------------------------------------------------------
void LGSetNamesSize()
  {
  for( int i=0; i<LGCount; ++i )
    {
    CGSize sz = [_LngNames[iUser][i] sizeWithAttributes:attrBtns];
    _LngSizes[i] = sz.width + 1;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
int LGNameSz( int lng )
  {
  if( lng<0 || lng>4 ) return 0;

	return _LngSizes[lng];
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
// Determina si la direccion de traducción src -> des esta instalada o no
BOOL LGIsInstDir( int src, int des )
  {
  if( src<0 || src>=LGCount || des<0 || des>=LGCount ) return false;
  
  return _Inst[src][des];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
void LGSetInstDir( int src, int des )
  {
  if( src<0 || src>=LGCount || des<0 || des>=LGCount ) return;
  
  _Inst[src][des] = 1;
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
// Obtiene un idioma destino inferido entre los idiomas instalados
int LGFirstSrc()
  {
  for( int j=0; j<LGCount; ++j )
    if( LGIsInstSrc(j) ) return j;
    
  return -1;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el proximo idioma destino disponible
int LGNextDes()
  {
  for( int j=LGDes+1; j<LGCount; ++j )
    if( LGIsInstDes(j) ) return j;
    
  for( int j=0; j<LGDes; ++j )
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

//--------------------------------------------------------------------------------------------------------------------------------------------------------
NSString* FlagSpaces = @"       ";
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cantidad de espacios necesarios que hay que adicional a principio de la cadena, para que no se sobreponga con la bandera
void GetFlagSpaces()
  {
  NSMutableString* Txt = [NSMutableString stringWithString: @"    "];
  
  for(;;)
    {
    CGSize sz = [Txt sizeWithAttributes:attrHistory];
    
    if( sz.width >= 25 )
      {
      FlagSpaces = Txt;
      return;
      }
      
    [Txt appendString:@" "];
    }
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
static inline double radians (double degrees) {return degrees * M_PI/180;}

//--------------------------------------------------------------------------------------------------------------------------------------------------------
UIImage * RotateImg( UIImage* src, UIImageOrientation orientation)
  {
  UIGraphicsBeginImageContext( src.size );
  
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
       if( orientation == UIImageOrientationRight ) CGContextRotateCTM( ct, radians(90 ) );
  else if( orientation == UIImageOrientationLeft  ) CGContextRotateCTM( ct, radians(-90) );
  else if (orientation == UIImageOrientationUp    ) CGContextRotateCTM( ct, radians(90)  );

  [src drawAtPoint:CGPointMake(0, 0) ];
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return image;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga la imagen del lanzamiento de la aplización
UIImage* LoadLaunchImage()
  {
  NSDictionary *dOfLaunchImage = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"-568h@2x.png"              ,@"568,320,2,8,p",  // ios 8 - iphone 5 - portrait
                                    @"-568h@2x.png"              ,@"568,320,2,8,l",  // ios 8 - iphone 5 - landscape
                                    @"-700-568h@2x.png"          ,@"568,320,2,7,p",  // ios 7 - iphone 5 - portrait
                                    @"-700-568h@2x.png"          ,@"568,320,2,7,l",  // ios 7 - iphone 5 - landscape
                                    @"-700-Landscape@2x~ipad.png",@"1024,768,2,7,l", // ios 7 - ipad retina - landscape
                                    @"-700-Landscape~ipad.png"   ,@"1024,768,1,7,l", // ios 7 - ipad regular - landscape
                                    @"-700-Portrait@2x~ipad.png" ,@"1024,768,2,7,p", // ios 7 - ipad retina - portrait
                                    @"-700-Portrait~ipad.png"    ,@"1024,768,1,7,p", // ios 7 - ipad regular - portrait
                                    @"-700@2x.png"               ,@"480,320,2,7,p",  // ios 7 - iphone 4/4s retina - portrait
                                    @"-700@2x.png"               ,@"480,320,2,7,l",  // ios 7 - iphone 4/4s retina - landscape
                                    @"-Landscape@2x~ipad.png"    ,@"1024,768,2,8,l", // ios 8 - ipad retina - landscape
                                    @"-Landscape~ipad.png"       ,@"1024,768,1,8,l", // ios 8 - ipad regular - landscape
                                    @"-Portrait@2x~ipad.png"     ,@"1024,768,2,8,p", // ios 8 - ipad retina - portrait
                                    @"-Portrait~ipad.png"        ,@"1024,768,1,8,l", // ios 8 - ipad regular - portrait
                                    @".png"                      ,@"480,320,1,7,p",  // ios 6 - iphone 3g/3gs - portrait
                                    @".png"                      ,@"480,320,1,7,l",  // ios 6 - iphone 3g/3gs - landscape
                                    @"@2x.png"                   ,@"480,320,2,8,p",  // ios 6,7,8 - iphone 4/4s - portrait
                                    @"@2x.png"                   ,@"480,320,2,8,l",  // ios 6,7,8 - iphone 4/4s - landscape
                                    @"-800-667h@2x.png"          ,@"667,375,2,8,p",  // ios 8 - iphone 6 - portrait
                                    @"-800-667h@2x.png"          ,@"667,375,2,8,l",  // ios 8 - iphone 6 - landscape
                                    @"-800-Portrait-736h@3x.png" ,@"736,414,3,8,p",  // ios 8 - iphone 6 plus - portrait
                                    @"-800-Landscape-736h@3x.png",@"736,414,3,8,l",  // ios 8 - iphone 6 plus - landscape
                                    nil];
    
  CGSize sz = [UIScreen mainScreen].bounds.size;
  
  int width  = (sz.width>sz.height)? sz.width : sz.height;
  int height = (sz.width>sz.height)? sz.height: sz.width;
  int scale  = (int)[UIScreen mainScreen].scale;
    
  NSString *orient  = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])? @"l": @"p";
  NSString *ImgKey  = [NSString stringWithFormat : @"%d,%d,%d,%d,%@", width, height, scale, iOS, orient ];
  NSString *ImgEnd  = [dOfLaunchImage valueForKey: ImgKey];
  NSString *ImgName = [NSString stringWithFormat : @"LaunchImage%@%@", sPack, ImgEnd ];
  
  UIImage* Img = [UIImage imageNamed: ImgName];
  
  if( [orient isEqualToString:@"l"] && [ImgEnd rangeOfString:@"Landscape"].length==0)
    Img = RotateImg( Img, UIImageOrientationRight );
    
  return Img;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------------------
