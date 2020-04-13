/* $Id$ */
/* Copyright (c) 2016 Pierre Pronchery <khorben@defora.org> */
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
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <System/variable.h>
#include "System/Marshall.h"

#ifndef PROGNAME
# define PROGNAME	"callfn"
#endif


/* private */
/* prototypes */
static int32_t _callfn(int32_t count, float arg1, float arg2, float arg3,
		float arg4, float arg5, float arg6, float arg7,
		float arg8, float arg9, float arg10, float arg11,
		float arg12);


/* functions */
/* callfn */
static int32_t _callfn_check(int32_t count, int32_t pos, float * arg);

static int32_t _callfn(int32_t count, float arg1, float arg2, float arg3,
		float arg4, float arg5, float arg6, float arg7,
		float arg8, float arg9, float arg10, float arg11,
		float arg12)
{
	int32_t ret = 0;

	fprintf(stderr, "%s: %s(%d)\n", PROGNAME, __func__, count);
	ret |= _callfn_check(count, 1, &arg1);
	ret |= _callfn_check(count, 2, &arg2);
	ret |= _callfn_check(count, 3, &arg3);
	ret |= _callfn_check(count, 4, &arg4);
	ret |= _callfn_check(count, 5, &arg5);
	ret |= _callfn_check(count, 6, &arg6);
	ret |= _callfn_check(count, 7, &arg7);
	ret |= _callfn_check(count, 8, &arg8);
	ret |= _callfn_check(count, 9, &arg9);
	ret |= _callfn_check(count, 10, &arg10);
	ret |= _callfn_check(count, 11, &arg11);
	ret |= _callfn_check(count, 12, &arg12);
	return ret;
}

static int32_t _callfn_check(int32_t count, int32_t pos, float * arg)
{
	float flow = 1111.0;
	float fhigh = 1111.2;

	if(pos <= count)
	{
		fprintf(stderr, "%d: %f\n", count, *arg);
		flow = flow * pos;
		fhigh = fhigh * pos;
		return (flow < (*arg) && fhigh > (*arg)) ? 0 : 1;
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
	const size_t count = 13;
	Variable ** args;
	int32_t i32;
	float f;
	Variable * res;

	i32 = 0;
	if((res = variable_new(VT_INT32, &i32)) == NULL)
		return 2;
	if((args = malloc(sizeof(*args) * count)) == NULL)
	{
		variable_delete(res);
		return 2;
	}
	for(i = 0; i < count; i++)
	{
		f = 1111.1;
		f = f * i;
		if((args[i] = variable_new(VT_FLOAT, &f)) == NULL)
			ret = 3;
	}
	for(i = 0; ret == 0 && i < count; i++)
	{
		i32 = i;
		if(variable_set_from(args[0], VT_INT32, &i32) != 0)
			ret = i + 4;
		else if(marshall_callp(res, (MarshallCall)_callfn, i + 1,
					args) != 0)
			ret = i + 4;
		else if(variable_get_as(res, VT_INT32, &i32) != 0 || i32 != 0)
			ret = i + 4;
	}
	for(i = 0; i < count; i++)
		if(args[i] != NULL)
			variable_delete(args[i]);
	variable_delete(res);
	free(args);
	return ret;
}
