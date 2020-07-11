//=========================================================================================================================================================
//  TrdEditView.m
//  TrdSuite
//
//  Created by Camilo on 01/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "TrdEditView.h"
#import "AppData.h"
#import "MainController.h"
#import "ColAndFont.h"

#define  LGNAME_W  180
#define  Y_INI     20

//=========================================================================================================================================================
@interface TrdEditView()
  {
  float Width;
  float Height;
  
  float HEdSrc;
  float HEdTrd;
  
  UIImageView *FgSrc, *FgTrd;
  UILabel     *lbSrc, *lbTrd;
  UITextView  *txSrc, *txTrd;
  
  UIButton* btnSaveTrd;                         // Guarda los cambios realizados hasta el momento
  UIButton* btnClose;                           // Cierra la vista de notificación sin guardar los cambio
  }

@end

//=========================================================================================================================================================
@implementation TrdEditView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  if( !self ) return nil;
  
  [self MakeViews];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
  {
  self = [super initWithFrame:frame];
  if( !self ) return nil;
  
  [self MakeViews];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa las propiedades 'TextSrc' y 'TextTrd'
- (NSString *)TextSrc { return txSrc.text; }
- (NSString *)TextTrd { return txTrd.text; }
- (BOOL)   SaveHidden { return btnSaveTrd.hidden; }

- (void)setTextSrc:(NSString *)TextSrc { txSrc.text = TextSrc; [self setNeedsLayout]; }
- (void)setTextTrd:(NSString *)TextTrd { txTrd.text = TextTrd; [self setNeedsLayout]; }
- (void)setSaveHidden:(BOOL)SaveHidden { btnSaveTrd.hidden = SaveHidden; }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Intercepta cuando se muetra la vista, para actualizar los datos
- (void)setHidden:(BOOL)hidden
  {
  super.hidden = hidden;
  if( !hidden ) [self UpdateData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea todas las subvistas
- (void) MakeViews
  {
  Width = self.frame.size.width;

  [self MakeTitle];
  
  FgSrc = [self MakeFlagView ];
  lbSrc = [self MakeLabelView];
  txSrc = [self MakeEditView ];
  
  FgTrd = [self MakeFlagView  ];
  lbTrd = [self MakeLabelView ];
  txTrd = [self MakeEditView  ];
  
  btnClose   = [self MakeButton:@"BtnClose1" Num:1];
  btnSaveTrd = [self MakeButton:@"BtnSave"   Num:2];
  
  txSrc.delegate = self;                                  // Pone delegado para el control de texto
  txSrc.layoutManager.delegate = self;                    // Pone delegado para el layoutManager del control de texto
  
  txTrd.delegate = self;                                  // Pone delegado para el control de texto
  txTrd.layoutManager.delegate = self;                    // Pone delegado para el layoutManager del control de texto
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImageView*) MakeFlagView
  {
  float x = SEP_BRD + SEP_TXT;
  float y = Y_INI + (LineHeight-FLAG_H)/2;
  
  CGRect frame = CGRectMake( x, y, FLAG_W, FLAG_H);
  
  UIImageView* img = [[UIImageView alloc] initWithFrame: frame];
  
  [self addSubview: img];
  
  return img;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) MakeTitle
  {
  UILabel* title         = [[UILabel alloc] initWithFrame: CGRectMake( 0, 0, Width, LineHeight)];
  title.font             = fontPanelTitle;
  title.textColor        = ColPanelTitle;
  title.textAlignment    = NSTextAlignmentCenter;
  title.text             = NSLocalizedString(@"TitleEdit", nil);
  title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
  [self addSubview: title];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (UILabel*) MakeLabelView
  {
  float hText = LineHeight;                         // Obtiene altura del texto
  float x = SEP_BRD + SEP_TXT + FLAG_W + SEP_BRD;
  
  UILabel* Lb  = [[UILabel alloc] initWithFrame: CGRectMake( x, Y_INI, LGNAME_W, hText)];
  Lb.font      = fontTxtBtns;
  Lb.textColor = ColTxtBtns;
  
  [self addSubview: Lb];
  return Lb;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (UITextView *) MakeEditView
  {
  float hText = LineHeight;                         // Obtiene altura del texto
  float x = SEP_BRD+BRD_W;
  float w = Width - 2*x;
  
  UITextView* Ed      = [[UITextView alloc] initWithFrame: CGRectMake( x, 0, w, hText)];
  Ed.font             = fontEdit;
  Ed.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
  [self addSubview: Ed];
  return Ed;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (UIButton*) MakeButton:(NSString*)sImage Num:(int) n
  {
  float   x = Width - n * ( BTN_W + SEP_BRD );
  CGRect rc = CGRectMake( x, 0, BTN_W, BTN_H);
    
  UIButton* btn = [[UIButton alloc] initWithFrame:rc];
    
  [btn addTarget:self action:@selector(OnTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
  [btn setTitle: @"" forState: UIControlStateNormal ];
  [btn setImage: [UIImage imageNamed: sImage] forState: UIControlStateNormal ];
  
  btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  
  [self addSubview:btn];
  
  return btn;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) UpdateData
  {
  FgSrc.image = [UIImage imageNamed: LGFlagFile( LGSrc, @"30" ) ];
  lbSrc.text = LGName(LGSrc);

  FgTrd.image = [UIImage imageNamed: LGFlagFile( LGDes, @"30" ) ];
  lbTrd.text = LGName(LGDes);
  
  [self ChkSaveVisibility];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se esta editando la traducción
- (void) ChkSaveVisibility
  {
  NSString *srcText = txSrc.text;                                           // Toma el texto de origen
  NSString *trdText = txTrd.text;                                           // Toma el texto traducido
  
  BOOL exist = [History ExistTrdSrc:srcText Trd:trdText ToLang:LGDes];      // Determina si la traducción ya esta en la hostoria

  btnSaveTrd.hidden = exist;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto
- (void)textViewDidChange:(UITextView *)textView
  {
  [self ChkSaveVisibility];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se comienza a editar el texto
- (void)textViewDidBeginEditing:(UITextView *)textView
  {
  if( KbHeight != 0 )                                                     // Se comenzo la edicción del texto sin ocultar el teclado
    [self.superview setNeedsLayout];                                      // Notifica al padre, por si hay que scrolear la vista

  Responder = textView;                                                   // Pone la vista en edición en una varible global, para ocultar el teclado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se termina de calcular el layout del texto dentro del control de edicción
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
  {
  [self setNeedsLayout];                                // Recalcula distribución de los controles
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cuando se toca fuera de los editores, se esconde el teclado
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  HideKeyBoard();
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca uno de los botones de la vista
- (void)OnTapButton:(id)sender
  {
  HideKeyBoard();                                               // Oculta el teclado
  
  if( sender == btnSaveTrd )
    {
    [_Ctrller OnBtnSaveEditTrd];
    btnSaveTrd.hidden = TRUE;
    }
  else if( sender == btnClose   ) [_Ctrller OnBtnCloseEditTrd];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (float) GetHeightTex:(UITextView *) TextCtl
  {
  CGRect rcTxt = [TextCtl.layoutManager usedRectForTextContainer:TextCtl.textContainer];  // Obtiene el tamaño del texto
  
  float hText = rcTxt.size.height + FontSize;                                             // Obtiene altura del control, con margen arriba y abajo
  if( hText>EditMaxHeigth )                                                               // Chequea si sobrepasa el tamaño maximo
      hText = EditMaxHeigth;                                                              // Lo pone al tamaño máximo
    
  return hText;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
  {
  BOOL chgSrc=FALSE;
  
  float w = self.frame.size.width;
  
  float xIni = SEP_BRD+BRD_W;
  float wAll = w - 2*xIni;
    
  float y = Y_INI + LineHeight - 2;
  
  float hSrc = [self GetHeightTex:txSrc];
  if( hSrc != HEdSrc || w != Width )
    {
    HEdSrc = hSrc;
    
    txSrc.frame = CGRectMake( xIni , y, wAll, hSrc );
    
    chgSrc = true;
    }
    
  y += hSrc + 3;
  
  float hLb = lbTrd.frame.size.height;
  
  if( chgSrc )
    {
    float xFg = SEP_BRD + SEP_TXT;
    float yFg = y + (hLb-FLAG_H)/2;
    
    FgTrd.frame =  CGRectMake( xFg               , yFg,   FLAG_W, FLAG_H );
    lbTrd.frame =  CGRectMake( xFg+FLAG_W+SEP_BRD,   y, LGNAME_W, hLb    );
    }
  
  y += hLb-2;

  float hTrd = [self GetHeightTex:txTrd];
  if( hTrd != HEdTrd || chgSrc  || w != Width )
    {
    HEdTrd = hTrd;
    
    txTrd.frame = CGRectMake( xIni , y, wAll, hTrd );
    
    y += hTrd + ROUND;
  
    if( w != Width || y!= Height )
      {
      Width  = w;
      Height = y;
      
      CGRect rc = self.frame;
      rc.size.width  = w;
      rc.size.height = y;
      
      self.frame = rc;
      
      [self setNeedsDisplay];                                               // Redibuja el fondo del panel
      [self.superview setNeedsLayout];                                      // Reorganiza los controles de la vista que contiene al panel
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//  Retorna retorna la altura de la vista sin el texto
- (float) StaticHeight
  {
  CGSize sz1 = self.frame.size;                               // Obtiene tamaño actual de la vista
  CGSize sz2 = txSrc.frame.size;                              // Obtiene tamaño actual de la vista de texto fuente
  CGSize sz3 = txTrd.frame.size;                              // Obtiene tamaño actual de la vista de texto traducido
  
  return sz1.height - sz2.height- sz3.height;                 // Retorna el espacio estatico de la vista
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  float w = self.frame.size.width - 2*SEP_BRD;
  float h = self.frame.size.height;

  CGRect rc = CGRectMake(SEP_BRD, 1, w, h-2*BRD_W );
  
  DrawRoundRect( rc, R_ALL, ColBrdRound1, ColFillRound1);
  }

@end
