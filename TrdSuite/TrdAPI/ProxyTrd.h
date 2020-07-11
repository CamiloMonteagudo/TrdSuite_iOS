//
//  ProxyTrd.h
//  IdiomaXTranslator
//
//  Created by MacPC on 9/5/11.
//  Copyright 2011 IdiomaX. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProxyTrd : NSObject {

}

+(bool) OpenSrc: (int)src Des: (int)des;
+(void) Close;
+(NSString *) TranslateText: (NSString *) Txt Prog: (UIProgressView *)Progress;

@end
