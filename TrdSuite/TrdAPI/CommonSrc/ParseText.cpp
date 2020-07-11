
#include <string.h> 
#include "stdafx.h"
#include "parsetext.h"


static BYTE Keys[] =  {//   Ini,End,Num,Up,Low
                      PACK( 0 , 1 , 0 , 0, 0 ),// 0  NUL
                      PACK( 0 , 1 , 0 , 0, 0 ),// 1  SOH
                      PACK( 0 , 1 , 0 , 0, 0 ),// 2  STX
                      PACK( 0 , 1 , 0 , 0, 0 ),// 3  ETX
                      PACK( 0 , 1 , 0 , 0, 0 ),// 4  EOT
                      PACK( 0 , 1 , 0 , 0, 0 ),// 5  ENQ
                      PACK( 0 , 1 , 0 , 0, 0 ),// 6  ACK
                      PACK( 0 , 1 , 0 , 0, 0 ),// 7  BEL
                      PACK( 0 , 1 , 0 , 0, 0 ),// 8  BS
                      PACK( 0 , 1 , 0 , 0, 0 ),// 9  HT
                      PACK( 0 , 1 , 0 , 0, 0 ),// 10 LF
                      PACK( 0 , 1 , 0 , 0, 0 ),// 11 VT
                      PACK( 0 , 1 , 0 , 0, 0 ),// 12 FF
                      PACK( 0 , 1 , 0 , 0, 0 ),// 13 CR
                      PACK( 0 , 1 , 0 , 0, 0 ),// 14 SO
                      PACK( 0 , 1 , 0 , 0, 0 ),// 15 SI
                      PACK( 0 , 1 , 0 , 0, 0 ),// 16 SLE
                      PACK( 0 , 1 , 0 , 0, 0 ),// 17 CS1
                      PACK( 0 , 1 , 0 , 0, 0 ),// 18 DC2
                      PACK( 0 , 1 , 0 , 0, 0 ),// 19 DC3
                      PACK( 0 , 1 , 0 , 0, 0 ),// 20 DC4
                      PACK( 0 , 1 , 0 , 0, 0 ),// 21 NAK
                      PACK( 0 , 1 , 0 , 0, 0 ),// 22 SYN
                      PACK( 0 , 1 , 0 , 0, 0 ),// 23 ETB
                      PACK( 0 , 1 , 0 , 0, 0 ),// 24 CAN
                      PACK( 0 , 1 , 0 , 0, 0 ),// 25 EM
                      PACK( 0 , 1 , 0 , 0, 0 ),// 26 SIB
                      PACK( 0 , 1 , 0 , 0, 0 ),// 27 ESC
                      PACK( 0 , 1 , 0 , 0, 0 ),// 28 FS
                      PACK( 0 , 1 , 0 , 0, 0 ),// 29 GS
                      PACK( 0 , 1 , 0 , 0, 0 ),// 30 RS
                      PACK( 0 , 1 , 0 , 0, 0 ),// 31 US
                      PACK( 0 , 0 , 0 , 0, 0 ),// 32 (space)
                      PACK( 1 , 1 , 0 , 0, 0 ),// 33 !
                      PACK( 1 , 1 , 0 , 0, 0 ),// 34 "
                      PACK( 0 , 0 , 0 , 0, 0 ),// 35 #
                      PACK( 0 , 0 , 0 , 0, 0 ),// 36 $
                      PACK( 0 , 0 , 0 , 0, 0 ),// 37 %
                      PACK( 0 , 0 , 0 , 0, 0 ),// 38 &
                      PACK( 1 , 0 , 0 , 0, 0 ),// 39 '
                      PACK( 1 , 0 , 0 , 0, 0 ),// 40 (
                      PACK( 0 , 0 , 0 , 0, 0 ),// 41 )
                      PACK( 0 , 0 , 0 , 0, 0 ),// 42 *
                      PACK( 0 , 0 , 0 , 0, 0 ),// 43 +
                      PACK( 0 , 0 , 0 , 0, 0 ),// 44 ,
                      PACK( 0 , 0 , 0 , 0, 0 ),// 45 -
                      PACK( 0 , 1 , 0 , 0, 0 ),// 46 .
                      PACK( 0 , 0 , 0 , 0, 0 ),// 47 /
                      PACK( 1 , 0 , 1 , 0, 0 ),// 48 0
                      PACK( 1 , 0 , 1 , 0, 0 ),// 49 1
                      PACK( 1 , 0 , 1 , 0, 0 ),// 50 2
                      PACK( 1 , 0 , 1 , 0, 0 ),// 51 3
                      PACK( 1 , 0 , 1 , 0, 0 ),// 52 4
                      PACK( 1 , 0 , 1 , 0, 0 ),// 53 5
                      PACK( 1 , 0 , 1 , 0, 0 ),// 54 6
                      PACK( 1 , 0 , 1 , 0, 0 ),// 55 7
                      PACK( 1 , 0 , 1 , 0, 0 ),// 56 8
                      PACK( 1 , 0 , 1 , 0, 0 ),// 57 9
                      PACK( 0 , 1 , 0 , 0, 0 ),// 58 :
                      PACK( 0 , 1 , 0 , 0, 0 ),// 59 ;
                      PACK( 0 , 0 , 0 , 0, 0 ),// 60 <
                      PACK( 0 , 0 , 0 , 0, 0 ),// 61 =
                      PACK( 0 , 0 , 0 , 0, 0 ),// 62 >
                      PACK( 0 , 1 , 0 , 0, 0 ),// 63 ?
                      PACK( 0 , 0 , 0 , 0, 0 ),// 64 @
                      PACK( 1 , 0 , 0 , 1, 0 ),// 65 A
                      PACK( 1 , 0 , 0 , 1, 0 ),// 66 B
                      PACK( 1 , 0 , 0 , 1, 0 ),// 67 C
                      PACK( 1 , 0 , 0 , 1, 0 ),// 68 D
                      PACK( 1 , 0 , 0 , 1, 0 ),// 69 E
                      PACK( 1 , 0 , 0 , 1, 0 ),// 70 F
                      PACK( 1 , 0 , 0 , 1, 0 ),// 71 G
                      PACK( 1 , 0 , 0 , 1, 0 ),// 72 H
                      PACK( 1 , 0 , 0 , 1, 0 ),// 73 I
                      PACK( 1 , 0 , 0 , 1, 0 ),// 74 J
                      PACK( 1 , 0 , 0 , 1, 0 ),// 75 K
                      PACK( 1 , 0 , 0 , 1, 0 ),// 76 L
                      PACK( 1 , 0 , 0 , 1, 0 ),// 77 M
                      PACK( 1 , 0 , 0 , 1, 0 ),// 78 N
                      PACK( 1 , 0 , 0 , 1, 0 ),// 79 O
                      PACK( 1 , 0 , 0 , 1, 0 ),// 80 P
                      PACK( 1 , 0 , 0 , 1, 0 ),// 81 Q
                      PACK( 1 , 0 , 0 , 1, 0 ),// 82 R
                      PACK( 1 , 0 , 0 , 1, 0 ),// 83 S
                      PACK( 1 , 0 , 0 , 1, 0 ),// 84 T
                      PACK( 1 , 0 , 0 , 1, 0 ),// 85 U
                      PACK( 1 , 0 , 0 , 1, 0 ),// 86 V
                      PACK( 1 , 0 , 0 , 1, 0 ),// 87 W
                      PACK( 1 , 0 , 0 , 1, 0 ),// 88 X
                      PACK( 1 , 0 , 0 , 1, 0 ),// 89 Y
                      PACK( 1 , 0 , 0 , 1, 0 ),// 90 Z
                      PACK( 0 , 1 , 0 , 0, 0 ),// 91 [
                      PACK( 0 , 1 , 0 , 0, 0 ),// 92 backslat
                      PACK( 0 , 1 , 0 , 0, 0 ),// 93 ]
                      PACK( 0 , 1 , 0 , 0, 0 ),// 94 ^
                      PACK( 0 , 0 , 0 , 0, 0 ),// 95 _
                      PACK( 0 , 0 , 0 , 0, 0 ),// 96 `
                      PACK( 1 , 0 , 0 , 0, 1 ),// 97 a
                      PACK( 1 , 0 , 0 , 0, 1 ),// 98 b
                      PACK( 1 , 0 , 0 , 0, 1 ),// 99 c
                      PACK( 1 , 0 , 0 , 0, 1 ),// 100 d
                      PACK( 1 , 0 , 0 , 0, 1 ),// 101 e
                      PACK( 1 , 0 , 0 , 0, 1 ),// 102 f
                      PACK( 1 , 0 , 0 , 0, 1 ),// 103 g
                      PACK( 1 , 0 , 0 , 0, 1 ),// 104 h
                      PACK( 1 , 0 , 0 , 0, 1 ),// 105 i
                      PACK( 1 , 0 , 0 , 0, 1 ),// 106 j
                      PACK( 1 , 0 , 0 , 0, 1 ),// 107 k
                      PACK( 1 , 0 , 0 , 0, 1 ),// 108 l
                      PACK( 1 , 0 , 0 , 0, 1 ),// 109 m
                      PACK( 1 , 0 , 0 , 0, 1 ),// 110 n
                      PACK( 1 , 0 , 0 , 0, 1 ),// 111 o
                      PACK( 1 , 0 , 0 , 0, 1 ),// 112 p
                      PACK( 1 , 0 , 0 , 0, 1 ),// 113 q
                      PACK( 1 , 0 , 0 , 0, 1 ),// 114 r
                      PACK( 1 , 0 , 0 , 0, 1 ),// 115 s
                      PACK( 1 , 0 , 0 , 0, 1 ),// 116 t
                      PACK( 1 , 0 , 0 , 0, 1 ),// 117 u
                      PACK( 1 , 0 , 0 , 0, 1 ),// 118 v
                      PACK( 1 , 0 , 0 , 0, 1 ),// 119 w
                      PACK( 1 , 0 , 0 , 0, 1 ),// 120 x
                      PACK( 1 , 0 , 0 , 0, 1 ),// 121 y
                      PACK( 1 , 0 , 0 , 0, 1 ),// 122 z
                      PACK( 0 , 1 , 0 , 0, 0 ),// 123 {
                      PACK( 0 , 1 , 0 , 0, 0 ),// 124 |
                      PACK( 0 , 1 , 0 , 0, 0 ),// 125 }
                      PACK( 0 , 1 , 0 , 0, 0 ),// 126 ~
                      PACK( 0 , 0 , 0 , 0, 0 ),// 127
                      PACK( 1 , 0 , 0 , 1, 0 ),// 128 €
                      PACK( 0 , 0 , 0 , 0, 0 ),// 129
                      PACK( 0 , 1 , 0 , 0, 0 ),// 130 ‚
                      PACK( 0 , 0 , 0 , 0, 0 ),// 131 
                      PACK( 0 , 1 , 0 , 0, 0 ),// 132 „
                      PACK( 0 , 1 , 0 , 0, 0 ),// 133 …
                      PACK( 0 , 1 , 0 , 0, 0 ),// 134 †
                      PACK( 0 , 1 , 0 , 0, 0 ),// 135 ‡
                      PACK( 0 , 0 , 0 , 0, 0 ),// 136
                      PACK( 0 , 1 , 0 , 0, 0 ),// 137 ‰
                      PACK( 1 , 0 , 0 , 1, 0 ),// 138 Š
                      PACK( 1 , 0 , 0 , 0, 0 ),// 139 ‹
                      PACK( 1 , 0 , 0 , 1, 0 ),// 140 S
                      PACK( 1 , 0 , 0 , 1, 0 ),// 141 T
                      PACK( 1 , 0 , 0 , 1, 0 ),// 142 Ž
                      PACK( 1 , 0 , 0 , 1, 0 ),// 143 Z
                      PACK( 0 , 0 , 0 , 0, 0 ),// 144 
                      PACK( 0 , 0 , 0 , 0, 0 ),// 145 ‘
                      PACK( 0 , 0 , 0 , 0, 0 ),// 146 ’
                      PACK( 0 , 0 , 0 , 0, 0 ),// 147 “
                      PACK( 0 , 1 , 0 , 0, 0 ),// 148 ”
                      PACK( 0 , 0 , 0 , 0, 0 ),// 149 •
                      PACK( 0 , 0 , 0 , 0, 0 ),// 150 –
                      PACK( 0 , 0 , 0 , 0, 0 ),// 151 — 
                      PACK( 0 , 0 , 0 , 0, 0 ),// 152
                      PACK( 0 , 1 , 0 , 0, 0 ),// 153 ™
                      PACK( 1 , 0 , 0 , 0, 1 ),// 154 š
                      PACK( 0 , 0 , 0 , 0, 0 ),// 155 ›
                      PACK( 1 , 0 , 0 , 0, 1 ),// 156 s
                      PACK( 1 , 0 , 0 , 0, 1 ),// 157 t
                      PACK( 1 , 0 , 0 , 0, 1 ),// 158 ž
                      PACK( 1 , 0 , 0 , 0, 1 ),// 159 z
                      PACK( 0 , 0 , 0 , 0, 0 ),// 160   
                      PACK( 1 , 0 , 0 , 0, 0 ),// 161 ¡
                      PACK( 0 , 0 , 0 , 0, 0 ),// 162 ¢
                      PACK( 0 , 0 , 0 , 0, 0 ),// 163 £
                      PACK( 0 , 0 , 0 , 0, 0 ),// 164 ¤
                      PACK( 0 , 0 , 0 , 0, 0 ),// 165 ¥
                      PACK( 0 , 1 , 0 , 0, 0 ),// 166 ¦
                      PACK( 0 , 0 , 0 , 0, 0 ),// 167 §
                      PACK( 0 , 1 , 0 , 0, 0 ),// 168 ¨
                      PACK( 0 , 0 , 0 , 0, 0 ),// 169 ©
                      PACK( 0 , 1 , 0 , 0, 0 ),// 170 ª
                      PACK( 1 , 0 , 0 , 0, 0 ),// 171 «
                      PACK( 0 , 1 , 0 , 0, 0 ),// 172 ¬
                      PACK( 0 , 1 , 0 , 0, 0 ),// 173 ­
                      PACK( 0 , 0 , 0 , 0, 0 ),// 174 ®
                      PACK( 0 , 1 , 0 , 0, 0 ),// 175 ¯
                      PACK( 0 , 0 , 0 , 0, 0 ),// 176 °
                      PACK( 0 , 0 , 0 , 0, 0 ),// 177 ±
                      PACK( 0 , 0 , 0 , 0, 0 ),// 178 ²
                      PACK( 0 , 0 , 0 , 0, 0 ),// 179 ³
                      PACK( 0 , 0 , 0 , 0, 0 ),// 180 ´
                      PACK( 0 , 0 , 0 , 0, 0 ),// 181 µ
                      PACK( 0 , 0 , 0 , 0, 0 ),// 182 ¶
                      PACK( 0 , 1 , 0 , 0, 0 ),// 183 ·
                      PACK( 0 , 1 , 0 , 0, 0 ),// 184 ¸
                      PACK( 0 , 1 , 0 , 0, 0 ),// 185 ¹
                      PACK( 0 , 0 , 0 , 0, 0 ),// 186 º
                      PACK( 0 , 0 , 0 , 0, 0 ),// 187 »
                      PACK( 1 , 0 , 0 , 0, 0 ),// 188 ¼
                      PACK( 1 , 0 , 0 , 0, 0 ),// 189 ½
                      PACK( 1 , 0 , 0 , 0, 0 ),// 190 ¾
                      PACK( 1 , 1 , 0 , 0, 0 ),// 191 ¿
                      PACK( 1 , 0 , 0 , 1, 0 ),// 192 À
                      PACK( 1 , 0 , 0 , 1, 0 ),// 193 Á
                      PACK( 1 , 0 , 0 , 1, 0 ),// 194 Â
                      PACK( 1 , 0 , 0 , 1, 0 ),// 195 Ã
                      PACK( 1 , 0 , 0 , 1, 0 ),// 196 Ä
                      PACK( 1 , 0 , 0 , 1, 0 ),// 197 Å
                      PACK( 0 , 0 , 0 , 0, 0 ),// 198 Æ
                      PACK( 0 , 0 , 0 , 1, 0 ),// 199 Ç
                      PACK( 1 , 0 , 0 , 1, 0 ),// 200 È
                      PACK( 1 , 0 , 0 , 1, 0 ),// 201 É
                      PACK( 1 , 0 , 0 , 1, 0 ),// 202 Ê
                      PACK( 1 , 0 , 0 , 1, 0 ),// 203 Ë
                      PACK( 1 , 0 , 0 , 1, 0 ),// 204 Ì
                      PACK( 1 , 0 , 0 , 1, 0 ),// 205 Í
                      PACK( 1 , 0 , 0 , 1, 0 ),// 206 Î
                      PACK( 1 , 0 , 0 , 1, 0 ),// 207 Ï
                      PACK( 1 , 0 , 0 , 1, 0 ),// 208 Ð
                      PACK( 1 , 0 , 0 , 1, 0 ),// 209 Ñ
                      PACK( 1 , 0 , 0 , 1, 0 ),// 210 Ò
                      PACK( 1 , 0 , 0 , 1, 0 ),// 211 Ó
                      PACK( 1 , 0 , 0 , 1, 0 ),// 212 Ô
                      PACK( 1 , 0 , 0 , 1, 0 ),// 213 Õ
                      PACK( 1 , 0 , 0 , 1, 0 ),// 214 Ö
                      PACK( 0 , 0 , 0 , 0, 0 ),// 215 ×
                      PACK( 0 , 0 , 0 , 1, 0 ),// 216 Ø
                      PACK( 1 , 0 , 0 , 1, 0 ),// 217 Ù
                      PACK( 1 , 0 , 0 , 1, 0 ),// 218 Ú
                      PACK( 1 , 0 , 0 , 1, 0 ),// 219 Û
                      PACK( 1 , 0 , 0 , 1, 0 ),// 220 Ü
                      PACK( 1 , 0 , 0 , 1, 0 ),// 221 Ý
                      PACK( 1 , 0 , 0 , 0, 0 ),// 222 Þ
                      PACK( 1 , 0 , 0 , 0, 0 ),// 223 ß
                      PACK( 1 , 0 , 0 , 0, 1 ),// 224 à
                      PACK( 1 , 0 , 0 , 0, 1 ),// 225 á
                      PACK( 1 , 0 , 0 , 0, 1 ),// 226 â
                      PACK( 1 , 0 , 0 , 0, 1 ),// 227 ã
                      PACK( 1 , 0 , 0 , 0, 1 ),// 228 ä
                      PACK( 1 , 0 , 0 , 0, 1 ),// 229 å
                      PACK( 1 , 0 , 0 , 0, 1 ),// 230 æ
                      PACK( 1 , 0 , 0 , 0, 1 ),// 231 ç
                      PACK( 1 , 0 , 0 , 0, 1 ),// 232 è
                      PACK( 1 , 0 , 0 , 0, 1 ),// 233 é
                      PACK( 1 , 0 , 0 , 0, 1 ),// 234 ê
                      PACK( 1 , 0 , 0 , 0, 1 ),// 235 ë
                      PACK( 1 , 0 , 0 , 0, 1 ),// 236 ì
                      PACK( 1 , 0 , 0 , 0, 1 ),// 237 í
                      PACK( 1 , 0 , 0 , 0, 1 ),// 238 î
                      PACK( 1 , 0 , 0 , 0, 1 ),// 239 ï
                      PACK( 1 , 0 , 0 , 0, 1 ),// 240 ð
                      PACK( 1 , 0 , 0 , 0, 1 ),// 241 ñ
                      PACK( 1 , 0 , 0 , 0, 1 ),// 242 ò
                      PACK( 1 , 0 , 0 , 0, 1 ),// 243 ó
                      PACK( 1 , 0 , 0 , 0, 1 ),// 244 ô
                      PACK( 1 , 0 , 0 , 0, 1 ),// 245 õ
                      PACK( 1 , 0 , 0 , 0, 1 ),// 246 ö
                      PACK( 0 , 0 , 0 , 0, 0 ),// 247 ÷
                      PACK( 0 , 0 , 0 , 0, 1 ),// 248 ø
                      PACK( 1 , 0 , 0 , 0, 1 ),// 249 ù
                      PACK( 1 , 0 , 0 , 0, 1 ),// 250 ú
                      PACK( 1 , 0 , 0 , 0, 1 ),// 251 û
                      PACK( 1 , 0 , 0 , 0, 1 ),// 252 ü
                      PACK( 1 , 0 , 0 , 0, 1 ),// 253 ý
                      PACK( 1 , 0 , 0 , 0, 1 ),// 254 þ
                      PACK( 1 , 0 , 0 , 0, 1 ),// 255 ÿ
                      };                  
