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
# define PROGNAME	"callf"
#endif


/* private */
/* prototypes */
static double _callf_double(void);
static float _callf_float(void);


/* functions */
/* callf_double */
static double _callf_double(void)
{
	double ret = M_PI;

	fprintf(stderr, "%s: %s() => %f\n", PROGNAME, __func__, ret);
	return ret;
}


/* callf_float */
static float _callf_float(void)
{
	float ret = M_PI;

	fprintf(stderr, "%s: %s() => %f\n", PROGNAME, __func__, ret);
	return ret;
}


/* public */
/* functions */
/* main */
int main(void)
{
	int ret;
	Variable * res;
	float f = 0.0;
	double d = 0.0;

	/* VT_FLOAT */
	if((res = variable_new(VT_FLOAT, &f)) == NULL)
		return 2;
	if((ret = marshall_call(res, (MarshallCallback)_callf_float, 0, NULL))
			== 0)
		ret = variable_get_as(res, VT_FLOAT, &f);
	variable_delete(res);
	if(ret != 0)
		return 3;
	if(f != (float)M_PI)
		return 4;
	/* VT_DOUBLE */
	if((res = variable_new(VT_DOUBLE, &d)) == NULL)
		return 5;
	if((ret = marshall_call(res, (MarshallCallback)_callf_double, 0, NULL))
			== 0)
		ret = variable_get_as(res, VT_DOUBLE, &d);
	variable_delete(res);
	if(ret != 0)
		return 6;
	if(d != M_PI)
		return 7;
	return 0;
}
