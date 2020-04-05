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
    param = pitch":0,"speaker":"%speaker%","speed":%speed%,"text":"%text%"}
    data := "data=rlWuoUObLFV6ZPjv" . this.B64Encode(param)
    url := "https://papago.naver.com/apis/tts/makeID"
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", url, true)
    whr.Send(data)
    whr.WaitForResponse()
    RegExMatch(whr.ResponseText, "O)"":""(.+)""}$", SubPat)
    ttsId := SubPat.value(1)
    tmpSoundFile := A_Temp . "\papago.deleteme.mp3"
    URLDownloadToFile https://papago.naver.com/apis/tts/%ttsId%, %tmpSoundFile%
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
}
