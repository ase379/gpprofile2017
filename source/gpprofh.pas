unit GpProfH;

interface

const
  PR_FREQUENCY   =  0; // .prf tags, never reuse them, always add new!
  PR_ENTERPROC   =  1;
  PR_EXITPROC    =  2;
  PR_UNITTABLE   =  3;
  PR_CLASSTABLE  =  4;
  PR_PROCTABLE   =  5;
  PR_PROCSIZE    =  6;
  PR_ENDDATA     =  7;
  PR_STARTDATA   =  8;
  PR_ENDHEADER   =  9;
  PR_COMPTICKS   = 10;
  PR_COMPTHREADS = 11;
  PR_PRFVERSION  = 12;
  PR_STARTCALIB  = 13;
  PR_ENDCALIB    = 14;
  PR_DIGEST      = 15;
  PR_DIGTHREADS  = 16;
  PR_DIGUNITS    = 17;
  PR_DIGCLASSES  = 18;
  PR_DIGPROCS    = 19;
  PR_DIGFREQ     = 20;
  PR_ENDDIGEST   = 21;
  PR_DIGESTVER   = 22;
  PR_DIGCALLG    = 23;
  PR_DIGENDCG    = -1;

  CALIB_CNT = 1000;

  CMD_MESSAGE = 'GPPROFILE_COMMAND';
  CMD_DONE    = 0;

  PRF_VERSION   = 4;
  PRF_DIGESTVER = 3;

implementation

end.
 