//=========================================================================================================================================================
//  ViewController.m
//  TrdSuite
//
//  Created by Camilo on 15/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "MainController.h"
#import "MainView.h"
#import "AppData.h"
//#import "RowHistoryView.h"
#import "RowSentenceView.h"
#import "Sentences.h"

#import "ProxyTrd.h"
#import "TrdAPI/CommonSrc/WinUtil.h"
#import "DictController.h"
#import "ConjController.h"
#import "NumsController.h"
#import "TrdEditView.h"
#import "ColAndFont.h"

#define MODE_ORAS   0
#define MODE_TRD    1

//=========================================================================================================================================================
@interface MainController ()
  {
  int LGSrcOld;                           // Idioma fuente ante de pasar a otra pantalla
  int LGDesOld;                           // Idioma destino ante de pasar a otra pantalla
  int lastLen;                            // Longitud del ultimo texto escrito
  
  NSString* lastTrdText;                  // Última traducción realizada a un texto fuente determinado
  
  BOOL OutSelf;                           // Bandera que indica que el controlador principal es otro
  id Observer;
  }
  
@property (weak, nonatomic) IBOutlet UIImageView *LaunchImage;

@property (weak, nonatomic) IBOutlet LangsPanelView *PanelSrc;
@property (weak, nonatomic) IBOutlet PanelTrdView *PanelTrd;
@property (weak, nonatomic) IBOutlet MainView *FrameView;
@property (weak, nonatomic) IBOutlet VirtualListView *ListOras;
@property (weak, nonatomic) IBOutlet TrdInfoView* TrdInfo;
@property (weak, nonatomic) IBOutlet TrdEditView *TrdEdit;

@end

