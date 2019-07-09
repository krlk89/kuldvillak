<!DOCTYPE html>
<html>
    <head>
        <title>Kuldvillak</title>
        <link rel="stylesheet" type="text/css" href="/static/stylesheet.css">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="keywords" content="kuldvillak, mälumäng, jeopardy, quiz">
    </head>

    <body>
        <div id="grid-container">

        <div id="header">
        <h1>KULDVILLAK</h1>
        <details>
            <summary>Õpetus</summary>
            <p>Klikkides küsimusel näed õiget vastust, uuesti klikkides ilmub taas küsimus.</p>
            <p>Õige vastuse korral vajuta "+", vale vastuse puhul "–" nupule.</p>
        </details>
        </div>

        <div id="main">
        <form action="/" method="get">
            <div class="topicsRadioButtons">
                <input type="radio" id="randomTopics" name="topicsType" value="random" checked>
                <label for="randomTopics">Juhuslikud teemad</label>
            </div>
            <div class="topicsRadioButtons">
                <input type="radio" id="selectedTopics" name="topicsType" value="chosen">
                <label for="selectedTopics">Valin ise teemad</label>
            </div>

            <div id="topicsChooserDiv">
            %for i in range(5):
                <select name="select{{i}}">
                <option hidden disabled selected value></option>
                %for topic in topics:
                    <option value="{{topic[0]}}">{{topic[0]}}</option>
                %end
                </select>
            %end
            </div>

            <div>
                <select name="playerCount" id="players">
                    <option value="1">1</option>
                    <option value="2">2</option>
                    <option value="3">3</option>
                </select>
                <label for="playerCount">Mängijate arv</label>
            </div>

            <div id="playerNames">
                <input type="text" name="player0" placeholder="Mängija 1" maxlength="25"/>
                <input type="text" id="player1" name="player1" placeholder="Mängija 2" maxlength="25"/>
                <input type="text" id="player2" name="player2" placeholder="Mängija 3" maxlength="25"/>
            </div>

            <input type="submit" id="submitBtn" class="button" value="Alusta"/>
        </form>

        <button id="createGameBtn" class="button">Loo ise mäng</button>
        </div>

        </div>

        <script>
            "use strict";

            const playerNames = document.querySelectorAll("input[type=text]");
            const topicsChooser = document.getElementById("topicsChooserDiv");
            const topicsChooserSelectBoxes = document.querySelectorAll("select");
            const chooseTopicsRadioBtn = document.getElementById("selectedTopics");
            const randomTopicsRadioBtn = document.getElementById("randomTopics");
            const playerCountSelectBox = document.getElementById("players");
            const oldSelectOptions = [0, 0, 0, 0, 0]; // initialized with default values
            const createGameBtn = document.getElementById("createGameBtn");


            function topicsChooserVisibility(visibility) {
                if (this.checked) {
                    topicsChooser.style.display = visibility;
                }
            }

            function topicChooserHandling(currentSelectBoxIndex) {
                for (let i = 0; i < 5; i++) {
                    if (i !== currentSelectBoxIndex) {
                        topicsChooserSelectBoxes[i].options[this.selectedIndex].disabled = true;
                        topicsChooserSelectBoxes[i].options[oldSelectOptions[currentSelectBoxIndex]].disabled = false;
                    }
                }
                oldSelectOptions[currentSelectBoxIndex] = this.selectedIndex;
            }

            function playerNameInputHandling() {
                const selectedIndex = this.selectedIndex;
                let player;

                for (let i = 1; i < 3; i++) {
                    player = document.getElementById(`player${i}`);
                    if (i <= selectedIndex) {
                        player.style.display = "inline";
                        player.disabled = false;
                    }
                    else {
                        player.style.display = "none";
                        player.disabled = true;
                    }
                }
            }

            function createContinueGameButton() {
                const mainDiv = document.getElementById("main");
                const continueGameButton = document.createElement("button");
                continueGameButton.textContent = "Jätka";
                continueGameButton.setAttribute("class", "button");

                mainDiv.insertBefore(continueGameButton, createGameBtn);

                continueGameButton.addEventListener("click", () => {
                    window.location.href = "/kuldvillak";
                });
            }

            // show continue game button only when there's an active game
            if (localStorage.length > 0) {
                createContinueGameButton();
            }

            // event listeners
            chooseTopicsRadioBtn.addEventListener("click",
                topicsChooserVisibility.bind(chooseTopicsRadioBtn, "block")
            );

            randomTopicsRadioBtn.addEventListener("click",
                topicsChooserVisibility.bind(randomTopicsRadioBtn, "none")
            );

            // disable topic when it's already selected in another selectbox
            for (let i = 0; i < 5; i++) {
                topicsChooserSelectBoxes[i].addEventListener("change",
                    topicChooserHandling.bind(topicsChooserSelectBoxes[i], i)
                );
            }

            // show player name input fields according to selected players count
            playerCountSelectBox.addEventListener("change", playerNameInputHandling);

            createGameBtn.addEventListener("click", () => {
                window.location.href = "kuldvillak/create";
            });

            // custom error messages
            document.getElementById("submitBtn").addEventListener("click", function() {
                let errorMsg = "";
                for (let i = 0; i < parseInt(playerCountSelectBox.value); i++) {
                    playerNames[i].value === "" ? errorMsg = "Sisesta nimi" : errorMsg = "";
                    playerNames[i].setCustomValidity(errorMsg);
                }

                errorMsg = "";
                if (chooseTopicsRadioBtn.checked) {
                    errorMsg = "Pead valima vähemalt ühe teema";
                    for (let j = 0; j < 5; j++) {
                        if (topicsChooserSelectBoxes[j].selectedIndex !== 0) {
                            errorMsg = "";
                            break;
                        }
                    }
                }
                topicsChooserSelectBoxes[0].setCustomValidity(errorMsg);
            });

            // back button handling
            for (let i = 0; i < 5; i++) {
                let selectBox = topicsChooserSelectBoxes[i];
                topicChooserHandling.call(selectBox, i);
            }

            topicsChooserVisibility.call(chooseTopicsRadioBtn, "inline");

            playerNameInputHandling.call(playerCountSelectBox);
        </script>
    </body>
</html>