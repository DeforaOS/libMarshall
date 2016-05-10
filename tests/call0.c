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



#include <stdio.h>
#include <string.h>
#include "System/Marshall.h"

#ifndef PROGNAME
# define PROGNAME	"call0"
#endif


/* private */
/* prototypes */
static int _call0_int32(void);
static char const * _call0_string(void);


/* functions */
/* call0_int32 */
static int _call0_int32(void)
{
	int ret = 0x41424344;

	fprintf(stderr, "%s: %s() => 0x%08x\n", PROGNAME, __func__, ret);
	return ret;
}


/* call0_string */
static char const * _call0_string(void)
{
	static char ret[] = "_call0_string";

	fprintf(stderr, "%s: %s() => \"%s\"\n", PROGNAME, __func__, ret);
	return ret;
}


/* public */
/* functions */
/* main */
int main(void)
{
	int ret;
	Variable * res;
	int32_t r = -1;
	char * s;

	if((res = variable_new(VT_INT32, &r)) == NULL)
		return 2;
	if((ret = marshall_call(res, (MarshallCallback)_call0_int32, 0, NULL))
			== 0)
		ret = variable_get_as(res, VT_INT32, &r);
	variable_delete(res);
	if(ret != 0 || r != 0x41424344)
		return 3;
	if((res = variable_new(VT_STRING, "")) == NULL)
		return 4;
	if((ret = marshall_call(res, (MarshallCallback)_call0_string, 0, NULL))
			== 0)
		ret = variable_get_as(res, VT_STRING, &s);
	variable_delete(res);
	if(ret != 0)
		return 5;
	if(strcmp(s, "_call0_string") != 0)
		return 6;
	return 0;
}
