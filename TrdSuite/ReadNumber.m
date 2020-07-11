//=========================================================================================================================================================
//  ReadNumber.m
//  TrdSuite
//
//  Created by Camilo on 24/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "ReadNumber.h"
#import "ColAndFont.h"

//================================================== Definicion de las pronuciaciones  ====================================================================
CentLangInfo LangEs =                             // Definiciones para ESPAÑOL
  {
  // Formación de números hasta mil
  @[ @"", @"uno "   , @"dos "       , @"tres "       , @"cuatro "       , @"cinco "      , @"seis "       , @"siete "       , @"ocho "       , @"nueve "       ],
  @[ @"", @"dieci"  , @"veinti"     , @"treinta y "  , @"cuarenta y "   , @"cincuenta y ", @"sesenta y "  , @"setenta y "   , @"ochenta y "  , @"noventa y "   ],
  @[ @"", @"ciento ", @"doscientos ", @"trescientos ", @"cuatrocientos ", @"quinientos " , @"seiscientos ", @"sietecientos ", @"ochocientos ", @"novecientos " ],

  // Casos especiales para las decenas y centenas exactas
  @[ @"", @"diez ", @"veinte "    , @"treinta "    , @"cuarenta "     , @"cincuenta " , @"sesenta "    , @"setenta "    , @"ochenta "    , @"noventa "    ],
  @[ @"", @"cien ", @"doscientos ", @"trescientos ", @"cuatrocientos ", @"quinientos ", @"seiscientos ", @"setecientos ", @"ochocientos ", @"novecientos "],

  // Sufijos utilizados para los multiplos de mil (10 a la 3) sistema largo
  @[ @"", @"mil ",  @"millones "  , @"mil ", @"billones " , @"mil ", @"trillones " , @"mil ", @"cuatrillones " , @"mil ", @"quintillones " , @"mil " , @"sextillones "  , @"mil ", @"septillones " , @"mil " , @"octillones " , @"mil ", @"nonillones "  , @"mil " , @"decillones " , @"mil " ],
  @[ @"", @"mil ",  @"un millon " , @"mil ", @"un billon ", @"mil ", @"un trillon ", @"mil ", @"un cuatrillon ", @"mil ", @"un quintillon ", @"mil " , @"un sextillon " , @"mil ", @"un septillon ", @"mil " , @"un octillon ", @"mil ", @"un nonillon " , @"mil " , @"un decillon ", @"mil " ],
 
  // Irregularidades en los numeros de la mitad inferior de las decenas
  @[ @"", @"once ", @"doce ", @"trece ", @"catorce ", @"quince " ],
  
  // Números ordinales
  @[ @"", @"primero "  , @"segundo "    , @"tercero "     , @"cuarto "          , @"quinto "       , @"sexto "       , @"séptimo "        , @"octavo "        , @"noveno "         ],
  @[ @"", @"décimo "   , @"vigésimo "   , @"trigésimo "   , @"cuadragésimo "    , @"quincuagésimo ", @"sexagésimo "  , @"septuagésimo "   , @"octogésimo "    , @"nonagésimo "     ],
  @[ @"", @"centésimo ", @"ducentésimo ", @"tricentésimo ", @"cuadringentésimo ", @"quingentésimo ", @"sexcentésimo ", @"septingentésimo ", @"octingentésimo ", @"noningentésimo " ],

  @[ @"", @"milésimo ", @"millonésimo ", @"mil millonésimo ", @"billonésimo ", @"mil billonésimo ", @"trillonésimo ", @"mil trillonésimo ", @"cuatrillonésimo ", @"mil cuatrillonésimo ", @"quintillonésimo ", @"mil quintillonésimo ", @"sextillonésimo ", @"mil sextillonésimo ", @"septillonésimo ", @"mil septillonésimo ", @"octillonésimo ", @"mil octillonésimo ", @"nonillonésimo ", @"mil nonillonésimo ", @"decillonécimo ", @"mil decillonésimo " ],

  @[ @"", @"undécimo ", @"duodécimo ", @"tredécimo " ],

  // Números Romanos
  @[ @"", @"I", @"II", @"III", @"IV", @"V", @"VI", @"VII", @"VIII", @"IX" ],
  @[ @"", @"X", @"XX", @"XXX", @"XL", @"L", @"LX", @"LXX", @"LXXX", @"XC" ],
  @[ @"", @"C", @"CC", @"CCC", @"CD", @"D", @"DC", @"DCC", @"DCCC", @"CM" ],

  @[ @"", @"M", @"MM", @"MMM" ],
  };


