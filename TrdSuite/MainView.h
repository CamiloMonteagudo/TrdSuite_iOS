//=========================================================================================================================================================
//  MainView.h
//  TrdSuite
//
//  Created by Camilo on 16/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>
#import "MainController.h"
#import "PanelTrdView.h"
#import "TrdEditView.h"

//=========================================================================================================================================================
@interface MainView : UIView

@property (weak, nonatomic) LangsPanelView *PanelSrc;
@property (weak, nonatomic) PanelTrdView *PanelTrd;
@property (weak, nonatomic) VirtualListView *ListOras;
@property (weak, nonatomic) TrdInfoView* TrdInfo;
@property (weak, nonatomic) TrdEditView *TrdEdit;

@end
//=========================================================================================================================================================
