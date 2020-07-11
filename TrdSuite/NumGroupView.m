//=========================================================================================================================================================
//  NumGruopView.m
//  TrdSuite
//
//  Created by Camilo on 27/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "NumGroupView.h"
#import "AppData.h"
#import "ColAndFont.h"
#import "NumsController.h"

//=========================================================================================================================================================
@interface NumGroupView ()
  {
  float hPanel;
  float wPanel;
  
  UITextView* TextCtl;
  UILabel*    PlaceHolder;
  
  int  nSpc;
  BOOL delSpc;
  
  int nChar;                            // Cantidad de caracteres para agrupar
  int sgn;                              // Singno de la agrupación -1 de izquierda a derecha, 1 derecha a izquierda
  }

@end

//=========================================================================================================================================================
// Permite editar texto o número separando los grupos con un espacio
@implementation NumGroupView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  if( !self ) return nil;

  [self initData];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los datos especifico de la barra de idiomas, una ves creada la vista
- (void) initData
  {
  self.backgroundColor = [UIColor clearColor];

  nChar = 3;
  sgn   = 1;
  
  wPanel = self.frame.size.width;
  hPanel = LineHeight + 2*SEP_TXT;
  
  CGPoint pos = self.frame.origin;
  self.frame  = CGRectMake(pos.x, pos.y, wPanel, hPanel );
  
  float  wText = wPanel-  2*SEP_BRD - 2*SEP_TXT;                   // Calcula ancho del control del texto
  CGRect    rc = CGRectMake(SEP_BRD+SEP_TXT, SEP_TXT, wText, LineHeight);
  
  TextCtl = [[UITextView alloc] initWithFrame:rc];
  
  TextCtl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  TextCtl.keyboardType     = UIKeyboardTypeNumberPad;
  
  [self addSubview:TextCtl];
  
  rc.origin.x   += 5;
  rc.size.width -= 10;
  
  PlaceHolder = [[UILabel alloc] initWithFrame:rc];
  
  [self addSubview:PlaceHolder];
  
  TextCtl.font          = fontEdit;
  PlaceHolder.font      = fontEdit;
  PlaceHolder.textColor = ColHolder;
  
  [self CheckPlaceHolder];
  
  TextCtl.textContainerInset = UIEdgeInsetsMake(FontSize/2.0, 0, FontSize/2.0, 0);
  
  TextCtl.delegate = self;                              // Pone delegado para el control de texto
  TextCtl.layoutManager.delegate = self;                // Pone delegado para el layoutManager del control de texto
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa la propiedad para poner/obtener el texto
- (void)setText:(NSString *)Text
  {
  delSpc = false;
  
  TextCtl.text = Text;
  [self FormatString];
  }

- (NSString *)Text
  {
  NSMutableString* sNum = [NSMutableString stringWithString: TextCtl.text];
  
  NSRange rg = NSMakeRange(0, sNum.length);
  
  [sNum replaceOccurrencesOfString:@" " withString:@"" options:0 range:rg];
  
  return sNum;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa la propiedad para poner/obtener la agrupacion de los digitos
- (void)setNGroup:(int)NGroup
  {
  if( (sgn*nChar) == NGroup ) return;                 // No cambia el valor anterior, no hace nada
  
  if( NGroup<0 ) { sgn=-1; nChar=-NGroup; }
  else           { sgn= 1; nChar= NGroup; }
  
  delSpc=false;
  [self FormatString];
  }

- (int)NGroup
  {
  return sgn*nChar;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Chequea si el texto es vacio y pone el placeholder si es necesario
- (void) CheckPlaceHolder
  {
  // Oculta el placeholder si no hay texto o no hay idioma seleccionado
  PlaceHolder.hidden = (TextCtl.text.length!=0);
  if( !PlaceHolder.hidden )                             // Si el placehoder esta visible
    PlaceHolder.text = NSLocalizedString( @"NumTip" , nil );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto
- (void)textViewDidChange:(UITextView *)textView
  {
  [self CheckPlaceHolder];
  
  int pos = (int)TextCtl.selectedRange.location;

  [self FormatString];
  
  TextCtl.selectedRange = NSMakeRange(pos+nSpc, 0);
  
  [_Ctrller OnChageNum];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
  {
  int pos  = (int)range.location;
  int num  = (int)range.length;
  
  if( num==1 && text.length==0 )                             // Esta borrando
    {
    unichar c = [textView.text characterAtIndex:pos];
    
    delSpc = (c==' ');
    }
  else
    {
    int len = (int)textView.text.length;
    len = len - (int)(len/(nChar+1));
    
    if( len>= _MaxChars )
      return NO;
    }
  
  return YES;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) FormatString
  {
  NSString* Sep = @" ";
  
  NSMutableString* sNum = [NSMutableString stringWithString: TextCtl.text];

  NSRange rg = NSMakeRange(0, sNum.length);
  
  nSpc = (int)[sNum replaceOccurrencesOfString:Sep withString:@"" options:0 range:rg];          // Quita todos los separadores

  int len   = (int)sNum.length;
  int resto = len%nChar;
  int grp   = 0;
  
  if( sgn<0 && len>nChar && resto!=0 ) grp = nChar - resto;
    
  for(int i=0; i<sNum.length; ++i)
    {
    if( grp==nChar )
      {
      [sNum insertString:Sep atIndex:i];
        
      grp = 0;
      --nSpc;
      }
    else
      ++grp;
    }

  if( delSpc ) nSpc = 0;
  else         nSpc = -nSpc;
  
  TextCtl.text = sNum;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se comienza a editar el texto
- (void)textViewDidBeginEditing:(UITextView *)textView
  {
  Responder = textView;                                 // Pone la vista en edición en una varible global, para ocultar el teclado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando termina la edicción del texto
- (void)textViewDidEndEditing:(UITextView *)textView
  {
  Responder = nil;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se termina de calcular el layout del texto dentro del control de edicción
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
  {
  [self setNeedsLayout];                                // Recalcula distribución de los controles
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
  {
  CGPoint  pos = self.frame.origin;
  float  wView = self.frame.size.width;
  float  wText  = wView-  2*SEP_BRD - 2*SEP_TXT;                   // Calcula ancho del control del texto
  
  CGSize sz = [TextCtl.layoutManager usedRectForTextContainer:TextCtl.textContainer].size;
  
  float hTxt  = (int)(sz.height+1) + FontSize;
  float hView = hTxt + 2*SEP_TXT;
  
  if( hView != hPanel || wPanel != wView )
    {
    hPanel = hView;
    wPanel = wView;
    
    self.frame = CGRectMake(pos.x, pos.y, wPanel, hPanel);
    
    TextCtl.frame     = CGRectMake(SEP_BRD+SEP_TXT, SEP_TXT, wText, hTxt);
    PlaceHolder.frame = CGRectMake(SEP_BRD+SEP_TXT+5, SEP_TXT, wText, hTxt);
    
    [self setNeedsDisplay];
    [self.superview setNeedsLayout];                                              // Reorganiza los controles de la vista que contiene al panel
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el borde redondiado alrededor del la vista de edicción
- (void)drawRect:(CGRect)rect
  {
  CGRect rc = CGRectMake(SEP_BRD, 0, wPanel-(2*SEP_BRD), hPanel );
  
  DrawRoundRect( rc, R_ALL, ColBrdRound2, ColFillRound2);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================
