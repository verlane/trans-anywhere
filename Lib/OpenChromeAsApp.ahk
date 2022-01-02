Class OpenChromeAsApp {
  __New(winTitleRegex, sendCommand, sendURL, profile="") {
    this.winTitleRegex := winTitleRegex
    this.sendCommand := sendCommand
    this.sendURL := sendURL
    this.profile := profile
  }

  RunApp(keyword="") {
    winTitleRegex := this.winTitleRegex
    sendCommand := this.sendCommand

    SetTitleMatchMode RegEx
    IfWinExist %winTitleRegex%
    {
      WinActivate %winTitleRegex%
      WinWaitActive %winTitleRegex%, , 3
      tmp := Clipboard
      Clipboard := keyword
      Send %sendCommand%
      Sleep 1000
      Clipboard := tmp
    } else {
      chromePath := this.GetProcessPath("chrome.exe")
      if (chromePath == "") {
        chromePath := "chrome.exe"
      }
      url := StrReplace(this.sendURL, "[KEYWORD]", this.URLEncode(keyword))
      if (this.profile != "") {
        profile := this.profile
        Run %chromePath% --app=%url% --profile-directory="%profile%" --app-shell-host-windows-bounds, , UseErrorLevel
      } else {
        Run %chromePath% --app=%url% --app-shell-host-windows-bounds, , UseErrorLevel
      }
      If ErrorLevel
        Run %url%
    }
  }

  CloseAppWindow() {
    winTitleRegex := this.winTitleRegex
    SetTitleMatchMode RegEx
    WinClose %winTitleRegex%
  }

  GetProcessPath(exe) {
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where name ='" exe "'") {
      Return process.ExecutablePath
    }
  }

  ; http://v1.autohotkey.co.kr/cgi/board.php?bo_table=script&wr_id=1048&sfl=&stx=&sst=wr_hit&sod=desc&sop=and&page=20
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
          result .= this.IsNonEncodedCharacter(char, except) ? char : this.ToPercentHexFormat(char, encoding)
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
      byteCnts := this.StrPutVar(str, encoded, encoding) - 1
      result := ""
      i := 0
      While (i < byteCnts) {
          byte := NumGet(encoded, i, "UChar")
          hex := this.StrUpper(SubStr(byte, 3)) ; "0x" 제거
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
}
