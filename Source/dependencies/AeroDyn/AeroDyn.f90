!**********************************************************************************************************************************
! LICENSING
! Copyright (C) 2015  National Renewable Energy Laboratory
!
!    This file is part of AeroDyn.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!
!**********************************************************************************************************************************
! File last committed: $Date: 2015-10-03 21:17:42 -0600 (Sat, 03 Oct 2015) $
! (File) Revision #: $Rev: 166 $
! URL: $HeadURL: https://windsvn.nrel.gov/WT_Perf/branches/v4.x/Source/dependencies/AeroDyn/AeroDyn.f90 $
!**********************************************************************************************************************************
module AeroDyn
    
   use NWTC_Library
   use AeroDyn_Types
   use AeroDyn_IO
   use BEMT
   use AirfoilInfo
   use NWTC_LAPACK
   
   
   implicit none

   private
         

   ! ..... Public Subroutines ...................................................................................................

   public :: AD_Init                           ! Initialization routine
   public :: AD_End                            ! Ending routine (includes clean up)

   public :: AD_UpdateStates                   ! Loose coupling routine for solving for constraint states, integrating
                                               !   continuous states, and updating discrete states
   public :: AD_CalcOutput                     ! Routine for computing outputs

   public :: AD_CalcConstrStateResidual        ! Tight coupling routine for returning the constraint state residual
   
  
contains    
!----------------------------------------------------------------------------------------------------------------------------------   
subroutine AD_SetInitOut(p, InitOut, errStat, errMsg)

   type(AD_InitOutputType),       intent(  out)  :: InitOut          ! output data
   type(AD_ParameterType),        intent(in   )  :: p                ! Parameters
   integer(IntKi),                intent(inout)  :: errStat          ! Error status of the operation
   character(*),                  intent(inout)  :: errMsg           ! Error message if ErrStat /= ErrID_None


      ! Local variables
   integer(intKi)                               :: ErrStat2          ! temporary Error status
   character(ErrMsgLen)                         :: ErrMsg2           ! temporary Error message
   character(*), parameter                      :: RoutineName = 'AD_SetInitOut'
   
   
   
   integer(IntKi)                               :: i
#ifdef DBG_OUTS
   integer(IntKi)                               :: j, k, m
   character(5)                                 ::chanPrefix
#endif   
      ! Initialize variables for this routine

   errStat = ErrID_None
   errMsg  = ""
   
   InitOut%AirDens = p%AirDens
   
   call AllocAry( InitOut%WriteOutputHdr, p%numOuts, 'WriteOutputHdr', errStat2, errMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
   
   call AllocAry( InitOut%WriteOutputUnt, p%numOuts, 'WriteOutputUnt', errStat2, errMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )

   
#ifdef DBG_OUTS
   ! Loop over blades and nodes to populate the output channel names and units
   
   do k=1,p%numBlades
      do j=1, p%NumBlNds
         
         m = (k-1)*p%NumBlNds*23 + (j-1)*23 
         
         chanPrefix = "B"//trim(num2lstr(k))//"N"//trim(num2lstr(j))
         InitOut%WriteOutputHdr( m + 1 ) = trim(chanPrefix)//"Twst"
         InitOut%WriteOutputUnt( m + 1 ) = '  (deg)  '
         InitOut%WriteOutputHdr( m + 2 ) = trim(chanPrefix)//"Psi"
         InitOut%WriteOutputUnt( m + 2 ) = '  (deg)  '
         InitOut%WriteOutputHdr( m + 3 ) = trim(chanPrefix)//"Vx"
         InitOut%WriteOutputUnt( m + 3 ) = '  (m/s)  '
         InitOut%WriteOutputHdr( m + 4 ) = trim(chanPrefix)//"Vy"
         InitOut%WriteOutputUnt( m + 4 ) = '  (m/s)  '
         InitOut%WriteOutputHdr( m + 5 ) = ' '//trim(chanPrefix)//"AIn"
         InitOut%WriteOutputUnt( m + 5 ) = '  (deg)  '
         InitOut%WriteOutputHdr( m + 6 ) = ' '//trim(chanPrefix)//"ApIn"
         InitOut%WriteOutputUnt( m + 6 ) = '  (deg)  '
         InitOut%WriteOutputHdr( m + 7 ) = trim(chanPrefix)//"Vrel"
         InitOut%WriteOutputUnt( m + 7 ) = '  (m/s)  '
         InitOut%WriteOutputHdr( m + 8 ) = ' '//trim(chanPrefix)//"Phi"
         InitOut%WriteOutputUnt( m + 8 ) = '  (deg)  '
         InitOut%WriteOutputHdr( m + 9 ) = ' '//trim(chanPrefix)//"AOA"
         InitOut%WriteOutputUnt( m + 9 ) = '  (deg)  '
         InitOut%WriteOutputHdr( m + 10 ) = ' '//trim(chanPrefix)//"Cl"
         InitOut%WriteOutputUnt( m + 10 ) = '   (-)   '
         InitOut%WriteOutputHdr( m + 11 ) = ' '//trim(chanPrefix)//"Cd"
         InitOut%WriteOutputUnt( m + 11 ) = '   (-)   '
         InitOut%WriteOutputHdr( m + 12 ) = ' '//trim(chanPrefix)//"Cm"
         InitOut%WriteOutputUnt( m + 12 ) = '   (-)   '
         InitOut%WriteOutputHdr( m + 13 ) = ' '//trim(chanPrefix)//"Cx"
         InitOut%WriteOutputUnt( m + 13 ) = '   (-)   '
         InitOut%WriteOutputHdr( m + 14 ) = ' '//trim(chanPrefix)//"Cy"
         InitOut%WriteOutputUnt( m + 14 ) = '   (-)   '
         InitOut%WriteOutputHdr( m + 15 ) = ' '//trim(chanPrefix)//"Cn"
         InitOut%WriteOutputUnt( m + 15 ) = '   (-)   '
         InitOut%WriteOutputHdr( m + 16 ) = ' '//trim(chanPrefix)//"Ct"
         InitOut%WriteOutputUnt( m + 16 ) = '   (-)   '
         InitOut%WriteOutputHdr( m + 17 ) = ' '//trim(chanPrefix)//"Fl"
         InitOut%WriteOutputUnt( m + 17 ) = '  (N/m)  '
         InitOut%WriteOutputHdr( m + 18 ) = ' '//trim(chanPrefix)//"Fd"
         InitOut%WriteOutputUnt( m + 18 ) = '  (N/m)  '
         InitOut%WriteOutputHdr( m + 19 ) = ' '//trim(chanPrefix)//"M"
         InitOut%WriteOutputUnt( m + 19 ) = ' (N/m^2) '
         InitOut%WriteOutputHdr( m + 20 ) = ' '//trim(chanPrefix)//"Fx"
         InitOut%WriteOutputUnt( m + 20 ) = '  (N/m)  '
         InitOut%WriteOutputHdr( m + 21 ) = ' '//trim(chanPrefix)//"Fy"
         InitOut%WriteOutputUnt( m + 21 ) = '  (N/m)  '
         InitOut%WriteOutputHdr( m + 22 ) = ' '//trim(chanPrefix)//"Fn"
         InitOut%WriteOutputUnt( m + 22 ) = '  (N/m)  '
         InitOut%WriteOutputHdr( m + 23 ) = ' '//trim(chanPrefix)//"Ft"
         InitOut%WriteOutputUnt( m + 23 ) = '  (N/m)  '
         
      end do
   end do
#else
   do i=1,p%NumOuts
      InitOut%WriteOutputHdr(i) = p%OutParam(i)%Name
      InitOut%WriteOutputUnt(i) = p%OutParam(i)%Units
   end do
#endif
  
        
      
   if (ErrStat >= AbortErrLev) return
   
   
   
   InitOut%Ver = AD_Ver
   
end subroutine AD_SetInitOut
!----------------------------------------------------------------------------------------------------------------------------------   
subroutine AD_Init( InitInp, u, p, x, xd, z, OtherState, y, Interval, InitOut, ErrStat, ErrMsg )
! This routine is called at the start of the simulation to perform initialization steps.
! The parameters are set here and not changed during the simulation.
! The initial states and initial guess for the input are defined.
!..................................................................................................................................

   type(AD_InitInputType),       intent(in   ) :: InitInp       ! Input data for initialization routine
   type(AD_InputType),           intent(  out) :: u             ! An initial guess for the input; input mesh must be defined
   type(AD_ParameterType),       intent(  out) :: p             ! Parameters
   type(AD_ContinuousStateType), intent(  out) :: x             ! Initial continuous states
   type(AD_DiscreteStateType),   intent(  out) :: xd            ! Initial discrete states
   type(AD_ConstraintStateType), intent(  out) :: z             ! Initial guess of the constraint states
   type(AD_OtherStateType),      intent(  out) :: OtherState    ! Initial other/optimization states
   type(AD_OutputType),          intent(  out) :: y             ! Initial system outputs (outputs are not calculated;
                                                                !   only the output mesh is initialized)
   real(DbKi),                   intent(inout) :: interval      ! Coupling interval in seconds: the rate that
                                                                !   (1) AD_UpdateStates() is called in loose coupling &
                                                                !   (2) AD_UpdateDiscState() is called in tight coupling.
                                                                !   Input is the suggested time from the glue code;
                                                                !   Output is the actual coupling interval that will be used
                                                                !   by the glue code.
   type(AD_InitOutputType),      intent(  out) :: InitOut       ! Output for initialization routine
   integer(IntKi),               intent(  out) :: errStat       ! Error status of the operation
   character(*),                 intent(  out) :: errMsg        ! Error message if ErrStat /= ErrID_None
   

      ! Local variables
   integer(IntKi)                              :: errStat2      ! temporary error status of the operation
   character(ErrMsgLen)                        :: errMsg2       ! temporary error message 
      
   type(AD_InputFile)                          :: InputFileData ! Data stored in the module's input file
   integer(IntKi)                              :: UnEcho        ! Unit number for the echo file
   
   character(*), parameter                     :: RoutineName = 'AD_Init'
   
   
      ! Initialize variables for this routine

   errStat = ErrID_None
   errMsg  = ""
   UnEcho  = -1

      ! Initialize the NWTC Subroutine Library

   call NWTC_Init( EchoLibVer=.FALSE. )

      ! Display the module information

   call DispNVD( AD_Ver )
   
   
   p%NumBlades = InitInp%NumBlades ! need this before reading the AD input file so that we know how many blade files to read
   !bjj: note that we haven't validated p%NumBlades before using it below!
   p%RootName  = TRIM(InitInp%RootName)//'.AD'
   
      ! Read the primary AeroDyn input file
   call ReadInputFiles( InitInp%InputFile, InputFileData, interval, p%RootName, p%NumBlades, UnEcho, ErrStat2, ErrMsg2 )   
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
      if (ErrStat >= AbortErrLev) then
         call Cleanup()
         return
      end if
         
      
      ! Validate the inputs
   call ValidateInputData( InputFileData, p%NumBlades, ErrStat2, ErrMsg2 )
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
      if (ErrStat >= AbortErrLev) then
         call Cleanup()
         return
      end if
      
      !............................................................................................
      ! Define parameters
      !............................................................................................
      
      ! Initialize AFI module (read Airfoil tables)
   call Init_AFIparams( InputFileData, p%AFI, UnEcho, p%NumBlades, ErrStat2, ErrMsg2 )
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
      if (ErrStat >= AbortErrLev) then
         call Cleanup()
         return
      end if
         
      
      ! set the rest of the parameters
   call SetParameters( InitInp, InputFileData, p, ErrStat2, ErrMsg2 )
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
      if (ErrStat >= AbortErrLev) then
         call Cleanup()
         return
      end if
   
      !............................................................................................
      ! Define and initialize inputs here 
      !............................................................................................
   
   call Init_u( u, p, InputFileData, InitInp, errStat2, errMsg2 ) 
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
      if (ErrStat >= AbortErrLev) then
         call Cleanup()
         return
      end if

      ! 

      !............................................................................................
      ! Initialize the BEMT module (also sets other variables for sub module)
      !............................................................................................
      
   !if (p%WakeMod == WakeMod_BEMT) then
      ! initialize BEMT after setting parameters and inputs because we are going to use the already-
      ! calculated node positions from the input meshes
      
      call Init_BEMTmodule( InputFileData, u, OtherState%BEMT_u, p, x%BEMT, xd%BEMT, z%BEMT, &
                            OtherState%BEMT, OtherState%BEMT_y, ErrStat2, ErrMsg2 )
         call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
         if (ErrStat >= AbortErrLev) then
            call Cleanup()
            return
         end if
         
   !end if      
      
      
      !............................................................................................
      ! Define outputs here
      !............................................................................................
   call Init_y(y, u, p, errStat2, errMsg2) ! do this after input meshes have been initialized
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
   
   
      !............................................................................................
      ! Initialize states
      !............................................................................................
      
      ! many states are in the BEMT module, which were initialized in BEMT_Init()
      
   call Init_OtherStates(OtherState, p, u, y, errStat2, errMsg2)
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
      
      !............................................................................................
      ! Define initialization output here
      !............................................................................................
   call AD_SetInitOut(p, InitOut, errStat2, errMsg2)
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
   
      
      !............................................................................................
      ! Print the summary file if requested:
      !............................................................................................
   if (InputFileData%SumPrint) then
      call AD_PrintSum( InputFileData, p, u, y, OtherState, ErrStat2, ErrMsg2 )
         call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )
   end if
      
            
   call Cleanup() 
      
contains
   subroutine Cleanup()

      CALL AD_DestroyInputFile( InputFileData, ErrStat2, ErrMsg2 )
      IF ( UnEcho > 0 ) CLOSE( UnEcho )
      
   end subroutine Cleanup

