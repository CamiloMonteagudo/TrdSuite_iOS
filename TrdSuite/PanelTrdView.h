//=========================================================================================================================================================
//  PanelTrdView..h
//
//  Created by Camilo on 26/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>
//#import "MainController.h"

@class MainController;

//=========================================================================================================================================================
@interface PanelTrdView : UIView <UITextViewDelegate, NSLayoutManagerDelegate>

  @property (weak, nonatomic) MainController* Ctrller;

  @property (nonatomic      ) int       SelLng;         // Idioma que se encuentra seleccionado
  @property (nonatomic, weak) NSString* Text;           // Texto traducido
  @property (nonatomic      ) BOOL      NoShow;         // Define si se muestra el panel de traducción o no
  @property (nonatomic      ) BOOL      NoText;         // Define si se muestra el texto de la traducción o no

  @property (nonatomic, readonly ) float StaticHeight;  // Retorna altura de la vista que no varia

- (void)RefreshLangs;

- (NSRange) GetMarkText;
- (void)    SetMarkText:(NSRange) range;
- (void)    ClearMarkText;
- (void)    RefreshView;

@end
//=========================================================================================================================================================
