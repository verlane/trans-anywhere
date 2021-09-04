#NoEnv
#Warn All
#Warn LocalSameAsGlobal, Off
#SingleInstance force
#MaxThreadsBuffer On
#UseHook On

SetBatchLines, -1

Menu, Tray, Icon, %A_ScriptDir%\TrayIcon.ico

global SettingsFile := A_ScriptDir . "\Settings.ini" ;path of the settings file
if (!FileExist(SettingsFile)) {
  global SettingsFile := A_ScriptDir . "\Settings-" . A_ComputerName . ".ini" ;path of the settings file
}

global WINDOW_TITLE := "TransAnywhere v20210829"

global cDictionary := new Dictionary

global SourceLanguage := "Auto"
global TargetLanguage := "Auto"
global PlayEnglishWordPronunciation := True
global UseDaumEnglishDictionary := True

global PapagoClientId := ""
global PapagoClientSecret := ""
global FirstLanguage := "Korean"
global FirstDicWindowTitle := "^Papago$"
global FirstDicWindowMacro := "{Esc}iii{Sleep 10}^a^v{Enter}"
global FirstDicWindowURL := "https://papago.naver.com/?st=[KEYWORD]"
global SecondLanguage := "English"
global SecondDicWindowTitle := "다음 영어사전"
global SecondDicWindowMacro := "{Esc}iii{Sleep 10}^a^v{Enter}"
global SecondDicWindowURL := "https://small.dic.daum.net/search.do?dic=eng&q=[KEYWORD]"
global ThirdLanguage := "Japanese"
global ThirdDicWindowTitle := "다음 일본어사전"
global ThirdDicWindowMacro := "{Esc}iii{Sleep 10}^a^v{Enter}"
global ThirdDicWindowURL := "https://small.dic.daum.net/search.do?dic=jp&q=[KEYWORD]"

global MainWindowTransparent := 200
global RunAsHiddenWindow := False
global AutoHide := False
global AutoHideCount := 0

IniRead, SourceLanguage, %SettingsFile%, Settings, SourceLanguage, %SourceLanguage%
IniRead, TargetLanguage, %SettingsFile%, Settings, TargetLanguage, %TargetLanguage%
IniRead, PlayEnglishWordPronunciation, %SettingsFile%, Settings, PlayEnglishWordPronunciation, %PlayEnglishWordPronunciation%
IniRead, UseDaumEnglishDictionary, %SettingsFile%, Settings, UseDaumEnglishDictionary, %UseDaumEnglishDictionary%

global PreSourceLanguage := SourceLanguage
global PreTargetLanguage := TargetLanguage

IniRead, PapagoClientId, %SettingsFile%, Settings, PapagoClientId, %PapagoClientId%
PapagoClientId := PapagoClientId == "ERROR" ? "" : PapagoClientId
IniRead, PapagoClientSecret, %SettingsFile%, Settings, PapagoClientSecret, %PapagoClientSecret%
PapagoClientSecret := PapagoClientSecret == "ERROR" ? "" :PapagoClientSecret
IniRead, FirstLanguage, %SettingsFile%, Settings, FirstLanguage, %FirstLanguage%
IniRead, FirstDicWindowTitle, %SettingsFile%, Settings, FirstDicWindowTitle, %FirstDicWindowTitle%
IniRead, FirstDicWindowMacro, %SettingsFile%, Settings, FirstDicWindowMacro, %FirstDicWindowMacro%
IniRead, FirstDicWindowURL, %SettingsFile%, Settings, FirstDicWindowURL, %FirstDicWindowURL%
IniRead, SecondLanguage, %SettingsFile%, Settings, SecondLanguage, %SecondLanguage%
IniRead, SecondDicWindowTitle, %SettingsFile%, Settings, SecondDicWindowTitle, %SecondDicWindowTitle%
IniRead, SecondDicWindowMacro, %SettingsFile%, Settings, SecondDicWindowMacro, %SecondDicWindowMacro%
IniRead, SecondDicWindowURL, %SettingsFile%, Settings, SecondDicWindowURL, %SecondDicWindowURL%
IniRead, ThirdLanguage, %SettingsFile%, Settings, ThirdLanguage, %ThirdLanguage%
IniRead, ThirdDicWindowTitle, %SettingsFile%, Settings, ThirdDicWindowTitle, %ThirdDicWindowTitle%
IniRead, ThirdDicWindowMacro, %SettingsFile%, Settings, ThirdDicWindowMacro, %ThirdDicWindowMacro%
IniRead, ThirdDicWindowURL, %SettingsFile%, Settings, ThirdDicWindowURL, %ThirdDicWindowURL%

