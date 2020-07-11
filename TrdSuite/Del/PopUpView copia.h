//
//  PopUpView.h
//  TrdSuite
//
//  Created by Camilo on 28/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import <UIKit/UIKit.h>

//=========================================================================================================================================================
@interface PopUpView : UIView

- (id)initForView:(UIView*)view ItemsNames:(NSArray*)Names ItemsIcons:(NSArray*) Icons;
- (void) OnHidePopUp:(SEL)action Target:(id)target;

@property(nonatomic,readonly) int SelectedItem;

@end

//=========================================================================================================================================================