/*------------------------------------------------------------------------------------*/
// Constructor, pone todos los valores por defecto
//<!----------------------------------------------------------------------------------->
CParseText::CParseText(void)
  {
  m_Txt   = "";
  m_len   = 0;
  }

/*------------------------------------------------------------------------------------*/
// Destructor, Libera todos los Items
//<!----------------------------------------------------------------------------------->
CParseText::~CParseText(void)
  {
  ClearSetting();
  }

/*------------------------------------------------------------------------------------*/
// Libera todos los Items analizados hasta ese momento
//<!----------------------------------------------------------------------------------->
void CParseText::ClearSetting(void)
  {
  for( int i=0; i<m_Items.GetSize(); ++i )  // Libera todos los Items
    delete (CItem *)m_Items[i];

  m_Items.RemoveAll();                      // Limpia el arreglo de Items
  }

/*------------------------------------------------------------------------------------*/
// Establece el texto que se va a analizar
//<!----------------------------------------------------------------------------------->
void CParseText::SetText(CStringA& Text )
  {
  if( Text.Length() == 0 ) return;
  
  m_Txt = CS2SZ(Text);                     // Guarda puntero al texto
  m_len = Text.Length();                   // Longitud del texto

  // Determina el formato del texto
  int i=0;
  while( Text[i]<=' ' ) ++i;                  // Salta los espacios iniciales

  ClearSetting();                           // Libera todos los items que habia
  }

