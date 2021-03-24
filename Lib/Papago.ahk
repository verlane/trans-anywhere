; #NoEnv
; #Warn All
; #SingleInstance force
; #Include %A_ScriptDir%\BUtil.ahk
; SetBatchLines, 1
; Papago.GetTranslation("I love you")

class Papago {
  Listen(text) {
    text := Trim(text)
    if (StrLen(text) < 1) {
      return
    }
    text := RegExReplace(text, "[`r`n]", "")
    speaker := this.GetExactSpeaker(text)
    this.ListenByParam(text, speaker)
  }

  ListenByParam(text, speaker="clara", speed="0") {
    text := RegExReplace(text, "[""]", "")
    downloadUrl := "https://dict.naver.com/api/nvoice?service=dictionary&speech_fmt=mp3&text=" . this.URLEncode(text) . "&speaker=" . speaker . "&speed=" . speed
    tmpSoundFile := A_Temp . "\papago.deleteme.mp3"
    URLDownloadToFile %downloadUrl%, %tmpSoundFile%
    SoundPlay %tmpSoundFile%, wait
  }

  GetTranslation(keyword, sl, tl, clientId, clientSecret) {
    keywordEncoded := URLEncode(keyword)
    data := "&source=" sl "&target=" tl "&text=" keywordEncoded
    req := ComObjCreate("Msxml2.XMLHTTP")
    req.Open("POST", "https://openapi.naver.com/v1/papago/n2mt", false)
    req.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    req.SetRequestHeader("X-Naver-Client-ID", clientId)
    req.SetRequestHeader("X-Naver-Client-Secret", clientSecret)
    req.Send(data)

    RegExMatch(req.ResponseText, "O)""translatedText"":""(.+)"",""engineType", SubPat)
    translatedText := SubPat.value(1)
    translatedText := RegExReplace(translatedText, "\\n", "`r`n")
    translatedText := RegExReplace(translatedText, "\\", "")
    Return translatedText
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

  ; @speaker = kyuri, jinho, matt, clara, jose, carmen, louis, roxane, shinji, yuri, liangliang, meimei
  GetExactSpeaker(text) {
    if (this.IsKorean(text)) {
      return "kyuri"
    } else if (this.IsJapanese(text)) {
      return "yuri"
    }
    return "clara"
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
}