end subroutine AD_Init
!----------------------------------------------------------------------------------------------------------------------------------   
subroutine Init_OtherStates(OtherState, p, u, y, errStat, errMsg)
   type(AD_OtherStateType),       intent(inout)  :: OtherState       ! Otherstate data (not defined in submodules)
   type(AD_ParameterType),        intent(in   )  :: p                ! Parameters
   type(AD_InputType),            intent(inout)  :: u                ! input for HubMotion mesh (create sibling mesh here)
   type(AD_OutputType),           intent(in   )  :: y                ! output (create mapping between output and otherstate mesh here)
   integer(IntKi),                intent(inout)  :: errStat          ! Error status of the operation
   character(*),                  intent(inout)  :: errMsg           ! Error message if ErrStat /= ErrID_None


      ! Local variables
   integer(intKi)                               :: k
   integer(intKi)                               :: ErrStat2          ! temporary Error status
   character(ErrMsgLen)                         :: ErrMsg2           ! temporary Error message
   character(*), parameter                      :: RoutineName = 'Init_OtherStates'

      ! Initialize variables for this routine

   errStat = ErrID_None
   errMsg  = ""
   
   call AllocAry( OtherState%DisturbedInflow, 3_IntKi, p%NumBlNds, p%numBlades, 'OtherState%DisturbedInflow', ErrStat2, ErrMsg2 ) ! must be same size as u%InflowOnBlade
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
   call AllocAry( OtherState%WithoutSweepPitchTwist, 3_IntKi, 3_IntKi, p%NumBlNds, p%numBlades, 'OtherState%WithoutSweepPitchTwist', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
      
         ! arrays for output
#ifdef DBG_OUTS
   allocate( OtherState%AllOuts(0:p%NumOuts), STAT=ErrStat2 ) ! allocate starting at zero to account for invalid output channels
#else
   allocate( OtherState%AllOuts(0:MaxOutPts), STAT=ErrStat2 ) ! allocate starting at zero to account for invalid output channels
#endif
      if (ErrStat2 /= 0) then
         call SetErrStat( ErrID_Fatal, "Error allocating AllOuts.", errStat, errMsg, RoutineName )
         return
      end if
   OtherState%AllOuts = 0.0_ReKi
   
      ! save these tower calculations for output:
   call AllocAry( OtherState%W_Twr, p%NumTwrNds, 'OtherState%W_Twr', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
   call AllocAry( OtherState%X_Twr, p%NumTwrNds, 'OtherState%X_Twr', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
   call AllocAry( OtherState%Y_Twr, p%NumTwrNds, 'OtherState%Y_Twr', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
      ! save blade calculations for output:
   call AllocAry( OtherState%Curve, p%NumBlNds, p%NumBlades, 'OtherState%Curve', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
   call AllocAry( OtherState%X, p%NumBlNds, p%NumBlades, 'OtherState%X', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
   call AllocAry( OtherState%Y, p%NumBlNds, p%NumBlades, 'OtherState%Y', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
   call AllocAry( OtherState%M, p%NumBlNds, p%NumBlades, 'OtherState%M', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
      ! mesh mapping data for integrating load over entire rotor:
   allocate( OtherState%B_L_2_H_P(p%NumBlades), Stat = ErrStat2)
      if (ErrStat2 /= 0) then
         call SetErrStat( ErrID_Fatal, "Error allocating B_L_2_H_P mapping structure.", errStat, errMsg, RoutineName )
         return
      end if

   call MeshCopy (  SrcMesh  = u%HubMotion        &
                  , DestMesh = OtherState%HubLoad &
                  , CtrlCode = MESH_SIBLING       &
                  , IOS      = COMPONENT_OUTPUT   &
                  , force    = .TRUE.             &
                  , moment   = .TRUE.             &
                  , ErrStat  = ErrStat2           &
                  , ErrMess  = ErrMsg2            )
   
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
      if (ErrStat >= AbortErrLev) RETURN         
   
   do k=1,p%NumBlades
      CALL MeshMapCreate( y%BladeLoad(k), OtherState%HubLoad, OtherState%B_L_2_H_P(k), ErrStat2, ErrMsg2 )
         CALL SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName//':B_L_2_H_P('//TRIM(Num2LStr(K))//')' )
   end do
   
   if (ErrStat >= AbortErrLev) RETURN

   ! 
   if (p%NumTwrNds > 0) then
      OtherState%W_Twr = 0.0_ReKi
      OtherState%X_Twr = 0.0_ReKi
      OtherState%Y_Twr = 0.0_ReKi
   end if
   
   
   
end subroutine Init_OtherStates
!----------------------------------------------------------------------------------------------------------------------------------   
subroutine Init_y(y, u, p, errStat, errMsg)
   type(AD_OutputType),           intent(  out)  :: y               ! Module outputs
   type(AD_InputType),            intent(inout)  :: u               ! Module inputs -- intent(out) because of mesh sibling copy
   type(AD_ParameterType),        intent(in   )  :: p               ! Parameters
   integer(IntKi),                intent(inout)  :: errStat         ! Error status of the operation
   character(*),                  intent(inout)  :: errMsg          ! Error message if ErrStat /= ErrID_None


      ! Local variables
   integer(intKi)                               :: k                 ! loop counter for blades
   integer(intKi)                               :: ErrStat2          ! temporary Error status
   character(ErrMsgLen)                         :: ErrMsg2           ! temporary Error message
   character(*), parameter                      :: RoutineName = 'Init_y'

      ! Initialize variables for this routine

   errStat = ErrID_None
   errMsg  = ""
   
         
   if (p%TwrAero) then
            
      call MeshCopy ( SrcMesh  = u%TowerMotion    &
                    , DestMesh = y%TowerLoad      &
                    , CtrlCode = MESH_SIBLING     &
                    , IOS      = COMPONENT_OUTPUT &
                    , force    = .TRUE.           &
                    , moment   = .TRUE.           &
                    , ErrStat  = ErrStat2         &
                    , ErrMess  = ErrMsg2          )
   
         call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
         if (ErrStat >= AbortErrLev) RETURN         
         
         !y%TowerLoad%force = 0.0_ReKi  ! shouldn't have to initialize this
         !y%TowerLoad%moment= 0.0_ReKi  ! shouldn't have to initialize this
   else
      y%TowerLoad%nnodes = 0
   end if

   
   allocate( y%BladeLoad(p%numBlades), stat=ErrStat2 )
   if (errStat2 /= 0) then
      call SetErrStat( ErrID_Fatal, 'Error allocating y%BladeLoad.', ErrStat, ErrMsg, RoutineName )      
      return
   end if
   

   do k = 1, p%numBlades
   
      call MeshCopy ( SrcMesh  = u%BladeMotion(k) &
                    , DestMesh = y%BladeLoad(k)   &
                    , CtrlCode = MESH_SIBLING     &
                    , IOS      = COMPONENT_OUTPUT &
                    , force    = .TRUE.           &
                    , moment   = .TRUE.           &
                    , ErrStat  = ErrStat2         &
                    , ErrMess  = ErrMsg2          )
   
         call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName ) 
                           
   end do
   
   call AllocAry( y%WriteOutput, p%numOuts, 'WriteOutput', errStat2, errMsg2 )
      call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )
   if (ErrStat >= AbortErrLev) RETURN      
   
   
   
end subroutine Init_y
!----------------------------------------------------------------------------------------------------------------------------------
subroutine Init_u( u, p, InputFileData, InitInp, errStat, errMsg )
! This routine is called from AD_Init.
!  it allocates and initializes the inputs to AeroDyn
!..................................................................................................................................

   type(AD_InputType),           intent(  out)  :: u                 ! Input data
   type(AD_ParameterType),       intent(in   )  :: p                 ! Parameters
   type(AD_InputFile),           intent(in   )  :: InputFileData     ! Data stored in the module's input file
   type(AD_InitInputType),       intent(in   )  :: InitInp           ! Input data for AD initialization routine
   integer(IntKi),               intent(inout)  :: errStat           ! Error status of the operation
   character(*),                 intent(inout)  :: errMsg            ! Error message if ErrStat /= ErrID_None


      ! Local variables
   real(reKi)                                   :: position(3)       ! node reference position
   real(reKi)                                   :: positionL(3)      ! node local position
   real(R8Ki)                                   :: theta(3)          ! Euler angles
   real(R8Ki)                                   :: orientation(3,3)  ! node reference orientation
   real(R8Ki)                                   :: orientationL(3,3) ! node local orientation
   
   integer(intKi)                               :: j                 ! counter for nodes
   integer(intKi)                               :: k                 ! counter for blades
   
   integer(intKi)                               :: ErrStat2          ! temporary Error status
   character(ErrMsgLen)                         :: ErrMsg2           ! temporary Error message
   character(*), parameter                      :: RoutineName = 'Init_u'

      ! Initialize variables for this routine

   ErrStat = ErrID_None
   ErrMsg  = ""


      ! Arrays for InflowWind inputs:
   
   call AllocAry( u%InflowOnBlade, 3_IntKi, p%NumBlNds, p%numBlades, 'u%InflowOnBlade', ErrStat2, ErrMsg2 )
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
   call AllocAry( u%InflowOnTower, 3_IntKi, p%NumTwrNds, 'u%InflowOnTower', ErrStat2, ErrMsg2 ) ! could be size zero
      call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
                
   if (errStat >= AbortErrLev) return      
      
   u%InflowOnBlade = 0.0_ReKi
   
      ! Meshes for motion inputs (ElastoDyn and/or BeamDyn)
         !................
         ! tower
         !................
   if (p%NumTwrNds > 0) then
      
      u%InflowOnTower = 0.0_ReKi 
      
      call MeshCreate ( BlankMesh = u%TowerMotion   &
                       ,IOS       = COMPONENT_INPUT &
                       ,Nnodes    = p%NumTwrNds     &
                       ,ErrStat   = ErrStat2        &
                       ,ErrMess   = ErrMsg2         &
                       ,Orientation     = .true.    &
                       ,TranslationDisp = .true.    &
                       ,TranslationVel  = .true.    &
                       ,RotationVel     = .true.    &
                      )
            call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )

      if (errStat >= AbortErrLev) return
            
         ! set node initial position/orientation
      position = 0.0_ReKi
      do j=1,p%NumTwrNds         
         position(3) = InputFileData%TwrElev(j)
         
         call MeshPositionNode(u%TowerMotion, j, position, errStat2, errMsg2)  ! orientation is identity by default
            call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
      end do !j
         
         ! create line2 elements
      do j=1,p%NumTwrNds-1
         call MeshConstructElement( u%TowerMotion, ELEMENT_LINE2, errStat2, errMsg2, p1=j, p2=j+1 )
            call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
      end do !j
            
      call MeshCommit(u%TowerMotion, errStat2, errMsg2 )
         call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
            
      if (errStat >= AbortErrLev) return

      
      u%TowerMotion%Orientation     = u%TowerMotion%RefOrientation
      u%TowerMotion%TranslationDisp = 0.0_R8Ki
      u%TowerMotion%TranslationVel  = 0.0_ReKi
      u%TowerMotion%RotationVel     = 0.0_ReKi
      
   end if ! we compute tower loads
   
         !................
         ! hub
         !................
   
      call MeshCreate ( BlankMesh = u%HubMotion     &
                       ,IOS       = COMPONENT_INPUT &
                       ,Nnodes    = 1               &
                       ,ErrStat   = ErrStat2        &
                       ,ErrMess   = ErrMsg2         &
                       ,Orientation     = .true.    &
                       ,TranslationDisp = .true.    &
                       ,TranslationVel  = .true.    &
                       ,RotationVel     = .true.    &
                      )
            call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )

      if (errStat >= AbortErrLev) return
                     
      call MeshPositionNode(u%HubMotion, 1, InitInp%HubPosition, errStat2, errMsg2, InitInp%HubOrientation)
         call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
         
      call MeshConstructElement( u%HubMotion, ELEMENT_POINT, errStat2, errMsg2, p1=1 )
         call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
            
      call MeshCommit(u%HubMotion, errStat2, errMsg2 )
         call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
            
      if (errStat >= AbortErrLev) return

         
      u%HubMotion%Orientation     = u%HubMotion%RefOrientation
      u%HubMotion%TranslationDisp = 0.0_R8Ki
      u%HubMotion%TranslationVel  = 0.0_ReKi
      u%HubMotion%RotationVel     = 0.0_ReKi   
      
   
         !................
         ! blade roots
         !................
         
      allocate( u%BladeRootMotion(p%NumBlades), STAT = ErrStat2 )
      if (ErrStat2 /= 0) then
         call SetErrStat( ErrID_Fatal, 'Error allocating u%BladeRootMotion array.', ErrStat, ErrMsg, RoutineName )
         return
      end if      
      
      do k=1,p%NumBlades
         call MeshCreate ( BlankMesh = u%BladeRootMotion(k)                  &
                          ,IOS       = COMPONENT_INPUT                       &
                          ,Nnodes    = 1                                     &
                          ,ErrStat   = ErrStat2                              &
                          ,ErrMess   = ErrMsg2                               &
                          ,Orientation     = .true.                          &
                          ,TranslationDisp = .true.                          &
                          ,TranslationVel  = .true.                          &
                          ,RotationVel     = .true.                          &
                         )
               call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )

         if (errStat >= AbortErrLev) return
            
         call MeshPositionNode(u%BladeRootMotion(k), 1, InitInp%BladeRootPosition(:,k), errStat2, errMsg2, InitInp%BladeRootOrientation(:,:,k))
            call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
                     
         call MeshConstructElement( u%BladeRootMotion(k), ELEMENT_POINT, errStat2, errMsg2, p1=1 )
            call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
            
         call MeshCommit(u%BladeRootMotion(k), errStat2, errMsg2 )
            call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
            
         if (errStat >= AbortErrLev) return

      
         u%BladeRootMotion(k)%Orientation     = u%BladeRootMotion(k)%RefOrientation
         u%BladeRootMotion(k)%TranslationDisp = 0.0_R8Ki
         u%BladeRootMotion(k)%TranslationVel  = 0.0_ReKi
         u%BladeRootMotion(k)%RotationVel     = 0.0_ReKi
   
   end do !k=numBlades      
      
      
         !................
         ! blades
         !................
   
      allocate( u%BladeMotion(p%NumBlades), STAT = ErrStat2 )
      if (ErrStat2 /= 0) then
         call SetErrStat( ErrID_Fatal, 'Error allocating u%BladeMotion array.', ErrStat, ErrMsg, RoutineName )
         return
      end if
      
      do k=1,p%NumBlades
         call MeshCreate ( BlankMesh = u%BladeMotion(k)                     &
                          ,IOS       = COMPONENT_INPUT                      &
                          ,Nnodes    = InputFileData%BladeProps(k)%NumBlNds &
                          ,ErrStat   = ErrStat2                             &
                          ,ErrMess   = ErrMsg2                              &
                          ,Orientation     = .true.                         &
                          ,TranslationDisp = .true.                         &
                          ,TranslationVel  = .true.                         &
                          ,RotationVel     = .true.                         &
                         )
               call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )

         if (errStat >= AbortErrLev) return
            
                        
         do j=1,InputFileData%BladeProps(k)%NumBlNds

               ! reference position of the jth node in the kth blade, relative to the root in the local blade coordinate system:
            positionL(1) = InputFileData%BladeProps(k)%BlCrvAC(j)
            positionL(2) = InputFileData%BladeProps(k)%BlSwpAC(j)
            positionL(3) = InputFileData%BladeProps(k)%BlSpn(  j)
            
               ! reference position of the jth node in the kth blade:
            position = u%BladeRootMotion(k)%Position(:,1) + matmul(positionL,u%BladeRootMotion(k)%RefOrientation(:,:,1))  ! note that because positionL is a 1-D array, we're doing the transpose of matmul(transpose(u%BladeRootMotion(k)%RefOrientation),positionL)

            
               ! reference orientation of the jth node in the kth blade, relative to the root in the local blade coordinate system:
            theta(1)     =  0.0_R8Ki
            theta(2)     =  InputFileData%BladeProps(k)%BlCrvAng(j)
            theta(3)     = -InputFileData%BladeProps(k)%BlTwist( j)            
            orientationL = EulerConstruct( theta )
                                 
               ! reference orientation of the jth node in the kth blade
            orientation = matmul( orientationL, u%BladeRootMotion(k)%RefOrientation(:,:,1) )

            
            call MeshPositionNode(u%BladeMotion(k), j, position, errStat2, errMsg2, orientation)
               call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
               
         end do ! j=blade nodes
         
            ! create line2 elements
         do j=1,InputFileData%BladeProps(k)%NumBlNds-1
            call MeshConstructElement( u%BladeMotion(k), ELEMENT_LINE2, errStat2, errMsg2, p1=j, p2=j+1 )
               call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
         end do !j
            
         call MeshCommit(u%BladeMotion(k), errStat2, errMsg2 )
            call SetErrStat( errStat2, errMsg2, errStat, errMsg, RoutineName )
            
         if (errStat >= AbortErrLev) return

      
         u%BladeMotion(k)%Orientation     = u%BladeMotion(k)%RefOrientation
         u%BladeMotion(k)%TranslationDisp = 0.8_ReKi
         u%BladeMotion(k)%TranslationVel  = 0.0_ReKi
         u%BladeMotion(k)%RotationVel     = 0.0_ReKi
   
   end do !k=numBlades
   
   
end subroutine Init_u
!----------------------------------------------------------------------------------------------------------------------------------
subroutine SetParameters( InitInp, InputFileData, p, ErrStat, ErrMsg )
! This routine is called from AD_Init.
! The parameters are set here and not changed during the simulation.
!..................................................................................................................................
   TYPE(AD_InitInputType),       intent(in   )  :: InitInp          ! Input data for initialization routine, out is needed because of copy below
   TYPE(AD_InputFile),           INTENT(INout)  :: InputFileData    ! Data stored in the module's input file -- intent(out) only for move_alloc statements
   TYPE(AD_ParameterType),       INTENT(INOUT)  :: p                ! Parameters
   INTEGER(IntKi),               INTENT(  OUT)  :: ErrStat          ! Error status of the operation
   CHARACTER(*),                 INTENT(  OUT)  :: ErrMsg           ! Error message if ErrStat /= ErrID_None


      ! Local variables
   CHARACTER(ErrMsgLen)                          :: ErrMsg2         ! temporary Error message if ErrStat /= ErrID_None
   INTEGER(IntKi)                                :: ErrStat2        ! temporary Error status of the operation
   !INTEGER(IntKi)                                :: i, j
   character(*), parameter                       :: RoutineName = 'SetParameters'
   
      ! Initialize variables for this routine

   ErrStat  = ErrID_None
   ErrMsg   = ""

   p%DT               = InputFileData%DTAero      
   p%WakeMod          = InputFileData%WakeMod
   p%TwrPotent        = InputFileData%TwrPotent
   p%TwrShadow        = InputFileData%TwrShadow
   p%TwrAero          = InputFileData%TwrAero
   
 ! p%numBlades        = InitInp%numBlades    ! this was set earlier because it was necessary
   p%NumBlNds         = InputFileData%BladeProps(1)%NumBlNds
   if (p%TwrPotent == TwrPotent_none .and. .not. p%TwrShadow .and. .not. p%TwrAero) then
      p%NumTwrNds     = 0
   else
      p%NumTwrNds     = InputFileData%NumTwrNds
      
      call move_alloc( InputFileData%TwrDiam, p%TwrDiam )
      call move_alloc( InputFileData%TwrCd,   p%TwrCd )      
   end if
   
   p%AirDens          = InputFileData%AirDens          
   p%KinVisc          = InputFileData%KinVisc
   p%SpdSound         = InputFileData%SpdSound
   
  !p%AFI     ! set in call to AFI_Init() [called early because it wants to use the same echo file as AD]
  !p%BEMT    ! set in call to BEMT_Init()
      
  !p%RootName       = TRIM(InitInp%RootName)//'.AD'   ! set earlier to it could be used   
   
#ifdef DBG_OUTS
   p%NBlOuts          = 23  
   p%numOuts          = p%NumBlNds*p%NumBlades*p%NBlOuts
   p%NTwOuts          = 0
      
#else
   p%numOuts          = InputFileData%NumOuts  
   p%NBlOuts          = InputFileData%NBlOuts      
   p%BlOutNd          = InputFileData%BlOutNd
   
   if (p%NumTwrNds > 0) then
      p%NTwOuts = InputFileData%NTwOuts
      p%TwOutNd = InputFileData%TwOutNd
   else
      p%NTwOuts = 0
   end if
   
   call SetOutParam(InputFileData%OutList, p, ErrStat2, ErrMsg2 ) ! requires: p%NumOuts, p%numBlades, p%NumBlNds, p%NumTwrNds; sets: p%OutParam.
      call setErrStat(ErrStat2,ErrMsg2,ErrStat,ErrMsg,RoutineName)
      if (ErrStat >= AbortErrLev) return  
   
#endif  
   
end subroutine SetParameters
!----------------------------------------------------------------------------------------------------------------------------------
subroutine AD_End( u, p, x, xd, z, OtherState, y, ErrStat, ErrMsg )
! This routine is called at the end of the simulation.
!..................................................................................................................................

      TYPE(AD_InputType),           INTENT(INOUT)  :: u           ! System inputs
      TYPE(AD_ParameterType),       INTENT(INOUT)  :: p           ! Parameters
      TYPE(AD_ContinuousStateType), INTENT(INOUT)  :: x           ! Continuous states
      TYPE(AD_DiscreteStateType),   INTENT(INOUT)  :: xd          ! Discrete states
      TYPE(AD_ConstraintStateType), INTENT(INOUT)  :: z           ! Constraint states
      TYPE(AD_OtherStateType),      INTENT(INOUT)  :: OtherState  ! Other/optimization states
      TYPE(AD_OutputType),          INTENT(INOUT)  :: y           ! System outputs
      INTEGER(IntKi),               INTENT(  OUT)  :: ErrStat     ! Error status of the operation
      CHARACTER(*),                 INTENT(  OUT)  :: ErrMsg      ! Error message if ErrStat /= ErrID_None



         ! Initialize ErrStat

      ErrStat = ErrID_None
      ErrMsg  = ""


         ! Place any last minute operations or calculations here:


         ! Close files here:



         ! Destroy the input data:

      CALL AD_DestroyInput( u, ErrStat, ErrMsg )


         ! Destroy the parameter data:

      CALL AD_DestroyParam( p, ErrStat, ErrMsg )


         ! Destroy the state data:

      CALL AD_DestroyContState(   x,           ErrStat, ErrMsg )
      CALL AD_DestroyDiscState(   xd,          ErrStat, ErrMsg )
      CALL AD_DestroyConstrState( z,           ErrStat, ErrMsg )
      CALL AD_DestroyOtherState(  OtherState,  ErrStat, ErrMsg )


         ! Destroy the output data:

      CALL AD_DestroyOutput( y, ErrStat, ErrMsg )




END SUBROUTINE AD_End
!----------------------------------------------------------------------------------------------------------------------------------
subroutine AD_UpdateStates( t, n, u, utimes, p, x, xd, z, OtherState, errStat, errMsg )
! Loose coupling routine for solving for constraint states, integrating continuous states, and updating discrete states
! Constraint states are solved for input Time t; Continuous and discrete states are updated for t + Interval
!..................................................................................................................................

   real(DbKi),                     intent(in   ) :: t          ! Current simulation time in seconds
   integer(IntKi),                 intent(in   ) :: n          ! Current simulation time step n = 0,1,...
   type(AD_InputType),             intent(inout) :: u(:)       ! Inputs at utimes (out only for mesh record-keeping in ExtrapInterp routine)
   real(DbKi),                     intent(in   ) :: utimes(:)  ! Times associated with u(:), in seconds
   type(AD_ParameterType),         intent(in   ) :: p          ! Parameters
   type(AD_ContinuousStateType),   intent(inout) :: x          ! Input: Continuous states at t;
                                                               !   Output: Continuous states at t + Interval
   type(AD_DiscreteStateType),     intent(inout) :: xd         ! Input: Discrete states at t;
                                                               !   Output: Discrete states at t  + Interval
   type(AD_ConstraintStateType),   intent(inout) :: z          ! Input: Initial guess of constraint states at t+dt;
                                                               !   Output: Constraint states at t+dt
   type(AD_OtherStateType),        intent(inout) :: OtherState ! Other/optimization states
   integer(IntKi),                 intent(  out) :: errStat    ! Error status of the operation
   character(*),                   intent(  out) :: errMsg     ! Error message if ErrStat /= ErrID_None

   ! local variables
   type(AD_InputType)                           :: uInterp     ! Interpolated/Extrapolated input
   
   integer(intKi)                               :: ErrStat2          ! temporary Error status
   character(ErrMsgLen)                         :: ErrMsg2           ! temporary Error message
   character(*), parameter                      :: RoutineName = 'AD_UpdateStates'
      
   ErrStat = ErrID_None
   ErrMsg  = ""
     

   call AD_CopyInput( u(1), uInterp, MESH_NEWCOPY, errStat2, errMsg2)
      call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
      if (ErrStat >= AbortErrLev) then
         call Cleanup()
         return
      end if
      
   call AD_Input_ExtrapInterp(u,utimes,uInterp,t, errStat2, errMsg2)
      call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)

   call SetInputs(p, uInterp, OtherState, errStat2, errMsg2)      
      call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
         
   
   !if ( p%WakeMod == WakeMod_BEMT ) then
                  
         ! Call into the BEMT update states    NOTE:  This is a non-standard framework interface!!!!!  GJH
      call BEMT_UpdateStates(t, n, OtherState%BEMT_u,  p%BEMT, x%BEMT, xd%BEMT, z%BEMT, OtherState%BEMT, p%AFI%AFInfo, errStat2, errMsg2)
         call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
         
   !end if
           
   call Cleanup()
   
contains
   subroutine Cleanup()
      call AD_DestroyInput( uInterp, errStat2, errMsg2)
   end subroutine Cleanup
end subroutine AD_UpdateStates
!----------------------------------------------------------------------------------------------------------------------------------
subroutine AD_CalcOutput( t, u, p, x, xd, z, OtherState, y, ErrStat, ErrMsg )
! Routine for computing outputs, used in both loose and tight coupling.
! This SUBROUTINE is used to compute the output channels (motions and loads) and place them in the WriteOutput() array.
! NOTE: the descriptions of the output channels are not given here. Please see the included OutListParameters.xlsx sheet for
! for a complete description of each output parameter.
! NOTE: no matter how many channels are selected for output, all of the outputs are calcalated
! All of the calculated output channels are placed into the OtherState%AllOuts(:), while the channels selected for outputs are
! placed in the y%WriteOutput(:) array.
!..................................................................................................................................

   REAL(DbKi),                   INTENT(IN   )  :: t           ! Current simulation time in seconds
   TYPE(AD_InputType),           INTENT(IN   )  :: u           ! Inputs at Time t
   TYPE(AD_ParameterType),       INTENT(IN   )  :: p           ! Parameters
   TYPE(AD_ContinuousStateType), INTENT(IN   )  :: x           ! Continuous states at t
   TYPE(AD_DiscreteStateType),   INTENT(IN   )  :: xd          ! Discrete states at t
   TYPE(AD_ConstraintStateType), INTENT(IN   )  :: z           ! Constraint states at t
   TYPE(AD_OtherStateType),      INTENT(INOUT)  :: OtherState  ! Other/optimization states
   TYPE(AD_OutputType),          INTENT(INOUT)  :: y           ! Outputs computed at t (Input only so that mesh con-
                                                               !   nectivity information does not have to be recalculated)
   INTEGER(IntKi),               INTENT(  OUT)  :: ErrStat     ! Error status of the operation
   CHARACTER(*),                 INTENT(  OUT)  :: ErrMsg      ! Error message if ErrStat /= ErrID_None


   integer(intKi)                               :: i
   integer(intKi)                               :: ErrStat2
   character(ErrMsgLen)                         :: ErrMsg2
   character(*), parameter                      :: RoutineName = 'AD_CalcOutput'
   
   
   ErrStat = ErrID_None
   ErrMsg  = ""

   
   call SetInputs(p, u, OtherState, errStat2, errMsg2)      
      call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
            
   ! Call the BEMT module CalcOutput.  Notice that the BEMT outputs are purposely attached to AeroDyn's OtherState structure to
   ! avoid issues with the coupling code
   
   call BEMT_CalcOutput(t, OtherState%BEMT_u, p%BEMT, x%BEMT, xd%BEMT, z%BEMT, OtherState%BEMT, p%AFI%AFInfo, OtherState%BEMT_y, ErrStat2, ErrMsg2 )
      call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
                  
   call SetOutputsFromBEMT(p, OtherState, y )
                          
   if ( p%TwrAero ) then
      call ADTwr_CalcOutput(p, u, OtherState, y, ErrStat2, ErrMsg2 )
         call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)      
   end if
         
   !-------------------------------------------------------   
   !     get values to output to file:  
   !-------------------------------------------------------   
   if (p%NumOuts > 0) then
