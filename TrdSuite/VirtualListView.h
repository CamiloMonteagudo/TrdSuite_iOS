//=========================================================================================================================================================
//  VirtualListView.h
//  PruScroll
//
//  Created by Camilo on 19/02/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

//=========================================================================================================================================================
@interface VirtualRowView : UIView

@property (nonatomic) int   Index;

-(void) CacheView;

@end

//=========================================================================================================================================================
@protocol VirtualListDelegate

- (VirtualRowView*) GetRowViewAt:(int) iRow;                  // Obtiene la vista que representa la fila 'iRow'
- (void)            OnSelectedRow:(int) iRow;                 // Notifica que se selecciono por el usuario la fila 'iRow'

@end

//=========================================================================================================================================================
@interface VirtualListView : UIScrollView

@property (nonatomic) int  MinHeight;
@property (nonatomic) int  Count;
@property (nonatomic) int  SelectedIndex;
@property (nonatomic) BOOL NoLayaut;

@property (weak) id<VirtualListDelegate> VirtualListDelegate;

-(void) ChangeRow:(int) iRow;
-(void) SetVisibleRow:(int) iRow;
-(void) SetAtTopRow:(int) iRow;
-(VirtualRowView*) GetVisualRow:(int) iRow;

- (void)UpdateCount:(int)Count;
- (void)Refresh;

@end

//=========================================================================================================================================================
