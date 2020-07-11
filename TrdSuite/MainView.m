//=========================================================================================================================================================
//  MainView.m
//  TrdSuite
//
//  Created by Camilo on 16/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "MainView.h"
#import "AppData.h"
#import "ColAndFont.h"

@interface MainView()
  {
  int LastSrc;
  int LastDes;
  }
@end

//=========================================================================================================================================================
@implementation MainView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Posiciona los controles de la vista principal
- (void)layoutSubviews
  {
  if( LGSrc ==-1 )                                                  // Si no hay lenguaje de origen, esconde todos lo datos
    {
    _PanelTrd.hidden = TRUE;
    _TrdInfo.hidden  = TRUE;
    _ListOras.hidden = TRUE;
   
    return;
    }
    
  if( LGSrc!=LastSrc || LGDes!=LastDes )                            // Cuando cambia el idioma fuente
    [_PanelTrd RefreshLangs];                                       // Se actualiza la barra de idiomas destinos
    
  CGSize sz = self.superview.bounds.size;                           // Tamaño de la pantalla disponible
  CGRect rcIni;                                                     // Tamaño de la primera vista visible
  
  if( _TrdEdit.hidden )                                             // Si no se esta editando la traducción
    {
    _PanelSrc.hidden = FALSE;                                       // Muestra la vista de texto fuente
    
    BOOL NoTxt = _PanelSrc.Text.length==0;
    
    _PanelTrd.hidden = NoTxt || _PanelTrd.NoShow;                   // Nuestra idimas para traducir, solo si hay texto de origen
    _TrdInfo.hidden  = NoTxt || (!_PanelTrd.NoShow && _PanelTrd.NoText);   // Decide cuando mostrar la de información de la traduccións
    
    rcIni = _PanelSrc.frame;                                        // Obtiene el tamaño de la vista del texto fuente
    }
  else                                                              // Se esta editando la traducción
    {
    _PanelSrc.hidden = TRUE;                                        // Oculta las vistas de texto fuente, traducido e información
    _PanelTrd.hidden = TRUE;
    _TrdInfo.hidden  = TRUE;
    
    rcIni = _TrdEdit.frame;                                         // Obtiene el tamaño de la vista de edicción de la traducción
    }
  
  float y    = rcIni.origin.y + rcIni.size.height;                  // Posicionamiento en la vertical del proximo control
  float yOff = [self OffsetByEditWithH:sz.height];                  // Desplazamiento de la vista hacia arriba
  
  if( !_PanelTrd.hidden )                                           // Si el panel de traduciones esta visible
    {
    float hTrd =  _PanelTrd.frame.size.height;                      // Calcula su altura
  
    _PanelTrd.frame = CGRectMake(0, y, sz.width, hTrd);             // Posiciona la vista adecuadamente
  
    y += hTrd;                                                      // Posicionamiento en la vertical del proximo control
    }
    
  if(  !_TrdInfo.hidden )                                           // Si la informacion sobre la traducción es visible
    {
    float hOpt = _TrdInfo.frame.size.height;                        // Calula su altura actual
    
    _TrdInfo.frame = CGRectMake(0, y-5, sz.width, hOpt);            // Posiciona la vista adecuamente
    
    y += hOpt-5;                                                    // Posicionamiento en la vertical del proximo control
    }
    
  float h =  sz.height - y;                                         // Altura que queda libre hacia abajo
  _ListOras.hidden = (h<LineHeight);                                // La lista de oraciones se muestra, si queda espacio
  
  if( yOff==0 && h<0 )                                              // Si no hay desplazamiento, y el ultimo control no cabe
    yOff = h;                                                       // Desplaza hacia arriba para mostrar último control
  
  float x = self.frame.origin.x;
  self.frame = CGRectMake(x, yOff, sz.width, sz.height-yOff);       // Posiciona la vista completa adecuadamente
  
  if( !_ListOras.hidden )                                           // Si la lista de oraciones es visible
    {
    if( _TrdInfo.hidden ) y+=10;
    
    _ListOras.frame = CGRectMake(5, y, sz.width-10, h);             // La posiciona adecuadamente
    }
    
  LastSrc = LGSrc;
  LastDes = LGDes;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina la magnitud que hay que desplazar hacia arriba para que el teclado no tapa la vista que se esta editando
-(float) OffsetByEditWithH:(float) H
  {
  if( KbHeight==0 ) return 0;                                       // No se esta editando un texto
  
  CGRect rc = Responder.frame;                                      // Recuadro de la vista de edicción
  rc = [self convertRect:rc fromView:Responder.superview];          // Convierte coordenadas a la vista actual
    
  float yEd = rc.origin.y + rc.size.height;                         // Linea inferior de la vista que se esta editando
  float yKb = H - KbHeight;                                         // Linea superior del teclado
    
  if( _TrdEdit.hidden )                                             // Si se esta editando el texto de origen
    yEd += BTN_H;                                                   // Para que se vean los botones de traduccir
  else                                                              // Si se esta editando la traducción
    yEd += ROUND;                                                   // Espacio de separacion del teclado

  if( yEd > yKb )                                                   // Si el control esta debajo del teclado
    return -(yEd-yKb);                                              // Desplaza la diferncia
    
  return 0;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
