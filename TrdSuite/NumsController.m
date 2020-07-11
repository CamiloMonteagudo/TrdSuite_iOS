//=========================================================================================================================================================
//  NumsController.m
//  TrdSuite
//
//  Created by Camilo on 03/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "NumsController.h"
#import "LangsPanelView.h"
#import "AppData.h"
#import "ColAndFont.h"
#import "LangsBar.h"
#import "NumGroupView.h"
#import "NumResultView.h"
#import "ReadNumber.h"
#import "ModuleHdrView.h"

//=========================================================================================================================================================
@interface NumsController ()
  {
  }

  @property (weak, nonatomic) IBOutlet ModuleHdrView *ModuleLabel;
  @property (weak, nonatomic) IBOutlet NumGroupView *GrpNum;
  @property (weak, nonatomic) IBOutlet UILabel *lbNum;
  @property (weak, nonatomic) IBOutlet LangsBar *LangBar;
  @property (weak, nonatomic) IBOutlet NumResultView *NumResult;

@end

//=========================================================================================================================================================
@implementation NumsController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];

  self.view.backgroundColor = ColMainBck;                     // Pone el color de fondo de la vista
  
  _lbNum.font      = fontPanelTitle;
  _lbNum.textColor = ColPanelTitle;
  _lbNum.text      = NSLocalizedString(@"NumLabel", nil);
  
  _LangBar.Trd = FALSE;                                    // Los idioma a mostrar en la barra son los de origen
  [_LangBar OnSelLang:@selector(OnSelLang:) Target:self];  // Pone callback para cuando se seleccione un idioma
  
  _GrpNum.Ctrller  = self;
  _GrpNum.NGroup   = GrpAll;
  
  _GrpNum.MaxChars = [ReadNumber MaxDigistInLang:LGSrc];
  
  _NumResult.NumEdit =_GrpNum;
  
  _ModuleLabel.Text = NSLocalizedString(@"MnuNums", nil);
  [_ModuleLabel OnCloseBtn:@selector(OnBtnClose:) Target:self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reorganiza todas las subvistas que estan dentro de la vista del viewcontroller
- (void)viewDidLayoutSubviews
  {
  /*
  _GrpNum;
  _lbNum;
  _LangBar;
  _NumResult;
  */
  float w = self.view.bounds.size.width;
  float y = _ModuleLabel.Height + SEP_BRD;
  
  float h = _GrpNum.frame.size.height;
  _GrpNum.frame = CGRectMake(0, y, w-BTN_W-SEP_BRD, h);
  
  y += h + SEP_BRD;  // Posición después del primer control
  
  float hLb = FontSize;
  float wLb = (int)(_lbNum.attributedText.size.width + 1);
  _lbNum.frame = CGRectMake(SEP_BRD, y, wLb, hLb);
  y += hLb;
    
  float hBar     = _LangBar.frame.size.height;
  _LangBar.frame = CGRectMake(0, y, w, hBar);
   y += hBar;
  
  float hResul = _NumResult.frame.size.height;
  _NumResult.frame = CGRectMake(0, y, w, hResul);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se gira la pantalla
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton para cerrar la vista
- (void)OnBtnClose:(id)sender
  {
  [self performSegueWithIdentifier: @"Back" sender: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama por la barra de botones, cuando se selecciona un idioma mediante los botones de las banderas
- (void)OnSelLang:(LangsBar*) view
  {
  HideKeyBoard();                                       // Oculta el teclado
  
  [_NumResult SetNumberReading];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que cambia el número que se esta analizando
- (void) OnChageNum
  {
  [_NumResult SetNumberReading];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  HideKeyBoard();
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================
