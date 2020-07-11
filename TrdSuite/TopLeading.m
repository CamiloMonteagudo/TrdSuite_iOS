//=========================================================================================================================================================
//  TopLeading.m
//  TrdSuite
//
//  Created by Camilo on 19/06/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "TopLeading.h"
#import "AppData.h"

//=========================================================================================================================================================
@interface TopLeading()
  {
  UIImageView* Lead;
  }
@end

//=========================================================================================================================================================
@implementation TopLeading

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  if( !self ) return nil;

  if( self.tag==0 )
    {
    CGRect frame = CGRectMake( _xPos, 8, 40, 28);                                 // Posiciona el indicador de idioma seleccionado
  
    Lead = [[UIImageView alloc] initWithFrame:frame ];
    Lead.image  = [UIImage imageNamed: @"Leading"];
  
    [self addSubview:Lead];
    }
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setXPos:(int)xPos
  {
  _xPos = xPos;
  
  if( self.tag==0 )
    Lead.frame = CGRectMake( _xPos, 8, 40, 28);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
  {
  [self setNeedsDisplay];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  UIColor* col = [UIColor whiteColor];
  
  float w = self.bounds.size.width - 2*SEP_BRD - 2;
  float h = ROUND+2;
  float y = self.bounds.size.height - h;

  CGRect rc = CGRectMake(SEP_BRD+1, y, w, h );
  
  DrawRoundRect( rc, R_SUP, col, col);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
@end