#ifdef DBG_OUTS
      call Calc_WriteDbgOutput( p, u, OtherState, y, ErrStat, ErrMsg ) 
#else
      call Calc_WriteOutput( p, u, OtherState, y, ErrStat, ErrMsg )   
#endif   
   
      !...............................................................................................................................   
      ! Place the selected output channels into the WriteOutput(:) array with the proper sign:
      !...............................................................................................................................   

      do i = 1,p%NumOuts  ! Loop through all selected output channels
#ifdef DBG_OUTS
         y%WriteOutput(i) = OtherState%AllOuts( i )
#else
         y%WriteOutput(i) = p%OutParam(i)%SignM * OtherState%AllOuts( p%OutParam(i)%Indx )
#endif

      end do             ! i - All selected output channels
      
   end if
   
   
   
end subroutine AD_CalcOutput
!----------------------------------------------------------------------------------------------------------------------------------
subroutine AD_CalcConstrStateResidual( Time, u, p, x, xd, z, OtherState, z_residual, ErrStat, ErrMsg )
! Tight coupling routine for solving for the residual of the constraint state equations
!..................................................................................................................................

   REAL(DbKi),                   INTENT(IN   )   :: Time        ! Current simulation time in seconds
   TYPE(AD_InputType),           INTENT(IN   )   :: u           ! Inputs at Time
   TYPE(AD_ParameterType),       INTENT(IN   )   :: p           ! Parameters
   TYPE(AD_ContinuousStateType), INTENT(IN   )   :: x           ! Continuous states at Time
   TYPE(AD_DiscreteStateType),   INTENT(IN   )   :: xd          ! Discrete states at Time
   TYPE(AD_ConstraintStateType), INTENT(INOUT)   :: z           ! Constraint states at Time (possibly a guess)
   TYPE(AD_OtherStateType),      INTENT(INOUT)   :: OtherState  ! Other/optimization states
   TYPE(AD_ConstraintStateType), INTENT(  OUT)   :: z_residual  ! Residual of the constraint state equations using
                                                                !     the input values described above
   INTEGER(IntKi),                INTENT(  OUT)  :: ErrStat     ! Error status of the operation
   CHARACTER(*),                  INTENT(  OUT)  :: ErrMsg      ! Error message if ErrStat /= ErrID_None


   
      ! Local variables   
   integer(intKi)                               :: ErrStat2
   character(ErrMsgLen)                         :: ErrMsg2
   character(*), parameter                      :: RoutineName = 'AD_CalcConstrStateResidual'
   
   
   
   ErrStat = ErrID_None
   ErrMsg  = ""
   
   call SetInputs(p, u, OtherState, errStat2, errMsg2)      
      call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
   
   
   !if (p%WakeMod == WakeMod_BEMT) then
      
   
      call BEMT_CalcConstrStateResidual( Time, OtherState%BEMT_u, p%BEMT, x%BEMT, xd%BEMT, z%BEMT, OtherState%BEMT, &
                                         z_residual%BEMT, p%AFI%AFInfo, ErrStat2, ErrMsg2 )
         call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
         
   !end if
   
   
