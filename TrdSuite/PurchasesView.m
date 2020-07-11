//=========================================================================================================================================================
//  PurchasesView.m
//  TrdSuite
//
//  Created by Camilo on 05/10/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "PurchasesView.h"
#import "AppData.h"
#import "ColAndFont.h"
#import "VirtualListView.h"
#import "ModuleHdrView.h"

//#define SIMULATE                          // Simula que se esta conectando a internet

//=========================================================================================================================================================
// Almacena los datos relacionado con un item
struct PurchItem
  {
  NSString *Precio;                           // Precio del item
  
  int lang1;                                  // Uno de los idiomas asociado al item
  int lang2;                                  // El otro idioma asociado al item
  
  NSString *strDir1;                          // Descripción de una de las direcciones asociadas con el item
  NSString *strDir2;                          // Descripción de la otra direccione asociadas con el item
  
  BOOL NoInst;                                // Si el producto no esta instalado, osea se puede comprar
  
  SKProduct* Prod;                            // Datos del producto desde AppStore
  BOOL       InProcess;                       // Indica que la compra del item esta en proceso
  };

//=========================================================================================================================================
// Definición de todos los items que se pueden comprar
static PurchItem Items[] =  { {@"", 1, 0, @"", @"", FALSE, nil, FALSE },        // EnEs
                              {@"", 1, 2, @"", @"", FALSE, nil, FALSE },        // EnIt
                              {@"", 1, 4, @"", @"", FALSE, nil, FALSE },        // EnFr
                              {@"", 0, 2, @"", @"", FALSE, nil, FALSE },        // EsIt
                              {@"", 0, 4, @"", @"", FALSE, nil, FALSE },        // EsFr
                              {@"", 2, 4, @"", @"", FALSE, nil, FALSE } };      // ItFr

static float MaxDirWidth;                     // Ancho maximo de la descrición de los items
static float PriceWidth;                      // Ancho para poner el precio
static int   Restore;                         // 1 Si perece la opcion de restaurar, 0 no aparece

static float  hRow;                           // Alto de las filas, con la informacion de un item
static float  wList;                          // Ancho de lista con los items
static float  hList;                          // Alto de las filas con los items

static UIImage* imgBuyItem = [UIImage imageNamed: @"BuyItem"];      // Icono que indica que el item se puede comprar
static UIImage* imgBuyOk   = [UIImage imageNamed: @"BuyOk"];        // Icono que indica que el item ya fue comprado

static Purchases*     _Purchases;                                   // Objeto para manejar las compras dentros de la aplicacion
static PurchasesView* ShowView;                                     // Vista donde se muestran los items
static BOOL           InProcessRest;                                // Indica que la restauración de las compras esta en proceso
static int            RequestStatus;                                // Estado de la solicitud de productos a AppStore

//---------------------------------------------------------------------------------------------------------------------------------------------
// Posibles valores para 'RequestStatus'
#define REQUEST_NOSTART    0                                         // La solicitud no ha comenzado
#define REQUEST_INPROCESS  1                                         // La solicitud no esta en proceso
#define REQUEST_ENDED      2                                         // La solicitud termino satisfactoriamente

//=========================================================================================================================================

#ifdef TrdSuiteEn
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteEn.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteEn.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteEn.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteEn.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteEn.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteEn.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EsIt,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEnEs
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteEnEs.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteEnEs.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteEnEs.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteEnEs.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteEnEs.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteEnEs.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnIt,ITEM_EnFr,ITEM_EsIt,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEnIt
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteEnIt.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteEnIt.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteEnIt.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteEnIt.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteEnIt.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteEnIt.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnFr,ITEM_EsIt,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEnFr
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteEnFr.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteEnFr.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteEnFr.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteEnFr.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteEnFr.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteEnFr.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EsIt,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEs
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteEs.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteEs.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteEs.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteEs.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteEs.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteEs.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnIt,ITEM_EnFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEsIt
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteEsIt.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteEsIt.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteEsIt.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteEsIt.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteEsIt.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteEsIt.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EnFr,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEsFr
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteEsFr.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteEsFr.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteEsFr.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteEsFr.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteEsFr.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteEsFr.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EnFr,ITEM_EsIt,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteIt
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteIt.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteIt.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteIt.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteIt.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteIt.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteIt.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnFr,ITEM_EsFr,nil];
#endif
#ifdef TrdSuiteItFr
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteItFr.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteItFr.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteItFr.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteItFr.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteItFr.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteItFr.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EnFr,ITEM_EsIt,ITEM_EsFr,nil];
#endif
#ifdef TrdSuiteFr
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteFr.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteFr.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteFr.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteFr.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteFr.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteFr.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EsIt,nil];
#endif
#ifdef TrdSuiteAll
#define ITEM_EnEs       @"com.BigXSoft.TrdSuiteAll.EnEs"
#define ITEM_EnIt       @"com.BigXSoft.TrdSuiteAll.EnIt"
#define ITEM_EnFr       @"com.BigXSoft.TrdSuiteAll.EnFr"
#define ITEM_EsIt       @"com.BigXSoft.TrdSuiteAll.EsIt"
#define ITEM_EsFr       @"com.BigXSoft.TrdSuiteAll.EsFr"
#define ITEM_ItFr       @"com.BigXSoft.TrdSuiteAll.ItFr"

