//=========================================================================================================================================================
//  ModuleHdrView.h
//  TrdSuite
//
//  Created by Camilo on 23/10/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

@interface ModuleHdrView : UIView

  @property (nonatomic) float Height;
  @property (nonatomic, weak) NSString* Text;

  - (void) OnCloseBtn:(SEL)action Target:(id)target;
  - (void) Refresh;

@end

//=========================================================================================================================================================
