#!/bin/bash
source ./lib.bash

# Test ignored files (simple path without shell patterns).

TestPhase_Setup ###############################################################
TestAddFile /dir/strayfile.txt 'Stray file contents'
TestAddFile /dir/strayfile2.txt 'Stray file contents'

#TestAddConfig IgnorePath /dir
TestAddConfig IgnorePath /dir
TestAddConfig NoticePath /dir/strayfile2.txt

TestPhase_Run #################################################################
AconfSave

TestPhase_Check ###############################################################
TestExpectConfig <<EOF
CopyFile /dir/strayfile2.txt
EOF

TestDone ######################################################################
