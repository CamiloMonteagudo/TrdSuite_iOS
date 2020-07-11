//=========================================================================================================================================================
//  PanelConjView.m
//  TrdSuite
//
//  Created by Camilo on 21/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "PanelConjView.h"
#include "ProxyConj.h"
#include "AppData.h"

//=========================================================================================================================================================
@interface PanelConjView()
  {
  float wPanel;                   // Ultimo ancho analizado del panel
  float hPanel;                   // Ultima altura analizada del panel
  
  UILabel* verb;
  
  NSArray* lstConjs;
  }

@end

//=========================================================================================================================================================
@implementation PanelConjView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( !self ) return nil;
  
  hPanel = 30;
  
  verb = [[UILabel alloc] initWithFrame: self.frame];
  
  verb.autoresizingMask = 0xFF;
  verb.numberOfLines    = 0;
  verb.backgroundColor  = ColFillGray;
    
  [self addSubview: verb];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa del propiedad 'Word'
- (void)setVerb:(NSString *)Verb
  {
  [self ConjugateVerb:Verb];
  }

- (NSString *)Verb
  {
  return verb.text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) ConjugateVerb:(NSString*) sVerb
  {
  [ProxyConj LoadConjLang];
//  [ProxyConj ConjVerb:sVerb];
//  
//  lstConjs = [ProxyConj SortAndGrop:YES];
//
//  verb.attributedText = [ProxyConj TextFromConjsList:lstConjs];


  NSString* lWord = [sVerb lowercaseString];
  verb.attributedText = [ProxyConj GetRootWord:lWord];
  
  [self ResizeWordHeight];                                              // Obtiene la altura del texto
  [self setNeedsLayout];                                                // Reorganiza los controles
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Recalcula la altura del texto, según el ancho disponible y el tamaño del texto
- (void) ResizeWordHeight
  {
  float    w = wPanel - 2*SEP_BRD - 2*SEP_TXT;
  CGSize  sz = CGSizeMake( w, 1000 );
  CGRect rc1 = [verb.attributedText boundingRectWithSize:sz options:NSStringDrawingUsesLineFragmentOrigin context:nil];
  
  hPanel = (int)(rc1.size.height + 12.5);
  if( hPanel<30 ) hPanel = 30;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Redimesiona el panel y todos las vistas que contenga
- (void) layoutSubviews
  {
  CGPoint pos = self.frame.origin;                                                // Posición actual de la vista
  CGSize   sz = self.frame.size;                                                  // Tamaño actual de la vista
  
  if( sz.width != wPanel || sz.height != hPanel)                                  // Si cambio de tamaño
    {
    wPanel = sz.width;
    
    self.frame = CGRectMake( pos.x, pos.y, wPanel, hPanel );                      // Redimesiona la vista
    
    float w = wPanel - 2*SEP_BRD - 2*SEP_TXT;
    float h = hPanel - 2*SEP_TXT;
  
    verb.frame = CGRectMake( SEP_BRD + SEP_TXT, SEP_TXT, w, h);
  
    [self  setNeedsDisplay];                                                      // Redibuja el fondo del panel
    [self.superview setNeedsLayout];                                              // Reorganiza los controles de la vista que contiene al panel
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  float w = self.frame.size.width - 2*SEP_BRD;
  float h = self.frame.size.height;

  CGRect rc = CGRectMake(SEP_BRD, 0, w, h );
  
  DrawRoundRect( rc, R_INF, ColBrdBlue, ColFillGray);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================
