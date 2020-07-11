//
//  VirtualConjRowView.h
//  PruTranslate
//
//  Created by Camilo on 20/03/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "VirtualListView.h"

@interface VirtualConjRowView : VirtualRowView

-(void) CacheView;

+(VirtualConjRowView *) RowWithConjIndex:(int) index Width:(float)w ;
+(void) SetConjData:(NSArray*) lstConjs;

@end
