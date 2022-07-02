class Dictionary {
  __New() {
    this.db := new SQLiteDB
    this.dbFileName := A_ScriptDir . "\Dictionary.db"
    this.media1FileRealPath := A_Temp . "\tw.pron1.deleteme.mp3"
    this.media2FileRealPath := A_Temp . "\tw.pron2.deleteme.mp3"
    if (!FileExist(this.dbfileName)) {
      if (!this.db.OpenDB(this.dbfileName)) {
        return this._ShowErrorMessage()
      }
      SQL := "CREATE TABLE entries (id integer NOT NULL, created_at text NOT NULL DEFAULT (DATETIME('now', 'localtime')), updated_at text NOT NULL DEFAULT (DATETIME('now', 'localtime')), source_language text NOT NULL COLLATE NOCASE, target_language text NOT NULL COLLATE NOCASE, word text NOT NULL COLLATE NOCASE, definition text COLLATE NOCASE, media1 blob, media2 blob, PRIMARY KEY (id)); CREATE INDEX source_language_index ON entries (source_language COLLATE NOCASE ASC); CREATE INDEX target_language_index ON entries (target_language COLLATE NOCASE ASC);"
      if (!this.db.Exec(SQL)) {
        return this._ShowErrorMessage()
      }
    } else {
      if (!this.db.OpenDB(this.dbFileName)) {
        return this._ShowErrorMessage()
      }
    }
  }

  __Delete() {
    this.db.CloseDB()
  }

  SelectEntry(sl, tl, keyword) {
    ; this.db.Exec("delete from entries") ; TODO delete
    ; this.db.Exec("delete FROM entries where source_language = 'ja';") ; TODO delete
    return this._SelectOrInsertEntry(sl, tl, keyword)
  }

  UpdateEntries(id = 106232, limit = 10) {
    recordset := ""
    sql := "SELECT id, created_at, updated_at, word, definition, media1, media2 FROM entries WHERE id <= " . id . " AND (definition IS NULL OR definition = '') ORDER BY id DESC LIMIT " . limit
    if (!this.db.Query(sql, recordset)) {
      return this._ShowErrorMessage()
    }
    row := ""
    while (recordset.HasRows && recordset.Next(row)) {
      entry := this._RowToEntry(row)
      if (entry.word) {
        OutputDebug % "AHK: " . entry.word . "   / " . entry.id
        this._SelectOrInsertEntry("en", "ko", entry.word)
      } else {
        break ; is there HasNext()?
      }
    }
  }

  _SelectEntry(sl, tl, sqlKeyword, usingGoogle = false) {
    recordset := ""
    sql := "SELECT id, created_at, updated_at, word, definition, media1, media2 FROM entries WHERE source_language = '" . sl . "' AND target_language = '" . tl . "' AND word = '" . sqlKeyword . "';"
    if (!this.db.Query(sql, recordset)) {
      return this._ShowErrorMessage()
    }
    if (recordset.HasRows) {
      row := ""
      recordset.Next(row)
      return this._RowToEntry(row)
    } 
  }

  _SelectOrInsertEntry(sl, tl, keyword) {
    sqlKeyword := Format("{:L}", keyword)
    sqlKeyword := StrReplace(sqlKeyword, "'", "''")

    entry := this._SelectEntry(sl, tl, sqlKeyword)
    if (entry && entry.definition != "") {
      return entry
    } 

    if (sl == "en" && tl == "ko") {
      dataMap := NaverDic.EnglishToKorean(keyword)
    } else if (sl == "ja" && tl == "ko") {
      dataMap := DaumDic.JapaneseToKorean(keyword)
    }
    if (!dataMap) {
      MsgBox Not found Entry
      return
    }

    definition := dataMap.simpleData
    if (definition != "") {
      blobArray := this._FileToBlob(dataMap.pronFilePath)
      sqlDefinition := StrReplace(definition, "'", "''")
      if (entry) { ; Update
        FormatTime, updatedAt, %A_Now%, "yyyy/MM/dd HH:mm:ss"
        sql := "UPDATE entries SET updated_at = '" . updatedAt . "', definition = '" . sqlDefinition . "', media1  = ? WHERE source_language = '" . sl . "' AND target_language = '" . tl . "' AND word = '" . sqlKeyword . "'"
      } else { ; Insert
        sql := "INSERT INTO entries (source_language, target_language, word, definition, media1) VALUES ('" . sl . "', '" . tl . "', '" . sqlKeyword . "', '" . sqlDefinition . "', ?)"
      }
      if (!this.db.StoreBLOB(sql, blobArray)) {
        return this._ShowErrorMessage()
      }
    }
    return this._SelectEntry(sl, tl, sqlKeyword)
  }

  _RowToEntry(row) {
    entry := {}
    if (row) {
      entry.id := row[1]
      entry.created_at := row[2]
      entry.updated_at := row[3]
      entry.word := row[4]
      entry.definition := row[5]
      entry.media1 := row[6]
      entry.media2 := row[7]
      if (entry.media1) {
        entry.media1FileRealPath := this._BlobToFile(entry.media1, this.media1FileRealPath)
      }
      if (entry.media2) {
        entry.media2FileRealPath := this._BlobToFile(entry.media2, this.media2FileRealPath)
      }
    }
    return entry
  }

  _FileToBlob(fileRealPath) {
    blob := ""
    hfile := FileOpen(fileRealPath, "r")
    hfileSize := hfile.RawRead(blob, hfile.Length)
    hfile.Close()
    blobArray := []
    if (hfileSize > 0) {
      blobArray.Insert({Addr: &blob, Size: hfileSize})
    }
    return blobArray
  }

  _BlobToFile(mediaBlob, mediaFileRealPath) {
    hfileSize := mediaBlob.Size
    if (hfileSize) {
      FileDelete % mediaFileRealPath
      hfile := FileOpen(mediaFileRealPath, "w")
      addr := mediaBlob.GetAddress("Blob")
      VarSetCapacity(myBLOBVar, hfileSize)
      DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", &myBLOBVar, "Ptr", addr, "Ptr", hfileSize)
      hfile.RawWrite(&myBLOBVar, hfileSize)
      hfile.Close()
      return mediaFileRealPath
    }
  }

  _ShowErrorMessage() {
    MsgBox, 16, SQLite Open Error, % "Msg:`t" . this.db.ErrorMsg . "`nCode:`t" . this.db.ErrorCode
  }
}