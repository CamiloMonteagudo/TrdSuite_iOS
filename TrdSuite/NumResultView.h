//=========================================================================================================================================================
//  NumResultView.h
//  TrdSuite
//
//  Created by Camilo on 28/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

@class NumGroupView;

@interface NumResultView : UIView

  @property (nonatomic) NSString* Text;

  @property (weak, nonatomic) NumGroupView *NumEdit;

- (void) SetNumberReading;

@end
//=========================================================================================================================================================