//---------------------------------------------------------------------------------------------------------------------------------------------------------
CentLangInfo LangEn =                             // Definiciones para INGLÉS
  {
  // Formación de números hasta mil
  @[ @"", @"one "        , @"two "        , @"three "        , @"four "        , @"five "        , @"six "        , @"seven "         , @"eight "        , @"nine "        ],
  @[ @"", @""            , @"twenty-"     , @"thirty-"       , @"fourty-"      , @"fifty-"       , @"sixty-"      , @"seventy-"       , @"eighty-"       , @"ninety-"      ],
  @[ @"", @"one hundred ", @"two hundred ", @"three hundred ", @"four hundred ", @"five hundred ", @"six hundred ", @"seven hundred  ", @"eight hundred ", @"nine hundred "],

  // Casos especiales para las decenas y centenas exactas
  @[ @"", @"ten "        , @"twenty "     , @"thirty "       , @"fourty "      , @"fifty "       , @"sixty "      , @"seventy "      , @"eighty "       , @"ninety "      ],
  @[ @"", @"one hundred ", @"two hundred ", @"three hundred ", @"four hundred ", @"five hundred ", @"six hundred ", @"seven hundred ", @"eight hundred ", @"nine hundred "],

  // Sufijos utilizados para los multiplos de mil (10 a la 3) sistema corto
  @[ @"", @"thousand "    , @"million "    , @"billion "    , @"trillion "    , @"quadrillion "     , @"quintillion "    , @"sixtillion "    , @"septillion "    , @"octillion "   , @"nonillion "    , @"decillion "    , @"undecillion "    , @"duodecillion "    , @"tredecillion "    , @"quattuordecillion "    , @"quindecillion "    , @"sexdecillion "    , @"septendecillion "    , @"octodecillion "    , @"novemdecillion "    , @"vigintillion "     ],
  @[ @"", @"one thousand ", @"one million ", @"one billion ", @"one trillion ", @"one quadrillion ", @"one quintillion ", @"one sixtillion ", @"one septillion ", @"one octillion ", @"one nonillion ", @"one decillion ", @"one undecillion ", @"one duodecillion ", @"one tredecillion ", @"one quattuordecillion ", @"one quindecillion ", @"one sexdecillion ", @"one septendecillion ", @"one octodecillion ", @"one nevemdecillion ", @"one vigintillion " ],
 
  // Irregularidades en los numeros de la mitad inferior de las decenas
  @[ @"", @"eleven ", @"twelve ", @"thirteen ", @"fourteen", @"fiftheen ", @"sexteen ", @"seventeen ", @"eigtheen ", @"nineteen " ],
  
  // Números ordinales
  @[ @"", @"first "    , @"second "       , @"third "          , @"fourth "        , @"fifth "         , @"sixth "        , @"seventh "        , @"eighth "         , @"ninth "          ],
  @[ @"", @"tenth "    , @"twentieth "    , @"thirtieth "      , @"fortieth "      , @"fiftieth "      , @"sixtieth "     , @"seventieth "     , @"eightieth "      , @"ninetieth "      ],
  @[ @"", @"hundredth ", @"two hundredth ", @"three hundredth ", @"four hundredth ", @"five hundredth ", @"six hundredth ", @"seven hundredth ", @"eight hundredth ", @"nine hundredth " ],

  @[ @"", @"thousandth ", @"millionth ", @"billionth ", @"trillionth ", @"quadrillonth ", @"quintillionth ", @"sixtillionth ", @"septillionth ", @"octillionth ", @"nonillionth ", @"decillionth ", @"undecillionth ", @"duodecillionth ", @"tredecillionth ", @"quattuordecillionth ", @"quindecillionth ", @"sexdicillionth ", @"septendecillionth ", @"octodecillionth ", @"novemdecillionth ", @"vigintillionth " ],

  @[ @"", @"eleventh ", @"twelfth ", @"thirteenth ", @"fourteenth ", @"fifteenth ", @"sixteenth ", @"seventeenth ", @"eighteenth ", @"nineteenth " ],

  // Números Romanos
  @[ @"", @"I", @"II", @"III", @"IV", @"V", @"VI", @"VII", @"VIII", @"IX" ],
  @[ @"", @"X", @"XX", @"XXX", @"XL", @"L", @"LX", @"LXX", @"LXXX", @"XC" ],
  @[ @"", @"C", @"CC", @"CCC", @"CD", @"D", @"DC", @"DCC", @"DCCC", @"CM" ],

  @[ @"", @"M", @"MM", @"MMM" ],
  };


//---------------------------------------------------------------------------------------------------------------------------------------------------------
CentLangInfo LangIt =                             // Definiciones para ITALIANO
  {
  // Formación de números hasta mil
  @[ @"", @"uno"  , @"due"     , @"tre"     , @"quattro"     , @"cinque"     , @"sei"     , @"sette"     , @"otto"     , @"nove"      ],
  @[ @"", @"dieci", @"venti"   , @"trenta"  , @"quaranta"    , @"cinquanta"  , @"sessanta", @"settanta"  , @"ottanta"  , @"novanta"   ],
  @[ @"", @"cento", @"duecento", @"trecento", @"quattrocento", @"cinquecento", @"seicento", @"settecento", @"ottocento", @"novecento" ],

  // Casos especiales para las decenas y centenas exactas
  @[ @"", @"dieci", @"vent"    , @"trent"   , @"quarant"     , @"cinquant"   , @"sessant" , @"settant"   , @"ottant"   , @"novent"    ],
  @[ @"", @"cento", @"duecento", @"trecento", @"quattrocento", @"cinquecento", @"seicento", @"settecento", @"ottocento", @"novecento" ],

  // Sufijos utilizados para los multiplos de mil (10 a la 3) sistema largo
  @[ @"", @"mila" , @" milioni "    , @" miliardi "   , @" bilioni "   , @" biliardi "   , @" trilioni "   , @" triliardi "   , @" quadrilioni "   , @" quadriliardi "   , @" quintilioni "   , @" quintiliardi "   , @" sestilioni "   , @" sestiliardi "  , @" settilioni "   , @" settiliardi "    ],
  @[ @"", @"mille", @" un millione ", @" un miliardo ", @" un bilione ", @" un biliardo ", @" un trilione ", @" un triliardo ", @" un quadrilione ", @" un quadriliardo ", @" un quintilione ", @" un quintiliardo ", @" un sestilione ", @"un sestiliardo ", @" un settilione ", @" un settiliardo " ],
 
  // Irregularidades en los numeros de la mitad inferior de las decenas
  @[ @"", @"undici", @"dodici", @"tredici", @"quattordici", @"quindici", @"sedici", @"diciassete", @"diciotto", @"diciannove" ],
  
  // Números ordinales
  @[ @"", @"primo "    , @"secondo "     , @"terzo "       , @"quarto "         , @"quinto "         , @"sesto "        , @"settimo "       , @"ottavo "       , @"nono "         ],
  @[ @"", @"decimo "   , @"ventesimo "   , @"trentesimo "  , @"quarantesimo "   , @"cinquantesimo "  , @"sessantesimo " , @"settantesimo "  , @"ottantesimo "  , @"novantesimo "  ],
  @[ @"", @"centesimo ", @"duecentesimo ", @"trecentesimo ", @"cuatrocentesimo ", @"cinquecentesimo ", @"seicentesimo " , @"settecentesimo ", @"ottocentesimo ", @"novacentesimo" ],

  @[ @"", @"millesimo", @"milionesimo ", @"miliardesimo ", @"bilionesimo ", @"biliardesimo ", @"trilionesimo ", @"triliardesimo ", @"quadrilionesimo ", @"quadriliardesimo ", @"quintilionesimo ", @"quintiliardesimo ", @"sestilionesimo ", @"sestiliardesimo ", @"settilionesimo ", @"settiliardesimo " ],

  @[ @"", @"undicesimo ", @"dodicesimo ", @"tredicesimo ", @"quattordicesimo ", @"quindicesimo ", @"sedicesimo ", @"diciassettesimo ", @"diciossettesimo ", @"diciannovesimo" ],

  // Números Romanos
  @[ @"", @"I", @"II", @"III", @"IV", @"V", @"VI", @"VII", @"VIII", @"IX" ],
  @[ @"", @"X", @"XX", @"XXX", @"XL", @"L", @"LX", @"LXX", @"LXXX", @"XC" ],
  @[ @"", @"C", @"CC", @"CCC", @"CD", @"D", @"DC", @"DCC", @"DCCC", @"CM" ],

  @[ @"", @"M", @"MM", @"MMM" ],
  };