/*------------------------------------------------------------------------------------*/
//Obtiene el texto traducido completo.
//<!----------------------------------------------------------------------------------->
CStringA CParseText::GetTrdText()
{
  CStringA  Text;                                     // Texto traducido completo

  for( int i=0; i<m_Items.GetSize(); ++i )            // Recorre todos los items
    {
    CItem *Item = (CItem*)(m_Items.GetAt(i));         // Toma el Item actual

    if( Item->m_Type == 'c'  )                        // Si el item no se traduce
      Text += Item->m_Text;                           // Adiciona item al texto

    if( Item->m_Type == 't' )                         // Si es un item que se traduce
      Text += Item->m_Trd;                            // Adiciona el resto al texto
    }

  return Text;                                        // Retorna texto completo
}

/*------------------------------------------------------------------------------------*/
// Analiza el texto establecido anteriormente y lo separa en oraciones
//<!----------------------------------------------------------------------------------->
bool CParseText::Parse()          
  {
  ClearSetting();                             // Libera todos los items que habia

  for( long i=0; i<m_len; )                   // Recorre todos los caracteres del texto
    {
    SkipNoText( i );                          // Obtiene todo hasta principio de oracion

    int _i = (int)i;                          // Caracter donde se inicia la busqueda
    GetTextOra( i );                          // Obtiene todo hasta fin de oración

    if( i<m_len && _i == i )                  // No se puedo obtener texto
      AddItem( 'c', CStringA(m_Txt[i++]) );   // Pone el caracter en la cascara para que 
                                              // no caiga en un ciclo infinito
    }
                                     
  return true;
  }

