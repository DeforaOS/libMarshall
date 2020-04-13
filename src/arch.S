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



#include "arch/common.h"


.text


/* marshall_callp */
.global SYMBOL(marshall_callp)


/* amd64 */
#if defined(__amd64__)
# if defined(__APPLE__) \
	|| defined(__FreeBSD__) \
	|| defined(__linux__) \
	|| defined(__NetBSD__) \
	|| defined(__OpenBSD__)
#  include "arch/amd64/sysv.S"
# elif defined(_WIN64)
#  include "arch/amd64/x64.S"
# else
#  warning Unsupported AMD64 ABI
# endif

/* i386 */
#elif defined(__i386__)
# if defined(__FreeBSD__) \
	|| defined(__linux__) \
	|| defined(__NetBSD__) \
	|| defined(__OpenBSD__) \
	|| defined(_WIN32)
#  include "arch/i386/cdecl.S"
# else
#  warning Unsupported x86 ABI
# endif

/* Unknown */
#else
# warning Unsupported platform
#endif
