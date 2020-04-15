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
SYMBOL(marshall_callp):
	push	%rbp
	mov	%rsp, %rbp
	sub	$0x90, %rsp
	xor	%rax, %rax
	mov	%rdi, -0x08(%rbp)		/* Variable * ret */
	mov	%rsi, -0x10(%rbp)		/* MarshallCall call */
	mov	%rdx, -0x18(%rbp)		/* size_t args_cnt */
	mov	%rcx, -0x20(%rbp)		/* Variable ** args */
	movq	%rax, -0x28(%rbp)		/* VariableType type = 0 */
	movq	%rax, -0x30(%rbp)		/* size_t args_pos = 0 */
	movq	%rax, -0x38(%rbp)		/* long rdi = 0 */
	movq	%rax, -0x40(%rbp)		/* long rsi = 0 */
	movq	%rax, -0x48(%rbp)		/* long rdx = 0 */
	movq	%rax, -0x50(%rbp)		/* long rcx = 0 */
	movq	%rax, -0x58(%rbp)		/* long r8 = 0 */
	movq	%rax, -0x60(%rbp)		/* long r9 = 0 */
	movq	%rax, -0x68(%rbp)		/* size_t offset = 0 */
	movq	%rax, -0x70(%rbp)		/* size_t args_cnt_integer = 0 */
	movq	%rax, -0x78(%rbp)		/* uint64_t u64 = 0 */
	movq	%rax, -0x80(%rbp)
	movq	%rax, -0x88(%rbp)		/* size_t args_cnt_sse = 0 */
	movq	%rax, -0x90(%rbp)		/* size_t pos = 0 */
type:
	/* get the return type */
	cmpq	NULL, %rdi
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
	mov	-0x30(%rbp), %rdi
	mov	(%rax, %rdi, 8), %rdi
	call	FUNC(variable_get_type)
	cmp	VT_NULL, %rax
	je	count_round
	/* FIXME make sure it is unsigned */
	cmpq	VT_UINT64, %rax
	jle	count_INTEGER
	cmpq	VT_DOUBLE, %rax
	jle	count_SSE
	cmpq	VT_STRING, %rax
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
	mov	-0x30(%rbp), %rdi
	mov	(%rax, %rdi, 8), %rdi
	call	FUNC(variable_get_type)
	cmp	VT_NULL, %rax
	je	args_done
	/* FIXME make sure it is unsigned */
	cmpq	VT_UINT64, %rax
	jle	args_INTEGER
	cmpq	VT_DOUBLE, %rax
	jle	args_SSE
	cmpq	VT_STRING, %rax
	je	args_INTEGER
	jmp	args_error
args_INTEGER:
	mov	-0x20(%rbp), %rdx
	mov	-0x30(%rbp), %rdi
	mov	(%rdx, %rdi, 8), %rdi
	mov	%rax, %rsi
	lea	-0x78(%rbp), %rdx
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
	cmpq	$0x4, -0x70(%rbp)
	je	args_INTEGER_4
	cmpq	$0x5, -0x70(%rbp)
	je	args_INTEGER_5
	jg	args_INTEGER_more
	jmp	error
args_INTEGER_0:
	mov	%rax, -0x38(%rbp)		/* rdi */
	jmp	args_INTEGER_loop
args_INTEGER_1:
	mov	%rax, -0x40(%rbp)		/* rsi */
	jmp	args_INTEGER_loop
args_INTEGER_2:
	mov	%rax, -0x48(%rbp)		/* rdx */
	jmp	args_INTEGER_loop
args_INTEGER_3:
	mov	%rax, -0x50(%rbp)		/* rcx */
	jmp	args_INTEGER_loop
args_INTEGER_4:
	mov	%rax, -0x58(%rbp)		/* r8 */
	jmp	args_INTEGER_loop
