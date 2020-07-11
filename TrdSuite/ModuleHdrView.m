//=========================================================================================================================================================
//  ModuleHdrView.m
//  TrdSuite
//
//  Created by Camilo on 23/10/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "ModuleHdrView.h"
#import "ColAndFont.h"
#import "AppData.h"

//=========================================================================================================================================================
@interface ModuleHdrView()
  {
  UILabel* ModLabel;
  UIButton* btnClose;
  
  SEL OnCloseFun;                                          // Metodo que se llama cuando se selecciona un Item
  id  CloseTarget;                                         // Objeto al que pertence el metodo de notificación seleccion de un item
  }
@end

@implementation ModuleHdrView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  
  if( self ) [self initData];
  
  return self;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
  {
  self = [super initWithFrame:frame];
  
  if( self ) [self initData];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) Refresh
  {
  ModLabel.font = fontTitle;
  
  [self setNeedsLayout];
  [self.superview setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementacion de popiedades del control
- (float)Height { return STUS_H + LineHeight; }
- (void)setText:(NSString *)Text { ModLabel.text = Text; }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los datos especificoa la vista
- (void) initData
  {
  self.backgroundColor = [UIColor clearColor];
  
  self.frame = CGRectMake(0, 0, 320, STUS_H + BTN_H );
  
  ModLabel = [self CreateLabel];
  btnClose = [self CreateButtonWithImage:@"BntCloseMod"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Estable el metodo y el objeto que se notificará cuando se seleccione un item adicional
- (void) OnCloseBtn:(SEL)action Target:(id)target
  {
  OnCloseFun  = action;
  CloseTarget = target;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un label con el nombre del modulo
-(UILabel*) CreateLabel
  {
  CGRect  rc = CGRectMake( 0, STUS_H, 320, LineHeight);                                  // Cualquier frame, en el layout se recalcuala
  UILabel* lb = [[UILabel alloc] initWithFrame:rc];
  
  lb.textColor     = ColPanelItemTxt;
  lb.font          = fontTitle;
  lb.text          = @"Dicionario";
  lb.numberOfLines = 1;
  lb.textAlignment = NSTextAlignmentCenter;
  
  [self addSubview:lb];
  
  return lb;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el boton que representa al idioma 'lang'
- (UIButton*) CreateButtonWithImage:(NSString*) sImage
  {
  CGRect rc = CGRectMake( 320-BTN_H, STUS_H, BTN_W, BTN_H);
    
  UIButton* btn = [[UIButton alloc] initWithFrame:rc];
    
  [btn addTarget:self action:@selector(OnButttonClose:) forControlEvents:UIControlEventTouchUpInside];
    
  [btn setTitle: @""                          forState: UIControlStateNormal ];
  [btn setImage: [UIImage imageNamed: sImage] forState: UIControlStateNormal ];
    
  [self addSubview:btn];
  
 // btn.backgroundColor = [UIColor grayColor];
  
  return btn;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca uno de los botones de items adicionales
- (void)OnButttonClose:(id)sender
  {
  if( OnCloseFun && CloseTarget )                                                   // Si se establecio el metodo para la notificación
    {
    NSThread* nowThread = [NSThread currentThread];
    [CloseTarget performSelector:OnCloseFun onThread:nowThread withObject:self waitUntilDone:NO];       // Realiza la notificacion
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
  {
  float w = self.superview.bounds.size.width;
  
  self.frame     = CGRectMake( 0, 0, w, STUS_H + BTN_H );
  ModLabel.frame = CGRectMake( 0, STUS_H, w, LineHeight);                                  // Cualquier frame, en el layout se recalcuala
  btnClose.frame = CGRectMake( w-BTN_H, STUS_H, BTN_W, BTN_H);
  
  [self setNeedsDisplay];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  CGContextRef ct = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(ct, ColHeaderBck.CGColor);

  float w = self.superview.bounds.size.width;
  
  CGRect rc = CGRectMake(0, 0, w, self.Height);
  CGContextFillRect(ct, rc);
  
  rc = CGRectInset(btnClose.frame, 4, 4);
  DrawRoundRect( rc, R_ALL, ColBrdRound2, ColMainBck);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
@end
//=========================================================================================================================================================
