
#include "Nyx.H"
#include "Nyx_F.H"

using namespace amrex;
using std::string;

void
Nyx::strang_first_step (Real time, Real dt, MultiFab& S_old, MultiFab& D_old)
{
    BL_PROFILE("Nyx::strang_first_step()");
    Real half_dt = 0.5*dt;

    const Real a = get_comoving_a(time);

#ifdef _OPENMP
#pragma omp parallel
#endif
    for (MFIter mfi(S_old,true); mfi.isValid(); ++mfi)
    {
        // Note that this "bx" includes the grow cells 
        const Box& bx = mfi.growntilebox(S_old.nGrow());

        int  min_iter = 100000;
        int  max_iter =      0;

        integrate_state
                (bx.loVect(), bx.hiVect(), 
                 BL_TO_FORTRAN(S_old[mfi]),
                 BL_TO_FORTRAN(D_old[mfi]),
                 &a, &half_dt, &min_iter, &max_iter);

#ifndef NDEBUG
        if (S_old[mfi].contains_nan())
            amrex::Abort("state has NaNs after the first strang call");
#endif

    }
}

void
Nyx::strang_second_step (Real time, Real dt, MultiFab& S_new, MultiFab& D_new)
{
    BL_PROFILE("Nyx::strang_second_step()");
    Real half_dt = 0.5*dt;
    int  min_iter = 100000;
    int  max_iter =      0;

    int min_iter_grid;
    int max_iter_grid;

    const Real a = get_comoving_a(time);

    compute_new_temp();

#ifdef _OPENMP
#pragma omp parallel
#endif
    for (MFIter mfi(S_new,true); mfi.isValid(); ++mfi)
    {
        // Here bx is just the valid region
        const Box& bx = mfi.tilebox();

        min_iter_grid = 100000;
        max_iter_grid =      0;

        integrate_state
            (bx.loVect(), bx.hiVect(), 
             BL_TO_FORTRAN(S_new[mfi]),
             BL_TO_FORTRAN(D_new[mfi]),
             &a, &half_dt, &min_iter_grid, &max_iter_grid);

        if (S_new[mfi].contains_nan(bx,0,S_new.nComp()))
        {
            std::cout << "NANS IN THIS GRID " << bx << std::endl;
        }

        min_iter = std::min(min_iter,min_iter_grid);
        max_iter = std::max(max_iter,max_iter_grid);
    }

    ParallelDescriptor::ReduceIntMax(max_iter);
    ParallelDescriptor::ReduceIntMin(min_iter);

    if (heat_cool_type == 1)
        if (ParallelDescriptor::IOProcessor())
            std::cout << "Min/Max Number of Iterations in Second Strang: " << min_iter << " " << max_iter << std::endl;
}