args_INTEGER_5:
	mov	%rax, -0x60(%rbp)		/* r9 */
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
	mov	-0x20(%rbp), %rdx
	mov	-0x30(%rbp), %rdi
	mov	(%rdx, %rdi, 8), %rdi
	mov	%rax, %rsi
	lea	-0x80(%rbp), %rdx
	call	FUNC(variable_get_as)
	cmp	$0x0, %rax			/* if(variable_get_as() != 0) */
	jne	args_error			/*	goto args_error */
	cmpq	$0x0, -0x88(%rbp)
	je	args_SSE_0
	cmpq	$0x1, -0x88(%rbp)
	je	args_SSE_1
	cmpq	$0x2, -0x88(%rbp)
	je	args_SSE_2
	cmpq	$0x3, -0x88(%rbp)
	je	args_SSE_3
	cmpq	$0x4, -0x88(%rbp)
	je	args_SSE_4
	cmpq	$0x5, -0x88(%rbp)
	je	args_SSE_5
	cmpq	$0x6, -0x88(%rbp)
	je	args_SSE_6
	cmpq	$0x7, -0x88(%rbp)
	je	args_SSE_7
	jg	args_SSE_more
	jmp	error
args_SSE_0:
	movaps	-0x80(%rbp), %xmm0
	jmp	args_SSE_loop
args_SSE_1:
	movaps	-0x80(%rbp), %xmm1
	jmp	args_SSE_loop
args_SSE_2:
	movaps	-0x80(%rbp), %xmm2
	jmp	args_SSE_loop
args_SSE_3:
	movaps	-0x80(%rbp), %xmm3
	jmp	args_SSE_loop
args_SSE_4:
	movaps	-0x80(%rbp), %xmm4
	jmp	args_SSE_loop
args_SSE_5:
	movaps	-0x80(%rbp), %xmm5
	jmp	args_SSE_loop
args_SSE_6:
	movaps	-0x80(%rbp), %xmm6
	jmp	args_SSE_loop
args_SSE_7:
	movaps	-0x80(%rbp), %xmm7
	jmp	args_SSE_loop
args_SSE_more:
	mov	%rsp, %rdx			/* rdx = rsp + pos */
	addq	-0x90(%rbp), %rdx
	mov	-0x80(%rbp), %rcx		/* *rdx = sse */
	mov	%rcx, (%rdx)
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
	mov	-0x38(%rbp), %rdi
	mov	-0x40(%rbp), %rsi
	mov	-0x48(%rbp), %rdx
	mov	-0x50(%rbp), %rcx
	mov	-0x58(%rbp), %r8
	mov	-0x60(%rbp), %r9
	mov	-0x10(%rbp), %rax
	call	*%rax				/* call() */
	addq	-0x68(%rbp), %rsp		/* rsp += offset */
call_done:
return:
	/* report the value returned */
	cmpq	VT_NULL, -0x28(%rbp)
	je	return_NULL
	xor	%rax, %rax
	/* FIXME make sure it is unsigned */
	cmpq	VT_UINT64, -0x28(%rbp)
	jle	return_INTEGER
	cmpq	VT_DOUBLE, -0x28(%rbp)
	jle	return_SSE
	cmpq	VT_STRING, -0x28(%rbp)
	je	return_POINTER
	jmp	error
return_NULL:
	jmp	return_done
return_INTEGER:
	mov	%rax, %rdx
	jmp	return_variable_set_type
return_POINTER:
	mov	%rax, %rdx
	jmp	return_variable_set_type
return_SSE:
	inc	%rax
#if 0 /* fallthrough */
	jmp	return_variable_set_type
#endif
return_variable_set_type:
	mov	-0x08(%rbp), %rdi
	mov	-0x28(%rbp), %rsi
	call	FUNC(variable_set_type)
	cmp	$0x0, %rax
	jne	error
#if 0 /* fallthrough */
	jmp	return_done
#endif
return_done:
	mov	$0x0, %rax
	jmp	return_mmx
error:
	mov	$-1, %rax
return_mmx:
	cmpq	$0x0, -0x88(%rbp)		/* if(args_cnt_sse == 0) */
	je	return_mmx_done			/*	goto return_mmx_done; */
	emms
return_mmx_done:
	mov	%rbp, %rsp
	pop	%rbp
	ret
