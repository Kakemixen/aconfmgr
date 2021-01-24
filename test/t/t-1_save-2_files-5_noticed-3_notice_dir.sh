
#!/bin/bash
source ./lib.bash

# Test ignored files (simple path without shell patterns).

TestPhase_Setup ###############################################################
TestAddFile /dir1/dir2/strayfile1.txt 'Stray file contents'
TestAddFile /dir1/dir2/strayfile2.txt 'Stray file contents'
TestAddFile /dir1/dir3/strayfile3.txt 'Stray file contents'
TestAddFile /dir1/dir3/strayfile4.txt 'Stray file contents'

TestAddConfig IgnorePath /dir1
TestAddConfig NoticePath /dir1/dir2

TestPhase_Run #################################################################
AconfSave

TestPhase_Check ###############################################################
TestExpectConfig <<EOF
CopyFile /dir1/dir2/strayfile1.txt
CopyFile /dir1/dir2/strayfile2.txt
EOF

TestDone ######################################################################
