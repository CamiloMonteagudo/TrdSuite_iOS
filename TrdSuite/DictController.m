//=========================================================================================================================================================
//  DictController.m
//  TrdSuite
//
//  Created by Camilo on 03/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "DictController.h"
#import "VirtualDictRowView.h"
#import "ProxyDict.h"
#import "AppData.h"
#import "LangsBar.h"
#import "TopLeading.h"
#import "WaitView.h"
#import "ModuleLabelView.h"
#import "ColAndFont.h"
#import "ProxyConj.h"

//=========================================================================================================================================================
@interface DictController ()
  {
  int oldSrc;
  int oldDes;
  
  NSArray* Roots;
  BOOL FindRoot;
  int  NextRoot;
  }

@property (weak, nonatomic) IBOutlet LangsPanelView *PanelSrc;
@property (weak, nonatomic) IBOutlet UIButton *BtnFindRoots;
@property (weak, nonatomic) IBOutlet UIButton *BtnNextRoot;

@property (weak, nonatomic) IBOutlet VirtualListView *LstWords;
@property (weak, nonatomic) IBOutlet LangsBar *LGBar;
@property (weak, nonatomic) IBOutlet TopLeading *Leading;
@property (weak, nonatomic) IBOutlet ModuleLabelView *ModuleTitle;

- (IBAction)OnClose:(id)sender;
- (IBAction)OnFindRoots:(id)sender;
- (IBAction)OnNextRoot:(id)sender;

@end

//=========================================================================================================================================================
@implementation DictController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  oldSrc = -1;                                                // Inicializa dirección actual como indefinida
  oldDes = -1;
  
  [super viewDidLoad];

  self.view.backgroundColor = ColMainBck;                     // Pone el color de fondo de la vista 
  
  _PanelSrc.Delegate    = self;
  _PanelSrc.HideTitle   = TRUE;
  _PanelSrc.PlaceHolderKey = @"DictTip";
  _PanelSrc.ReturnType  = UIReturnKeyDone;
  _PanelSrc.SelLng      = _lngSrc;                            // Fuerza a que se inicialice con el idioma de origen
  
  _LstWords.MinHeight = 45;
  _LstWords.VirtualListDelegate = self;
  
  [_LGBar OnSelLang:@selector(OnSelTrdLang:) Target:self];    // Pone callback para cuando se seleccione un idioma
  [_LGBar OnSelItem:@selector(OnSelFilter:) Target:self];     // Pone callback para cuando se seleccione un idioma
  
  _LGBar.SelLng = _lngDes;
  [_LGBar RefreshLangsButtons];                               // Manada a refrescar los idiomas destinos disponibles
  
//  [self ShowData: (_Word.length>0) ];
  
  _PanelSrc.Text = _Word;
  
  [self SetActualDir];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando la vista esta a punto de mostrarse
