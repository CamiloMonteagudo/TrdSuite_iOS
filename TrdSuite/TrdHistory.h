//
//  TrdHistory.h
//  PruTranslate
//
//  Created by Camilo on 14/01/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrdItem;

//=========================================================================================================================================================
@interface TrdHistory : NSObject
  @property (nonatomic,readonly) int  Src;
  @property (nonatomic,readonly) BOOL Found;
  @property (nonatomic)          int  Count;

  + (TrdHistory*) HistoryWithSrc:(int) src;
  + (TrdHistory*) LoadWithSrc:(int) src;
  - (TrdHistory*) FilterByText:(NSString*) txt;

  - (int ) AddTrdSrc: (NSString*) src Trd:(NSString*) trd TrdLang:(int) lng;
  - (BOOL) ExistTrdSrc:(NSString*) src Trd:(NSString*) trd ToLang:(int) lng;

  - (int ) FindTrdSrc:(NSString*) src;

  - (TrdItem*) TrdItemAtIndex:(int) idx;
  - (NSArray*) TrdRowsAtIndex:(int) idx;

  - (TrdItem*) FindTrdItemSrc:(NSString*) src;
  - (int)      FindIndexSrc:(NSString*) src;

  - (void) RemoveTrdItemAtIndex:(int) idx;

  - (BOOL) Save;
@end

//=========================================================================================================================================================
@interface LabelText: NSObject
  @property NSString* Text;

  @property int Width;
  @property int Height;

  -(BOOL) SetSizeWithWidth:(int) Width;
@end

//=========================================================================================================================================================
@interface TrdItem : LabelText

  + (TrdItem*) ItemWithSrc:(NSString*) src;
  + (TrdItem*) ItemFromLines:(NSArray*)Lines Index:(int *)idx sLang:(NSString*)sLang;

  - (void) SetTrd:(NSString*) trd ToLang:(int) lng;
  - (NSString*) GetTrdWithLang:(int) lng;
  - (NSString*) GetTrdIdx:(int) idx;
  - (BOOL) IsNoTrds;

  - (void) SaveToText:(NSMutableString*)SaveText sLang:(NSString*)sLang;

  - (void) UpdateWithItem:(TrdItem*) Item;
@end

//=========================================================================================================================================================
@interface TrdRow : LabelText

  @property int Lng;

+ (TrdRow*) RowWithText:(NSString*) Txt Lang:(int) lang;

@end


//=========================================================================================================================================================
