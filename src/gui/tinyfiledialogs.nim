{.compile: "tinyfiledialogs.c".}
import std/options

when defined(windows):
  ## On windows, if you want to use UTF-8 ( instead of the UTF-16/wchar_t
  ## functions at the end of this file ) Make sure your code is really
  ## prepared for UTF-8 (on windows, functions like fopen() expect MBCS and
  ## not UTF-8)
  var tinyfd_winUtf8*: cint
  ##  on windows char strings can be 1:UTF-8(default) or 0:MBCS
  ##  for MBCS change this to 0, in tinyfiledialogs.c or in your code
  ##  Here are some functions to help you convert between UTF-16 UTF-8 MBSC
  proc utf8toMbcs*(aUtf8string: cstring): cstring {.
      importc: "tinyfd_utf8toMbcs".}
  proc utf16toMbcs*(aUtf16string: WideCString): cstring {.
      importc: "tinyfd_utf16toMbcs".}
  proc mbcsTo16*(aMbcsString: cstring): WideCString {.
      importc: "tinyfd_mbcsTo16".}
  proc mbcsTo8*(aMbcsString: cstring): cstring {.importc: "tinyfd_mbcsTo8".}
  proc utf8to16*(aUtf8string: cstring): WideCString {.
      importc: "tinyfd_utf8to16".}
  proc utf16to8*(aUtf16string: WideCString): cstring {.
      importc: "tinyfd_utf16to8".}
## ****************************************************************************************************
## ****************************************************************************************************
## ****************************************************************************************************
## ************ 3 funtions for C# (you don't need this in C or C++) :

proc getGlobalChar*(aCharVariableName: cstring): cstring {.
    importc: "tinyfd_getGlobalChar".}
##  returns NULL on error

proc getGlobalInt*(aIntVariableName: cstring): cint {.
    importc: "tinyfd_getGlobalInt".}
##  returns -1 on error

proc setGlobalInt*(aIntVariableName: cstring, aValue: cint): cint {.
    importc: "tinyfd_setGlobalInt".}
##  returns -1 on error
##  aCharVariableName: "tinyfd_version" "tinyfd_needs" "tinyfd_response"
##    aIntVariableName : "tinyfd_verbose" "tinyfd_silent" "tinyfd_allowCursesDialogs"
## 				      "tinyfd_forceConsole" "tinyfd_assumeGraphicDisplay" "tinyfd_winUtf8"
## ************

var tinyfd_version*: array[8, char]

##  contains tinyfd current version number

var tinyfd_needs*: ptr UncheckedArray[char]

##  info about requirements

var tinyfd_verbose*: cint

##  0 (default) or 1 : on unix, prints the command line calls

var tinyfd_silent*: cint

##  1 (default) or 0 : on unix, hide errors and warnings from called dialogs
##  Curses dialogs are difficult to use, on windows they are only ascii and uses the unix backslah

var tinyfd_allowCursesDialogs*: cint

##  0 (default) or 1

var tinyfd_forceConsole*: cint

##  0 (default) or 1
##  for unix & windows: 0 (graphic mode) or 1 (console mode).
## 0: try to use a graphic solution, if it fails then it uses console mode.
## 1: forces all dialogs into console mode even when an X server is present,
##    it can use the package dialog or dialog.exe.
##    on windows it only make sense for console applications

var tinyfd_assumeGraphicDisplay*: cint

##  0 (default) or 1
##  some systems don't set the environment variable DISPLAY even when a graphic display is present.
## set this to 1 to tell tinyfiledialogs to assume the existence of a graphic display

var tinyfd_response*: array[1024, char]

##  if you pass "tinyfd_query" as aTitle,
## the functions will not display the dialogs
## but will return 0 for console mode, 1 for graphic mode.
## tinyfd_response is then filled with the retain solution.
## possible values for tinyfd_response are (all lowercase)
## for graphic mode:
##   windows_wchar windows applescript kdialog zenity zenity3 matedialog
##   shellementary qarma yad python2-tkinter python3-tkinter python-dbus
##   perl-dbus gxmessage gmessage xmessage xdialog gdialog
## for console mode:
##   dialog whiptail basicinput no_solution

proc beep*() {.importc: "tinyfd_beep".}
proc notifyPopup*(aTitle: cstring, aMessage: cstring, aIconType: cstring): cint {.
    importc: "tinyfd_notifyPopup".}
  ##  NULL or ""
  ##  NULL or "" may contain \n \t
##  "info" "warning" "error"
##  return has only meaning for tinyfd_query

proc messageBox*(aTitle: cstring, aMessage: cstring, aDialogType: cstring;
                       aIconType: cstring, aDefaultButton: cint): cint {.
    importc: "tinyfd_messageBox".}
  ##  NULL or ""
  ##  NULL or "" may contain \n \t
  ##  "ok" "okcancel" "yesno" "yesnocancel"
  ##  "info" "warning" "error" "question"