/*------------------------------------------------------------------------------------*/
// Analiza el texto 'Text' a partir del caracter 'i', obteniendo todos los caracteres
// no texto y avanzando 'i' hasta el comienzo de la proxima oración. Si 'i' lleva hasta
// 'len' retorna false y termina.
//<!----------------------------------------------------------------------------------->
bool CParseText::SkipNoText( long& _i)
  {
  CStringA Cascara;
  long i;
  for( i=_i; i<m_len; ++i )                 // Para todos los caracters i    
    {
    char c = m_Txt[i];                      // Obtine el caracter i 

    if( isc_ini(c)  )                       // Si el caracter puede inicial oración
      {
      if( IsBullet( i, i, Cascara) )        // Si empieza con bullet
        continue;                           // Contunua analizando
      else
        break;                              // Termina el analasis
      }

    Cascara += c;                         // Guarda el caracter
    }

  // Encontro el inicio de oración
  AddItem( 'c', Cascara );                  // Adiciona los caracteres a la lista
  _i = i;                                   // Pone el puntero al inicio de oracion

  return true;
  }

/*------------------------------------------------------------------------------------*/
// Analiza el texto 'Text' a partir del caracter 'i', obteniendo todos los caracteres
// que forman parte de una oración y avanzando 'i' hasta el final de la oración. 
// Si 'i' lleva hasta 'len' retorna false y termina.
//<!----------------------------------------------------------------------------------->
bool CParseText::GetTextOra( long& _i)
  {
  CStringA Ora;                               // Contenido de la oración
  
  long i=_i;
  for( ; i<m_len; ++i )                       // Para todos los caracters i    
    {
    char c = m_Txt[i];                        // Obtine el caracter i

    if( isc_end(c)  )                         // Si el caracter puede ser fin de oración
      {
      switch( c )
        {
        case '\r': case '\n':                       // Cambio de linea.
          {
          long j = i+1;                             // Indice temporal
          if( c=='\r' && m_Txt[j]=='\n' )           // Car return, seguido de New line
            ++j;                                    // Salta el new line

          if( c=='\n' && m_Txt[j]=='\r' )           // New line, seguido de Car return
            ++j;                                    // Salta el Car return
        
          for(; m_Txt[j] && m_Txt[j]<=' '; ++j )    // Espacios y caracteres especiales
            {
            if( m_Txt[j]=='\n' || m_Txt[j]=='\r' )  // Linea vacia
              goto Termina;                         // Corta
            }

          if( isc_up(m_Txt[j]) )                    // Proxima letra mayuscula
            goto Termina;                           // Corta

          CStringA s;
          if( IsBullet(j, j, s) )                   // Es un Bullet
            goto Termina;                           // Corta

          Ora += ' ';                               // Espacio para separar palabras

          i = j-1;                                  // Salta los caracteres
          continue;                                 // Continua con resto de la oración
          }

        case '\t':                                // Tab
          goto Termina;                           // Siempre corta la oración

        case ':':
          if( isFile( i, Ora) )                   // Nombre de fichero o URL
            continue ;                            // Lo toma
          goto Termina;                           // Corta

        case '.':
          {
          if( isc_up(m_Txt[i-1]) &&               // Antecedido de mayuscula
              isc_up(m_Txt[i+1])  )               // Seguido de mayuscula
            break;                                // Lo toma       

          if( IsExt(i+1) || IsAbr(i-1) )          // Si es una extension o abreviatura
            break;                                // Lo toma

          long j = i+1 ;
          for( ; m_Txt[j]==' '; ++j ) {};            // Salta espacios

          if( isc_up(m_Txt[j])     ||             // Le sigue mayuscula
             !isc_alfanum(m_Txt[j]) )             // Le sigue no alfanumerico
            goto Termina;                         // Rompe.

          break;                                  // En otro caso lo toma
          }

        case '!':
          if( Ora.GetLength()==0  )               // Es el primer caracter
            break;                                // Siempre lo toma
                                                  // Sigue para abajo
        case '?':
          Ora += m_Txt[i++];                      // Lo toma y despues termina
          goto Termina;                       

        case '¿':
          if( Ora.GetLength()==0  )               // Es el primer caracter
            break;                                // Lo toma

          goto Termina;                           // En otro caso, corta
          
        case '”':
        case '"':
          {
          if( Ora.GetLength()==0  )               // Es el primer caracter
            break;                                // Siempre lo toma

          int j = (int)(i+1);
          while( j<m_len && m_Txt[j] == ' ') ++j;   // Salta espacios
          if( !isc_alfanum(m_Txt[j]) )              // Seguido de no alfanumerico
            {
            Ora += m_Txt[i++];                  // Lo toma y despues termina
            goto Termina;                       
            }
          break;                                // Lo toma y sigue
          }

        case '`':
          c = '\'';                             // Sustituye el tipo de comilla
          break;                                // Y la toma siempre

        default:                                // Siempre es fin de oración
          goto Termina;                         // Corta
        } // end switch
      } // end if

    Ora += c;                                   // Agrega caracter a la oración
    } // end for

Termina:;
  AddItem( 't', Ora );                          // Adiciona oración a la lista de items

  _i = i;                                       // Pone el puntero al final de la oracion
  return true;
  }