//---------------------------------------------------------------------------------------------------------------------------------------------------------
CentLangInfo LangFr =                             // Definiciones para FRANCÉS
  {
  // Formación de números hasta mil
  @[ @"", @"un "  , @"deux "      , @"trois "      , @"quatre "      , @"cinq "      , @"six "      , @"sept "      , @"huit "        , @"neuf "         ],
  @[ @"", @""     , @"vingt-"     , @"trente-"     , @"quarante-"    , @"cinquante-" , @"soixante-" , @"soixante-"  , @"quatre-vingt-", @"quatre-vingt-" ],
  @[ @"", @"cent ", @"deux cents ", @"trois cents ", @"quatre cents ", @"cinq cents ", @"six cents ", @"sept cents ", @"huit cents "  , @"neuf cents "   ],

  // Casos especiales para las decenas y centenas exactas
  @[ @"", @"dix ", @"vingt "      , @"trente "     , @"quarante "    , @"cinquante " , @"soixante " , @"soixante-dix ", @"quatre-vingts ", @"quatre-vingt-dix " ],
  @[ @"", @"cent ", @"deux cents ", @"trois cents ", @"quatre cents ", @"cinq cents ", @"six cents ", @"sept cents "  , @"huit cents "   , @"neuf cents "       ],

  // Sufijos utilizados para los multiplos de mil (10 a la 3) sistema largo
  @[ @"", @"mile ", @"million " , @"milliard ", @"billion ", @"billiard ", @"trillion ", @"trilliard ", @"quadrillion " , @"quadrilliard " , @"quintillion " , @"quintilliard ", @"sextillion ", @"sextilliard ", @"septillion " , @"septilliard ", @"octillion ", @"octilliard ", @"nonillion ", @"nonilliard ", @"décillion " , @"décilliard " ],
  @[ @"", @"mile ", @"million " , @"milliard ", @"billion ", @"billiard ", @"trillion ", @"trilliard ", @"quadrillion " , @"quadrilliard " , @"quintillion " , @"quintilliard ", @"sextillion ", @"sextilliard ", @"septillion " , @"septilliard ", @"octillion ", @"octilliard ", @"nonillion ", @"nonilliard ", @"décillion " , @"décilliard " ],
 
  // Irregularidades en los numeros de la mitad inferior de las decenas
  @[ @"", @"onze ", @"douze ", @"treize ", @"quatorze ", @"quinze ", @"seize ", @"dix-sept ", @"dix-huit ", @"dix-neuf " ],
  
  // Números ordinales
  @[ @"", @"premier"  , @"deuxième "     , @"troisième "     , @"quatrième "      , @"cinquième "    , @"sixième "     , @"septième "        , @"huitième "        , @"neuvième "             ],
  @[ @"", @"dixième " , @"vingtième "    , @"trentième "     , @"quarantième "    , @"cinquantième " , @"soixantième " , @"soixante-dixième ", @"quatre-vingtième ", @"quatre-vingt-dixième " ],
  @[ @"", @"centième ", @"deux centième ", @"trois centième ", @"quatre centième ", @"cinq centième ", @"six centième ", @"sept centième "   , @"huit centième "   , @"neuf centième "        ],

  @[ @"", @"milliéme ", @"millioniéme ", @"milliardiéme ", @"billioniéme ", @"billiardiéme ", @"trillioniéme ", @"trilliadiéme ", @"quadrillioniéme ", @"quadrilliardiéme ", @"quintillioniéme ", @"quintilliardiéme ", @"sextillioniéme ", @"sextilliardiéme ", @"septillioniéme ", @"octillioniéme ", @"octilliardiéme ", @"nonillioniéme ", @"nonilliardiéme ", @"decillioniéme ", @"decilliardiéme " ],

  @[ @"", @"onzième ", @"douzième ", @"treizième ", @"quatorzième ", @"quinzième ", @"seizième ", @"dix-septième", @"dix-huitième ", @"dix-neuvième " ],

  // Números Romanos
  @[ @"", @"I", @"II", @"III", @"IV", @"V", @"VI", @"VII", @"VIII", @"IX" ],
  @[ @"", @"X", @"XX", @"XXX", @"XL", @"L", @"LX", @"LXX", @"LXXX", @"XC" ],
  @[ @"", @"C", @"CC", @"CCC", @"CD", @"D", @"DC", @"DCC", @"DCCC", @"CM" ],

  @[ @"", @"M", @"MM", @"MMM" ],
  };

