//=========================================================================================================================================================
//  ConjHeaderView.h
//  TrdSuite
//
//  Created by Camilo on 17/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

//=========================================================================================================================================================
#import <UIKit/UIKit.h>

@class ConjController;

@interface ConjHeaderView : UIView

  @property (weak, nonatomic) ConjController* Ctrller;
  
  @property (nonatomic) int Mode;                                     // Modo que se muestra la vista

  - (void) ClearData;
  - (void) ShowDataVerb:(BOOL) isVerb;
  - (void) ShowMessage:(NSString*) sMsg Color:(UIColor*) col;

@end
//=========================================================================================================================================================
