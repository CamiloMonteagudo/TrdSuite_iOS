//=========================================================================================================================================================
//  ReadNumber.h
//  TrdSuite
//
//  Created by Camilo on 24/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <Foundation/Foundation.h>

#define NoDef   -1                                                           // Constante que indica que un digito no esta definido

//=========================================================================================================================================================
// Guarda la información para leer un número de manera regular en un idioma
struct CentLangInfo
  {
  // Formación de números hasta mil
  NSArray* Unidades;                                                         // Pronunciación de las unidades Ej: "uno", "dos", "tres", etc.
  NSArray* Decenas;                                                          // Pronunciación de las decenas  Ej: "veinti", "treinta y" etc.
  NSArray* Centenas;                                                         // Pronunciación de las centenas Ej: "ciento", "docientos", "trescientos" etc.

  // Casos especiales para las decenas y centenas exactas
  NSArray* DeceExactas;                                                      // Pronunciación de las decenas exactas  Ej: "diez", "vente", "trenta" etc.
  NSArray* CentExactas;                                                      // Pronunciación de las centenas exactas Ej: "cien", "dociento", "tresciento" etc.

  // Sufijo usados en las centenas a partir del número 1000
  NSArray* SufixPlural;                                                      // Prefijos en plural   Ej: "miles", "millones" , "billones", etc.
  NSArray* SufixSingular;                                                    // Prefijos en singular Ej: "mil"  , "un millon", "un billon", etc.

  // Irregularidades en los numeros de la mitad inferior de las decenas
  NSArray* FixDecenas;                                                       // Ajuste para las decenas Ej: 11, 12, 13 ....

  // Números ordinales
  NSArray* UnOrd;
  NSArray* DecOrd;
  NSArray* CenOrd;
  NSArray* SufixOrd;
  NSArray* FixDecOrd;

  // Números Romanos
  NSArray* UnRom;
  NSArray* DecRom;
  NSArray* CenRom;

  NSArray* MilesRom;
  };

//=========================================================================================================================================================
@interface CenteInfo : NSObject

  @property(nonatomic ) int valUnid;                                         // Valor númerico del digito correspondiemte a las unidades
  @property(nonatomic ) int valDec;                                          // Valor númerico del digito correspondiente a las decenas
  @property(nonatomic ) int valCent;                                         // Valor númerico del digito correspondiente a las centena

  @property(nonatomic ) NSString* sUnid;                                     // Lectura del digito correspondiente a las unidades
  @property(nonatomic ) NSString* sDec;                                      // Lectura del digito correspondiente a las decenas
  @property(nonatomic ) NSString* sCent;                                     // Lectura del digito correspondiente a las centena

  @property(nonatomic ) NSString* Subfix;                                    // Sufijo que se le coloca al grupo, de acuerdo a su posición en el número

  @property(nonatomic ) BOOL AllCero;                                        // Bandera que indica que todos los digitos no cero o no estan definidos

  +(id) InfoWithString:(NSString*) sNum FromIndex:(int) ini;

  - (void) SetRegularReadForLang:(CentLangInfo) info;

  -(NSString*) Read;

@end

//=========================================================================================================================================================
@interface ReadNumber : NSObject

  +(id) NumberWithString:(NSString*) sNum Lang:(int) lang;
  +(int) MaxDigistInLang:(int) lang;

  -(NSAttributedString*) ReadCardinalAll;
  -(NSAttributedString*) ReadCardinalByGroup:(int) grp;
  -(NSString*) ReadOrdinalString;
  -(NSString*) ReadRomano;

//-(NSString*) ReadOrdinal;
@end
//=========================================================================================================================================================
