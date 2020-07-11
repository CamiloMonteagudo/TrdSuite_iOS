//=========================================================================================================================================================
//  ShowInWebView.m
//  WebTest: Muestra una pagina Web en una pantalla, al cerrar la pantalla retorna a la vista actual
//
//  Created by Camilo on 18/12/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "ShowInWebView.h"
#import "AppData.h"
#import "ColAndFont.h"
#import "ModuleHdrView.h"

//=========================================================================================================================================================
@interface ShowInWebView()
  {
  ModuleHdrView* Header;
  UIWebView *WebPage;
  UIActivityIndicatorView* wait;
  }
@end


//=========================================================================================================================================================
@implementation ShowInWebView

+ (void)FromView:(UIView*)view AndUrl:(NSURL *) url
  {
  UIView* TopView = [self FindTopView:view];
  if( !TopView ) return;
  
  ShowInWebView* screen = [[ShowInWebView alloc] initWithFrame:TopView.bounds];
  
  screen.backgroundColor = ColMainBck;
  screen.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  [screen CreateWebPage];
  [screen CreateTitle];
  [screen CreateWaitCursor];
  
  [TopView addSubview:screen];
  
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes

  [screen->WebPage loadRequest:[NSURLRequest requestWithURL:url]];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Encuentra la vista definida como el tope superior, que se usa para definir el tamaño y posicion de la pantalla, todas las subviews quedan cubiertas
+ (UIView*) FindTopView:(UIView*) view
  {
  for( ; view!=nil; )                                                                     // Itera para encontrar la vista de mayor jerarquia
    {
    if( view.tag == 999 )
      return view;
      
    view = view.superview;
    }
    
  NSLog(@"No encontro la vista superior");
  return nil;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la vista para mostrar el titulo el cual aparece en la parte superior
- (void) CreateTitle
  {
  Header = [[ModuleHdrView alloc] initWithFrame: CGRectMake( 0, 0, 290, 20)];
  Header.Text = NSLocalizedString(@"TitleWeb", nil);
  Header.Height = 60;
  
  [Header OnCloseBtn:@selector(OnCloseMod:) Target:self];
  
  [self addSubview: Header];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la vista que muestra el listado de Items para comprar
- (void) CreateWebPage
  {
  CGRect frame = self.bounds;
  frame.origin.y     = 60;
  frame.size.height -= 60;
  
  WebPage = [[UIWebView alloc] initWithFrame: frame];
  WebPage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  [self addSubview: WebPage];
  
  WebPage.delegate = self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el cursor de espera y lo posiciona en el centro del control web
- (void) CreateWaitCursor
  {
  wait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  wait.center = WebPage.center;
  wait.color  = ColPanelBck;
  wait.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  
  [self addSubview: wait ];
  
  [wait startAnimating];
  
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton de cerrar la pantalla y regresar a la anterior
- (void)OnCloseMod:(id)sender
  {
  WebPage.delegate = nil;
  
  [self removeFromSuperview];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se cargo la página sin problemas
- (void)webViewDidFinishLoad:(UIWebView *)webView
  {
  [wait stopAnimating];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Hubo un error al cargar la página
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
  {
  NSLog(@"%@", error.description);
  
  [wait stopAnimating];
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString( @"Error", nil )
                                                  message: NSLocalizedString( @"NoInternet", nil )
                                                 delegate: self
 																			  cancelButtonTitle: NSLocalizedString( @"lbClose", nil )
 											                  otherButtonTitles: nil];
  [alert show];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cierra el mensaje de alerta
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  WebPage.delegate = nil;
  
  [self removeFromSuperview];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

