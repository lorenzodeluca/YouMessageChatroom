# **Lorenzo De Luca** [github](https://github.com/lorenzodeluca) - [gitlab](https://gitlab.com/lorenzodeluca) - [stackoverflow](https://stackoverflow.com/users/9441578/lorenzo?tab=profile)

# Progetto

ANDROID/Flutter: chatroom

Punti principali: `Login multipiattaforma(Firebase),Socket TCP, Emoji, SQLlite(Salvataggio dati in locale,SharedPreferences), Animazioni, CustomPainter, Stream, Layout portait/landscape, SnackBar, Parametri di default nelle funzioni, Gestione Dati(Server-side), interfaccia server debug, rubrica, server status` e altro

### Prerequisiti

L'applicazione è compatibile con tutti i nuovi smartphones(IOS,Huawei,Samsung,ecc...).

### Installazione 

Istruzioni passo passo per compilare ed ottenere un eseguibile del programma
Per compilare il programma e ottenere un file compilato(APK) serve aver installato `Flutter-SDK` e `Visual studio code` con i rispettivi plugin

Per ottenere installare l'app su un dispositivo:
```
Aprire la cartella del client su Visual Studio Code -> Collegare il dispositivo -> Premere 'F5'
```
A compilazione terminata si potra trovare l'app installata sul dispositivo e  l'apk pronto per l'installazione nella directory `build/app/outputs/apk/app.apk`

<br />

## Eseguire i test

Per avviare l'app dopo aver compilato tutti i sorgenti e averli installati in un dispositivo basta clickare sull'icona nominata `uMessage`


### Il programma(dettagli)
La applicazione è divisa in due parti, `client e server`, i sorgenti sono nelle omonime directory. Lato server necessità di un server web(Vedi `Apache2`/Nginx) per visualizzare l'interfaccia web(index.html) e di aprire la porta dove saranno ricevuti i dati.
Per eseguire le funzioni di rete sul server deve essere eseguito con dart l'applicativo apposito.
All'avvio dell'applicazione la prima cosa che verra caricata è la schermata principale del cronometro. `Cliccando al centro` dello schermo si protrà far `partire` il cronometro. Per metterlo momentaneamente in `pausa` è sufficiente `cliccare sullo schermo di nuovo`. Per `resettarlo` basta `tenere il dito premuto` sullo schermo per 2 secondi.
Nel menu principale si può premere sull'icona + in basso allo schermo per `salvare un tempo giro`.
`Trascinando` il dito dal centro dello schermo verso il basso o `premento la relativa icona` si può passare alla schermata con tutti i `tempi giro salvati dell'ultima sessione`.

Ecco nei dettagli i delle classi e dei principali metodi presenti nel codice:

> `class main`
- Inizializzazione dell'applicazione e del template. Consente di eseguire il login nell'applicazione
<br />  <br /> 
  
> `class chat`
- Classe per disegnare la chat e le animazioni dei messaggi. Invio/Ricezione messaggi.
<br /><br />   
  
> `class home`
- Homepage
<br /><br /> 