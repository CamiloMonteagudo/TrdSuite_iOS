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
#import "ShowInWebView.h"

//=========================================================================================================================================================
@interface SettingController ()
  {
  NSString* sSlider;
  
  float LstVal;
  }

  @property (weak, nonatomic) IBOutlet ModuleHdrView *ModuleLabel;
  @property (weak, nonatomic) IBOutlet UIScrollView *Scroll;

  @property (weak, nonatomic) IBOutlet UIView *frmSlider;
  @property (weak, nonatomic) IBOutlet UISlider *Slider;
  @property (weak, nonatomic) IBOutlet UILabel *lbSlider;

  @property (weak, nonatomic) IBOutlet UIView *frmLangs;
  @property (weak, nonatomic) IBOutlet UILabel *lbLangs;
  @property (weak, nonatomic) IBOutlet UIButton *btnLangs;
  
  @property (weak, nonatomic) IBOutlet UIView *frmHelp;
  @property (weak, nonatomic) IBOutlet UILabel *lbHelp;
  @property (weak, nonatomic) IBOutlet UIButton *btnHelp;

- (IBAction)OnChangeFonSize:(UISlider *)sender;
- (IBAction)OnLangs:(id)sender;
- (IBAction)OnHelp:(id)sender;

@end

//=========================================================================================================================================================
@implementation SettingController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  self.view.backgroundColor  = ColMainBck;
  
  [self SetFontSizeData];
  [self SetLangsInstData];
  [self SetHelpData];
  
  _ModuleLabel.Text = NSLocalizedString(@"MnuSetting", nil);
  [_ModuleLabel OnCloseBtn:@selector(OnBtnClose:) Target:self];
  
  _ModuleLabel.Height = STUS_H + BTN_H;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa adecuadamente el area de cambio de tamaño de letra
-(void) SetFontSizeData
  {
  if( iPad ) { _Slider.minimumValue = 15;             // Valores del slider para el iPad
               _Slider.maximumValue = 30; }
  
  else       { _Slider.minimumValue = 12;             // Valores del slider para el iPhone
               _Slider.maximumValue = 20; }
  
  _Slider.value = FontSize;                           // Ponel el tamaño actual de las letras
  
  sSlider = NSLocalizedString( @"lbFontSize", nil );  // Texto para poner en el label del slider
  
  [self SetSliderLabel];                              // Pone el valor en el label del slider
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa adecuadamente el area de idiomas y compras
-(void) SetLangsInstData
  {
  _lbLangs.text = NSLocalizedString( @"lbLangs"   , nil );
  
  NSString* sLangs   = NSLocalizedString( @"LngsInts"   , nil );
  int       nLangs   = LGInstCount();
  NSString* bntTitle = [NSString stringWithFormat:@"%d %@",nLangs,sLangs];
  
  [_btnLangs setTitle:bntTitle forState: UIControlStateNormal];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa adecuadamente el area para la ayuda en línea
-(void) SetHelpData
  {
  _lbHelp.text = NSLocalizedString( @"lbHelp", nil );
  
  NSString* bntTitle = NSLocalizedString( @"SiteName", nil );
  
  [_btnHelp setTitle:bntTitle forState: UIControlStateNormal];
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
  
  float y = STUS_H + BTN_H;
  _Scroll.frame = CGRectMake(0, y, sz.width, sz.height-y-SEP_BRD );
  
  float  w1 = sz.width - (2*SEP_BRD);
  float  w2 = w1 - (2*SEP_BRD);
  
  float hLb = 1.4 * FontSize;
  _lbSlider.frame = CGRectMake(SEP_BRD, SEP_BRD, w2, hLb);
  _lbLangs.frame  = CGRectMake(SEP_BRD, SEP_BRD, w2, hLb);
  _lbHelp.frame   = CGRectMake(SEP_BRD, SEP_BRD, w2, hLb);
  
  float hBtn = 3 * FontSize;
  
  y = SEP_BRD + hLb;
  _Slider.frame   = CGRectMake(SEP_BRD, y, w2, hBtn);
  _btnLangs.frame = CGRectMake(SEP_BRD, y, w2, hBtn);
  _btnHelp.frame  = CGRectMake(SEP_BRD, y, w2, hBtn);

  float hFrm = hLb + hBtn + (2*SEP_BRD);
  
  y = SEP_BRD;
  _frmSlider.frame = CGRectMake(SEP_BRD, y, w1, hFrm);
  
  y += hFrm + SEP_BRD;
  _frmLangs.frame  = CGRectMake(SEP_BRD, y, w1, hFrm);
  
  y += hFrm + SEP_BRD;
  _frmHelp.frame   = CGRectMake(SEP_BRD, y, w1, hFrm);
  
  _Scroll.contentSize = CGSizeMake(sz.width, y + hFrm );
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
- (IBAction)OnLangs:(id)sender
  {
  PurchasesScreen* PutcView = [[PurchasesScreen alloc] initWithFromView:self.view ];
  PutcView = nil;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnHelp:(id)sender
  {
//  NSString* sUrl = NSLocalizedString( @"SiteURL_", nil );
//  
// 	NSString *path = [[NSBundle mainBundle] bundlePath];
//            path = [path stringByAppendingPathComponent: sUrl];
//  
//  
//  NSURL* url = [NSURL fileURLWithPath:path];
  
  NSString* sUrl = NSLocalizedString( @"SiteURL", nil );
  NSURL*     url = [NSURL URLWithString:sUrl];
 
  [ShowInWebView FromView:self.view AndUrl:url];
  } 

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el tamaña de las fuentes de la vista
-(void) ChangeViewFontSize
  {
  SetFontSize( LstVal );
   
   [_ModuleLabel Refresh];
   
  _lbSlider.font = fontEdit;
  _lbLangs.font = fontEdit;
  _lbHelp.font = fontEdit;
  
  _btnHelp.titleLabel.font = fontEdit;
  _btnLangs.titleLabel.font = fontEdit;
  
  [self.view setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end
