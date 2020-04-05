﻿GetResponseText(url) {
  req := ComObjCreate("Msxml2.XMLHTTP")
  req.open("GET", url, false)
  ; req.setRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3887.7 Safari/537.36")
  req.send()
  return req.ResponseText
}

GetDocument(url) {
  return GetDocumentByHTML(GetResponseText(url))
}

GetDocumentByHTML(html) {
  html := "<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">" . html
  document := ComObjCreate("HTMLFile")
  document.write(html)
  return document
}

ReverseMap(map) {
  newMap := {}
  For k, v in map
  {
    newMap[v] := k
  }
}

GetComboboxText(map, default="default", prefix="", postfix="") {
  s := ""
  For k, v in map
  {
    s := s . k . "|"
    if (k == default) {
      s := s . "|"
    }
  }
  return prefix . SubStr(s, 1, StrLen(s) - 1) . postfix
}

; Easy way to add tooltips to GUI Controls
; https://www.reddit.com/r/AutoHotkey/comments/bbzr8n/example_easy_way_to_add_tooltips_to_gui_controls/
; Tooltips := {}
; OnMessage(0x200, "WM_MOUSEMOVE")
; OnMessage(0x2a3, "WM_MOUSELEAVE")
; Gui FindWordForm:Add, Button, hwndhTranslateBtn gTranslateBtn x148 y48 w40 h40 Default, 🌏
; Tooltips[hTranslateBtn] := "This is for Button"
WM_MOUSEMOVE() {
	Global ToolTips
	MouseGetPos,,,,hwnd, 2		;Get the hwnd of the control under the mouse
	ToolTip, % ToolTips[hwnd]
}
WM_MOUSELEAVE() {
	ToolTip
}

B64Encode(string) {
  size := ""
  VarSetCapacity(bin, StrPut(string, "UTF-8")) && len := StrPut(string, &bin, "UTF-8") - 1
  if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size))
      throw Exception("CryptBinaryToString failed", -1)
  VarSetCapacity(buf, size << 1, 0)
  if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size))
      throw Exception("CryptBinaryToString failed", -1)
  return RegExReplace(StrGet(&buf), "[`r`n]", "")
}

B64Decode(string) {
  size := ""
  if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0))
    throw Exception("CryptStringToBinary failed", -1)
  VarSetCapacity(buf, size, 0)
  if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
    throw Exception("CryptStringToBinary failed", -1)
  return StrGet(&buf, size, "UTF-8")
}

GetNaverPron(keyword) {
  keywordEncoded := URLEncode(keyword)
  req := ComObjCreate("Msxml2.XMLHTTP")
  req.open("GET", "https://endic.naver.com/searchAssistDict.nhn?query=" . keywordEncoded, false)
  req.send()
  html := "<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">" req.ResponseText
  document := ComObjCreate("HTMLFile")
  document.write(html)

  playlist := document.getElementById("pron_en").getAttribute("playlist")
  if (playlist) {
    pronFilePath := A_Temp . "\endic.deleteme.mp3"
    URLDownloadToFile %playlist%, %pronFilePath%
  } else {
    pronFilePath := ""
  }

  return pronFilePath
}

GetNaverTranslation(keyword) {
  keywordEncoded := URLEncode(keyword)
  req := ComObjCreate("Msxml2.XMLHTTP")
  req.open("GET", "https://endic.naver.com/searchAssistDict.nhn?query=" . keywordEncoded, false)
  req.send()
  html := "<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">" req.ResponseText
  document := ComObjCreate("HTMLFile")
  document.write(html)

  text := ""
  text := text . GetNaverTranslationText(document, "box_a")
  text := text . GetNaverTranslationText(document, "box_b")
  text := text . GetNaverTranslationText(document, "box_c")
  text := text . GetNaverTranslationText(document, "box_d")
  text := text . GetNaverTranslationText(document, "box_e")
  text := RegExReplace(text, "( ?성우 발음듣기| ?TTS 발음듣기|[0-9 ]+개 뜻 더보기[`n]?)", "")

  return text
}

GetNaverTranslationText(document, boxClassName) {
  text := ""
  box_a := document.getElementsByClassName(boxClassName)
  Loop % box_a.length
  {
    h3Text := document.getElementsByTagName("h3")[A_index-1].innerText
    if ((A_index-1) > 0) {
      text := text . "`n" . h3Text
    } else {
      text := text . h3Text
    }

    h4Text := box_a[A_Index-1].getElementsByTagName("h4")[0].innerText
    text := text . h4Text . "`n"
    dl := box_a[A_Index-1].getElementsByTagName("dl")
    Loop % dl.length
    {
      children := dl[A_Index-1].children
      Loop % children.length
      {
        space := children[A_Index-1].tagName == "DT" ? " " : "   "
        text := text . space . children[A_Index-1].innerText . "`n"
      }
    }
  }
  return StrLen(text) > 0 ? text "`n" : text
}

GetGoogleTranslation(keyword, sl="auto", tl="ko") {
  keywordEncoded := URLEncode(keyword)
  req := ComObjCreate("Msxml2.XMLHTTP")
  req.open("GET", "https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=" . sl . "&tl=" . tl . "&q=" . keywordEncoded, false)
  req.send()
  return req.ResponseText
}

