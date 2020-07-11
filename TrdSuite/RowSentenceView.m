//=========================================================================================================================================================
//  RowSentenceView.m
//  TrdSuite
//
//  Created by Camilo on 09/11/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "RowSentenceView.h"
#import "AppData.h"
#import "ColAndFont.h"
#import "Sentences.h"

//=========================================================================================================================================================
static NSMutableArray *OrasRowCache;                               // Filas que se usan en la zona visual

//=========================================================================================================================================================
float HeightTextWithWidth( NSString* Text,  float Width )
  {
  float Height = LineHeight;
  
  if( Text.length*FontSize > Width )
    {
    CGSize  sz = CGSizeMake( Width, 5000);
    CGRect rc1 = [Text boundingRectWithSize: sz
                                    options: NSStringDrawingUsesLineFragmentOrigin
                                 attributes: attrHistory
                                    context: nil      ];
  
    int hTxt = rc1.size.height + FontSize-1;
    if( hTxt>LineHeight ) Height = hTxt;

    if( Height > 3*FontSize )
      Height = 3*FontSize;
    }
  
  return Height;
  }

//=========================================================================================================================================================
@interface RowSentSingleView()
  {
  }
@end

//=========================================================================================================================================================
@implementation RowSentSingleView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(RowSentSingleView *) RowWithOraIndex:(int) index Width:(float)w
  {
  NSString* txtSrc = [[Sentences Actual] GetSrcTextAt:index];
  float     Height = HeightTextWithWidth( txtSrc, w-10 );
  CGRect     frame = CGRectMake(0, 0, w, Height);
  
  RowSentSingleView* view;
  UILabel* src;

  if( OrasRowCache && OrasRowCache.count>0 )                            // Si el cache existe y hay al menos una fila
    {
    view = [OrasRowCache lastObject];                                   // Toma la ultima fila del cache
    [OrasRowCache removeLastObject];                                    // La quita del cache
    
    view.frame = frame;                                                 // Actualiza el tamaño
    src = view.subviews[0];
    }
  else                                                                  // Si no hay filas en el cache
    {
    view = [[RowSentSingleView alloc] initWithFrame:frame];
  
    frame.origin.x = 5;
    frame.size.width = w-10;
  
    src = [[UILabel alloc] initWithFrame: frame];
  
    src.autoresizingMask = 0xFF;
    src.numberOfLines    = 0;
    
    [view addSubview: src];
  
    view.tag   = -1;
    view.backgroundColor = [UIColor whiteColor];
  
    }
    
  view.Index = index;
  
  src.font   = fontHistory;
  src.text   = txtSrc;
  
  return view;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona la fila al cache
- (void) CacheView
  {
  if( OrasRowCache == nil )
    OrasRowCache = [[NSMutableArray alloc] initWithCapacity:20];
  
  [OrasRowCache addObject: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================

//=========================================================================================================================================================
@interface RowSentSelectedView()
  {
  BtnDelView* btnDel;
  }
@end

//=========================================================================================================================================================
@implementation RowSentSelectedView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(RowSentSelectedView *) RowWithOraIndex:(int) index Width:(float)w
  {
  RowSentSelectedView* view = [[RowSentSelectedView alloc] init];
  
  view.tag   = -1;
  view.Index = index;
  
  Sentences *Oras = [Sentences Actual];
  
  NSString* srcText = [Oras GetSrcTextAt:index];
  NSString* trdText = [Oras GetTrdTextAt:index];
  
  float yPos = 0;
  [view CreateLabelText:srcText Lang:Oras.LangSrc YPos:&yPos Width:w ];
  
  yPos -= (LineHeight/4.0);
  [view CreateLabelText:trdText Lang:Oras.LangDes YPos:&yPos Width:w ];
    
  view.frame = CGRectMake(0, 0, w, yPos);
  view.backgroundColor = ColBckSelHistoy1;
    
  view->btnDel = [BtnDelView BtnDelInView:view];
  
  return view;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el un label con la información del item de traducción 'idx'
- (void) CreateLabelText:(NSString*) text Lang:(int) lng YPos:(float*) yPos Width:(float)w
  {
  int wTxt = w -  50;
  
  text = [FlagSpaces stringByAppendingString: text];
  
  float h = HeightTextWithWidth( text, wTxt );
  
  CGRect frame = CGRectMake( 0, *yPos, w, h);
  
  UIView* rowView = [[UIView alloc] initWithFrame: frame];
   
  CGRect rc = CGRectMake( 5, 0, wTxt, h);
  UILabel* Text = [[UILabel alloc] initWithFrame: rc];
  Text.numberOfLines    = 0;
  Text.font             = fontHistory;
  Text.text             = text;
  
  [rowView  addSubview: Text];
  [self addSubview: rowView];
  
  [self CreateFlagLang:lng InView:rowView];
  
  *yPos = *yPos + h;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) CreateFlagLang:(int) Lng InView:(UIView*)rowView
  {
  CGRect frame = CGRectMake( 5, (LineHeight-FLAG_H)/2.0, FLAG_W, FLAG_H);
  
  UIImageView* img = [[UIImageView alloc] initWithFrame: frame];
  img.image   = [UIImage imageNamed: LGFlagFile(Lng,@"30") ];
  
  [rowView addSubview: img];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona la fila al cache
// Nota: No implementada, porque estas filas son muy diferentes y solo se usa una en toda la lista
- (void) CacheView
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Atienede cuando se toca sobre la fila
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
  {
  VirtualListView* List = (VirtualListView*)self.superview;     // Obtiene la lista que contiene la fila
  CGPoint pnt = [[touches anyObject] locationInView: self];     // Punto que se toco dentro de la fila
  
  if( CGRectContainsPoint( btnDel.frame, pnt ) )                // Si esta dentro de boton de borrar
    {
    if( btnDel.Expanded )
      [List.VirtualListDelegate OnSelectedRow: -1];             // Llama a la función que atiende el evento de seleccionar una fila
    else
      btnDel.Expanded = TRUE;
    }
  else
    [List.VirtualListDelegate OnSelectedRow: -2];               // Llama a la función que atiende el evento de seleccionar una fila
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end
//=========================================================================================================================================================

//=========================================================================================================================================================
@interface BtnDelView()
  {
  UIImageView* imgDel;
  }
@end

//=========================================================================================================================================================
@implementation BtnDelView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(BtnDelView *) BtnDelInView:(UIView*) parent
  {
  CGSize sz = parent.frame.size;
  CGRect rc = CGRectMake( sz.width-BTN_W, (sz.height-BTN_H)/2, BTN_W, BTN_H);
  
  BtnDelView* view = [[BtnDelView alloc] initWithFrame:rc ];
  view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  
  view.backgroundColor = [UIColor clearColor];
  
  [parent addSubview: view];
  
  float x = (BTN_W - 20) / 2.0;
  float y = (BTN_H - 20) / 2.0;
  
  CGRect frame = CGRectMake( x, y, 20, 20);
  
  view->imgDel= [[UIImageView alloc] initWithFrame: frame];
  view->imgDel.image   = [UIImage imageNamed: @"Delete" ];
  
  [view addSubview: view->imgDel];
  
  return view;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setExpanded:(BOOL)Expanded
  {
  _Expanded = Expanded;
  if( !Expanded ) return;

  NSString* txt = NSLocalizedString(@"Delete", nil);
  CGPoint   pos = self.frame.origin;
  CGSize     sz = self.frame.size;

  CGPoint lbPos = CGPointMake( 0, (sz.height-LineHeight)/2.0);
  
  RoundLabelView* lbDel = [RoundLabelView RoundLabelText:txt Pos:lbPos];
 
  float w = lbDel.frame.size.width;
  
  [UIView animateWithDuration: 0.3
                   animations: ^{
                                self.frame = CGRectMake( pos.x+sz.width, pos.y, 0, sz.height);
                                }
                   completion:^(BOOL finished)
                                {
                                imgDel.alpha = 0;
                                
                                [self addSubview:lbDel];
                                
                                CGRect rc2 = CGRectMake( pos.x-(w-sz.width)-5, pos.y, w, sz.height);
  
                                [UIView animateWithDuration: 0.5
                                                 animations: ^{
                                                              self.frame = rc2;
                                                              } ];
                                }];
  }

@end
//=========================================================================================================================================================

//=========================================================================================================================================================
@implementation RoundLabelView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(RoundLabelView *) RoundLabelText:(NSString*) txt Pos:(CGPoint) pos
  {
  float    h = LineHeight;
  float    w = [txt sizeWithAttributes:attrBuy].width + 20;
  CGRect rc1 = CGRectMake(pos.x, pos.y, w, h);
  
  RoundLabelView* view = [[RoundLabelView alloc] initWithFrame:rc1];
  view.backgroundColor = [UIColor clearColor];
  
  UILabel* Text;
  
  CGRect rc2 = CGRectMake( 10, 0, w-18, h);
  Text = [[UILabel alloc] initWithFrame: rc2];
  Text.numberOfLines = 0;
  Text.font          = fontBuyItem;
  Text.textColor     = ColPanelTitle;
  Text.text          = txt;
  
  [view addSubview: Text];
  
  return view;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja un fondo con los bordes redondeados
- (void)drawRect:(CGRect)rect
  {
  UIColor* col = [UIColor redColor];

  DrawRoundRect( self.bounds, R_ALL, col, col);
  }
@end
//=========================================================================================================================================================

