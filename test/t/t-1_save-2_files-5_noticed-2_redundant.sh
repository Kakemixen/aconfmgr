
#!/bin/bash
source ./lib.bash

# Test ignored files (simple path without shell patterns).

TestPhase_Setup ###############################################################
TestAddFile /strayfile.txt 'Stray file contents'
TestAddFile /strayfile2.txt 'Stray file contents'

#TestAddConfig IgnorePath /dir
TestAddConfig IgnorePath /strayfile.txt
TestAddConfig NoticePath /strayfile2.txt

TestPhase_Run #################################################################
AconfSave

TestPhase_Check ###############################################################
TestExpectConfig <<EOF
CopyFile /strayfile2.txt
EOF

TestDone ######################################################################
