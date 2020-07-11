//
//  WaitView.m
//  PruTranslate
//
//  Created by Camilo on 11/03/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "WaitView.h"

//=========================================================================================================================================================
@implementation WaitView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicia una vista que ocupa el area de 'parent' con un control de esper en el medio
- (id)initInView:(UIView*) parent
  {
  CGSize sz = parent.bounds.size;
  CGRect frame = CGRectMake( 0, 0, sz.width, sz.height );
  
  self = [super initWithFrame:frame];
  if( !self ) return self;
  
  self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
  
  UIActivityIndicatorView* wait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  wait.center = self.center;
  wait.color  = [UIColor darkGrayColor];
  
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
  
  [self addSubview: wait ];
  
  [parent addSubview:self];
  [wait startAnimating];
  
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
  
  return self;
  }

@end
//=========================================================================================================================================================
