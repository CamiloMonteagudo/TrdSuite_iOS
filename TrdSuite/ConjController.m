//=========================================================================================================================================================
//  ConjController.m
//  TrdSuite
//
//  Created by Camilo on 03/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "ConjController.h"
#import "AppData.h"
#import "LangsPanelView.h"
#import "ProxyConj.h"
#import "ConjDataView.h"
#import "TopLeading.h"
#import "ColAndFont.h"
#import "ConjHeaderView.h"
#import "ModuleHdrView.h"

//=========================================================================================================================================================
@interface ConjController ()
  {
  BOOL IsVerb;
  }

  @property (weak, nonatomic) IBOutlet LangsPanelView *PanelSrc;
  @property (weak, nonatomic) IBOutlet ConjHeaderView *HdrConjs;
  @property (weak, nonatomic) IBOutlet ConjDataView   *LstConjs;
  @property (weak, nonatomic) IBOutlet ModuleHdrView *ModuleLabel;

  @property (weak, nonatomic) IBOutlet UIButton *btnConj;

- (IBAction)OnConjugate:(id)sender;

@end

//=========================================================================================================================================================
@implementation ConjController
//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];

  self.view.backgroundColor = ColMainBck;                 // Pone el color de fondo de la vista

  _HdrConjs.Ctrller = self;                               // Pone esta clase como controlador de la vista de encabezamiento
  
  _PanelSrc.Delegate       = self;                        // Pone delegado para atender los eventos
//  _PanelSrc.BoxMaxWidth    = 350;                         // Limita el tamaño del recuadro con el texto
  _PanelSrc.NoSaveText     = TRUE;                        // No guarda el ultimo texto escrito para el idioma seleccionado
  _PanelSrc.HideTitle      = TRUE;                        // Por defecto aculta el nombre del idioma seleccionado
  _PanelSrc.PlaceHolderKey = @"ConjTip";                  // Clave para los tectos en el place holder
  _PanelSrc.ReturnType     = UIReturnKeySearch;           // Pone el botón de buscar el teclado
  _PanelSrc.SelLng         = _lngSrc;                     // Fuerza a que se inicialice con el idioma de origen
 
  LGDes = _lngDes;
  [ProxyConj LoadConjLang:_PanelSrc.SelLng];              // Carga la conjugacion para el idiom actual
 
  if( [ProxyConj IsVerbWord:_Verb InLang:_lngSrc] )       // Si el parameto recibido es un verbo
    {
    _PanelSrc.Text = _Verb;                               // Lo pone en el editor
    
    IsVerb = [ProxyConj IsVerbWord:_Verb InLang:_lngSrc]; // Determina si el texto es un verbo o alguna conjugación
    [self Conjugate];                                     // Lo manda a conjugar
    }
  else
    {
    [self ClearConjData];
    }
  
  _ModuleLabel.Text = NSLocalizedString(@"ModConjugation", nil);
  
  [_ModuleLabel OnCloseBtn:@selector(OnBtnBack:) Target:self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama antes de pasar a la proxima pantalla
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  _Verb = _PanelSrc.Text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reorganiza todas las subvistas que estan dentro de la vista del viewcontroller
- (void)viewDidLayoutSubviews
  {
  float w = self.view.bounds.size.width;
  float y = _ModuleLabel.Height;
  
  float hSrc = _PanelSrc.frame.size.height;
  
  _PanelSrc.frame = CGRectMake(0, y, w-50, hSrc);
  
  float xc = w-25;
  float yc = y + BTN_H + LineHeight/2 + 10;

  _btnConj.center  = CGPointMake(xc, yc);

  y += hSrc;
  
  float h = _HdrConjs.frame.size.height;
  
  _HdrConjs.frame = CGRectMake(0, y, w, h);
  
  y += (h-BRD_W);
  h  = self.view.bounds.size.height - y;
  
  _LstConjs.frame = CGRectMake(SEP_BRD, y, w-(2*SEP_BRD), h);
  }

//+++++++++++++++++++++++++++++++++++++++++++ Implementa LangsPanelDelegate ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia el idioma del texto de origen
- (void) OnSelLang:(LangsPanelView *)Panel;
  {
  [ProxyConj LoadConjLang:_PanelSrc.SelLng];          // Carga la conjugacion para el idiom actual
  
  LGDes = LGInferedDes(-1);
  
  [self ConjugateIfVerb];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto de origen
- (void) OnChanged:(LangsPanelView *)Panel Text:(UITextView *)textView;
  {
  [self ConjugateIfVerb];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cuando ese toca el boton de budcar en el teclado
- (void)OnKeyBoardReturn
  {
  [self Conjugate];
  HideKeyBoard();
  }

//+++++++++++++++++++++++++++++++++++++++++++ Fin LangsPanelDelegate +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el boton de conjugación
- (IBAction)OnConjugate:(id)sender
  {
  HideKeyBoard();
  
  [self Conjugate];
  
  if( !_btnConj.hidden )
    [_HdrConjs ShowMessage:NSLocalizedString(@"NoConjWord", nil) Color:ColErrInfo];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia el modo como se muestran las conjugaciones
- (void)OnChangeMode
  {
  int viewMode = _HdrConjs.Mode;
  
  _LstConjs.ViewMode = viewMode;                          // Pone el modo nuevo

  if( viewMode == BY_WORDS )                              // Si el nuevo modo es por palabras
    {
    NSString* sVerb = _PanelSrc.Text;                     // Toma el texto que hay en el editor
    [_LstConjs SelectConj:sVerb  ];                       // Selecciona la conjugacion tecleada
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se oprime el botón de retroceder
- (void)OnBtnBack:(id)sender
  {
  [self performSegueWithIdentifier: @"Back" sender: self];  // Retorna a la vista anterior
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Conjuga la palabra actual
- (void) ConjugateIfVerb
  {
  NSString* sVerb = _PanelSrc.Text;                       // Toma el contenido del editor
  int         lng = _PanelSrc.SelLng;
  
  IsVerb = [ProxyConj IsVerbWord:sVerb InLang:lng];    // Determina si el texto es un verbo o alguna conjugación
  
  if( IsVerb ) [self Conjugate];
  else         [self ClearConjData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Conjuga la palabra actual
- (void)Conjugate
  {
  NSString* sVerb = _PanelSrc.Text;                         // Toma el texto que hay en el editor
  
  if( [ProxyConj ConjVerb:sVerb] )                          // Si se puedo obtener las conjugaciones
    [self ShowConjData:sVerb];
   else                                                     // No se puedo obtener las conjugaciones
    [self ClearConjData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra los datos de las conjugaciones
- (void) ShowConjData:(NSString*) sVerb
  {
  _LstConjs.contentOffset = CGPointMake(0, 0);            // Pone el escroll de los datos al inicio
    
  [_LstConjs UpdateConjugate   ];                         // Actualiza los datos de la conjución
  [_LstConjs SelectConj:sVerb  ];                         // Selecciona las conjugaciones tecleadas
    
  _btnConj.hidden = TRUE;
  [_HdrConjs ShowDataVerb:IsVerb];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita los datos de las conjugaciones
- (void) ClearConjData
  {
  [_HdrConjs ClearData];

  if( _PanelSrc.Text.length==0 )
    _btnConj.hidden = TRUE;
  else
    {
    _btnConj.hidden = FALSE;
    [_HdrConjs ShowMessage:NSLocalizedString(@"NoVerb", nil) Color:ColErrInfo];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
  {
  scrnWidth  = self.view.bounds.size.width;
  }

@end
//=========================================================================================================================================================
