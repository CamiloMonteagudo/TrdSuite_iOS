//=========================================================================================================================================================
//  LangsBar.h
//  TrdSuite
//
//  Created by Camilo on 26/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

//=========================================================================================================================================================
@interface LangsBar : UIView

  @property (nonatomic         ) int  SelLng;                  // Idioma que se encuentra seleccionado
  @property (nonatomic,readonly) int  SelItem;                 // Item del menú que se seleccionó
  @property (nonatomic         ) BOOL Trd;                     // Si la barra muestra el idioma destino de la traducción
  @property (nonatomic         ) BOOL HideTitle;               // No muestra titulo del idioma
  @property (nonatomic         ) BOOL NoCur;                   // Inica si se muestra la flechita del idioma actual o no

  - (id)initWithView:(UIView*) view;

  - (void) AddItemId:(NSString*) strItem;
  - (void) ClearAllItems;

  - (void) OnSelItem:(SEL)action Target:(id)target;
  - (void) OnSelLang:(SEL)action Target:(id)target;
  - (void) OnOnBack:(SEL)action Target:(id)target;

  - (void) RefreshLangsButtons;

  - (void) MoveToX:(float) x Y:(float) y;

@end
//=========================================================================================================================================================
