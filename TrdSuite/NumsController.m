//
//  NumsController.m
//  TrdSuite
//
//  Created by Camilo on 03/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "NumsController.h"
#import "LangsPanelView.h"
#import "AppData.h"
#import "ModuleLabelView.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
@interface NumsController ()

  @property (weak, nonatomic) IBOutlet LangsPanelView *PanelSrc;
  @property (weak, nonatomic) IBOutlet ModuleLabelView *ModuleTitle;

@end

//=========================================================================================================================================================
@implementation NumsController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];

  self.view.backgroundColor = ColMainBck;                     // Pone el color de fondo de la vista
  
   _PanelSrc.Back = TRUE;
  
  _PanelSrc.Delegate = self;
  _PanelSrc.Text = self.sNum;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
  {
  NSString* Title = NSLocalizedString(@"ModNumbers", nil);
  
  [_ModuleTitle ShowLabel:Title InFrame:self.view.bounds ];
  }

//+++++++++++++++++++++++++++++++++++++++++++ Implementa LangsPanelDelegate ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia el idioma del texto de origen
- (void) OnSelLang:(LangsPanelView *)Panel;
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto de origen
- (void) OnChanged:(LangsPanelView *)Panel Text:(UITextView *)textView;
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)OnBack:(LangsPanelView *)Panel
  {
  [self performSegueWithIdentifier: @"Back" sender: self];
  }

//+++++++++++++++++++++++++++++++++++++++++++ Fin LangsPanelDelegate +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
  {
  scrnWidth  = self.view.bounds.size.width;
  
  _ModuleTitle.hidden = TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================