NSSet* LstProds = [NSSet setWithObjects:nil];
#endif

//---------------------------------------------------------------------------------------------------------------------------------------------
#ifdef DEBUG
void DebugMsg(NSString* msg)
  {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Debug Info"
                                                  message: msg
                                                 delegate: nil
                                        cancelButtonTitle: @"Cerrar"
                                        otherButtonTitles: nil];
  [alert show];
//  NSLog(@"%@",msg);
  }
#endif
//---------------------------------------------------------------------------------------------------------------------------------------------


//=========================================================================================================================================================
@implementation Purchases

//---------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los item que se pueden comprar y la comonicación con AppStore
+(void) Initialize
  {
  _Purchases = [[Purchases alloc] init];
  
  [self SetViewParameters];
  
  [[SKPaymentQueue defaultQueue] addTransactionObserver:_Purchases];
  
  [Purchases RequestProdInfo];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Quita el objeto que espera por las compras
+(void) Remove
  {
  if( _Purchases != nil )
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:_Purchases];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Estable cual es la vista que esta mostrando los item que se pueden comprar
+(void)setView:(PurchasesView*) view
  {
  ShowView = view;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Solicita la información sobre los productos a AppStore
+(void) RequestProdInfo
  {
  if( RequestStatus != REQUEST_NOSTART ) return;
  
  #ifndef SIMULATE
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:LstProds ];
    [request setDelegate:_Purchases];
  
    [request start];
    #ifdef DEBUG
      NSString* Info = @"Solicitud Información de productos";
  
      for( NSString* ProdId in LstProds )
        {
        Info = [Info stringByAppendingString:@"\r\n"];
        Info = [Info stringByAppendingString:ProdId ];
        }
  
      DebugMsg( Info );
    #endif
  
  #else
    int tm = 3 + rand()%27;
    [NSTimer scheduledTimerWithTimeInterval:tm target:self selector:@selector(productsRequest_:) userInfo:nil repeats:NO];
  #endif
  
  RequestStatus = REQUEST_INPROCESS;
  
  if( ShowView) [ShowView RefreshItems];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Retorno desde AppStore de la información de los productos solicitados
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
  {
  #ifdef DEBUG
    NSString* Info = [NSString stringWithFormat:@"Respuesta a solicitud de productos\r\n%d productos validos %d productos invalidos", (int)response.products.count, (int)response.invalidProductIdentifiers.count];

    Info = [Info stringByAppendingString:@"\r\nValidos"];
    for( SKProduct* Prod in response.products )
      {
      Info = [Info stringByAppendingString:@"\r\n"];
      Info = [Info stringByAppendingString:Prod.productIdentifier];
      }
  
    Info = [Info stringByAppendingString:@"\r\nNO VALIDOS"];
    for( NSString* Prod in response.invalidProductIdentifiers )
      {
      Info = [Info stringByAppendingString:@"\r\n"];
      Info = [Info stringByAppendingString:Prod];
      }
  
    DebugMsg( Info );
  #endif
  
  for( SKProduct* Prod in response.products )
    {
    int index = [Purchases IndexOfProductId: Prod.productIdentifier];
    if( index<0 ) continue;
    
    [Purchases SetItem:index WithProd:Prod];
    }
  
  RequestStatus = REQUEST_ENDED;
  
  if( ShowView) [ShowView RefreshItems];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Llamada cuando se produce un error en la solicitud de información de los productos
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
  {
  #ifdef DEBUG
    NSString* Info = [NSString stringWithFormat:@"Fallo la solicitud de información\r\n%@", error.localizedDescription];
    DebugMsg( Info );
  #endif
  
  RequestStatus = REQUEST_NOSTART;
  [request cancel];
  
  if( ShowView) [ShowView RefreshItems];
  }

#ifdef SIMULATE
//---------------------------------------------------------------------------------------------------------------------------------------------
// Simula la función 'productsRequest' pero es llamada desde un timer
+ (void)productsRequest_: (NSTimer *) timer
  {
  for( NSString* ProdId in LstProds )
    {
    int index = [Purchases IndexOfProductId: ProdId];
    if( index<0 ) continue;
    
    [self SetItem:index WithProd:nil];
    }
  
  RequestStatus = REQUEST_ENDED;
  
  if( ShowView) [ShowView RefreshItems];
  }
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene con el identificador del producto el indice de Item en el arreglo
+(int) IndexOfProductId:(NSString*) ProdId
  {
  if( [ProdId isEqualToString: ITEM_EnEs] ) return 0;
  if( [ProdId isEqualToString: ITEM_EnIt] ) return 1;
  if( [ProdId isEqualToString: ITEM_EnFr] ) return 2;
  if( [ProdId isEqualToString: ITEM_EsIt] ) return 3;
  if( [ProdId isEqualToString: ITEM_EsFr] ) return 4;
  if( [ProdId isEqualToString: ITEM_ItFr] ) return 5;
  
  return -1;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el identificador del producto que tiene indice 'Idx'
+(NSString*) ProductIdOfIndex:(int) idx
  {
  static NSString* ListIds[] = { ITEM_EnEs, ITEM_EnIt, ITEM_EnFr, ITEM_EsIt, ITEM_EsFr, ITEM_ItFr};
  
  if( idx<0 || idx>=N_PURCH ) return @"";
  
  return ListIds[idx];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Asocia el Item con indice 'idx' con el producto 'prod'
+ (void) SetItem:(int) idx WithProd:(SKProduct*) prod
  {
  #ifndef SIMULATE
    if( prod == nil ) return;
  
    NSLocale* loc          = prod.priceLocale;
    NSDecimalNumber* price = prod.price;
  #else
    NSLocale* loc          = [NSLocale currentLocale];
    NSDecimalNumber* price = [NSDecimalNumber decimalNumberWithMantissa:299 exponent:-2 isNegative:NO];
  #endif
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [numberFormatter setLocale:loc];

  PurchItem &item = Items[idx];
  
  item.Precio = [numberFormatter stringFromNumber:price];
  item.Prod   = prod;

  #ifdef DEBUG
    NSString* Info = [NSString stringWithFormat:@"SetItem idx=%d Precio=%@ Title='%@' Desc='%@'", idx, item.Precio, prod.localizedTitle, prod.localizedDescription];
    DebugMsg( Info );
  #endif
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Esta función manda a restaurar todas las compras que se hicieron anteriormente
+ (void)RestorePurchases
  {
  InProcessRest = TRUE;
  if( ShowView) [ShowView RefreshItems];
  
  #ifndef SIMULATE
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
  #else
    int tm = 3 + rand()%27;
    [NSTimer scheduledTimerWithTimeInterval:tm target:self selector:@selector(EndRestore:) userInfo:nil repeats:NO];
  #endif
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se produce un error al tratar de restaurar las compras realizadas
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
  {
  InProcessRest = FALSE;
  if( ShowView) [ShowView RefreshItems];                                                // Refresca la lista de productos
  
  [Purchases AlertMsg: @"TransError"];
  }

#ifdef SIMULATE
//---------------------------------------------------------------------------------------------------------------------------------------------
// Emula la terminación del proceso de restauración, que en realidad se hace en paymentQueue
+ (void)EndRestore: (NSTimer *) timer
  {
  InProcessRest = FALSE;
  if( ShowView) [ShowView RefreshItems];
  }
#endif

//---------------------------------------------------------------------------------------------------------------------------------------------
// Desencadena el proceso de compra de un producto
+ (BOOL) PurchaseProdIndex:(int) idx
  {
  #ifdef SIMULATE
    NSString* ProdId = [self ProductIdOfIndex:idx];
    
    int tm = 3 + rand()%27;
    [NSTimer scheduledTimerWithTimeInterval:tm target:self selector:@selector(Payment:) userInfo:ProdId repeats:NO];
  #else
    SKProduct* Prod = Items[idx].Prod;            // Obtiene informacion del producto con indice 'idx'
  
    if( Prod == nil )                             // No existe información del producto
      {
      [Purchases AlertMsg: @"NoAppStore"];        // Pone cartel que no se ha conectado
      
      RequestStatus = REQUEST_NOSTART;            // Reinicia el proceso, de solicitud
      [Purchases RequestProdInfo];                // Solicita información sobre los productos
      return FALSE;
      }
    
    SKPayment* PayRequest = [SKPayment paymentWithProduct:Prod];  // Crea un pago con informacion del producto
  
    [[SKPaymentQueue defaultQueue] addPayment:PayRequest];        // Envia el pago a App Store
  #endif
  
  Items[idx].InProcess = TRUE;                    // Pone el estado del item (en proceso de compra)
    
  if( ShowView) [ShowView RefreshItems];          // Refresca la lista de productos (para poner cursor de espera)
  
  return TRUE;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Función que es llamada cuando una compra es completada
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
  {
  for( SKPaymentTransaction* Transation in transactions )                               // Recorre todas la transaciones pendientes
    {
    if( Transation.transactionState == SKPaymentTransactionStatePurchasing ) continue;
    
    SKPayment * Pay = Transation.payment;
    
    if( Transation.transactionState == SKPaymentTransactionStateFailed )                // Hubo un error en el poceso de pago
      {
      [Purchases CancelPayment:Pay];
      [Purchases AlertMsg: @"TransError"];
      }
    else if( Transation.transactionState == SKPaymentTransactionStatePurchased )        // El producto fue comprado satisfactoriamente
      {
      [Purchases ProcessPayment: Pay];
      }
    else if( Transation.transactionState == SKPaymentTransactionStateRestored  )        // El producto fue restaurado de una compra anterior
      {
      [Purchases ProcessPayment: Pay];
      
      InProcessRest = FALSE;
      }
      
    [queue finishTransaction:Transation];                                               // Quita la transación de la cola
    }
    
  if( ShowView) [ShowView RefreshItems];                                                // Refresca la lista de productos
  }

#ifdef SIMULATE
//---------------------------------------------------------------------------------------------------------------------------------------------
// Emula la función paymentQueue, que es la que recibe la confirmación de AppStore que termino el proceso de compra de un producto
+ (void)Payment: (NSTimer *) timer
  {
  NSString* ProdId = timer.userInfo;
  
  SKMutablePayment *myPayment = [SKMutablePayment paymentWithProductIdentifier: ProdId];
  
//  [[SKPaymentQueue defaultQueue] addPayment:myPayment];
  
  [Purchases ProcessPayment:myPayment ];
    
  if( ShowView) [ShowView RefreshItems];                                                // Refresca la lista de productos
  }
#endif

//---------------------------------------------------------------------------------------------------------------------------------------------
+(void) AlertMsg:(NSString*) msg
  {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString( @"Error", nil )
                                                  message: NSLocalizedString( msg, nil )
                                                 delegate: nil
 																			  cancelButtonTitle: NSLocalizedString( @"lbClose", nil )
 											                  otherButtonTitles: nil];
  [alert show];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Procesa un pago realizado para un item determinado
+ (void) ProcessPayment: (SKPayment *) Pay
  {
  NSUserDefaults* def = [NSUserDefaults standardUserDefaults];                          // Datos del usuario
  
  NSString* ProdId = Pay.productIdentifier;
  int idx = [Purchases IndexOfProductId: ProdId];                                       // Obtiene el indice la producto según el ID
  if( idx<0 ) return;
        
  [Purchases SetPurchasedItem:idx];                                                     // Actualiza datos de la aplicación
        
  NSString* key = [NSString stringWithFormat:@"Purchase%d", idx];                       // Guarda el producto como comprado
  [def setBool:TRUE forKey:key];
  [def synchronize];

  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];                  // Refresca las barras de idiomas
  [center postNotificationName:RefreshNotification object:self];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Cancela el proceso de pago para un producto
+ (void) CancelPayment: (SKPayment *) Pay
  {
  NSString* ProdId = Pay.productIdentifier;
  int idx = [Purchases IndexOfProductId: ProdId];                                       // Obtiene el indice la producto según el ID
  if( idx<0 ) return;
  
  Items[idx].InProcess = FALSE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el item con indice 'idx' como comprado
+(void) SetPurchasedItem:(int) idx
  {
  PurchItem &item = Items[idx];
  
  item.NoInst    = FALSE;
  item.InProcess = FALSE;

  LGSetInstDir( item.lang1 , item.lang2 );
  LGSetInstDir( item.lang2 , item.lang1 );
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Calcula los parametros visuales relacionado con la lista de items de venta
+(void) SetViewParameters
  {
  MaxDirWidth = 0;                            // Ancho maximo para la descripción de los items
  Restore     = 0;                            // Indica si se muestra el items de restaurar las compras o no
  
  for(int i=0; i<N_PURCH; ++i )               // Recorre todos los items disponibles para la compra
    {
    PurchItem &item = Items[i];               // Toma el items actual
    
    item.strDir1 = [_Purchases GetDirWithSrc: item.lang1 AndDes: item.lang2];   // Obtiene descripción de la primera dirección
    item.strDir2 = [_Purchases GetDirWithSrc: item.lang2 AndDes: item.lang1];   // Obtiene descripción de la segundo dirección
    
    item.NoInst = ( !LGIsInstDir( item.lang1, item.lang2 ) ||   // Determina si el item esta indtalado o no
                    !LGIsInstDir( item.lang2, item.lang1 ) );
      
    if( item.NoInst ) Restore = 1;                              // Si al menos hay uno sin instalar, se muestra restaural
    }
    
  if( Restore == 0 )  RequestStatus = REQUEST_ENDED;            // Si todos los productos estan comprados, no nesecita solicitar información
  
  PriceWidth = [@"$ 0.00" sizeWithAttributes:attrBuy].width+1;  // Determina el ancho de la cadena con el precio
    
  hRow  =  (7.0*LineHeight)/4.0;                                                    // Alto de una fila
  wList = SEP_BRD + MaxDirWidth + SEP_BRD + BTN_W + SEP_BRD + PriceWidth + SEP_BRD; // Ancho de la lista de items
  hList = (N_PURCH+Restore) * (hRow+SEP_ROW) - SEP_ROW;                             // Altura de la lista de items
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cadena que define la dirección de traducción formada por 'sSrc' y 'sDes'
- (NSString*) GetDirWithSrc:(int) src AndDes:(int) des
  {
  NSString* sDir = [NSString stringWithFormat:@"%@ -> %@", LGName(src), LGName(des) ];
  
  CGSize sz = [sDir sizeWithAttributes:attrBuy];
  
  if( sz.width > MaxDirWidth )
    MaxDirWidth = (int)(sz.width + 1);
    
  return sDir;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
@end

//=========================================================================================================================================================
// Maneja la lista de compras a pantalla completa
//=========================================================================================================================================================
@interface PurchasesScreen()
  {
  ModuleHdrView* Header;
  PurchasesView* PurchList;
  }
@end

//=========================================================================================================================================================
@implementation PurchasesScreen

//---------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un objeto a partir de la vista 'view', a partir de ella se busca la 'vista top' que es la que tiene tag=999
- (id)initWithFromView:(UIView*)view
  {
  UIView* TopView = [self FindTopView:view];
  if( !TopView ) return nil;
  
  self = [super initWithFrame:TopView.bounds];
  if( !self ) return self;
  
  [Purchases SetViewParameters];
  
  self.backgroundColor = ColMainBck;
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  [self CreateTitle];
  [self CreateList ];
  
  [TopView addSubview:self];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Encuentra la vista definida como el tope superior, que se usa para definir el tamaño y posicion de la pantalla, todas las subviews quedan cubiertas
- (UIView*) FindTopView:(UIView*) view
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
  Header.Text = NSLocalizedString(@"TitlePurchases", nil);
  
  [Header OnCloseBtn:@selector(OnCloseMod:) Target:self];
  
  [self addSubview: Header];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton de cerrar la pantalla y regresar a la anterior
- (void)OnCloseMod:(id)sender
  {
  [self removeFromSuperview];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la vista que muestra el listado de Items para comprar
- (void) CreateList
  {
  PurchList = [[PurchasesView alloc] initWithFrame: CGRectMake( 0, 0, wList, hList)];
  
  [self addSubview: PurchList];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Selecciona la dirección de traducción en la lista de Items
- (void) SelPurchasesSrc:(int) src Des:(int) des
  {
  for( int i=0; i<N_PURCH; ++i )
    {
    PurchItem &data = Items[i];
    if( (data.lang1==src && data.lang2==des) ||
        (data.lang1==des && data.lang2==src) )
      {
      PurchList.SelectedItem = i;
      break;
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Organiza los controles dentro de la pantalla
-(void)layoutSubviews
  {
  CGSize   sz = self.bounds.size;                                      // Toda el arrea de la vista
  float hPurc = SEP_BRD + hList + SEP_BRD;                             // Calcula altura de la lista de items
  float     y = Header.Height + SEP_BRD;                               // Posicion en Y, minima donde se puede poner la lista
  float hDisp = sz.height - Header.Height;                             // Calcula altura disponible para poner la lista
  
  if( hPurc <= hDisp )                                                 // Si hay mas espacio del necesario
    {
    y = Header.Height + ((hDisp-hList)/2);                             // Centra la lista verticalmente
    hPurc = hList;
    }
  else                                                                 // No hay espacio
    hPurc = sz.height - y - SEP_BRD;                                   // Acorta la lista de items
    
  float w = SEP_BRD + wList + SEP_BRD;;                                // Toma el ancho de la lista de items
  float x = (sz.width - w)/2;                                          // Centra horizontalmente
  
  PurchList.frame = CGRectMake( x, y, w, hPurc );                      // Pone la posición y tamaño de la lista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================================
// Objeto para representar un items para la compra
@interface PurchasesRowView : VirtualRowView
  {
  UILabel* lbPrecio;
  UILabel* lbDir1;
  UILabel* lbDir2;
  }

  - (id) initWithFrame:(CGRect)frame AtIndex:(int)iRow;
  -(void) SelectItem:(BOOL)idx Selected:(BOOL) sel;

@end

//=========================================================================================================================================================
// Objeto que maneja la vista donde se muestra la lista de Item que se pueden compar
//=========================================================================================================================================================
@interface PurchasesView()
  {
  VirtualListView* ListItems;
  }
@end

//=========================================================================================================================================================
@implementation PurchasesView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la vista desde storyboard o interface builder
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( !self ) return nil;

  [self CreateListItems];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la vista desde código
- (id)initWithFrame:(CGRect)frame
  {
  self = [super initWithFrame:frame];
  if( !self ) return nil;

  [self CreateListItems];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la vista con la lista de productos
-(void) CreateListItems
  {
  [Purchases setView:self];                                   // Relaciona la esta vista con el los datos de las compras
  [Purchases RequestProdInfo];                                // Solicita la informacion sobre los items de compra

  self.backgroundColor = [UIColor clearColor];                // Quita el color de fondo (el fondo lo establece una vista superior)
  self.clipsToBounds   = TRUE;                                // No muestra los objetos fuera de la frontera de la vista
  
  CGRect rc2 = CGRectMake( SEP_BRD, SEP_BRD, wList, hList );  // Rectangulo para mostrar los items
  
  ListItems = [[VirtualListView alloc] initWithFrame:rc2];    // Vista para mostrar los items
  [self addSubview:ListItems];                                // La adiciona como subvista de ella misma
  
  ListItems.VirtualListDelegate = self;                       // Se pne ella misma como delegado, de la lista de itemas
  
  ListItems.MinHeight = 3*LineHeight;                         // Pone latura por defecto para los items de compra
  
  [self RefreshItems];                                        // Pone el contenido de los items de compra
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone o actualiza el contenido de los items de compra
-(void) RefreshItems
  {
  [Purchases SetViewParameters];                              // Actualiza los datos de las compras que se visualizan

  int count = N_PURCH + Restore;                              // Obtiene la cantidad de items
  if( ListItems.Count != count )                              // Si cambio la cantidad de items
    {
    ListItems.Count = count;                                  // Actualiza la cantidad en la lista que muestra los items
  
    [self FillBackground];                                    // Acomoda el fondo para que sea dek mismo color
  
    [self setNeedsLayout];                                    // Marca que se necesitan reposicionar las subvista de esta vista
    [self.superview setNeedsLayout];                          // Marca que se necesitan reposicionar las subvista de la vista superior
    }
  else                                                        // Si no cambio la cantidad de items
    {
    [ListItems Refresh];                                      // Actualiza el contenido de los items
    [self setNeedsLayout];                                    // Marca que se necesitan reposicionar las subvista de esta vista
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
#define BckGrdSup          100
#define BckGrdInf          200
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone una vista en la parte superior e inferior, para que el fondo aparezca de manera homogenia con el fondo de los Items
- (void) FillBackground
  {
  float w = ListItems.frame.size.width;
  
  UIView * vs = [ListItems viewWithTag:BckGrdSup];
  
  if( vs==nil ) [self AddBckGrdViewAtPos:-hList Width:w ID:BckGrdSup];
  else         vs.frame = CGRectMake( 0, -hList, w, hList);
  
  UIView * vi = [ListItems viewWithTag:BckGrdInf];
  
  if( vi==nil ) [self AddBckGrdViewAtPos: hList Width:w ID:BckGrdSup];
  else          vi.frame = CGRectMake( 0, hList, w, hList);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea y posiciona una imagen de fondo para el scroll
- (void) AddBckGrdViewAtPos:(float) y Width:(float) w ID:(int) ID
  {
  CGRect rc = CGRectMake( 0, y, w, hList);
  
  UIView * v = [[UIView alloc] initWithFrame:rc];
  
  v.backgroundColor  = ColCellBck;
  v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  v.tag              = ID;
  
  [ListItems addSubview:v];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implemanta la propiedad 'SelectedItem'
- (int)SelectedItem              { return ListItems.SelectedIndex;       }
- (void)setSelectedItem:(int)idx {        ListItems.SelectedIndex = idx; }

+(int)MinHeight {return hList + 2*SEP_BRD + 1;}
+(int)MinWidth  {return wList + 2*SEP_BRD + 1;}

//+++++++++++++++++++++++++++++++++++++++++++ VirtualListView ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para obtener la vista que representa cada fila
-(VirtualRowView *)GetRowViewAt:(int)iRow
  {
  float hRow = (7.0*LineHeight)/4.0;
  float    w = self.frame.size.width;
  
  PurchasesRowView *cel = [[PurchasesRowView alloc] initWithFrame: CGRectMake( 0, 0, w, hRow) AtIndex:iRow];
  
  [cel SelectItem:iRow Selected:(ListItems.SelectedIndex==iRow) ];
  return cel;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cunado el usuario toca en una fila
- (void)OnSelectedRow:(int)iRow
  {
  if( iRow>= N_PURCH )                            // Si la fila sobrepasa el número de productos
    {
    [Purchases RestorePurchases];                 // Manda a restaurar los productos comprados
    return;                                       // No hace mas nada
    }
  
  PurchItem &item = Items[iRow];                  // Toma los datos del item seleccionado
  if( item.NoInst == FALSE ) return;              // Ya el item esta instaldo, no hace nada
  
  if( item.Prod != nil )                          // Si ya se obtuvo información del producto
    [Purchases PurchaseProdIndex:iRow];           // Inicializa el proceso de compra
  else                                            // Si no se ha obtenido información del producto
    {
    if( RequestStatus == REQUEST_INPROCESS )      // Si esta esperando por la información
      return;                                     // No hace nada
    
    RequestStatus = REQUEST_NOSTART;              // Fuerza a la solicitud de información
    [Purchases RequestProdInfo];                  // Solicita la informacion sobre los items de compra
    }
  }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(void)layoutSubviews
  {
  CGSize sz = self.bounds.size;                                     // Area disponible en la vista
  
  float h = sz.height - (2*SEP_BRD);                                // Calcula altura maxima de la lista de items

  ListItems.bounces = (h<hList);                                    // Permite que se mueva el contenido o no
  
  float w = sz.width - (2*SEP_BRD);                                 // Calcula el ancho de la lista de items
  
  ListItems.frame = CGRectMake( SEP_BRD, SEP_BRD, w, h );           // Posiciona la lista
  
  [self setNeedsDisplay];                                           // Manda a dibujar, para refrescar el borde
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el contenido de la vista
- (void)drawRect:(CGRect)rect
  {
  CGSize sz = self.frame.size;
  
  CGRect rcTx = CGRectMake(0, 0, sz.width, sz.height );
    
  DrawRoundRect( rcTx, R_ALL , ColBrdRound2, ColFillRound2 );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)willMoveToSuperview:(UIView *)newSuperview
  {
  if( newSuperview==nil )
    [Purchases setView:nil];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================

//=========================================================================================================================================================
@implementation PurchasesRowView

//--------------------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la fila con indice 'iRow' en la lista de compras
- (id)initWithFrame:(CGRect)frame AtIndex:(int)iRow
  {
  self = [super initWithFrame:frame];                               // Crea la vista
  if( !self ) return nil;
  
  self.backgroundColor = ColCellBck;                                // Le pone el color de fondo
  
  float hRow = self.frame.size.height;                              // Obtiene la altura de la fila
  
  if( iRow >= N_PURCH )                                             // Si sobrepasa el número de compras
    {
    [self FillRestoreRow];                                          // Crea una fila para restaurar las compras
    return self;                                                    // Termina
    }
    
  float xlb = SEP_BRD;                                              // Posición en x para primera subvista
  float ylb = 0;                                                    // Posición en y para primera subvista
  
  PurchItem &data = Items[iRow];                                    // Obtiene los datos para item de compra

  lbDir1 = [self LabelWithText:data.strDir1 X:xlb Y:ylb W:MaxDirWidth H:LineHeight];  // Pone primer idioma
  
  ylb += ((3.0*LineHeight) / 4.0);
  
  lbDir2 = [self LabelWithText:data.strDir2 X:xlb Y:ylb W:MaxDirWidth H:LineHeight];  // Pone segundo idioma
  
  xlb += MaxDirWidth;                                               // Avanza posición en x para proxima subvista
  
  if( data.NoInst )                                                 // No esta instalado el par de idiomas
    {
    ylb = 0;
  
    NSString* sPrice = data.Precio;
    if( data.Precio.length!=0 )                                     // Ya se obtubo la informacion del producto
      {
      xlb += SEP_BRD;
      lbPrecio = [self LabelWithText:sPrice X:xlb Y:ylb W:PriceWidth H:hRow];  // Pone el precio
      
      ylb  = (hRow-BTN_H)/2;
      xlb += PriceWidth + SEP_BRD;
      [self BuyIconX:xlb Y:ylb Index:iRow];                         // Pone icono de comprar (o espera)
      }
    else                                                            // No se han obtenido los datos del producto
      {
      CGRect frm = CGRectMake( xlb, 0, frame.size.width-xlb, hRow );
      
      if( RequestStatus == REQUEST_INPROCESS )                      // Si esta en progreso la obtencion de los datos
        [self ShowWaitInFrame:frm];                                 // Pone cursor de espera
      else                                                          // No se esta esperando por la información
        [self LbConectInFrame:frm];                                 // Pone cartel de 'Conectar'
      }
    }
  else                                                              // El producto esta comprado
    {
    ylb = (hRow-BTN_H)/2;                                           // Centra en la vertical
    xlb = xlb + (frame.size.width - xlb - BTN_W) / 2.0 ;            // Centra en el espacio restante
    [self BuyIconX:xlb Y:ylb Index:iRow];                           // Dibuja el icono de comprado
    }
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Chequea si la fila 'iRow' es la seleccionada y cambia el color y pone el texto parpadeando
-(void) SelectItem:(BOOL)idx Selected:(BOOL) sel
  {
  if( !Items[idx].NoInst )
    {
    lbDir1.textColor = ColBoughtItem;
    lbDir2.textColor = ColBoughtItem;
    
    return;
    }
    
  if( !sel  )
    {
    lbDir1.textColor = ColBuyItem;
    lbDir2.textColor = ColBuyItem;
    
    return;
    }
  
  lbDir1.textColor = ColBuyItemSel;
  lbDir2.textColor = ColBuyItemSel;
    
  [UIView animateWithDuration:0.8 delay:0 options: UIViewAnimationOptionRepeat//|UIViewAnimationOptionAutoreverse
                   animations:^{
                               lbDir1.alpha = 0.2;
                               lbDir2.alpha = 0.2;
                               }
                   completion:^(BOOL finished)
                               {
                               lbDir1.alpha = 1.0;
                               lbDir2.alpha = 1.0;
                               }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea los labes para el precio y las direcciones de traducción
-(UILabel*) LabelWithText:(NSString*)txt X:(float)x Y:(float)y W:(float)w H:(float)h
  {
  UILabel* lb = [[UILabel alloc] initWithFrame: CGRectMake( x, y, w, h)];
  
  lb.font = (x<50)? fontEdit : fontBuyItem;
  lb.text = txt;

  [self addSubview:lb];
  
  return lb;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea los labes para el precio y las direcciones de traducción
-(void) LbConectInFrame:(CGRect) frame
  {
  UILabel* lb = [[UILabel alloc] initWithFrame: frame];
  
  lb.font = fontBuyItem;
  lb.textColor = ColTxtBtns;
  lb.text = NSLocalizedString(@"Connect", nil);
  lb.textAlignment = NSTextAlignmentCenter;
  
  [self addSubview:lb];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el icono que indica si el item esta comprado o no
-(void) BuyIconX:(float)x Y:(float)y Index:(int)idx
  {
  PurchItem &data = Items[idx];
  
  CGRect rc = CGRectMake( x, y, BTN_W, BTN_H);        // Marco para dibujar el icono
  if( data.NoInst && data.InProcess )                 // El producto esta en proceso de compra
    {
    [self ShowWaitInFrame:rc];                        // Pone cursor de espera
    return;                                           // Termina
    }
  
  UIImageView* img = [[UIImageView alloc] initWithFrame:rc];
  
  img.image = data.NoInst? imgBuyItem : imgBuyOk;     // Icono de comprado o por comprar según el caso
  [self addSubview:img];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) FillRestoreRow
  {
  if( !InProcessRest )
    {
    UILabel* lb = [[UILabel alloc] initWithFrame: self.frame];
  
    lb.font = fontPanelTitle;
    lb.textColor = ColPanelTitle;
    lb.text = NSLocalizedString(@"Restore", nil);
    lb.textAlignment = NSTextAlignmentCenter;
  
    [self addSubview:lb];
    }
  else
    [self ShowWaitInFrame:self.frame];
  
  self.backgroundColor = ColMainBck;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra un cursor de espera en el rectangulo dado por 'Frame'
- (void) ShowWaitInFrame:(CGRect) frame
  {
  UIActivityIndicatorView* Wait = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    
  Wait.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  Wait.color = ColPanelBck;
    
  [Wait startAnimating];
  [self addSubview:Wait];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================