/*------------------------------------------------------------------------------------*/
// Determina si la palabra que sigue al punto es una de las exteniones mas conocidas
// para nombres de ficheros
//<!----------------------------------------------------------------------------------->
bool CParseText::IsExt(long i)
  {
  int j= (int)i;
  for(; isc_alfa(m_Txt[j]); ++j ) {};                   // Salta caracteres
  if( j==i )                                            // No encontor ninguno
    return false;                                       // Retorna no extension

  static const char *Exts = "|net|com|gob|doc|txt|es|mx|htm|html|exe|dll|xml|rtf|bmp|jpe|zip|"
                      "|psd|pdf|rar|reg|mp|avi|dat|ttf|hlp|gid|sys|cfg|gif|pnp|wmf|wmv|"
                      "|wma|asf|mid|dwg|pdf|mht|ini|bad|log|tmp|drv|ocx|inf|";

  CStringA sExt = '|' + CStringA(m_Txt+i, j-(int)i) + '|';   // Forma palabar para buscar
  sExt.MakeLower();
  //_strlwr( (LPSTR)(LPCSTR)sExt );
  
  if( strstr(Exts, CS2SZ(sExt)) )                              // Busca en lista de extensiones
    return true;                                        // Retorna no extension
 
  return false;                                         // Retorna no extension
  }

