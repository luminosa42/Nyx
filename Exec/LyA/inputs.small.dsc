# This is an example script that shows how to run a small Nyx problem with
# sidecars doing post-processing. The sidecar-specific parameters are at the
# end of the inputs file.

# ------------------  INPUTS TO MAIN PROGRAM  -------------------
max_step = 20
max_step = 30

particles.nreaders=1

nyx.ppm_type         = 0
nyx.use_colglaz      = 1
nyx.add_ext_src      = 1
nyx.heat_cool_type   = 1
nyx.strang_split     = 1
gravity.show_timings = 1
nyx.show_timings     = 1

#This is 1e-8 times the lowest density in plt00000
nyx.small_dens = 5.162470e1

#This is 1e-5 times the constant temparature in plt00000
nyx.small_temp = 1.e-2

#This is 1e-8 times the lowest pressure in plt00000
nyx.small_pres = 3.487507e2

nyx.do_santa_barbara = 1
nyx.init_sb_vels     = 1
gravity.sl_tol = 1.e-12

nyx.initial_z = 100.0
nyx.final_z = 2.0

#File written during the run: nstep | time | dt | redshift | a
amr.data_log = runlog
#amr.grid_log = grdlog

#This is how we restart from a checkpoint and write an ascii particle file
#Leave this commented out in cvs version
#amr.restart = chk00070
#max_step = 4
#particles.particle_output_file = particle_output

gravity.gravity_type = PoissonGrav
gravity.no_sync      = 1
gravity.no_composite = 1

mg.bottom_solver = 4

# PROBLEM SIZE & GEOMETRY
geometry.is_periodic =  1     1     1
geometry.coord_sys   =  0

geometry.prob_lo     =  0     0     0

#Domain size in Mpc
geometry.prob_hi     =  8.0  8.0  8.0

amr.n_cell           = 32 32 32
amr.n_cell           = 64 64 64
amr.max_grid_size    = 32
amr.max_grid_size    = 8


# >>>>>>>>>>>>>  BC FLAGS <<<<<<<<<<<<<<<<
# 0 = Interior           3 = Symmetry
# 1 = Inflow             4 = SlipWall
# 2 = Outflow
# >>>>>>>>>>>>>  BC FLAGS <<<<<<<<<<<<<<<<
nyx.lo_bc       =  0   0   0
nyx.hi_bc       =  0   0   0

# WHICH PHYSICS
nyx.do_hydro = 1
nyx.do_grav  = 1

# PARTICLES
nyx.do_dm_particles = 1

# >>>>>>>>>>>>>  PARTICLE INIT OPTIONS <<<<<<<<<<<<<<<<
#  "AsciiFile"        "Random"	    "Cosmological"
# >>>>>>>>>>>>>  PARTICLE INIT OPTIONS <<<<<<<<<<<<<<<<
nyx.particle_init_type = BinaryFile
nyx.binary_particle_file = 32.nyx

# >>>>>>>>>>>>>  PARTICLE MOVE OPTIONS <<<<<<<<<<<<<<<<
#  "Gravitational"    "Random"
# >>>>>>>>>>>>>  PARTICLE MOVE OPTIONS <<<<<<<<<<<<<<<<
nyx.particle_move_type = Gravitational


# TIME STEP CONTROL
nyx.relative_max_change_a = 0.01    # max change in scale factor
particles.cfl             = 0.5     # 'cfl' for particles 
nyx.cfl                   = 0.9     # cfl number for hyperbolic system
nyx.init_shrink           = 1.0     # scale back initial timestep
nyx.change_max            = 1.1     # factor by which timestep can change
nyx.dt_cutoff             = 5.e-20  # level 0 timestep below which we halt

# DIAGNOSTICS & VERBOSITY
nyx.print_fortran_warnings = 0
nyx.sum_interval      = -1      # timesteps between computing mass
nyx.v                 = 1       # verbosity in Nyx.cpp
gravity.v             = 1       # verbosity in Gravity.cpp
amr.v                 = 1       # verbosity in Amr.cpp
mg.v                  = 1       # verbosity in Amr.cpp
particles.v           = 2       # verbosity in Particle class

# REFINEMENT / REGRIDDING
amr.max_level          = 0        # maximum level number allowed
#amr.ref_ratio          = 2 2 2 2
#amr.regrid_int         = 4 4 4 4
#amr.n_error_buf        = 0 0 0 8
#amr.refine_grid_layout = 1
#amr.regrid_on_restart  = 1
#amr.blocking_factor    = 32

# CHECKPOINT FILES
amr.check_file      = chk
amr.check_int       = 1
amr.checkpoint_files_output = 0

# PLOTFILES
amr.plot_file       = plt
amr.plot_int        = 1
amr.plot_files_output = 0

amr.plot_vars        = ALL
amr.derive_plot_vars = particle_count particle_mass_density pressure magvel

#PROBIN FILENAME
amr.probin_file = probin

# >>>>>>>>>>>>>>>>>>>> SIDECARS <<<<<<<<<<<<<<<<<<<<
# how many MPI procs to use for sidecars?
# Reeber needs at least 8.
nSidecars = 8
# how to distribute grids on sidecar procs? "2" means random
how = 2
# time step interval for doing Gimlet analysis
nyx.gimlet_int = 5

# Parameters to Reeber. Remember that nyx.halo_int and reeber.halo_int need to
# be the same.
reeber.halo_int = 5
reeber.component = 0
reeber.negate = 1
reeber.merge_tree_file = merge-tree-density
reeber.merge_tree_int = 10
reeber.compute_persistence_diagram = 1
reeber.persistence_diagram_file = persistence-diagram-density
reeber.persistence_diagram_int = 1
reeber.persistence_diagram_eps = 1.0e9
reeber.compute_halos = 1
reeber.halo_extrema_threshold = 7.0e9
reeber.halo_component_threshold = 6.0e9
reeber.halo_extrema_threshold = 7.5e9
reeber.halo_component_threshold = 7.0e9
# >>>>>>>>>>>>>>>>>>>> SIDECARS <<<<<<<<<<<<<<<<<<<<
