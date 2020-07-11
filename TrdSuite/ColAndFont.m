//=========================================================================================================================================================
//  ColAndFont.h
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "ColAndFont.h"
#import "AppData.h"

//=========================================================================================================================================================
// FUENTES Y COLORES USADAS EN EL PROGRAMA
//=========================================================================================================================================================

CGFloat FontSize   = [UIFont systemFontSize];                                                           // Tamaño de la letras estandard del sistema
CGFloat LineHeight = 2*FontSize;                                                                        // Altura estandar de una linea de texto

//UIColor* ColMainBck = [UIColor colorWithRed:0.25 green:0.65 blue:0.85 alpha:0.75];                    // Define color de fondo de la aplicación en general
UIColor* ColMainBck       = [UIColor colorWithRed:0.25 green:0.65 blue:1 alpha:1];                      // Define color de fondo de la aplicación en general

UIColor* ColPanelBck     = [UIColor colorWithRed:0.05 green:0.2 blue:0.75 alpha:1.0];                   // Color de fondo para el menú lateral
UIColor* ColPanelItemBck = [UIColor colorWithRed:0.25 green:0.65 blue:1 alpha:1];                       // Color de fondo para los items del menú lateral
UIColor* ColPanelItemTxt = [UIColor whiteColor];                                                        // Color de los textos del menú lateral

// Texto para los botones
UIColor* ColTxtBtns     = [UIColor colorWithRed:0.05 green:0.05 blue:0.4 alpha:1.0];                       // Color del texto de los botones
UIFont*  fontTxtBtns    = [UIFont systemFontOfSize:0.9*FontSize];                                          // Fuente para los botones
NSDictionary* attrBtns  = [NSDictionary dictionaryWithObjectsAndKeys:fontTxtBtns, NSFontAttributeName, nil];

// Texto para compras
UIColor* ColBuyItem    = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];                       // Item de compra nornal
UIColor* ColBuyItemSel = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];                       // Item de compra seleccionado
UIColor* ColBoughtItem = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];                       // Item comprado
UIFont*  fontBuyItem   = [UIFont boldSystemFontOfSize:FontSize];                                        // Fuente usada para los items
NSDictionary* attrBuy  = [NSDictionary dictionaryWithObjectsAndKeys:fontBuyItem, NSFontAttributeName, nil];

// Titulos
UIFont*       fontTitle = [UIFont boldSystemFontOfSize:1.5*FontSize];                                       // Fuente para los titulos de los modulos
NSDictionary* attrTitle = [NSDictionary dictionaryWithObjectsAndKeys:fontTitle, NSFontAttributeName, nil];  // Atributo para los titulo de los modulos

// Editores de texto
UIFont*  fontEdit      = [UIFont systemFontOfSize:FontSize];                                              // Fuente para los textos editados
UIColor* ColTxtSel     = [UIColor colorWithRed:0.7 green:0.8 blue:0.95 alpha:1.00];                       // Color para las palabras seleccionadas
UIColor* ColHolder     = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];                      // Color del los textos de place holder
NSDictionary* attrEdit = [NSDictionary dictionaryWithObjectsAndKeys:fontEdit, NSFontAttributeName, nil];  // Atributo normales de los textos editados

// Celulas de las tablas
UIColor* ColCellBckSel = [UIColor colorWithRed:0.7 green:0.95 blue:1.0 alpha:1.0];                         // Color de fondo de celdas seleccionadas
UIColor* ColCellBck    = [UIColor whiteColor];                                                            // Color de fondo de celdas normales
UIColor* ColCellSep    = [UIColor lightGrayColor];                                                        // Color de los separadores de celdas

// Significados
UIFont* fontMean      = [UIFont systemFontOfSize:          FontSize];                                     // Fuente para los significados
UIFont* fontMeanBold  = [UIFont boldSystemFontOfSize:      FontSize];                                     // Fuente para los textos resaltados dentro del significado
UIFont* fontMeanSmall = [UIFont italicSystemFontOfSize:0.7*FontSize];                                     // Fuente mas pequeña dentro del significado

UIColor* ColMean      = [UIColor blackColor];                                                             // Color para el cuerpo del significado
UIColor* ColMeanGray  = [UIColor darkGrayColor];                                                          // Color atenuado para las palabras que pueden cambiar dentro del significado
UIColor* ColMeanType  = [UIColor colorWithRed:0.06 green:0.06 blue:0.43 alpha:1.00];                      // Color para las definiciones del tipo gramatical
UIColor* ColMeanAttr  = [UIColor colorWithRed:0.06 green:0.43 blue:0.06 alpha:1.00];                      // Color para los atributos asociados al significado

NSDictionary* attrKey   = @{ NSFontAttributeName:fontMeanBold , NSForegroundColorAttributeName:ColMean      };
NSDictionary* attrBody  = @{ NSFontAttributeName:fontMean     , NSForegroundColorAttributeName:ColMean      };
NSDictionary* attrBody2 = @{ NSFontAttributeName:fontMean     , NSForegroundColorAttributeName:ColMeanGray  };
NSDictionary* attrType  = @{ NSFontAttributeName:fontMeanSmall, NSForegroundColorAttributeName:ColMeanType  };
NSDictionary* attrAttr  = @{ NSFontAttributeName:fontMeanSmall, NSForegroundColorAttributeName:ColMeanAttr  };

