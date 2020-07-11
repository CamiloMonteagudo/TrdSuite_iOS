//=========================================================================================================================================================
//  ConjController.h
//  TrdSuite
//
//  Created by Camilo on 03/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>
#import "LangsPanelView.h"

#define SEP 2

#define BY_WORDS   0
#define BY_MODES   1
#define BY_PERSONS 2

//=========================================================================================================================================================
@interface ConjController : UIViewController <LangsPanelDelegate>

  @property (nonatomic, copy) NSString* Verb;
  @property (nonatomic      )       int lngSrc;

- (void)OnChangeMode;

@end
//=========================================================================================================================================================
