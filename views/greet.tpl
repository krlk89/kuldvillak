<!DOCTYPE html>
<html>
    <head>
        <title>Kuldvillak</title>
        <link rel="stylesheet" type="text/css" href="/static/stylesheet.css">
    </head>

    <body>
        <h1 align="center">KULDVILLAK</h1>
        %if cont:
            <h2>Tere tulemast tagasi {{player_name}}!</h2>
        %else:
            <h2>Tere tulemast mängima populaarseimat mälumängu maailmas!</h2>
        %end
        
        <p>Vihje: klikkides küsimusel näed õiget vastust, uuesti klikkides ilmub taas küsimus.</p>
        <p>Õige vastuse korral vajuta "+", vale vastuse puhul "–" nupule.</p>

        <br>

        <form action="/" method="post" class="greet">
            %for i in range(1, 2): # change to (1, 4) for 3 players
                %name = "mangija{}".format(i)
                <input name="{{name}}" placeholder="Sisesta nimi" required/>
            %end
                <input type="submit" class="button" value="Alusta!"/>
            </form>
        %if cont:
            
            <form action="/kuldvillak" class="greet">
                <input type="submit" class="button" value="Jätka!"/>
            </form>
        %end

        <br>

        <a href="/results">Edetabel</a>
    </body>
</html>