- (void)viewWillAppear:(BOOL)animated
  {
  NSString* Title = NSLocalizedString(@"ModDitionary", nil);
  
  [_ModuleTitle ShowLabel:Title InFrame:self.view.bounds ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama antes de pasar a la proxima pantalla
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  _Word = _PanelSrc.Text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reorganiza todas las subvistas que estan dentro de la vista del viewcontroller
- (void)viewDidLayoutSubviews
  {
  float w = self.view.bounds.size.width;
  float y = _PanelSrc.frame.origin.y + _PanelSrc.frame.size.height + 5;
  
  _LGBar.frame = CGRectMake( 0, y, w, 50);
  
  y += (50 - 22);
  _Leading.frame = CGRectMake( 0, y, w, 30);
    
  y += 30;
  float h = self.view.frame.size.height - y;
  
  _LstWords.frame = CGRectMake( 5, y, w-10, h);
  }

//+++++++++++++++++++++++++++++++++++++++++++ Implementa LangsPanelDelegate ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia el idioma del texto de origen
- (void) OnSelLang:(LangsPanelView *)Panel;
  {
  if( oldSrc==Panel.SelLng ) return;                      // Si ya es el idioma fuente seleccionado, no hace nada
  
  _LGBar.SelLng = LGInferedDes(oldSrc);                // Indefine el idioma destino de forma que siempre sea valido
    
//  bool shw = ( Panel.Text.length>0 );
  
//  if( shw != Show )
//    [self ShowData:shw ];
    
  [_LGBar RefreshLangsButtons];                           // Manada a refrescar los idiomas destinos disponibles
  
  [self SetActualDir];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto de origen
- (void) OnChanged:(LangsPanelView *)Panel Text:(UITextView *)textView;
  {
  [self FindInDictWord];
  [self ClearRoots];
  
//  bool shw = (textView.text.length>0);
//  
//  if( shw != Show )
//    [self ShowData:  shw];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cuando ese toca el boton de aceptar en el teclado
- (void)OnKeyBoardReturn
  {
  HideKeyBoard();
  }

//+++++++++++++++++++++++++++++++++++++++++++ Fin LangsPanelDelegate +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++ Implementa VirtualListDelegate ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para obtener la vista que representa cada fila
-(VirtualRowView *)GetRowViewAt:(int)iRow
  {
  float W  = _LstWords.frame.size.width;
  BOOL sel = (_LstWords.SelectedIndex == iRow);

  return [VirtualDictRowView RowWithIndex:iRow Width:W Select:sel];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cunado el usuario toca en una fila
- (void)OnSelectedRow:(int)iRow
  {
  HideKeyBoard();
  
  NSString* sWord = [ProxyDict getWordAt:iRow];
  _PanelSrc.Text = sWord;

  [self ClearRoots];
  }

//+++++++++++++++++++++++++++++++++++++++++++ Fin VirtualListDelegate +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone la dirección actual
- (void)SetActualDir
  {
  _BtnFindRoots.hidden = TRUE;
  _BtnNextRoot.hidden   = TRUE;
  FindRoot = FALSE;
  
  if( LGSrc!=oldSrc || LGDes!=oldDes )                                  // Si cambia idioma con respecto al actual
    {
    oldSrc = LGSrc;                                                     // Guarda el idioma actual
    oldDes = LGDes;
    
//    WaitView* Wait = [[WaitView alloc] initInView:MainCtrll.view];
  
    if( [ProxyDict OpenDictSrc:LGSrc Dest:LGDes] )                      // Abre el diccionario
      _LstWords.Count = [ProxyDict getSize];                            // Si se abrio, obtiene tamaño y de lo pone a la lista
    else
      _LstWords.Count = 0;                              // Refresca diccionario para el idioma seleccionado
    
//    [Wait removeFromSuperview];
    }
    
  [self UpdateFilterButton];
  [self FindInDictWord];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la palabra actual en el diccionario
- (void) FindInDictWord
  {
  if( ![ProxyDict OpenDictSrc:LGSrc Dest:LGDes] ) return;              // Si no puede abrir el diccionario no hace nada
  
  NSString *word = _PanelSrc.Text;
  
  int idx = 0;                                                          // Toma por defecto la primera palabra
  int len = (int)[word length];                                         // Obtiene tamaño de la palabra a buscar
  if( len > 0 )                                                         // Si la palabra no esta vacia
    idx = [ProxyDict getWordIdx:word];                                  // Obtiene el indice de la palabra en el diccionario

  [_LstWords SetAtTopRow:idx];                                          // Pone la palabra (o mas cercana) en la parte de arriba de la lista
 
  if( [ProxyDict Found] && len>0 )                                      // Si la palabra fue encontrada
    {
    _LstWords.SelectedIndex = idx;                                      // Selecciona la palabra en la lista
    
    [self SetRootOf:nil];                                              // Quita la ultima raiz encontrada
    }
  else
    {
    [self SetRootOf:word];                                             // Trata de ver si la palabra tiene raices
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama por la barra de botones, cuando se selecciona un idioma mediante los botones de las banderas
- (void)OnSelTrdLang:(LangsBar*) view
  {
  HideKeyBoard();                                       // Oculta el teclado
  
  [self SetActualDir];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama por la barra de botones, cuando se selecciona el item de filtrar
- (void)OnSelFilter:(LangsBar*) view
  {
  HideKeyBoard();                                                       // Oculta el teclado
  
  WaitView* Wait = [[WaitView alloc] initInView:self.view];
  
  NSString *sFilter = _PanelSrc.Text;
  
  [ProxyDict KeysFilter:sFilter];
    
  _LstWords.Count = [ProxyDict getSize];                                // Refresca diccionario para el idioma seleccionado
    
  [Wait removeFromSuperview];

  [self UpdateFilterButton];
  [self FindInDictWord];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza el boon de filtrado, de acuerdo al estado en el momento que se llama
- (void)UpdateFilterButton
  {
  [_LGBar ClearAllItems];                                         // Quita todos los botones adicionales de la barra
  
  if( LGDes<0 ) return;                                           // Si no hay idioma destino no pone nada
  
  if( [ProxyDict IsFiltered] )                                    // Los datos del diccionario ya estaban filtrados
    [_LGBar AddItemId:@"FilterOff"];                              // Pone boton para quitar el filtro
  else                                                            // Si no
    [_LGBar AddItemId:@"FilterOn"];                               // Pone botón para filtrar
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Trata de ver si la palabra tiene raices
- (void) SetRootOf:word
  {
  if( !_BtnNextRoot.hidden ) return;                               // Esta buscando la proxima raiz, no hace nada
  
  BOOL Root = FALSE;                                              // Por defecto, no hay raices
  
  if( word != nil )                                               // Si hay una palabra
    Root = ([ProxyConj FindRootWord:word Lang:LGSrc] != nil);     // Busca una raiza de la palabra
    
  if( Root == FindRoot ) return;                                  // Si estaba en el mismo estado, no hace nada
    
  _BtnFindRoots.hidden = !Root;                                   // Oculta/Muestra el boton para buscar raices
    
  FindRoot = Root;                                                // Guarda ultimo estado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita las raices, que hay en ese momento
- (void) ClearRoots
  {
  if( !_BtnNextRoot.hidden )
    {
    _BtnNextRoot.hidden = TRUE;
    Roots = nil;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton de cerrar la pantalla y regresar a la anterior
- (IBAction)OnClose:(id)sender
  {
  [self performSegueWithIdentifier: @"Back" sender: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al tocar el boton de buscar raices a la palabra
- (IBAction)OnFindRoots:(id)sender
  {
  FindRoot = FALSE;
  _BtnFindRoots.hidden = TRUE;
  
  NSString* word = _PanelSrc.Text;
  Roots = [ProxyConj GetRootListForWord:word Lang:LGSrc];
  
  int nRoots = (int)Roots.count;
  if( nRoots == 0 ) return;
  
  _PanelSrc.Text = Roots[0];
  [self FindInDictWord];
  
  if( nRoots == 1 )
    {
    Roots = nil;
    return;
    }
    
  _BtnNextRoot.hidden = FALSE;
  NextRoot = 1;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al tocar el boton para pasar a la proxima raiz
- (IBAction)OnNextRoot:(id)sender
  {
  _PanelSrc.Text = Roots[NextRoot];
  [self FindInDictWord];
  
  ++NextRoot;
  if( NextRoot >= Roots.count )
    {
    Roots = nil;
    _BtnNextRoot.hidden = TRUE;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama por la barra de botones, cuando se selecciona un idioma mediante los botones de las banderas
//- (void)ShowData:(bool) shw
//  {
//  _LGBar.hidden = !shw;
//  _Leading.hidden = !shw;
//  _LstWords.hidden = !shw;
//  
//  Show = shw;
//  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
  {
  scrnWidth  = self.view.bounds.size.width;
  
  _ModuleTitle.hidden = TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotate
  {
  return TRUE;
  }

@end
//=========================================================================================================================================================
