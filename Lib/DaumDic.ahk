; #NoEnv
; #Warn All
; #Warn LocalSameAsGlobal, Off
; #SingleInstance force
; #MaxThreadsBuffer On
; SetBatchLines, 1
; #Include %A_ScriptDir%\BUtil.ahk

; ; TODO remove JPN rubyies
; MsgBox % GetDaumJpnDic("申し込み")
; MsgBox % GetDaumEngDic("love")

GetDaumEngDic(keyword) {
  dicURL := "https://dic.daum.net/search.do?dic=eng&q=" URLEncode(keyword)
  html := GetResponseText(dicURL)
  RegExMatch(html, "Oi)data-wordid=""(.+?)"" data-", subPat)
  wordId := subPat.value(1)
  if (!wordId) {
    RegExMatch(html, "Oi)view.do\?wordid=(.+?)&", subPat)
    wordId := subPat.value(1)
  }
  Return GetDaumDic(keyword, wordId, "KUMSUNG_EK")
}

GetDaumJpnDic(keyword) {
  dicURL := "https://dic.daum.net/search.do?dic=jp&q=" URLEncode(keyword)
  RegExMatch(GetResponseText(dicURL), "Oi)/word/view.do\?wordid=(.+?)&supid=", subPat)
  wordId := subPat.value(1)
  if (!wordId) {
    RegExMatch(wordId, "Oi)view.do\?wordid=(.+?)&", subPat)
    wordId := subPat.value(1)
  }
  Return GetDaumDic(keyword, wordId, "KUMSUNG_JK")
}

GetDaumDic(keyword, wordId, subType) {
  wordURL := "https://dic.daum.net/word/view.do?wordid=" wordId
  ; OutputDebug % "AHK: " wordURL ""

  SetBatchLines, 1
  wordHtml := GetResponseText(wordURL)
  word := GetDocumentByHTML(wordHtml)

  RegExMatch(wordHtml, "Oi)supid : '(.+)',", subPat)
  supId := subPat.value(1)
  supURL := "https://dic.daum.net/word/view_supword.do?wordid=" wordId "&supid=" supId "&suptype=" subType
  ; OutputDebug % "AHK: " supURL ""
  supHtml := GetResponseText(supURL)
  sup := GetDocumentByHTML(supHtml)
  SetBatchLines, -1

  text := ""
  txtPronounce := RegExReplace(word.querySelector(".txt_pronounce").innerText, "`t", " ")
  txtPronounce := RegExReplace(txtPronounce, " ,", ",")
  text := text . word.querySelector(".txt_cleanword").innerText " " txtPronounce "`n"
  text := text . RegExReplace(word.querySelector(".list_mean").innerText, "[`r`n]", " ") "`n`n"

  group_sorts := word.querySelectorAll(".group_sort")
  Loop % group_sorts.length
  {
    group_sort := group_sorts[A_Index-1]
    text := text group_sort.querySelector(".tit_sort").innerText
    list_sort := group_sort.querySelector(".list_sort").innerText
    list_sort := RegExReplace(list_sort, "[`r`n]", "")
    list_sort := RegExReplace(list_sort, "[0-9가-힣ㄱ-ㅣ]+", " ")
    text := text list_sort "`n"
  }

  rubies := sup.querySelectorAll(".fold_ex daum\:ruby")
  Loop % rubies.length
  {
    rubies[A_Index-1].innerText := "(" rubies[A_Index-1].innerText ")"
  }

  fold_exes := sup.querySelectorAll(".fold_ex")
  Loop % fold_exes.length
  {
    text := text "`n■ "
    fold_ex := fold_exes[A_Index-1]
    Loop % fold_ex.children.length
    {
      childText := ""
      child := fold_ex.children[A_Index-1]
      if (child.tagName == "UL") {
        childText := "  " RemoveCommonChar(child.querySelectorAll("li p")[0].innerText) "`n"
        childText := childText "  " RemoveCommonChar(child.querySelectorAll("li p")[1].innerText)
      } else {
        childText := RemoveCommonChar(child.innerText)
        childText := RegExReplace(childText, "[`r`n]", "")
      }
      if (StrLen(childText) > 0) {
        if (RegExMatch(childText, "^[0-9]+`.")) {
          text := text "`n" childText
        } else {
          text := text childText "`n"
        }
      }
    }
    if (A_Index > 1) {
      Break
    }
  }

  return text
}

RemoveCommonChar(arg) {
  return Trim(RegExReplace(arg, "(듣기|뜻별예문열기|참고더보기|어법더보기)", ""))
}
