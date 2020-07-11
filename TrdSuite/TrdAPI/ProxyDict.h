/*
 *  ProxyDict.h
 *  IdiomaXTranslator
 *
 *  Created by MacPC on 5/27/11.
 *  Copyright 2011 IdiomaX. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface ProxyDict : NSObject {
	
}

+(bool) OpenDictSrc:(int) src Dest:(int) des;
+(void) CloseDict;

+(NSAttributedString*) getWDataFromIndex: (int)idx;
+(NSAttributedString*) FormatedMsg:(NSString*) sMsg Title:(NSString*) sTitle;

+(int) getSize;
+(NSString *)getWordAt: (int)idx;
+(int) getWordIdx: (NSString *) Key;
+(bool) Found;

+(void) KeysFilter:(NSString*) sFilter;
+(void) RemoveFilter;
+(BOOL) IsFiltered;

@end