//---------------------------------------------------------------------------------------------------------------------------------------------------------
CentLangInfo AllLangs[] = { LangEs, LangEn, LangIt, LangFr };

// Forma corta de decir uno, como en 21000, 31000 ect.
NSArray* OneShort = @[@"un ", @"one ", @"uno ", @"un " ];

//====================================================== Clase CenteInfo  =================================================================================
// Guarda la información de hasta 3 digitos, que forman una centena, o parte de ella

@implementation CenteInfo
//----------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa un objeto con una cadena y el indice al primer digito de la centena (los digitos se toman de atras hacia adelante)
+(id) InfoWithString:(NSString*) sNum FromIndex:(int) ini
  {
  CenteInfo* cInfo = [CenteInfo new];
  
  cInfo.valUnid = ([sNum characterAtIndex:ini] - '0');
  cInfo.valDec  = (ini-1 < 0) ? NoDef : ([sNum characterAtIndex:ini-1] - '0');
  cInfo.valCent = (ini-2 < 0) ? NoDef : ([sNum characterAtIndex:ini-2] - '0');

  cInfo.AllCero = ( cInfo.valUnid==0 && cInfo.valDec<=0 && cInfo.valCent<=0 );

  cInfo.sUnid  = @"";
  cInfo.sDec   = @"";
  cInfo.sCent  = @"";
  cInfo.Subfix = @"";
  
  return cInfo;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Pone la informacion de idioma para leer cada digito de la centena de forma regular
-(void) SetRegularReadForLang:(CentLangInfo) info
  {
  if( _AllCero ) return;                                      // Todos los número son cero, no hace nada

  if( _valDec==0 && _valUnid==0 )                             // Un número seguido de dos ceros
    {
    _sCent = info.CentExactas[_valCent];                      // Pone pronuciación de las centenas solamente
    return;                                                   // y teramina
    }

  if( _valUnid==0 )                                           // El último número de la centena es cero
    {
    _sDec = info.DeceExactas[_valDec];                        // Pone pronuciación de las decenas (ignora las unidades)

    if( _valCent != NoDef )                                   // Si el valor de las centenas esta definido
      _sCent = info.Centenas[_valCent];                       // Pone pronunciación de las centenas

    return;                                                   // Termina
    }

  _sUnid = info.Unidades[_valUnid];                           // No hay terminaciones en cero, pone pronunciación de los 3 digitos

  if( _valDec  != NoDef ) _sDec  = info.Decenas[_valDec];
  if( _valCent != NoDef ) _sCent = info.Centenas[_valCent];
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una cadena con la lectura de la centena representada
-(NSString*) Read
 {
 return [NSString stringWithFormat:@"%@%@%@%@", _sCent, _sDec, _sUnid, _Subfix];
 }

@end

//==================================================== Clase ReadNumber  ==================================================================================
// Maneja como se lee un número en un idioma determinado
@interface ReadNumber ()
  {
  int       lng;                          // Idioma que se esta trabajando
  NSString* Num;                          // Cadena con el número que se esta analizando

  BOOL   ParCol;                          // Define color par o inpar para el texto
  
  // bool negative;                                  // Indica si el número es negativo

  CentLangInfo    LngInfo;                // Información de idioma para leer el número
  NSMutableArray* NumInfo;                // Informacion sobre el número actual expresado como una lista de centenas
  }
@end

//=========================================================================================================================================================
@implementation ReadNumber
//----------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa un objeto con un idioma y una cadena
+(id) NumberWithString:(NSString*) sNum Lang:(int) lang
  {
  ReadNumber* This = [ReadNumber new];
  
 int nLng = sizeof(AllLangs)/sizeof(AllLangs[0]);
 
  if( lang<0 || lang>= nLng )                                                       // Si el idioma esta fuera del rango definido en 'AllLangs'
    lang = 0;                                                                       // Fuerza a que tenga un valor correcto

  This->lng = lang;                                                                 // Pone el idioma actual
  This->Num = sNum;                                                                 // Pone el número actual

  This->LngInfo = AllLangs[lang];                                                   // Pone la informacion de idioma actual
  
  return This;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cantidad máxima de digitos permitidos para un idioma determinado
+(int) MaxDigistInLang:(int) lang
  {
 int nLng = sizeof(AllLangs)/sizeof(AllLangs[0]);
 
  if( lang<0 || lang>= nLng )                                                       // Si el idioma esta fuera del rango definido en 'AllLangs'
    lang = 0;                                                                       // Fuerza a que tenga un valor correcto

  CentLangInfo info = AllLangs[lang];
  
  return 3*(int)info.SufixPlural.count;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
//
-(NSAttributedString*) ReadCardinalAll
  {
  NSString* sNum = [self StringClearIniCeros: false ];                              // Limpia la cadena de los caracteres no significativos

  ParCol = FALSE;
  return [self FormatString: sNum ];                                                // Lee la cadena en el idioma actual
	}

//----------------------------------------------------------------------------------------------------------------------------------------------
// Retorna el resultado de leer la cadena actual, agrupando los digitos en la cantidad dada por 'grp'
-(NSAttributedString*) ReadCardinalByGroup:(int) grp
  {
  NSString* sNum = [self StringClearIniCeros: true ];                               // Limpia la cadena actual de los caracteres que sobran (ni limpia el inicio)

  NSArray* sGrps = [self GetGroups: grp FromStr: sNum ];                            // Divide la cadena según la catidad de caraceteres por grupo especificada

  NSCharacterSet* sp = [NSCharacterSet whitespaceCharacterSet];
  
  NSMutableAttributedString* Str = [[NSMutableAttributedString alloc] init];
  
  ParCol = FALSE;
  for( int i=0; i<sGrps.count ; ++i )                                               // Recorre todos los grupos obtenidos
    {
    NSString* str1 = [self ReadCerosFormStr: sGrps[i]];                             // Lee el los cero que esta a la izquierda, para el idioma actual
    NSString* str2 = [self ReadString: sGrps[i] ];                                  // Lee el grupo actual para el idioma actual
    NSString* str  = [str1 stringByAppendingString:str2];                           // Agrega el numero leido

    str = [str stringByTrimmingCharactersInSet:sp];                                 // Quita el espacio del final
    
    if( i<sGrps.count-1 )                                                           // Si no es el primer grupo
      str = [str stringByAppendingString:@"; "];                                    // Agrega un separador

    [self AttrStr:str In:Str];
    }

    return Str;                                                                     // Retorna el resultado
	  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Quita todos los caracteres de la cadena que no son validos, 'clearIni' indica que se quieren saltar los caracteres iniciales no validos
-(NSString*) StringClearIniCeros:(bool) IniCeros
  {
  NSMutableString* sNum = [NSMutableString stringWithCapacity: Num.length];

  int len = (int)Num.length;
  for( int i=0; i<len; ++i )                                                      // Recorre todos los caracteres de la cadena
    {
    const unichar c = [Num characterAtIndex:i];

    if( c=='0' && sNum.length==0  && !IniCeros )                                  // Quita todos los ceros de la izquierda
      continue;

    if( c==' ' ) continue;                                                        // Si hay un espacio lo concidera un separador

    if( c<'0' || c>'9' ) break;                                                   // Si el caracter no es un numero, corta la cadena
  
    [sNum appendString: [NSString stringWithCharacters:&c length:1] ];            // Toma el caracter como valido
    }

  return sNum;                                                                    // Retorna la cadena limpia
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Divide la cadena 'sNum' en grupos del tamaño 'grp' y retorna una lista con todos los grupos obtenidos
-(NSArray*) GetGroups:(int) grp FromStr:(NSString*) sNum
  {
  NSMutableArray* lst = [NSMutableArray arrayWithCapacity:10];
  
  for( int i=0; i<sNum.length; i+=grp )
    {
    int n   = (i+grp >= (int)sNum.length)? (int)sNum.length-i : grp;
    int ini = i;

    NSRange rg = NSMakeRange(ini ,n);
    [lst addObject: [sNum substringWithRange:rg ]];
    }

  return lst;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Lee y retorna la pronunciación de los ceros que se encuentran a la derecha de 'sNum'
NSArray* sCeros = @[ @"cero ", @"zero ", @"zero ", @"zéro " ];                         // Pronunciación de cero en los 4 idiomas

-(NSString*) ReadCerosFormStr:(NSString*) sNum
  {
  NSString* str = @"";

  int IzqCero = 0;                                                                // Contador del número de ceros a la izquierda
  for( int i=0; i<sNum.length; ++i )                                              // Recorre todos lo digitos
    {
    if( [sNum characterAtIndex:i] != '0' )  break;                                // Si encuantra un digito que no es cero termina la busqueda
        
    ++IzqCero;                                                                    // Incrementa el contador de ceros
    str = [str stringByAppendingString:sCeros[lng]];                              // Lo agrega a la cadena de pronunciación
    }

  if( IzqCero>0 )                                                                 // Si encontro algún cero a la izquierda
    sNum = [sNum substringFromIndex:IzqCero];                                     // los quita de la cadena original

  return str;                                                                     // Retorna pronunciación de ceros encontrados
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cadena resultante de leer la cadena númerica 'sNum'
-(NSString*) ReadString:(NSString*) num
  {
  [self ProcessStrNum:num];
  
  return [self StringNumber];
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cadena resultante de leer la cadena númerica 'sNum'
-(NSAttributedString*) FormatString:(NSString*) num
  {
  [self ProcessStrNum:num];
  
  return [self FormatNumber];
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Procesa el numero expresado a traves de la cadena 'sNum'
-(BOOL) ProcessStrNum:(NSString*) num
  {
  int len = (int)num.length;
  
  NumInfo = [NSMutableArray arrayWithCapacity:len/3+1];

  for( int i=len-1; i >= 0; i -= 3)                                               // Recorre la cadena de 3 en 3
    {
    CenteInfo* cent = [CenteInfo InfoWithString:num FromIndex:i];                 // Obtiene la información de una centena a partir de i

    [cent SetRegularReadForLang:LngInfo];

    [NumInfo addObject: cent ];                                                   // Guarda la información en 'NumInfo' agrupada en centenas
    }

  if( NumInfo.count == 0 ) return FALSE;
  
  [self FixLowDecenas];                                                           // Aregla la parte inferior de las decenas Ej: 12, 13, 14 ...
  [self SetLargeSufixes];                                                         // Pone los sifijos a las centenas de acuerdo a su posición en el número
  
  if( lng == 1 ) [self SetAnd];
  if( lng == 2 ) [self FixUnoOcho];
  if( lng == 3 ) [self FixFrenchDec];
  
  return TRUE;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Corrige las irregularidades de los numeros inferiores de las decenas 11,12,13,14,15 ....
-(void) FixLowDecenas
  {
  NSArray* DecInfo = LngInfo.FixDecenas;                                          // Obtiene información para el idioma actual de las decenas

  for( int i=0; i<NumInfo.count; ++i )                                            // Recorre todas las centenas
    {
    CenteInfo* cent = NumInfo[i];                                                 // Obtiene información de la centena actual
    int nUni = cent.valUnid;                                                      // Obtiene el número de unidades
    
    if( cent.valDec == 1 && nUni>0 && nUni<DecInfo.count )                        // Si el decimal es uno y las unidades estan incluidas detro de DecInfo
      {
      cent.sUnid = @"";                                                           // Borra pronuciación para las unidades
      cent.sDec  = DecInfo[nUni];                                                 // Pone pronunciación corregida en las decenas
      }
    }
  }
  
//----------------------------------------------------------------------------------------------------------------------------------------------
// Pone todos los sufijos a la información almacenada en NumInfo
-(void) SetLargeSufixes
  {
  int nCent = (int)NumInfo.count;                                                 // Número de centenas que forman el número

  for( int i=1; i<nCent; ++i )                                                    // Recorre todas las centenas (Saltandose la primera)
    {
    CenteInfo* cent = NumInfo[i];                                                 // Obtiene información de la centena actual
    if( cent.AllCero )                                                            // si todos los numeros son cero
      {
      if( lng==0 && i%2==0 && i<nCent-1)                                          // Idioma español, una centena par que no es la última
        {
        CenteInfo* nextCent = NumInfo[i+1];                                       // Toma la centena proxima
        if( !nextCent.AllCero )                                                   // Si la centena proxima no es cero tambien
          cent.Subfix = LngInfo.SufixPlural[i];                                   // Pone el sufijo en plural  (para poner "mil millones" Ej: 1 000 000 000)
        }
           
      continue;                                                                   // Continua con la proxima centena
      }

    if( cent.valUnid == 1  )                                                      // Si la centena termina en un uno
      {
      if( cent.valDec<=0 && cent.valCent<=0 )                                     // Si solo un uno (los otros no existen o son cero)
        {
        cent.sUnid = @"";                                                         // Borra pronuciación
        cent.Subfix = LngInfo.SufixSingular[i];                                   // Pone el sufijo, correspondiente en singular
        continue;                                                                 // Continua con la otra centena
        }
      else
        cent.sUnid = OneShort[lng];                                               // Cambia pronunciación de la unidad, de 'uno' por 'un', Ej: 21000
      }

    cent.Subfix = LngInfo.SufixPlural[i];                                         // Pone el sufijo en plural
    }
  }


//----------------------------------------------------------------------------------------------------------------------------------------------
// Caso especial en italiano del ocho y el uno en las decenas
-(void) FixUnoOcho
  {
  for( int i = 0; i<NumInfo.count; ++i )
    {
    CenteInfo* cent = NumInfo[i];
    
    if( cent.valDec>1 && (cent.valUnid == 8 || cent.valUnid == 1) )       // Si las decenas son mayor que 1 y termina en 1 o en 8 Ej: 21, 28, 31, 28, etc
        cent.sDec = [cent.sDec substringToIndex: cent.sDec.length-1 ];    // Se le substrae la última letra al nombre de las decenas
      
    if( cent.valDec>1 && cent.valUnid == 3 )                              // Si el números es mayor que 20 y termina en 3 como: 23, 33, 43, 53...
        cent.sUnid = @"tré";                                              // Si el números es mayor que 20 y termina en 3 como: 23, 33, 43, 53...
    }
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Casos especiales del francés: el uno en las decenas y el setenta y el noventa
-(void) FixFrenchDec
  {
  for( int i = 0; i<NumInfo.count; ++i )
    {
    CenteInfo* cent = NumInfo[i];
    
    if( cent.valDec > 1 && cent.valUnid == 1)                                           // Si el número es mayor que 20 y termina en 1, como: 21, 31, 41....
        cent.sDec = [LngInfo.DeceExactas[cent.valDec] stringByAppendingString: @"et "]; // El nombre de las decenas es el mismo que el de las decenas exactas más "et"
      
    if( cent.valDec == 7 || cent.valDec == 9 )                                          // Si el valor de las decenas es 7 o 9
      {
      cent.sUnid = LngInfo.FixDecenas[cent.valUnid];                                    // El valor de las unidades es el de las decenas especiales como once, doce, trece
      if( cent.valUnid != 0 )                                                           // Si no es una decena exacta
        cent.sDec = LngInfo.Decenas[cent.valDec-1];                                     // El nombre de las decenas es el mismo que el de la decena anterior
      }
    }
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Añade and en la última centena en los números en inglés
-(void) SetAnd
  {
  if( NumInfo.count==0 ) return;
  
  CenteInfo* cent = NumInfo[0];                                                  // Obtiene información de la centena actual
  if( cent.valUnid != 0 || cent.valDec != 0 )
    {
    if( cent.valCent >= 0 )
      cent.sCent = [cent.sCent stringByAppendingString:@"and "];
    }
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Crea la cadena que representa al numero a partir de la informacion disponible en 'NumInfo'
-(NSString*) StringNumber
  {
  NSMutableString* sNum = [NSMutableString stringWithCapacity: 12*NumInfo.count];
  
  for( int i=(int)NumInfo.count-1; i>=0; --i )                                    // Recorre todas las centenas
    {
    CenteInfo* cent = NumInfo[i];                                                 // Toma la centena actual
    [sNum appendString: [cent Read] ];                                            // Adiciona su pronunciación al numero final
    }

  return sNum;                                                                    // Retorna el resultado
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Crea la cadena formateada que representa al numero a partir de la informacion disponible en 'NumInfo'
-(NSAttributedString*) FormatNumber
  {
  NSMutableAttributedString* Str = [[NSMutableAttributedString alloc] init];
  
  for( int i=(int)NumInfo.count-1; i>=0; --i )                                    // Recorre todas las centenas
    {
    CenteInfo* cent = NumInfo[i];                                                 // Toma la centena actual
    [self AttrStr:[cent Read] In:Str];
    }

  return Str;                                                                     // Retorna el resultado
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Crea la cadena que representa al numero a partir de la informacion disponible en 'NumInfo'
-(NSAttributedString*) AttrStr:(NSString*)txt In:(NSMutableAttributedString*) Str
  {
  if( Str == nil )
    Str = [[NSMutableAttributedString alloc] init];
  
  NSDictionary* attr = ParCol? attrNum2 : attrNum1;
    
  [Str appendAttributedString: [[NSMutableAttributedString alloc] initWithString:txt attributes:attr] ];
    
  ParCol = !ParCol;

  return Str;                                                                     // Retorna el resultado
  }

//=============================================================================================================================================
// NÚMEROS ORDINALES
//=============================================================================================================================================

//----------------------------------------------------------------------------------------------------------------------------------------------
// Procesa la información de los números ordinales
- (NSString*) ReadOrdinalString
  {
  NSString* sNum = [self StringClearIniCeros: false ];                            // Limpia la cadena de los caracteres no significativos
  [self ProcessStrNum:sNum];
  
  if( NumInfo.count==0 ) return @"";
  
  [self RegularOrdinalIniCent];                                                  // Controla la pronunciacion normal de los números ordinales
  [self FixPrimerosNum];                                                         // Arregla los primeros números ej: "primero ", "segundo ", "tercero"
  
  if( lng == 0 ) [self IrregES];                                                 // Si el idioma es Español
  if( lng == 1 ) [self IrregEN];                                                 // Si el idioma es Inglés
  if( lng == 2 ) [self IrregIT];                                                 // Si el idioma es Italiano
  if( lng == 3 ) [self IrregFR];                                                 // Si el idioma es Francés
  
  [self SufixOrd];                                                               //Añade los sufijos correspondientes a los números ordinales
  
  return [self StringNumber];
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
NSString* Term[] = {@"ésimo ", @"th ", @"esimo ", @"ième  "};                    // Terminación de los números ordinales
//----------------------------------------------------------------------------------------------------------------------------------------------
// Pronunciación regular de los números ordinales de la primera centena
-(void) RegularOrdinalIniCent
  {
  CenteInfo* cent = NumInfo[0];
  
  if( cent.sUnid!=nil && cent.sUnid.length > 0 )                    // Si el existen unidades o el conjunto de las unidades no está vacio
    {
    NSString* s = cent.sUnid;
    s = [s substringToIndex:s.length-1];                            // Quita el ultimo caracter (sepacio)
    
    cent.sUnid  = [s stringByAppendingString:Term[lng]];            // Le añade a las unidades la terminación de los números  ordinales
    }
  
  else if( cent.sDec!=nil && cent.sDec.length>0 )                   // Sino hay decenas o el conjunto de las decenas no está vacia
    {
    NSString* s = cent.sDec;
    
    if( lng!=2 )                                                    // Menos el Italiano
      s = [s substringToIndex:s.length-1];                          // Quita el ultimo caracter (espacio)
    
    cent.sDec = [s stringByAppendingString:Term[lng]];              // Le añade terminación de ordinales
    }
  
  else if( cent.sCent!=nil && cent.sCent.length>0 )                 // Sino hay centenas o el conjunto de las centenas no está vacio
    {
    NSString* s = cent.sCent;
    s = [s substringToIndex:s.length-1];                            // Quita el ultimo caracter (sepacio)
    
    cent.sCent  = [s stringByAppendingString:Term[lng]];            // Le añade terminación de ordinales
    }
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Para arreglar los primeros números
-(void) FixPrimerosNum
  {
  CenteInfo* cent = NumInfo[0];
  
  if( cent.valDec<0 && cent.valUnid > 0 )                   // Ve si está entre los números del 1 al 10
    cent.sUnid = LngInfo.UnOrd[cent.valUnid];               // Pone el nombre irregular de los primeros números como: primero, segundo, tercero etc..
  }

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Arregla las irregularidades en Español
- (void) IrregES
  {
  CenteInfo* cent = NumInfo[0];
  
  cent.sUnid = LngInfo.UnOrd[cent.valUnid];                             // Pone la pronunciación de las unidades en los números ordinales Ej: primero, segundo
  
  if(cent.valDec > 0)                                                   // Si hay decenas
    cent.sDec = LngInfo.DecOrd[cent.valDec];                            // Pone el nombre especial de las decenas Ej: décimo, vigésimo, etc
  
  if(cent.valCent > 0)                                                  // Si hay centenas
    cent.sCent = LngInfo.CenOrd[cent.valCent];                          // Pone el nombre de las centenas como: centésimo, vigentésimo, etc
  
  if(cent.valDec == 1 && cent.valUnid > 0 && cent.valUnid < LngInfo.FixDecOrd.count)       // Si es de los números 11, 12, 13, 14, etc
    {
    cent.sUnid = @"";                                                   // Vacia las unidades
    cent.sDec = LngInfo.FixDecOrd[cent.valUnid];                        // Pone la pronunciación de las decenas especiales en los num ordinales
    }
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------
// Arregla las irregularidades en inglés
- (void) IrregEN
  {
  CenteInfo* cent = NumInfo[0];
  
  if( cent.valDec >= 0 || cent.valCent >=0 )                            // Si el número tiene decenas o centenas
    cent.sUnid = LngInfo.UnOrd[cent.valUnid];                           // Pone en las unidades los números especiales Ej: first, second, third, etc
  
  if( cent.valDec == 1 && cent.valUnid < LngInfo.FixDecOrd.count )
    {
    cent.sUnid = @"";                                                   // Vacia las unidades
    cent.sDec = LngInfo.FixDecOrd[cent.valUnid];                        // Pone la pronunciación de las decenas especiales en los num ordinales
    }
  
  if( cent.valUnid==0 )                                                 // Si es una decena exacta, si termina en cero
    cent.sDec = LngInfo.DecOrd[cent.valDec];                            // Pone el nombre especial de las decenas en los números ordinales
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------
// Arregla las irregularidades en Italiano
- (void) IrregIT
  {
  CenteInfo* cent0 = NumInfo[0];
  
  if( cent0.valDec == 1 && cent0.valUnid == 0 )                         // Si el número es 10
    cent0.sDec = @"decimo ";                                            // Pone decimo
  
  if((cent0.valUnid == 3 || cent0.valUnid == 6) && cent0.valDec > 1)     // Si el número termina en 3 o 6 y es mayor que 20, como: 23, 26, 33, 36, 43, 46
    cent0.sUnid = [LngInfo.Unidades[cent0.valUnid] stringByAppendingString:@"esimo "];  // Pone el nombre normal del número cardinal y le añade la terminación de los ordinales
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------
// Arregla las irregularidades en Francés
- (void) IrregFR
  {
  for(int i = 0; i < NumInfo.count; ++i)
    {
    CenteInfo* cent = NumInfo[i];
    
    if(cent.valUnid > 1 && cent.valDec > 1)                             // Si el número no termina ni en 0 ni en 1 y es mayor que 20, como: 21, 21, 34, 35, 45, etc
      cent.sUnid = LngInfo.UnOrd[cent.valUnid];                         // Las unidades cambian a su valor especial de los números ordinales
    
    if(cent.valDec == 1 && cent.valUnid > 0)                            // Si el número está entre 11 y 19
      cent.sDec = LngInfo.FixDecOrd[cent.valUnid];                      // Las decenas toman el valor característicos de las decenas especiales ordinales
    
    if(cent.valDec == 7 || cent.valDec == 9)                            // Si las decenas son 7 o 9, si el número es 70 o 90
      cent.sUnid = LngInfo.FixDecOrd[cent.valUnid];                     // Las unidades toman el valor de las decenas especiales ordinales como: once, doce, trece, etc
    
    if(cent.valUnid == 0 && cent.valDec > 1)                            // Si es una decena exacta
      cent.sDec = LngInfo.DecOrd[cent.valDec];                          // Pone la pronunciación de las decenas ordinales
    }
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
// Para poner los sufijos a los números ordinales
-(void) SufixOrd
  {
  if( NumInfo.count <= 1 ) return;
  
  CenteInfo* centIni = NumInfo[0];
  bool LstSufix     = !centIni.AllCero  ;
  
  for( int i=1; i< NumInfo.count; ++i )                                                    // Recorre todas las centenas (Saltandose la primera)
    {
    if( lng==0 && i>1 && i%2!=0 ) continue;
    
    CenteInfo* cent = NumInfo[i];
    if( cent.Subfix==nil || cent.Subfix.length==0 ) continue;
    
    if( lng==0 )
      {
           if( cent.sUnid !=nil && cent.sUnid.length > 0 ) cent.sUnid = [cent.sUnid substringToIndex: cent.sUnid.length-1];
      else if( cent.sDec  !=nil && cent.sDec.length  > 0 ) cent.sDec  = [cent.sDec  substringToIndex: cent.sDec.length-1 ];
      else if( cent.sCent !=nil && cent.sCent.length > 0 ) cent.sCent = [cent.sCent substringToIndex: cent.sCent.length-1];
      
      cent.Subfix = LngInfo.SufixOrd[i];                                                       //Pone el sufijo correspondiente de los números ordinales
      }
    
    if( lng!=0 && LstSufix==false && !cent.AllCero)
      {
      if( lng == 1 && (cent.valCent <= 0 && cent.valDec <= 0 && cent.valUnid == 1) )
        cent.sUnid = OneShort[lng];
        
      cent.Subfix = LngInfo.SufixOrd[i];                                                       //Pone el sufijo correspondiente de los números ordinales
        
      LstSufix = true;
      }
    
    }
  }

//=============================================================================================================================================
// NÚMEROS ROMANOS
//=============================================================================================================================================

//----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el número romano
-(NSString*) ReadRomano
  {
  NSString* sNum = [self StringClearIniCeros: false ];                            // Limpia la cadena de los caracteres no significativos
  [self ProcessStrNum:sNum];
  
  if( NumInfo.count>2 ) return @"";
  if( NumInfo.count==2 )
    {
    CenteInfo* cent = NumInfo[1];
    if( cent.valCent!=-1 || cent.valDec!=-1 || cent.valUnid>3 )
        return @"";
    }

  [self SimpleRom];
  [self SufixRom ];

  return [self StringNumber];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------
// Pronunciación simple de los números romanos
-(void) SimpleRom
  {
  for( int i = 0; i<NumInfo.count; ++i )
    {
    CenteInfo* cent = NumInfo[i];
    cent.sUnid = LngInfo.UnRom[cent.valUnid];                                       // Pronunciación de los unidades de los numeros romanos
       
    if( cent.valDec>0 )                                                             // Si las decenas existen
      cent.sDec = LngInfo.DecRom[cent.valDec];                                      // Pronunciación de las decenas de los números romanos

    if( cent.valCent>0 )                                                            // Si las centenas existen
       cent.sCent = LngInfo.CenRom[cent.valCent];                                   // Pronunciación de las centenas

    if( NumInfo.count>2 )
      cent.sUnid = LngInfo.MilesRom[cent.valUnid];
    }
  }

//----------------------------------------------------------------------------------------------------------------------------------------------
//
-(void) SufixRom
  {
  for( int i=1; i< NumInfo.count; ++i )                                             // Recorre todas las centenas (Saltandose la primera)
    {
    CenteInfo* cent = NumInfo[i];
    cent.sUnid = @"";
    cent.sDec  = @"";
    cent.sCent = @"";

    cent.Subfix = LngInfo.MilesRom[cent.valUnid];                                   // Pone el sufijo correspondiente de los números ordinales
    }
  }


  //----------------------------------------------------------------------------------------------------------------------------------------------

//=================================================== Fin de la clase  =============================================================================
@end
