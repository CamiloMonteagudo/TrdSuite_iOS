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
  UIButton* btnLang;
  
  float wPanel;
  float hPanel;
  
  int       nowIdx;                             // Indice de la ultima palabra buscada
  NSString* nowKey;                             // Ultima palabra buscada
  
  BOOL showClose;                               // Se esta mostrando el boton de cerra el significado
  }

@end

//=========================================================================================================================================================
@implementation ConjHeaderView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];            // Clase base hace la inicializacion del objeto
  if( !self ) return nil;

  btnMode  = (UIButton*)[self viewWithTag:100];     // Boton para cambiar el modo como se muestran las conjugaciones
  lbMode   = (UILabel* )[self viewWithTag:101];     // Etiqueta donde se muestra el modo actual
  lbVebo   = (UILabel* )[self viewWithTag:102];     // Etiqueta donde aparece el verbo en infinitivo
  lbGerund = (UILabel* )[self viewWithTag:103];     // Etiqueta donde aparece el gerundio
  lbPartic = (UILabel* )[self viewWithTag:104];     // Etiqueta donde aparece el pasado participio
  btnMeans = (UIButton*)[self viewWithTag:105];     // Botón para ver los significados del verbo
  txtMean  = (UILabel* )[self viewWithTag:106];     // Texto donde aparecen los significados del verbo
  btnLang  = (UIButton*)[self viewWithTag:107];     // Botón para mostrar/cambiar idioma

  wPanel = self.frame.size.width - 4*SEP_BRD;
  
  [btnMode  addTarget:self action:@selector(OnChangeModo:) forControlEvents:UIControlEventTouchUpInside];
  [btnMeans addTarget:self action:@selector(OnFindMeans:)  forControlEvents:UIControlEventTouchUpInside];
  [btnLang  addTarget:self action:@selector(OnChangeLang:)  forControlEvents:UIControlEventTouchUpInside];
  
  lbMode.font      = fontPanelTitle;
  lbMode.textColor = ColPanelTitle;
  
  btnLang.hidden = TRUE;
  
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
  
  if( !txtMean.hidden )
    {
    txtMean.hidden = TRUE;
    btnLang.hidden = TRUE;
    
    [self setNeedsLayout];
    }
  else
    {
    txtMean.hidden = false;
  
    [self FindInDictWord:[ProxyConj GetInfinitive]];
    }
    
  [self SetIcon];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el icono de cerrar cuando se muestran los significados y el mostrar significados en caso contrareo
