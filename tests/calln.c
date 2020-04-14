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



#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <System/variable.h>
#include "System/Marshall.h"

#ifndef PROGNAME
# define PROGNAME	"calln"
#endif


/* private */
/* prototypes */
static int32_t _calln(int32_t count, int32_t arg1, int32_t arg2, int32_t arg3,
		int32_t arg4, int32_t arg5, int32_t arg6, int32_t arg7,
		int32_t arg8, int32_t arg9);


/* functions */
/* calln */
static int32_t _calln_check(int32_t count, int32_t pos, int32_t * arg);

static int32_t _calln(int32_t count, int32_t arg1, int32_t arg2, int32_t arg3,
		int32_t arg4, int32_t arg5, int32_t arg6, int32_t arg7,
		int32_t arg8, int32_t arg9)
{
	int32_t ret = 0;

	fprintf(stderr, "%s: %s(%d)\n", PROGNAME, __func__, count);
	ret |= _calln_check(count, 1, &arg1);
	ret |= _calln_check(count, 2, &arg2);
	ret |= _calln_check(count, 3, &arg3);
	ret |= _calln_check(count, 4, &arg4);
	ret |= _calln_check(count, 5, &arg5);
	ret |= _calln_check(count, 6, &arg6);
	ret |= _calln_check(count, 7, &arg7);
	ret |= _calln_check(count, 8, &arg8);
	ret |= _calln_check(count, 9, &arg9);
	return ret;
}

static int32_t _calln_check(int32_t count, int32_t pos, int32_t * arg)
{
	if(pos <= count)
	{
		fprintf(stderr, "%d: %d\n", count, *arg);
		return ((pos * 1111) == (*arg)) ? 0 : 1;
	}
	return 0;
}


/* public */
/* functions */
/* main */
int main(void)
{
	int ret = 0;
	size_t i;
	const size_t count = 10;
	Variable ** args;
	int32_t i32;
	Variable * res;

	i32 = 0;
	if((res = variable_new(VT_INT32, i32)) == NULL)
		return 2;
	if((args = object_new(sizeof(*args) * count)) == NULL)
	{
		variable_delete(res);
		return 2;
	}
	for(i = 0; i < count; i++)
	{
		i32 = i * 1111;
		if((args[i] = variable_new(VT_INT32, i32)) == NULL)
			ret = 3;
	}
	for(i = 0; ret == 0 && i < count; i++)
	{
		i32 = i;
		if(variable_set_type(args[0], VT_INT32, i32) != 0)
			ret = i + 4;
		else if(marshall_callp(res, (MarshallCall)_calln, i + 1,
					args) != 0)
			ret = i + 4;
		else if(variable_get_as(res, VT_INT32, &i32) != 0 || i32 != 0)
			ret = i + 4;
	}
	for(i = 0; i < count; i++)
		if(args[i] != NULL)
			variable_delete(args[i]);
	variable_delete(res);
	object_delete(args);
	return ret;
}
