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



#ifndef LIBMARSHALL_SYSTEM_MARSHALL_H
# define LIBMARSHALL_SYSTEM_MARSHALL_H

# include <stdarg.h>
# include <System.h>


/* Marshall */
/* public */
/* types */
typedef void(*MarshallCall)(void);
typedef enum _MarshallCallDirection
{
	MCD_IN = 1,
	MCD_OUT,
	MCD_IN_OUT
} MarshallCallDirection;


/* prototypes */
int marshall_call(Variable * res, MarshallCall call,
		size_t args_cnt, ...);
int marshall_callp(Variable * res, MarshallCall call,
		size_t args_cnt, Variable ** args);
int marshall_callv(Variable * res, MarshallCall call,
		size_t args_cnt, va_list ap);

int marshall_call_direction(Variable * res, MarshallCall call,
		size_t args_cnt, ...);
int marshall_call_directionp(Variable * res, MarshallCall call, size_t args_cnt,
		MarshallCallDirection * direction, Variable ** args);
int marshall_call_directionv(Variable * res, MarshallCall call,
		size_t args_cnt, va_list ap);

#endif /* !LIBMARSHALL_SYSTEM_MARSHALL_H */