IniRead, MainWindowTransparent, %SettingsFile%, Settings, MainWindowTransparent, %MainWindowTransparent%
IniRead, RunAsHiddenWindow, %SettingsFile%, Settings, RunAsHiddenWindow, %RunAsHiddenWindow%
IniRead, AutoHide, %SettingsFile%, Settings, AutoHide, %AutoHide%

global PAPAGO_APP := new OpenChromeAsApp(FirstDicWindowTitle, FirstDicWindowMacro, FirstDicWindowURL)
global ENGLISH_DIC_APP := new OpenChromeAsApp(SecondDicWindowTitle, SecondDicWindowMacro, SecondDicWindowURL)
global JAPANESE_DIC_APP := new OpenChromeAsApp(ThirdDicWindowTitle, ThirdDicWindowMacro, ThirdDicWindowURL)
global GOOGLE_LANGUAGES := {"Afrikaans":"af","Albanian":"sq","Amharic":"am","Arabic":"ar","Armenian":"hy","Azerbaijani":"az","Basque":"eu","Belarusian":"be","Bengali":"bn","Bosnian":"bs","Bulgarian":"bg","Catalan":"ca","Cebuano":"ceb","Chichewa":"ny","Chinese(Simplified)":"zh-CN","Chinese(Traditional)":"zh-TW","Corsican":"co","Croatian":"hr","Czech":"cs","Danish":"da","Dutch":"nl","English":"en","Esperanto":"eo","Estonian":"et","Filipino":"tl","Finnish":"fi","French":"fr","Frisian":"fy","Galician":"gl","Georgian":"ka","German":"de","Greek":"el","Gujarati":"gu","HaitianCreole":"ht","Hausa":"ha","Hawaiian":"haw","Hebrew":"iw","Hindi":"hi","Hmong":"hmn","Hungarian":"hu","Icelandic":"is","Igbo":"ig","Indonesian":"id","Irish":"ga","Italian":"it","Japanese":"ja","Javanese":"jw","Kannada":"kn","Kazakh":"kk","Khmer":"km","Korean":"ko","Kurdish(Kurmanji)":"ku","Kyrgyz":"ky","Lao":"lo","Latin":"la","Latvian":"lv","Lithuanian":"lt","Luxembourgish":"lb","Macedonian":"mk","Malagasy":"mg","Malay":"ms","Malayalam":"ml","Maltese":"mt","Maori":"mi","Marathi":"mr","Mongolian":"mn","Myanmar(Burmese)":"my","Nepali":"ne","Norwegian":"no","Pashto":"ps","Persian":"fa","Polish":"pl","Portuguese":"pt","Punjabi":"pa","Romanian":"ro","Russian":"ru","Samoan":"sm","ScotsGaelic":"gd","Serbian":"sr","Sesotho":"st","Shona":"sn","Sindhi":"sd","Sinhala":"si","Slovak":"sk","Slovenian":"sl","Somali":"so","Spanish":"es","Sundanese":"su","Swahili":"sw","Swedish":"sv","Tajik":"tg","Tamil":"ta","Telugu":"te","Thai":"th","Turkish":"tr","Ukrainian":"uk","Urdu":"ur","Uzbek":"uz","Vietnamese":"vi","Welsh":"cy","Xhosa":"xh","Yiddish":"yi","Yoruba":"yo","Zulu":"zu"}
global GOOGLE_LANGUAGES_R := ReverseMap(GOOGLE_LANGUAGES)
global CONFIG := {"tmpX":0, "tmpY":0, "gTickCount":0}

