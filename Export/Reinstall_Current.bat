::nanoCAD СПДС Эстакады 1
start /wait msiexec.exe /x {AE7A9835-1B3C-46F9-A932-3C6A9735B073} /quiet
::nanoCAD СПДС Стройплощадка 3x64
start /wait msiexec.exe /x {6E375845-D282-4267-B1CE-41849826D1CA} /quiet
::СПДС Стройплощадка 3
start /wait msiexec.exe /x {3660D13B-7B84-4EE3-838C-963AD91905FC} /quiet
::СПДС GraphiCS 8x64
start /wait msiexec.exe /x {8BFD9524-825B-4F2C-8E2A-EDCA836D27CE} /quiet
::MechaniCS 10x64
start /wait msiexec.exe /x {6033A16E-379D-42DC-A48F-EB31A59D5018} /quiet
::nanoCAD СПДС 4.0
start /wait msiexec.exe /x {863744AD-5960-4B8B-8C95-6D14D8251BC4} /quiet
::nanoCAD Механика 4.0
start /wait msiexec.exe /x {4A98D236-A1B4-4AF3-A069-68AC54042467} /quiet
::nanoCAD Железобетон 1.0
start /wait msiexec.exe /x {31FCB128-6994-4639-9586-7C3085C0EA6C} /quiet

::pause

"\\build-server\distrib\Nano40\nmech4\nMech40(1963.1287).exe"/i /quiet 
"\\BUILD-SERVER\Distrib\Nano40\bridges1\nBridge10(1963.1287).exe" /i /quiet 
"\\BUILD-SERVER\Distrib\Nano40\nspds4\nSpds40(1963.1287).exe" /i /quiet
"\\BUILD-SERVER\Distrib\Nano40\ppr3\nPPR30(1963.1287).exe" /i /quiet
"\\build-server\Distrib\Nano40\sprc1\nRC10(1963.1287).exe" /i /quiet

"\\BUILD-SERVER\Distrib\Spds\8\acad\Full\x64\setup.exe"  /i /quiet
"\\BUILD-SERVER\Distrib\PPR\3\x64\setup.exe" /i /quiet
"\\BUILD-SERVER\Distrib\MechaniCS\9.2\acad\Full\x64\setup.exe" /i /quiet
"\\BUILD-SERVER\Distrib\RC\1\x64\setup.exe" /i /quiet