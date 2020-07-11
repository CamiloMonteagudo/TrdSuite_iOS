//=========================================================================================================================================================
//  TrdEditView.h
//  TrdSuite
//
//  Created by Camilo on 01/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

@class MainController;

//=========================================================================================================================================================
@interface TrdEditView : UIView <UITextViewDelegate, NSLayoutManagerDelegate>

  @property (weak, nonatomic) MainController* Ctrller;

  @property (weak, nonatomic) NSString* TextSrc;
  @property (weak, nonatomic) NSString* TextTrd;

  @property (nonatomic) BOOL SaveHidden;
  
  @property (nonatomic, readonly ) float StaticHeight;  // Retorna altura de la vista que no varia

  - (void) UpdateData;

@end

//=========================================================================================================================================================
