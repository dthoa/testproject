class VoiceRepository {
    constructor(dao) {
        this.dao = dao
    }

    createTable() {
        const sql = `
        CREATE TABLE IF NOT EXISTS voices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          text TEXT,
          audio TEXT)`
        return this.dao.run(sql)
    }

    create(name, text, audio) {
        return this.dao.run(
            `INSERT INTO voices (name, text, audio) VALUES (?, ?, ?)`,
            [name, text, audio]
        )
    }

    update(voice) {
        const { id, name, text, audio } = voice
        return this.dao.run(
            `UPDATE voices
          SET id = ?,
          name = ?,
          text = ?,
          audio = ?
          WHERE id = ?`,
            [name, text, audio, id]
        )
    }

    delete(id) {
        return this.dao.run(
            `DELETE FROM voices WHERE id = ?`,
            [id]
        )
    }

    getAll() {
        return this.dao.all(`SELECT * FROM voices`)
    }

    getById(id) {
        return this.dao.get(
            `SELECT * FROM voices WHERE id = ?`,
            [id])
    }

    getByNameAndText(name, text) {
        return this.dao.get(
            `SELECT * FROM voices WHERE name = ? AND text = ?`,
            [name, text])
    }

}

module.exports = VoiceRepository  