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
/* FIXME: untested code */



#if !defined(__APPLE__)
.type marshall_callp,@function
#endif
SYMBOL(marshall_callp):
	push	%rbp
	mov	%rsp, %rbp
	sub	$0xc8, %rsp
	xor	%rax, %rax
	mov	%rcx, -0x08(%rbp)		/* Variable * ret = res */
	mov	%rdx, -0x10(%rbp)		/* MarshallCall call = call */
	mov	%r8, -0x18(%rbp)		/* size_t args_cnt = args_cnt */
	mov	%r9, -0x20(%rbp)		/* Variable ** args = args */
	/* movq	%rax, -0x28(%rbp) */		/* VariableType type = VT_NULL */
	movq	%rax, -0x30(%rbp)		/* size_t args_pos = 0 */
	movq	%rax, -0x38(%rbp)		/* long rcx = 0 */
	movq	%rax, -0x40(%rbp)		/* long rdx = 0 */
	movq	%rax, -0x48(%rbp)		/* long r8 = 0 */
	movq	%rax, -0x50(%rbp)		/* long r9 = 0 */
	movq	%rax, -0x58(%rbp)		/* XXX padding */
	movq	%rax, -0x60(%rbp)		/* XXX padding */
	movq	$0x20, -0x68(%rbp)		/* size_t offset = 0x20 */
	movq	%rax, -0x70(%rbp)		/* size_t args_cnt_integer = 0 */
	movq	%rax, -0x78(%rbp)		/* uint64_t u64 = 0 */
	movq	%rax, -0x80(%rbp)
	movq	%rax, -0x88(%rbp)		/* size_t args_cnt_sse = 0 */
	movq	$0x20, -0x90(%rbp)		/* size_t pos = 0x20 */
	movq	%rax, -0x9f(%rbp)		/* size_t offset2 = 0 */
	movq	%rax, -0xa0(%rbp)
						/* double xmm[4] */
type:
	/* get the return type */
	cmp	NULL, %rcx
	je	type_done
	call	FUNC(variable_get_type)		/* type = variable_get_type() */
	mov	%rax, -0x28(%rbp)
type_done:
count:
	mov	-0x30(%rbp), %rdi		/* if(args_pos == args_cnt) */
	mov	-0x18(%rbp), %rdx
	cmp	%rdx, %rdi
	je	count_round			/* 	goto count_round */
#if 0 /* should not happen */
	jg	count_error			/* else if(args_pos > args_cnt)
							goto count_error */
#endif
count_type:
	mov	-0x20(%rbp), %rax
	mov	-0x30(%rbp), %rcx
	mov	(%rax, %rcx, 8), %rcx
	call	FUNC(variable_get_type)
	cmp	VT_NULL, %rax
	je	count_round
	/* FIXME make sure it is unsigned */
	cmp	VT_UINT64, %rax
	jle	count_INTEGER
	cmp	VT_DOUBLE, %rax
	jle	count_SSE
	cmp	VT_STRING, %rax
	je	count_INTEGER
	jmp	count_error
count_INTEGER:
	cmpq	$0x5, -0x70(%rbp)
	jg	count_INTEGER_more
#if 0 /* fallthrough */
	jmp	count_INTEGER_registers
#endif
count_INTEGER_registers:
	jmp	count_INTEGER_loop
count_INTEGER_more:
	addq	$0x8, -0x68(%rbp)		/* offset += 8 */
#if 0 /* fallthrough */
	jmp	count_INTEGER_loop
#endif
count_INTEGER_loop:
	incq	-0x70(%rbp)			/* args_cnt_integer++ */
	jmp	count_loop
count_SSE:
	cmpq	$0x7, -0x88(%rbp)
	jg	count_SSE_more
#if 0 /* fallthrough */
	jle	count_SSE_registers
#endif
count_SSE_registers:
	jmp	count_SSE_loop
count_SSE_more:
	addq	$0x8, -0x68(%rbp)		/* offset += 8 */
#if 0 /* fallthrough */
	jmp	count_SSE_loop
#endif
count_SSE_loop:
	incq	-0x88(%rbp)			/* args_cnt_sse++ */
#if 0 /* fallthrough */
	jmp	count_loop
#endif
count_loop:
	incq	-0x30(%rbp)			/* args_pos++ */
	jmp	count
count_error:
	jmp	error
count_round:
	mov	-0x68(%rbp), %rax		/* if((offset & 0x8) != 0x0) */
	and	$0x8, %rax
	cmp	$0x0, %rax
	je	count_done
	addq	$0x8, -0x68(%rbp)		/*	offset += 0x8 */
count_done:
	subq	-0x68(%rbp), %rsp		/* rsp -= offset */
	xor	%rax, %rax
	movq	%rax, -0x70(%rbp)		/* args_cnt_integer = 0 */
	movq	%rax, -0x88(%rbp)		/* args_cnt_sse = 0 */
	movq	%rax, -0x30(%rbp)		/* args_pos = 0 */
args:
	mov	-0x30(%rbp), %rdi		/* if(args_pos == args_cnt) */
	mov	-0x18(%rbp), %rdx
	cmp	%rdx, %rdi
	je	args_done			/* 	goto args_done */
#if 0 /* should not happen */
	jg	args_error			/* else if(args_pos > args_cnt)
							goto args_error */
