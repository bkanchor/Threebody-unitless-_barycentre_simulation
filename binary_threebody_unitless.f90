!===============================================================
! A three body integrator in Fortran without using any additional math library.
! Place two bodies of the same mass on a stationary circular orbit around each other, and take a 3rd body with a negligible mass.
! Initial coordinates and velocity vector for the third body is an input.
! Output the trajectory of all three bodies for 10 orbital revolutions for several intial inputs for the third body, and plot it on xy and xz.
! You can ignore the effect of the 3rd body on the two bodies
!===============================================================

PROGRAM ThreeBodyDiagram
    IMPLICIT NONE
    INTEGER, PARAMETER :: dp = kind(1.0d0)
    INTEGER :: i, nfilled
    CHARACTER(len=100) :: outfile

    !---Physical constants---
    REAL(dp), PARAMETER :: G = 1

    !---Two equal-mass bodies---
    REAL(dp), PARAMETER :: m = 1
    REAL(dp), PARAMETER :: D = 2
    REAL(dp) :: r1(3), r2(3), v1(3), v2(3)
    REAL(dp) :: a12(3), a21(3), a12n(3), a21n(3)

    !---Third (test) body---
    REAL(dp) :: r3(3), v3(3), a3(3), a3n(3)

    !---Time parameters---
    REAL(dp), PARAMETER :: PI = 4.0d0 * ATAN(1.0d0)
    REAL(dp), PARAMETER :: Period = 2 * PI * sqrt( (D)**3 / (G * 2.0d0 * m) ) ! 1 oscillation
    REAL(dp), PARAMETER :: t_max = 10 * Period     ! 10 oscillations
    REAL(dp), PARAMETER :: dt = 0.001
    INTEGER, PARAMETER :: nsteps = CEILING(t_max / dt) + 100
    REAL(dp) :: t = 0.0d0

    !---Trajectory storage---
    REAL(dp), ALLOCATABLE :: traj1(:, :), traj2(:, :), traj3(:, :)

    !---Initial Setup---
    ALLOCATE(traj1(3, nsteps))
    ALLOCATE(traj2(3, nsteps))
    ALLOCATE(traj3(3, nsteps))
    traj1 = 0.0d0
    traj2 = 0.0d0
    traj3 = 0.0d0

    !---Initial positions of the two masses---
    r1 = (/ D / 2.0d0, 0.0d0, 0.0d0 /)
    r2 = (/ -D / 2.0d0, 0.0d0, 0.0d0 /)

    !---Initial velocities (circular orbit) of the two masses---
    v1 = (/ 0.0d0,  sqrt(G * m * (D / 2.0d0) / (D**2)), 0.0d0 /)
    v2 = (/ 0.0d0, -sqrt(G * m * (D / 2.0d0) / (D**2)), 0.0d0 /)

    !---Test body input---
    PRINT *, 'Enter initial x, y, z (space separated) for the third body:'
    READ *, r3(1), r3(2), r3(3)
    PRINT *, 'Enter initial vx, vy, vz (space separated) for the third body:'
    READ *, v3(1), v3(2), v3(3)

    !---Initial accelerations---
    CALL accel(r1, r2, m, a12)
    CALL accel(r2, r1, m, a21)
    CALL accel_test(r3, r1, r2, m, a3)

    !---Store initial positions---
    i = 1
    traj1(:, i) = r1
    traj2(:, i) = r2
    traj3(:, i) = r3

    !--- Velocity Verlet Algorithm---
    DO WHILE (t < t_max .AND. i < nsteps)
        t = t + dt

        !---Iterating positions---
        r1 = r1 + v1 * dt + 0.5d0 * a12 * dt**2
        r2 = r2 + v2 * dt + 0.5d0 * a21 * dt**2
        r3 = r3 + v3 * dt + 0.5d0 * a3  * dt**2

        !---Calculate the accelerations for the new positions---
        CALL accel(r1, r2, m, a12n)
        CALL accel(r2, r1, m, a21n)
        CALL accel_test(r3, r1, r2, m, a3n)

        !---Iterating velocities---
        v1 = v1 + 0.5d0 * (a12 + a12n) * dt
        v2 = v2 + 0.5d0 * (a21 + a21n) * dt
        v3 = v3 + 0.5d0 * (a3  + a3n)  * dt

        !---Iterating accelerations---
        a12 = a12n
        a21 = a21n
        a3  = a3n

        !---Recording new positions---
        i = i + 1
        traj1(:, i) = r1
        traj2(:, i) = r2
        traj3(:, i) = r3
    END DO

    !===============================================================
    ! Output; writing data into a .txt file is helped by ChatGPT
    !===============================================================
    nfilled = i
    outfile = 'threebody_output.dat'
    OPEN(unit=10, file=outfile, status='replace')
    WRITE(10, '(a)') '# x1 y1 z1  x2 y2 z2  x3 y3 z3'
    DO i = 1, nfilled
        WRITE(10, '(9e20.10)') traj1(:, i), traj2(:, i), traj3(:, i)
    END DO
    CLOSE(10)
    PRINT *, 'Trajectory written to ', TRIM(outfile)

    DEALLOCATE(traj1, traj2, traj3)

END PROGRAM ThreeBodyDiagram


!===============================================================
! Subroutine: accel
!   Computes gravitational acceleration on body 1 due to body 2, ignoring the third (test) body's mass.
!===============================================================
SUBROUTINE accel(r1, r2, m, a)
    IMPLICIT NONE
    INTEGER, PARAMETER :: dp = kind(1.0d0)
    REAL(dp), PARAMETER :: G = 1
    REAL(dp), INTENT(in) :: r1(3), r2(3), m
    REAL(dp), INTENT(out) :: a(3)
    REAL(dp) :: dr(3), drmag

    dr = r2 - r1
    drmag = sqrt(dr(1)**2 + dr(2)**2 + dr(3)**2)
    a = G * m * dr / (drmag**3)
END SUBROUTINE accel


!===============================================================
! Subroutine: accel_test
!   Computes gravitational acceleration on test body due to both stars.
!===============================================================
SUBROUTINE accel_test(r3, r1, r2, m, a)
    IMPLICIT NONE
    INTEGER, PARAMETER :: dp = kind(1.0d0)
    REAL(dp), PARAMETER :: G = 1
    REAL(dp), INTENT(in) :: r3(3), r1(3), r2(3), m
    REAL(dp), INTENT(out) :: a(3)
    REAL(dp) :: dr1(3), dr2(3), drmag1, drmag2

    dr1 = r1 - r3
    dr2 = r2 - r3
    drmag1 = sqrt(dr1(1)**2 + dr1(2)**2 + dr1(3)**2)
    drmag2 = sqrt(dr2(1)**2 + dr2(2)**2 + dr2(3)**2)
    a = G * m * (dr1 / (drmag1**3) + dr2 / (drmag2**3))
END SUBROUTINE accel_test