; 단어검색 폼GUI를 정의 {
; Gui FindWordForm:+Owner
Tooltips := {}
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x2a3, "WM_MOUSELEAVE")
Gui FindWordForm:+hWndhMainWnd +Owner -MaximizeBox -MinimizeBox
Gui FindWordForm:Color, White
Gui FindWordForm:Font, s10, Meiryo UI
  srcComboxText := GetComboboxText(GOOGLE_LANGUAGES, SourceLanguage, "Auto||")
  Gui FindWordForm:Add, DDL, vSrcLangComb x4 y4 w120, %srcComboxText%
  Gui FindWordForm:Add, Edit, vSrcEditText x4 y32 w412 h90 +Multi -WantReturn
  targetComboxText := GetComboboxText(GOOGLE_LANGUAGES, TargetLanguage, "Auto||")
  Gui FindWordForm:Add, DDL, vTargetLangComb x4 y132 w120, %targetComboxText%
  ; Gui FindWordForm:Add, Edit, vTargetEditText x4 y160 w412 h310 +ReadOnly +Multi
  targetRE := new RichEdit("FindWordForm", "x4 y160 w412 h310")
  targetRE.SetBkgndColor(0xFFFFFF)
  ; targetRE.SetOptions(["READONLY"], "Set") ; to avoid a bug not scrolling
  targetRE.WordWrap(True)
  targetRE.SetDefaultFont({"Name": "Meiryo UI", "Color": 0x000000, "Size": 10})
  palette := {"rose": 0xEE3158, "red": 0xFF6188, "orange": 0xFC9867, "yellow": 0xFFD866, "green": 0xA9DC76, "blue": 0x78DCE8, "purple": 0xAB9DF2}
Gui FindWordForm:Font

Gui FindWordForm:Font, s14 Meiryo UI
  Gui FindWordForm:Add, Button, hwndhTranslateBtn gTranslateBtn x236 y0 w30 h30 Default, 🌏
  Tooltips[hTranslateBtn] := "Translate (Enter)"
  Gui FindWordForm:Add, Button, hwndhSwitchBtn gSwitchBtn x266 y0 w30 h30, 🔁
  Tooltips[hSwitchBtn] := "Switch (Alt+Q)"
  Gui FindWordForm:Add, Button, hwndhGoogleBtn gGoogleBtn x296 y0 w30 h30, 🔍
  Tooltips[hGoogleBtn] := "Google (Alt+G)"
  Gui FindWordForm:Add, Button, hwndhOpenWebSrcBtn gOpenWebSrcBtn x326 y0 w30 h30, 📖
  Tooltips[hOpenWebSrcBtn] := "Open (Shift+Enter)"
  Gui FindWordForm:Add, Button, hwndhListenSrcBtn gListenSrcBtn x356 y0 w30 h30, 🔉
  Tooltips[hListenSrcBtn] := "Listen (Alt+E)"
  Gui FindWordForm:Add, Button, hwndhCopySrcBtn gCopySrcBtn x386 y0 w30 h30, 📋
  Tooltips[hCopySrcBtn] := "Copy (Alt+Y)"

  Gui FindWordForm:Add, Button, hwndhSettingBtn gSettingBtn x296 y128 w30 h30, ⚙️
  Tooltips[hSettingBtn] := "Alt+W to display this form, Ctrl+Enter to start new line.`nAlt+W long press to copy selected text and translate.`nTab or Number key to enter the phrase for AutoComplete."
  Gui FindWordForm:Add, Button, hwndhOpenWebTargetBtn gOpenWebTargetBtn x326 y128 w30 h30, 📖
  Tooltips[hOpenWebTargetBtn] := "Open (Alt+A)"
  Gui FindWordForm:Add, Button, hwndhListenTargetBtn gListenTargetBtn x356 y128 w30 h30, 🔉
  Tooltips[hListenTargetBtn] := "Listen (Alt+S)"
  Gui FindWordForm:Add, Button, hwndhCopyTargetBtn gCopyTargetBtn x386 y128 w30 h30, 📋
  Tooltips[hCopyTargetBtn] := "Copy (Alt+D)"
