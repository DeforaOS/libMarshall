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
# define PROGNAME	"calln"
#endif


/* private */
/* prototypes */
static void _calln(int32_t count, int32_t arg1, int32_t arg2, int32_t arg3,
		int32_t arg4, int32_t arg5, int32_t arg6, int32_t arg7,
		int32_t arg8, int32_t arg9);


/* functions */
/* calln */
static void _calln(int32_t count, int32_t arg1, int32_t arg2, int32_t arg3,
		int32_t arg4, int32_t arg5, int32_t arg6, int32_t arg7,
		int32_t arg8, int32_t arg9)
{
	fprintf(stderr, "%s: %s(%d)\n", PROGNAME, __func__, count);
	if(count >= 1)
		fprintf(stderr, "%d: %d\n", count, arg1);
	if(count >= 2)
		fprintf(stderr, "%d: %d\n", count, arg2);
	if(count >= 3)
		fprintf(stderr, "%d: %d\n", count, arg3);
	if(count >= 4)
		fprintf(stderr, "%d: %d\n", count, arg4);
	if(count >= 5)
		fprintf(stderr, "%d: %d\n", count, arg5);
	if(count >= 6)
		fprintf(stderr, "%d: %d\n", count, arg6);
	if(count >= 7)
		fprintf(stderr, "%d: %d\n", count, arg7);
	if(count >= 8)
		fprintf(stderr, "%d: %d\n", count, arg8);
	if(count >= 9)
		fprintf(stderr, "%d: %d\n", count, arg9);
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

	if((args = malloc(sizeof(*args) * count)) == NULL)
		return 2;
	for(i = 0; i < count; i++)
	{
		i32 = i * 1111;
		if((args[i] = variable_new(VT_INT32, &i32)) == NULL)
			ret = 3;
	}
	for(i = 0; ret == 0 && i < count; i++)
	{
		i32 = i;
		if(variable_set_from(args[0], VT_INT32, &i32) != 0)
			ret = i + 4;
		else if(marshall_call(NULL, (MarshallCallback)_calln, i + 1,
					args) != 0)
			ret = i + 4;
	}
	for(i = 0; i < count; i++)
		if(args[i] != NULL)
			variable_delete(args[i]);
	free(args);
	return ret;
}
