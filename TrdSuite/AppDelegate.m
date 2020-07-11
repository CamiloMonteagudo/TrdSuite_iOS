//=========================================================================================================================================================
//  AppDelegate.m
//  TrdSuite
//
//  Created by Camilo on 15/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "AppDelegate.h"
#import "AppData.h"
#import "ColAndFont.h"
#import "PurchasesView.h"
#import "Sentences.h"


//=========================================================================================================================================================
@implementation AppDelegate

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando la aplicación termina de cargarse y comienza a ejecutarse
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
  {
  UIDevice* Device = [UIDevice currentDevice];
  
  iUser = [NSLocalizedString(@"UserLang", nil) intValue];                                     // Idioma para la interfaz de usuario
  iPad  = (Device.userInterfaceIdiom == UIUserInterfaceIdiomPad);                             // Si el dispositivo es un iPad
  iOS   = (int)[[[Device systemVersion] componentsSeparatedByString:@"."][0] integerValue];   // Versión del sistema operativo
  
  NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
  
  for( int i=0; i<N_PURCH; ++i)                                       // Recorre todas las compras posibles
    {
    NSString* key = [NSString stringWithFormat:@"Purchase%d", i];     // Crea la llave con la que guarda
    if( [def boolForKey:key] )                                        // Si para esa llave fue hecha la compra
      [Purchases SetPurchasedItem:i ];                                // Pone el producto como comprado
    }
  
  int szFont = (int)[def integerForKey:@"FontSize"];                  // Obtiene el tamamaño de la letras
  if( szFont == 0 )                                                   // Si no se ha establecido ninguno
    {
    if( iPad )                                                        // Si estamo en un iPad toma 20 por defecto
      SetFontSize(20);
    else                                                              // Si estamos en iPhone toma 15 por defecto
      SetFontSize(15);
    }
  else                                                                // Si ya se establecio uno anteriormente
    SetFontSize(szFont);                                              // Se toma el valor establecido

  [Purchases Initialize];
  
  return YES;
  }
							
//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
  {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
  {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
  {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
  {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
  {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

@end
//=========================================================================================================================================================

