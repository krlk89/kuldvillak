<!DOCTYPE html>
<html>
    <head>
        <title>Kuldvillak</title>
        <link rel="stylesheet" type="text/css" href="/static/stylesheet.css">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>

    <body>
    <table>

    </table>

    <h1 id="question"></h1>

    <div id="answerButtons"></div>

    <a href="/">Esilehele</a>

    <script>
        "use strict";

        const gameTable = document.querySelector("table");
        const question = document.querySelector("#question");
        const answerButtonsDiv = document.querySelector("#answerButtons");
        let answerButtons;
        let gameObj;
        let scores;
        let playerCount;
        let answerCount = 0;
        let answerObj;
        let questionButton;
        let lastQuestionId;

        function buildGameTable() {
            const fragment = document.createDocumentFragment();
            let isNewGame;
			let row;
			let td;
            let button;
            let price = 0;

            if (localStorage.length === 0) {
                if ({{!new_gametable}}.length === 0) {
                    window.location.href = "/";
                    return;
                }

                localStorage.setItem("game", JSON.stringify({{!new_gametable}}));
            }
            else {
                if ("{{newgame}}" === "y") {
                    isNewGame = confirm("Alusta uut mängu?");

                    if (isNewGame) {
                        localStorage.setItem("game", JSON.stringify({{!new_gametable}}));
                    }
                }
            }
            gameObj = {"game" : JSON.parse(localStorage.getItem("game"))};
            scores = gameObj.game.players;
            playerCount = scores.length;

            // gametable
            for (let i = 0; i <= 50; i += 10) {
            	row = document.createElement("tr");

            	for (let j = 0; j < 5; j++) {
                	td = document.createElement("td");

                	if (i === 0) {
                	    button = document.createElement("button");
                	    button.textContent = gameObj.game[i][j];
                	    button.setAttribute("class", "button title");
                        button.disabled = true;

                        td.appendChild(button);
                    }
                    else if (gameObj.game[i][j] !== -1) {
                        button = document.createElement("button");
                        button.textContent = price;
                        button.setAttribute("class", "button content");

                        if (gameObj.game.type === "manual") {
                            let question = Object.keys(gameObj.game[i][j])[0];
                            let answer = gameObj.game[i][j][Object.keys(gameObj.game[i][j])[0]];
                            button.setAttribute("data-question", question);
                            button.setAttribute("data-answer", answer);

                        }
                        else {
                            button.setAttribute("data-id", gameObj.game[i][j]);
                        }

                    	td.appendChild(button);
                    }
                    row.appendChild(td);
                }
                price += 10;
                fragment.appendChild(row);
            }

            gameTable.appendChild(fragment);
        }

        function buildScores() {
            const fragment = document.createDocumentFragment();
            let paragraph;
            let answerButtonsWrapper;
            let rightAnswerButton;
            let wrongAnswerButton;

            for (let i = 0; i < playerCount; i++) {
            	answerButtonsWrapper = document.createElement("div");
                answerButtonsWrapper.setAttribute("class", "answerButtons");
                paragraph = document.createElement("p");
                paragraph.textContent = `${Object.keys(scores[i])[0]} : ${scores[i][Object.keys(scores[i])[0]]}`;

                rightAnswerButton = document.createElement("button");
                rightAnswerButton.setAttribute("class", "add answerButton");
                rightAnswerButton.name = "add";
                rightAnswerButton.id = "add" + i;
                rightAnswerButton.textContent = "+";

                wrongAnswerButton = document.createElement("button");
                wrongAnswerButton.setAttribute("class", "sub answerButton");
                wrongAnswerButton.name = "sub";
                wrongAnswerButton.id = "sub" + i;
                wrongAnswerButton.textContent = "-";

                answerButtonsWrapper.appendChild(rightAnswerButton);
                answerButtonsWrapper.appendChild(wrongAnswerButton);
                answerButtonsWrapper.appendChild(paragraph);
                fragment.appendChild(answerButtonsWrapper);
            }

            answerButtonsDiv.appendChild(fragment);
            answerButtons = document.getElementsByClassName("answerButton");
        }

        function updateLocalStorage(questionValue) {
            const questionIndex = gameObj.game[questionValue].findIndex(elem => JSON.stringify(elem) === JSON.stringify(lastQuestionId));
            gameObj.game[questionValue][questionIndex] = -1;
			gameObj.game.players = scores;
            localStorage.setItem("game", JSON.stringify(gameObj.game));
        }

        function answerHandling(event) {
            const playerIndex = parseInt(event.target.id[3]);
            if (isNaN(playerIndex)) {
                return;
            }
            const scoreParagraph = document.querySelectorAll("p")[playerIndex];
            const questionValue = parseInt(questionButton.textContent);

            if (event.target.name === "add") {
                answerCount = playerCount;
                scores[playerIndex][Object.keys( scores[playerIndex] )[0]] += questionValue;
            }
            else {
                answerCount++;
                event.target.disabled = true;
                event.target.previousElementSibling.disabled = true; // + button
                scores[playerIndex][Object.keys( scores[playerIndex] )[0]] -= questionValue;
            }

            scoreParagraph.textContent = `${Object.keys( scores[playerIndex] )[0]} : ${scores[playerIndex][Object.keys( scores[playerIndex] )[0]]}`;

            if (answerCount === playerCount) {
                answerCount = 0;
                gameTable.style.display = "table";
        	    question.style.display = "none";
                answerButtonsDiv.style.display = "none";
                updateLocalStorage(questionValue);
            }
        }

        function showQuestion(ajaxResponse, gameTable, question, answerButtonsDiv, questionButton) {
            gameTable.style.display = "none";
            questionButton.style.visibility = "hidden";
            question.style.display = "block";
            answerObj = ajaxResponse;
            console.log(`Küsimus:  ${ajaxResponse.question}\nVastus: ${ajaxResponse.answer}`);
            question.textContent = ajaxResponse.question;
            answerButtonsDiv.style.display = "grid";
            answerButtonsDiv.style.gridTemplateColumns = "auto ".repeat(playerCount).trim();

            for (let i = 0; i < answerButtons.length; i++) {
                answerButtons[i].disabled = false;
            }
        }

        async function getQuestionInfo(event) {
            if (event.target.nodeName === "BUTTON") {
                let response;
                let data;
                questionButton = event.target;
                lastQuestionId = parseInt(questionButton.dataset.id);

                try {
                    response = await fetch(`/kuldvillak/questions/${lastQuestionId}`);
                    data = await response.json();
                }
                catch(err) {
                    console.error(err);
                    return;
                }

                showQuestion(data, gameTable, question, answerButtonsDiv, questionButton);
            }
        }

        function showQuestionInfo(event) {
            if (event.target.nodeName === "BUTTON") {
                questionButton = event.target;
                lastQuestionId = {[questionButton.dataset.question]: questionButton.dataset.answer};
                const data = {"question": questionButton.dataset.question, "answer": questionButton.dataset.answer};

                showQuestion(data, gameTable, question, answerButtonsDiv, questionButton);
            }
        }

        // create gametable, player names and score elements
        buildGameTable();
        buildScores();

        // event listeners
        if (gameObj.game.type === "auto") {
            gameTable.addEventListener("click", getQuestionInfo);
        }
        else if (gameObj.game.type === "manual") {
            gameTable.addEventListener("click", showQuestionInfo);
        }

        question.addEventListener("click", function() {
            if (this.textContent === answerObj.question) {
                this.textContent = answerObj.answer;
            }
            else {
                this.textContent = answerObj.question;
            }
        });

        answerButtonsDiv.addEventListener("click", answerHandling);
    </script>
    </body>
</html>