#import "import.h"

#include <stdint.h>

/*
 *  (c) 2021 nat Mulle kybernetiK
 *
 *  version:  major, minor, patch
 */
#define MULLE_UI_VERSION  ((0 << 20) | (7 << 8) | 56)


static inline unsigned int   MulleUI_get_version_major( void)
{
   return( MULLE_UI_VERSION >> 20);
}


static inline unsigned int   MulleUI_get_version_minor( void)
{
   return( (MULLE_UI_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   MulleUI_get_version_patch( void)
{
   return( MULLE_UI_VERSION & 0xFF);
}


extern uint32_t   MulleUI_get_version( void);

/*
   Add your library headers here for exposure to library
   consumers.
*/

#import "_MulleUIWidgetsBase-export.h"

#include "_MulleUIWidgetsBase-provide.h"
