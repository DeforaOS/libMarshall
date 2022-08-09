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



#include <unistd.h>
#include <stdlib.h>
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
static int _runso(char const * filename, char const * method, int argc,
		char ** argv);
static int _runso_list(char const * filename);

static int _error(char const * error, int ret);
static int _usage(void);


/* functions */
/* runso */
static int _runso_callback(char const * method, MarshallCall callback,
		int argc, char ** argv);

static int _runso(char const * filename, char const * method, int argc,
		char ** argv)
{
	int ret = 0;
	void * handler;
	MarshallCall callback;

	if((handler = dlopen(filename, RTLD_LAZY)) == NULL)
		return _error(dlerror(), -1);
	if((callback = dlsym(handler, method)) == NULL)
		ret = _error(dlerror(), -1);
	else
		ret = _runso_callback(method, callback, argc, argv);
	dlclose(handler);
	return ret;
}

static int _runso_callback(char const * method, MarshallCall callback,
		int argc, char ** argv)
{
	int ret = 0;
	Variable ** args;
	Variable * v;
	int i;
	int32_t i32;

	if((args = malloc(sizeof(*args) * argc)) == NULL)
		return _error(strerror(errno), -errno);
	for(i = 0; i < argc; i++)
		if((args[i] = variable_new(VT_STRING, argv[i])) == NULL)
			ret = -_error(error_get(NULL), 1);
	if((v = variable_new(VT_INT32, &i32)) == NULL)
		ret = -_error(error_get(NULL), 1);
	if(ret == 0 && marshall_callp(v, callback, argc, args) != 0)
		ret = -_error(error_get(NULL), 1);
	else if(variable_get_as(v, VT_INT32, &i32, NULL) != 0)
		ret = _error(error_get(NULL), -1);
	else
		printf("%s: %s returned %d\n", PROGNAME, method, i32);
	if(v != NULL)
		variable_delete(v);
	for(i = 0; i < argc; i++)
		if(args[i] != NULL)
			variable_delete(args[i]);
	free(args);
	return ret;
}


/* runso_list */
static int _runso_list(char const * filename)
{
	/* FIXME implement */
	return -1;
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
	fputs("Usage: " PROGNAME " filename method [arguments...]\n"
"       " PROGNAME " -l filename\n"
"       " PROGNAME " -s method [arguments...]\n"
"  -l	List the methods available\n"
"  -s	Look for callbacks inside " PROGNAME " itself\n", stderr);
	return 1;
}


/* public */
/* functions */
/* main */
int main(int argc, char * argv[])
{
	int ret = 0;
	int o;
	int list = 0;
	int self = 0;
	char const * filename;
	char const * method;

	while((o = getopt(argc, argv, "ls")) != -1)
		switch(o)
		{
			case 'l':
				list = 1;
				self = 0;
				break;
			case 's':
				list = 0;
				self = 1;
				break;
			default:
				return _usage();
		}
	/* check usage accordingly */
	if(list != 0 && optind + 1 == argc)
	{
		if(_runso_list(argv[optind]) != 0)
			ret = 2;
	}
	else if(list == 0 && optind < argc)
	{
		if(self)
			filename = NULL;
		else
			filename = argv[optind++];
		method = argv[optind++];
		if(_runso(filename, method, argc - optind, &argv[optind]) != 0)
			ret = 2;
	}
	else
		return _usage();
	return ret;
}
