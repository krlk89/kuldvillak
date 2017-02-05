<!DOCTYPE html>
<html>
    <head>
        <title>Kuldvillak</title>
        <link rel="stylesheet" type="text/css" href="/static/stylesheet.css">
    </head>
    
    <body>
        <table style="width:100%">
            %for nr, row in enumerate(rows):
                <tr>
                %for col in row:
                    %if nr == 0:
                        <th><button disabled class="button" id="title">{{col[0]}}</button></th>
                    %else:
                        %if col == "":
                            <td><button disabled class="button" id="hidden"></button></td>
                        %else:
                            <td><form action="/q" method="post">
                                <input type="hidden" name="kys_id" value="{{col[1]}}"/>
                                <input type="submit" class="button" id="content" value="{{col[0]}}"/>
                            </form></td>
                        %end
                    %end
                %end
                </tr>
            %end
        </table>
            
        <p>Skoor: {{skoor}}</p>
        <a href="/">Esilehele</a>
    </body>
</html>
