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



#define RET			-0x08(%rbp)
#define CALL			-0x10(%rbp)
#define ARGS_CNT		-0x18(%rbp)
#define DIRECTION		-0x20(%rbp)
#define ARGS			-0x28(%rbp)
#define TYPE			-0x30(%rbp)
#define ARGS_POS		-0x38(%rbp)
#define REG_RDI			-0x40(%rbp)
#define REG_RSI			-0x48(%rbp)
#define REG_RDX			-0x50(%rbp)
#define REG_RCX			-0x58(%rbp)
#define REG_R8			-0x60(%rbp)
#define REG_R9			-0x68(%rbp)
#define OFFSET			-0x70(%rbp)
#define ARGS_CNT_INTEGER	-0x78(%rbp)
#define U64			-0x80(%rbp)
#define ARGS_CNT_SSE		-0x88(%rbp)
#define POS			-0x90(%rbp)
#define REG_XMM0		-0xd0(%rbp)
#define REG_XMM1		-0xc8(%rbp)
#define REG_XMM2		-0xc0(%rbp)
#define REG_XMM3		-0xb8(%rbp)
#define REG_XMM4		-0xb0(%rbp)
#define REG_XMM5		-0xa8(%rbp)
#define REG_XMM6		-0xa0(%rbp)
#define REG_XMM7		-0x98(%rbp)


#if !defined(__APPLE__)
.type marshall_call_directionp,@function
#endif
SYMBOL(marshall_call_directionp):
	push	%rbp
	mov	%rsp, %rbp
	sub	$0xd0, %rsp
	mov	%rdi, RET			/* Variable * ret = res */
	mov	%rsi, CALL			/* MarshallCall call = call */
	mov	%rdx, ARGS_CNT			/* size_t args_cnt = args_cnt */
	mov	%rcx, DIRECTION			/* MarshallCallDirection * direction = direction */
	mov	%r8,  ARGS			/* Variable ** args = args */
init:
	lea	REG_XMM0, %rdi
	xor	%rsi, %rsi
	mov	$0xa8, %rdx
	call	FUNC(memset)
type:
	/* get the return type */
	cmp	NULL, RET
	je	type_done
	mov	RET, %rdi
	call	FUNC(variable_get_type)		/* type = variable_get_type() */
	mov	%rax, TYPE
type_done:
count:
	mov	ARGS_POS, %rdi			/* if(args_pos == args_cnt) */
	mov	ARGS_CNT, %rdx
	cmp	%rdx, %rdi
	je	count_round			/* 	goto count_round */
#if 0 /* should not happen */
	jg	count_error			/* else if(args_pos > args_cnt)
							goto count_error */
#endif
count_type:
	mov	ARGS, %rax
	mov	ARGS_POS, %rdi
	mov	(%rax, %rdi, 8), %rdi
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
	cmpq	$0x5, ARGS_CNT_INTEGER
	jg	count_INTEGER_more
#if 0 /* fallthrough */
	jmp	count_INTEGER_registers
#endif
count_INTEGER_registers:
	jmp	count_INTEGER_loop
count_INTEGER_more:
	addq	$0x8, OFFSET			/* offset += 8 */
#if 0 /* fallthrough */
	jmp	count_INTEGER_loop
#endif
count_INTEGER_loop:
	incq	ARGS_CNT_INTEGER		/* args_cnt_integer++ */
	jmp	count_loop
count_SSE:
	cmpq	$0x7, ARGS_CNT_SSE
	jg	count_SSE_more
#if 0 /* fallthrough */
	jle	count_SSE_registers
#endif
count_SSE_registers:
	jmp	count_SSE_loop
count_SSE_more:
	addq	$0x8, OFFSET			/* offset += 8 */
#if 0 /* fallthrough */
	jmp	count_SSE_loop
#endif
count_SSE_loop:
	incq	ARGS_CNT_SSE			/* args_cnt_sse++ */
#if 0 /* fallthrough */
	jmp	count_loop
#endif
count_loop:
	incq	ARGS_POS			/* args_pos++ */
	jmp	count
count_error:
	jmp	error
count_round:
	mov	OFFSET, %rax			/* if((offset & 0x8) != 0x0) */
	and	$0x8, %rax
	cmp	$0x0, %rax
	je	count_done
	addq	$0x8, OFFSET			/*	offset += 0x8 */
count_done:
	subq	OFFSET, %rsp			/* rsp -= offset */
	xor	%rax, %rax
	movq	%rax, ARGS_CNT_INTEGER		/* args_cnt_integer = 0 */
	movq	%rax, ARGS_CNT_SSE		/* args_cnt_sse = 0 */
	movq	%rax, ARGS_POS			/* args_pos = 0 */
args:
	mov	ARGS_POS, %rdi			/* if(args_pos == args_cnt) */
	mov	ARGS_CNT, %rdx
	cmp	%rdx, %rdi
	je	args_done			/* 	goto args_done */
#if 0 /* should not happen */
	jg	args_error			/* else if(args_pos > args_cnt)
							goto args_error */
#endif
args_direction:
	/* FIXME implement */
