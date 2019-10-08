/*
            Copyright Oliver Kowalke 2009.
   Distributed under the Boost Software License, Version 1.0.
      (See accompanying file LICENSE_1_0.txt or copy at
          http://www.boost.org/LICENSE_1_0.txt)
*/

/*******************************************************
 *                                                     *
 *  -------------------------------------------------  *
 *  |  0  |  4  |  8  |  12 |  16 |  20 |  24 |  28 |  *
 *  -------------------------------------------------  *
 *  |bchai|hiddn|   fpscr   |  PC |  CR | R14 | R15 |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  |  32 |  36 |  40 |  44 |  48 |  52 |  56 |  60 |  *
 *  -------------------------------------------------  *
 *  | R16 | R17 | R18 | R19 | R20 | R21 | R22 | R23 |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  |  64 |  68 |  72 |  76 |  80 |  84 |  88 |  92 |  *
 *  -------------------------------------------------  *
 *  | R24 | R25 | R26 | R27 | R28 | R29 | R30 | R31 |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  |  96 | 100 | 104 | 108 | 112 | 116 | 120 | 124 |  *
 *  -------------------------------------------------  *
 *  |    F14    |    F15    |    F16    |    F17    |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  | 128 | 132 | 136 | 140 | 144 | 148 | 152 | 156 |  *
 *  -------------------------------------------------  *
 *  |    F18    |    F19    |    F20    |    F21    |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  | 160 | 164 | 168 | 172 | 176 | 180 | 184 | 188 |  *
 *  -------------------------------------------------  *
 *  |    F22    |    F23    |    F24    |    F25    |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  | 192 | 196 | 200 | 204 | 208 | 212 | 216 | 220 |  *
 *  -------------------------------------------------  *
 *  |    F26    |    F27    |    F28    |    F29    |  *
 *  -------------------------------------------------  *
 *  -------------------------                          *
 *  | 224 | 228 | 232 | 236 |                          *
 *  -------------------------                          *
 *  |    F30    |    F31    |                          *
 *  -------------------------                          *
 *                                                     *
 *******************************************************/

.file "ontop_ppc32_sysv_elf_gas.S"
.text
.globl ontop_fcontext
.align 2
.type ontop_fcontext,@function
ontop_fcontext:
    # Linux: ontop_fcontext( hidden transfer_t * R3, R4, R5, R6)
    # Other: transfer_t R3:R4 = jump_fcontext( R3, R4, R5)

    mflr  %r0  # return address from LR
    mffs  %f0  # FPSCR
    mfcr  %r8  # condition register

    stwu  %r1, -240(%r1)  # allocate stack space, R1 % R16 == 0
    stw   %r0, 244(%r1)   # save LR in caller's frame

#ifdef __linux__
    stw   %r3, 4(%r1)   # hidden pointer
#endif

    stfd  %f0, 8(%r1)   # FPSCR
    stw   %r0, 16(%r1)  # LR as PC
    stw   %r8, 20(%r1)  # CR

    # Save registers R14 to R31.
    # Don't change R13, the small data pointer.
    stw   %r14, 24(%r1)
    stw   %r15, 28(%r1)
    stw   %r16, 32(%r1)
    stw   %r17, 36(%r1)
    stw   %r18, 40(%r1)
    stw   %r19, 44(%r1)
    stw   %r20, 48(%r1)
    stw   %r21, 52(%r1)
    stw   %r22, 56(%r1)
    stw   %r23, 60(%r1)
    stw   %r24, 64(%r1)
    stw   %r25, 68(%r1)
    stw   %r26, 72(%r1)
    stw   %r27, 76(%r1)
    stw   %r28, 80(%r1)
    stw   %r29, 84(%r1)
    stw   %r30, 88(%r1)
    stw   %r31, 92(%r1)

    # Save registers F14 to F31 in slots with 8-byte alignment.
    # 4-byte alignment may stall the pipeline of some processors.
    # Less than 4 may cause alignment traps.
    stfd  %f14, 96(%r1)
    stfd  %f15, 104(%r1)
    stfd  %f16, 112(%r1)
    stfd  %f17, 120(%r1)
    stfd  %f18, 128(%r1)
    stfd  %f19, 136(%r1)
    stfd  %f20, 144(%r1)
    stfd  %f21, 152(%r1)
    stfd  %f22, 160(%r1)
    stfd  %f23, 168(%r1)
    stfd  %f24, 176(%r1)
    stfd  %f25, 184(%r1)
    stfd  %f26, 192(%r1)
    stfd  %f27, 200(%r1)
    stfd  %f28, 208(%r1)
    stfd  %f29, 216(%r1)
    stfd  %f30, 224(%r1)
    stfd  %f31, 232(%r1)

    # store RSP (pointing to context-data) in R7
    mr  %r7, %r1

    # restore RSP (pointing to context-data) from R4/R3
    # set CTR to ontop-function from R6/R5
#ifdef __linux__
    mr   %r1, %r4
    lwz  %r3, 4(%r1)   # hidden pointer
    mtctr  %r6
#else
    mr   %r1, %r3
    mtctr  %r5