Gui FindWordForm:Font

; 창위치 복원
IniRead, positionX, %SettingsFile%, Position, X
IniRead, positionY, %SettingsFile%, Position, Y
CONFIG.tmpX := positionX
CONFIG.tmpY := positionY
if (!RunAsHiddenWindow) {
  ShowFindWordFormGui(positionX, positionY)
}

; }

#Include %A_ScriptDir%\Lib\AutoComplete.ahk

FindWordFormGuiEscape:
FindWordFormGuiClose:
  ToolTip
  Gui FindWordForm:Hide
  SavePosition()
Return

SettingBtn:
  GoSub ShowSettings
Return

CopyTargetBtn:
  Clipboard := targetRE.GetTextRN()
  MsgBox,,, Copied to clipboard, 0.5
Return

ListenTargetBtn:
  ListenSentence(targetRE.GetTextRN())
Return

OpenWebTargetBtn:
  OpenWeb(targetRE.GetTextRN(), TargetLangComb)
Return

CopySrcBtn:
  Gui FindWordForm:Submit, NoHide
  GuiControlGet, SrcEditText
  Clipboard := SrcEditText
  MsgBox,,, Copied to clipboard, 0.5
Return

ListenSrcBtn:
  Gui FindWordForm:Submit, NoHide
  GuiControlGet, SrcEditText
  ListenSentence(SrcEditText)
Return

OpenWebSrcBtn:
  Gui FindWordForm:Submit, NoHide
  GuiControlGet, SrcEditText
  OpenWeb(SrcEditText, SrcLangComb)
Return

SwitchBtn:
  Gui FindWordForm:Submit, NoHide
  GuiControlGet, SrcEditText
  targetREText := targetRE.GetTextRN()
  GuiControl, FindWordForm:Text, SrcEditText, %targetREText%
  targetRE.setText(SrcEditText)

  GuiControlGet, SrcLangComb
  GuiControlGet, TargetLangComb
  GuiControl, FindWordForm:Choose, TargetLangComb, %SrcLangComb%
  GuiControl, FindWordForm:Choose, SrcLangComb, %TargetLangComb%

  GuiControl, FindWordForm:Focus, SrcEditText
  Send ^{End}
Return

