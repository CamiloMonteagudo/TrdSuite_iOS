//=========================================================================================================================================================
//  TrdInfoView.h
//  TrdSuite
//
//  Created by Camilo on 03/06/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

@class MainController;

//=========================================================================================================================================================
@interface TrdInfoView : UIView

  @property (nonatomic) int Mode;                                     // Modo que se muestra la vista
  @property (nonatomic) int ModeBtnCenter;                            // Modo actual del boton central
  @property (nonatomic) int ModeBtnRight;                             // Modo actual del boton derecho

  @property (weak, nonatomic) MainController* Ctrller;
  @property (nonatomic) BOOL SaveHidden;

  -(void) FindWord:(NSString*) txt;
  -(void) UpdateButtons;
  -(void) RefreshView;

@end

//=========================================================================================================================================================