- (void) SetIcon
  {
  if( txtMean.hidden )
    {
    if( showClose )
      {
      [btnMeans setImage: [UIImage imageNamed:@"BtnMeans2" ] forState: UIControlStateNormal ];
      btnMeans.contentEdgeInsets = UIEdgeInsetsMake(5,5,5,5);
      showClose = FALSE;
      }
    }
  else
    {
    if( !showClose )
      {
      [btnMeans setImage: [UIImage imageNamed:@"BtnClose1" ] forState: UIControlStateNormal ];
      btnMeans.contentEdgeInsets = UIEdgeInsetsMake(7,2,3,8);
      showClose = TRUE;
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton con la bandera del idioma
- (void)OnChangeLang:(id)sender
  {
  HideKeyBoard();                                                                   // Se oculta el teclado si esta desplegado
  
  int lng = LGNextDes();
  if( lng >=0 )
    {
    LGDes = lng;
    [self FindInDictWord:[ProxyConj GetInfinitive]];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Limpia los datos y ocupa toda la pantalla
- (void) ClearData
  {
  btnMode.hidden  = true;
  btnMeans.hidden = true;
  btnLang.hidden  = true;
  
  lbVebo.hidden   = true;
  lbGerund.hidden = true;
  lbPartic.hidden = true;
  txtMean.hidden  = true;
  
  lbMode.textColor = ColPanelTitle;
  lbMode.text = @"";
  
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Limpia los datos y ocupa toda la pantalla
- (void) ShowMessage:(NSString*) sMsg Color:(UIColor*) col
  {
  if( col==nil ) col = ColPanelTitle;
  
  lbMode.textColor = col;
  lbMode.text = sMsg;
  
  lbMode.frame = CGRectMake(2*SEP_BRD, 0, wPanel, LineHeight);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra los datos de la conjugacion actual
- (void) ShowDataVerb:(BOOL) isVerb;
  {
  btnMode.hidden  = FALSE;
  btnMeans.hidden = FALSE;
  
  [self setModeLabel];
  
  lbVebo.hidden   = FALSE;
  lbVebo.attributedText = [ProxyConj GetFormatedData:0];                           // Obtiene el verbo en modo infinitivo
  
  if( showClose || !isVerb )
    {
    txtMean.hidden = FALSE;
    NSString* sWord = [ProxyConj GetInfinitive];
    
    if( isVerb )
      [self FindInDictWord: sWord ];
    else
      {
      txtMean.attributedText = [ProxyConj GetAttrError:@"WrdNoFound" Prefix:sWord];
      }
    }
  
  [self SetIcon];                                                                  // Pone imagen que corresponde a boton Buscar/Cerrar
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
  lbMode.textColor = ColPanelTitle;
  
  NSString* sKey = [NSString stringWithFormat:@"ConjMode%d", _Mode];
  
  lbMode.text =NSLocalizedString(sKey, nil);
  
  lbMode.frame = CGRectMake(BTN_W, 0, wPanel-BTN_W, BTN_H);
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
  
  int h  = (int)(rc1.size.height + 1);
  int sep = 0;
  
  if( lbView == txtMean ) { h += FontSize; sep = SEP_TXT; }
  
  lbView.frame = CGRectMake( 2*SEP_BRD, y + sep, rc1.size.width+SEP_BRD, h );
  
  return y + h + sep;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  UIColor* col = [UIColor whiteColor];

  CGRect rc = self.bounds;

  float xi = SEP_BRD + (BRD_W/2.0);
  float xf = rc.size.width - xi;
  
  rc.origin.y = BTN_H-10;
  rc.origin.x = xi;
  
  rc.size.width   = xf-xi;
  rc.size.height -= rc.origin.y;
  
  DrawRoundRect( rc, R_SUP, col, col);
  
  float y = self.bounds.size.height - BRD_W;
  
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
  CGContextSetStrokeColorWithColor(ct, ColCellSep.CGColor);
  CGContextSetLineWidth(ct, BRD_W);

  CGPoint pnts[] = {CGPointMake(xi, y), CGPointMake(xf, y)};
  
  CGContextStrokeLineSegments(ct, pnts, 2);
  
  if( !txtMean.hidden )
    {
    CGContextSetFillColorWithColor(ct, ColBckTrdInfo2.CGColor);
    
    float y1 = rc.origin.y + 2;
    float y2 = txtMean.frame.origin.y;
    float y3 = y2 + txtMean.frame.size.height;
    
    float x1 = rc.origin.x + 2;
    float x3 = x1 + rc.size.width - 4;
    float x2 = x3 - 2*BTN_W;
    
    float r = ROUND;
    
    CGContextMoveToPoint   (ct, x1+r, y2   );
    CGContextAddArc        (ct, x1+r, y2+r, r, -M_PI_2, -M_PI  , 1 );
    CGContextAddLineToPoint(ct, x1  , y3-r );
    CGContextAddArc        (ct, x1+r, y3-r, r, -M_PI  ,  M_PI_2, 1 );
    CGContextAddLineToPoint(ct, x3-r, y3   );
    CGContextAddArc        (ct, x3-r, y3-r, r, M_PI_2 ,  0     , 1 );
    CGContextAddLineToPoint(ct, x3  , y1+r );
    CGContextAddArc        (ct, x3-r, y1+r, r, 0      , -M_PI_2, 1 );
    CGContextAddLineToPoint(ct, x2+r, y1 );
    CGContextAddArc        (ct, x2+r, y1+r, r, -M_PI_2, -M_PI  , 1 );
    CGContextAddLineToPoint(ct, x2  , y2 );
    CGContextClosePath(ct);
    
    CGContextDrawPath( ct, kCGPathFillStroke);
    }
  }

/****************************************************************** BUSCA SIGNIFICADOS *******************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la palabra actual en el diccionario
- (void) FindInDictWord:( NSString *) sWord
  {
  [btnLang setImage: [UIImage imageNamed:LGFlagFile(LGDes, @"30") ] forState: UIControlStateNormal ];
  
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
    {
    btnLang.hidden = FALSE;
    txtMean.attributedText = [ProxyDict getWDataFromIndex:nowIdx NoKey:TRUE];        // Obtiene los significado de la palabra
    }
  else                                                                    // Si no encontro, la palabra
    {
    btnLang.hidden = TRUE;
    txtMean.attributedText = [ProxyConj GetAttrError:@"WrdNoFound" Prefix:sWord];
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