#endif
args_type:
	mov	-0x20(%rbp), %rax
	mov	-0x30(%rbp), %rcx
	mov	(%rax, %rcx, 8), %rcx
	call	FUNC(variable_get_type)
	cmp	VT_NULL, %rax
	je	args_done
	/* FIXME make sure it is unsigned */
	cmp	VT_UINT64, %rax
	jle	args_INTEGER
	cmp	VT_DOUBLE, %rax
	jle	args_SSE
	cmp	VT_STRING, %rax
	je	args_INTEGER
	jmp	args_error
args_INTEGER:
	mov	-0x20(%rbp), %r8
	mov	-0x30(%rbp), %rcx
	mov	(%rdx, %rcx, 8), %rcx
	mov	%rax, %rdx
	lea	-0x78(%rbp), %r8
	call	FUNC(variable_get_as)
	cmp	$0x0, %rax			/* if(variable_get_as() != 0) */
	jne	args_error			/*	goto args_error */
	mov	-0x78(%rbp), %rax
	cmpq	$0x0, -0x70(%rbp)
	je	args_INTEGER_0
	cmpq	$0x1, -0x70(%rbp)
	je	args_INTEGER_1
	cmpq	$0x2, -0x70(%rbp)
	je	args_INTEGER_2
	cmpq	$0x3, -0x70(%rbp)
	je	args_INTEGER_3
	jg	args_INTEGER_more
	jmp	error
args_INTEGER_0:
	mov	%rax, -0x38(%rbp)		/* rcx */
	jmp	args_INTEGER_loop
args_INTEGER_1:
	mov	%rax, -0x40(%rbp)		/* rdx */
	jmp	args_INTEGER_loop
args_INTEGER_2:
	mov	%rax, -0x48(%rbp)		/* r8 */
	jmp	args_INTEGER_loop
args_INTEGER_3:
	mov	%rax, -0x50(%rbp)		/* r9 */
	jmp	args_INTEGER_loop
args_INTEGER_more:
	mov	%rsp, %rdx			/* rdx = rsp + pos */
	addq	-0x90(%rbp), %rdx
	mov	%rax, (%rdx)			/* *rdx = rax */
	addq	$0x8, -0x90(%rbp)		/* pos += 8 */
#if 0 /* fallthrough */
	jmp	args_INTEGER_loop
#endif
args_INTEGER_loop:
	incq	-0x70(%rbp)			/* args_cnt_integer++ */
	jmp	args_loop
args_SSE:
	mov	-0x20(%rbp), %r8
	mov	-0x30(%rbp), %rcx
	mov	(%r8, %rcx, 8), %rcx
	mov	%rax, %rdx
	cmpq	$0x4, -0x88(%rbp)
	jge	args_SSE_more
args_SSE_registers:
	lea	-0xc8(%rbp), %r8
	mov	-0x88(%rbp), %r9
	shl	$0x3, %r9
	add	%r9, %r8
	call	FUNC(variable_get_as)
	cmp	$0x0, %rax			/* if(variable_get_as() != 0) */
	jne	args_error			/*	goto args_error */
	jmp	args_SSE_loop
args_SSE_more:
	mov	%rsp, %r8			/* rdx = rsp + pos */
	addq	-0x90(%rbp), %r8
	call	FUNC(variable_get_as)
	cmp	$0x0, %rax			/* if(variable_get_as() != 0) */
	jne	args_error			/*	goto args_error */
	addq	$0x8, -0x90(%rbp)		/* pos += 8 */
#if 0 /* fallthrough */
	jmp	args_SSE_loop
#endif
args_SSE_loop:
	incq	-0x88(%rbp)			/* args_cnt_sse++ */
#if 0 /* fallthrough */
	jmp	args_loop
#endif
args_loop:
	incq	-0x30(%rbp)			/* args_pos++ */
	jmp	args
args_error:
	addq	-0x68(%rbp), %rsp		/* rsp += offset */
	jmp	error
args_done:
call:
	/* call the function */
	mov	-0x38(%rbp), %rcx
	mov	-0x40(%rbp), %rdx
	mov	-0x48(%rbp), %r8
	mov	-0x50(%rbp), %r9
	mov	-0x10(%rbp), %r10
	movsd	-0xe8(%rbp), %xmm0
	movsd	-0xe0(%rbp), %xmm1
	movsd	-0xd8(%rbp), %xmm2
	movsd	-0xd0(%rbp), %xmm3
	mov	-0x88(%rbp), %rax		/* rax = min(args_cnt_sse, 4) */
	cmp	$0x4, %rax
	jle	call_do
	mov	$0x4, %rax
call_do:
	call	*%r10				/* call() */
	addq	-0x68(%rbp), %rsp		/* rsp += offset */
call_done:
return:
	mov	%rax, %r8
	xor	%rax, %rax
	/* report the value returned */
	mov	-0x28(%rbp), %rdx
	cmp	VT_NULL, %rdx
	je	return_NULL
	/* FIXME make sure it is unsigned */
	cmp	VT_UINT64, %rdx
	jle	return_INTEGER
	cmp	VT_DOUBLE, %rdx
	jle	return_SSE
	cmp	VT_STRING, %rdx
	je	return_INTEGER
	jmp	error
return_NULL:
	xor	%rax, %rax
	jmp	return_do
return_SSE:
	inc	%rax				/* rax = 1 */
	jmp	return_variable_set_type
return_INTEGER:
#if 0 /* fallthrough */
	jmp	return_variable_set_type
#endif
return_variable_set_type:
	mov	-0x08(%rbp), %rcx		/* variable_set_type(ret) */
	call	FUNC(variable_set_type)
	cmp	$0x0, %rax
	jne	error
	jmp	return_do
error:
	mov	$-1, %rax
return_do:
	mov	%rbp, %rsp
	pop	%rbp
	ret
