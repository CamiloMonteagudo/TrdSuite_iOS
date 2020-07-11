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
#import "ConjController.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
@interface ConjDataView()
  {
  int nCol;
  int hCell;
  int Count;
  int WLayout;
  
  NSArray* CnjCells;
  }
@end

//=========================================================================================================================================================
@implementation ConjDataView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza el contenido de la conjugación
- (void)UpdateConjugate
  {
//  [self GetHeaderData];
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
    if( view.tag >= 0 ) continue;                                       // Si la vista no es una celda, la salta
    
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
  
  float y = SEP;
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
  
  cell.backgroundColor = ColCellBck;
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
// Busca todas las celdas en la vista y le pone el contenido, con la conjugación correspondiente
- (void) FillConjList
  {
  int idx = 0;
  int nVRows = (int)self.subviews.count;                                // Guarda la cantidad de vistas en el scroll
    
  for( int i=0; i<nVRows; ++i )
    {
    UIView* view = self.subviews[i];                                    // Toma la vista actual
    
    if( view.tag != -1 ) continue;                                      // Si la vista no es una celda, la salta

    UILabel* label = view.subviews[0];                                  // Obtiene label para los datos

    int iData = idx;                                                    // Obtiene el indice a los datos
    if( iData < CnjCells.count )                                        // Si esta dentro del rango de los datos
      {
      ConjAndTxt* data = CnjCells[iData];                               // Obtiene los datos
      label.attributedText = data.AttrText;                             // Pone texto de los datos
      }
    else                                                                // No hay datos
      label.Text = @"";                                                 // Pone texto vacio
        
    ++idx;                                                              // Pasa al proximo dato
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
    
    if( view.tag != -1 /*|| view == hdrView*/ ) continue;              // Si la vista no es una celda, o es el encabezamiento, la salta

    int iData = idx;                                                    // Obtiene el indice a los datos
    if( iData >= CnjCells.count ) break;                                // Llego al final de los datos, termina
    
    ConjAndTxt* data = CnjCells[iData];                                 // Obtiene los datos, para el indice actual
        
    int ret = (int)[Conj compare:data.Conj options:NSCaseInsensitiveSearch]; // Compara conjuagacion actual, con la buscada
          
    if( ret == NSOrderedSame )                                          // Son iguales las conjugaciones
      {
      view.backgroundColor = ColCellBckSel;                             // La marca como seleccionada
      if( offset == 0 && self.bounces )                                 // Si la lista no ha sido desplazada y se puede scrolear
        {
        offset = view.frame.origin.y - SEP;                             // Obtiene cantidad a desplazar
        self.contentOffset = CGPointMake(0, offset);                    // La desplaza
        }
      }
    else if( view.backgroundColor != ColCellBck )                      // Si la celda ya estaba seleccionada
      {
      view.backgroundColor = ColCellBck;                               // Quita la marca de selección
      }
      
    ++idx;                                                              // Pasa al proximo dato
    }
  }


//=========================================================================================================================================================
@end
