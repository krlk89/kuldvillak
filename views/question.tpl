<!DOCTYPE html>
<html>
    <head>
        <title>Kuldvillak</title>
        <link rel="stylesheet" type="text/css" href="/static/stylesheet.css">
    </head>
    
    <body>
        <div>
            <input onclick="change()" type="submit" class="button" id="question" value="{{kysimus}}"/>
            <form action="/kuldvillak" method="post">
                <input type="hidden" name="hind" value="{{hind}}"/>
                <input type="submit" name="sub" class="btn" id="sub" value="-"/>
                <input type="submit" name="add" class="btn" id="add" value="+"/>
            </form>
        </div>
        
        <script>
        function change() {
            var elem = document.getElementById("question");
            if (elem.value == "{{kysimus}}")
                elem.value = "{{vastus}}";
            else
                elem.value = "{{kysimus}}";
        }
        </script>
    </body>
</html>
