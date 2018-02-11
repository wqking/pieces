Name SampleInstaller
OutFile SampleInstallerSetup.exe

SetCompressor /SOLID /FINAL LZMA

#Icon "someicon.ico"

VIAddVersionKey "ProductName" "Sample Product"
VIAddVersionKey "Comments" "This is only a sample"
VIAddVersionKey "CompanyName" "Sample Company"
VIAddVersionKey "LegalCopyright" "(c) Sample"
VIAddVersionKey "FileDescription" "Sample installer"
VIAddVersionKey "FileVersion" "1.0"
VIProductVersion "1.0.0.0"
VIFileVersion "1.0.0.0"

LicenseText "End-User License Agreement"
LicenseData README.md # sample!
#LicenseForceSelection checkbox

!include "installer.nsh"

Section "Install"
	Call doGetFolderIndicators # install files to Indicators folders
	SetOutPath $0

	File ".\README.md" # sample!
	File ".\installer.nsh" # sample!
	File ".\sample.nsi" # sample!
SectionEnd
