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



/* constants */
#define NULL		$0x0

#define VT_NULL		$0x0
#define VT_BOOL		$0x1
#define VT_INT8		$0x2
#define VT_UINT8	$0x3
#define VT_INT16	$0x4
#define VT_UINT16	$0x5
#define VT_INT32	$0x6
#define VT_UINT32	$0x7
#define VT_INT64	$0x8
#define VT_UINT64	$0x9


.type marshall_call,@function
marshall_call:
	push	%rbp
	mov	%rsp, %rbp
	sub	$0x28, %rsp
	mov	%rdi, -0x08(%rbp)		/* Variable * ret */
	mov	%rsi, -0x10(%rbp)		/* MarshallCallback callback */
	mov	%rdx, -0x18(%rbp)		/* size_t args_cnt */
	mov	%rcx, -0x20(%rbp)		/* Variable ** args */
	movl	$0x0, -0x28(%rbp)		/* VariableType */
type:
	/* get the return type */
	cmp	NULL, %rdi
	je	type_done
#ifdef __PIC__
	call	variable_get_type@PLT
#else
	call	variable_get_type
#endif
	mov	%rax, -0x28(%rbp)
type_done:
args:
	mov	-0x18(%rbp), %rdi
	cmp	$0x0, %rdi
	je	args_done
	/* FIXME implement arguments */
	jmp	error
args_done:
call:
	/* call the function */
	call	*%rsi
call_done:
return:
	/* report the value returned */
	cmp	VT_NULL, -0x28(%rbp)
	je	return_NULL
	cmp	VT_BOOL, -0x28(%rbp)
	je	return_INTEGER
	cmp	VT_INT8, -0x28(%rbp)
	je	return_INTEGER
	cmp	VT_UINT8, -0x28(%rbp)
	je	return_INTEGER
	cmp	VT_INT16, -0x28(%rbp)
	je	return_INTEGER
	cmp	VT_UINT16, -0x28(%rbp)
	je	return_INTEGER
	cmp	VT_INT32, -0x28(%rbp)
	je	return_INTEGER
	cmp	VT_UINT32, -0x28(%rbp)
	je	return_INTEGER
	jmp	error
return_NULL:
	jmp	return_done
return_INTEGER:
	mov	-0x08(%rbp), %rdi
	mov	-0x28(%rbp), %rsi
	mov	%rax, -0x28(%rbp)		/* XXX scratch VariableType */
	lea	-0x28(%rbp), %rdx
#ifdef __PIC__
	call	variable_set_from@PLT
#else
	call	variable_set_from
#endif
	cmp	$0x0, %rax
	jne	error
	jmp	return_done
return_done:
	mov	$0x0, %rax
	jmp	ret
error:
	mov	$-1, %rax
ret:
	mov	%rbp, %rsp
	pop	%rbp
	ret
