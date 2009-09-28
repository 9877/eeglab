#ifndef mxInfoH
#define mxInfoH
/*

  Header file for a simple wrapper for matlabs array types.

  $Id: mxInfo.h,v 1.1 2009-07-07 02:23:44 arno Exp $

 Copyright 2006-     by Jason D.R. Farquhar (jdrf@zepler.org)
 Permission is granted for anyone to copy, use, or modify this
 software and accompanying documents for any uncommercial
 purposes, provided this copyright notice is retained, and note is
 made of any changes that have been made. This software and
 documents are distributed without any warranty, express or
 implied

 */


/* use different memory allocation depending on MEX or generic code */
#ifdef MATLAB_MEX_FILE
#include "mex.h"
#include "matrix.h"
#define MALLOC mxMalloc
#define CALLOC mxCalloc
#define FREE   mxFree
#else
#include <stdlib.h>
#define MALLOC malloc
#define CALLOC calloc
#define FREE   free
#endif

/* check the compilier state to use the appropriate inline directive */
#ifdef __GNUC__ /* use the GNUC special form */
#define INLINE __inline__
#elif defined(__STDC__) && __STDC_VERSION__ >= 199901L /*C99 compat compilier*/
#define INLINE static inline
#else /* fall back on C89 version, i.e. *no inlines* */
#define INLINE
#endif

/* enum list for different data types -- MATCHED TO THE MATLAB ONES */
/* DEFINE LIST OF DATA TYPES -- N.B. use defines for pre-processor */
#define  LOGICAL_DTYPE 3
#define  CHAR_DTYPE    4
#define  DOUBLE_DTYPE  6
#define  SINGLE_DTYPE  7
#define  INT8_DTYPE    8
#define  UINT8_DTYPE   9
#define  INT16_DTYPE   10
#define  UINT16_DTYPE  11
#define  INT32_DTYPE   12
#define  UINT32_DTYPE  13
#define  INT64_DTYPE   14
#define  UINT64_DTYPE  15
typedef int MxInfoDTypes;

/*-------------------------------------------------------------------------*/
/* struct to hold useful info for iterating over a n-d matrix              */
/* e.g. for 3 x 3 x 3 matrix:
   ndim=3, numel=27, sz=[2 2 2], stride=[1 3 9] */
typedef struct {
  int nd;          /* number of dimensions of the matrix */
  int numel;       /* total number elements in the matrix */
  int *sz;         /* size of each matrix dimension */
  int *stride;     /* per dimension stride, up to 1 past nd */
  double *rp;      /* real data pointer */
  double *ip;      /* imaginary data pointer */
  MxInfoDTypes dtype; /* flag for the type of data the array holds */
} MxInfo;

/* MATLAB specific helper function */
#ifdef MATLAB_MEX_FILE
mxArray* mkmxArrayCopy(const MxInfo info);
/* convert back to mxArray */
mxArray* mkmxArray(const MxInfo info);
MxInfo mkmxInfo(const mxArray *mat, int nd);
#endif

MxInfo mkemptymxInfo(int nd);
MxInfo copymxInfo(const MxInfo inf);
void delmxInfo(MxInfo *minfo);
char isContiguous(const MxInfo info);
void copyData(const MxInfo info, const double *from, double *to);
int dsz_bytes(const MxInfo info);

int stride(const MxInfo info,int i);
int sz(const MxInfo info, int i);

/* /\* I wish all the C compiliers allowed inline! *\/ */
/* static INLINE int stride(const MxInfo info,int i){ */
/*   return (i<info.nd+1)?info.stride[i]:info.stride[info.nd];   */
/* } */
/* static INLINE int sz(const MxInfo info, int i){ */
/*     return (i<info.nd+1)?info.sz[i]:1;  */
/* } */

#endif
