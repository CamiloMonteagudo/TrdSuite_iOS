//=========================================================================================================================================================
//  SettingController.m
//  TrdSuite
//
//  Created by Camilo on 01/10/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "SettingController.h"
#import "AppData.h"
#import "PurchasesView.h"
#import "ColAndFont.h"
#import "ModuleHdrView.h"

//=========================================================================================================================================================
@interface SettingController ()
  {
  NSString* sSlider;
  
  float LstVal;
  }

  @property (weak, nonatomic) IBOutlet ModuleHdrView *ModuleLabel;
  @property (weak, nonatomic) IBOutlet UISlider *Slider;
  @property (weak, nonatomic) IBOutlet UILabel *lbSlider;
  @property (weak, nonatomic) IBOutlet UILabel *lbLangs;
  @property (weak, nonatomic) IBOutlet PurchasesView *ListItems;

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
  
  if( iPad )
    {
    _Slider.minimumValue = 15;
    _Slider.maximumValue = 30;
    }
  else
    {
    _Slider.minimumValue = 12;
    _Slider.maximumValue = 20;
    }
  
  _Slider.value = FontSize;
  
  [self SetSliderLabel];
  
  _ModuleLabel.Text = NSLocalizedString(@"MnuSetting", nil);
  [_ModuleLabel OnCloseBtn:@selector(OnBtnClose:) Target:self];
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
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reorganiza todas las subvistas que estan dentro de la vista del viewcontroller
- (void)viewDidLayoutSubviews
  {
  CGSize sz = self.view.bounds.size;
  float   y = _ModuleLabel.Height;
  float   w = sz.width - (2*SEP_BRD);
  
  float hLb1 = 1.4 * FontSize;
  _lbSlider.frame = CGRectMake(SEP_BRD, y, w, hLb1);
  y += hLb1 + SEP_BRD + SEP_BRD;
  
  float hSld = _lbSlider.frame.size.height;
  _Slider.frame = CGRectMake(SEP_BRD, y, w-BTN_W, hSld);
  y += hSld + SEP_BRD;
  
  float hLb2 =  1.4 * FontSize;;
  _lbLangs.frame = CGRectMake(SEP_BRD, y, w, hLb2);
  y += hLb2;
  
  float hRes = sz.height - y - SEP_BRD;
  float hMin = [PurchasesView MinHeight];
  
  float hLst = (hRes > hMin)? hMin : hRes;
  _ListItems.frame =  CGRectMake(SEP_BRD, y, w, hLst);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton para cerrar la vista
- (void)OnBtnClose:(id)sender
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
   
   [_ModuleLabel Refresh];
   
  _lbSlider.font = fontEdit;
  _lbLangs.font = fontEdit;
  
  [_ListItems RefreshItems];
  
  [self.view setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end
