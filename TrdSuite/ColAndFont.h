//=========================================================================================================================================================
//  ColAndFont.h
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <Foundation/Foundation.h>

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// FUENTES Y COLORES USADAS EN EL PROGRAMA
//--------------------------------------------------------------------------------------------------------------------------------------------------------
extern CGFloat FontSize;                              // Tamaño de la letras estandard del sistema
extern CGFloat LineHeight;                            // Altura estandar de una linea de texto

extern UIColor* ColMainBck;                           // Define color de fondo de la aplicación en general
extern UIColor* ColPanelBck;                          // Color de fondo para el menú lateral
extern UIColor* ColPanelItemBck;                      // Color de fondo para los items del menú lateral
extern UIColor* ColPanelItemTxt;                      // Color de los textos del menú lateral
extern UIColor* ColHeaderBck;                         // Color de fondo para el encabezamiento de las pantallas

// Texto para los botones
extern UIColor* ColTxtBtns;                           // Color del texto de los botones
extern UIFont*  fontTxtBtns;                          // Fuente para los botones
extern NSDictionary* attrBtns;                        // Atributo para el texto de los botones

// Texto para compras
extern UIColor* ColBuyItem;                           // Item de compra nornal
extern UIColor* ColBuyItemSel;                        // Item de compra seleccionado
extern UIColor* ColBoughtItem;                        // Item comprado
extern UIFont*  fontBuyItem;                          // Fuente usada para los items
extern NSDictionary* attrBuy;

// Titulos
extern UIFont*       fontTitle;                       // Fuente para los titulos de los modulos
extern NSDictionary* attrTitle;                       // Atributo para los titulo de los modulos

// Editores de texto
extern UIFont*       fontEdit;                        // Fuente para los textos editados
extern UIColor*      ColTxtSel;                       // Color para los textos seleccionados
extern UIColor*      ColHolder;                       // Color para los place holder de los textos
extern NSDictionary* attrEdit;                        // Atributo normales de los textos editados

// Diccionario
extern UIColor* ColCellBckSel;                        // Color de fondo de celdas seleccionadas
extern UIColor* ColCellBck;                           // Color de fondo de celdas normales
extern UIColor* ColCellSep;                           // Color de los separadores de celdas

// Significados
extern UIFont* fontMean;                              // Fuente para los significados
extern UIFont* fontMeanBold;                          // Fuente para los textos resaltados dentro del significado
extern UIFont* fontMeanSmall;                         // Fuente mas pequeña dentro del significado

extern UIColor* ColMean;                              // Color para el cuerpo del significado
extern UIColor* ColMeanGray;                          // Color atenuado para las palabras que pueden cambiar dentro del significado
extern UIColor* ColMeanType;                          // Color para las definiciones del tipo gramatical
extern UIColor* ColMeanAttr;                          // Color para los atributos asociados al significado

extern NSDictionary* attrKey;
extern NSDictionary* attrBody;
extern NSDictionary* attrBody2;
extern NSDictionary* attrType;
extern NSDictionary* attrAttr;

extern UIColor*   ColErrInfo;                        // Color para mostrar infomación de errores
extern NSDictionary* attrErr;

// Números
extern UIColor* ColNum1;
extern UIColor* ColNum2;

extern NSDictionary* attrNum1;
extern NSDictionary* attrNum2;

// Historial
extern UIFont*       fontHistory;                     // Fuente para la historia de las oraciones
extern NSDictionary* attrHistory;                     // Atributos para la hostoria de las oraciones

extern UIColor* ColBckSelHistoy1;                     // Color de fondo de las filas pares, en la fila de la historia seleccionada
extern UIColor* ColBckSelHistoy2;                     // Color de fondo de las filas impares, en la fila de la historia seleccionada

// Conjugaciones
extern UIFont* fontConj;
extern UIFont* fontConjBold;
extern UIFont* fontConjSmallItalic;
extern UIFont* fontConjMid;
extern UIFont* fontConjBoldMid;

extern UIColor* colConj;
extern UIColor* colConjMode;
extern UIColor* colConjPers;
extern UIColor* colConjGray;

extern NSDictionary* attrModeBold;                    // Attributos para mostrar modo resaltado
extern NSDictionary* attrModeBoldMid;                 // Attributos para mostrar modo resaltado pero de tamanño mediano
extern NSDictionary* attrModeSmall;                   // Attributos para mostrar modo de tamaño pequeño

extern NSDictionary* attrConjBold;                    // Atributos para mostrar las conjugaciones resaltadas
extern NSDictionary* attrConjBoldMid;                 // Atributos para mostrar las conjugaciones resaltadas pero de tamaño mediano
extern NSDictionary* attrConj;                        // Atributos para mostrar las conjugaciones con la fuente estandar

extern NSDictionary* attrPersBold;
extern NSDictionary* attrPersItalicSmall;
extern NSDictionary* attrPersMid;

extern NSDictionary* attrConjGray;

// Información de traducción
extern UIColor* ColBrdRound1;                         // Color del borde de las zonas con borde redondeado
extern UIColor* ColBrdRound2;                         // Color del borde de las zonas con borde redondeado

extern UIColor* ColFillRound1;                        // Color de relleno de las zonas con borde redondeado
extern UIColor* ColFillRound2;                        // Color de relleno de las zonas con borde redondeado

extern UIColor* ColBckTrdInfo1;                        // Color de background para la zona de información de la traducción
extern UIColor* ColBckTrdInfo2;                        // Color de background para la zona de información de la traducción

extern UIColor* ColPanelTitle;                        // Color del titulo de los paneles
extern UIFont*  fontPanelTitle;                       // Fuente para los titulos de los paneles

extern void SetFontSize( CGFloat szFont );

//--------------------------------------------------------------------------------------------------------------------------------------------------------