/*------------------------------------------------------------------------------------*/
// Trata de determinar si la palabra que antecede al punto es una abreviatura, o no.
//<!----------------------------------------------------------------------------------->
bool CParseText::IsAbr(long i)
  {
  int j= (int)i;
  for( ; j>0 && isc_alfa(m_Txt[j]); --j ){};          // Salta caracteres hacia atras
  if( j==i )                                          // No encontro nada
    return false;                                     // Retorna no abreviatura

  if( j==0 )                                          // Es una sola palabra
    return true;                                      // No corta

  if( j+1 == i && m_Txt[j]=='.' )                     // Si es X.X.X. ó x.x.x
    return true;                                      // Retorna no extension

  if( i-j < 5 && isc_up(m_Txt[j+1]) )                 // Cortica y comienza en mayuscula
    {                                                 // Ej: Xxx.
    for( int k=j+2; k<i; ++k )                        // Para los demas caracteres
      if( isc_up(m_Txt[k]) )                          // Es mayuscula
        return false;                                 // No es abreviatura

    return true;                                      // Es abreviatura
    }

  while( j>0 && m_Txt[j] <= ' ')                     // Salta tarecos hacia atras
    --j;

  if( m_Txt[j]=='(' || m_Txt[j]=='{'  || m_Txt[j]=='[' || // Caracter de agrupamiento
      m_Txt[j]=='"' || m_Txt[j]=='“'  )                   // Ej: ( xxxx. ó "xxxxx.
    return true;                                          // Retorna si abreviatura

  return false;                                           // Retorna no extension
  }

