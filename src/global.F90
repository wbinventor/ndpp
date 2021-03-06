module global
!!! Most of these exist here because of dependencies in ace.F90. If I decide to
!!! rewrite ace.F90 in the future (likely b/c I can read the ace files much faster
!!! if I skip info I know I will not need), then I can revisit this file and
!!! remove lots of dependencies as well.
  use ace_header,       only: Nuclide, SAlphaBeta, xsListing, NuclideMicroXS
  use constants
  use dict_header,      only: DictCharInt
  use material_header,  only: Material

#ifdef MPI
  use mpi
#endif

#ifdef HDF5
  use hdf5_interface,  only: HID_T
#endif

  implicit none
  save

  ! ============================================================================
  ! MATERIALS-RELATED VARIABLES

  ! Main arrays
  type(Material), allocatable, target :: materials(:)

  integer :: n_materials ! # of materials

  ! ============================================================================
  ! INTEGRATION PARAMETERS

  ! Fraction of maximum s(a,b) value to use as cutoff for determining
  ! the range of integration
  real(8) :: SAB_THRESHOLD

  ! Brent root finding algorithm threshold for the mu variable
  real(8) :: BRENT_MU_THRESH

  ! Adaptive Simpsons integration (of mu) tolerance
  real(8) :: ADAPTIVE_MU_TOL

  ! Adaptive Simpsons integration (of mu) maximum recursion depth/iterations
  integer :: ADAPTIVE_MU_ITS

  ! Adaptive Simpsons integration (of Eout) tolerance
  real(8) :: ADAPTIVE_EOUT_TOL

  ! Adaptive Simpsons integration (of Eout) maximum recursion depth/iterations
  integer :: ADAPTIVE_EOUT_ITS

  ! Number of Eout points per bin for thermal scatter collisions
  integer :: SAB_EPTS_PER_BIN

  ! Number of Eout points per group for adaptive integration of CM to lab
  ! conversion of inelastic collisions
  integer :: NE_PER_GRP

  ! Number of points to extend the incoming energy grid (per ACE Ein) for elastic
  ! and inelastic group boundary effects
  integer :: EXTEND_PTS
  integer :: INEL_EXTEND_PTS

  ! ============================================================================
  ! CROSS SECTION RELATED VARIABLES

  ! Cross section arrays
  type(Nuclide),    allocatable, target :: nuclides(:)    ! Nuclide cross-sections
  type(SAlphaBeta), allocatable, target :: sab_tables(:)  ! S(a,b) tables
  type(XsListing),  allocatable, target :: xs_listings(:) ! cross_sections.xml listings

  ! Cross section caches
  type(NuclideMicroXS), allocatable :: micro_xs(:)  ! Cache for each nuclide

  integer :: n_nuclides_total ! Number of nuclide cross section tables
  integer :: n_sab_tables     ! Number of S(a,b) thermal scattering tables
  integer :: n_listings       ! Number of listings in cross_sections.xml

  ! Dictionaries to look up cross sections and listings
  type(DictCharInt) :: nuclide_dict
  type(DictCharInt) :: sab_dict
  type(DictCharInt) :: xs_listing_dict

  ! Unresolved resonance probablity tables
  logical :: urr_ptables_on = .true.

  ! ============================================================================
  ! PARALLEL PROCESSING VARIABLES

  ! The defaults set here for the number of processors, rank, and master and
  ! mpi_enabled flag are for when MPI is not being used at all, i.e. a serial
  ! run. In this case, these variables are still used at times.

  integer :: n_procs     = 1       ! number of processes
  integer :: rank        = 0       ! rank of process
  logical :: master      = .true.  ! master process?
  logical :: mpi_enabled = .false. ! is MPI in use and initialized?
  integer :: mpi_err               ! MPI error code

  ! ============================================================================
  ! HDF5 VARIABLES

#ifdef HDF5
  integer(HID_T) :: h5_file         ! identifier for output file
  integer(HID_T) :: hdf5_integer8_t ! type for integer(8)
#endif

  ! ============================================================================
  ! MISCELLANEOUS VARIABLES

  character(MAX_FILE_LEN) :: path_input          ! Path to input file

  ! Message used in message/warning/fatal_error
  character(MAX_LINE_LEN) :: message

  ! The verbosity controls how much information will be printed to the
  ! screen and in logs
  integer :: verbosity = 7

  ! Number of OpenMP threads to USE
  integer :: omp_threads

contains

!===============================================================================
! FREE_MEMORY deallocates all global allocatable arrays in the program
!===============================================================================

  subroutine free_memory()

    integer :: i ! Loop Index

    ! Deallocate materials
    if (allocated(materials)) deallocate(materials)

    ! Deallocate cross section data, listings, and cache
    if (allocated(nuclides)) then
    ! First call the clear routines
      do i = 1, size(nuclides)
        call nuclides(i) % clear()
      end do
      deallocate(nuclides)
    end if
    if (allocated(sab_tables)) deallocate(sab_tables)
    if (allocated(xs_listings)) deallocate(xs_listings)
    if (allocated(micro_xs)) deallocate(micro_xs)

    ! Deallocate dictionaries
    call nuclide_dict % clear()
    call sab_dict % clear()
    call xs_listing_dict % clear()

  end subroutine free_memory

end module global