END SUBROUTINE AD_CalcConstrStateResidual
!----------------------------------------------------------------------------------------------------------------------------------
subroutine SetInputs(p, u, OtherState, errStat, errMsg)
   type(AD_ParameterType),       intent(in   )  :: p                      ! AD parameters
   type(AD_InputType),           intent(in   )  :: u                      ! AD Inputs at Time
   type(AD_OtherStateType),      intent(inout)  :: OtherState             ! OtherStates (with inputs to submodules)
   integer(IntKi),               intent(  out)  :: ErrStat                ! Error status of the operation
   character(*),                 intent(  out)  :: ErrMsg                 ! Error message if ErrStat /= ErrID_None
                                 
   ! local variables             
   integer(intKi)                               :: ErrStat2
   character(ErrMsgLen)                         :: ErrMsg2
   character(*), parameter                      :: RoutineName = 'SetInputs'
   
   
   ErrStat = ErrID_None
   ErrMsg  = ""
   
   if (p%TwrPotent /= TwrPotent_none .or. p%TwrShadow) then
      call TwrInfl( p, u, OtherState, ErrStat2, ErrMsg2 )
         call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
   else
      OtherState%DisturbedInflow = u%InflowOnBlade
   end if
      
   
   !if ( p%WakeMod == WakeMod_BEMT ) then
      
         ! This needs to extract the inputs from the AD data types (mesh) and massage them for the BEMT module
      call SetInputsForBEMT(p, u, OtherState, errStat2, errMsg2)  
         call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
      
   !end if
   
end subroutine SetInputs
!----------------------------------------------------------------------------------------------------------------------------------
subroutine SetInputsForBEMT(p, u, OtherState, errStat, errMsg)

   type(AD_ParameterType),  intent(in   )  :: p                               ! AD parameters
   type(AD_InputType),      intent(in   )  :: u                               ! AD Inputs at Time
   type(AD_OtherStateType), intent(inout)  :: OtherState                      ! AD other states
   !type(BEMT_InputType),    intent(inout)  :: BEMT_u                          ! BEMT Inputs at Time
   !real(ReKi),              intent(in   )  :: DisturbedInflow(:,:,:)          ! inflow wind velocity disturbed by tower influence 
   !real(ReKi),              intent(  out)  :: WithoutSweepPitchTwist(:,:,:,:) ! modified orientation matrix
   !real(ReKi),              intent(inout)  :: AllOuts(:)                      ! array of values to potentially write to file
   integer(IntKi),          intent(  out)  :: ErrStat                         ! Error status of the operation
   character(*),            intent(  out)  :: ErrMsg                          ! Error message if ErrStat /= ErrID_None
      
   ! local variables
   real(ReKi)                              :: x_hat(3)
   real(ReKi)                              :: y_hat(3)
   real(ReKi)                              :: z_hat(3)
   real(ReKi)                              :: x_hat_disk(3)
   real(ReKi)                              :: y_hat_disk(3)
   real(ReKi)                              :: z_hat_disk(3)
   real(ReKi)                              :: tmp(3)
   real(R8Ki)                              :: theta(3)
   real(R8Ki)                              :: orientation(3,3)
   real(R8Ki)                              :: orientation_nopitch(3,3)
   real(ReKi)                              :: tmp_sz, tmp_sz_y
   
   integer(intKi)                          :: j                      ! loop counter for nodes
   integer(intKi)                          :: k                      ! loop counter for blades
   integer(intKi)                          :: ErrStat2
   character(ErrMsgLen)                    :: ErrMsg2
   character(*), parameter                 :: RoutineName = 'SetInputsForBEMT'
   
   
   ErrStat = ErrID_None
   ErrMsg  = ""
   
   
      ! calculate disk-averaged relative wind speed, V_DiskAvg
   OtherState%V_diskAvg = 0.0_ReKi
   do k=1,p%NumBlades
      do j=1,p%NumBlNds
         tmp = OtherState%DisturbedInflow(:,j,k) - u%BladeMotion(k)%TranslationVel(:,j)
         OtherState%V_diskAvg = OtherState%V_diskAvg + tmp         
      end do
   end do
   OtherState%V_diskAvg = OtherState%V_diskAvg / real( p%NumBlades * p%NumBlNds, ReKi ) 
   
      ! orientation vectors:
   x_hat_disk = u%HubMotion%Orientation(1,:,1) !actually also x_hat_hub      
   
   OtherState%V_dot_x  = dot_product( OtherState%V_diskAvg, x_hat_disk )
   tmp    = OtherState%V_dot_x * x_hat_disk - OtherState%V_diskAvg
   tmp_sz = TwoNorm(tmp)
   if ( EqualRealNos( tmp_sz, 0.0_ReKi ) ) then
      y_hat_disk = u%HubMotion%Orientation(2,:,1)
      z_hat_disk = u%HubMotion%Orientation(3,:,1)
   else
     y_hat_disk = tmp / tmp_sz
     z_hat_disk = cross_product( OtherState%V_diskAvg, x_hat_disk ) / tmp_sz
  end if
     
      ! "Angular velocity of rotor" rad/s
   OtherState%BEMT_u%omega   = dot_product( u%HubMotion%RotationVel(:,1), x_hat_disk )    
   
      ! "Angle between the vector normal to the rotor plane and the wind vector (e.g., the yaw angle in the case of no tilt)" rad 
   tmp_sz = TwoNorm( OtherState%V_diskAvg )
   if ( EqualRealNos( tmp_sz, 0.0_ReKi ) ) then
      OtherState%BEMT_u%chi0 = 0.0_ReKi
   else
         ! make sure we don't have numerical issues that make the ratio outside +/-1
      tmp_sz_y = min(  1.0_ReKi, OtherState%V_dot_x / tmp_sz )
      tmp_sz_y = max( -1.0_ReKi, tmp_sz_y )
      
      OtherState%BEMT_u%chi0 = acos( tmp_sz_y )
      
   end if
   
      ! "Azimuth angle" rad
   do k=1,p%NumBlades
      z_hat = u%BladeRootMotion(k)%Orientation(3,:,1)      
      tmp_sz_y = -1.0*dot_product(z_hat,y_hat_disk)
      tmp_sz   =      dot_product(z_hat,z_hat_disk)
      if ( EqualRealNos(tmp_sz_y,0.0_ReKi) .and. EqualRealNos(tmp_sz,0.0_ReKi) ) then
         OtherState%BEMT_u%psi(k) = 0.0_ReKi
      else
         OtherState%BEMT_u%psi(k) = atan2( tmp_sz_y, tmp_sz )
      end if      
   end do
   
      ! theta, "Twist angle (includes all sources of twist)" rad
      ! Vx, "Local axial velocity at node" m/s
      ! Vy, "Local tangential velocity at node" m/s
   do k=1,p%NumBlades
      
         ! construct system equivalent to u%BladeRootMotion(k)%Orientation, but without the blade-pitch angle:
      
      !orientation = matmul( u%BladeRootMotion(k)%Orientation(:,:,1), transpose(u%HubMotion%Orientation(:,:,1)) )
      call LAPACK_gemm( 'n', 't', 1.0_R8Ki, u%BladeRootMotion(k)%Orientation(:,:,1), u%HubMotion%Orientation(:,:,1), 0.0_R8Ki, orientation, errStat2, errMsg2)
         call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
      theta = EulerExtract( orientation ) !hub_theta_root(k)
#ifndef DBG_OUTS
      OtherState%AllOuts( BPitch(  k) ) = -theta(3)*R2D ! save this value of pitch for potential output
