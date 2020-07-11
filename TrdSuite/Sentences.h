//=========================================================================================================================================================
//  Sentences.h
//  TrdSuite
//
//  Created by Camilo on 08/11/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <Foundation/Foundation.h>

//=========================================================================================================================================================
@interface Sentence : NSObject

  @property (nonatomic) NSString* Text1;           // Texto para el primer idioma
  @property (nonatomic) NSString* Text2;           // Texto para el segundo idioma

+ (Sentence*) SentenceWithText1:(NSString*) txt1 AndText2:(NSString*) txt2;
+ (Sentence*) SentenceFromLines:(NSArray*)Lines Index:(int *)idx sLang1:(NSString*)sLng1 sLang2:(NSString*)sLng2;

@end
//=========================================================================================================================================================

//=========================================================================================================================================================
@interface Sentences : NSObject

  @property (nonatomic,readonly) BOOL Found;
  @property (nonatomic,readonly) int  Count;
  @property (nonatomic,readonly) int  LangSrc;
  @property (nonatomic,readonly) int  LangDes;

+ (Sentences*) Actual;
+ (Sentences*) LoadWithLang1:(int) lng1 AndLang2:(int) lng2;

+ (BOOL) IsActualLangSrc:(int) LGSrc AndLangDes:(int)LGDes;

- (int) AddSrcText:(NSString*) txtSrc TrdText:(NSString*) txtTrd;
- (int) IndexForSrcText:(NSString*) txtSrc;
- (BOOL) ExistTrdSrc:(NSString*) src Trd:(NSString*) trd;

- (NSString*) GetSrcTextAt:(int) IdxSrc;
- (NSString*) GetTrdTextAt:(int) IdxTrd;
- (Sentence*) GetSentenceAt:(int) IdxTrd;

- (Sentences*) FilterByText:(NSString*) txt;
- (BOOL) IsFiltered;
- (Sentences*) RemoveFilter;

- (void) RemoveAt:(int) IdxSrc;

@end
//=========================================================================================================================================================

