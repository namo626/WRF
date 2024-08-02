      module module_offload_advect

      implicit none

      public

      real, allocatable, dimension(:,:,:) :: ru_device, rv_device
   REAL , allocatable, DIMENSION(:,:,:)  :: field_d,   field_old_d
      !$omp declare target(ru_device, rv_device)
      !$omp declare target(field_d, field_old_d)

      contains

      subroutine alloc_offload_advect(ims,ime,kms,kme,jms,jme)
      implicit none

      integer, intent(in) :: ims,ime,kms,kme,jms,jme

      allocate( ru_device(ims:ime, kms:kme, jms:jme) )
      allocate( rv_device(ims:ime, kms:kme, jms:jme) )

     !$omp target enter data map(to: ru_device, rv_device)

      end subroutine alloc_offload_advect

      subroutine update_offload_advect(ims,ime,kms,kme,jms,jme, ru, rv)
      implicit none
      integer, intent(in) :: ims,ime,kms,kme,jms,jme

      REAL , DIMENSION( ims:ime , kms:kme , jms:jme ) , INTENT(IN   ) :: ru, rv

      if (allocated(ru_device)) then
         ru_device = ru
         rv_device = rv
         !$omp target update to( ru_device, rv_device)
      else
         call alloc_offload_advect(ims,ime,kms,kme,jms,jme)
      endif

      end subroutine update_offload_advect

      subroutine update_offload_field(ims,ime,kms,kme,jms,jme, f, f_old, nowait)
      implicit none

      integer, intent(in) :: ims,ime,kms,kme,jms,jme
      logical, intent(in) :: nowait
      REAL , DIMENSION( ims:ime , kms:kme , jms:jme ) , INTENT(IN   ) :: f, f_old

      if (allocated(field_d)) then
         field_d = f
         field_old_d = f_old
         if (nowait) then
            !$omp target update to(field_d, field_old_d) nowait
         else
            !$omp target update to(field_d, field_old_d)
         endif


      else
         allocate( field_d(ims:ime, kms:kme, jms:jme) )
         allocate( field_old_d(ims:ime, kms:kme, jms:jme) )
         !$omp target enter data map(to: field_d, field_old_d)
      endif


      end subroutine update_offload_field



      subroutine free_offload_advect(ims,ime,kms,kme,jms,jme)
      implicit none
      integer, intent(in) :: ims,ime,kms,kme,jms,jme

      deallocate(ru_device, rv_device)

      end subroutine free_offload_advect

      end module module_offload_advect
