      SUBROUTINE INCTAB(ATAG,ATYP,NODE)

C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    INCTAB
C   PRGMMR: WOOLLEN          ORG: NP20       DATE: 1994-01-06
C
C ABSTRACT: THIS SUBROUTINE RETURNS THE NEXT AVAILABLE POSITIONAL INDEX
C   FOR WRITING INTO THE INTERNAL JUMP/LINK TABLE IN COMMON BLOCK
C   /BTABLES/, AND IT ALSO USES THAT INDEX TO STORE ATAG AND ATYP
C   WITHIN, RESPECTIVELY, THE INTERNAL JUMP/LINK TABLE ARRAYS TAG(*)
C   AND TYP(*).  IF THERE IS NO MORE ROOM FOR ADDITIONAL ENTRIES WITHIN
C   THE INTERNAL JUMP/LINK TABLE, THEN AN APPROPRIATE CALL IS MADE TO
C   BUFR ARCHIVE LIBRARY SUBROUTINE BORT.
C
C PROGRAM HISTORY LOG:
C 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C                           ROUTINE "BORT"
C 2003-11-04  J. ATOR    -- ADDED DOCUMENTATION
C 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C                           INTERDEPENDENCIES
C 2003-11-04  D. KEYSER  -- MAXJL (MAXIMUM NUMBER OF JUMP/LINK ENTRIES)
C                           INCREASED FROM 15000 TO 16000 (WAS IN
C                           VERIFICATION VERSION); UNIFIED/PORTABLE FOR
C                           WRF; ADDED HISTORY DOCUMENTATION; OUTPUTS
C                           MORE COMPLETE DIAGNOSTIC INFO WHEN ROUTINE
C                           TERMINATES ABNORMALLY
C
C USAGE:    CALL INCTAB (ATAG, ATYP, NODE)
C   INPUT ARGUMENT LIST:
C     ATAG     - CHARACTER*(*): MNEMONIC NAME
C     ATYP     - CHARACTER*(*): MNEMONIC TYPE
C
C   OUTPUT ARGUMENT LIST:
C     NODE     - INTEGER: NEXT AVAILABLE POSITIONAL INDEX FOR WRITING
C                INTO THE INTERNAL JUMP/LINK TABLE
C
C REMARKS:
C    THIS ROUTINE CALLS:        BORT
C    THIS ROUTINE IS CALLED BY: TABENT   TABSUB
C                               Normally not called by any application
C                               programs.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C   MACHINE:  PORTABLE TO ALL PLATFORMS
C
C$$$

      INCLUDE 'bufrlib.prm'

      COMMON /BTABLES/ MAXTAB,NTAB,TAG(MAXJL),TYP(MAXJL),KNT(MAXJL),
     .                JUMP(MAXJL),LINK(MAXJL),JMPB(MAXJL),
     .                IBT(MAXJL),IRF(MAXJL),ISC(MAXJL),
     .                ITP(MAXJL),VALI(MAXJL),KNTI(MAXJL),
     .                ISEQ(MAXJL,2),JSEQ(MAXJL)

      CHARACTER*(*) ATAG,ATYP
      CHARACTER*128 BORT_STR
      CHARACTER*10  TAG
      CHARACTER*3   TYP

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

      NTAB = NTAB+1
      IF(NTAB.GT.MAXTAB) GOTO 900
      TAG(NTAB) = ATAG
      TYP(NTAB) = ATYP
      NODE = NTAB

C  EXITS
C  -----

      RETURN
 900  WRITE(BORT_STR,'("BUFRLIB: INCTAB - THE NUMBER OF JUMP/LINK '//
     . 'TABLE ENTRIES EXCEEDS THE LIMIT, MAXTAB (",I7,")")') MAXTAB
      CALL BORT(BORT_STR)
      END