#endif
      theta(3) = 0.0_ReKi  
      orientation = EulerConstruct( theta )
      orientation_nopitch = matmul( orientation, u%HubMotion%Orientation(:,:,1) ) ! withoutPitch_theta_Root(k)
            
      do j=1,p%NumBlNds         
         
            ! form coordinate system equivalent to u%BladeMotion(k)%Orientation(:,:,j) but without live sweep (due to in-plane
            ! deflection), blade-pitch and twist (aerodynamic + elastic) angles:
         
         ! orientation = matmul( u%BladeMotion(k)%Orientation(:,:,j), transpose(orientation_nopitch) )
         call LAPACK_gemm( 'n', 't', 1.0_R8Ki, u%BladeMotion(k)%Orientation(:,:,j), orientation_nopitch, 0.0_R8Ki, orientation, errStat2, errMsg2)
            call SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
         theta = EulerExtract( orientation ) !root(k)WithoutPitch_theta(j)_blade(k)
         
         OtherState%BEMT_u%theta(j,k) = -theta(3) ! local pitch + twist (aerodyanmic + elastic) angle of the jth node in the kth blade
         
         
         theta(1) = 0.0_ReKi
         theta(3) = 0.0_ReKi
         OtherState%Curve(j,k) = theta(2)  ! save value for possible output later
         OtherState%WithoutSweepPitchTwist(:,:,j,k) = matmul( EulerConstruct( theta ), orientation_nopitch ) ! WithoutSweepPitch+Twist_theta(j)_Blade(k)
                           
         x_hat = OtherState%WithoutSweepPitchTwist(1,:,j,k)
         y_hat = OtherState%WithoutSweepPitchTwist(2,:,j,k)
         tmp   = OtherState%DisturbedInflow(:,j,k) - u%BladeMotion(k)%TranslationVel(:,j) ! rel_V(j)_Blade(k)
         
         OtherState%BEMT_u%Vx(j,k) = dot_product( tmp, x_hat ) ! normal component (normal to the plane, not chord) of the inflow velocity of the jth node in the kth blade
         OtherState%BEMT_u%Vy(j,k) = dot_product( tmp, y_hat ) ! tangential component (tangential to the plane, not chord) of the inflow velocity of the jth node in the kth blade
         
      end do !j=nodes
   end do !k=blades
   
   
      ! "Radial distance from center-of-rotation to node" m
   
   do k=1,p%NumBlades
      do j=1,p%NumBlNds
         
            ! displaced position of the jth node in the kth blade relative to the hub:
         tmp =  u%BladeMotion(k)%Position(:,j) + u%BladeMotion(k)%TranslationDisp(:,j) &
              - u%HubMotion%Position(:,1)      - u%HubMotion%TranslationDisp(:,1)
         
            ! local radius (normalized distance from rotor centerline)
         tmp_sz_y = dot_product( tmp, y_hat_disk )**2
         tmp_sz   = dot_product( tmp, z_hat_disk )**2
         OtherState%BEMT_u%rLocal(j,k) = sqrt( tmp_sz + tmp_sz_y )
         
      end do !j=nodes
      
   end do !k=blades
   
   
   ! values for coupled model:
! FIX ME!!!!
 !???  ! "Local upstream velocity at node" m/s
   !do k=1,p%NumBlades
   !   do j=1,p%NumBlNds
   !      OtherState%BEMT_u%Vinf(j,k) = TwoNorm( OtherState%DisturbedInflow(:,j,k) ) 
   !   end do
   !end do
   
      
end subroutine SetInputsForBEMT
!----------------------------------------------------------------------------------------------------------------------------------
subroutine SetOutputsFromBEMT(p, OtherState, y )

   type(AD_ParameterType),  intent(in   )  :: p                               ! AD parameters
   type(AD_OutputType),     intent(inout)  :: y                               ! AD outputs 
   type(AD_OtherStateType), intent(inout)  :: OtherState                      ! AD other states
   !type(BEMT_OutputType),   intent(in   )  :: BEMT_y                          ! BEMT outputs
   !real(ReKi),              intent(in   )  :: WithoutSweepPitchTwist(:,:,:,:) ! modified orientation matrix

   integer(intKi)                          :: j                      ! loop counter for nodes
   integer(intKi)                          :: k                      ! loop counter for blades
   real(reki)                              :: force(3)
   real(reki)                              :: moment(3)
   real(reki)                              :: q
   
  
   
   force(3)    =  0.0_ReKi          
   moment(1:2) =  0.0_ReKi          
   do k=1,p%NumBlades
      do j=1,p%NumBlNds
                      
         q = 0.5 * p%airDens * OtherState%BEMT_y%inducedVel(j,k)**2        ! dynamic pressure of the jth node in the kth blade
         force(1) =  OtherState%BEMT_y%cx(j,k) * q * p%BEMT%chord(j,k)     ! X = normal force per unit length (normal to the plane, not chord) of the jth node in the kth blade
         force(2) = -OtherState%BEMT_y%cy(j,k) * q * p%BEMT%chord(j,k)     ! Y = tangential force per unit length (tangential to the plane, not chord) of the jth node in the kth blade
         moment(3)=  OtherState%BEMT_y%cm(j,k) * q * p%BEMT%chord(j,k)**2  ! M = pitching moment per unit length of the jth node in the kth blade
         
            ! save these values for possible output later:
         OtherState%X(j,k) = force(1)
         OtherState%Y(j,k) = force(2)
         OtherState%M(j,k) = moment(3)
         
            ! note: because force and moment are 1-d arrays, I'm calculating the transpose of the force and moment outputs
            !       so that I don't have to take the transpose of WithoutSweepPitchTwist(:,:,j,k)
         y%BladeLoad(k)%Force(:,j)  = matmul( force,  OtherState%WithoutSweepPitchTwist(:,:,j,k) )  ! force per unit length of the jth node in the kth blade
         y%BladeLoad(k)%Moment(:,j) = matmul( moment, OtherState%WithoutSweepPitchTwist(:,:,j,k) )  ! moment per unit length of the jth node in the kth blade
         
      end do !j=nodes
   end do !k=blades
   
   
