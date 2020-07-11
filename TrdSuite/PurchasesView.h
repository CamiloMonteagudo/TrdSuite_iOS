//=========================================================================================================================================================
//  PurchasesView.h
//  TrdSuite
//
//  Created by Camilo on 05/10/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>
#import "VirtualListView.h"
#import <StoreKit/StoreKit.h>

#define N_PURCH 6

@class PurchasesView;

//=========================================================================================================================================================
@interface Purchases : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

  +(void) Initialize;
  +(void) RequestProdInfo;
  +(void) SetPurchasedItem:(int) idx;
  +(BOOL) PurchaseProdIndex:(int) idx;
  +(void) SetViewParameters;

  +(void)setView:(PurchasesView*) view;
  +(void) Remove;

@end

//=========================================================================================================================================================
@interface PurchasesScreen : UIView

  - (id)initWithFromView:(UIView*)view;
  - (void) SelPurchasesSrc:(int) src Des:(int) des;

@end

//=========================================================================================================================================================

@interface PurchasesView : UIView <VirtualListDelegate>

  @property (nonatomic) int SelectedItem;

  +(int) MinHeight;
  +(int)MinWidth;

  -(void) RefreshItems;

@end

//=========================================================================================================================================================