TranslateBtn:
  pressShift := GetKeyState("Shift", "P") ; the value is 1 at pressed
  pressLCtrl := GetKeyState("LCtrl", "P") ; the value is 1 at pressed
  Gui FindWordForm:Submit, NoHide
  GuiControl, FindWordForm:Focus, SrcEditText
  keyword := Trim(SrcEditText)

  if (PreSourceLanguage != SrcLangComb || PreTargetLanguage != TargetLangComb) {
    IniWrite, %SrcLangComb%, %SettingsFile%, Settings, SourceLanguage
    IniWrite, %TargetLangComb%, %SettingsFile%, Settings, TargetLanguage
  }
  PreSourceLanguage := SrcLangComb
  PreTargetLanguage := TargetLangComb

  if (keyword == "") {
    ; MsgBox 키워드를 입력하세요.
    Return
  }

  if (pressShift == 1 && pressLCtrl != 1) {
    OpenWeb(keyword, SrcLangComb)
    Gui, Suggestions:Hide
    Return
  }

  isEnglish := IsEnglish(keyword)
  isKorean := IsKorean(keyword)
  isJapanese := IsJapanese(keyword)
  isSentence := IsSentence(keyword)

  ; 히스토리 등록
  isMatched := RegExMatch(keyword, "Oi)^\+ ?(.+)$", SubPat)
  word := SubPat.value(1)
  if (isMatched && isEnglish) {
		FileAppendToHead(word, WordListHistoryFile)
    MsgBox Registered.
    Return
  }

  ; 히스토리 제거
  isMatched := RegExMatch(keyword, "Oi)^\- ?(.+)$", SubPat)
  word := SubPat.value(1)
  if (isMatched && isEnglish) {
    FileRead, theText, %WordListHistoryFile%
    theText := StrReplace(theText, word "`r`n", "")
    FileDelete, %WordListHistoryFile%
    FileAppend, %theText%, %WordListHistoryFile%
    MsgBox Removed.
    Return
  }

  ; 히스토리에 단어 등록
  if (isEnglish && !isSentence && StrLen(keyword) > 3) {
    FileRead, WordListExcluded, %WordListExcludedFile%
    FileRead, WordListHistoryReloaded, %WordListHistoryFile%
    if (RegExMatch(WordList, "i)(^|[`r`n])" keyword "([`r`n]|$)")) {
			FileAppendToHead(keyword, WordListHistoryFile)
    } else if (!RegExMatch(WordList, "i)" keyword) && !RegExMatch(WordListExcluded, "i)" keyword)) {
      ; pending 20200305222011
      ; MsgBox 0x1, , There is no word in the dictionary. Do you want to register it?, 10
      ; IfMsgBox, OK
        ; FileAppend, %keyword%`r`n, %WordListHistoryFile%
      ; else
        ; FileAppend, %keyword%`r`n, %WordListExcludedFile%
    }
  }

  GuiControlGet, SrcLangComb
  GuiControlGet, TargetLangComb

  sl := GOOGLE_LANGUAGES[SrcLangComb]
  if (sl == "Auto" || sl == "") {
    if (GOOGLE_LANGUAGES[SecondLanguage] == "en" && IsEnglish(keyword)) { ; Avoiding being recognized in other languages
      sl := "en"
    } else {
      rJson := JSON.Load(GetGoogleTranslation(keyword)) ; check src language
      sl := rJson.src
    }
  }

  tl := GOOGLE_LANGUAGES[TargetLangComb]
  if (pressShift == 1 && pressLCtrl == 1) { ; shift && lctrl
    if (sl == GOOGLE_LANGUAGES[ThirdLanguage]) {
      tl := GOOGLE_LANGUAGES[SecondLanguage]
    } else {
      tl := GOOGLE_LANGUAGES[ThirdLanguage]
    }
  } else if (tl == "Auto" || tl == "") {
    tl := GOOGLE_LANGUAGES[FirstLanguage]
    if (sl == GOOGLE_LANGUAGES[FirstLanguage]) {
      tl := GOOGLE_LANGUAGES[SecondLanguage]
    }
  }

  text := ""
  playWord := false

  if (isSentence) {
    if (sl == "en" && tl == "ko") {
      replacedKeyword := StrReplace(keyword, " `n", "`n")
      wordArray := StrSplit(replacedKeyword, "`n")
      if (wordArray.MaxIndex() > 1 && StrSplit(wordArray[1], " ").MaxIndex() < 2 && StrSplit(wordArray[2], " ").MaxIndex() < 2) {
        for index, word in wordArray ; Enumeration is the recommended approach in most cases.
        {
          text := text word "`t" GetDaumTranslation(word) "`n"
        }
      }
    }
  } else {
    if (sl == "en" && tl == "ko" || sl == "ja" && tl == "ko") {
      entry := cDictionary.SelectEntry(sl, tl, keyword)
      text .= entry.definition
      SoundPlay % entry.media1FileRealPath ; TODO
    } else if (sl == "ko" && tl == "en") {
      if (UseDaumEnglishDictionary) {
        text := GetDaumTranslation(keyword)
      }
      if (text) {
        text := text "`n`n"
      }
      text := text GetNaverTranslation(keyword)
    }
    
    if (sl == "en" && PlayEnglishWordPronunciation) {
      playWord := true
    }
  }

  if (StrLen(text) == 0 && PapagoClientId && PapagoClientSecret && (sl == "en" && tl == "ko" || sl == "ko" && tl == "en")) {
    text := Papago.GetTranslation(SrcEditText, sl, tl, PapagoClientId, PapagoClientSecret)
  }
  if (StrLen(text) == 0) {
    text := GetTargetText(GetGoogleTranslation(keyword, sl, tl))
  }

	; text := RegExReplace(text, "\r\n", "\r")

  lowerCaseKeyword := Format("{:L}", keyword)
  IsInHeader := RegExMatch(text, "^" . lowerCaseKeyword)
  IsInfooter := RegExMatch(text, lowerCaseKeyword . "$")
  targetRE.SetText("")
  textsWithStyle := []
  if (IsInHeader) {
    textsWithStyle.Push([lowerCaseKeyword, palette.rose, True])
    text := RegExReplace(text, "^" . lowerCaseKeyword, "")
  }
  textArr := StrSplit(text, lowerCaseKeyword)
  for i, v in textArr
  {
      textsWithStyle.Push(v)
      if (i != textArr.MaxIndex()) {
        textsWithStyle.Push([lowerCaseKeyword, palette.rose, True])
      }
  }
  if (IsInfooter) {
    textsWithStyle.Push([lowerCaseKeyword, palette.rose, True])
  }
  AppendRE(targetRE, textsWithStyle)

  ; GuiControl, FindWordForm:Text, TargetEditText, %text%

  if (playWord) {
    ListenSentence(keyword)
  }

  Gui, Suggestions:Hide
