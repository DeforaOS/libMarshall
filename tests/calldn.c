/* $Id$ */
/* Copyright (c) 2016-2022 Pierre Pronchery <khorben@defora.org> */
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
# define PROGNAME	"calldn"
#endif


/* private */
/* prototypes */
static uint32_t _calldn(int32_t count, double arg1, double arg2, double arg3,
		double arg4, double arg5, double arg6, double arg7,
		double arg8, double arg9, double arg10, double arg11,
		double arg12);


/* functions */
/* calldn */
static uint32_t _calldn_check(int32_t count, int32_t pos, double * arg);

static uint32_t _calldn(int32_t count, double arg1, double arg2, double arg3,
		double arg4, double arg5, double arg6, double arg7,
		double arg8, double arg9, double arg10, double arg11,
		double arg12)
{
	uint32_t ret = 0;

	fprintf(stderr, "%s: %s(%d)\n", PROGNAME, __func__, count);
	ret |= _calldn_check(count, 1, &arg1);
	ret |= _calldn_check(count, 2, &arg2);
	ret |= _calldn_check(count, 3, &arg3);
	ret |= _calldn_check(count, 4, &arg4);
	ret |= _calldn_check(count, 5, &arg5);
	ret |= _calldn_check(count, 6, &arg6);
	ret |= _calldn_check(count, 7, &arg7);
	ret |= _calldn_check(count, 8, &arg8);
	ret |= _calldn_check(count, 9, &arg9);
	ret |= _calldn_check(count, 10, &arg10);
	ret |= _calldn_check(count, 11, &arg11);
	ret |= _calldn_check(count, 12, &arg12);
	return ret;
}

static uint32_t _calldn_check(int32_t count, int32_t pos, double * arg)
{
	double d = 1111.1;

	if(pos <= count)
	{
		d = d * pos;
		fprintf(stderr, "%d: %f (expected: %f)\n", count, *arg, d);
		return (d == (*arg)) ? 0 : (1 << pos);
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
	uint32_t u32;
	double d;
	Variable * res;

	if((res = variable_new(VT_UINT32, 0)) == NULL)
		return 2;
	if((args = malloc(sizeof(*args) * count)) == NULL)
	{
		variable_delete(res);
		return 3;
	}
	if((args[0] = variable_new(VT_INT32, 0)) == NULL)
		ret = 4;
	for(i = 1; i < count; i++)
	{
		d = 1111.1 * i;
		if((args[i] = variable_new(VT_DOUBLE, d)) == NULL)
			ret = 5;
	}
	for(i = 0; ret == 0 && i < count; i++)
	{
		if(variable_set(args[0], (int32_t)i) != 0)
			ret = 6 + (i * 3);
		else if(marshall_callp(res, (MarshallCall)_calldn, i + 1,
					args) != 0)
			ret = 7 + (i * 3);
		else if(variable_get_as(res, VT_UINT32, &u32, NULL) != 0 || u32 != 0)
			ret = 8 + (i * 3);
	}
	for(i = 0; i < count; i++)
		if(args[i] != NULL)
			variable_delete(args[i]);
	variable_delete(res);
	free(args);
	return ret;
}
