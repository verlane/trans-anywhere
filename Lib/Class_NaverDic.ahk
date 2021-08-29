class NaverDic {
  EnglishToKorean(word) {
    simpleData := ""

    ; C:"미국∙영국"
    PRON_TYPE_MAP := {C: "", A: "미", E: "영", N: "명", V: "동", AJ: "형"}
    searchPage := "https://en.dict.naver.com/api3/enko/search?range=word&query=" . word
    res := GetResponseText(searchPage)
    rJson := JSON.Load(res)
    entryId := rJson.searchResultMap.searchResultListMap.WORD.items[1].entryId
    wordDetailPage := "https://en.dict.naver.com/api/platform/enko/entry?entryId=" . entryId
    rawData := GetResponseText(wordDetailPage)
    rJson := JSON.Load(rawData)

    primary_mean := rJson.entry.primary_mean ; 현재의, 현 …|||있는, 참석한|||선물
    simpleData .= this.AppendString(StrReplace(primary_mean, "|||", ", "), "")

    simpleData .= this.AppendString(rJson.entry.group.entryCommon.entry_name, "`n`n") ; pres·ent

    d := ""
    Loop {
      pron_type := rJson.entry.group.prons[A_Index].pron_type ; V
      pron_symbol := rJson.entry.group.prons[A_Index].pron_symbol ; prɪˈzent
      if (!pron_type) {
        break
      }
      if (pron_symbol) {
        d .= " " . PRON_TYPE_MAP[pron_type] . "[" . pron_symbol . "]"
      }
    }
    simpleData .= this.AppendString(SubStr(d, 2), " ")

    d := ""
    Loop {
      tense_type := rJson.entry.conjs[A_Index].tense_type ; 11 = 과거
      conj_content := rJson.entry.conjs[A_Index].conj_content ; presented
      if (!tense_type) {
        break
      }
      if (tense_type == 11 || tense_type == 12 || tense_type == 13) { ; 과거, 과거분사, 현재분사
        d .= " - " . conj_content
      }
    }
    simpleData .= this.AppendString(SubStr(d, 4))

    d := ""
    i := 1
    no := 1
    Loop, % rJson.entry.means.length() {
      ; d .= this.AppendString(rJson.entry.means[i].part.part_ko_name, "`n`n") ; 형용사
      ; d .= this.AppendString(rJson.entry.means[i].specific_part_of_speech) ; 타동사
      ; d .= this.AppendString(rJson.entry.means[i].specific_part_description) ; 명사 앞에만 씀
      if (rJson.entry.means[i].origin_mean) {
        if (no == 1) {
          d .= this.AppendString(no . ". " . rJson.entry.means[i].origin_mean) ; 현재의, 현 …
        } else {
          d .= this.AppendString(no . ". " . rJson.entry.means[i].origin_mean, "`n`n") ; 현재의, 현 …
        }
        d .= this.AppendString(rJson.entry.means[i].examples[1].origin_example, "`n " . " ") ; in the present situation
        d .= this.AppendString(rJson.entry.means[i].examples[1].translations[1].origin_translation, "`n " . " ") ; 현 상황에서
        no += 1
      }

      i += 1
    }
    simpleData .= this.AppendString(d)

    pronFilePath := ""
    pronFileUrl := rJson.entry.group.prons[1].female_pron_file
    if (pronFileUrl) {
      pronFilePath := A_Temp . "\tw.naver.endic.deleteme.mp3"
      URLDownloadToFile %pronFileUrl%, %pronFilePath%
      Sleep 100
      FileGetSize, fileSize, %pronFilePath%, K
      if (fileSize < 1) {
        pronFilePath := GetNaverPron(word)
      }
    }

    return {simpleData: simpleData, rawData: rawData, pronFilePath: pronFilePath}
  }

  AppendString(string, prefixCr = "`n") {
    string := RegExReplace(Trim(string), "</?[a-zA-Z]+>" , "")
    if (string) {
      return prefixCr . string
    }
    return ""
  }
}