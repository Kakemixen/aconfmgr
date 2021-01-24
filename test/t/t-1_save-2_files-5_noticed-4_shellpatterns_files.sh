#!/bin/bash
source ./lib.bash

# Test ignored files (using shell patterns).

TestPhase_Setup ###############################################################
TestAddFile /dir1/strayfile.txt 'Stray file contents'
TestAddFile /dir1/strayfile_abc.txt 'Stray file contents'
TestAddFile /dir1/strayfile_xyz.txt 'Stray file contents'
TestAddFile /dir1/strayfile-one.txt 'Stray file contents'
TestAddFile /dir1/strayfile-three.txt 'Stray file contents'
TestAddFile '/dir2/strayfile aa x b.txt' 'Stray file contents'
TestAddFile '/dir2/strayfile c x ddd.txt' 'Stray file contents'
TestAddFile '/dir2/strayfile e y ff.txt' 'Stray file contents'
TestAddFile '/dir2/strayfile_jeff.txt' 'Stray file contents'
TestAddFile /dir3/strayfilea.txt 'Stray file contents'
TestAddFile /dir3/strayfileb.txt 'Stray file contents'
TestAddFile /dir3/strayfileg.txt 'Stray file contents'
TestAddFile /dir3/strayfilex.txt 'Stray file contents'
TestAddFile /dir3/strayfiley.txt 'Stray file contents'
TestAddFile /dir3/strayfilez.txt 'Stray file contents'
TestAddFile /dir3/strayfile-two.txt 'Stray file contents'

TestAddConfig IgnorePath "'"'*'"'"
TestAddConfig NoticePath "'"'/dir1/strayfile_*.txt'"'"
TestAddConfig NoticePath "'"'/dir1/strayfile-?????.txt'"'"
TestAddConfig NoticePath "'"'/dir2/strayfile * x*.txt'"'"
TestAddConfig NoticePath "'"'/dir3/strayfile[a-hy].txt'"'"

TestPhase_Run #################################################################
AconfSave

TestPhase_Check ###############################################################
TestExpectConfig <<EOF
CopyFile /dir1/strayfile-three.txt
CopyFile /dir1/strayfile_abc.txt
CopyFile /dir1/strayfile_xyz.txt
CopyFile /dir2/strayfile\ aa\ x\ b.txt
CopyFile /dir2/strayfile\ c\ x\ ddd.txt
CopyFile /dir3/strayfilea.txt
CopyFile /dir3/strayfileb.txt
CopyFile /dir3/strayfileg.txt
CopyFile /dir3/strayfiley.txt
EOF


TestDone ######################################################################
