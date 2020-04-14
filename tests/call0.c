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
#include "System/Marshall.h"

#ifndef PROGNAME
# define PROGNAME	"call0"
#endif


/* private */
/* prototypes */
static double _call0_double(void);
static float _call0_float(void);
static int32_t _call0_int32(void);
static int64_t _call0_int64(void);
static char const * _call0_string(void);


/* functions */
static double _call0_double(void)
{
	double ret = 1.234567e89;

	fprintf(stderr, "%s: %s() => %f\n", PROGNAME, __func__, ret);
	return ret;
}


/* call0_float */
static float _call0_float(void)
{
	float ret = 1.234e5;

	fprintf(stderr, "%s: %s() => %f\n", PROGNAME, __func__, ret);
	return ret;
}


/* call0_int32 */
static int32_t _call0_int32(void)
{
	int32_t ret = 0x41424344;

	fprintf(stderr, "%s: %s() => 0x%08" PRIx32 "\n", PROGNAME, __func__,
			ret);
	return ret;
}


/* call0_int64 */
static int64_t _call0_int64(void)
{
	int64_t ret = 0x4142434445464748;

	fprintf(stderr, "%s: %s() => 0x%016" PRIx64 "\n", PROGNAME, __func__,
			ret);
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
	double d = -1.0;
	float f = -1.0;
	int32_t r32 = -1;
	int64_t r64 = -1;
	char * s;

	/* VT_INT32 */
	if((res = variable_new(VT_INT32, r32)) == NULL)
		return 2;
	if((ret = marshall_call(res, (MarshallCall)_call0_int32, 0)) == 0)
		ret = variable_get_as(res, VT_INT32, &r32);
	variable_delete(res);
	if(ret != 0)
		return 3;
	if(r32 != 0x41424344)
		return 4;
	/* VT_INT64 */
	if((res = variable_new(VT_INT64, r64)) == NULL)
		return 5;
	if((ret = marshall_call(res, (MarshallCall)_call0_int64, 0)) == 0)
		ret = variable_get_as(res, VT_INT64, &r64);
	variable_delete(res);
	if(ret != 0)
		return 6;
	if(r64 != 0x4142434445464748)
		return 7;
	/* VT_DOUBLE */
	if((res = variable_new(VT_DOUBLE, d)) == NULL)
		return 8;
	if((ret = marshall_call(res, (MarshallCall)_call0_double, 0)) == 0)
		ret = variable_get_as(res, VT_DOUBLE, &d);
	variable_delete(res);
	if(ret != 0)
		return 9;
	if(d != 1.234567e89)
		return 10;
	/* VT_FLOAT */
	if((res = variable_new(VT_FLOAT, f)) == NULL)
		return 11;
	if((ret = marshall_call(res, (MarshallCall)_call0_float, 0)) == 0)
		ret = variable_get_as(res, VT_FLOAT, &f);
	variable_delete(res);
	if(ret != 0)
		return 12;
	if(f != 1.234e5)
		return 13;
	/* VT_STRING */
	if((res = variable_new(VT_STRING, "")) == NULL)
		return 14;
	if((ret = marshall_call(res, (MarshallCall)_call0_string, 0)) == 0)
		ret = variable_get_as(res, VT_STRING, &s);
	variable_delete(res);
	if(ret != 0)
		return 15;
	if(strcmp(s, "_call0_string") != 0)
		return 16;
	return 0;
}
