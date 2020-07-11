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

//#define PRU_PRURCHASE                     // Para probar que la compra se hace correctamente
#define SIMULATE                          // Simula que se esta conectando a internet

//=========================================================================================================================================================
// Almacena los datos relacionado con un item
struct PurchItem
  {
  NSString *Precio;                           // Precio del item
  
  int lang1;                                  // Uno de los idiomas asociado al item
  int lang2;                                  // El otro idioma asociado al item
  
  NSString *strDir1;                          // Descripción de una de las direcciones asociadas con el item
  NSString *strDir2;                          // Descripción de otras de las direcciones asociadas con el item
  
  BOOL NoInst;                                // Si el producto no esta instalado, osea se puede comprar
  
  SKProduct* Prod;                            // Datos del producto desde AppStore
  BOOL       InProcess;                       // Indica que la compra del item esta en proceso
  };

//=========================================================================================================================================
// Definición de todos los items que se pueden compra
static PurchItem Items[] =  { {@"", 1, 0, @"", @"", FALSE, nil, FALSE },        // EnEs
                              {@"", 1, 2, @"", @"", FALSE, nil, FALSE },        // EnIt
                              {@"", 1, 4, @"", @"", FALSE, nil, FALSE },        // EnFr
                              {@"", 0, 2, @"", @"", FALSE, nil, FALSE },        // EsIt
                              {@"", 0, 4, @"", @"", FALSE, nil, FALSE },        // EsFr
                              {@"", 2, 4, @"", @"", FALSE, nil, FALSE } };      // ItFr

static float MaxDirWidth;                     // Ancho maximo de la descrición de los items
static float PriceWidth;                      // Ancho para poner el precio
static int   Retore;                          // 1 Si perece la opcion de restaurar, 0 no aparece

static float  hRow;                           // Alto de las filas, con la informacion de un item
static float  wList;                          // Ancho de lista con los items
static float  hList;                          // Alto de las filas con los items

static UIImage* imgBuyItem = [UIImage imageNamed: @"BuyItem"];      // Icono que indica que el item se puede comprar
static UIImage* imgBuyOk   = [UIImage imageNamed: @"BuyOk"];        // Icono que indica que el item ya fue comprado

static Purchases* _Purchases;
static PurchasesView* ShowView;                                     // Vista donde se muestran los items
static BOOL           InProcessRest;                                // Indica que la restauración de las compras esta en proceso

//=========================================================================================================================================

#ifdef TrdSuiteEn
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteEn.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteEn.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteEn.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteEn.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteEn.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteEn.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EsIt,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEnEs
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteEnEs.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteEnEs.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteEnEs.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteEnEs.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteEnEs.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteEnEs.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnIt,ITEM_EnFr,ITEM_EsIt,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEnIt
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteEnIt.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteEnIt.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteEnIt.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteEnIt.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteEnIt.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteEnIt.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnFr,ITEM_EsIt,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEnFr
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteEnFr.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteEnFr.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteEnFr.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteEnFr.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteEnFr.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteEnFr.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EsIt,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEs
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteEs.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteEs.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteEs.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteEs.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteEs.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteEs.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnIt,ITEM_EnFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEsIt
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteEsIt.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteEsIt.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteEsIt.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteEsIt.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteEsIt.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteEsIt.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EnFr,ITEM_EsFr,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteEsFr
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteEsFr.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteEsFr.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteEsFr.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteEsFr.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteEsFr.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteEsFr.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EnFr,ITEM_EsIt,ITEM_ItFr,nil];
#endif
#ifdef TrdSuiteIt
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteIt.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteIt.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteIt.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteIt.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteIt.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteIt.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnFr,ITEM_EsFr,nil];
#endif
#ifdef TrdSuiteItFr
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteItFr.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteItFr.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteItFr.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteItFr.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteItFr.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteItFr.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EnFr,ITEM_EsIt,ITEM_EsFr,nil];
#endif
#ifdef TrdSuiteFr
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteFr.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteFr.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteFr.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteFr.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteFr.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteFr.ItFr"

