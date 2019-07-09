#!/usr/bin/env python3

"""
Kuldvillaku veebimäng
Autor: https://github.com/krlk89/kuldvillak
"""

import bottle
import sqlite3
import random


def open_connection():
    """Open database connection"""
    db_file = "kuldvillak.db"
    db = sqlite3.connect(db_file)

    return db, db.cursor()


def close_connection(db, connection):
    """Close database connection"""
    connection.close()
    db.close()


def get_random_topics(topics, chosen_topics):
    """Replace not chosen topics with random topics"""
    for i, topic in enumerate(chosen_topics):
        if not topic:
            selectedtopic = random.choice(topics)[0]
            while selectedtopic in chosen_topics:
                selectedtopic = random.choice(topics)[0]

            chosen_topics[i] = selectedtopic

    return chosen_topics

@bottle.route("/")
def first_page():
    """Create player and game board"""
    db, connection = open_connection()

    topics = connection.execute("""SELECT Pealkiri FROM Teemad ORDER BY Pealkiri ASC""").fetchall()

    if bottle.request.GET.get("player0"):
        new_game = {}
        playercount = bottle.request.GET.get("playerCount", type = int)
        scores = [{bottle.request.query.getunicode("player{}".format(i)): 0} for i in range(playercount)]

        if bottle.request.GET.get("topicsType") == "random":
            chosen_topics = random.sample(topics, 5)
            chosen_topics = [topic[0] for topic in chosen_topics]
        else:
            chosen_topics = [(bottle.request.query.getunicode("select{}".format(i)),)[0] for i in range(5)]
            chosen_topics = get_random_topics(topics, chosen_topics)

        new_game["0"] = chosen_topics

        for price in range(10, 60, 10):
            row = []
            for topic in chosen_topics:
                topic = connection.execute("""SELECT KysimuseId from Kysimused
                                        JOIN Teemad ON Kysimused.TeemaId = Teemad.TeemaId
                                        WHERE Pealkiri = ? AND Hind = ?
                                        ORDER BY RANDOM() LIMIT 1""", (topic, price)).fetchall()[0]

                row.append(topic[0])
            new_game[str(price)] = row

        new_game["players"] = scores
        new_game["type"] = "auto"

        close_connection(db, connection)

        return bottle.template("kuldvillak", new_gametable = new_game, newgame = "y")

    close_connection(db, connection)

    return bottle.template("greet", topics = topics)


@bottle.route("/kuldvillak/")
@bottle.route("/kuldvillak")
def game_board():
    """Game page"""

    return bottle.template("kuldvillak", new_gametable = [], newgame = "n")


@bottle.route("/kuldvillak/questions/<id:int>")
def get_question(id):
    """Get question from the database by id"""

    db, connection = open_connection()

    question, answer = connection.execute("""SELECT Kys, Vastus from Kysimused
                            WHERE KysimuseId = ?""", (id,)).fetchall()[0]

    close_connection(db, connection)

    return {"question": question, "answer": answer}


@bottle.route("/kuldvillak/questions", method = "POST")
def post_question():
    """Add question to the database"""
    db, connection = open_connection()

    data = bottle.request.json
    connection.execute("""INSERT INTO Kysimused (Kys, Hind, Vastus, TeemaId)
        VALUES(?, ?, ?, (SELECT TeemaId FROM Teemad WHERE Pealkiri is ?))""",
        (data["question"].upper(), data["price"], data["answer"].upper(), data["topic"]))
    db.commit()

    close_connection(db, connection)

    return data


@bottle.route("/kuldvillak/create")
def create_game():
    """Create game"""
    if bottle.request.query.pealkiri:
        new_game = {}
        headlines = [headline.encode("iso-8859-1").decode("utf-8").upper() for headline in bottle.request.query.getall("pealkiri")]
        new_game["0"] = headlines
        playercount = bottle.request.GET.get("playerCount", type = int)
        scores = [{bottle.request.query.getunicode("player{}".format(i)): 0} for i in range(playercount)]

        nr = 10
        for i in range(1, 6):
            rida =  bottle.request.query.getall("row" + str(i))
            for j in range(10):
                new_game[str(nr)] = [{rida[i].encode("iso-8859-1").decode("utf-8").upper():  rida[i + 1].encode("iso-8859-1").decode("utf-8").upper()} for i in range(0, 10, 2)]
            nr += 10

        new_game["players"] = scores
        new_game["type"] = "manual"

        return bottle.template("kuldvillak", new_gametable = new_game, newgame = "y")

    return bottle.template("create_game")


@bottle.route("/kuldvillak/db")
def update_database():
    """Create question"""
    db, connection = open_connection()

    topics = connection.execute("""SELECT Pealkiri FROM Teemad ORDER BY Pealkiri ASC""").fetchall()

    close_connection(db, connection)

    return bottle.template("update_database", topics = topics)


@bottle.route("/static/<filename>")
def server_static(filename):
    """CSS"""
    return bottle.static_file(filename, root = "static")


@bottle.error(404)
def page_not_found(code):
    """Page not found template"""

    return "Lehekülge ei leitud."

bottle.run(host = "localhost")
