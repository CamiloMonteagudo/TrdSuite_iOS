//=========================================================================================================================================================
//  SrcPanel.h
//  PruTranslate
//
//  Created by Camilo on 26/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

@class LangsPanelView;

//=========================================================================================================================================================
@protocol LangsPanelDelegate <NSObject>

- (void) OnSelLang:(LangsPanelView *)Panel;
- (void) OnChanged:(LangsPanelView *)Panel Text:(UITextView *)textView;

@optional
- (void) OnSelItem:(LangsPanelView *)Panel;
- (void) OnBack:(LangsPanelView *)Panel;
- (void) OnChanged:(LangsPanelView *)Panel SelectText:(UITextView *)textView;
- (void) OnKeyBoardReturn;

@end

//=========================================================================================================================================================
@interface LangsPanelView : UIView <UITextViewDelegate, NSLayoutManagerDelegate>

  @property (weak) id<LangsPanelDelegate> Delegate;
  
  @property (nonatomic) int  SelLng;                     // Idioma que se encuentra seleccionado
  @property (nonatomic) int  SelItem;                    // Item adiconal que se encuentra seleccionado
  @property (nonatomic) BOOL Back;                       // Pone el botón de retroceso en la barra de botones
  @property (nonatomic) int  Round;                      // Define el tipo de redondeado que va tener

  @property (nonatomic) int BoxInit;                     // Separación inicial del recuadro del borde de la vista
  @property (nonatomic) int BoxMaxWidth;                 // Maximo ancho del recuadro

  @property (nonatomic) NSString* PlaceHolderKey;        // Clava para buscar las cadenas que se muestran como placeholder
  @property (nonatomic) BOOL NoSaveText;                 // No guarda útimo texto escrito, para cada idoma
  @property (nonatomic) BOOL HideTitle;                  // No muestra titulo del idioma
  @property (nonatomic) BOOL TextMark;                   // Si marcar el texto seleccionado o no
  @property (nonatomic) UIReturnKeyType ReturnType;      // Pone el tipo de retorno del teclado

  @property (nonatomic, weak) NSString* Text;           // Texto traducido
  
  @property (nonatomic, readonly ) float StaticHeight;  // Retorna altura de la vista que no varia

- (NSRange)   GetMarkText;
- (void)      SetMarkText:(NSRange) range;
- (void)      ClearMarkText;

- (void)RefreshLangs;

- (void) AddItemID:(NSString*) strItem;
- (void) ClearAllItems;

- (UITextView*) GetTextView;
- (void)    RefreshView;

@end
//=========================================================================================================================================================
