class Dictionary {
  __New() {
    this.db := new SQLiteDB
    this.dbFileName := A_ScriptDir . "\Dictionary.db"
    this.pronFileRealPath := A_Temp . "\transanywhere.pron.deleteme.mp3"
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

  SelectEntity(sl, tl, keyword) {
    return this._SelectOrInsertEntity(sl, tl, keyword)
  }

  _SelectEntity(sl, tl, sqlKeyword) {
    table := ""
    sql := "SELECT id, created_at, updated_at, definition, media1, media2 FROM entries WHERE source_language = '" . sl . "' AND target_language = '" . tl . "' AND word = '" . sqlKeyword . "';"
    if (!this.db.GetTable(sql, table)) {
      return this._ShowErrorMessage()
    }
    if (table.HasRows) {
      row := ""
      table.Next(row)
      return this._RowToEntity(row)
    } 
  }

  _SelectOrInsertEntity(sl, tl, keyword) {
    sqlKeyword := Format("{:L}", keyword)
    sqlKeyword := StrReplace(sqlKeyword, "'", "''")

    entity := this._SelectEntity(sl, tl, sqlKeyword)
    if (entity) {
      return entity
    } 

    if (sl == "en" && tl == "ko") {
      dataMap := NaverDic.EnglishToKorean(keyword)
    }
    if (!dataMap) {
      MsgBox Not found Entity
      return
    }
    definition := dataMap.simpleData
    blobArray := this._FileToBlob(dataMap.pronFilePath)
    sql := "INSERT INTO entries (source_language, target_language, word, definition, media1) VALUES ('" . sl . "', '" . tl . "', '" . sqlKeyword . "', '" . definition . "', ?)"
    if (!this.db.StoreBLOB(sql, blobArray)) {
      return this._ShowErrorMessage()
    }
    return this._SelectEntity(sl, tl, sqlKeyword)
  }

  _RowToEntity(row) {
    entity := {}
    if (row) {
      entity.id := row[1]
      entity.created_at := row[2]
      entity.updated_at := row[3]
      entity.definition := row[4]
      entity.media1 := row[5]
      entity.media2 := row[6]
      if (entity.media1) {
        entity.media1FileRealPath := this._BlobToFile(entity.media1)
      }
      if (entity.media2) {
        entity.media2FileRealPath := this._BlobToFile(entity.media2)
      }
    }
    return entity
  }

  _FileToBlob(fileRealPath) {
    hfile := FileOpen(fileRealPath, "r")
    hfileSize := hfile.RawRead(blob, hfile.Length)
    hfile.Close()
    blobArray := []
    blobArray.Insert({Addr: &blob, Size: hfileSize})
    return blobArray
  }

  _BlobToFile(mediaBlob) {
    hfile := FileOpen(this.pronFileRealPath, "w")
    hfileSize := mediaBlob.Size
    if (hfileSize > 0) {
      addr := mediaBlob.GetAddress("Blob")
      VarSetCapacity(myBLOBVar, hfileSize)
      DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", &myBLOBVar, "Ptr", addr, "Ptr", hfileSize)
      hfile.RawWrite(&myBLOBVar, hfileSize)
    }
    return this.pronFileRealPath
  }

  _ShowErrorMessage() {
    MsgBox, 16, SQLite Open Error, % "Msg:`t" . this.db.ErrorMsg . "`nCode:`t" . this.db.ErrorCode
  }
}