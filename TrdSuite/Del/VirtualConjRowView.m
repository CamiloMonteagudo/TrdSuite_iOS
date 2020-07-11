//
//  VirtualConjRowView.m
//  PruTranslate
//
//  Created by Camilo on 20/03/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "VirtualConjRowView.h"
#include "ProxyConj.h"

//=========================================================================================================================================================
@interface VirtualConjRowView ()
  {
  UILabel* lbWord;
  }

@end

//=========================================================================================================================================================
//static NSMutableArray *ConjRowCache;                          // Filas que se usan en la zona visual
static NSArray*        Conjs;

//=========================================================================================================================================================
@implementation VirtualConjRowView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Establece la lista de conjugaciones con la que se esta trabajando actualmente
+(void) SetConjData:(NSArray*) lstConjs
  {
  Conjs = lstConjs;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(VirtualConjRowView *) RowWithConjIndex:(int) index Width:(float)w
  {
  VirtualConjRowView* view;
  
  int h = (w<450)? 45: 30;
  
  CGRect frame = CGRectMake(0, 0, w, h);
  
  view = [[VirtualConjRowView alloc] initWithFrame:frame];
  
  frame.origin.x = 5;
  frame.size.width = w-10;
  
  view->lbWord = [[UILabel alloc] initWithFrame: frame];
  view->lbWord.autoresizingMask = 0xFF;
  view->lbWord.numberOfLines  = 0;
//  view->lbWord.backgroundColor = [UIColor blueColor];
    
  [view addSubview: view->lbWord];
  
  view.tag   = -1;
    
  view.backgroundColor = [UIColor whiteColor];
  
  view.Index = index;
  
  ConjGroup* Grp = Conjs[index];
   
  view->lbWord.attributedText = [ProxyConj TextFromGrpCnj:Grp Height:h];
  
  return view;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona la fila al cache
- (void) CacheView
  {
//  if( ConjRowCache == nil )
//    ConjRowCache = [[NSMutableArray alloc] initWithCapacity:20];
//  
//  [ConjRowCache addObject: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
