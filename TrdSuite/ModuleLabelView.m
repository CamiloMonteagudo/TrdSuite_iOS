//=========================================================================================================================================================
//  ModuleLabelView.m
//  TrdSuite
//
//  Created by Camilo on 18/08/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "ModuleLabelView.h"
#import "AppData.h"
#import "ColAndFont.h"

@interface ModuleLabelView()
  {
  UILabel* Title;
  
  CGRect rcIni;                           // Rectangulo donde se inicia la animación
  CGRect rcFin;                           // Rectangulo donde termina la animación
  }

@end

//=========================================================================================================================================================
@implementation ModuleLabelView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  if( !self ) return nil;

  self.backgroundColor = [UIColor clearColor];
  self.hidden = TRUE;
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se combia el texto a mostrar
- (void)CreateLabel:(NSString *)Text
  {
  if( Title == nil )
    {
    CGFloat w = rcIni.size.width  - (2*ROUND);
    CGFloat h = rcIni.size.height - (2*ROUND);
    
    CGRect rcTitle  = CGRectMake( ROUND, ROUND, w, h);
  
    Title               = [[UILabel alloc] initWithFrame: rcTitle];                 // Crea la vista para el titulo
    Title.textColor     = ColPanelBck;                                          // Pone el color de las letras del titulo
    Title.textAlignment = NSTextAlignmentCenter;                                  // Centra el titulo por la horizontal
    Title.font          = fontTitle;                                               // Pone el tipo de letra a utilizar
    
    //Title.backgroundColor = [UIColor redColor];
    [self addSubview: Title];                                                   // Agrega la vista del titulo a la fila
    }

  Title.text = Text;                                                     // Pone el texto del titulo
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra el titulo del modulo
- (void) ShowLabel:(NSString *)Text InFrame:(CGRect) frm
  {
  CGFloat w = self.frame.size.width;
  CGFloat h = 2.0 * LineHeight;
  CGFloat x = (frm.size.width-w)/2;
  CGFloat y = frm.origin.y + frm.size.height;
  
  rcIni = CGRectMake( x , y, w, h );
  
  self.frame  = rcIni;
  [self CreateLabel:Text];
  
  self.hidden = FALSE;

  rcFin          = rcIni;
  rcFin.origin.y = rcIni.origin.y - h - 5;
  
  [UIView animateWithDuration:1 animations:^{ self.frame=rcFin;} ];
  
  [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(EndTime:) userInfo:nil repeats:NO];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama después de mostrar el label del modulo por 5 segundos, para esconderlo
- (void)EndTime: (NSTimer *) timer
  {
  [UIView animateWithDuration:1 animations:^{ self.frame=rcIni; } completion:^(BOOL finished) { self.hidden=TRUE; } ];
	}

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca en cualquier lugar de la pantalla
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  [UIView animateWithDuration:0.5 animations:^{ self.frame=rcIni; } completion:^(BOOL finished) { self.hidden=TRUE; } ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el borde redondiado alrededor del la vista de edicción
- (void)drawRect:(CGRect)rect
  {
  CGRect rc = CGRectInset(self.bounds, 2, 2)  ;
  
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
  CGContextSetLineWidth(ct, 2);
  CGContextSetStrokeColorWithColor(ct, ColPanelBck.CGColor);
  CGContextSetFillColorWithColor(ct, ColPanelItemBck.CGColor);

  float xIzq = rc.origin.x;
  float xDer = xIzq + rc.size.width;

  float ySup = rc.origin.y;
  float yInf = ySup + rc.size.height;
  
  float ycSup  = ySup + ROUND;
  float xcSupI = xIzq + ROUND;
  float xcSupD = xDer - ROUND;

  float ycInf  = yInf - ROUND;
  float xcInfI = xIzq + ROUND;
  float xcInfD = xDer - ROUND;

  CGContextBeginPath(ct);
	CGContextMoveToPoint   (ct, xcSupI, ySup  );
  CGContextAddArc        (ct, xcSupI, ycSup , ROUND, -M_PI_2, -M_PI  , 1 );
  CGContextAddLineToPoint(ct, xIzq  , ycInf );
  CGContextAddArc        (ct, xcInfI, ycInf , ROUND, -M_PI  ,  M_PI_2, 1 );
  CGContextAddLineToPoint(ct, xcInfD, yInf );
  CGContextAddArc        (ct, xcInfD, ycInf , ROUND, M_PI_2 ,  0     , 1 );
  CGContextAddLineToPoint(ct, xDer  , ycSup );
  CGContextAddArc        (ct, xcSupD, ycSup , ROUND, 0      , -M_PI_2, 1 );
  
  CGContextClosePath(ct);
    
  CGContextDrawPath( ct, kCGPathFillStroke);
  }

@end
//=========================================================================================================================================================
