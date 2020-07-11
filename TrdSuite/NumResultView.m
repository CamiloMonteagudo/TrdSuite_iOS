//=========================================================================================================================================================
//  NumResultView.m
//  TrdSuite
//
//  Created by Camilo on 28/09/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "NumResultView.h"
#import "AppData.h"
#import "ColAndFont.h"
#import "ReadNumber.h"
#import "NumGroupView.h"

//=========================================================================================================================================================
@interface NumResultView ()
  {
  float hPanel;
  float wPanel;
  
  UILabel* lbCardinal;
  UILabel* txtCardinal;
  UISegmentedControl *SelType;
  
  UILabel* lbOrdinal;
  UILabel* txtOrdinal;
  
  UILabel* lbRomano;
  UILabel* txtRomano;
  }

@end

//=========================================================================================================================================================
// Permite editar texto o número separando los grupos con un espacio

@implementation NumResultView
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

  wPanel = self.frame.size.width;
  
  CGPoint pos = self.frame.origin;
  self.frame  = CGRectMake(pos.x, pos.y, wPanel, LineHeight );
  
  lbCardinal  = [self CreateLabelWithText:@"lbCardinal" ];
  txtCardinal = [self CreateLabelWithText:nil           ];
  lbOrdinal   = [self CreateLabelWithText:@"lbOrdinal"  ];
  txtOrdinal  = [self CreateLabelWithText:nil           ];
  lbRomano    = [self CreateLabelWithText:@"lbRomano"   ];
  txtRomano   = [self CreateLabelWithText:nil           ];
  
  float  wText = wPanel-2*SEP_BRD - 2*SEP_TXT;                   // Calcula ancho del control del texto
  CGRect    rc = CGRectMake(SEP_BRD+SEP_TXT, SEP_TXT, wText, LineHeight);
  
  NSString* title1 = NSLocalizedString(@"GroupAll", nil);
  NSString* title2 = NSLocalizedString(@"Group2"  , nil);
  NSString* title3 = NSLocalizedString(@"Group3"  , nil);
  
  SelType = [[UISegmentedControl alloc] initWithFrame:rc];
  
  [SelType addTarget:self action:@selector(ChangeType:) forControlEvents:UIControlEventValueChanged];
  
  [SelType insertSegmentWithTitle:title1 atIndex:0 animated:FALSE];
  [SelType insertSegmentWithTitle:title2 atIndex:1 animated:FALSE];
  [SelType insertSegmentWithTitle:title3 atIndex:2 animated:FALSE];
  
  SelType.tintColor =  ColMeanGray;

  SelType.selectedSegmentIndex = 0;

  [self addSubview:SelType];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un label y opcionalmente le pone un texto
-(UILabel*) CreateLabelWithText:(NSString*) txt
  {
  CGRect  rc = CGRectMake(0, 0, wPanel, LineHeight);                                  // Cualquier frame, en el layout se recalcuala
  UILabel* lb = [[UILabel alloc] initWithFrame:rc];
  
  if( txt!=nil )
    {
    lb.font = fontPanelTitle;
    lb.textColor = ColPanelTitle;
    lb.numberOfLines = 1;
    
    lb.text = [@" " stringByAppendingString: NSLocalizedString(txt, nil) ];
    lb.backgroundColor = ColMainBck;
    }
  else
    {
    lb.font = fontEdit;
    lb.numberOfLines = 0;
    lb.lineBreakMode = NSLineBreakByTruncatingHead;
    }
  
  [self addSubview:lb];
  
  return lb;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al cambiar el tipo de agrupamiento
- (void) ChangeType:(id)sender
  {
  HideKeyBoard();
  
  [self SetGroupType];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa la propiedad para poner/obtener el texto
- (void)setText:(NSString *)Text
  {
  txtCardinal.attributedText = [[NSAttributedString alloc] initWithString:Text attributes:attrEdit];
  
  [self setNeedsLayout];
  }

- (NSString *)Text
  {
  return txtCardinal.text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el tipo de agrupado y el tipo de pronuciación del número
- (void) SetGroupType
  {
  switch( SelType.selectedSegmentIndex )
    {
    case 0: _NumEdit.NGroup = GrpAll;  break;
    case 1: _NumEdit.NGroup = GrpBy2;  break;
    case 2: _NumEdit.NGroup = GrpBy3;  break;
    }
    
  [self SetNumberReading];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Lee el número en el idioma actual y pone el reslutado en la vista 'NumText'
- (void) SetNumberReading
  {
  int lng = (LGSrc==4)? 3 : LGSrc;
  
  int MaxChar = [ReadNumber MaxDigistInLang:lng];
  _NumEdit.MaxChars = MaxChar;
  
  NSString* txt = _NumEdit.Text;
  if( txt.length >= MaxChar )
    {
    txt = [txt substringToIndex:MaxChar];
    _NumEdit.Text = txt;
    }
  
  ReadNumber* rn = [ReadNumber NumberWithString:txt Lang:lng];
  
  NSAttributedString* Text = nil;
  switch( SelType.selectedSegmentIndex )
    {
    case 0: Text = [rn ReadCardinalAll      ]; break;
    case 1: Text = [rn ReadCardinalByGroup:2]; break;
    case 2: Text = [rn ReadCardinalByGroup:3]; break;
    }
  
  txtCardinal.attributedText = Text;
  txtOrdinal.text  = [rn ReadOrdinal];
  txtRomano.text   = [rn ReadRomano ];
  
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
  {
  float wView = self.frame.size.width;                         // Ancho actual de la vista
  float     x = SEP_BRD + SEP_TXT;                             // Posición en x para todos los controles
  float     w = wView-(2*x);                                   // Ancho para todas las subvistas
  
  CGRect rc = [txtCardinal.attributedText boundingRectWithSize: CGSizeMake(w, 10000)
                                                       options: NSStringDrawingUsesLineFragmentOrigin
                                                       context: nil ];
  
  float hTxt  = (int)(rc.size.height+1) + FontSize;
  if( hTxt < LineHeight ) hTxt = LineHeight;
  
  float hLabels = LineHeight;
  CGSize szSel = SelType.frame.size;
  float  hView = SEP_TXT +  hTxt + SEP_BRD + szSel.height + SEP_BRD + (5*LineHeight) + SEP_TXT;
  
  if( hView != hPanel || wView != wPanel )
    {
    hPanel = hView;
    wPanel = wView;
    
    CGPoint pos = self.frame.origin;
    self.frame = CGRectMake(pos.x, pos.y, wPanel, hPanel);
    
    float y = SEP_TXT;
    lbCardinal.frame  = CGRectMake(x, y, w, hLabels );
    y += hLabels;
    
    txtCardinal.frame = CGRectMake(x, y, w, hTxt );
    y += hTxt;
    
    SelType.frame = CGRectMake((wPanel-szSel.width)/2, y, szSel.width, szSel.height );
    y += szSel.height + SEP_BRD;
    
    lbOrdinal.frame  = CGRectMake(x, y, w, hLabels );
    y += hLabels;
    
    txtOrdinal.frame  = CGRectMake(x, y, w, hLabels );
    y += hLabels;
    
    lbRomano.frame  = CGRectMake(x, y, w, hLabels );
    y += hLabels;
    
    txtRomano.frame  = CGRectMake(x, y, w, hLabels );
    
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


@end
