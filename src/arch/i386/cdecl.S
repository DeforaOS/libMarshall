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



#if !defined(__APPLE__)
.type marshall_callp,@function
#endif
marshall_callp:
	push	%ebp
	mov	%esp, %ebp
	sub	$0x20, %esp			/* VariableType type */
	movl	$0x0, -0x4(%ebp)		/* type = 0 */
	movl	$0x0, -0x8(%ebp)		/* args_pos = 0 */
						/* uint64_t res */
	movl	$0x0, -0x14(%ebp)		/* offset = 0 */
	movl	$0x0, -0x18(%ebp)		/* pos = 0 */
type:
	/* get the return type */
	cmpl	NULL, 0x8(%ebp)
	je	type_done
	push	0x8(%ebp)
	call	FUNC(variable_get_type)		/* variable_get_type(res) */
	add	$0x4, %esp
	mov	%eax, -0x4(%ebp)
type_done:
count:
	mov	0x10(%ebp), %eax
	mov	-0x8(%ebp), %edx
	cmp	%eax, %edx			/* if(args_pos == args_cnt) */
	je	count_done			/*	goto count_done */
#if 0 /* should not happen */
	jg	count_error			/* else if(args_pos > args_cnt)
							goto count_error */
#endif
count_type:
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0x8(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	FUNC(variable_get_type)		/* variable_get_type(eax) */
	add	$0x4, %esp
	cmp	VT_NULL, %eax
	je	count_done
	cmp	VT_UINT32, %eax
	jle	count_INTEGER
	cmp	VT_UINT64, %eax
	jle	count_INTEGER64
	cmp	VT_FLOAT, %eax
	jle	count_FLOAT
	cmp	VT_DOUBLE, %eax
	jle	count_DOUBLE
	cmp	VT_STRING, %eax
	jle	count_INTEGER
	/* FIXME implement more types */
	jmp	count_error
count_INTEGER:
	addl	$0x4, -0x14(%ebp)		/* offset += 4 */
	jmp	count_loop
count_INTEGER64:
	addl	$0x8, -0x14(%ebp)		/* offset += 8 */
	jmp	count_loop
count_FLOAT:
	addl	$0x4, -0x14(%ebp)		/* offset += 4 */
	jmp	count_loop
count_DOUBLE:
	addl	$0x8, -0x14(%ebp)		/* offset += 8 */
#if 0 /* fallback */
	jmp	count_loop
#endif
count_loop:
	incl	-0x8(%ebp)			/* args_pos++ */
	jmp	count
count_error:
	jmp	error
count_done:
	subl	-0x14(%ebp), %esp		/* esp -= offset */
	movl	$0x0, -0x8(%ebp)		/* args_pos = 0 */
args:
	mov	0x10(%ebp), %eax
	mov	-0x8(%ebp), %edx
	cmp	%eax, %edx			/* if(args_pos == args_cnt) */
	je	args_done			/*	goto args_done */
#if 0 /* should not happen */
	jg	args_error			/* else if(args_pos > args_cnt)
							goto args_error */
#endif
args_type:
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0x8(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	FUNC(variable_get_type)		/* variable_get_type(eax) */
	add	$0x4, %esp
	cmp	VT_NULL, %eax
	je	args_done
	cmp	VT_UINT32, %eax
	jle	args_INTEGER
	cmp	VT_UINT64, %eax
	jle	args_INTEGER64
	jle	args_error
	cmp	VT_FLOAT, %eax
	jle	args_FLOAT
	cmp	VT_DOUBLE, %eax
	jle	args_DOUBLE
	cmp	VT_STRING, %eax
	jle	args_POINTER
	/* FIXME implement more types */
	jmp	args_error
args_INTEGER:
	lea	-0x10(%ebp), %edx
	push	%edx
	push	%eax
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0x8(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	FUNC(variable_get_as)		/* eax = variable_get_as() */
						/* XXX memory leak */
	add	$0xc, %esp
	cmp	$0x0, %eax			/* if(eax != 0) */
	jne	args_error			/*	goto args_error */
	mov	%esp, %edx			/* edx = esp + pos */
	addl	-0x18(%ebp), %edx
	mov	-0x10(%ebp), %eax		/* *edx = res */
	mov	%eax, (%edx)
	addl	$0x4, -0x18(%ebp)		/* pos += 4 */
	jmp	args_loop
args_INTEGER64:
	lea	-0x10(%ebp), %edx
	push	%edx
	push	%eax
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0x8(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	FUNC(variable_get_as)		/* eax = variable_get_as() */
						/* XXX memory leak */
	add	$0xc, %esp
	cmp	$0x0, %eax			/* if(eax != 0) */
	jne	args_error			/*	goto args_error */
	mov	%esp, %edx			/* edx = esp + pos */
	addl	-0x18(%ebp), %edx
	mov	-0x10(%ebp), %eax		/* *edx = low(res) */
	mov	%eax, (%edx)
	addl	$0x4, %edx
	mov	-0xc(%ebp), %eax		/* *edx = high(res) */
	mov	%eax, (%edx)
	addl	$0x8, -0x18(%ebp)		/* pos += 8 */
	jmp	args_loop
args_FLOAT:
	mov	%esp, %edx			/* edx = esp + pos */
	addl	-0x18(%ebp), %edx
	push	%edx
	push	%eax
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0x8(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	FUNC(variable_get_as)		/* eax = variable_get_as() */
						/* XXX memory leak */
	add	$0xc, %esp
	cmp	$0x0, %eax			/* if(eax != 0) */
	jne	args_error			/*	goto args_error */
	addl	$0x4, -0x18(%ebp)		/* pos += 4 */
	jmp	args_loop
args_DOUBLE:
	mov	%esp, %edx			/* edx = esp + pos */
	addl	-0x18(%ebp), %edx
	push	%edx
	push	%eax
	mov	0x14(%ebp), %eax		/* eax = args */
	mov	-0x8(%ebp), %edx		/* edx = args_pos */
	push	(%eax, %edx, 4)			/* eax = args[args_pos] */
	call	FUNC(variable_get_as)		/* eax = variable_get_as() */
						/* XXX memory leak */
	add	$0xc, %esp
	cmp	$0x0, %eax			/* if(eax != 0) */
	jne	args_error			/*	goto args_error */
	addl	$0x8, -0x18(%ebp)		/* pos += 8 */
	jmp	args_loop
args_POINTER:
	jmp	args_INTEGER
args_loop:
	incl	-0x8(%ebp)			/* args_pos++ */
	jmp	args
args_error:
	addl	-0x14(%ebp), %esp		/* esp += offset */
	jmp	error
args_done:
call:
	/* call the function */
	mov	0xc(%ebp), %eax
	call	*%eax
	add	-0x14(%ebp), %esp		/* esp += offset */
call_done:
return:
	/* report the value returned */
	cmpl	VT_NULL, -0x4(%ebp)
	je	return_NULL
	cmpl	VT_UINT32, -0x4(%ebp)
	jle	return_INTEGER
	cmpl	VT_UINT64, -0x4(%ebp)
	jle	return_INTEGER64
	cmpl	VT_FLOAT, -0x4(%ebp)
	jle	return_FLOAT
	cmpl	VT_DOUBLE, -0x4(%ebp)
	jle	return_DOUBLE
	cmpl	VT_STRING, -0x4(%ebp)		/* XXX free the result */
	je	return_POINTER
	jmp	error
return_NULL:
	jmp	return_done
return_INTEGER:
	mov	%eax, -0x10(%ebp)
	lea	-0x10(%ebp), %eax		/* &value */
	push	%eax
	push	-0x4(%ebp)			/* VariableType type */
	push	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_INTEGER64:
	mov	%edx, -0xc(%ebp)
	mov	%eax, -0x10(%ebp)
	lea	-0x10(%ebp), %eax		/* &value */
	push	%eax
	push	-0x4(%ebp)			/* VariableType type */
	push	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_FLOAT:
	fsts	-0x10(%ebp)
	lea	-0x10(%ebp), %eax
	push	%eax
	push	-0x4(%ebp)			/* VariableType type */
	push	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_DOUBLE:
	fstl	-0x10(%ebp)
	lea	-0x10(%ebp), %eax
	push	%eax
	push	-0x4(%ebp)			/* VariableType type */
	push	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_POINTER:
	push	%eax				/* void * value */
	push	-0x4(%ebp)			/* VariableType type */
	push	0x8(%ebp)			/* Variable * ret */
	jmp	return_variable_set_from
return_variable_set_from:
	call	FUNC(variable_set_from)
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