NSSet* LstProds = [NSSet setWithObjects:ITEM_EnEs,ITEM_EnIt,ITEM_EsIt,nil];
#endif
#ifdef TrdSuiteAll
#define ITEM_EnEs       @"com.FMontSoft.TrdSuiteAll.EnEs"
#define ITEM_EnIt       @"com.FMontSoft.TrdSuiteAll.EnIt"
#define ITEM_EnFr       @"com.FMontSoft.TrdSuiteAll.EnFr"
#define ITEM_EsIt       @"com.FMontSoft.TrdSuiteAll.EsIt"
#define ITEM_EsFr       @"com.FMontSoft.TrdSuiteAll.EsFr"
#define ITEM_ItFr       @"com.FMontSoft.TrdSuiteAll.ItFr"

NSSet* LstProds = [NSSet setWithObjects:nil];
#endif

//=========================================================================================================================================================
@implementation Purchases

//---------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los item que se pueden comprar y la comonicación con AppStore
+(void) Initialize
  {
  _Purchases = [[Purchases alloc] init];
  
  [self CalculateParameters];
  
  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  
  [_Purchases RequestProdInfo];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Estable cual es la vista que esta mostrando los item que se pueden comprar
+(void)setView:(PurchasesView*) view
  {
  ShowView = view;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Solicita la información sobre los productos que hay en AppStore
- (void) RequestProdInfo
  {
  #ifndef SIMULATE
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:LstProds ];
    [request setDelegate:_Purchases];
  
    [request start];
  #else
    int tm = 3 + rand()%27;
    [NSTimer scheduledTimerWithTimeInterval:tm target:self selector:@selector(productsRequest_:) userInfo:nil repeats:NO];
  #endif
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Función que retorna los produtos que estan listo para la compra dentro de la aplicación
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
  {
  for( SKProduct* Prod in response.products )
    {
    int index = [Purchases IndexOfProductId: Prod.productIdentifier];
    if( index<0 ) continue;
    
    [self SetItem:index WithProd:Prod];
    }
  
  if( ShowView) [ShowView RefreshItems];
  }

#ifdef SIMULATE
//---------------------------------------------------------------------------------------------------------------------------------------------
// Simula la función 'productsRequest' pero es llamada desde un timer
- (void)productsRequest_: (NSTimer *) timer
  {
  for( NSString* ProdId in LstProds )
    {
    int index = [Purchases IndexOfProductId: ProdId];
    if( index<0 ) continue;
    
    [self SetItem:index WithProd:nil];
    }
  
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
// Obtiene con el indice del items en el arreglo el identificador del producto
+(NSString*) ProductIdOfIndex:(int) idx
  {
  static NSString* ListIds[] = { ITEM_EnEs, ITEM_EnIt, ITEM_EnFr, ITEM_EsIt, ITEM_EsFr, ITEM_ItFr};
  
  if( idx<0 || idx>=N_PURCH ) return @"";
  
  return ListIds[idx];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Asocia el Item con indice 'idx' con el producto 'prod'
- (void) SetItem:(int) idx WithProd:(SKProduct*) prod
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
    SKProduct* Prod = Items[idx].Prod;
  
    if( Prod == nil )
      {
      [Purchases AlertMsg: @"NoInternet"];
      return FALSE;
      }
    
    SKPayment* PayRequest = [SKPayment paymentWithProduct:Prod];
  
    [[SKPaymentQueue defaultQueue] addPayment:PayRequest];
  #endif
  
  Items[idx].InProcess = TRUE;
    
  if( ShowView) [ShowView RefreshItems];                                                // Refresca la lista de productos
  
  return TRUE;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Función que es llamada cuando una compra es completada
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
  {
  for( SKPaymentTransaction* Transation in transactions )                               // Recorre todas la transaciones pendientes
    {
    if( Transation.transactionState == SKPaymentTransactionStateFailed )
      {
      [Purchases AlertMsg: @"TransError"];
      }
    else if( Transation.transactionState != SKPaymentTransactionStatePurchased )
      {
      [Purchases ProcessPayment:Transation.payment ];
      
      [queue finishTransaction:Transation];                                               // Quita la transación de la cola
      }
    else if( Transation.transactionState != SKPaymentTransactionStateRestored  )
      {
      [Purchases ProcessPayment:Transation.payment ];
      
      [queue finishTransaction:Transation];                                               // Quita la transación de la cola
      
      InProcessRest = FALSE;
      }
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

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el item con indice 'idx' como comprado
+(void) SetPurchasedItem:(int) idx
  {
  PurchItem &item = Items[idx];
  
  item.NoInst    = FALSE;
  item.InProcess = FALSE;

  LGSetInstDir( item.lang1 , item.lang2 );
  LGSetInstDir( item.lang2 , item.lang1 );

  #ifdef PRU_PRURCHASE
    if( ShowView) [ShowView RefreshItems];
  
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
  
    NSString* key = [NSString stringWithFormat:@"Purchase%d", idx];
    [def setBool:TRUE forKey:key];
  #endif
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Calcula los parametros geometricos relacionado con la lista de items de venta
+(void) CalculateParameters
  {
  MaxDirWidth = 0;
  Retore      = 0;
  
  for(int i=0; i<N_PURCH; ++i )
    {
    PurchItem &item = Items[i];
    
    item.strDir1 = [_Purchases GetDirWithSrc: item.lang1 AndDes: item.lang2];
    item.strDir2 = [_Purchases GetDirWithSrc: item.lang2 AndDes: item.lang1];
    
    item.NoInst = ( !LGIsInstDir( item.lang1, item.lang2 ) ||
                    !LGIsInstDir( item.lang2, item.lang1 ) );
      
    if( item.NoInst ) Retore = 1;
    }
    
  CGSize sz = [@"$ 0.00" sizeWithAttributes:attrBuy];

  PriceWidth = sz.width+1;
    
  hRow  =  (7.0*LineHeight)/4.0;
  wList = SEP_BRD + MaxDirWidth + SEP_BRD + BTN_W + SEP_BRD + PriceWidth + SEP_BRD;
  hList = (N_PURCH+Retore) * (hRow+SEP_ROW) - SEP_ROW;
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
@interface PurchasesScreen()
  {
  UILabel* title;
  
  PurchasesView* PurchList;
  }
@end

//=========================================================================================================================================================
@implementation PurchasesScreen

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithFromView:(UIView*)view
  {
  UIView* TopView = [self FindTopView:view];
  if( !TopView ) return nil;
  
  self = [super initWithFrame:TopView.frame];
  if( !self ) return self;
  
  [Purchases CalculateParameters];
  
  self.backgroundColor = ColMainBck;
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  [self CreateTitle];
  [self CreateList ];
  
  [TopView addSubview:self];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Encuentra la vista definida como el tope superior
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
// Crea la vista para mostrar el titulo
- (void) CreateTitle
  {
  title = [[UILabel alloc] initWithFrame: CGRectMake( 0, 0, 290, 20)];
  
  title.font             = fontTitle;
  title.textColor        = ColPanelTitle;
  title.textAlignment    = NSTextAlignmentCenter;
  title.text             = NSLocalizedString(@"TitlePurchases", nil);
  
  [self addSubview: title];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la vista para mostrar el titulo
- (void) CreateList
  {
  PurchList = [[PurchasesView alloc] initWithFrame: CGRectMake( 0, 0, wList, hList)];
  
  [self addSubview: PurchList];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Selecciona la dirección de traducción
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
  CGSize sz  = self.bounds.size;                                        // Toda el arrea de la vista
  
  float hText = fontTitle.pointSize + FontSize;                         // Calcula altura del titulo
  float hPurc = SEP_BRD + hList + SEP_BRD;                              // Calcula altura de la lista de items
  float     h = hText + hPurc + SEP_BRD;                                // Altura total para acomodar las dos vistas
  
  float     y =  STUS_H;                                                // Se salta la altura de la barra de estado
  float hDisp = sz.height - STUS_H;                                     // Calcula altura disponible para poner las vistas
  
  if( h <= hDisp )                                                      // Si hay espacio para todas las vistas
    y += ((hDisp- h)/2);                                                // Las centra verticalmente
  else                                                                  // No hay espacio
    hPurc = hDisp - hText - SEP_BRD;                                    // Acorta la lista de items
    
  float w = SEP_BRD + wList + SEP_BRD;;                                 // Toma el ancho de la lista de items
  float x = (sz.width - w)/2;                                           // Centra horizontalmente
  
  title.frame = CGRectMake( x, y, w, hText );                           // Pone el titulo
  
  y += hText;                                                           // Salta la altura del titulo
  PurchList.frame = CGRectMake( x, y, w, hPurc );                       // Pone la lista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  [self Close];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) Close
  {
  [self removeFromSuperview];
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
@interface PurchasesView()
  {
  VirtualListView* ListItems;
  }
@end

//=========================================================================================================================================================
@implementation PurchasesView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( !self ) return nil;

  [self CreateListItems];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
  {
  self = [super initWithFrame:frame];
  if( !self ) return nil;

  [self CreateListItems];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//
-(void) CreateListItems
  {
  [Purchases setView:self];

  self.backgroundColor = [UIColor clearColor];
  self.clipsToBounds   = TRUE;
  
  CGRect rc2 = CGRectMake( SEP_BRD, SEP_BRD, wList, hList );
  
  ListItems = [[VirtualListView alloc] initWithFrame:rc2];
  [self addSubview:ListItems];
  
  ListItems.VirtualListDelegate = self;
  
  ListItems.MinHeight = 3*LineHeight;
  
  [self RefreshItems];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(void) RefreshItems
  {
  [Purchases CalculateParameters];

  int count = N_PURCH + Retore;
  if( ListItems.Count != count )
    {
    ListItems.Count = count;
  
    [self FillBackground];
  
    [self setNeedsLayout];
    [self.superview setNeedsLayout];
    }
  else
    {
    [ListItems Refresh];
    [self setNeedsLayout];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
#define BckGrdSup          100
#define BckGrdInf          200
//--------------------------------------------------------------------------------------------------------------------------------------------------------
//
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
  if( iRow>= N_PURCH )
    {
    [Purchases RestorePurchases];
    return;
    }
  
  PurchItem &item = Items[iRow];
  
  if( item.NoInst )
    {
    #ifndef PRU_PRURCHASE
      [Purchases PurchaseProdIndex:iRow];
    #else
      [Purchases SetPurchasedItem:iRow];
    
      NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
      [center postNotificationName:RefreshNotification object:self];
    #endif
    }
  else
    {
    if( [self.superview isKindOfClass:[PurchasesScreen class]] )
      {
      [((PurchasesScreen*)self.superview) Close];
      }
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
- (id)initWithFrame:(CGRect)frame AtIndex:(int)iRow
  {
  self = [super initWithFrame:frame];
  if( !self ) return nil;
  
  self.backgroundColor = ColCellBck;
  
  float hRow = self.frame.size.height;
  
  if( iRow >= N_PURCH )
    {
    [self FillRestoreRow];
    return self;
    }
    
  float xlb = SEP_BRD;
  float ylb = 0;
  
  PurchItem &data = Items[iRow];

  lbDir1 = [self LabelWithText:data.strDir1 X:xlb Y:ylb W:MaxDirWidth H:LineHeight];
  
  ylb += ((3.0*LineHeight) / 4.0);
  
  lbDir2 = [self LabelWithText:data.strDir2 X:xlb Y:ylb W:MaxDirWidth H:LineHeight];
  
  xlb += MaxDirWidth + SEP_BRD;
  
  if( data.NoInst )
    {
    ylb = 0;
  
    NSString* sPrice = data.Precio;
    if( data.Precio.length==0 ) sPrice = @"$$.$$";
  
    lbPrecio = [self LabelWithText:sPrice X:xlb Y:ylb W:PriceWidth H:hRow];
    
    xlb += BTN_W + SEP_BRD;
    }

  ylb  = (hRow-BTN_H)/2;
  
  [self BuyIconX:xlb Y:ylb W:BTN_W H:BTN_H Index:iRow];
  
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
// Crea el icono que indica si el item esta comprado o no
-(void) BuyIconX:(float)x Y:(float)y W:(float)w H:(float)h Index:(int)idx
  {
  PurchItem &data = Items[idx];
  
  CGRect rc = CGRectMake( x, y, w, h);
 
  if( !data.InProcess )
    {
    UIImageView* img = [[UIImageView alloc] initWithFrame:rc];
    
    img.image = data.NoInst? imgBuyItem : imgBuyOk;
    
    [self addSubview:img];
    }
  else
    [self ShowWaitInFrame:rc];
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
