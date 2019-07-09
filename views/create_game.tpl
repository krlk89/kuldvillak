<!DOCTYPE html>
<html>
    <head>
        <title>Kuldvillak</title>
        <link rel="stylesheet" type="text/css" href="/static/stylesheet.css">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>

    <body>
    <form method="get" action="/kuldvillak/create">
        <table>
        %for i in range(6):
            <tr>
            %for j in range(6):
                %if i == 0:
                    %if j == 0:
                        <th></th>
                    %else:
                        <th><input type="text" placeholder="Pealkiri" name="pealkiri" required></th>
                    %end
                %else:
                    %if j == 0:
                        <th><p>{{i * 10}}</></th>
                    %else:
                        <td>
                        <input type="text" placeholder="Küsimus" name="row{{i}}" required>
                        <input type="text" placeholder="Vastus" name="row{{i}}" required>
                        </td>
                    %end
                %end
            %end
            </tr>
        %end
        </table>

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

        <input type="submit" class="button" value="Alusta">
    </form>

    <script>
        "use strict";

        const playerCountSelectBox = document.getElementById("players");

        function playerNameInputHandling() {
            const selectedIndex = this.selectedIndex;
            let player;

            for (let i = 1; i < 3; i++) {
                player = document.getElementById(`player${i}`);
                if (i <= selectedIndex) {
                    player.style.display = "inline-block";
                    player.disabled = false;
                }
                else {
                    player.style.display = "none";
                    player.disabled = true;
                }
            }
        }

        // show player name input fields according to selected players count
        playerCountSelectBox.addEventListener("change", playerNameInputHandling);
    </script>
    </body>
</html>