##  0 for cancel/no , 1 for ok/yes , 2 for no in yesnocancel

proc inputBox*(aTitle: cstring, aMessage: cstring, aDefaultInput: cstring): cstring {.
    importc: "tinyfd_inputBox".}
  ##  NULL or ""
  ##  NULL or "" (\n and \t have no effect)
##  NULL passwordBox, "" inputbox
##  returns NULL on cancel

proc saveFileDialog*(aTitle: cstring, aDefaultPathAndFile: cstring;
                           aNumOfFilterPatterns: cint;
                           aFilterPatterns: cstringArray;
                           aSingleFilterDescription: cstring): cstring {.
    importc: "tinyfd_saveFileDialog".}
    ##  NULL or ""
    ##  NULL or ""
    ##  0  (1 in the following example)
    ##  NULL or char const * lFilterPatterns[1]={"*.txt"}
    ##  NULL or "text files"
    ##  returns NULL on cancel

proc saveFileDialog*(
    title: string,
    defaultPathName: string = "",
    filterPatterns: openarray[string] = [],
    filterDesc: string = ""
  ): Option[string] =

  var patterns = allocCStringArray(filterPatterns)

  let file = saveFileDialog(
    title.cstring,
    defaultPathName.cstring,
    cint(len(filterPatterns)),
    patterns,
    filterDesc.cstring
  )

  if not isNil(file):
    return some $file


proc openFileDialog*(aTitle: cstring, aDefaultPathAndFile: cstring;
                           aNumOfFilterPatterns: cint;
                           aFilterPatterns: cstringArray;
                           aSingleFilterDescription: cstring;
                           aAllowMultipleSelects: cint): cstring {.
    importc: "tinyfd_openFileDialog".}
  ##  NULL or ""
  ##  NULL or ""
  ##  0 (2 in the following example)
  ##  NULL or char const * lFilterPatterns[2]={"*.png","*.jpg"};
  ##  NULL or "image files"
##  0 or 1
##  in case of multiple files, the separator is |
##  returns NULL on cancel

proc selectFolderDialog*(aTitle: cstring, aDefaultPath: cstring): cstring {.
    importc: "tinyfd_selectFolderDialog".}
  ##  NULL or ""
##  NULL or ""
##  returns NULL on cancel

proc colorChooser*(aTitle: cstring, aDefaultHexRGB: cstring;
                         aDefaultRGB: array[3, cuchar];
                         aoResultRGB: array[3, cuchar]): cstring {.
    importc: "tinyfd_colorChooser".}
  ##  NULL or ""
  ##  NULL or "#FF0000"
  ##  unsigned char lDefaultRGB[3] = { 0 , 128 , 255 };
##  unsigned char lResultRGB[3];
##  returns the hexcolor as a string "#FF0000"
##  aoResultRGB also contains the result
##  aDefaultRGB is used only if aDefaultHexRGB is NULL
##  aDefaultRGB and aoResultRGB can be the same array
##  returns NULL on cancel
## *********** WINDOWS ONLY SECTION ***********************

