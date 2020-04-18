/* $Id$ */
/* Copyright (c) 2016-2020 Pierre Pronchery <khorben@defora.org> */
/* This file is part of DeforaOS System libMarshall */
/* All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */



#ifndef ARCH_COMMON_H
# define ARCH_COMMON_H


/* macros */
# if defined(__APPLE__)	/* macOS */
#  define SYMBOL(name)	_ ## name
#  define FUNC(name)	_ ## name
# else
#  define SYMBOL(name)	name
#  if defined(__PIC__)
#  define FUNC(name)	name@PLT
#  else
#  define FUNC(name)	name
#  endif
# endif


/* constants */
#define NULL		$0x0

#define VT_NULL		$0x0
#define VT_BOOL		$0x1
#define VT_INT8		$0x2
#define VT_UINT8	$0x3
#define VT_INT16	$0x4
#define VT_UINT16	$0x5
#define VT_INT32	$0x6
#define VT_UINT32	$0x7
#define VT_INT64	$0x8
#define VT_UINT64	$0x9
#define VT_FLOAT	$0xa
#define VT_DOUBLE	$0xb
#define VT_BUFFER	$0xc
#define VT_STRING	$0xd
#define VT_ARRAY	$0xe
#define VT_COMPOUND	$0xf

#endif /* !ARCH_COMMON_H */