GetDaumTranslation(keyword) {
  ; for google https://clients5.google.com/translate_a/t?client=dict-chrome-ex&q=did%20you%20push%20your%20changes%20to%20the%20hotfix%2F33488%20branch%3F&sl=auto&tl=ko
  oHTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  url := "https://suggest-bar.daum.net/suggest?mod=json&code=utf_in_out&enc=utf&id=language&cate=eng&q=" keyword "&callback=window.suggestInstance.dataModel.forceLoadComplete"
  oHTTP.Open("Get", url , False)
  oHTTP.SetRequestHeader("Content-Type", "application/json")
  oHTTP.Send()
  oHTTP.WaitForResponse()
  response := oHTTP.ResponseText
  oHTTP := ""
  RegExMatch(response, "Oi)""items"" : \[ "".+\|" keyword "\|(.+?)""", SubPat)

  Return SubPat.value(1)
}

GetResponse(url) {
  oHTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  oHTTP.Open("Get", url , False)
  ; oHTTP.SetRequestHeader("Content-Type", "application/json")
  oHTTP.Send()
  oHTTP.WaitForResponse()
  response := oHTTP.ResponseText
  oHTTP := ""

  Return response
}

; 문자열을 특정 인코딩을 사용해서 URL Encoding 한다.
; @param str 문자열
; @param encoding 인코딩. 기본값 UTF-8
; @param except 제외할 문자들. 기본값 "!#$&'()*+,-./:;=?@_~"
; @return 인코딩된 값
URLEncode(str, encoding="UTF-8", except="!#$&'()*+,-./:;=?@_~") {
    len := StrLen(str)
    result := ""
    i := 1
    oldFmt := A_FormatInteger
    SetFormat, Integer, hex
    While (i <= len) {
        char := SubStr(str, i, 1) ; 한문자씩 파싱
        result .= IsNonEncodedCharacter(char, except) ? char : ToPercentHexFormat(char, encoding)
        i++
    }
    SetFormat, Integer, %oldFmt%
    return result
}

; 문자가 인코딩에서 제외할 문자인지를 체크한다.
; @param char 문자
; @param except 제외할 문자들
; @return 제외 여부
IsNonEncodedCharacter(char, except) {
    ascii := Asc(char)
    return ascii >= 0x41 && ascii <= 0x5A ; A-Z
            || ascii >= 0x61 && ascii <= 0x7A ; a-z
            || ascii >= 0x30 && ascii <= 0x39 ; 0-9
            || InStr(except, char, true)
}

; 문자열을 퍼센트 HEX 포맷으로 변환한다.
; @param str 문자열
; @param encoding 인코딩
; @return 변환된 문자열
ToPercentHexFormat(str, encoding) {
    byteCnts := StrPutVar(str, encoded, encoding) - 1
    result := ""
    i := 0
    While (i < byteCnts) {
        byte := NumGet(encoded, i, "UChar")
        hex := StrUpper(SubStr(byte, 3)) ; "0x" 제거
        If (StrLen(hex) == 1)
            hex := "0" . hex
        result .= "%" . hex
        i++
    }
    return result
}

; 문자열을 대문자로 변환한다.
; @param str 문자열
; @return 대문자로 변환된 문자열
StrUpper(str) {
    StringUpper, out, str
    return out
}

; UTF-16 문자열을 특정 인코딩의 문자열로 변환한다.
; @param str 대상 문자열
; @param var 변환된 문자열
; @param encoding 인코딩
; @return 변환된 문자열의 바이트수
StrPutVar(str, ByRef var, encoding) {
    VarSetCapacity(var, StrPut(str, encoding) * ((encoding == "utf-16" || encoding == "cp1200") ? 2 : 1))
    return StrPut(str, &var, encoding)
}

IsKorean(text) {
  return RegExMatch(text, "[가-힣ㄱ-ㅣ]+")
}

IsJapanese(text) {
  return RegExMatch(text, "[亜-熙ぁ-んァ-ヶ]+")
}

IsEnglish(text) {
  return RegExMatch(text, "^[ a-zA-Z1-9.'"";:`-]+$")
}

IsSentence(text) {
  return StrSplit(text, " ").MaxIndex() > 1 || StrSplit(text, "`n").MaxIndex() > 1 || (IsJapanese(text) && StrLen(text) > 10)
}

ArrayUniq(arr) {
  hash := {}, newArr := []
  for e, v in arr
  {
    if (!hash[v]) {
      hash[(v)] := 1, newArr.push(v)
    }
  }
  return newArr
}

ArrayCompact(arr) {
  hash := {}, newArr := []
  for e, v in arr
  {
    if (StrLen(v) > 0 && !hash[v]) {
      hash[(v)] := 1, newArr.push(v)
    }
  }
  return newArr
}

ArrayJoins(arr, str) {
  newStr := ""
  for e, v in arr
  {
    if (e >= arr.MaxIndex()) {
      newStr .= v
    } else {
      newStr .= v . str
    }
  }
  return newStr
}
