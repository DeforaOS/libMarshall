/* $Id$ */
/* Copyright (c) 2020 Pierre Pronchery <khorben@defora.org> */
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



#include "System/Marshall.h"


/* MarshallCall */
/* public */
/* functions */
/* marshall_call */
int marshall_call(Variable * res, MarshallCall call,
		size_t args_cnt, ...)
{
	int ret;
	va_list ap;

	va_start(ap, args_cnt);
	ret = marshall_callv(res, call, args_cnt, ap);
	va_end(ap);
	return ret;
}


/* marshall_callv */
int marshall_callv(Variable * res, MarshallCall call,
		size_t args_cnt, va_list ap)
{
	int ret;
	Variable ** args;
	size_t i;

	if(args_cnt == 0)
		args = NULL;
	else if((args = object_new(sizeof(*args) * args_cnt)) == NULL)
		return -1;
	for(i = 0; i < args_cnt; i++)
		args[i] = va_arg(ap, Variable *);
	ret = marshall_callp(res, call, args_cnt, args);
	object_delete(args);
	return ret;
}


/* marshall_call_direction */
int marshall_call_direction(Variable * res, MarshallCall call,
		size_t args_cnt, ...)
{
	int ret;
	va_list ap;

	va_start(ap, args_cnt);
	ret = marshall_call_directionv(res, call, args_cnt, ap);
	va_end(ap);
	return ret;
}


/* marshall_call_directionv */
int marshall_call_directionv(Variable * res, MarshallCall call,
		size_t args_cnt, va_list ap)
{
	int ret;
	MarshallCallDirection * direction;
	Variable ** args;
	size_t i;

	if(args_cnt == 0)
	{
		direction = NULL;
		args = NULL;
	}
	else
	{
		direction = object_new(sizeof(*direction) * args_cnt);
		args = object_new(sizeof(*args) * args_cnt);
		if(direction == NULL || args == NULL)
		{
			object_delete(args);
			object_delete(direction);
			return -1;
		}
	}
	for(i = 0; i < args_cnt; i++)
	{
		direction[i] = va_arg(ap, MarshallCallDirection);
		args[i] = va_arg(ap, Variable *);
	}
	ret = marshall_call_directionp(res, call, args_cnt, direction, args);
	object_delete(args);
	object_delete(direction);
	return ret;
}