/*------------------------------------------------------------------------------------*/
// Analiza el texto 'Text' a partir del caracter 'i', determina si es un numerado con
// uno de los siguientes formatos:
//    Romano  - Ej: I- II- III- ó I. II. III. ó I) II) III) ó I)- II)- III)- 
//              Ej: i- ii- iii- ó i. ii. iii. ó i) ii) iii) ó i)- ii)- iii)- 
//    Numero  - Ej: 1- 2- 3- ó 1. 2. 3. ó 1) 2) 3) ó 1)- 2)- 3)- 
//    Letra   - Ej: a- b- c- ó a. b. c. ó a) b) c) ó a)- b)- c)- 
//
// Si es este el caso, pone los caracteres en la cadena 'Cascara', avanza i y retorna
// true, en otro caso retorna false sin hacer nada.
//<!----------------------------------------------------------------------------------->
bool CParseText::IsBullet(long ini, long& i, CStringA& Cascara)
  {
  bool num = false;
  long   j = ini;

  while( m_Txt[j]=='I' || m_Txt[j]=='V' || m_Txt[j]=='X' )      // Romanos mayusculas
    ++j;

  if( j == ini)                                                 // No ha encontrado nada
    while( m_Txt[j]=='i' || m_Txt[j]=='v' || m_Txt[j]=='x' )    // Romanos minusculas
      ++j;

  if( j == ini)                                     // No ha encontrado nada
    while( isc_num(m_Txt[j]) )                      // Numeros 
      { 
      ++j; 
      if( m_Txt[j]=='.' && isc_num(m_Txt[j+1]) )    // Si 2.1 ...
        { j+=2; num = true; }                       // Salta el punto y num.
      }

  if( j == ini)                                     // No ha encontrado nada        
    j = i + 1;                                      // Salta caracter actual
  
  int skip = 0;
  CStringA sTag;       

  if( !skip && (m_Txt[j]=='-' || m_Txt[j]=='.' ||   // Seguido de - ó .
                m_Txt[j]==')' || m_Txt[j]==':') )   // Seguido de ) ó :
    {
    ++j;

    if( m_Txt[j]=='-' ) ++j;                        // Opcionalmente - Ej a)- i.- a:-    

    if( m_Txt[j]==' ' )                             // Seguido de espacio
      skip = 1;
    }

  if( !skip && num && m_Txt[j]==' ' )               // Numero seguido de espacio
    skip = 1;

  if( !skip && m_Txt[j]=='\t' )                     // Seguido de tab normal
    skip = 1;

  if( skip )                                        // Es un bullet o numerando
    {
    j += skip;
    Cascara += CStringA( m_Txt+ini, (int)(j-ini));    // Lo mete en la cascara

    i = j-1;                                        // Actualiza el puntero
    return true;
    }

  return false;                                     // No complio con el formato
  }