when defined(windows):
  ##  windows only - utf-16 version
  proc notifyPopupW*(aTitle: WideCString, aMessage: WideCString;
                           aIconType: WideCString): cint {.
      importc: "tinyfd_notifyPopupW".}
    ##  NULL or L""
    ##  NULL or L"" may contain \n \t
  ##  L"info" L"warning" L"error"
  ##  windows only - utf-16 version
  proc messageBoxW*(aTitle: WideCString, aMessage: WideCString;
                          aDialogType: WideCString, aIconType: WideCString;
                          aDefaultButton: cint): cint {.
      importc: "tinyfd_messageBoxW".}
    ##  NULL or L""
    ##  NULL or L"" may contain \n \t
    ##  L"ok" L"okcancel" L"yesno"
    ##  L"info" L"warning" L"error" L"question"
  ##  0 for cancel/no , 1 for ok/yes
  ##  returns 0 for cancel/no , 1 for ok/yes
  ##  windows only - utf-16 version
  proc inputBoxW*(aTitle: WideCString, aMessage: WideCString;
                        aDefaultInput: WideCString): WideCString {.
      importc: "tinyfd_inputBoxW".}
    ##  NULL or L""
    ##  NULL or L"" (\n nor \t not respected)
  ##  NULL passwordBox, L"" inputbox
  ##  windows only - utf-16 version
  proc saveFileDialogW*(aTitle: WideCString;
                              aDefaultPathAndFile: WideCString;
                              aNumOfFilterPatterns: cint;
                              aFilterPatterns: ptr WideCString;
                              aSingleFilterDescription: WideCString): WideCString {.
      importc: "tinyfd_saveFileDialogW".}
    ##  NULL or L""
    ##  NULL or L""
    ##  0 (1 in the following example)
    ##  NULL or wchar_t const * lFilterPatterns[1]={L"*.txt"}
  ##  NULL or L"text files"
  ##  returns NULL on cancel
  ##  windows only - utf-16 version
  proc openFileDialogW*(aTitle: WideCString;
                              aDefaultPathAndFile: WideCString;
                              aNumOfFilterPatterns: cint;
                              aFilterPatterns: ptr WideCString;
                              aSingleFilterDescription: WideCString;
                              aAllowMultipleSelects: cint): WideCString {.
      importc: "tinyfd_openFileDialogW".}
    ##  NULL or L""
    ##  NULL or L""
    ##  0 (2 in the following example)
    ##  NULL or wchar_t const * lFilterPatterns[2]={L"*.png","*.jpg"}
    ##  NULL or L"image files"
  ##  0 or 1
  ##  in case of multiple files, the separator is |
  ##  returns NULL on cancel
  ##  windows only - utf-16 version
  proc selectFolderDialogW*(aTitle: WideCString, aDefaultPath: WideCString): WideCString {.
      importc: "tinyfd_selectFolderDialogW".}
    ##  NULL or L""
  ##  NULL or L""
  ##  returns NULL on cancel
  ##  windows only - utf-16 version
  proc colorChooserW*(aTitle: WideCString, aDefaultHexRGB: WideCString;
                            aDefaultRGB: array[3, cuchar];
                            aoResultRGB: array[3, cuchar]): WideCString {.
      importc: "tinyfd_colorChooserW".}
    ##  NULL or L""
    ##  NULL or L"#FF0000"
    ##  unsigned char lDefaultRGB[3] = { 0 , 128 , 255 };
  ##  unsigned char lResultRGB[3];
  ##  returns the hexcolor as a string L"#FF0000"
  ##  aoResultRGB also contains the result
  ##  aDefaultRGB is used only if aDefaultHexRGB is NULL
  ##  aDefaultRGB and aoResultRGB can be the same array
  ##  returns NULL on cancel
##
##  ________________________________________________________________________________
## |  ____________________________________________________________________________  |
## | |                                                                            | |
## | | on windows:                                                                | |
## | |  - for UTF-16, use the wchar_t functions at the bottom of the header file  | |
## | |  - _wfopen() requires wchar_t                                              | |
## | |                                                                            | |
## | |  - in tinyfiledialogs, char is UTF-8 by default (since v3.6)               | |
## | |  - but fopen() expects MBCS (not UTF-8)                                    | |
## | |  - if you want char to be MBCS: set tinyfd_winUtf8 to 0                    | |
## | |                                                                            | |
## | |  - alternatively, tinyfiledialogs provides                                 | |
## | |                        functions to convert between UTF-8, UTF-16 and MBCS | |
## | |____________________________________________________________________________| |
##
## |________________________________________________________________________________|
##
## - This is not for ios nor android (it works in termux though).
## - The files can be renamed with extension ".cpp" as the code is 100% compatible C C++
##   (just comment out << extern "C" >> in the header file)
## - Windows is fully supported from XP to 10 (maybe even older versions)
## - C# & LUA via dll, see files in the folder EXTRAS
## - OSX supported from 10.4 to latest (maybe even older versions)
## - Do not use " and ' as the dialogs will be displayed with a warning
##   instead of the title, message, etc...
## - There's one file filter only, it may contain several patterns.
## - If no filter description is provided,
##   the list of patterns will become the description.
## - On windows link against Comdlg32.lib and Ole32.lib
##   (on windows the no linking claim is a lie)
## - On unix: it tries command line calls, so no such need (NO LINKING).
## - On unix you need one of the following:
##   applescript, kdialog, zenity, matedialog, shellementary, qarma, yad,
##   python (2 or 3)/tkinter/python-dbus (optional), Xdialog
##   or curses dialogs (opens terminal if running without console).
## - One of those is already included on most (if not all) desktops.
## - In the absence of those it will use gdialog, gxmessage or whiptail
##   with a textinputbox. If nothing is found, it switches to basic console input,
##   it opens a console if needed (requires xterm + bash).
## - for curses dialogs you must set tinyfd_allowCursesDialogs=1
## - You can query the type of dialog that will be used (pass "tinyfd_query" as aTitle)
## - String memory is preallocated statically for all the returned values.
## - File and path names are tested before return, they should be valid.
## - tinyfd_forceConsole=1, at run time, forces dialogs into console mode.
## - On windows, console mode only make sense for console applications.
## - On windows, console mode is not implemented for wchar_T UTF-16.
## - Mutiple selects are not possible in console mode.
## - The package dialog must be installed to run in curses dialogs in console mode.
##   It is already installed on most unix systems.
## - On osx, the package dialog can be installed via
##   http://macappstore.org/dialog or http://macports.org
## - On windows, for curses dialogs console mode,
##   dialog.exe should be copied somewhere on your executable path.
##   It can be found at the bottom of the following page:
##   http://andrear.altervista.org/home/cdialog.php
##
