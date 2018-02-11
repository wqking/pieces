!include nsDialogs.nsh
!include LogicLib.nsh
!include WinMessages.nsh
!include WordFunc.nsh

BrandingText " "

XPStyle on

Var dialogHandle
Var metaTraderListBox
Var browseButton
Var folderEdit
Var root
Var appDataPath
Var installFolder
Var previousSelection
Var tempText
Var fileHandle
Var tempPath
Var originalText

Page license
Page custom metaTraderSelectionPage metaTraderSelectionPageLeave
Page custom beforeInstallPage beforeInstallPageLeave
Page instfiles

Function beforeInstallPage
	nsDialogs::Create 1018
	Pop $0

	${If} $0 == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 0 0 100% 10% "It's ready to install files."
	${NSD_CreateLabel} 0 10% 100% 10% "Please close any running MetaTrader before start."

	nsDialogs::Show

FunctionEnd

Function beforeInstallPageLeave

FunctionEnd

Function metaTraderSelectionPage

	nsDialogs::Create 1018
	Pop $dialogHandle

	${If} $dialogHandle == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 0 0 100% 10% "Select destination directory to install"
	nsDialogs::CreateControl /NOUNLOAD ${__NSD_ListBox_CLASS} ${__NSD_ListBox_STYLE}|${WS_HSCROLL} ${__NSD_ListBox_EXSTYLE} 0 10% 100% 70% ""
	Pop $metaTraderListBox
	SendMessage $metaTraderListBox ${LB_SETHORIZONTALEXTENT} 1000 0
	${NSD_OnChange} $metaTraderListBox onListBoxChanged

	${NSD_CreateText} 0 85% 80% 24 ""
	Pop $folderEdit

	${NSD_CreateBrowseButton} 81% 85% 19% 30 "Browse..."
	Pop $browseButton
	GetFunctionAddress $0 onBrowseButtonClicked
	nsDialogs::OnClick /NOUNLOAD $browseButton $0

	System::Call 'shell32::SHGetSpecialFolderPath(i $HWNDPARENT, t .r1, i 0x1A, i0)i.r0'

	StrCpy $appDataPath $1

	# search in MetaQuotes path
	StrCpy $root "$appDataPath\MetaQuotes\Terminal"
	Call doSearchMetaTrader

	# search in app data path
	StrCpy $root "$appDataPath"
	Call doSearchMetaTrader

	nsDialogs::Show

FunctionEnd

Function metaTraderSelectionPageLeave
#	${NSD_LB_GetSelection} $metaTraderListBox $installFolder
	${NSD_GetText} $folderEdit $installFolder

	${If} $installFolder == ""
		MessageBox MB_OK|MB_ICONINFORMATION "MetaTrader folder must be set."
		Abort
	${EndIf}
	
	# avoid function not referenced warning
	Call doGetFolderExperts
	Call doGetFolderIndicators
	Call doGetFolderScripts
FunctionEnd

Function onBrowseButtonClicked
	nsDialogs::SelectFolderDialog "Select a folder" ""
	Pop $9
	StrCmp $9 "error" done
#	${NSD_LB_AddString} $metaTraderListBox "$9"
#	${NSD_LB_SelectString} $metaTraderListBox "$9"
	${NSD_SetText} $folderEdit "$9"
	done:
FunctionEnd

Function onListBoxChanged
	${NSD_LB_GetSelection} $metaTraderListBox $installFolder
	${If} $previousSelection != $installFolder
		StrCpy $previousSelection  $installFolder

		${WordFind} $installFolder ">" "+2}*" $7
		${If} $7 == ""
			StrCpy $7 $installFolder
		${EndIf}
		StrCpy $installFolder $7

		${NSD_SetText} $folderEdit $installFolder
	${EndIf}
FunctionEnd

Function isMetaTraderDataPath
	StrCpy $9 ""
	${If} ${FileExists} "$8\MQL4\*"
	${AndIf} ${FileExists} "$8\profiles\*"
	${AndIf} ${FileExists} "$8\config\*"
		StrCpy $9 "1"
	${EndIf}
FunctionEnd

# http://nsis.sourceforge.net/Unicode_FileRead
Function "FileReadUnicode"
	Push $0
	Exch 
	Pop $0 ; handle
	Push $1
	Push $2
	Push $3
	Push $4
 
	IntOp $4 0 + 0
	IntOp $3 0 + 0
	StrCpy $1 ""
	SetErrorLevel 0
read:	
	FileReadByte $0 $2
	IntCmp $4 0 0 skip skip
	IntCmp $2 0x0a skip 0 0 
	IntCmp $2 0x0d readsecondhalf 0 0 
	IntCmp $2 0 done 0 0
	IntFmt $2 "%c" $2
	StrCpy $1 "$1$2"
skip:	
	IntOp $4 $4 + 1
	IntOp $4 $4 % 2
	Goto read
readsecondhalf:	
	FileReadByte $0 $2
done:	
	Pop $4
	Pop $3
	Pop $2
	Push $1
	Exch 
	Pop $1
	Exch 
	Pop $0
FunctionEnd

Function doSearchMetaTrader
	FindFirst $0 $1 $root\*
	loop:
	StrCmp $1 "" done
	StrLen $2 $1

	${If} $2 > 2
		StrCpy $tempText "$root\$1"
		StrCpy $8 $tempText
		Call isMetaTraderDataPath
		${If} $9 == "1"
			StrCpy $originalText $tempText
			${If} ${FileExists} $tempText\origin.txt
				# not sure why the file can't be read from $tempText\origin.txt
				# so copy it to installer folder first
				StrCpy $tempPath $EXEPATH
				${WordFind} $tempPath "\" "-2{*" $7
				StrCpy $tempPath $7
				CopyFiles $tempText\origin.txt "$tempPath\"

				ClearErrors
				FileOpen $fileHandle $tempPath\origin.txt r
				IfErrors doneReadOriginText
				FileSeek $fileHandle 2 # skip FF FE header
				push $fileHandle
				Call FileReadUnicode
				pop $8
#MessageBox MB_OK "$8"

				StrCpy $tempText <$8>$tempText
				doneReadOriginText:
				FileClose $fileHandle
				
				Delete $tempPath\origin.txt
			${EndIf}

			${NSD_LB_AddString} $metaTraderListBox $tempText
			${NSD_LB_GetSelection} $metaTraderListBox $3
			${If} $3 == ""
				${NSD_LB_SelectString} $metaTraderListBox $tempText
				${NSD_SetText} $folderEdit $originalText
				StrCpy $previousSelection $tempText
			${EndIf}
		${EndIf}
	${EndIf}

	FindNext $0 $1
	Goto loop
	done:
	FindClose $0
FunctionEnd

Function doGetFolderExperts
	StrCpy $0 "$installFolder\MQL4\Experts"
FunctionEnd

Function doGetFolderIndicators
	StrCpy $0 "$installFolder\MQL4\Indicators"
FunctionEnd

Function doGetFolderScripts
	StrCpy $0 "$installFolder\MQL4\Scripts"
FunctionEnd