Return

GoogleBtn:
  Gui FindWordForm:Submit, NoHide
  GuiControlGet, SrcEditText
  Run % "https://www.google.com/search?q=" . StrReplace(SrcEditText, "`n", " ")
Return

AutoHideTimer:
	WinGetTitle thisWindowTitle, A
	if (RegExMatch(thisWindowTitle, WINDOW_TITLE) || RegExMatch(thisWindowTitle, FirstDicWindowTitle) || RegExMatch(thisWindowTitle, SecondDicWindowTitle) || RegexMatch(thisWindowTitle, ThirdDicWindowTitle)) {
    AutoHideCount := 0
	} else {
    AutoHideCount := AutoHideCount + 1
    if (AutoHideCount > 10) {
			ENGLISH_DIC_APP.CloseAppWindow()
			JAPANESE_DIC_APP.CloseAppWindow()
			PAPAGO_APP.CloseAppWindow()
      HideGui()
      SetTimer, AutoHideTimer, Off
    }
  }
Return

SavePosition() {
  WinGetPos, x, y, width, height
  if (CONFIG.tmpX != x && CONFIG.tmpY != y) {
    CONFIG.tmpX := x
    CONFIG.tmpY := y
    IniWrite, %x%, %SettingsFile%, Position, X
    IniWrite, %y%, %SettingsFile%, Position, Y
  }
}

GetTargetText(responseText) {
  rJson := JSON.Load(responseText)
  text := ""
  if (rJson.dict) {
    for key1, dict in rJson.dict
    {
      if (key1 > 1) {
        text := text . "`n`n"
      }
      text := text . "[" . dict.pos "]  "
      for key2, term in dict.terms
      {
        if (key2 > 1) {
          text := text . ", "
        }
        text := text . term
      }
    }
  } else {
    for key0, sentence in rJson.sentences
    {
      text := text . sentence.trans
    }
  }

  Return text
}

ShowFindWordFormGui(x=0, y=0) {
  width := 420
  height := 474
  if (x==0 || y==0 || x < 0 || y < 0 || x > (A_ScreenWidth - width) || y > (A_ScreenHeight - height)) {
    x := 0
    y := 0
  }
  Gui FindWordForm:Show, x%x% y%y% w%width% h%height%, %WINDOW_TITLE%
  GuiControl, FindWordForm:Focus, SrcEditText

  MainWindowTransparent := MainWindowTransparent > 255 ? 255 : MainWindowTransparent
  MainWindowTransparent := MainWindowTransparent < 50 ? 50 : MainWindowTransparent

  WinSet Transparent, %MainWindowTransparent%, %WINDOW_TITLE%

	if (AutoHide) {
		waitingTime := 1 * 1000 ; seconds
		SetTimer, AutoHideTimer, %waitingTime%
	}
}

