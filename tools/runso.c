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



#include <unistd.h>
#include <stdio.h>
#if 1 /* XXX */
# include <string.h>
# include <errno.h>
#endif
#include <dlfcn.h>
#include <System/error.h>
#include "System/Marshall.h"

#define PROGNAME	"runso"


/* private */
/* prototypes */
static int _runso(char const * filename, char const * method, char ** args);

static int _error(char const * error, int ret);
static int _usage(void);


/* functions */
/* runso */
static int _runso_callback(char const * method, MarshallCallback callback,
		char ** args);

static int _runso(char const * filename, char const * method, char ** args)
{
	int ret = 0;
	void * handler;
	MarshallCallback callback;

	if((handler = dlopen(filename, RTLD_LAZY)) == NULL)
		return _error(dlerror(), -1);
	if((callback = dlsym(handler, method)) == NULL)
		ret = _error(dlerror(), -1);
	else
		ret = _runso_callback(method, callback, args);
	dlclose(handler);
	return ret;
}

static int _runso_callback(char const * method, MarshallCallback callback,
		char ** args)
{
	Variable * v;
	int32_t i32;

	if((v = variable_new(VT_INT32, &i32)) == NULL)
		return _error(error_get(NULL), -1);
	if(marshall_call(v, callback, 0, NULL) != 0)
		return _error(error_get(NULL), -1);
	else if(variable_get_as(v, VT_INT32, &i32) != 0)
		_error(error_get(NULL), -1);
	else
		printf("%s: %s returned %d\n", PROGNAME, method, i32);
	return 0;
}


/* error */
static int _error(char const * error, int ret)
{
	fprintf(stderr, "%s: %s\n", PROGNAME, error);
	return ret;
}


/* usage */
static int _usage(void)
{
	fputs("Usage: " PROGNAME " filename method [arguments...]\n", stderr);
	return 1;
}


/* public */
/* functions */
/* main */
int main(int argc, char * argv[])
{
	int o;

	while((o = getopt(argc, argv, "")) != -1)
		switch(o)
		{
			default:
				return _usage();
		}
	if(argc - optind < 2)
		return _usage();
#if 1 /* XXX */
	if(argc - optind > 2)
		return _error(strerror(ENOSYS), 2);
#endif
	if(_runso(argv[optind], argv[optind + 1], &argv[optind + 2]) != 0)
		return 2;
	return 0;
}
