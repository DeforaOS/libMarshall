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
#define VT_STRING	$0xd


.type marshall_call,@function
marshall_call:
	push	%ebp
	mov	%esp, %ebp
	sub	$0x8, %esp			/* VariableType type */
						/* int value */
type:
	/* get the return type */
	cmpl	NULL, -0x4(%esp)
	je	type_done
	mov	0x8(%ebp), %eax
	push	%eax
	call	variable_get_type
	mov	%eax, -0x4(%ebp)
	add	$0x4, %esp
type_done:
args:
	cmpl	$0x0, 0x10(%ebp)		/* XXX size_t */
	je	args_done
	/* FIXME implement arguments */
	jmp	error
args_done:
call:
	/* call the function */
	mov	0xc(%ebp), %eax
	call	*%eax
call_done:
return:
	/* report the value returned */
	cmpl	VT_NULL, -0x4(%ebp)
	je	return_NULL
	cmpl	VT_BOOL, -0x4(%ebp)
	je	return_INTEGER
	cmpl	VT_INT8, -0x4(%ebp)
	je	return_INTEGER
	cmpl	VT_UINT8, -0x4(%ebp)
	je	return_INTEGER
	cmpl	VT_INT16, -0x4(%ebp)
	je	return_INTEGER
	cmpl	VT_UINT16, -0x4(%ebp)
	je	return_INTEGER
	cmpl	VT_INT32, -0x4(%ebp)
	je	return_INTEGER
	cmpl	VT_UINT32, -0x4(%ebp)
	je	return_INTEGER
	cmpl	VT_STRING, -0x4(%ebp)
	je	return_POINTER
	jmp	error
return_NULL:
	jmp	return_done
return_INTEGER:
	mov	%eax, -0x8(%ebp)
	lea	-0x8(%ebp), %eax		/* &value */
	push	%eax
	mov	-0x4(%ebp), %eax		/* VariableType type */
	push	%eax
	mov	0x8(%ebp), %eax			/* Variable * ret */
	push	%eax
	jmp	return_variable_set_from
return_POINTER:
	push	%eax				/* void * value */
	mov	-0x4(%ebp), %eax		/* VariableType type */
	push	%eax
	mov	0x8(%ebp), %eax			/* Variable * ret */
	push	%eax
	jmp	return_variable_set_from
return_variable_set_from:
	call	variable_set_from
	add	$0xc, %esp
	cmp	$0x0, %eax
	jne	error
	jmp	return_done
return_done:
	mov	$0x0, %eax			/* return 0 */
	jmp	ret
error:
	mov	$-1, %eax			/* return -1 */
ret:
	mov	%ebp, %esp
	pop	%ebp
	ret
