//=========================================================================================================================================================
//  DictController.h
//  TrdSuite
//
//  Created by Camilo on 03/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>
#import "LangsPanelView.h"
#import "VirtualListView.h"

//=========================================================================================================================================================
@interface DictController : UIViewController <LangsPanelDelegate, VirtualListDelegate>

  @property (nonatomic, copy) NSString* Word;
  @property (nonatomic      )       int lngSrc;
  @property (nonatomic      )       int lngDes;

@end
//=========================================================================================================================================================