// Números
UIColor* ColNum1        = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.00];
UIColor* ColNum2        = [UIColor colorWithRed:0.10 green:0.05 blue:0.75 alpha:1.00];

NSDictionary* attrNum1 = @{ NSFontAttributeName:fontMean, NSForegroundColorAttributeName:ColNum1  };
NSDictionary* attrNum2 = @{ NSFontAttributeName:fontMean, NSForegroundColorAttributeName:ColNum2  };

// Historial
UIFont*       fontHistory = [UIFont fontWithName:@"Arial" size:FontSize];
NSDictionary* attrHistory = [NSDictionary dictionaryWithObjectsAndKeys: fontHistory, NSFontAttributeName,nil];

//UIColor* ColBckSelHistoy1 = [UIColor colorWithRed:0.7  green:0.7  blue:1.0 alpha:0.6];
//UIColor* ColBckSelHistoy2 = [UIColor colorWithRed:0.62 green:0.82 blue:1.0 alpha:0.6];

UIColor* ColBckSelHistoy1 = [UIColor colorWithRed:0.7 green:0.95 blue:1.0 alpha:1.0];                         // Color de fondo de celdas seleccionadas
UIColor* ColBckSelHistoy2 = [UIColor colorWithRed:0.7 green:0.7  blue:0.7 alpha:0.2];                         // Color de fondo de celdas seleccionadas

// Conjugaciones
UIFont* fontConj            = [UIFont systemFontOfSize:           FontSize];
UIFont* fontConjBold        = [UIFont boldSystemFontOfSize:       FontSize];
UIFont* fontConjSmallItalic = [UIFont italicSystemFontOfSize:0.7 *FontSize];
UIFont* fontConjMid         = [UIFont systemFontOfSize:      0.85*FontSize];
UIFont* fontConjBoldMid     = [UIFont boldSystemFontOfSize:  0.85*FontSize];

UIColor* colConj     = [UIColor blackColor];
UIColor* colConjMode = [UIColor colorWithRed:0.06 green:0.43 blue:0.06 alpha:1.00];
UIColor* colConjPers = [UIColor colorWithRed:0.06 green:0.06 blue:0.43 alpha:1.00];
UIColor* colConjGray = [UIColor darkGrayColor];

NSDictionary* attrModeBold        = @{ NSFontAttributeName:fontConjBold        , NSForegroundColorAttributeName:colConjMode };
NSDictionary* attrModeBoldMid     = @{ NSFontAttributeName:fontConjBoldMid     , NSForegroundColorAttributeName:colConjMode };
NSDictionary* attrModeSmall       = @{ NSFontAttributeName:fontConjSmallItalic , NSForegroundColorAttributeName:colConjMode };

NSDictionary* attrConjBold        = @{ NSFontAttributeName:fontConjBold        , NSForegroundColorAttributeName:colConj     };
NSDictionary* attrConjBoldMid     = @{ NSFontAttributeName:fontConjBoldMid     , NSForegroundColorAttributeName:colConj     };
NSDictionary* attrConj            = @{ NSFontAttributeName:fontConj            , NSForegroundColorAttributeName:colConj     };

NSDictionary* attrPersBold        = @{ NSFontAttributeName:fontConjBold        , NSForegroundColorAttributeName:colConjPers };
NSDictionary* attrPersItalicSmall = @{ NSFontAttributeName:fontConjSmallItalic , NSForegroundColorAttributeName:colConjPers };
NSDictionary* attrPersMid         = @{ NSFontAttributeName:fontConjMid         , NSForegroundColorAttributeName:colConjPers };

NSDictionary* attrConjGray = @{ NSFontAttributeName:fontConjSmallItalic, NSForegroundColorAttributeName:colConjGray };

UIColor* ColErrInfo   = [UIColor colorWithRed:0.6 green:0.2 blue:0.2 alpha:1.00];                        // Color para mostrar infomación de errores
NSDictionary* attrErr = @{ NSFontAttributeName:fontConjBoldMid, NSForegroundColorAttributeName:ColErrInfo  };


// Información de traducción
UIColor* ColBrdRound1  = [UIColor colorWithRed:0.05 green:0.05 blue:0.4 alpha:1.0];
UIColor* ColBrdRound2  = [UIColor colorWithRed:1.0  green:1.0  blue:1.0 alpha:1.0];

UIColor* ColFillRound1 = [UIColor colorWithRed:0.05 green:0.05 blue:0.4 alpha:0.1];
UIColor* ColFillRound2 = [UIColor colorWithRed:1.0  green:1.0  blue:1.0 alpha:1.0];

UIColor* ColBckTrdInfo1  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
UIColor* ColBckTrdInfo2  = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.5];