HideGui() {
  ; for non-display items
  Gui, Suggestions:Default
  Gui, Suggestions:Hide
  Gui, Hide
  Gui, FindWordForm:Hide
  ToolTip
}

OpenWeb(keyword, language="Auto") {
  keyword := Trim(keyword)
  if (StrLen(keyword) < 1) {
    Return
  }

  sl := ""
  if (language == "Auto" || language == "") {
    rJson := JSON.Load(GetGoogleTranslation(keyword))
    sl := rJson.src
  } else {
    sl := GOOGLE_LANGUAGES[language]
  }

  ; TODO to change variable names
  isKorean := sl == GOOGLE_LANGUAGES[FirstLanguage]
  isEnglish := sl == GOOGLE_LANGUAGES[SecondLanguage]
  isJapanese := sl == GOOGLE_LANGUAGES[ThirdLanguage]
  isSentence := IsSentence(keyword)
  if (isSentence) {
    OpenPapago(keyword)
  } else if(isEnglish || isKorean) {
    OpenEngDic(keyword)
  } else if(isJapanese) {
    OpenJpnDic(keyword)
  } else {
    OpenPapago(keyword)
  }
}

OpenEngDic(keyword) {
  ENGLISH_DIC_APP.runApp(keyword)
}

OpenJpnDic(keyword) {
  JAPANESE_DIC_APP.runApp(keyword)
}

OpenPapago(keyword) {
  PAPAGO_APP.runApp(keyword)
}

ListenSentence(keyword) {
  keyword := Trim(keyword)
  isEnglish := IsEnglish(keyword)
  isSentence := IsSentence(keyword)
  tmpSoundFile := ""
  if (isEnglish && !isSentence) {
    ; tmpSoundFile := GetNaverPron(keyword)
    ; SoundPlay %tmpSoundFile%, wait
  }
  if (tmpSoundFile == "") {
    ; Papago.Listen(keyword)
  }
}

AppendRE(RE, textsWithStyle) {
	static WM_VSCROLL := 0x115, SB_BOTTOM := 7, CP_UTF8 := 65001
	GuiControl, -Redraw, % RE.hWnd

	; Generate an RTF document based on the given input
	font := RE.GetFont(1)
	colors := {rgb := font.Color: max_color := 1}
 	colortbl := "\red" rgb>>16&0xFF "\green" rgb>>8&0xFF "\blue" rgb&0xFF ";"
  text := ""
	for i, v in textsWithStyle
	{
		color := 1
    effects := "\b0\i0"
		if (IsObject(v)) {
      rgb := v[2], effect := v[3], v := v[1]
			if (colors[rgb]) {
				color := colors[rgb]
      } else {
				; Add a new color table entry
				color := colors[rgb] := ++max_color
				colortbl .= "\red" rgb>>16&0xFF "\green" rgb>>8&0xFF "\blue" rgb&0xFF ";"
			}
      if (effect) {
        effects := "\b\i"
      }
		}
		text .= effects "\cf" color " " RegExReplace(v, "(\r\n|[\\{}\r\n])", "\$0")
	}
	fonttbl := "{\fonttbl{\f0\fmodern\fcharset0 " font.Name ";}}"
	rtf := "{\rtf{\colortbl;" colortbl "}" fonttbl "\fs" Round(font.Size)*2 " " text "\`n}"

	; Move cursor to end of document and paste
	sel := RE.GetSel()
	len := RE.GetTextLen()
	RE.SetSel(len, len)

	; Replace selection with rtf
  VarSetCapacity(bRTF, StrPut(rtf, "CP" CP_UTF8))
  StrPut(rtf, &bRTF, "CP" CP_UTF8)
  VarSetCapacity(SETTEXTEX, 8, 0)
  NumPut(2      , SETTEXTEX, 0, "UInt") ; DWORD flags
  NumPut(CP_UTF8, SETTEXTEX, 4, "UInt") ; UINT  codepage
  SendMessage, 0x461, &SETTEXTEX, &bRTF,, % "ahk_id " . RE.hWnd

	; Restore selection or scroll appropriately
	; if (Sel.S == Len) {
		; GuiControl, +Redraw, % RE.hWnd
		; SendMessage, WM_VSCROLL, SB_BOTTOM, 0,, % "ahk_id" RE.hWnd
	; } else {
		RE.SetSel(Sel.S, Sel.E)
		GuiControl, +Redraw, % RE.hWnd
	; }
}

