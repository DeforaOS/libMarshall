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



#include "../common.h"


.type marshall_call,@function
marshall_call:
	push	%ebp
	mov	%esp, %ebp
	sub	$0x14, %esp			/* VariableType type */
						/* uint64_t res */
	movl	$0x0, -0x4(%ebp)		/* type = 0 */
	movl	$0x0, -0xc(%ebp)		/* args_pos = 0 */
	movl	$0x0, -0x10(%ebp)		/* offset = 0 */
type:
	/* get the return type */
	cmpl	NULL, 0x8(%ebp)
	je	type_done
	pushl	0x8(%ebp)
	call	variable_get_type		/* variable_get_type(res) */
	add	$0x4, %esp
	mov	%eax, -0x4(%ebp)
type_done:
args:
	mov	0x10(%ebp), %eax
	mov	-0xc(%ebp), %edx
	cmp	%eax, %edx			/* if(args_pos == args_cnt) */
	je	args_done			/*	goto args_done */
	jg	args_error			/* else if(args_pos > args_cnt)
							goto error */
args_type:
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0xc(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	variable_get_type		/* variable_get_type(eax) */
	add	$0x4, %esp
	cmp	VT_NULL, %eax
	je	args_done
	cmp	VT_UINT32, %eax
	jle	args_INTEGER
	cmp	VT_UINT64, %eax
	/* FIXME implement */
	jle	args_error
	cmp	VT_DOUBLE, %eax
	jle	args_DOUBLE
	cmp	VT_STRING, %eax
	jle	args_INTEGER
	/* FIXME implement more types */
	jmp	args_error
args_INTEGER:
	lea	-0x8(%ebp), %edx
	push	%edx
	push	%eax
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0xc(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	variable_get_as			/* variable_get_as() */
						/* XXX memory leak */
	add	$0xc, %esp
	cmp	$0x0, %eax
	jne	args_error
	/* FIXME push in reverse order instead */
	push	-0x8(%ebp)
	addl	$0x4, -0x10(%ebp)		/* offset += 4 */
	jmp	args_loop
args_DOUBLE:
	lea	-0xc(%ebp), %edx
	push	%edx
	push	%eax
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0xc(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	variable_get_as			/* variable_get_as() */
						/* XXX memory leak */
	add	$0xc, %esp
	cmp	$0x0, %eax
	jne	args_error
	fld	-0xc(%ebp)
	jmp	args_loop
args_loop:
	incl	-0xc(%ebp)			/* args_pos++ */
	jmp	args
args_error:
	addl	-0x10(%ebp), %esp		/* esp += offset */
	jmp	error
args_done:
call:
	/* call the function */
	mov	0xc(%ebp), %eax
	call	*%eax
	add	-0x10(%ebp), %esp
call_done:
return:
	/* report the value returned */
	cmpl	VT_NULL, -0x4(%ebp)
	je	return_NULL
	cmpl	VT_UINT32, -0x4(%ebp)
	jle	return_INTEGER
	cmpl	VT_UINT64, -0x4(%ebp)
	jle	return_INTEGER64
	cmpl	VT_DOUBLE, -0x4(%ebp)
	jle	return_DOUBLE
	cmpl	VT_STRING, -0x4(%ebp)		/* XXX free the result */
	je	return_POINTER
	jmp	error
return_NULL:
	jmp	return_done
return_INTEGER:
	mov	%eax, -0x8(%ebp)
	lea	-0x8(%ebp), %eax		/* &value */
	push	%eax
	pushl	-0x4(%ebp)			/* VariableType type */
	pushl	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_INTEGER64:
	mov	%edx, -0x8(%ebp)
	mov	%eax, -0xc(%ebp)
	lea	-0xc(%ebp), %eax		/* &value */
	push	%eax
	pushl	-0x4(%ebp)			/* VariableType type */
	pushl	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_DOUBLE:
	fst	-0xc(%ebp)
	lea	-0xc(%ebp), %eax
	push	%eax
	pushl	-0x4(%ebp)			/* VariableType type */
	push	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_POINTER:
	push	%eax				/* void * value */
	pushl	-0x4(%ebp)			/* VariableType type */
	pushl	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_variable_set_from:
	call	variable_set_from
	add	$0xc, %esp
	cmp	$0x0, %eax
	jne	error
return_done:
	mov	$0x0, %eax			/* return 0 */
	jmp	ret
error:
	mov	$-1, %eax			/* return -1 */
ret:
	mov	%ebp, %esp
	pop	%ebp
	ret