#endif

    # ignore PC
    lfd  %f0, 8(%r1)   # FPSCR
    lwz  %r8, 20(%r1)  # CR

    mtfsf  0xff, %f0   # restore FPSCR
    mtcr   %r8         # restore CR

    # restore R14 to R31
    lwz  %r14, 24(%r1)
    lwz  %r15, 28(%r1)
    lwz  %r16, 32(%r1)
    lwz  %r17, 36(%r1)
    lwz  %r18, 40(%r1)
    lwz  %r19, 44(%r1)
    lwz  %r20, 48(%r1)
    lwz  %r21, 52(%r1)
    lwz  %r22, 56(%r1)
    lwz  %r23, 60(%r1)
    lwz  %r24, 64(%r1)
    lwz  %r25, 68(%r1)
    lwz  %r26, 72(%r1)
    lwz  %r27, 76(%r1)
    lwz  %r28, 80(%r1)
    lwz  %r29, 84(%r1)
    lwz  %r30, 88(%r1)
    lwz  %r31, 92(%r1)

    # restore F14 to F31
    lfd  %f14, 96(%r1)
    lfd  %f15, 104(%r1)
    lfd  %f16, 112(%r1)
    lfd  %f17, 120(%r1)
    lfd  %f18, 128(%r1)
    lfd  %f19, 136(%r1)
    lfd  %f20, 144(%r1)
    lfd  %f21, 152(%r1)
    lfd  %f22, 160(%r1)
    lfd  %f23, 168(%r1)
    lfd  %f24, 176(%r1)
    lfd  %f25, 184(%r1)
    lfd  %f26, 192(%r1)
    lfd  %f27, 200(%r1)
    lfd  %f28, 208(%r1)
    lfd  %f29, 216(%r1)
    lfd  %f30, 224(%r1)
    lfd  %f31, 232(%r1)

    # keep LR in caller's frame
    # adjust stack
    addi  %r1, %r1, 240
    # FALLTHROUGH to ontop_fcontext_tail
.size ontop_fcontext, .-ontop_fcontext

/*
 * Linux: CTR( hidden transfer_t * R3, R4 = &transfer_t{ R7, R5 })
 * Other: transfer_t R3:R4 = CTR( R3 = &transfer_t{ R7, R4 })
 *
 * To pass the transfer_t as a pointer, we must allocate 8 bytes of
 * memory.  We do this with ontop_fcontext_tail, a separate function
 * with its own stack frame.  If the ontop-function in CTR throws a
 * C++ exception, then our .eh_frame will remove the stack frame.
 */

.type ontop_fcontext_tail,@function
ontop_fcontext_tail:
    stwu  %r1, -16(%r1)  # allocate stack space, R1 % R16 == 0
7:  stw   %r7, 8(%r1)
#ifdef __linux__
    stw   %r5, 12(%r1)
    la    %r4, 8(%r1)    # address of transfer_t
#else
    stw   %r4, 12(%r1)
    la    %r3, 8(%r1)    # address of transfer_t
#endif
    bctrl                # call ontop-function
    lwz   %r0, 20(%r1)
8:  mtlr  %r0            # restore LR from caller's frame
    addi  %r1, %r1, 16   # adjust stack
    blr                  # return what ontop-function returned
.size ontop_fcontext_tail, .-ontop_fcontext_tail

/* constants for exception handling */
#define DW_EH_PE_sdata4            0x0b  /* pointer encoding */
#define DW_EH_PE_pcrel             0x10
#define DW_CFA_def_cfa             0x0c  /* define canonical frame address */
#define DW_CFA_def_cfa_offset      0x0e  /* define cfa offset */
#define DW_CFA_offset_extended_sf  0x11  /* save register at offset */
/* register numbers from GCC, not DWARF */
#define GCC_r1                      0x1  /* stack pointer */
#define GCC_lr                     0x41  /* link register */

.section .eh_frame,"a",%progbits

/*
 * Common Information Entry: This came from g++ -S of gcc 8.3.0.
 */
9:  .4byte    2f - 1f         # length of entry
1:  .4byte    0               # CIE
    .byte     0x1             # version
    .string   "zR"            # augmentation string
    .uleb128  0x1             # code alignment factor
    .sleb128  -4              # data alignment factor
    .byte     GCC_lr          # return address register
    .uleb128  0x1             # length of augmentation data
    # 'R' pointer encoding
    .byte     DW_EH_PE_sdata4 | DW_EH_PE_pcrel
    # call frame information
    .byte     DW_CFA_def_cfa
    .uleb128  GCC_r1
    .uleb128  0               # cfa at 0(%r1)
    .align    2
2:

/*
 * Frame Description Entry: This entry describes only the part of
 * ontop_fcontext_tail around the ontop-function call.  If the call
 * throws an exception, this should be enough to remove the stack
 * frame of ontop_fcontext_tail.
 */
    .4byte    2f - 1f         # length of entry
1:  .4byte    . - 9b          # CIE
    .4byte    7b - .          # beginning of code
    .4byte    8b - 7b         # length of code
    .uleb128  0               # length of augmentation data
    # call frame information
    .byte     DW_CFA_def_cfa_offset
    .uleb128  0x10            # cfa at 16(%r1)
    .byte     DW_CFA_offset_extended_sf
    .uleb128  GCC_lr
    .sleb128  -1              # lr at 4(cfa)
    .align    2
2:

/* Mark that we don't need executable stack.  */
.section .note.GNU-stack,"",%progbits
