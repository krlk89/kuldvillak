<!DOCTYPE html>
<html>
    <head>
        <title>Kuldvillak</title>
        <link rel="stylesheet" type="text/css" href="/static/stylesheet.css">
    </head>
    
    <body>
    <h1 align="center">Edetabel</h1>
    
    <table style="width:50%" align="center" class="results">
        <tr>
            <th>Koht</th>
            <th>Nimi</th>
            <th>Skoor</th>
        </tr>
    %for nr, row in enumerate(top, start = 1):
        <tr>
            <td>{{nr}}.</td>
            <td>{{row[0]}}</td>
            <td>{{row[1]}}</td>
        </tr>
    %end
    </table>
    
    <a href="/">Esilehele</a>
    </body>
</html>
