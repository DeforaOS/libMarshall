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
	push	%rbp
	mov	%rsp, %rbp
	sub	$0x78, %rsp
	mov	%rdi, -0x08(%rbp)		/* Variable * ret */
	mov	%rsi, -0x10(%rbp)		/* MarshallCallback callback */
	mov	%rdx, -0x18(%rbp)		/* size_t args_cnt */
	mov	%rcx, -0x20(%rbp)		/* Variable ** args */
	movq	$0x0, -0x28(%rbp)		/* VariableType */
	movq	$0x0, -0x30(%rbp)		/* size_t args_pos */
	movq	$0x0, -0x38(%rbp)		/* long rdi */
	movq	$0x0, -0x40(%rbp)		/* long rsi */
	movq	$0x0, -0x48(%rbp)		/* long rdx */
	movq	$0x0, -0x50(%rbp)		/* long rcx */
	movq	$0x0, -0x58(%rbp)		/* long r8 */
	movq	$0x0, -0x60(%rbp)		/* long r9 */
	movq	$0x0, -0x68(%rbp)		/* size_t offset */
	movq	$0x0, -0x70(%rbp)		/* size_t args_cnt_integer */
	movq	$0x0, -0x78(%rbp)		/* uint64_t u64 */
type:
	/* get the return type */
	cmpq	NULL, %rdi
	je	type_done
#ifdef __PIC__					/* variable_get_type() */
	call	variable_get_type@PLT
#else
	call	variable_get_type
#endif
	mov	%rax, -0x28(%rbp)
type_done:
args:
	mov	-0x30(%rbp), %rdi		/* if(args_pos == args_cnt) */
	mov	-0x18(%rbp), %rdx
	cmp	%rdx, %rdi
	je	args_done			/* 	goto args_done */
	jg	args_error			/* else if(args_pos > args_cnt)
							goto args_error */
	/* FIXME assumes integers */
args_integer:
	mov	-0x20(%rbp), %rax
	mov	-0x30(%rbp), %rdi
	mov	(%rax, %rdi, 8), %rdi
	mov	VT_INT32, %rsi
	lea	-0x78(%rbp), %rdx
#ifdef __PIC__
	call	variable_get_as@PLT
#else
	call	variable_get_as
#endif
	cmp	$0x0, %rax			/* if(variable_get_as() != 0) */
	jne	args_error			/*	goto args_error */
	mov	-0x78(%rbp), %rax
	cmpq	$0x0, -0x70(%rbp)
	je	args_integer_0
	cmpq	$0x1, -0x70(%rbp)
	je	args_integer_1
	cmpq	$0x2, -0x70(%rbp)
	je	args_integer_2
	cmpq	$0x3, -0x70(%rbp)
	je	args_integer_3
	cmpq	$0x4, -0x70(%rbp)
	je	args_integer_4
	cmpq	$0x5, -0x70(%rbp)
	je	args_integer_5
	cmpq	$0x6, -0x70(%rbp)
	jge	args_integer_more
	jmp	error
args_integer_0:
	mov	%rax, -0x38(%rbp)		/* rdi */
	jmp	args_integer_loop
args_integer_1:
	mov	%rax, -0x40(%rbp)		/* rsi */
	jmp	args_integer_loop
args_integer_2:
	mov	%rax, -0x48(%rbp)		/* rdx */
	jmp	args_integer_loop
args_integer_3:
	mov	%rax, -0x50(%rbp)		/* rcx */
	jmp	args_integer_loop
args_integer_4:
	mov	%rax, -0x58(%rbp)		/* r8 */
	jmp	args_integer_loop
args_integer_5:
	mov	%rax, -0x60(%rbp)		/* r9 */
	jmp	args_integer_loop
args_integer_more:
	/* FIXME push in reverse order instead */
	push	%rax				/* stack */
	addq	$0x8, -0x68(%rbp)		/* offset += 8 */
	jmp	args_integer_loop
args_integer_loop:
	incq	-0x70(%rbp)			/* args_cnt_integer++ */
	jmp	args_loop
args_loop:
	incq	-0x30(%rbp)			/* args_pos++ */
	jmp	args
args_error:
	sub	-0x68(%rbp), %rsp		/* rsp -= offset */
	jmp	error
args_done:
call:
	/* call the function */
	mov	-0x38(%rbp), %rdi
	mov	-0x40(%rbp), %rsi
	mov	-0x48(%rbp), %rdx
	mov	-0x50(%rbp), %rcx
	mov	-0x58(%rbp), %r8
	mov	-0x60(%rbp), %r9
	mov	-0x10(%rbp), %rax
	call	*%rax				/* callback() */
	sub	-0x68(%rbp), %rsp		/* rsp -= offset */
call_done:
return:
	/* report the value returned */
	cmpq	VT_NULL, -0x28(%rbp)
	je	return_NULL
	/* FIXME make sure it is unsigned */
	cmpq	VT_UINT64, -0x28(%rbp)
	jle	return_INTEGER
	cmpq	VT_STRING, -0x28(%rbp)
	je	return_POINTER
	jmp	error
return_NULL:
	jmp	return_done
return_INTEGER:
	mov	-0x08(%rbp), %rdi
	mov	-0x28(%rbp), %rsi
	mov	%rax, -0x28(%rbp)		/* XXX scratch VariableType */
	lea	-0x28(%rbp), %rdx
	jmp	return_variable_set
return_POINTER:
	mov	-0x08(%rbp), %rdi
	mov	-0x28(%rbp), %rsi
	mov	%rax, %rdx
	jmp	return_variable_set
return_variable_set:
#ifdef __PIC__					/* variable_set_from() */
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
