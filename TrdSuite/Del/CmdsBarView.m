//=========================================================================================================================================================
//  CmsBarView.m
//  TrdSuite
//
//  Created by Camilo on 21/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "CmdsBarView.h"
#import "AppData.h"

#define H_BRD     30              // Altura del borde


//=========================================================================================================================================================
@interface CmdsBarView()
  {
  SEL OnHideView;
  id  HideTarget;

  int Round;
  }
@end

//=========================================================================================================================================================
@implementation CmdsBarView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( !self ) return nil;
  
  self.yIni = 5;
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setYIni:(float)yIni
  {
  _yIni = yIni;
  
  if( yIni == 5) Round = R_INF;
  else           Round = R_SUP;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Estable el metodo y el objeto que se notificará cuando se oculte la vista
- (void) SetOnHideView:(SEL)action Target:(id)target
  {
  OnHideView  = action;
  HideTarget = target;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa la modificación de la propiedad 'Hidden' de la vista
- (void)setHidden:(BOOL)hidded
  {
  if( super.hidden != hidded )
    {
    super.hidden = hidded;
    if( hidded && OnHideView && HideTarget )
      {
      NSThread* nowThread = [NSThread currentThread];
      [HideTarget performSelector:OnHideView onThread:nowThread withObject:self waitUntilDone:NO];       // Realiza la notificacion
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Redimesiona el panel y todos las vistas que contenga
- (void) layoutSubviews
  {
  [self setNeedsDisplay];                                                   
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  float w = self.frame.size.width - 2*SEP_BRD;

  CGRect rc = CGRectMake(SEP_BRD, _yIni, w, H_BRD );
  
  DrawRoundRect( rc, Round, ColBrdBlue, ColFillBlue);
  }

@end
//=========================================================================================================================================================
