program = test_scattdata
source  = $(wildcard *.F90)
SRC_DIR = ../../src

#===============================================================================
# Object Files
#===============================================================================

objects = \
$(SRC_DIR)/scattdata.o \
$(SRC_DIR)/ace_header.o \
$(SRC_DIR)/constants.o \
$(SRC_DIR)/dict_header.o \
$(SRC_DIR)/endf_header.o \
$(SRC_DIR)/error.o \
$(SRC_DIR)/freegas.o \
$(SRC_DIR)/global.o \
$(SRC_DIR)/interpolation.o \
$(SRC_DIR)/legendre.o \
$(SRC_DIR)/output.o \
$(SRC_DIR)/scatt.o \
$(SRC_DIR)/search.o \
$(SRC_DIR)/string.o \
test_scattdata.o

#===============================================================================
# User Options
#===============================================================================

COMPILER = gnu
DEBUG    = no
PROFILE  = no
OPTIMIZE = no
OPENMP   = no
MPI      = no
HDF5     = no

#===============================================================================
# External Library Paths
#===============================================================================

#~ MPI_DIR   = /opt/mpich/3.0.2-$(COMPILER)
#~ HDF5_DIR  = /opt/hdf5/1.8.10-patch1-$(COMPILER)

#===============================================================================
# Add git SHA-1 hash
#===============================================================================

GIT_SHA1 = $(shell git log -1 2>/dev/null | head -n 1 | awk '{print $$2}')

#===============================================================================
# GNU Fortran compiler options
#===============================================================================

ifeq ($(COMPILER),gnu)
  F90 = gfortran
  F90FLAGS := -cpp -fbacktrace -DNO_F2008
  LDFLAGS =

  # Debugging
  ifeq ($(DEBUG),yes)
    F90FLAGS += -g -Wall -pedantic -std=f2008 -fbounds-check \
                -ffpe-trap=invalid,overflow,underflow
    LDFLAGS  += -g
  endif

  # Profiling
  ifeq ($(PROFILE),yes)
    F90FLAGS += -pg
    LDFLAGS  += -pg
  endif
  
  # Code-Coverage
  ifeq ($(CODECOV),yes)
    F90FLAGS += -pg
    LDFLAGS  += -pg
  endif

  # Optimization
  ifeq ($(OPTIMIZE),yes)
    F90FLAGS += -O3 
  endif
endif

#===============================================================================
# Intel Fortran compiler options
#===============================================================================

ifeq ($(COMPILER),intel)
  F90 = ifort
  F90FLAGS := -fpp -warn -assume byterecl -traceback
  LDFLAGS =

  # Debugging
  ifeq ($(DEBUG),yes)
    F90FLAGS += -g -ftrapuv -fp-stack-check -check all -fpe0
    LDFLAGS  += -g
  endif

  # Profiling
  ifeq ($(PROFILE),yes)
    F90FLAGS += -pg 
    LDFLAGS  += -pg
  endif
  
  # Code-Coverage
  ifeq ($(CODECOV),yes)
    F90FLAGS += -pg -prof-gen=srcpos
    LDFLAGS  += -pg -prof-gen=srcpos
  endif

  # Optimization
  ifeq ($(OPTIMIZE),yes)
    F90FLAGS += -O3
  endif
endif

#===============================================================================
# Setup External Libraries
#===============================================================================

#~ # MPI for distributed-memory parallelism
#~ 
#~ ifeq ($(MPI),yes)
  #~ F90 = $(MPI_DIR)/bin/mpif90
  #~ F90FLAGS += -DMPI
#~ endif

# OpenMP for shared-memory parallelism

ifeq ($(OPENMP),yes)
	ifeq ($(COMPILER),intel)
    F90FLAGS += -openmp -DOPENMP
    LDFLAGS += -openmp
	endif

	ifeq ($(COMPILER),gnu)
    F90FLAGS += -fopenmp -DOPENMP
    LDFLAGS += -fopenmp
	endif
endif

#~ 
#~ # HDF5 for I/O
#~ 
#~ ifeq ($(HDF5),yes)
  #~ F90FLAGS += -DHDF5 -I$(HDF5_DIR)/include
  #~ LDFLAGS += -L$(HDF5_DIR)/lib64 $(HDF5_DIR)/lib64/libhdf5hl_fortran.a \
             #~ $(HDF5_DIR)/lib64/libhdf5_hl.a $(HDF5_DIR)/lib64/libhdf5_fortran.a \
             #~ $(HDF5_DIR)/lib64/libhdf5.a -lz -lrt -lm -Wl,-rpath -Wl,$(HDF5_DIR)/lib64
#~ endif

#===============================================================================
# Targets
#===============================================================================

all: $(program)
$(program): $(objects)
	$(F90) $(objects) $(LDFLAGS) -o $@
distclean: clean
clean:
	@rm -f *.o *.mod $(program)
neat:
	@rm -f *.o *.mod

#===============================================================================
# Rules
#===============================================================================

.SUFFIXES: .F90 .o
.PHONY: all clean neat distclean 

%.o: %.F90
	$(F90) $(F90FLAGS) -DGIT_SHA1="\"$(GIT_SHA1)\"" -I$(SRC_DIR) -c $<

#===============================================================================
# Dependencies
#===============================================================================

include $(SRC_DIR)/DEPENDENCIES
test_scattdata.o: $(SRC_DIR)/ace_header.o
test_scattdata.o: $(SRC_DIR)/constants.o
test_scattdata.o: $(SRC_DIR)/scatt.o
test_scattdata.o: $(SRC_DIR)/scattdata.o
