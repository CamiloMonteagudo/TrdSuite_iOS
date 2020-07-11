//=========================================================================================================================================================
//  ConjHeaderView.m
//  TrdSuite
//
//  Created by Camilo on 17/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "ConjHeaderView.h"
#import "AppData.h"
#import "ConjController.h"
#import "ColAndFont.h"
#import "ProxyConj.h"
#import "ProxyDict.h"

//=========================================================================================================================================================
@interface ConjHeaderView()
  {
  UIButton* btnMode;
  UILabel*  lbMode;
  UILabel*  lbVebo;
  UILabel*  lbGerund;
  UILabel*  lbPartic;
  UIButton* btnMeans;
  UILabel*  txtMean;
  
  float wPanel;
  float hPanel;
  
  int       nowIdx;                             // Indice de la ultima palabra buscada
  NSString* nowKey;                             // Ultima palabra buscada
  }

@end

//=========================================================================================================================================================
@implementation ConjHeaderView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  if( !self ) return nil;

  btnMode  = (UIButton*)[self viewWithTag:100];     // Boton para cambiar el modo como se muestran las conjugaciones
  lbMode   = (UILabel* )[self viewWithTag:101];     // Etiqueta donde se muestra el modo actual
  lbVebo   = (UILabel* )[self viewWithTag:102];     // Etiqueta donde aparece el verbo en infinitivo
  lbGerund = (UILabel* )[self viewWithTag:103];     // Etiqueta donde aparece el gerundio
  lbPartic = (UILabel* )[self viewWithTag:104];     // Etiqueta donde aparece el pasado participio
  btnMeans = (UIButton*)[self viewWithTag:105];     // Botón para ver los significados del verbo
  txtMean  = (UILabel* )[self viewWithTag:106];     // Texto donde aparecen los significados del verbo

  [btnMode  addTarget:self action:@selector(OnChangeModo:) forControlEvents:UIControlEventTouchUpInside];
  [btnMeans addTarget:self action:@selector(OnFindMeans:)  forControlEvents:UIControlEventTouchUpInside];
  
  lbMode.font      = fontPanelTitle;
  lbMode.textColor = ColPanelTitle;
  
