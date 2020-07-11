//=========================================================================================================================================================
//  ConjDataView.m
//  TrdSuite
//
//  Created by Camilo on 18/06/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "ConjDataView.h"
#import "AppData.h"
#import "ProxyConj.h"

#define SEP 2

#define BY_WORDS   0
#define BY_MODES   1
#define BY_PERSONS 2

#define N_MODES    3

static UIColor* selCol = [UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0];  // Color de fondo conjugaciones seleccionadas
static UIColor* bckCol = [UIColor whiteColor];                                     // Color de fondo conjugaciones normales

//=========================================================================================================================================================
@interface ConjDataView()
  {
  NSAttributedString *hdrTxts[3];
  float               hdrLens[3];
  float               hdrHeight;
  
  int nCol;
  int hCell;
  int Count;
  int WLayout;
  
  UIView* hdrView;
  NSArray* CnjCells;
  }
@end

//=========================================================================================================================================================
@implementation ConjDataView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza el contenido de la conjugación
- (void)UpdateConjugate
  {
  [self GetHeaderData];
  [self UpdateInActualViewMode];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se ca,
- (void)setViewMode:(int)ViewMode
  {
  _ViewMode = ViewMode;
  
  [self UpdateInActualViewMode];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  HideKeyBoard();
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (void) UpdateInActualViewMode
  {
  
  if( _ViewMode == BY_WORDS )
    {
    CnjCells = [ProxyConj GetConjsByWord];
    CnjCells = [ProxyConj SortByConjList:CnjCells];
    }
  else if( _ViewMode == BY_MODES )
    {
    CnjCells = [ProxyConj GetConjsByMode];
    }
  else if( _ViewMode == BY_PERSONS )
    {
    CnjCells = [ProxyConj GetConjsByPersons];
    }
  else return;

  int Cols = (self.bounds.size.width + SEP) / (ProxyConj.WMax + 10 + SEP);
  if( Cols <= 0 ) Cols = 1;
  
  [self MakeCellsForCols:Cols Heigth:ProxyConj.HMax+10 Count:(int)CnjCells.count];
  
  [self FillConjList];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra todas las celdas
- (void) RemoveAllCells
  {
  int nVRows = (int)self.subviews.count;                                // Guarda la cantidad de vistas en el scroll
  for( int i=nVRows-1; i>=0; --i )                                      // Recorre todas las vistas de atras hacia adelante
    {
    UIView* view = self.subviews[i];                                    // Toma la vista actual
    if( view.tag >= 0 ) continue;                                      // Si la vista no es una celda, la salta
    
    [view removeFromSuperview];                                         // Borra la vista del scroll
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) MakeCellsForCols:(int) cols Heigth:(int) h Count:(int) n
  {
  if( Count == n  )                                                     // Ya estan todas las celdas creadas
    {
    if( nCol!=cols || hCell != h )                                      // Si cambio el número de columnas o alto de las celdas
      {
      [self setNeedsLayout];                                            // Manda a redistribuir a las celdas
      return;                                                           // Termina
      }
      
    float h1 = hdrView.frame.size.height;                               // Obtiene la altura actual del header
    float h2 = [self LayoutHeaderView];                                 // Redistribuye las vistas dentro del header
    
    if( h1 != h2 )                                                      // Si la altura del header cambio
      {
      WLayout = 0;                                                      // Fuerza, que se tengan que redistribuir las celdas
      [self setNeedsLayout];                                            // Manda a redistribuir a las celdas
      }
      
    return;                                                             // No crea ninguna celda
    }
  
  nCol  = cols;                                                         // Guarda datos de las celdas que va a crear
  hCell = h;
  Count = n;
  
  [self RemoveAllCells];                                                // Borra todas las celdas que habia
  
  WLayout = self.frame.size.width;                                      // Ancho disponbles para distribuir las celdas
  
  CGRect rc = CGRectMake(0, -200, WLayout, 200);                        // Espacio, anterior a la primera celda
  UIView* back = [self CreateCellWithFrame:rc];                         // Crea la celda, inicial de fondo
  back.tag = -2;
  
  float y = [self CreateHeader];                                        // Crea la celda de encamezamiento
  float w = (WLayout - (SEP*(cols-1))) / cols;                          // Calcula en ancho de las celdas

  for( int i=0; i<n; )                                                  // Ciclo para las filas
    {
    float x = 0;                                                        // Resetea a x de las celdas
    for( int col=0; col<cols && i<n; ++col, ++i )                       // Ciclo de las columnas
      {
      UIView* cell = [self CreateCellWithFrame:CGRectMake(x, y, w, h)]; // Crea la celda
      
      [self AddLabelToCell:cell WithFrame:CGRectMake(5, 0, w-10, h)];   // Crea label dentro de la celda para poner texto
      
      x += (w + SEP);                                                   // Avanza la x de la proxima celda
      }
    
    y += (h + SEP);                                                     // Avanza la y para proxima fila
    }
    
  [self AjustHeigth:y];                                                 // Ajusta la altura del scroll y su contenido
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Ajusta la altura de la vista y la altura del contenido del scroll
- (void) AjustHeigth:(int) h
  {
  CGRect rc1 = self.superview.bounds;
  CGRect rc2 = self.frame;
  
  float HParent = rc1.origin.y + rc1.size.height;
  float YBottom = rc2.origin.y + h;
  if( YBottom< HParent )
    {
    rc2.size.height = h;
    self.bounces = FALSE;
    }
  else
    {
    rc2.size.height = HParent - rc2.origin.y;
    self.bounces = TRUE;
    }
    
  self.frame = rc2;
  
  self.contentSize   = CGSizeMake(WLayout, h);
  self.contentOffset = CGPointMake(0, 0);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una celda dentro de la lista de conjugaciones que ocupa el rectangulo definido por 'frame'
- (UIView*) CreateCellWithFrame:(CGRect) frame
  {
  UIView* cell = [[UIView alloc] initWithFrame:frame];
  
  cell.backgroundColor = bckCol;
  //cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  cell.tag = -1;
      
  [self addSubview: cell];
  
  frame = CGRectMake(5, 0, frame.size.width-10, frame.size.height);
  return cell;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona un label a una celda
- (UILabel*) AddLabelToCell:(UIView*) cell WithFrame:(CGRect) frame
  {
  UILabel* label = [[UILabel alloc] initWithFrame: frame];
  //label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  label.numberOfLines  = 0;
  
  [cell addSubview: label];
  return label;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos de los textos del encabezamiento
- (void) GetHeaderData
  {
  for( int i=0; i<3; ++i )                                                // Recorre los 3 elementos del encabezammiento
    {
    hdrTxts[i] = [ProxyConj GetFormatedData:i];                           // Obtiene el texto que lo representa
    hdrLens[i] = hdrTxts[i].size.width + 10;                              // Obtiene el tamaño del texto
    }
    
  hdrHeight = hdrTxts[0].size.height + 3;                                 // Obtiene alto de una linea del encabezamiento
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene le encabezamiento para las conjugaciones
- (float) CreateHeader
  {
  CGRect frms[3];
  
  float W = self.frame.size.width;
  
  float x = 5;
  float y = 5;

  for( int i=0; i<3; ++i )
    {
    float len = hdrLens[i];
    if( x+len > W ) {x=5; y += hdrHeight;}
    
    frms[i] = CGRectMake( x, y, len, hdrHeight );
    x += len;
    }
  
  int idxLast = (_ViewMode==BY_MODES)? 2 : 0;
  
  float h = (frms[idxLast].origin.y + frms[idxLast].size.height + 5);
  
  hdrView = [self CreateCellWithFrame:CGRectMake(0, SEP, W, h)];
      
  for( int i=0; i<3; ++i )
    [self AddLabelToCell:hdrView WithFrame:frms[i]];
  
  return h + SEP + SEP;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
  {
  int   W  = self.frame.size.width;
  int Cols = (W + SEP) / (ProxyConj.WMax + 10 + SEP);
  if( Cols >= 0 ) Cols = 1;
  
  int H = ProxyConj.HMax + 10;
  
  if( W != WLayout || nCol != Cols || hCell != H )
    {
    nCol  = Cols;
    hCell = H;
    [self LayoutCellsInWidth:W];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Relocaliza las celdas generalmente devido a un cambio en el número de columnas
- (void) LayoutCellsInWidth:(int) W
  {
  WLayout = W;                                                        // Ancho para mostrar las celdas
  
  float y = 0;                                                        // Posición para la primera fila
  float w = (W - (SEP*(nCol-1))) / nCol;                              // Determina el ancho de las celdas

  int n = (int)self.subviews.count;                                   // Cantidad de sub-vistas en el scroll
  for( int i=0; i<n; )                                                // Recorre todas las sub-vistas
    {
    float x = 0;                                                      // Posición para la primera columna
    for( int col=0; col<nCol && i<n; ++col, ++i )                     // Recorre todas las columnas
      {
      UIView* view = self.subviews[i];                                // Toma la vista actual
      if( view.tag >= 0 ) {--col; continue;}                          // Si la vista no es una celda, la salta
      
      if( view.tag == -2 )                                            // Es la celda de background inicial
        {
        view.frame = CGRectMake(0, -200, WLayout, 200);               // Redimesiona la celda
        --col;                                                        // No la cuenta como columna
        }
      else if( view == hdrView )                                      // Es la celda de encabezamiento
        {
        y = [self LayoutHeaderView] + SEP;                            // La redimesiona y pone 'y' segun su altura
        --col;                                                        // No la toma como columna
        }
      else                                                            // Es una celda normal
        {
        view.frame = CGRectMake(x, y, w, hCell);                      // La mueve para la posición actual
        UIView* lb = view.subviews[0];                                // Toma el label con el contenido
        lb.frame   = CGRectMake(5, 0, w-10, hCell);                   // Lo ajusta al tamaño de la celda
      
        x += (w + SEP);                                               // Avanza posición en x (cambia de columna)
        }
      }
    
    y += (hCell + SEP);                                               // Avanza posión en y (cambio de fila)
    }
    
  [self AjustHeigth:y];                                               // Ajusta la altura del scroll y su contenido
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Relocaliza los label dentro del encabezamiento, y lo redimesiona si es necesario
- (float) LayoutHeaderView
  {
  float  x = 5;                                                       // Posición del label inicial
  float  y = 5;
  CGRect lstFrm;                                                      // Frame del ultimo label a mostrar
  
  for( int i=0; i<3; ++i )                                            // Recorre todos lo label, en el encabezamiento
    {
    UILabel* lb = hdrView.subviews[i];                                // Coje label actual
    
    float len = hdrLens[i];                                           // Obtiene longitud del label correspondiente
    if( x+len > WLayout ) {x=5; y += hdrHeight;}                      // Si sobrepasa el ancho disponible, pasa la proxima fila
    
    lb.frame = CGRectMake( x, y, len, hdrHeight );                    // Posiona el label
    x += len;                                                         // Salta la longituda del label actual
    
    if( !lb.hidden ) lstFrm = lb.frame;                               // Si no esta oculto, lo toma como el último
    }

  float h = (lstFrm.origin.y + lstFrm.size.height + 5);               // Calcula la altura, según el ultimo label visible
  
  hdrView.frame = CGRectMake(0, SEP, WLayout, h);                     // Redimensiona la celda de encabezamiento
      
  return h + SEP;                                                     // Retorna la altura del encabezamiento
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca todas las celdas en la vista y le pone el contenido, con la conjugación correspondiente
- (void) FillConjList
  {
  int idx = 0;
  int nVRows = (int)self.subviews.count;                                // Guarda la cantidad de vistas en el scroll
    
  for( int i=0; i<nVRows; ++i )
    {
    UIView* view = self.subviews[i];                                    // Toma la vista actual
    
    if( view.tag != -1 ) continue;                                      // Si la vista no es una celda, la salta
    if( view == hdrView )                                               // Este es el header
      {
      int idxLast = (_ViewMode==BY_MODES)? 2:0;                         // Último elemento visible en el header
  
      for( int j=0; j<3; ++j )                                          // Recorre todos lo label
        {
        UILabel* lb = view.subviews[j];                                 // Coje label actual
        lb.attributedText = hdrTxts[j];                                 // Le pone el texto
    
        lb.hidden = (j>idxLast);                                        // Lo muestra/oculta según el caso
        }
      }
    else                                                                // Cualquier otra celda
      {
      UILabel* label = view.subviews[0];                                // Obtiene label para los datos

      int iData = idx;                                                  // Obtiene el indice a los datos
      if( iData < CnjCells.count )                                      // Si esta dentro del rango de los datos
        {
        ConjAndTxt* data = CnjCells[iData];                             // Obtiene los datos
        label.attributedText = data.AttrText;                           // Pone texto de los datos
        }
      else                                                              // No hay datos
        label.Text = @"";                                               // Pone texto vacio
        
      ++idx;                                                            // Pasa al proximo dato
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca todas las conjugaciones y selecciona la que coincida con 'Conj' si ya hay una seleccionada la quita
- (void) SelectConj:(NSString*) Conj
  {
  float offset = 0;                                                     // Desplazamiento hacia arriba de la lista
  
  if( _ViewMode != BY_WORDS ) return;                                   // Solo se aplica en el modo por conjugaciones
  
  int idx = 0;
  int nVRows = (int)self.subviews.count;                                // Guarda la cantidad de vistas en el scroll
    
  for( int i=0; i<nVRows; ++i )                                         // Recorre todas las vistas en el scroll
    {
    UIView* view = self.subviews[i];                                    // Toma la vista actual
    
    if( view.tag != -1 || view == hdrView ) continue;                   // Si la vista no es una celda, o es el encabezamiento, la salta

    int iData = idx;                                                    // Obtiene el indice a los datos
    if( iData >= CnjCells.count ) break;                                // Llego al final de los datos, termina
    
    ConjAndTxt* data = CnjCells[iData];                                 // Obtiene los datos, para el indice actual
        
    int ret = [Conj compare:data.Conj options:NSCaseInsensitiveSearch]; // Compara conjuagacion actual, con la buscada
          
    if( ret == NSOrderedSame )                                          // Son iguales las conjugaciones
      {
      view.backgroundColor = selCol;                                    // La marca como seleccionada
      if( offset == 0 && self.bounces )                                 // Si la lista no ha sido desplazada y se puede scrolear
        {
        offset = view.frame.origin.y - SEP;                             // Obtiene cantidad a desplazar
        self.contentOffset = CGPointMake(0, offset);                    // La desplaza
        }
      }
    else if( view.backgroundColor != bckCol )                           // Si la celda ya estaba seleccionada
      {
      view.backgroundColor = bckCol;                                    // Quita la marca de selección
      }
      
    ++idx;                                                              // Pasa al proximo dato
    }
  }


//=========================================================================================================================================================
@end
