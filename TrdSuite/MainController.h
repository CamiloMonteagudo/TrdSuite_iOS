//=========================================================================================================================================================
//  ViewController.h
//  TrdSuite
//
//  Created by Camilo on 15/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>
#import "LangsPanelView.h"
#import "VirtualListView.h"
#import "TrdInfoView.h"
#import "PanelTrdView.h"

@class TrdInfoView;

//=========================================================================================================================================================
@interface MainController : UIViewController <LangsPanelDelegate, VirtualListDelegate>

@property (nonatomic) BOOL OnTextTrd;                               // Define que la busqueda de significados y raices se haga en el texto traducido

@property (nonatomic,copy) NSString* ParamWord;                     // Palabra que se pasa a la proxima pantalla
@property (nonatomic     )       int ParamSrc;                      // Idioma fuente que utiliza la proxima pantalla
@property (nonatomic     )       int ParamDes;                      // Idioma destino que utiliza la proxima pantalla

- (void) ShowScreenNum:(int) n;                                     // Muestra la proxima pantalla

- (IBAction)ReturnFromUnwind:(UIStoryboardSegue *)unWindSegue;


- (NSString *) GetMarkedWord;
- (void)       ClearMarkText;

- (int) GetBtnCenterMode;                                           // Obtiene el modo que debe trabajar el boton central
- (int) GetBtnRightMode;                                            // Obtiene el modo que debe trabajar el boton derecho

- (void) UpdateButtons;                                              // Actualiza los botones de la barra de comandos


- (void) OnBtnSaveTrd;
- (void) OnBtnPrevWord;
- (void) OnBtnNextWord;

- (void) OnBtnTrd;

- (void) OnBtnRight;
- (void) OnBtnCloseEditTrd;
- (void) OnBtnSaveEditTrd;
- (void) OnBtnCenter;

//- (void) OnBtnFilterOras;
//- (void) OnBtnUnFilterOras;
- (void) OnBtnHideTrd;

- (void) OnChangedTextTrd;
- (void) OnChangedSelectTextTrd;

@end
//=========================================================================================================================================================
