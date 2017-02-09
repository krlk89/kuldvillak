#!/usr/bin/env python3

import bottle
import sqlite3
import uuid

def open_connection():
    """Open database connection."""
    db_file = "kuldvillak.db"
    db = sqlite3.connect(db_file)
    
    return db, db.cursor()

def close_connection(db, connection, commit):
    """Close database connection."""
    if commit:
        db.commit()
    connection.close()
    db.close()

@bottle.route("/", method = ["GET", "POST"])
def first_page():
    """Create player and game board."""
    player_id = bottle.request.get_cookie("player")
    
    if bottle.request.forms.mangija1:
        db, connection = open_connection()
        
        tabel = []        
        player_id = str(uuid.uuid4())

        connection.execute("""INSERT INTO Mangijad(MangijaId, Nimi)
                    VALUES(?, ?)""", (player_id, bottle.request.forms.mangija1,))
        bottle.response.set_cookie("player", player_id, path="/")
        
        valitud_teemad = connection.execute("""SELECT Pealkiri FROM Teemad
                                    ORDER BY RANDOM() LIMIT 5""").fetchall()
        tabel.append(valitud_teemad)
        
        seis = [teema[0] for teema in valitud_teemad]
        
        for hind in range(10, 60, 10):
            rida = []
            for teema in valitud_teemad:
                hind_kysimus = connection.execute("""SELECT Hind, KysimuseId from Kysimused
                                        JOIN Teemad ON Kysimused.TeemaId = Teemad.TeemaId
                                        WHERE Pealkiri = ? AND Hind = ?
                                        ORDER BY RANDOM() LIMIT 1""", (teema[0], hind)).fetchall()[0]
                                            
                seis.append(str(hind_kysimus[1]))
                rida.append(hind_kysimus)
            tabel.append(rida)
            
        seis = ";".join(seis)
        connection.execute("""UPDATE Mangijad SET Seis = ?
                    WHERE MangijaId = ?""", (seis, player_id))
        
        close_connection(db, connection, True)

        return bottle.template("views/kuldvillak", rows = tabel, skoor = 0, hind = 0)
    
    elif player_id:
        db, connection = open_connection()
        player_info = connection.execute("""SELECT Nimi, Lopp FROM Mangijad
                                WHERE MangijaId = ?""", (player_id,)).fetchall()[0]
        close_connection(db, connection, False)
        
        if player_info[1] == 0:
            # return the first page with continue game button
            return bottle.template("views/greet", player_name = player_info[0], cont = True)
        else:
            return bottle.template("views/greet", cont = False)

    return bottle.template("views/greet", cont = False)

@bottle.route("/kuldvillak", method = ["GET", "POST"])
def game_board():
    """Kuldvillaku pealeht"""
    player_id = bottle.request.get_cookie("player")
    if player_id:
        db, connection = open_connection()
        
        tabel = []
        
        skoor, seis = connection.execute("""SELECT Skoor, Seis from Mangijad
                            WHERE MangijaId = ?""", (player_id,)).fetchall()[0]
        seis = seis.split(";")
        
        temp_tabel, redirect = [], True
        for nr, question_id in enumerate(seis, start = 1):
            if question_id == "": # answered question
                temp_tabel.append("")
            elif nr < 6: # category title
                temp_tabel.append((question_id,))
            else:
                kys = connection.execute("""SELECT Hind, KysimuseId FROM Kysimused
                                    JOIN Teemad ON Kysimused.TeemaId = Teemad.TeemaId
                                    WHERE KysimuseId = ?""", (int(question_id),)).fetchall()[0]
                temp_tabel.append(kys)
                redirect = False
            if nr % 5 == 0: # end of category
                tabel.append(temp_tabel)
                temp_tabel = []
                
        if redirect: # all questions answered
            connection.execute("""UPDATE Mangijad SET Lopp = 1
                        WHERE MangijaId = ?""", (player_id, ))
            db.commit()
            bottle.redirect("/results")
        
        if bottle.request.forms.hind:
            hind = int(bottle.request.forms.hind)
            if bottle.request.forms.sub:
                skoor -= hind
            elif bottle.request.forms.add:
                skoor += hind
            connection.execute("""UPDATE Mangijad SET Skoor = ?
                        WHERE MangijaId = ?""", (skoor, player_id))
            db.commit()
        
        close_connection(db, connection, False)
    else:
        bottle.redirect("/")
        
    return bottle.template("views/kuldvillak", rows = tabel, skoor = skoor)
    
@bottle.route("/q", method = "POST")
def question_page():
    """Küsimuse leht"""
    db, connection = open_connection()
    
    player_id = bottle.request.get_cookie("player")
    question_id = bottle.request.forms.kys_id
    kysimus, hind, vastus = connection.execute("""SELECT Kys, Hind, Vastus FROM Kysimused
                        WHERE KysimuseId = ?""", (int(question_id),)).fetchall()[0]
        
    seis = connection.execute("""SELECT Seis FROM Mangijad
                        WHERE MangijaId = ?""", (player_id,)).fetchall()[0][0]
    seis = seis.split(";")
    q_id = seis.index(question_id)
    seis[q_id] = ""
    seis = ";".join(seis)
    connection.execute("""UPDATE Mangijad SET Seis = ?
                WHERE MangijaId = ?""", (seis, player_id))
    
    close_connection(db, connection, True)
    
    return bottle.template("views/question", kysimus = kysimus, vastus = vastus, hind = hind)

@bottle.route("/results")
def results():
    """Show results and leaderboard."""
    db, connection = open_connection()
    
    leaderboard = connection.execute("""SELECT Nimi, Skoor FROM Mangijad
                                WHERE Lopp = 1 ORDER BY Skoor DESC LIMIT 10""").fetchall()
                                
    close_connection(db, connection, False)
    
    return bottle.template("views/results", top = leaderboard)

@bottle.route("/static/<filename>")
def server_static(filename):
    """CSS and images."""
    return bottle.static_file(filename, root = "static")

@bottle.error(404)
def page_not_found(code):
    """ """
    return "Page not found! Sorry."

bottle.debug(True)
bottle.run(host = "localhost", reloader = True)
