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
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "System/Marshall.h"

#ifndef PROGNAME
# define PROGNAME	"calls"
#endif


/* private */
/* prototypes */
static String const * _calls(String const * str);


/* functions */
/* calls */
static String const * _calls(String const * str)
{
	fprintf(stderr, "%s: %s(\"%s\")\n", PROGNAME, __func__, str);
	return str;
}


/* public */
/* functions */
/* main */
int main(void)
{
	int ret;
	Variable * res;
	char const * str = "Test string";
	char * p = NULL;

	/* VT_STRING */
	if((res = variable_new(VT_STRING, str)) == NULL)
		return 2;
	if((ret = marshall_callp(res, (MarshallCall)_calls, 1, &res)) == 0)
		ret = variable_get_as(res, VT_STRING, &p);
	variable_delete(res);
	if(ret != 0)
		ret = 3;
	else if(strcmp(str, p) == 0)
		ret = 0;
	else
		ret = 4;
	string_delete(p);
	return ret;
}