!s::
  KeyWait s, T0.3
  if (ErrorLevel) { ; by long press
    Clipboard := ""
    Send, ^x
    ClipWait, 3
    if (!ErrorLevel) {
      text := ""
      keyword := Clipboard
      replacedKeyword := StrReplace(Clipboard, " `n", "`n")
      replacedKeyword := StrReplace(replacedKeyword, "`r", "")
      wordArray := StrSplit(replacedKeyword, "`n")
      for index, word in wordArray ; Enumeration is the recommended approach in most cases.
      {
        if (word != "" && word != "`n") {
					text := text word "`t" GetDaumTranslation(word)
					if (wordArray.MaxIndex() != index) {
						text := text . "`n"
					}
        }
      }
      Clipboard := text
      Send ^v
    }
  } else {
    Send !s
  }
  KeyWait %A_ThisHotkey%
Return
!w::
  KeyWait w, T0.3
  if (ErrorLevel) { ; by long press
    Clipboard := ""
    Send, ^c
    ClipWait, 3
    if !ErrorLevel
    {
      ShowFindWordFormGui(CONFIG.tmpX, CONFIG.tmpY)
      GuiControl, FindWordForm:Text, SrcEditText, %Clipboard%
      Gosub TranslateBtn ; test
    }
  } else {
    ShowFindWordFormGui(CONFIG.tmpX, CONFIG.tmpY)
    Send, ^a
    Gosub, ResetWord
    ; It will not be ImeOff if you executed one within 30 seconds
    if (CONFIG.tickCount < (A_TickCount - 1000 * 30)) {
      Loop 5 {
        IME_Off()
        Sleep 100
      }
    }
    CONFIG.tickCount := A_TickCount
  }
  KeyWait %A_ThisHotkey%
Return
; !f::Reload

#If WinActive(WINDOW_TITLE)
!w::
  ShowFindWordFormGui(CONFIG.tmpX, CONFIG.tmpY)
  Send, ^a
Return
!q::
  Gosub, SwitchBtn
Return
!g::
  Gosub, GoogleBtn
Return
!e::
  Gosub, ListenSrcBtn
Return
!y::
  Gosub, CopySrcBtn
Return
!a::
  Gosub, OpenWebTargetBtn
Return
!s::
  Gosub, ListenTargetBtn
Return
!d::
  Gosub, CopyTargetBtn
Return
~LButton Up::
  SavePosition()
Return
!f::
  Reload
Return

#Include %A_ScriptDir%\Lib\BUtil.ahk
#Include %A_ScriptDir%\Lib\JSON.ahk
#Include %A_ScriptDir%\Lib\OpenChromeAsApp.ahk
#Include %A_ScriptDir%\Lib\Papago.ahk
#Include %A_ScriptDir%\Lib\IME.ahk
#Include %A_ScriptDir%\Lib\Class_RichEdit.ahk
#Include %A_ScriptDir%\Lib\Class_SQLiteDB.ahk
#Include %A_ScriptDir%\Lib\Class_NaverDic.ahk
#Include %A_ScriptDir%\Lib\Class_DaumDic.ahk
#Include %A_ScriptDir%\Lib\Class_Dictionary.ahk