/*------------------------------------------------------------------------------------*/
// Adiciona un item a la lista
//<!----------------------------------------------------------------------------------->
bool CParseText::AddItem(BYTE Type, const CStringA& Text)
  {
  if (Text.GetLength() == 0)
  //if( !Text || Text[0]==NULL )
    return false;

  CStringA Txt = Text;

  m_Items.Add( new CItem(Txt,Type) );

  return true;
  }

#define mytolower(ch)  (((ch) >= 'a' && (ch) <= 'z') ? (ch) : (ch) - ('a' - 'A'))  
/*------------------------------------------------------------------------------------*/
// Funcion parecida a la _strnicmp, que se implementa aqui porque no existe en Symbian
//<!----------------------------------------------------------------------------------->
TInt _strnicmp_0(const char* s1, const char* s2, TInt len)
	{
	for(TInt i=0; i<len; i++)
		{
		char ch1 = mytolower(s1[i]);
		char ch2 = mytolower(s2[i]);
		if (ch1 == 0 || ch2 == 0 || ch1 != ch2)
			return 1;
		}
	
	return 0;
	}

/*------------------------------------------------------------------------------------*/
// Determina si es un nombre de fichero o un URL
//<!----------------------------------------------------------------------------------->
bool CParseText::isFile( long& _i, CStringA& Ora)
  {
  int i = (int)_i;
  if( (i>2 && !isc_alfanum(m_Txt[i-2]) && isc_alfa(m_Txt[i-1]) ) || // A:\ ...
      (m_len>4 && _strnicmp_0(m_Txt+i-4, "file", 4) == 0  )      ||      // file: ...
      (m_len>4 && _strnicmp_0(m_Txt+i-4, "http", 4) == 0  )      ||      // http: ...
      (m_len>3 && _strnicmp_0(m_Txt+i-3, "ftp" , 3) == 0  )      )       //  ftp: ...
    {
    ++i;                         // Salta el : 

    // Solo seguido de numero, letra o slat o backslat
    if( !isc_alfanum(m_Txt[i]) && m_Txt[i]!='\\' && m_Txt[i]!='/' )
      return false;
  
    // Toma el resto del nombre del fichero
    for( ;i<m_len; ++i )
      {
      if( isc_alfanum(m_Txt[i]) )
        continue;

      if( m_Txt[i]=='\\' || m_Txt[i]=='/' )
        continue;

      // El punto solo si esta entre letras o numeros
      if( m_Txt[i]=='.' && isc_alfanum(m_Txt[i-1]) && isc_alfanum(m_Txt[i+1]) )
        continue;

      break;
      }

    Ora += CStringA( m_Txt+_i, i-(int)_i);    // Coje el nombre de fichero
    _i = i-1;
    return true;
    }

  return false;
  }

/*------------------------------------------------------------------------------------*/
//<!----------------------------------------------------------------------------------->

