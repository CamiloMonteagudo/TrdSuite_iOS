//=========================================================================================================================================================
//  SettingController.m
//  TrdSuite
//
//  Created by Camilo on 01/10/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "SettingController.h"
#import "ModuleLabelView.h"
#import "AppData.h"
#import "PurchasesView.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
@interface SettingController ()
  {
  NSString* sSlider;
  
  float LstVal;
  }

  @property (weak, nonatomic) IBOutlet UIButton *btnClose;
  @property (weak, nonatomic) IBOutlet PurchasesView *ListItems;
  @property (weak, nonatomic) IBOutlet ModuleLabelView *ModuleTitle;
  @property (weak, nonatomic) IBOutlet UISlider *Slider;
  @property (weak, nonatomic) IBOutlet UILabel *lbSlider;
  @property (weak, nonatomic) IBOutlet UILabel *lbLangs;

- (IBAction)OnBtnClose:(id)sender;
- (IBAction)OnChangeFonSize:(UISlider *)sender;

@end

//=========================================================================================================================================================
@implementation SettingController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  self.view.backgroundColor  = ColMainBck;
  
  sSlider       = NSLocalizedString( @"lbFontSize", nil );
  _lbLangs.text = NSLocalizedString( @"lbLangs"   , nil );
  
  if( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
    _Slider.maximumValue = 25;
  else
    _Slider.maximumValue = 20;
  
  _Slider.value = FontSize;
  
  [self SetSliderLabel];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidAppear:(BOOL)animated
  {
  NSString* Title = NSLocalizedString(@"ModSetting", nil);
  
  [_ModuleTitle ShowLabel:Title InFrame:self.view.bounds ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el valor actual del font en el label del slider
-(void) SetSliderLabel
  {
  float val = _Slider.value;
  if( LstVal == val ) return;
  
  LstVal = val;
  
  [self ChangeViewFontSize];
  
  _lbSlider.text = [NSString stringWithFormat:@"%@%2.1f", sSlider, val];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se gira la pantalla
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
  {
  scrnWidth  = self.view.bounds.size.width;
  
  _ModuleTitle.hidden = TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reorganiza todas las subvistas que estan dentro de la vista del viewcontroller
- (void)viewDidLayoutSubviews
  {
  CGSize sz = self.view.bounds.size;
  CGRect rc = _ListItems.frame;
  
  float    h = sz.height - rc.origin.y - SEP_BRD;
  float hMin = [PurchasesView MinHeight];
  
  if( h > hMin  )
    rc.size.height = hMin;
  else
    rc.size.height = h;
    
  _ListItems.frame = rc;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton para cerrar la vista
- (IBAction)OnBtnClose:(id)sender
  {
  [self performSegueWithIdentifier: @"Back" sender: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se desliza el slider para cambiar el tamaño de las letras
- (IBAction)OnChangeFonSize:(UISlider *)sender
  {
  sender.value = roundf(sender.value);
  
  [self SetSliderLabel];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el tamaña de las fuentes de la vista
-(void) ChangeViewFontSize
  {
  SetFontSize( LstVal );
   
  _lbSlider.font = fontEdit;
  _lbLangs.font = fontEdit;
  
  [_ListItems RefreshItems];
  [_ModuleTitle RefreshLabel];
  
  [self.view setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end
