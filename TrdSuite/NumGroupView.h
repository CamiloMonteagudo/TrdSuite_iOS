//=========================================================================================================================================================
//  NumGruopView.h
//  TrdSuite
//
//  Created by Camilo on 27/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

#define GrpAll     -3
#define GrpBy3      3
#define GrpBy2      2

@class NumsController;

@interface NumGroupView : UIView <UITextViewDelegate, NSLayoutManagerDelegate>

  @property (weak, nonatomic) NumsController* Ctrller;

  @property (nonatomic) NSString* Text;
  @property (nonatomic) int NGroup;
  @property (nonatomic) int MaxChars;

@end
//=========================================================================================================================================================