args_type:
	mov	ARGS, %rax
	mov	ARGS_POS, %rdi
	mov	(%rax, %rdi, 8), %rdi
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
	mov	ARGS, %rdx
	mov	ARGS_POS, %rdi
	mov	(%rdx, %rdi, 8), %rdi
	mov	%rax, %rsi
	lea	U64, %rdx
	call	FUNC(variable_get_as)
	cmp	$0x0, %rax			/* if(variable_get_as() != 0) */
	jne	args_error			/*	goto args_error */
	mov	U64, %rax
	cmpq	$0x0, ARGS_CNT_INTEGER
	je	args_INTEGER_0
	cmpq	$0x1, ARGS_CNT_INTEGER
	je	args_INTEGER_1
	cmpq	$0x2, ARGS_CNT_INTEGER
	je	args_INTEGER_2
	cmpq	$0x3, ARGS_CNT_INTEGER
	je	args_INTEGER_3
	cmpq	$0x4, ARGS_CNT_INTEGER
	je	args_INTEGER_4
	cmpq	$0x5, ARGS_CNT_INTEGER
	je	args_INTEGER_5
	jg	args_INTEGER_more
	jmp	error
args_INTEGER_0:
	mov	%rax, REG_RDI			/* rdi */
	jmp	args_INTEGER_loop
args_INTEGER_1:
	mov	%rax, REG_RSI			/* rsi */
	jmp	args_INTEGER_loop
args_INTEGER_2:
	mov	%rax, REG_RDX			/* rdx */
	jmp	args_INTEGER_loop
args_INTEGER_3:
	mov	%rax, REG_RCX			/* rcx */
	jmp	args_INTEGER_loop
args_INTEGER_4:
	mov	%rax, REG_R8			/* r8 */
	jmp	args_INTEGER_loop
args_INTEGER_5:
	mov	%rax, REG_R9			/* r9 */
	jmp	args_INTEGER_loop
args_INTEGER_more:
	mov	%rsp, %rdx			/* rdx = rsp + pos */
	addq	POS, %rdx
	mov	%rax, (%rdx)			/* *rdx = rax */
	addq	$0x8, POS			/* pos += 8 */
#if 0 /* fallthrough */
	jmp	args_INTEGER_loop
#endif
args_INTEGER_loop:
	incq	ARGS_CNT_INTEGER		/* args_cnt_integer++ */
	jmp	args_loop
args_SSE:
	mov	ARGS, %rdx
	mov	ARGS_POS, %rdi
	mov	(%rdx, %rdi, 8), %rdi
	mov	%rax, %rsi
	cmpq	$0x8, ARGS_CNT_SSE
	jge	args_SSE_more
args_SSE_registers:
	lea	REG_XMM0, %rdx
	mov	ARGS_CNT_SSE, %rcx
	shl	$0x3, %rcx
	add	%rcx, %rdx
	call	FUNC(variable_get_as)
	cmp	$0x0, %rax			/* if(variable_get_as() != 0) */
	jne	args_error			/*	goto args_error */
	jmp	args_SSE_loop
args_SSE_more:
	mov	%rsp, %rdx			/* rdx = rsp + pos */
	addq	POS, %rdx
	call	FUNC(variable_get_as)
	cmp	$0x0, %rax			/* if(variable_get_as() != 0) */
	jne	args_error			/*	goto args_error */
	addq	$0x8, POS			/* pos += 8 */
#if 0 /* fallthrough */
	jmp	args_SSE_loop
#endif
args_SSE_loop:
	incq	ARGS_CNT_SSE			/* args_cnt_sse++ */
#if 0 /* fallthrough */
	jmp	args_loop
#endif
args_loop:
	incq	ARGS_POS			/* args_pos++ */
	jmp	args
args_error:
	addq	OFFSET, %rsp			/* rsp += offset */
	jmp	error
args_done:
call:
	/* call the function */
	mov	REG_RDI, %rdi
	mov	REG_RSI, %rsi
	mov	REG_RDX, %rdx
	mov	REG_RCX, %rcx
	mov	REG_R8, %r8
	mov	REG_R9, %r9
	movsd	REG_XMM0, %xmm0
	movsd	REG_XMM1, %xmm1
	movsd	REG_XMM2, %xmm2
	movsd	REG_XMM3, %xmm3
	movsd	REG_XMM4, %xmm4
	movsd	REG_XMM5, %xmm5
	movsd	REG_XMM6, %xmm6
	movsd	REG_XMM7, %xmm7
	mov	ARGS_CNT_SSE, %rax		/* rax = min(args_cnt_sse, 8) */
	cmp	$0x8, %rax
	jle	call_do
	mov	$0x8, %rax
call_do:
	mov	CALL, %r10
	call	*%r10				/* call() */
	addq	OFFSET, %rsp			/* rsp += offset */
call_done:
return:
	mov	%rax, %rdx
	xor	%rax, %rax
	/* report the value returned */
	mov	TYPE, %rsi
	cmp	VT_NULL, %rsi
	je	return_NULL
	/* FIXME make sure it is unsigned */
	cmp	VT_UINT64, %rsi
	jle	return_INTEGER
	cmp	VT_DOUBLE, %rsi
	jle	return_SSE
	cmp	VT_STRING, %rsi
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
	mov	RET, %rdi			/* variable_set_type(ret) */
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