//=========================================================================================================================================================
@implementation MainController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  InitMFCSystem();
  GetFlagSpaces();
  
  self.view.backgroundColor  = ColMainBck;
  _FrameView.backgroundColor = ColMainBck;
  
  _TrdEdit.hidden  = TRUE;
  _TrdEdit.Ctrller = self;
  
  _TrdInfo.Ctrller = self;

  _ListOras.VirtualListDelegate = self;
  
  _PanelSrc.Delegate = self;
  _PanelSrc.TextMark = TRUE;
  _PanelSrc.Round    = R_SUP;
  _PanelSrc.PlaceHolderKey = @"TrdTip";
  
  [_PanelSrc AddItemID:@"Dict"];
  [_PanelSrc AddItemID:@"Conj"];
  [_PanelSrc AddItemID:@"Nums"];
  [_PanelSrc AddItemID:@"Setting"];

  _PanelSrc.SelLng = LGFirstSrc();                                    // Pone por defecto el primer idioma fuente instalado
  LGSrcOld = _PanelSrc.SelLng;                                        // Lo guarda como último idioma fuente
  
  _PanelTrd.Ctrller = self;
  
  _PanelTrd.SelLng  = LGInferedDes(-1);                               // Obtiene un idioma de traducción valido (preferiblemente inglés)
  LGDesOld = _PanelTrd.SelLng;                                        // Guarda último idioma destino utilizado
  
  [self CalculateEditMaxHeigth];                                      // Calcula el tamaño maximo de los editores
  
  _FrameView.PanelSrc   = _PanelSrc;
  _FrameView.PanelTrd   = _PanelTrd;
  _FrameView.TrdInfo    = _TrdInfo;
  _FrameView.ListOras   = _ListOras;
  _FrameView.TrdEdit    = _TrdEdit;

  // Notificaciones para cuando se muestra/oculta el teclado
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  Observer = [center addObserverForName: RefreshNotification  object:nil queue:nil
                             usingBlock:^(NSNotification *note)
                                          {
                                          [_PanelSrc RefreshView];    // Cambio el tamaño de las letras o idiomas instalados
                                          [_PanelTrd RefreshView];
                                          
                                          if( note.object == nil )    // Cambio el tamaño de las letras
                                            {
                                            if( _TrdInfo.Mode != MODE_CMDS ) [_TrdInfo RefreshView];
                                            
                                            [_TrdEdit  RefreshView];
                                            [_ListOras Refresh    ];
                                            }
                                          }];
  _ParamWord = @"";
  _ParamSrc  = LGSrc;
  _ParamDes  = LGDes;

  UIImage* img = LoadLaunchImage();
  if( img != nil )
    {
    _LaunchImage.image = img;
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(CloseLaunch:) userInfo:nil repeats:NO];
    }
  else
    {
    _LaunchImage.hidden = TRUE;
    };
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando termina el tiempo de mustra de la imagen inicial
- (void)CloseLaunch: (NSTimer *) timer
  {
  [UIView animateWithDuration:2
                   animations:^{
                               _LaunchImage.alpha = 0;
                               }
                   completion:^(BOOL finished)
                               {
                               _LaunchImage.hidden = TRUE;
                               }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

- (void)viewWillAppear:(BOOL)animated
  {
  _ListOras.MinHeight = LineHeight;                                   // Define la altura minima de las filas en la lista de oraciones
  
  [self FindOnSenteces];                                               // Busca en la lista de oraciones la oración actual
  }

- (void)viewDidUnload
  {
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  [center removeObserver:Observer];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)CalculateEditMaxHeigth
  {
  if( OutSelf ) return;
  
  float old = EditMaxHeigth;

  float H = self.view.bounds.size.height;
  if( !_TrdEdit.hidden )
    EditMaxHeigth = (H - (STUS_H + _TrdEdit.StaticHeight)) / 2;
  else
    EditMaxHeigth = (H - (STUS_H + _PanelSrc.StaticHeight + _PanelTrd.StaticHeight + BTN_H)) / 2;
  
  float KbSpc = H - STUS_H - BTN_H - KbHeight;
  if( KbSpc < LineHeight ) KbSpc = LineHeight;
  
  if( EditMaxHeigth > KbSpc )
    EditMaxHeigth = KbSpc;
  
  if( EditMaxHeigth != old )
    {
    if( !_TrdEdit.hidden )
      [_TrdEdit setNeedsLayout];
    else
      {
      [_PanelSrc setNeedsLayout];
      [_PanelTrd setNeedsLayout];
      }
    }
  }

//+++++++++++++++++++++++++++++++++++++++++++ Implementa LangsPanelDelegate ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia el idioma del texto de origen
- (void) OnSelLang:(LangsPanelView *)Panel;
  {
  if( LGSrc == LGSrcOld ) return;                                     // Si es el mismo idioma no hace nada
    
  [self SaveLastTrd: nil];                                            // Guarda último texto traducido
  lastLen = (int)_PanelSrc.Text.length;                               // Longitud del texto actual
    
  _PanelTrd.SelLng = LGInferedDes(LGSrcOld);                          // Obtiene un idioma destino
  _PanelTrd.NoText = TRUE;                                            // Quita el idioma de traducción
  [_PanelTrd layoutIfNeeded];                                         // Fuerza a que la pantalla se actualice inmediatamente
    
  [self ClearMarkText];                                               // Quita las palabras que esten marcadas
  if( _TrdInfo.Mode != MODE_CMDS )                                    // Si esta mostrando información las palabras
    {
    [self GetMarkedWord];                                             // Obtiene la palabra macada
    [self ProcessMarkWord];                                           // La procesa
    }
    
  [self FindOnSenteces];                                               // Busca la oracion actual en la lista de oraciones
  [_FrameView setNeedsLayout];                                        // Actualiza la distribución de los controles
  
  LGSrcOld = LGSrc;                                                   // Guarda ultimo idioma origen procesado
  
  // Pone parametros por defecto
  _ParamWord = @"";
  _ParamSrc  = LGSrc;
  _ParamDes  = LGDes;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando toca una de las opciones adicionales en el panel de idiomas
- (void) OnSelItem:(LangsPanelView *)Panel
  {
  [self ShowScreenNum:Panel.SelItem ];                                // Pasa a uno de los modulos (Diccionario, Conjugación ... )
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto de origen
- (void) OnChanged:(LangsPanelView *)Panel Text:(UITextView *)textView;
  {
  _PanelTrd.NoText = TRUE;                                            // Quita texto traducido (la tradución ya no es valida)
  [self UnFilterOras];                                                // Quita el filtro, para buscar por todas la oraciones
      
  int lenTxt = (int)_PanelSrc.Text.length;                                 // Longitud del texto actual
  if( (lastLen==0 && lenTxt==1) ||                                    // Cuando se empieza desde un texto vacio
      (lastLen==1 && lenTxt==0) )                                     // Cuando el texto se convierte en vacio
      {
      [_FrameView setNeedsLayout];                                    // Manda a reacomodar los controles
      [_FrameView layoutIfNeeded];                                    // Fuerza a que se redimensione inmediatamente
      }
    
  lastLen = lenTxt;
  [self FindOnSenteces];                                               // Busca la oracion actual en la lista de oraciones
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que cambia la seleccion del texto de origen
- (void) OnChanged:(LangsPanelView *)Panel SelectText:(UITextView *)textView;
  {
  if( _OnTextTrd ) self.OnTextTrd = FALSE;
  
  [self ProcessMarkWord];                                               // Procesa las palabra marcada
  }

//+++++++++++++++++++++++++++++++++++++++++++ Fin LangsPanelDelegate +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++ VirtualListView ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para obtener la vista que representa cada fila
-(VirtualRowView *)GetRowViewAt:(int)iRow
  {
  VirtualRowView *newRow;
  float W = _ListOras.frame.size.width;

  if( _ListOras.SelectedIndex == iRow )
    newRow = [RowSentSelectedView RowWithOraIndex:iRow Width:W];
  else
    newRow = [RowSentSingleView RowWithOraIndex:iRow Width:W];
  
  return newRow;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cunado el usuario toca en una fila
- (void)OnSelectedRow:(int)iRow
  {
  HideKeyBoard();                                               // Oculta el teclado
  if( iRow<0 )                                                  // Si se toco sobre la fila ya seleccionada
    {
    int SelRow = _ListOras.SelectedIndex;
    if( iRow==-1 ) [self OnDelTranslateLng:SelRow ];           // Fue sobre el icono de borrar, borra la oración
    else           [self OnSelTranslateLng:SelRow ];           // Fue sobre el el texto de la oración, selecciona la oración
    }
  else
    {
    [_ListOras SetVisibleRow:iRow];                             // Garantiza que la fila este en la parte visible de la lista
    }
  }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca sobre la vista principal
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  HideKeyBoard();                                               // Oculta el teclado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca una de la banderas de idiomas a traducir
- (void) OnBtnTrd
  {
  NSString *srcText = _PanelSrc.Text;                                     // Toma el texto de origen
  NSString *trdText = [self TranslateText: srcText];                      // Lo manda a traducir

  _PanelTrd.NoText = FALSE;
  _PanelTrd.Text = trdText;                                               // Pone la tradución en el panel de texto traducido
  
  [self CheckSaveBtn];                                                    // Muestra o no el boton de guardar la traducción
    
  if( _TrdInfo.InfoMode == InfoModeTrd )                                  // Si se esta mostrando información sobre el texto trducido
    {
    [self GetMarkedWord];                                                 // Obtiene una nueva, a partir de la primera palabra
    }
  else
    {
    _TrdInfo.InfoMode = -1;                                               // Fuerza a que se redibuje el boton de cambiar información
    [_TrdInfo UpdateButtons];                                             // Recalacula y redibuja el boton central
    }
    
  [self ProcessMarkWord];                                                 // Procesa las palabra marcada
  
  [self FindOnSenteces];                                                   // Busca en la lista de oraciones la oreción traducida
    
  // Pone parametros por defecto para otras vistas
  if( _ParamSrc != LGSrc )                                                // Si cambio el idioma de origen
    _ParamWord = @"";                                                     // Quita la palabra
    
  _ParamSrc  = LGSrc;
  _ParamDes  = LGDes;
  
  [_FrameView setNeedsLayout];                                            // Actualiza la distribución de los controles
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia el texto traducido
- (void) OnChangedTextTrd
  {
  [self CheckSaveBtn];                                                    // Muestra o no el boton de guardar la traducción
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia la seleccion del texto traducido
- (void) OnChangedSelectTextTrd
  {
  if( !_OnTextTrd ) self.OnTextTrd = TRUE;
  
  [self ProcessMarkWord];                                               // Procesa las palabra marcada
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para ocultar las traduciones
- (void) OnBtnHideTrd
  {
  _PanelTrd.NoShow    = TRUE;
  _TrdInfo.SaveHidden = TRUE;
  
  [_FrameView setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia la propiedad OnTextTrd, que define sobre que texto se buscan las raices y los significados
- (void)setOnTextTrd:(BOOL)OnTextTrd
  {
  if( _OnTextTrd == OnTextTrd ) return;

  [self ClearMarkText];
  
  _OnTextTrd = OnTextTrd;                                               // Establece el valor de la propiedad
  
  [_TrdInfo UpdateButtons];                                             // Manda a actualizar el boton central
  
  if(_TrdInfo.Mode != MODE_CMDS )
    {
    [self GetMarkedWord];
    [self ProcessMarkWord];                                            // Procesa las palabra marcada
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza los botones de la barra de comandos
- (void) UpdateButtons
  {
  [_TrdInfo UpdateButtons];                                             // Manda a actualizar el boton central
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si hay que mostrar el botón de guardar o no
- (void) CheckSaveBtn
  {
  BOOL hidden = TRUE;
  
  if( _PanelTrd.NoShow==FALSE && _PanelTrd.NoText==FALSE )
    {
    //OJO: aqui filtar la cadena de entrada
    NSString *srcText = _PanelSrc.Text;                                     // Toma el texto de origen
    //OJO: aqui filtar la cadena de entrada
    NSString *trdText = _PanelTrd.Text;                                     // Texto traducido
    
    hidden = [[Sentences Actual] ExistTrdSrc:srcText Trd:trdText];          // Determina si la traducción ya esta en la lista de oraciones
    }
  
  _TrdInfo.SaveHidden = hidden;                                            // Si existe no muestra el boton para guardar
  _TrdEdit.SaveHidden = hidden;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina el modo que se debe mostrar el boton para cambiar la informacion que se muestra
// InfoModeHide - No se muestra,               InfoModeDown - Muestra panel de traducción,
// InfoModeSrc  - Información de texto fuente, InfoModeTrd  - Información de texto traducido
- (int) GetChgInfoMode
  {
  if( _TrdInfo.Mode != MODE_CMDS )
    {
    if( _OnTextTrd ) return InfoModeTrd;
    else             return InfoModeSrc;
    }
  else if( _PanelTrd.NoShow ) return InfoModeDown;
  
  return InfoModeHide;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina el modo que se debe mostrar el boton de la derecha
// 0- No se muestra, 1- Modificación del texto, 2- Filtar las oraciones, 3-Quitar filtro de las oraciones
- (int) GetEdFilterMode
  {
  if( _PanelTrd.NoShow && _TrdInfo.Mode == MODE_CMDS)
    {
    if( [[Sentences Actual] IsFiltered] ) return 3;
    else                                  return 2;
    }
  
  if( !_PanelTrd.NoShow && !_PanelTrd.NoText)
    return 1;
  
  return 0;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton de la derecha en TrdInfo
- (void) OnBtnChgInfo
  {
  switch (_TrdInfo.InfoMode)
    {
    case InfoModeDown : _PanelTrd.NoShow = FALSE;
                        [self CheckSaveBtn];
                        break;
        
    case InfoModeSrc  : if( !_PanelTrd.NoShow )
                          self.OnTextTrd = TRUE;
                        break;
        
    case InfoModeTrd  : self.OnTextTrd   = FALSE; break;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el modo para trabajar con el texto marcado
- (void) SetMarkedOnTextTrd:(BOOL) txtOn
  {
  self.OnTextTrd = txtOn;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el ultimo boton de la derecha
- (void) OnBtnEdFilter
  {
  switch (_TrdInfo.ModeBtnRight)
    {
    case 1: [self SetEditMode ]; break;
    case 2: [self FilterOras  ]; break;
    case 3: [self UnFilterOras]; [self FindOnSenteces]; break;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Entra en el modo de edicción de las oraciones
- (void) SetEditMode
  {
  _TrdEdit.TextSrc = _PanelSrc.Text;                                      // Copia texto fuente a la vista de edicción
  _TrdEdit.TextTrd = _PanelTrd.Text;                                      // Copia texto traducido a la vista de edicción
  
  _TrdEdit.hidden = FALSE;                                                // Muestra la vista de edicción
  
  [self CalculateEditMaxHeigth];                                          // Recalcula tamaño maximo de los editores
  
  [_FrameView setNeedsLayout];                                            // Reorganiza las vistas
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para filtar la lista de oraciones por el texto fuente
- (void) FilterOras
  {
    //OJO: aqui filtar la cadena de entrada
  Sentences* Ora = [[Sentences Actual] FilterByText:_PanelSrc.Text];      // Filtra las oraciones con el texto fuente
  _ListOras.Count = Ora.Count;                                            // Inicializa la lista que muestra las oraciones
  
  [_TrdInfo UpdateButtons];                                               // Manda a actualizar el boton derecho
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita el filtro de las oraciones filtradas
- (void) UnFilterOras
  {
  Sentences* Oras = [Sentences Actual];                                   // Obtiene el objeto con la lista de oraciones
  
  if( [Oras IsFiltered] )                                                 // Si la lista esta filtrada
    {
    Oras = [Oras RemoveFilter];                                           // Quita el filtro y retorna lista actualizada

    _ListOras.Count = Oras.Count;                                         // Inicializa la lista que muestra las oraciones
  
    [_TrdInfo UpdateButtons];                                             // Manda a actualizar el boton
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cierra el modo de edicción de la traducción
- (void) OnBtnCloseEditTrd
  {
  _PanelSrc.Text = _TrdEdit.TextSrc;
  _PanelTrd.Text = _TrdEdit.TextTrd;
  
  _TrdInfo.SaveHidden = _TrdEdit.SaveHidden;
  
  [self FindOnSenteces];                                               // Busca la oracion actual en la lista de oraciones
  
  _TrdEdit.hidden = TRUE;
  
  [self CalculateEditMaxHeigth];
  [_FrameView setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda la traducción que esta fue editada
- (void) OnBtnSaveEditTrd
  {
  _PanelSrc.Text = _TrdEdit.TextSrc;
  _PanelTrd.Text = _TrdEdit.TextTrd;
  
  [self OnBtnSaveTrd];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda el texto traducido en la lista de oraciones
- (void) OnBtnSaveTrd
  {
  NSString *srcText = _PanelSrc.Text;                                     // Toma el texto de origen
  NSString *trdText = _PanelTrd.Text;                                     // Toma el texto traducido
    
  Sentences* Oras = [Sentences Actual];                                   // Obtiene lista de oraciones
  int         idx = [Oras AddSrcText:srcText TrdText:trdText];            // Adiciona la fuente y la traducción a la lista
  
  if( idx!= -1 )                                                          // La adicionó
    {
    _ListOras.SelectedIndex = idx;                                        // Pone la fila como seleccionada
    
    if( !Oras.Found )                                                     // Si fue adicionada una oración nueva
      [_ListOras UpdateCount:Oras.Count];                                 // Actualiza la cantidad de oraciones de la lista
    else                                                                  // Se actualizo una oracion que ya existia
      [_ListOras Refresh];                                                // Fuerza a que se refresque el contenido de la lista
    
    [_ListOras SetAtTopRow: idx ];                                        // Pone la fila mas cercana en la parte de arriba de la lista
    }
    
  [self SaveLastTrd:trdText];                                             // Guarda la ultima tradución
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Mueve la palabra marcada, a la palabra anterior
- (void) OnBtnPrevWord
  {
  NSRange rg = [self PrevMarkedWord];
  [self SetMarkedText:rg];                                                  // Manda a mostra proxima selección
  
  [self ProcessMarkWord];                                                   // Procesa las palabra marcada
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Mueve la palabra marcada a la proxima palabra
- (void) OnBtnNextWord
  {
  NSRange rg = [self NextMarkedWord];
  [self SetMarkedText:rg];                                                  // Manda a mostra proxima selección
  
  [self ProcessMarkWord];                                                   // Procesa las palabra marcada
  }

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al borrar una traducción de una de las traduciones recientes
- (void)OnDelTranslateLng:(int) Idx
  {
  Sentences* Oras = [Sentences Actual];
  [Oras RemoveAt:Idx];
  
  [_ListOras UpdateCount:Oras.Count];                                     // Actualiza la lista de oraciones
    
  _ListOras.SelectedIndex = -1 ;                                          // Quita la seleccion
    
  [self CheckSaveBtn];                                                    // Muestra o no el boton de guardar la traducción
  }

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se selecciona una oración de la lista de oraciones
- (void)OnSelTranslateLng:(int) Idx;
  {
  Sentences* Oras = [Sentences Actual];                               // Toma la oración con indice 'Idx'
  
  NSString* srcText = [Oras GetSrcTextAt:Idx];                        // Toma el texto fuente
  NSString* trdText = [Oras GetTrdTextAt:Idx];                        // Toma el texto traducido
  
  [_ListOras SetAtTopRow: Idx ];                                      // Pone la oración de primera en la lista
  
  _PanelSrc.Text   = srcText;                                         // Pone el texto de origen en el panel
  [_PanelSrc ClearMarkText];                                          // Quita cualquier palabra que este seleccionada
  
  _PanelTrd.NoText = FALSE;                                           // Garanrtiza que se muestre el texto
  _PanelTrd.SelLng = Oras.LangDes;                                    // Pone el idioma de traducción actual
  _PanelTrd.Text   = trdText;                                         // Pone la tradución en el panel de texto traducido
  
  _PanelTrd.NoShow = FALSE;                                           // Hace que se muestre la vista
  
  [self SaveLastTrd: srcText];                                        // Guarda último texto traducido
  
  _TrdInfo.Mode = MODE_CMDS;                                          // Si esta mostrando opciones de traducción las quita
  
  if( !_TrdEdit.hidden )                                              // Si esta en el modo de modificación
    {
    _TrdEdit.TextSrc = srcText;                                       // Actualiza el texto fuente
    _TrdEdit.TextTrd = trdText;                                       // Actualiza el texto traducido
    
    [_TrdEdit UpdateData];                                            // Actualiza datos de modificación
    }
  else                                                                // Si no esta en el modo de modificación
    {
    NSRange chrs = [srcText rangeOfString:@"<"];                      // Busca si hay alguna palabra para sustituir
    if( chrs.length > 0 )                                             // Si la encontro
      [self SetEditMode ];                                            // Pone el modo de modificación
    }
    
  _ParamDes  = LGDes;                                                 // Guarda idioma destino
  
  _TrdInfo.SaveHidden = TRUE;                                         // Oculta boton de guardar en TrdInfo
  _TrdEdit.SaveHidden = TRUE;                                         // Oculta boton de guardar en la vista de modificación
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra la pantalla con le número dado
- (void) ShowScreenNum:(int) n
  {
  LGSrcOld = LGSrc;
  LGDesOld = LGDes;
  
  NSString* idSegue[] = { @"DictSegue", @"ConjSegue", @"NumsSegue", @"SettingSegue" };
  
  [self performSegueWithIdentifier: idSegue[n] sender: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama antes de pasar a la proxima pantalla
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  NSString* sID = segue.identifier;
  
  if( [sID isEqualToString:@"DictSegue"] )
    {
    DictController* DicCtrller = segue.destinationViewController;
    
    DicCtrller.Word   = _ParamWord;
    DicCtrller.lngSrc = _ParamSrc;
    DicCtrller.lngDes = _ParamDes;
    }
  else if( [sID isEqualToString:@"ConjSegue"] )
    {
    ConjController* ConjCtrller = segue.destinationViewController;
    
    ConjCtrller.Verb   = _ParamWord;
    ConjCtrller.lngSrc = _ParamSrc;
    ConjCtrller.lngDes = _ParamDes;
    }
  else if( [sID isEqualToString:@"NumsSegue"] )
    {
    NumsController* NumsCtrller = segue.destinationViewController;
    
    NumsCtrller.sNum = _ParamWord;
    }
  else if( [sID isEqualToString:@"SettingSegue"] )
    {
    }
    
  OutSelf = TRUE;
  }
  
//------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se retorna desde otra pantalla
- (IBAction)ReturnFromUnwind:(UIStoryboardSegue *)unWindSegue
  {
  OutSelf = FALSE;
  
  UIViewController* Ctrll = unWindSegue.sourceViewController;     // Obtiene el controlador desde donde se retorna

  if( [Ctrll isKindOfClass:[DictController class]] )              // Si viene desde la vista de diccionarios
    {
    DictController* DicCtrller = (DictController*)Ctrll;          // Obtiene controlador de diccionario
    
    _ParamSrc  = LGSrc;                                           // Pone parametros por defecto para cuando regrese
    _ParamDes  = LGDes;
    _ParamWord = DicCtrller.Word;
    }
  else if( [Ctrll isKindOfClass:[ConjController class]] )         // Si viene desde la vista de conjugación
    {
    ConjController* ConjCtrller = (ConjController*)Ctrll;         // Obtiene controlador de conjugación
    
    int         des = LGInferedDes(-1);                           // Infiere un idioma destino, para el conjugación actual
    NSString* sVerb = ConjCtrller.Verb;
    
    if( des >=0 && sVerb.length>0 )                               // Si es posible inferir el idioma destino y hay un verbo
      {
      _ParamSrc  = LGSrc;                                         // Pone los paramentos por defecto para llamar a las vista
      _ParamDes  = des;
      _ParamWord = sVerb;
      }
    }
    
  LGSrc = LGSrcOld;                                               // Restaura los idiomas antes de llamar la vista
  LGDes = LGDesOld;
  
  Ctrll = nil;                                                    // Hace nulo el controlador para que se libere
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Realiza la traducción del texto 'Text' de acuerdo a los idiomas de fuente y destido actuales
- (NSString*) TranslateText:(NSString*) Text
  {
  [ProxyTrd OpenSrc:LGSrc Des:LGDes];                       // Abre la direccion, si no esta abierta
  
  NSString* sTrd = [ProxyTrd TranslateText:Text Prog:nil];     // Traduce el texto
  
  [self SaveLastTrd: sTrd];                                           // Guarda último texto traducido
  return sTrd;
  }

//------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga o inicializa la lista de oraciones si es necesario
- (Sentences*) LoadSentences
  {
  if( ![Sentences IsActualLangSrc: LGSrc AndLangDes:LGDes] )
    {
    Sentences* Oras = [Sentences LoadWithLang1:LGSrc AndLang2:LGDes];
    _ListOras.Count = Oras.Count;                                          // Inicializa la lista que muestra las oraciones
    }

  return [Sentences Actual];
  }
      
//-------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la oracion actual en la lista de oraciones y posiciona la oración mas cercana de la lista en la parte superior
- (void) FindOnSenteces
  {
  [self.view layoutIfNeeded];
  
  Sentences* Oras = [self LoadSentences];                                 // Carga la lista de oraciones si es necesario
  
  //OJO: aqui filtar la cadena de entrada
  NSString *srcText = _PanelSrc.Text;                                     // Obtiene el texto de origen
  
  int idx = [Oras IndexForSrcText:srcText];                               // Lo busca en la lista de oraciones
  if( idx<0 ) idx = 0;                                                    // No pudo buscar, pone la primera oración
  if( idx>=Oras.Count ) --idx;                                            // Se pasa del final, toma como actua el ultimo
  
  if( Oras.Found )                                                        // Se encontro la oracion
    _ListOras.SelectedIndex = idx;                                        // Pone la fila como seleccionada
  else                                                                    // No se encontro la oración
    _ListOras.SelectedIndex = -1;                                         // Quita la seleccion
    
  [_ListOras SetAtTopRow: idx ];                                          // Pone la fila mas cercana en la parte de arriba de la lista
  [_ListOras layoutIfNeeded];                                             // Fuerza el layaut inmediatamente
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda la ultima traducción para saber cuando cambia
- (void) SaveLastTrd:(NSString*) sTrad
  {
  lastTrdText = sTrad;                                                    // Guarda ultimo texto traducido para saber si cambio
  
  _TrdInfo.SaveHidden = TRUE;                                             // Oculta el boton de guardar texto traducido
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene obtiene el rango marcado en el texto de trabajo
- (NSRange) GetMarkedRange
  {
  if( _OnTextTrd ) return [_PanelTrd GetMarkText];
  else             return [_PanelSrc GetMarkText];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el texto marcado en el texto de trabajo
- (void) SetMarkedText:(NSRange)rg
  {
  if( _OnTextTrd ) return [_PanelTrd SetMarkText:rg];
  else             return [_PanelSrc SetMarkText:rg];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el texto de trabajo actual
- (NSString*) GetActualText
  {
  if( _OnTextTrd ) return _PanelTrd.Text;
  else             return _PanelSrc.Text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita el texto que se encuentre marcado en ese momento
- (void) ClearMarkText
  {
  if( _OnTextTrd ) return [_PanelTrd ClearMarkText];
  else             return [_PanelSrc ClearMarkText];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la palabra la palabra marcada, se no hay niguna, obtine la proxima a útima marcada
- (NSString *) GetMarkedWord
  {
  NSRange rg = [self GetMarkedRange];                           // Obtiene el texto seleccionado
  if( rg.length == 0 )
    {
    rg = [self NextMarkedWord];
    
    [self SetMarkedText:rg];                                      // Manda a mostra proxima selección
    }
  
  NSString* Txt = [self GetActualText];                           // Obtiene el texto a traducir
  return [Txt substringWithRange:rg];                             // Obtene la palabra marcada
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Procesa la palabra marcada si esta la vista de conjugaciones o significados visibles
- (void) ProcessMarkWord
  {
  NSRange rg = [self GetMarkedRange];                           // Obtiene el texto maracado
  if( rg.length == 0 ) return;                                  // Si no hay texto marcado, no hece nada
  
  NSString* Txt = [self GetActualText];                         // Obtiene el texto origen
  NSString* Wrd = [Txt substringWithRange:rg];                  // Obtene la palabra marcada

  _ParamWord = Wrd;                                             // Pone parametros por defecto para otras vistas
  _ParamSrc  = (_OnTextTrd)? LGDes : LGSrc;
  _ParamDes  = (_OnTextTrd)? LGSrc : LGDes;
    
  if( _TrdInfo.Mode == MODE_CMDS ) return;                      // Si no hay donde mostrar, no hace nada
  
  [_TrdInfo FindWord:Wrd];                                      // Busca y la muestra la palabra en vista de infornación
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la palabra que sigue a la palabra marcada
- (NSRange) NextMarkedWord
  {
  NSString* Txt = [self GetActualText ];                        // Obtiene el texto a traducir
  NSRange    rg = [self GetMarkedRange];                        // Obtiene el texto seleccionado
  NSInteger len = Txt.length;                                   // Longitud del texto
  NSInteger   i = rg.location + rg.length;                      // Indice a la ultima letra de la selección
  NSInteger ini = -1;
  NSInteger num = 0;
  
  if( i>=len ) i = 0;                                           // Si esta al final, pone el indice al principio
  
  for( ;i<len; ++i)                                             // Corre el inidice hacia adelante
    {
    if( (i==0 || !IsLetter(i-1, Txt) ) && IsLetter(i, Txt) )    // Si el caracter actual es una letra precedido de un caracter no letra
      {
      ini = i;                                                  // Toma el inicio de la proxima selección
      break;                                                    // Termina el avance
      }
    }
    
  for( ;i<len && IsLetter(i, Txt); ++i) ++num;                  // Cuenta las letras que sigue al caracter inicial

  if( ini<0 ) ini=0 ;                                           // Si no se encontro el inicio, lo pone a 0
  
  return NSMakeRange( ini, num);                                // Crea el rango de la selección nueva
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la palabra que que antecede a la palabra marcada
- (NSRange) PrevMarkedWord
  {
  NSString* Txt = [self GetActualText];                         // Obtiene el texto a traducir
  NSRange    rg = [self GetMarkedRange];                        // Obtiene el texto seleccionado
  NSInteger len = Txt.length;                                   // Longitud del texto
  NSInteger   i = rg.location-1;                                // Indice a la primera letra de la selección
  NSInteger fin = -1;                                           // Fin de la selección
  NSInteger num = 0;                                            // Número de caracteres de la selección
  
  if( i<=0 ) i = len-1;                                         // Si esta al principio, pone el indice al final
  
  for( ;i>0; --i)                                               // Corre el inidice al caracter, hacia atras
    {
    if( (i==len-1 || !IsLetter(i+1, Txt) ) && IsLetter(i, Txt) )    // Si el caracter actual es una letra seguido de un caracter no letra
      {
      fin = i;                                                  // Toma el fin de la proxima selección
      break;                                                    // Termina el avance
      }
    }
    
  for( ;i>=0 && IsLetter(i, Txt); --i) ++num;                   // Cuenta las letras que preceden al caracter final

  if( fin<0 ) fin = 0;                                          // Si no se encontro el final lo pone a 0
  
  return NSMakeRange( fin-num+1, num);                          // Crea el rango de la selección nueva y lo retorna
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)supportedInterfaceOrientations
  {
  if( _LaunchImage.hidden )
    return UIInterfaceOrientationMaskAll;
  else
    {
    return UIInterfaceOrientationMaskPortrait;
    }
  }

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
  {
  }

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
  {
  [self CalculateEditMaxHeigth];
  }

//------------------------------------------------------------------------------------------------------
// Evento que se produce cuando se va ha mostrar el teclado
- (void)keyboardWillShow:(NSNotification *)notification 
  {
  if( OutSelf ) return;

  NSDictionary *userInfo = [notification userInfo];
  
  NSValue *KbSz = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGRect rcKb = [self.view convertRect:[KbSz CGRectValue] fromView:nil];
  
  KbHeight = rcKb.size.height;
  
  [self CalculateEditMaxHeigth];
  
  [_FrameView setNeedsLayout];
  }

//------------------------------------------------------------------------------------------------------
// Evento que se produce cuando se va a esaconder el teclado
- (void)keyboardWillHide:(NSNotification *)notification 
  {
  if( OutSelf ) return;
  
  KbHeight = 0;
  [self CalculateEditMaxHeigth];
  
  [_FrameView setNeedsLayout];
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end
//=========================================================================================================================================================