UIColor* ColPanelTitle  = [UIColor whiteColor];                                   // Color del titulo de los paneles
UIFont*  fontPanelTitle = [UIFont boldSystemFontOfSize:FontSize];                 // Fuente para los titulos de los paneles

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// Define el tamaño de la fuente usada en toda la aplicación
void SetFontSize( CGFloat szFont )
  {
  FontSize = szFont;
  LineHeight = 2*FontSize;

  // Texto de los botones
  fontTxtBtns = [UIFont systemFontOfSize:0.9*FontSize];                                         // Fuente para los botones
  attrBtns    = [NSDictionary dictionaryWithObjectsAndKeys:fontTxtBtns, NSFontAttributeName, nil];
  
  // Para compras
  fontBuyItem  = [UIFont boldSystemFontOfSize:FontSize];                                        // Fuente usada para los items
  attrBuy      = [NSDictionary dictionaryWithObjectsAndKeys:fontBuyItem, NSFontAttributeName, nil];

  // Titulos
  fontTitle = [UIFont boldSystemFontOfSize:1.5*FontSize];                                       // Fuente para los titulos de los modulos
  attrTitle = [NSDictionary dictionaryWithObjectsAndKeys:fontTitle, NSFontAttributeName, nil];  // Atributo para los titulo de los modulos

  // Editores de texto
  fontEdit = [UIFont systemFontOfSize:FontSize];
  attrEdit = [NSDictionary dictionaryWithObjectsAndKeys:fontEdit, NSFontAttributeName, nil];  // Atributo normales de los textos editados

  // Significados
  fontMean      = [UIFont systemFontOfSize:          FontSize];                                     // Fuente para los significados
  fontMeanBold  = [UIFont boldSystemFontOfSize:      FontSize];                                     // Fuente para los textos resaltados dentro del significado
  fontMeanSmall = [UIFont italicSystemFontOfSize:0.7*FontSize];                                     // Fuente mas pequeña dentro del significado

  attrKey   = @{ NSFontAttributeName:fontMeanBold , NSForegroundColorAttributeName:ColMean      };
  attrBody  = @{ NSFontAttributeName:fontMean     , NSForegroundColorAttributeName:ColMean      };
  attrBody2 = @{ NSFontAttributeName:fontMean     , NSForegroundColorAttributeName:ColMeanGray  };
  attrType  = @{ NSFontAttributeName:fontMeanSmall, NSForegroundColorAttributeName:ColMeanType  };
  attrAttr  = @{ NSFontAttributeName:fontMeanSmall, NSForegroundColorAttributeName:ColMeanAttr  };

  // Historial
  fontHistory = [UIFont fontWithName:@"Arial" size:FontSize];
  attrHistory = [NSDictionary dictionaryWithObjectsAndKeys: fontHistory, NSFontAttributeName,nil];

  // Conjugaciones
  fontConj            = [UIFont systemFontOfSize:           FontSize];
  fontConjBold        = [UIFont boldSystemFontOfSize:       FontSize];
  fontConjSmallItalic = [UIFont italicSystemFontOfSize:0.7 *FontSize];
  fontConjMid         = [UIFont systemFontOfSize:      0.85*FontSize];
  fontConjBoldMid     = [UIFont boldSystemFontOfSize:  0.85*FontSize];

  attrModeBold        = @{ NSFontAttributeName:fontConjBold        , NSForegroundColorAttributeName:colConjMode };
  attrModeBoldMid     = @{ NSFontAttributeName:fontConjBoldMid     , NSForegroundColorAttributeName:colConjMode };
  attrModeSmall       = @{ NSFontAttributeName:fontConjSmallItalic , NSForegroundColorAttributeName:colConjMode };

  attrConjBold        = @{ NSFontAttributeName:fontConjBold        , NSForegroundColorAttributeName:colConj     };
  attrConjBoldMid     = @{ NSFontAttributeName:fontConjBoldMid     , NSForegroundColorAttributeName:colConj     };
  attrConj            = @{ NSFontAttributeName:fontConj            , NSForegroundColorAttributeName:colConj     };

  attrPersBold        = @{ NSFontAttributeName:fontConjBold        , NSForegroundColorAttributeName:colConjPers };
  attrPersItalicSmall = @{ NSFontAttributeName:fontConjSmallItalic , NSForegroundColorAttributeName:colConjPers };
  attrPersMid         = @{ NSFontAttributeName:fontConjMid         , NSForegroundColorAttributeName:colConjPers };

  attrConjGray = @{ NSFontAttributeName:fontConjSmallItalic, NSForegroundColorAttributeName:colConjGray };
 
  attrNum1 = @{ NSFontAttributeName:fontMean, NSForegroundColorAttributeName:ColNum1  };
  attrNum2 = @{ NSFontAttributeName:fontMean, NSForegroundColorAttributeName:ColNum2  };
   
  fontPanelTitle = [UIFont boldSystemFontOfSize:FontSize];                 // Fuente para los titulos de los paneles
  
  LGSetNamesSize();
  GetFlagSpaces();
  
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];                  // Refresca las barras de idiomas
  [center postNotificationName:RefreshNotification object:nil];
  
  NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
  [def setInteger:FontSize forKey:@"FontSize"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
