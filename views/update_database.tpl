<!DOCTYPE html>
<html>
    <head>
        <title>Kuldvillak</title>
        <link rel="stylesheet" type="text/css" href="/static/stylesheet.css">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="keywords" content="kuldvillak, mälumäng, jeopardy, quiz">
    </head>

    <body>
        <div id="addQuestion">
            <input type="text" id="questionInput" placeholder="Küsimus"></input>

            <input type="text" id="answerInput" placeholder="Vastus"></input>

            <select id="topic">
                <option hidden disabled selected></option>
                %for topic in topics:
                    <option value="{{topic[0]}}">{{topic[0]}}</option>
                %end
            </select>

            <select id="price">
                <option>10</option>
                <option>20</option>
                <option>30</option>
                <option>40</option>
                <option>50</option>
            </select>
        </div>

        <button class="button">Lisa</button>

        <p></p>

        <script>
            "use strict";

            const submitBtn = document.querySelector("button");

            submitBtn.addEventListener("click", async function() {
                this.disabled = true;
                const question = document.querySelector("#questionInput").value;
                const answer = document.querySelector("#answerInput").value;
                const topic = document.querySelector("#topic").value;
                const price = document.querySelector("#price").value;
                const statusField = document.querySelector("p");
                const request = {"question": question, "answer": answer, "topic": topic, "price": price};
                statusField.textContent = "";

                if (!question || !answer || !topic || !price) {
                    statusField.textContent = "Täida kõik väljad!";
                    this.disabled = false;
                    return;
                }

                try {
                    const response = await fetch("/kuldvillak/questions", {
                        method: "POST",
                        headers: {"Content-Type": "application/json"},
                        body: JSON.stringify(request)
                    });
                    const data = await response.text();
                }
                catch(err) {
                    console.error(err);
                    statusField.textContent = "Tekkis viga. Proovi uuesti.";
                    this.disabled = false;
                    return;
                }

                statusField.textContent = "Küsimus lisatud!";
                this.disabled = false;
            });
        </script>
    </body>
</html>