//  lbGerund.backgroundColor = [UIColor redColor];
//  lbVebo.backgroundColor  = [UIColor blueColor];
//  lbPartic.backgroundColor  = [UIColor cyanColor];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton para cambiar de modo
- (void)OnChangeModo:(id)sender
  {
  HideKeyBoard();                                                                   // Se oculta el teclado si esta desplegado
  
  if( _Mode >= BY_PERSONS ) self.Mode = 0;
  else                      self.Mode = _Mode + 1;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton para buscar los significados del verbo
- (void)OnFindMeans:(id)sender
  {
  HideKeyBoard();                                                                   // Se oculta el teclado si esta desplegado
  
  txtMean.hidden = false;
  
  [self FindInDictWord:[ProxyConj GetInfinitive]];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Limpia los datos y ocupa toda la pantalla
- (void) ClearData
  {
  btnMode.hidden  = true;
  btnMeans.hidden = true;
  lbVebo.hidden   = true;
  lbGerund.hidden = true;
  lbPartic.hidden = true;
  txtMean.hidden  = true;
  
  lbMode.textColor = ColPanelTitle;
  lbMode.text = @"No parece ser un verbo";
  
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Limpia los datos y ocupa toda la pantalla
- (void) ShowData
  {
  btnMode.hidden  = FALSE;
  btnMeans.hidden = FALSE;
  
  [self setModeLabel];
  
  lbVebo.hidden   = FALSE;
  lbVebo.attributedText = [ProxyConj GetFormatedData:0];                           // Obtiene el verbo en modo infinitivo
  
  [self SetByMode];
  
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) SetByMode
  {
  BOOL hide = ( _Mode != BY_MODES );
  
  if( lbGerund.hidden == hide ) return;
  
  lbGerund.hidden = hide;
  lbPartic.hidden = hide;
  
  if( !hide )
    {
    lbGerund.attributedText = [ProxyConj GetFormatedData:1];
    lbPartic.attributedText = [ProxyConj GetFormatedData:2];
    }
    
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca sobre la vista
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  HideKeyBoard();                                                                   // Se oculta el teclado si esta desplegado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al cambiar la propiedad mode
- (void)setMode:(int)Mode
  {
  if( Mode == _Mode ) return;                                                       // El modo es igual al anterior, no hace nada
  
  _Mode = Mode;                                                                     // Pone el nuevo valor del modulo
  
  [self SetByMode];
  
  [_Ctrller OnChangeMode];                                                          // Llama al controlador para que actue en consecuencia
  
  [self setModeLabel];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el label correspondiente al modo actual
- (void) setModeLabel
  {
  NSString* sKey = [NSString stringWithFormat:@"ConjMode%d", _Mode];
  
  lbMode.text =NSLocalizedString(sKey, nil);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
  {
  CGRect rc = self.frame;
  int  y, oldW = wPanel;
  
  wPanel = rc.size.width - 4*SEP_BRD;
  
  if( btnMode.hidden )
    {
    y = self.superview.bounds.size.height - rc.origin.y;
    }
  else
    {
    y = btnMode.frame.size.height - 4;
    y = [self ResizeLabel:lbVebo YPos:y];
    
    CGRect rcVb = lbVebo.frame;
    float     x = rcVb.origin.x + rcVb.size.width + (BTN_W/2);
    
    btnMeans.center = CGPointMake( x, lbVebo.center.y+2 );
    
    if( !txtMean.hidden )
      y =  [self ResizeLabel:txtMean YPos:y];
      
    if( _Mode == BY_MODES )
      {
      y = [self ResizeLabel:lbGerund YPos:y+4];
      
      int y2 = [self ResizeLabel:lbPartic YPos:y+4];
      
      CGRect rc1 = lbGerund.frame;
      CGRect rc2 = lbPartic.frame;
      
      float x = rc1.origin.x + rc1.size.width;
      if( x + rc2.size.width < (2*SEP_BRD)+wPanel )
        {
        rc2.origin.x = x;
        rc2.origin.y = rc1.origin.y;
        
        lbPartic.frame = rc2;
        }
      else
        y = y2;
      }
    
    y += 6;
    }
  
  if( oldW != wPanel || y != hPanel )
    {
    hPanel = y;
    rc.size.height = y;
    self.frame = rc;

    [self setNeedsDisplay];
    [self.superview setNeedsLayout];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Redimenciona el label 'lbView' y retorna la coordenad de su borde inferior
- (int) ResizeLabel:(UILabel *) lbView YPos:(int) y
  {
  CGSize sz = CGSizeMake( wPanel, 1000 );
  CGRect rc1 = [lbView.attributedText boundingRectWithSize:sz options:NSStringDrawingUsesLineFragmentOrigin context:nil];
  
  int h = (int)(rc1.size.height + 1);
  
  lbView.frame = CGRectMake( 2*SEP_BRD, y, rc1.size.width+SEP_BRD, h );
  
  return y + h;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  UIColor* col = [UIColor whiteColor];

  CGRect rc = self.bounds;

  rc.origin.y = BTN_H-10;
  rc.origin.x = SEP_BRD + (BRD_W/2.0);
  
  rc.size.width  -= (2*rc.origin.x);
  rc.size.height -= rc.origin.y;
  
  DrawRoundRect( rc, R_SUP, col, col);
  
  float y = self.bounds.size.height - BRD_W;
  
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
  CGContextSetStrokeColorWithColor(ct, ColCellSep.CGColor);
  CGContextSetLineWidth(ct, BRD_W);

  CGPoint pnts[] = {CGPointMake(rc.origin.x, y), CGPointMake( rc.origin.x+rc.size.width, y )};
  
  CGContextStrokeLineSegments(ct, pnts, 2);
  }

/****************************************************************** BUSCA SIGNIFICADOS *******************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la palabra actual en el diccionario
- (void) FindInDictWord:( NSString *) sWord
  {
  BOOL dOk = [ProxyDict OpenDictSrc:LGSrc Dest:LGDes];                    // Si puede abrir el diccionario
  BOOL wOk = (sWord && [sWord length] != 0 );                             // Si la palabra a buscar no es nula o esta vacia
  BOOL fOK = FALSE;                                                       // Si la palabra fue encontrada
  
  if( dOk && wOk )                                                        // Si todo esta OK
    {
    nowKey = sWord;                                                       // Pone palabra actual para la busqueda
    nowIdx = [ProxyDict getWordIdx:nowKey];                               // Busca la palabra en el diccionario
  
    if( ![ProxyDict Found] ) [self FindLowerWord];                        // No la encontro, la busca en minusculas
    if( ![ProxyDict Found] ) [self FindRootWord ];                        // No la encontro, busca una se sus raices

    fOK = [ProxyDict Found];
    }

  if( fOK )                                                               // Si la palabra fue encontrada
    txtMean.attributedText = [ProxyDict getWDataFromIndex:nowIdx];        // Obtiene los significado de la palabra
  else                                                                    // Si no encontro, la palabra
    {
    NSString* sMsg = NSLocalizedString( @"WrdNoFound", nil);
    txtMean.attributedText = [ProxyDict FormatedMsg:sMsg Title:sWord];    // Pone mensaje de palabra no encontrada
    }
    
  [self setNeedsLayout];                                                  // Reorganiza los controles
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Lleva la palabra actual a minusculas y después la busca en el diccionario
- (void) FindLowerWord
  {
  NSString* lWord = [nowKey lowercaseString];                             // La lleva a minusculas
  
  if( [lWord isEqualToString:nowKey] )                                    // Si son iguales (no tenia mayusculas)
    return;                                                               // No hace nada
    
  nowKey = lWord;                                                         // Pone palabra actual para la busqueda
  nowIdx = [ProxyDict getWordIdx:nowKey];                                 // Busca la palabra en el diccionario
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la primera raíz de la palabra que se encuentre en el diccionario
- (void) FindRootWord
  {
  NSString* rWord = [ProxyConj FindRootWord: nowKey Lang:LGSrc];          // Busca una raiza de la palabra
  if( rWord==nil ) return;                                                // No encontro raiz, no hace nada
    
  nowKey = rWord;                                                         // Pone palabra actual para la busqueda
  nowIdx = [ProxyDict getWordIdx:nowKey];                                 // Busca la palabra en el diccionario
  }

/**********************************************************************************************************************************************/

@end
//=========================================================================================================================================================
