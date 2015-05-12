# Instructions after checking out repository

# 1. Update the MAINDIR shell variable in coNLSP.cfg with your current working path

# 2. To generate slha file
./make_slha.sh coNLSP.cfg

# 3. To generate lhe file
./make_lhe.sh coNLSP.cfg

# To compile pythia fotran file if having compilation issues
# (Note: a .o file has been provided. This step may be skipped.)
gfortran -c -m64 -fPIC pythia-6.4.26.f

# To create fortran executable file
# (Note: a .out file has been provided. This step may be skipped.)
gfortran -ffixed-line-length-none coNLSP.f  pythia-6.4.26.o -o coNLSP.out

# To run executable file
# (Note: for debuging purposes. This step may be skipped.)
./test/coNLSP.out <enter>
1 5000 13.0D3 22.95 "store/slha/coNLSP_chargino1400_gluino1700.slha" "store/pythialogs/coNLSP_chargino1400_gluino1700.txt" "store/lhe/coNLSP_chargino1400_gluino1700.lhe" <enter>

# 4. To generate MINIAODSIM files
./make_miniaodsim.sh coNLSP.cfg
