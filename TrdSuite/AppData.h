//
//  Langs.h
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrdHistory.h"

#define LGCount 5

extern NSString *const RefreshNotification;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Constantes para DrawRoundRect
#define ROUND  8                  // Radio de redondeo de las esquinas
#define BRD_W  1                  // Ancho del borde de las zonas redondeadas

#define STUS_H 20                 // Altura de la barra de estado del telefono

#define R_SUP  0x0001             // Lleva redondeo en la parte superior
#define R_INF  0x0002             // Lleva redondeo en la parte inferior
#define R_ALL  0x0003             // Llava redondeo en todas las esquinas

// Separacion de las vistas
#define SEP_BRD   5               // Sepatación de los bordes
#define SEP_TXT   3               // Separación de los bordes del control de texto
#define SEP_ROW   0.5             // Separación entre las filas de la lista


#define BTN_W      50             // Ancho de los botones de la barra de botones
#define BTN_H      50             // Alto de los botones de la barra de botones
#define BTN_SEP    10             // Separación entre los botones de la barra

#define MAX_LGTITLE   85          // Ancho maximo para el nombre del idioma

// Modos para mostrar información de la traducción
#define MODE_CMDS     0           // Solo muestra los comandos disponibles
#define MODE_MEANS    1           // Muestra los significados de las palabras
#define MODE_ROOTS    2           // Muestra las raices de las palabras

// Funciones del boton de la derecha del panel de traducción
#define FUN_CLOSE     0           // Cierra el panel de traducción (quita la traducción actual)
#define FUN_FILTER    1           // Filta la lista de oraciones con el texto fuente
#define FUN_UNFILTER  2           // Quita el filtro de la lista de oraciones

#define FLAG_W       23           // Ancho de las banderas pequeñas
#define FLAG_H       15           // Alto de las banderas pequeñas

//--------------------------------------------------------------------------------------------------------------------------------------------------------
#define FindOpt    (NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
//--------------------------------------------------------------------------------------------------------------------------------------------------------
extern int  LGSrc;
extern int  LGDes;
extern int  iUser;
extern BOOL iPad;
extern int  iOS;

extern float scrnWidth;           // Ancho de la pantalla
extern float EditMaxHeigth;       // Altura máxima de los controles de edicción
extern float KbHeight;            // Altura del teclado, si no esta desplegado es 0

extern UITextView* Responder;
extern TrdHistory *History;

extern NSString*  LGFlagFile( int lng, NSString* Suxfix );
extern BOOL       LGIsInstSrc( int lng );
extern BOOL       LGIsInstDes( int lng );
extern int        LGInferedDes( int lng );
extern int        LGFirstSrc();
extern int        LGNextDes();

extern BOOL       LGIsInstDir( int src, int des );
extern void       LGSetInstDir( int src, int des );

extern NSString*  LGAbrv( int lng );
extern NSString*  LGName( int lng );
extern int        LGNameSz( int lng );
extern void       LGSetNamesSize();
extern UIColor*   LGCol( int lng );

extern void HideKeyBoard();
extern BOOL IsLetter( NSInteger idx, NSString* Txt );
extern void DrawRoundRect( CGRect rc, int Round, UIColor* ColBrd, UIColor* ColBody );

extern NSString* FlagSpaces;
extern void GetFlagSpaces();

extern UIImage* LoadLaunchImage();

//--------------------------------------------------------------------------------------------------------------------------------------------------------


