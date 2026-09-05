//
//  MulleUICore.h
//  MulleUICore
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import.h"

#include <stdint.h>

/*
 *  (c) 2021 nat Mulle kybernetiK
 *
 *  version:  major, minor, patch
 */
#define MULLE_UI_CORE_VERSION  ((0 << 20) | (1 << 8) | 0)


static inline unsigned int   MulleUI_get_version_major( void)
{
   return( MULLE_UI_CORE_VERSION >> 20);
}


static inline unsigned int   MulleUI_get_version_minor( void)
{
   return( (MULLE_UI_CORE_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   MulleUI_get_version_patch( void)
{
   return( MULLE_UI_CORE_VERSION & 0xFF);
}


MULLE_UI_CORE_GLOBAL
uint32_t   MulleUICore_get_version( void);

/*
   Add your library headers here for exposure to library
   consumers.
*/

#import "_MulleUICore-export.h"

#include "_MulleUICore-provide.h"