end subroutine SetOutputsFromBEMT
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE ValidateInputData( InputFileData, NumBl, ErrStat, ErrMsg )
! This routine validates the inputs from the AeroDyn input files.
!..................................................................................................................................
      
      ! Passed variables:

   type(AD_InputFile),       intent(in)     :: InputFileData                       ! All the data in the AeroDyn input file
   integer(IntKi),           intent(in)     :: NumBl                               ! Number of blades
   integer(IntKi),           intent(out)    :: ErrStat                             ! Error status
   character(*),             intent(out)    :: ErrMsg                              ! Error message

   
      ! local variables
   integer(IntKi)                           :: k                                   ! Blade number
   integer(IntKi)                           :: j                                   ! node number
   character(*), parameter                  :: RoutineName = 'ValidateInputData'
   
   ErrStat = ErrID_None
   ErrMsg  = ""
         
   if (NumBl > MaxBl .or. NumBl < 1) call SetErrStat( ErrID_Fatal, 'Number of blades must be between 1 and '//trim(num2lstr(MaxBl))//'.', ErrSTat, ErrMsg, RoutineName )
   if (InputFileData%DTAero <= 0.0)  call SetErrStat ( ErrID_Fatal, 'DTAero must be greater than zero.', ErrStat, ErrMsg, RoutineName )
   if (InputFileData%WakeMod /= WakeMod_None .and. InputFileData%WakeMod /= WakeMod_BEMT) call SetErrStat ( ErrID_Fatal, &
      'WakeMod must '//trim(num2lstr(WakeMod_None))//' (none) or '//trim(num2lstr(WakeMod_BEMT))//' (BEMT).', ErrStat, ErrMsg, RoutineName ) 
   if (InputFileData%AFAeroMod /= AFAeroMod_Steady .and. InputFileData%AFAeroMod /= AFAeroMod_BL_unsteady) then
      call SetErrStat ( ErrID_Fatal, 'AFAeroMod must be '//trim(num2lstr(AFAeroMod_Steady))//' (steady) or '//&
                        trim(num2lstr(AFAeroMod_BL_unsteady))//' (Beddoes-Leishman unsteady).', ErrStat, ErrMsg, RoutineName ) 
   end if
   if (InputFileData%TwrPotent /= TwrPotent_none .and. InputFileData%TwrPotent /= TwrPotent_baseline .and. InputFileData%TwrPotent /= TwrPotent_Bak) then
      call SetErrStat ( ErrID_Fatal, 'TwrPotent must be 0 (none), 1 (baseline potential flow), or 2 (potential flow with Bak correction).', ErrStat, ErrMsg, RoutineName ) 
   end if   
   
   if (InputFileData%AirDens <= 0.0) call SetErrStat ( ErrID_Fatal, 'The air density (AirDens) must be greater than zero.', ErrStat, ErrMsg, RoutineName )
   if (InputFileData%KinVisc <= 0.0) call SetErrStat ( ErrID_Fatal, 'The kinesmatic viscosity (KinVisc) must be greater than zero.', ErrStat, ErrMsg, RoutineName )
   if (InputFileData%SpdSound <= 0.0) call SetErrStat ( ErrID_Fatal, 'The speed of sound (SpdSound) must be greater than zero.', ErrStat, ErrMsg, RoutineName )
      
   
      ! BEMT inputs
      ! these checks should probably go into BEMT where they are used...
   if (InputFileData%WakeMod == WakeMod_BEMT) then
      if ( InputFileData%MaxIter < 1 ) call SetErrStat( ErrID_Fatal, 'MaxIter must be greater than 0.', ErrStat, ErrMsg, RoutineName )
      
      if ( InputFileData%IndToler < 0.0 .or. EqualRealNos(InputFileData%IndToler, 0.0_ReKi) ) &
         call SetErrStat( ErrID_Fatal, 'IndToler must be greater than 0.', ErrStat, ErrMsg, RoutineName )
   
      if ( InputFileData%SkewMod /= SkewMod_Uncoupled .and. InputFileData%SkewMod /= SkewMod_PittPeters) &  !  .and. InputFileData%SkewMod /= SkewMod_Coupled )
           call SetErrStat( ErrID_Fatal, 'SkewMod must be 1, or 2.  Option 3 will be implemented in a future version.', ErrStat, ErrMsg, RoutineName )      
      
   end if !BEMT checks
   
      ! UA inputs
   if (InputFileData%AFAeroMod == AFAeroMod_BL_unsteady ) then
      if (InputFileData%UAMod < 2 .or. InputFileData%UAMod > 3 ) call SetErrStat( ErrID_Fatal, &
         "In this version, UAMod must be 2 (Gonzalez's variant) or 3 (Minemma/Pierce variant).", ErrStat, ErrMsg, RoutineName )  ! NOTE: for later-  1 (baseline/original) 
   end if
   
   
   
   
   if (.not. InputFileData%FLookUp ) call SetErrStat( ErrID_Fatal, 'FLookUp must be TRUE for this version.', ErrStat, ErrMsg, RoutineName )
   
         ! validate the AFI input data because it doesn't appear to be done in AFI
   if (InputFileData%NumAFfiles < 1) call SetErrStat( ErrID_Fatal, 'The number of unique airfoil tables (NumAFfiles) must be greater than zero.', ErrStat, ErrMsg, RoutineName )   
   if (InputFileData%InCol_Alfa  < 0) call SetErrStat( ErrID_Fatal, 'InCol_Alfa must not be a negative number.', ErrStat, ErrMsg, RoutineName )
   if (InputFileData%InCol_Cl    < 0) call SetErrStat( ErrID_Fatal, 'InCol_Cl must not be a negative number.', ErrStat, ErrMsg, RoutineName )
   if (InputFileData%InCol_Cd    < 0) call SetErrStat( ErrID_Fatal, 'InCol_Cd must not be a negative number.', ErrStat, ErrMsg, RoutineName )
   if (InputFileData%InCol_Cm    < 0) call SetErrStat( ErrID_Fatal, 'InCol_Cm must not be a negative number.', ErrStat, ErrMsg, RoutineName )
   if (InputFileData%InCol_Cpmin < 0) call SetErrStat( ErrID_Fatal, 'InCol_Cpmin must not be a negative number.', ErrStat, ErrMsg, RoutineName )
   
      ! .............................
      ! check blade mesh data:
      ! .............................
   if ( InputFileData%BladeProps(1)%NumBlNds < 2 ) call SetErrStat( ErrID_Fatal, 'There must be at least two nodes per blade.',ErrStat, ErrMsg, RoutineName )
   do k=2,NumBl
      if ( InputFileData%BladeProps(k)%NumBlNds /= InputFileData%BladeProps(k-1)%NumBlNds ) then
         call SetErrStat( ErrID_Fatal, 'All blade property files must have the same number of blade nodes.', ErrStat, ErrMsg, RoutineName )
         exit  ! exit do loop
      end if
   end do
   
      ! Check the list of airfoil tables for blades to make sure they are all within limits.
   do k=1,NumBl
      do j=1,InputFileData%BladeProps(k)%NumBlNds
         if ( ( InputFileData%BladeProps(k)%BlAFID(j) < 1 ) .OR. ( InputFileData%BladeProps(k)%BlAFID(j) > InputFileData%NumAFfiles ) )  then
            call SetErrStat( ErrID_Fatal, 'Blade '//trim(Num2LStr(k))//' node '//trim(Num2LStr(j))//' must be a number between 1 and NumAFfiles (' &
               //TRIM(Num2LStr(InputFileData%NumAFfiles))//').', ErrStat, ErrMsg, RoutineName )
         end if
      end do ! j=nodes
   end do ! k=blades
            
      ! Check that the blade chord is > 0.
   do k=1,NumBl
      do j=1,InputFileData%BladeProps(k)%NumBlNds
         if ( InputFileData%BladeProps(k)%BlChord(j) <= 0.0_ReKi )  then
            call SetErrStat( ErrID_Fatal, 'The chord for blade '//trim(Num2LStr(k))//' node '//trim(Num2LStr(j)) &
                             //' must be greater than 0.', ErrStat, ErrMsg, RoutineName )
         endif
      end do ! j=nodes
   end do ! k=blades
   
   do k=1,NumBl
      if ( .not. EqualRealNos(InputFileData%BladeProps(k)%BlSpn(1), 0.0_ReKi) ) call SetErrStat( ErrID_Fatal, 'Blade '//trim(Num2LStr(k))//' span location must start at 0.0 m', ErrStat, ErrMsg, RoutineName)       
      do j=2,InputFileData%BladeProps(k)%NumBlNds
         if ( InputFileData%BladeProps(k)%BlSpn(j) <= InputFileData%BladeProps(k)%BlSpn(j-1) )  then
            call SetErrStat( ErrID_Fatal, 'Blade '//trim(Num2LStr(k))//' nodes must be entered in increasing elevation.', ErrStat, ErrMsg, RoutineName )
            exit
         end if
      end do ! j=nodes
   end do ! k=blades
   
      ! .............................
      ! check tower mesh data:
      ! .............................
   if (InputFileData%TwrPotent /= TwrPotent_none .or. InputFileData%TwrShadow .or. InputFileData%TwrAero ) then
      
      if (InputFileData%NumTwrNds < 2) call SetErrStat( ErrID_Fatal, 'There must be at least two nodes on the tower.',ErrStat, ErrMsg, RoutineName )
         
         ! Check that the tower diameter is > 0.
      do j=1,InputFileData%NumTwrNds
         if ( InputFileData%TwrDiam(j) <= 0.0_ReKi )  then
            call SetErrStat( ErrID_Fatal, 'The diameter for tower node '//trim(Num2LStr(j))//' must be greater than 0.' &
                            , ErrStat, ErrMsg, RoutineName )
         end if
      end do ! j=nodes
      
         ! check that the elevation is increasing:
      do j=2,InputFileData%NumTwrNds
         if ( InputFileData%TwrElev(j) <= InputFileData%TwrElev(j-1) )  then
            call SetErrStat( ErrID_Fatal, 'The tower nodes must be entered in increasing elevation.', ErrStat, ErrMsg, RoutineName )
            exit
         end if
      end do ! j=nodes
            
   end if
   
      ! .............................
      ! check outputs:
      ! .............................
   
   if ( ( InputFileData%NTwOuts < 0_IntKi ) .OR. ( InputFileData%NTwOuts > 9_IntKi ) )  then
      call SetErrStat( ErrID_Fatal, 'NTwOuts must be between 0 and 9 (inclusive).', ErrStat, ErrMsg, RoutineName )
   else
         ! Check to see if all TwOutNd(:) analysis points are existing analysis points:

      do j=1,InputFileData%NTwOuts
         if ( InputFileData%TwOutNd(j) < 1_IntKi .OR. InputFileData%TwOutNd(j) > InputFileData%NumTwrNds ) then
            call SetErrStat( ErrID_Fatal, ' All TwOutNd values must be between 1 and '//&
                           trim( Num2LStr( InputFileData%NumTwrNds ) )//' (inclusive).', ErrStat, ErrMsg, RoutineName )
            exit ! stop checking this loop
         end if
      end do         
   
   end if
         
         
   if ( ( InputFileData%NBlOuts < 0_IntKi ) .OR. ( InputFileData%NBlOuts > 9_IntKi ) )  then
      call SetErrStat( ErrID_Fatal, 'NBlOuts must be between 0 and 9 (inclusive).', ErrStat, ErrMsg, RoutineName )
   else 

   ! Check to see if all BlOutNd(:) analysis points are existing analysis points:

      do j=1,InputFileData%NBlOuts
         if ( InputFileData%BlOutNd(j) < 1_IntKi .OR. InputFileData%BlOutNd(j) > InputFileData%BladeProps(1)%NumBlNds ) then
            call SetErrStat( ErrID_Fatal, ' All BlOutNd values must be between 1 and '//&
                    trim( Num2LStr( InputFileData%BladeProps(1)%NumBlNds ) )//' (inclusive).', ErrStat, ErrMsg, RoutineName )
            exit ! stop checking this loop
         end if
      end do
      
   end if   
   
         
END SUBROUTINE ValidateInputData
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE Init_AFIparams( InputFileData, p_AFI, UnEc, NumBl, ErrStat, ErrMsg )


      ! Passed variables
   type(AD_InputFile),      intent(inout)   :: InputFileData      ! All the data in the AeroDyn input file (intent(out) only because of the call to MOVE_ALLOC)
   type(AFI_ParameterType), intent(  out)   :: p_AFI              ! parameters returned from the AFI (airfoil info) module
   integer(IntKi),          intent(in   )   :: UnEc               ! I/O unit for echo file. If > 0, file is open for writing.
   integer(IntKi),          intent(in   )   :: NumBl              ! number of blades (for performing check on valid airfoil data read in)
   integer(IntKi),          intent(  out)   :: ErrStat            ! Error status
   character(*),            intent(  out)   :: ErrMsg             ! Error message

      ! local variables
   type(AFI_InitInputType)                  :: AFI_InitInputs     ! initialization data for the AFI routines
   
   integer(IntKi)                           :: j                  ! loop counter for nodes
   integer(IntKi)                           :: k                  ! loop counter for blades
   integer(IntKi)                           :: File               ! loop counter for airfoil files
   integer(IntKi)                           :: Table              ! loop counter for airfoil tables in a file
   logical, allocatable                     :: fileUsed(:)
   
   integer(IntKi)                           :: ErrStat2
   character(ErrMsgLen)                     :: ErrMsg2
   character(*), parameter                  :: RoutineName = 'Init_AFIparams'

   
   ErrStat = ErrID_None
   ErrMsg  = ""
   
   
      ! Setup Airfoil InitInput data structure:
   AFI_InitInputs%NumAFfiles = InputFileData%NumAFfiles
   call MOVE_ALLOC( InputFileData%AFNames, AFI_InitInputs%FileNames ) ! move from AFNames to FileNames      
   AFI_InitInputs%InCol_Alfa  = InputFileData%InCol_Alfa
   AFI_InitInputs%InCol_Cl    = InputFileData%InCol_Cl
   AFI_InitInputs%InCol_Cd    = InputFileData%InCol_Cd
   AFI_InitInputs%InCol_Cm    = InputFileData%InCol_Cm
   AFI_InitInputs%InCol_Cpmin = InputFileData%InCol_Cpmin
               
      ! Call AFI_Init to read in and process the airfoil files.
      ! This includes creating the spline coefficients to be used for interpolation.

   call AFI_Init ( AFI_InitInputs, p_AFI, ErrStat2, ErrMsg2, UnEc )
      call SetErrStat(ErrStat2,ErrMsg2, ErrStat, ErrMsg, RoutineName)   
   
      
   call MOVE_ALLOC( AFI_InitInputs%FileNames, InputFileData%AFNames ) ! move from FileNames back to AFNames
   call AFI_DestroyInitInput( AFI_InitInputs, ErrStat2, ErrMsg2 )
   
   if (ErrStat >= AbortErrLev) return
   
   
      ! check that we read the correct airfoil parameters for UA:      
   if ( InputFileData%AFAeroMod == AFAeroMod_BL_unsteady ) then
      
         
         ! determine which airfoil files will be used
      call AllocAry( fileUsed, InputFileData%NumAFfiles, 'fileUsed', errStat2, errMsg2 )
         call SetErrStat(ErrStat2,ErrMsg2, ErrStat, ErrMsg, RoutineName)   
      if (errStat >= AbortErrLev) return
      fileUsed = .false.
            
      do k=1,NumBl
         do j=1,InputFileData%BladeProps(k)%NumBlNds
            fileUsed ( InputFileData%BladeProps(k)%BlAFID(j) ) = .true.
         end do ! j=nodes
      end do ! k=blades
      
         ! make sure all files in use have UA input parameters:
      do File = 1,InputFileData%NumAFfiles
         
         if (fileUsed(File)) then
            do Table=1,p_AFI%AFInfo(File)%NumTabs            
               if ( .not. p_AFI%AFInfo(File)%Table(Table)%InclUAdata ) then
                  call SetErrStat( ErrID_Fatal, 'Airfoil file '//trim(InputFileData%AFNames(File))//', table #'// &
                        trim(num2lstr(Table))//' does not contain parameters for UA data.', ErrStat, ErrMsg, RoutineName )
               end if
            end do
         end if
         
      end do
      
      if ( allocated(fileUsed) ) deallocate(fileUsed)
      
   end if
   
   
END SUBROUTINE Init_AFIparams
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE Init_BEMTmodule( InputFileData, u_AD, u, p, x, xd, z, OtherState, y, ErrStat, ErrMsg )
! This routine initializes the BEMT module from within AeroDyn
!..................................................................................................................................

   type(AD_InputFile),             intent(in   ) :: InputFileData  ! All the data in the AeroDyn input file
   type(AD_InputType),             intent(in   ) :: u_AD           ! AD inputs - used for input mesh node positions
   type(BEMT_InputType),           intent(  out) :: u              ! An initial guess for the input; input mesh must be defined
   type(AD_ParameterType),         intent(inout) :: p              ! Parameters ! intent out b/c we set the BEMT parameters here
   type(BEMT_ContinuousStateType), intent(  out) :: x              ! Initial continuous states
   type(BEMT_DiscreteStateType),   intent(  out) :: xd             ! Initial discrete states
   type(BEMT_ConstraintStateType), intent(  out) :: z              ! Initial guess of the constraint states
   type(BEMT_OtherStateType),      intent(  out) :: OtherState     ! Initial other/optimization states
   type(BEMT_OutputType),          intent(  out) :: y              ! Initial system outputs (outputs are not calculated;
                                                                   !   only the output mesh is initialized)
   integer(IntKi),                 intent(  out) :: errStat        ! Error status of the operation
   character(*),                   intent(  out) :: errMsg         ! Error message if ErrStat /= ErrID_None


      ! Local variables
   real(DbKi)                                    :: Interval       ! Coupling interval in seconds: the rate that
                                                                   !   (1) BEMT_UpdateStates() is called in loose coupling &
                                                                   !   (2) BEMT_UpdateDiscState() is called in tight coupling.
                                                                   !   Input is the suggested time from the glue code;
                                                                   !   Output is the actual coupling interval that will be used
                                                                   !   by the glue code.
   type(BEMT_InitInputType)                      :: InitInp        ! Input data for initialization routine
   type(BEMT_InitOutputType)                     :: InitOut        ! Output for initialization routine
                                                 
   integer(intKi)                                :: j              ! node index
   integer(intKi)                                :: k              ! blade index
   integer(IntKi)                                :: ErrStat2
   character(ErrMsgLen)                          :: ErrMsg2
   character(*), parameter                       :: RoutineName = 'Init_BEMTmodule'

   ! note here that each blade is required to have the same number of nodes
   
   ErrStat = ErrID_None
   ErrMsg  = ""
   
   
      ! set initialization data here:   
   Interval                 = p%DT   
   InitInp%numBlades        = p%NumBlades
   
   InitInp%airDens          = InputFileData%AirDens 
   InitInp%kinVisc          = InputFileData%KinVisc                  
   InitInp%skewWakeMod      = InputFileData%SkewMod
   InitInp%aTol             = InputFileData%IndToler
   InitInp%useTipLoss       = InputFileData%TipLoss
   InitInp%useHubLoss       = InputFileData%HubLoss
   InitInp%useInduction     = InputFileData%WakeMod == WakeMod_BEMT
   InitInp%useTanInd        = InputFileData%TanInd
   InitInp%useAIDrag        = InputFileData%AIDrag        
   InitInp%useTIDrag        = InputFileData%TIDrag  
   InitInp%numBladeNodes    = p%NumBlNds
   InitInp%numReIterations  = 1                              ! This is currently not available in the input file and is only for testing  
   InitInp%maxIndIterations = InputFileData%MaxIter 
   
   call AllocAry(InitInp%chord, InitInp%numBladeNodes,InitInp%numBlades,'chord', ErrStat2,ErrMsg2); call SetErrStat(ErrStat2,ErrMsg2,ErrStat,ErrMsg,RoutineName)   
   call AllocAry(InitInp%AFindx,InitInp%numBladeNodes,InitInp%numBlades,'AFindx',ErrStat2,ErrMsg2); call SetErrStat(ErrStat2,ErrMsg2,ErrStat,ErrMsg,RoutineName)   
   call AllocAry(InitInp%zHub,                        InitInp%numBlades,'zHub',  ErrStat2,ErrMsg2); call SetErrStat(ErrStat2,ErrMsg2,ErrStat,ErrMsg,RoutineName)
   call AllocAry(InitInp%zLocal,InitInp%numBladeNodes,InitInp%numBlades,'zLocal',ErrStat2,ErrMsg2); call SetErrStat(ErrStat2,ErrMsg2,ErrStat,ErrMsg,RoutineName)   
   call AllocAry(InitInp%zTip,                        InitInp%numBlades,'zTip',  ErrStat2,ErrMsg2); call SetErrStat(ErrStat2,ErrMsg2,ErrStat,ErrMsg,RoutineName)

   if ( ErrStat >= AbortErrLev ) then
      call Cleanup()
      return
   end if  

   
   do k=1,p%numBlades
      
      InitInp%zHub(k) = TwoNorm( u_AD%BladeRootMotion(k)%Position(:,1) - u_AD%HubMotion%Position(:,1) )  
      if (EqualRealNos(InitInp%zHub(k),0.0_ReKi) ) &
         call SetErrStat( ErrID_Fatal, "zHub for blade "//trim(num2lstr(k))//" is zero.", ErrStat, ErrMsg, RoutineName)
      
      InitInp%zLocal(1,k) = InitInp%zHub(k) + TwoNorm( u_AD%BladeMotion(k)%Position(:,1) - u_AD%BladeRootMotion(k)%Position(:,1) )
      do j=2,p%NumBlNds
         InitInp%zLocal(j,k) = InitInp%zLocal(j-1,k) + TwoNorm( u_AD%BladeMotion(k)%Position(:,j) - u_AD%BladeMotion(k)%Position(:,j-1) ) 
      end do !j=nodes
      
      InitInp%zTip(k) = InitInp%zLocal(p%NumBlNds,k)
      
   end do !k=blades
   
               
  do k=1,p%numBlades
     do j=1,p%NumBlNds
        InitInp%chord (j,k)  = InputFileData%BladeProps(k)%BlChord(j)
        InitInp%AFindx(j,k)  = InputFileData%BladeProps(k)%BlAFID(j)
     end do
  end do
   
   InitInp%UA_Flag  = InputFileData%AFAeroMod == AFAeroMod_BL_unsteady
   InitInp%UAMod    = InputFileData%UAMod
   InitInp%Flookup  = InputFileData%Flookup
   InitInp%a_s      = InputFileData%SpdSound
   
   if (ErrStat >= AbortErrLev) then
      call cleanup()
      return
   end if
   
   
   call BEMT_Init(InitInp, u, p%BEMT,  x, xd, z, OtherState, p%AFI%AFInfo, y, Interval, InitOut, ErrStat2, ErrMsg2 )
      call SetErrStat(ErrStat2,ErrMsg2, ErrStat, ErrMsg, RoutineName)   
         
   if (.not. equalRealNos(Interval, p%DT) ) &
      call SetErrStat( ErrID_Fatal, "DTAero was changed in Init_BEMTmodule(); this is not allowed.", ErrStat2, ErrMsg2, RoutineName)
   
   call Cleanup()
   return
      
contains   
   subroutine Cleanup()
      call BEMT_DestroyInitInput( InitInp, ErrStat2, ErrMsg2 )   
      call BEMT_DestroyInitOutput( InitOut, ErrStat2, ErrMsg2 )   
   end subroutine Cleanup
   
END SUBROUTINE Init_BEMTmodule
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE ADTwr_CalcOutput(p, u, OtherState, y, ErrStat, ErrMsg )

   TYPE(AD_InputType),           INTENT(IN   )  :: u           ! Inputs at Time t
   TYPE(AD_ParameterType),       INTENT(IN   )  :: p           ! Parameters
   TYPE(AD_OtherStateType),      INTENT(INOUT)  :: OtherState  ! Other/optimization states
   TYPE(AD_OutputType),          INTENT(INOUT)  :: y           ! Outputs computed at t (Input only so that mesh con-
                                                               !   nectivity information does not have to be recalculated)
   INTEGER(IntKi),               INTENT(  OUT)  :: ErrStat     ! Error status of the operation
   CHARACTER(*),                 INTENT(  OUT)  :: ErrMsg      ! Error message if ErrStat /= ErrID_None


   INTEGER(IntKi)                               :: j
   real(ReKi)                                   :: q
   real(ReKi)                                   :: V_rel(3)    ! relative wind speed on a tower node
   real(ReKi)                                   :: VL(2)       ! relative local x- and y-components of the wind speed on a tower node
   real(ReKi)                                   :: tmp(3)
   
   !integer(intKi)                               :: ErrStat2
   !character(ErrMsgLen)                         :: ErrMsg2
   character(*), parameter                      :: RoutineName = 'ADTwr_CalcOutput'
   
   
   ErrStat = ErrID_None
   ErrMsg  = ""

   
   do j=1,p%NumTwrNds
      
      V_rel = u%InflowOnTower(:,j) - u%TowerMotion%TranslationDisp(:,j) ! relative wind speed at tower node
   
      tmp   = u%TowerMotion%Orientation(1,:,j)
      VL(1) = dot_product( V_Rel, tmp )            ! relative local x-component of wind speed of the jth node in the tower
      tmp   = u%TowerMotion%Orientation(2,:,j)
      VL(2) = dot_product( V_Rel, tmp )            ! relative local y-component of wind speed of the jth node in the tower
      
      OtherState%W_Twr(j)  =  TwoNorm( VL )            ! relative wind speed normal to the tower at node j      
      q     = 0.5 * p%TwrCd(j) * p%AirDens * p%TwrDiam(j) * OtherState%W_Twr(j)
      
         ! force per unit length of the jth node in the tower
      tmp(1) = q * VL(1)
      tmp(2) = q * VL(2)
      tmp(3) = 0.0_ReKi
      
      y%TowerLoad%force(:,j) = matmul( tmp, u%TowerMotion%Orientation(:,:,j) ) ! note that I'm calculating the transpose here, which is okay because we have 1-d arrays
      OtherState%X_Twr(j) = tmp(1)
      OtherState%Y_Twr(j) = tmp(2)
      
      
         ! moment per unit length of the jth node in the tower
      y%TowerLoad%moment(:,j) = 0.0_ReKi
      
   end do
   

END SUBROUTINE ADTwr_CalcOutput
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE CheckTwrInfl(u, ErrStat, ErrMsg )

   TYPE(AD_InputType),           INTENT(IN   )  :: u           ! Inputs at Time t
   !TYPE(AD_OtherStateType),      INTENT(INOUT)  :: OtherState  ! Other/optimization states
   INTEGER(IntKi),               INTENT(  OUT)  :: ErrStat     ! Error status of the operation
   CHARACTER(*),                 INTENT(  OUT)  :: ErrMsg      ! Error message if ErrStat /= ErrID_None
   
   ! local variables
   real(reKi)                                   :: ElemSize
   real(reKi)                                   :: tmp(3)
   integer(intKi)                               :: j
   character(*), parameter                      :: RoutineName = 'CheckTwrInfl'
   
   
   ErrStat = ErrID_None
   ErrMsg  = ""
   
   ! the Tower-influence models (tower potential flow and tower shadow) are only valid for small tower deflections;
   ! so, first throw an error to avoid a division-by-zero error if any line2 elements on the tower mesh are collocated.
   
   do j = 2,u%TowerMotion%Nnodes
      tmp =   u%TowerMotion%Position(:,j  ) + u%TowerMotion%TranslationDisp(:,j  ) &
            - u%TowerMotion%Position(:,j-1) - u%TowerMotion%TranslationDisp(:,j-1)
   
      ElemSize = TwoNorm(tmp)
      if ( EqualRealNos(ElemSize,0.0_ReKi) ) then
         call SetErrStat(ErrID_Fatal, "Division by zero:Elements "//trim(num2lstr(j))//' and '//trim(num2lstr(j-1))//' are collocated.', ErrStat, ErrMsg, RoutineName )
         exit
      end if
   end do
      
   
END SUBROUTINE CheckTwrInfl
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE TwrInfl( p, u, OtherState, ErrStat, ErrMsg )
! this routine calculates OtherState%DisturbedInflow, the influence of tower shadow and/or potential flow on the inflow velocities
!..................................................................................................................................

   TYPE(AD_InputType),           INTENT(IN   )  :: u                       ! Inputs at Time t
   TYPE(AD_ParameterType),       INTENT(IN   )  :: p                       ! Parameters
   TYPE(AD_OtherStateType),      INTENT(INOUT)  :: OtherState              ! Other/optimization states
   INTEGER(IntKi),               INTENT(  OUT)  :: ErrStat                 ! Error status of the operation
   CHARACTER(*),                 INTENT(  OUT)  :: ErrMsg                  ! Error message if ErrStat /= ErrID_None

   ! local variables
   real(ReKi)                                   :: xbar                    ! local x^ component of r_TowerBlade (distance from tower to blade) normalized by tower radius
   real(ReKi)                                   :: ybar                    ! local y^ component of r_TowerBlade (distance from tower to blade) normalized by tower radius
   real(ReKi)                                   :: zbar                    ! local z^ component of r_TowerBlade (distance from tower to blade) normalized by tower radius
   real(ReKi)                                   :: theta_tower_trans(3,3)  ! transpose of local tower orientation expressed as a DCM
   real(ReKi)                                   :: TwrCd                   ! local tower drag coefficient
   real(ReKi)                                   :: W_tower                 ! local relative wind speed normal to the tower

   real(ReKi)                                   :: BladeNodePosition(3)    ! local blade node position
   
   
   real(ReKi)                                   :: u_TwrShadow             ! axial velocity deficit fraction from tower shadow
   real(ReKi)                                   :: u_TwrPotent             ! axial velocity deficit fraction from tower potential flow
   real(ReKi)                                   :: v_TwrPotent             ! transverse velocity deficit fraction from tower potential flow
   
   real(ReKi)                                   :: denom                   ! denominator
   real(ReKi)                                   :: v(3)                    ! temp vector
   
   integer(IntKi)                               :: j, k                    ! loop counters for elements, blades
   integer(intKi)                               :: ErrStat2
   character(ErrMsgLen)                         :: ErrMsg2
   character(*), parameter                      :: RoutineName = 'TwrInfl'
   
   
   ErrStat = ErrID_None
   ErrMsg  = ""   
   
   
      ! these models are valid for only small tower deflections; check for potential division-by-zero errors:   
   call CheckTwrInfl( u, ErrStat2, ErrMsg2 )
      call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )
      if (ErrStat >= AbortErrLev) return
      
   do k = 1, p%NumBlades
      do j = 1, u%BladeMotion(k)%NNodes
         
         ! for each line2-element node of the blade mesh, a nearest-neighbor line2 element or node of the tower 
         ! mesh is found in the deflected configuration, returning theta_tower, W_tower, xbar, ybar, zbar, and TowerCd:
         
         BladeNodePosition = u%BladeMotion(k)%Position(:,j) + u%BladeMotion(k)%TranslationDisp(:,j)
         
         call getLocalTowerProps(p, u, BladeNodePosition, theta_tower_trans, W_tower, xbar, ybar, zbar, TwrCd, ErrStat2, ErrMsg2)
            call SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )
            if (ErrStat >= AbortErrLev) return
         
      
         ! calculate tower influence:
         if ( abs(zbar) < 1.0_ReKi .and. p%TwrPotent /= TwrPotent_none ) then
            if ( p%TwrPotent == TwrPotent_baseline ) then
               
               denom = (xbar**2 + ybar**2)**2
               
               u_TwrPotent = ( -1.0*xbar**2 + ybar**2 ) / denom
               v_TwrPotent = ( -2.0*xbar    * ybar    ) / denom      
               
            elseif (p%TwrPotent == TwrPotent_Bak) then
               
               xbar = xbar + 0.1
               
               denom = (xbar**2 + ybar**2)**2               
               u_TwrPotent = ( -1.0*xbar**2 + ybar**2 ) / denom
               v_TwrPotent = ( -2.0*xbar    * ybar    ) / denom        
               
               denom = TwoPi*(xbar**2 + ybar**2)               
               u_TwrPotent = u_TwrPotent + TwrCd*xbar / denom
               v_TwrPotent = v_TwrPotent + TwrCd*ybar / denom                       
               
            end if
         else
            u_TwrPotent = 0.0_ReKi
            v_TwrPotent = 0.0_ReKi
         end if
         
         denom = sqrt( sqrt( xbar**2 + ybar**2 ) )
         if ( p%TwrShadow .and. abs(ybar) < denom .and. abs(zbar) < 1.0_ReKi ) then
            u_TwrShadow = -TwrCd / denom * cos( PiBy2*ybar / denom )**2
         else
            u_TwrShadow = 0.0_ReKi
         end if
                     
         v(1) = (u_TwrPotent + u_TwrShadow)*W_tower
         v(2) = v_TwrPotent*W_tower
         v(3) = 0.0_ReKi
         
         OtherState%DisturbedInflow(:,j,k) = u%InflowOnBlade(:,j,k) + matmul( theta_tower_trans, v ) 
      
      end do !j=NumBlNds
   end do ! NumBlades
   
   
END SUBROUTINE TwrInfl 
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE getLocalTowerProps(p, u, BladeNodePosition, theta_tower_trans, W_tower, xbar, ybar, zbar, TwrCd, ErrStat, ErrMsg)
! this routine returns the tower parameters necessary to compute the tower influence. 
! if u%TowerMotion does not have any nodes there will be serious problems. I assume that has been checked earlier.
!..................................................................................................................................
   TYPE(AD_InputType),           INTENT(IN   )  :: u                       ! Inputs at Time t
   TYPE(AD_ParameterType),       INTENT(IN   )  :: p                       ! Parameters
   REAL(ReKi)                   ,INTENT(IN   )  :: BladeNodePosition(3)    ! local blade node position
   REAL(ReKi)                   ,INTENT(  OUT)  :: theta_tower_trans(3,3)  ! transpose of local tower orientation expressed as a DCM
   REAL(ReKi)                   ,INTENT(  OUT)  :: W_tower                 ! local relative wind speed normal to the tower
   REAL(ReKi)                   ,INTENT(  OUT)  :: xbar                    ! local x^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                   ,INTENT(  OUT)  :: ybar                    ! local y^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                   ,INTENT(  OUT)  :: zbar                    ! local z^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                   ,INTENT(  OUT)  :: TwrCd                   ! local tower drag coefficient
   INTEGER(IntKi),               INTENT(  OUT)  :: ErrStat                 ! Error status of the operation
   CHARACTER(*),                 INTENT(  OUT)  :: ErrMsg                  ! Error message if ErrStat /= ErrID_None

   ! local variables
   real(ReKi)                                   :: r_TowerBlade(3)         ! distance vector from tower to blade
   real(ReKi)                                   :: TwrDiam                 ! local tower diameter  
   logical                                      :: found   
   character(*), parameter                      :: RoutineName = 'getLocalTowerProps'
   
   
   ErrStat = ErrID_None
   ErrMsg  = ""   
   
   ! ..............................................
   ! option 1: nearest line2 element
   ! ..............................................
   call TwrInfl_NearestLine2Element(p, u, BladeNodePosition, r_TowerBlade, theta_tower_trans, W_tower, xbar, ybar, zbar, TwrCd, TwrDiam, found)
   
   if ( .not. found) then 
      ! ..............................................
      ! option 2: nearest node
      ! ..............................................
      call TwrInfl_NearestPoint(p, u, BladeNodePosition, r_TowerBlade, theta_tower_trans, W_tower, xbar, ybar, zbar, TwrCd, TwrDiam)
         
   end if
   
   if ( TwoNorm(r_TowerBlade) < 0.5_ReKi*TwrDiam ) then
      call SetErrStat(ErrID_Severe, "Tower strike.", ErrStat, ErrMsg, RoutineName)
   end if
   
   
END SUBROUTINE getLocalTowerProps
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE TwrInfl_NearestLine2Element(p, u, BladeNodePosition, r_TowerBlade, theta_tower_trans, W_tower, xbar, ybar, zbar, TwrCd, TwrDiam, found)
! Option 1: Find the nearest-neighbor line2 element of the tower mesh for which the blade line2-element node projects orthogonally onto
!   the tower line2-element domain (following an approach similar to the line2_to_line2 mapping search for motion and scalar quantities). 
!   That is, for each node of the blade mesh, an orthogonal projection is made onto all possible Line2 elements of the tower mesh and 
!   the line2 element of the tower mesh that is the minimum distance away is found.
! Adapted from CreateMapping_ProjectToLine2()
!..................................................................................................................................
   TYPE(AD_InputType),              INTENT(IN   )  :: u                             ! Inputs at Time t
   TYPE(AD_ParameterType),          INTENT(IN   )  :: p                             ! Parameters
   REAL(ReKi)                      ,INTENT(IN   )  :: BladeNodePosition(3)          ! local blade node position
   REAL(ReKi)                      ,INTENT(  OUT)  :: r_TowerBlade(3)               ! distance vector from tower to blade
   REAL(ReKi)                      ,INTENT(  OUT)  :: theta_tower_trans(3,3)        ! transpose of local tower orientation expressed as a DCM
   REAL(ReKi)                      ,INTENT(  OUT)  :: W_tower                       ! local relative wind speed normal to the tower
   REAL(ReKi)                      ,INTENT(  OUT)  :: xbar                          ! local x^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                      ,INTENT(  OUT)  :: ybar                          ! local y^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                      ,INTENT(  OUT)  :: zbar                          ! local z^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                      ,INTENT(  OUT)  :: TwrCd                         ! local tower drag coefficient
   REAL(ReKi)                      ,INTENT(  OUT)  :: TwrDiam                       ! local tower diameter
   logical                         ,INTENT(  OUT)  :: found
      
      ! local variables
   REAL(ReKi)      :: denom
   REAL(ReKi)      :: dist
   REAL(ReKi)      :: min_dist
   REAL(ReKi)      :: elem_position, elem_position2
   REAL(SiKi)      :: elem_position_SiKi

   REAL(ReKi)      :: p1(3), p2(3)        ! position vectors for nodes on tower line 2 element
   
   REAL(ReKi)      :: V_rel_tower(3)
   
   REAL(ReKi)      :: n1_n2_vector(3)     ! vector going from node 1 to node 2 in Line2 element
   REAL(ReKi)      :: n1_Point_vector(3)  ! vector going from node 1 in Line 2 element to Destination Point
   REAL(ReKi)      :: tmp(3)              ! temporary vector for cross product calculation

   INTEGER(IntKi)  :: jElem               ! do-loop counter for elements on tower mesh

   INTEGER(IntKi)  :: n1, n2              ! nodes associated with an element

   LOGICAL         :: on_element
   
      
   found = .false.
   min_dist = HUGE(min_dist)

   do jElem = 1, u%TowerMotion%ElemTable(ELEMENT_LINE2)%nelem   ! number of elements on TowerMesh
         ! grab node numbers associated with the jElem_th element
      n1 = u%TowerMotion%ElemTable(ELEMENT_LINE2)%Elements(jElem)%ElemNodes(1)
      n2 = u%TowerMotion%ElemTable(ELEMENT_LINE2)%Elements(jElem)%ElemNodes(2)

      p1 = u%TowerMotion%Position(:,n1) + u%TowerMotion%TranslationDisp(:,n1)
      p2 = u%TowerMotion%Position(:,n2) + u%TowerMotion%TranslationDisp(:,n2)

         ! Calculate vectors used in projection operation
      n1_n2_vector    = p2 - p1
      n1_Point_vector = BladeNodePosition - p1

      denom           = DOT_PRODUCT( n1_n2_vector, n1_n2_vector ) ! we've already checked that these aren't zero

         ! project point onto line defined by n1 and n2

      elem_position = DOT_PRODUCT(n1_n2_vector,n1_Point_vector) / denom

            ! note: i forumlated it this way because Fortran doesn't necessarially do shortcutting and I don't want to call EqualRealNos if we don't need it:
      if ( elem_position .ge. 0.0_ReKi .and. elem_position .le. 1.0_ReKi ) then !we're ON the element (between the two nodes)
         on_element = .true.
      else
         elem_position_SiKi = REAL( elem_position, SiKi )
         if (EqualRealNos( elem_position_SiKi, 1.0_SiKi )) then !we're ON the element (at a node)
            on_element = .true.
            elem_position = 1.0_ReKi
         elseif (EqualRealNos( elem_position_SiKi,  0.0_SiKi )) then !we're ON the element (at a node)
            on_element = .true.
            elem_position = 0.0_ReKi
         else !we're not on the element
            on_element = .false.
         end if
         
      end if

      if (on_element) then

         ! calculate distance between point and line (note: this is actually the distance squared);
         ! will only store information once we have determined the closest element
         elem_position2 = 1.0_ReKi - elem_position
         
         r_TowerBlade  = BladeNodePosition - elem_position2*p1 - elem_position*p2
         dist = dot_product( r_TowerBlade, r_TowerBlade )

         if (dist .lt. min_dist) then
            found = .true.
            min_dist = dist

            V_rel_tower =   ( u%InflowOnTower(:,n1) - u%TowerMotion%TranslationVel(:,n1) ) * elem_position2  &
                          + ( u%InflowOnTower(:,n2) - u%TowerMotion%TranslationVel(:,n2) ) * elem_position
            
            TwrDiam     = elem_position2*p%TwrDiam(n1) + elem_position*p%TwrDiam(n2)
            TwrCd       = elem_position2*p%TwrCd(  n1) + elem_position*p%TwrCd(  n2)
            
            
            ! z_hat
            theta_tower_trans(:,3) = n1_n2_vector / sqrt( denom ) ! = n1_n2_vector / twoNorm( n1_n2_vector )
            
            tmp = V_rel_tower - dot_product(V_rel_tower,theta_tower_trans(:,3)) * theta_tower_trans(:,3)
            denom = TwoNorm( tmp )
            if (.not. EqualRealNos( denom, 0.0_ReKi ) ) then
               ! x_hat
               theta_tower_trans(:,1) = tmp / denom
               
               ! y_hat
               tmp = cross_product( theta_tower_trans(:,3), V_rel_tower )
               theta_tower_trans(:,2) = tmp / denom  
               
               W_tower = dot_product( V_rel_tower,theta_tower_trans(:,1) )
               xbar    = 2.0/TwrDiam * dot_product( r_TowerBlade, theta_tower_trans(:,1) )
               ybar    = 2.0/TwrDiam * dot_product( r_TowerBlade, theta_tower_trans(:,2) )
               zbar    = 0.0_ReKi
                                             
            else
                  ! there is no tower influence because dot_product(V_rel_tower,x_hat) = 0
                  ! thus, we don't need to set the other values (except we don't want the sum of xbar^2 and ybar^2 to be 0)
               theta_tower_trans = 0.0_ReKi
               W_tower           = 0.0_ReKi
               xbar              = 1.0_ReKi
               ybar              = 0.0_ReKi  
               zbar              = 0.0_ReKi
            end if
   
            
         end if !the point is closest to this line2 element

      end if

   end do !jElem

END SUBROUTINE TwrInfl_NearestLine2Element
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE TwrInfl_NearestPoint(p, u, BladeNodePosition, r_TowerBlade, theta_tower_trans, W_tower, xbar, ybar, zbar, TwrCd, TwrDiam)
! Option 2: used when the blade node does not orthogonally intersect a tower element
!  Find the nearest-neighbor node in the tower Line2-element domain (following an approach similar to the point_to_point mapping
!  search for motion and scalar quantities). That is, for each node of the blade mesh, the node of the tower mesh that is the minimum 
!  distance away is found.
!..................................................................................................................................
   TYPE(AD_InputType),              INTENT(IN   )  :: u                             ! Inputs at Time t
   TYPE(AD_ParameterType),          INTENT(IN   )  :: p                             ! Parameters
   REAL(ReKi)                      ,INTENT(IN   )  :: BladeNodePosition(3)          ! local blade node position
   REAL(ReKi)                      ,INTENT(  OUT)  :: r_TowerBlade(3)               ! distance vector from tower to blade
   REAL(ReKi)                      ,INTENT(  OUT)  :: theta_tower_trans(3,3)        ! transpose of local tower orientation expressed as a DCM
   REAL(ReKi)                      ,INTENT(  OUT)  :: W_tower                       ! local relative wind speed normal to the tower
   REAL(ReKi)                      ,INTENT(  OUT)  :: xbar                          ! local x^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                      ,INTENT(  OUT)  :: ybar                          ! local y^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                      ,INTENT(  OUT)  :: zbar                          ! local z^ component of r_TowerBlade normalized by tower radius
   REAL(ReKi)                      ,INTENT(  OUT)  :: TwrCd                         ! local tower drag coefficient
   REAL(ReKi)                      ,INTENT(  OUT)  :: TwrDiam                       ! local tower diameter
      
      ! local variables
   REAL(ReKi)      :: denom
   REAL(ReKi)      :: dist
   REAL(ReKi)      :: min_dist
   REAL(ReKi)      :: cosTaper

   REAL(ReKi)      :: p1(3)                     ! position vectors for nodes on tower   
   REAL(ReKi)      :: V_rel_tower(3)
   
   REAL(ReKi)      :: tmp(3)                    ! temporary vector for cross product calculation

   INTEGER(IntKi)  :: n1                        ! node
   INTEGER(IntKi)  :: node_with_min_distance    

   
   
      !.................
      ! find the closest node
      !.................
      
   min_dist = HUGE(min_dist)
   node_with_min_distance = 0

   do n1 = 1, u%TowerMotion%NNodes   ! number of nodes on TowerMesh
      
      p1 = u%TowerMotion%Position(:,n1) + u%TowerMotion%TranslationDisp(:,n1)
      
         ! calculate distance between points (note: this is actually the distance squared);
         ! will only store information once we have determined the closest node
      r_TowerBlade  = BladeNodePosition - p1         
      dist = dot_product( r_TowerBlade, r_TowerBlade )

      if (dist .lt. min_dist) then
         min_dist = dist
         node_with_min_distance = n1
               
      end if !the point is (so far) closest to this blade node

   end do !n1
   
      !.................
      ! calculate the values to be returned:  
      !..................
   if (node_with_min_distance == 0) then
      node_with_min_distance = 1
      if (NWTC_VerboseLevel == NWTC_Verbose) call WrScr( 'AD:TwrInfl_NearestPoint:Error finding minimum distance. Positions may be invalid.' )
   end if
   
   n1 = node_with_min_distance
   
   r_TowerBlade = BladeNodePosition - u%TowerMotion%Position(:,n1) - u%TowerMotion%TranslationDisp(:,n1)
   V_rel_tower  = u%InflowOnTower(:,n1) - u%TowerMotion%TranslationVel(:,n1)
   TwrDiam      = p%TwrDiam(n1) 
   TwrCd        = p%TwrCd(  n1) 
                           
   ! z_hat
   theta_tower_trans(:,3) = u%TowerMotion%Orientation(3,:,n1)
            
   tmp = V_rel_tower - dot_product(V_rel_tower,theta_tower_trans(:,3)) * theta_tower_trans(:,3)
   denom = TwoNorm( tmp )
   
   if (.not. EqualRealNos( denom, 0.0_ReKi ) ) then
      
      ! x_hat
      theta_tower_trans(:,1) = tmp / denom
               
      ! y_hat
      tmp = cross_product( theta_tower_trans(:,3), V_rel_tower )
      theta_tower_trans(:,2) = tmp / denom  
               
      W_tower = dot_product( V_rel_tower,theta_tower_trans(:,1) )

      if ( n1 == 1 .or. n1 == u%TowerMotion%NNodes) then         
         ! option 2b
         zbar    = 2.0/TwrDiam * dot_product( r_TowerBlade, theta_tower_trans(:,3) )
         if (abs(zbar) < 1) then   
            cosTaper = cos( PiBy2*zbar )
            xbar = 2.0/TwrDiam * dot_product( r_TowerBlade, theta_tower_trans(:,1) ) / cosTaper
            ybar = 2.0/TwrDiam * dot_product( r_TowerBlade, theta_tower_trans(:,2) ) / cosTaper
         else ! we check that zbar < 1 before using xbar and ybar later, but I'm going to set them here anyway:
            xbar = 1.0_ReKi
            ybar = 0.0_ReKi  
         end if                                    
      else
         ! option 2a
         xbar    = 2.0/TwrDiam * dot_product( r_TowerBlade, theta_tower_trans(:,1) )
         ybar    = 2.0/TwrDiam * dot_product( r_TowerBlade, theta_tower_trans(:,2) )
         zbar    = 0.0_ReKi
      end if

   else
      
         ! there is no tower influence because W_tower = dot_product(V_rel_tower,x_hat) = 0
         ! thus, we don't need to set the other values (except we don't want the sum of xbar^2 and ybar^2 to be 0)
      W_tower           = 0.0_ReKi
      theta_tower_trans = 0.0_ReKi
      xbar              = 1.0_ReKi
      ybar              = 0.0_ReKi  
      zbar              = 0.0_ReKi
      
   end if   

END SUBROUTINE TwrInfl_NearestPoint
!----------------------------------------------------------------------------------------------------------------------------------
END MODULE AeroDyn
