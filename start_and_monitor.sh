#!/bin/bash

# Timeout in Sekunden, bevor der Server pausiert wird
INACTIVITY_TIMEOUT=10
CHECK_INTERVAL=1
IDLE_TIME=0
RCON_PORT=25575
RCON_PASSWORD=
SEARCH_PATTERN="(\d+) von maximal"
PFAD=/home/mcserver/
JAR_NAME="purpur.jar"  # Name der spezifischen .jar-Datei für Minecraft

# Entferne die .paused Datei und setze den Server fort, falls sie existiert
if [[ -f "${PFAD}.paused" ]]; then
    rm "${PFAD}.paused"
    resume
fi

pause() {
    # Prüfen, ob ein Java-Prozess mit `purpur` im Befehl im Schlafmodus ist (S-Status)
    if [[ $(ps -ax -o stat,comm,args | grep 'java' | grep "$JAR_NAME" | awk '{ print $1 }') =~ ^S.*$ ]]; then
        # Nur den Java-Prozess pausieren, der `purpur` enthält
        pkill -STOP -f "$JAR_NAME"
        touch "${PFAD}.paused"
    fi
}

resume() {
    # Schleife läuft, solange die Datei .paused existiert
    while [[ -f "${PFAD}.paused" ]]; do
        sleep 1
    done

    # Prüfen, ob der spezifische Java-Prozess mit `purpur` im Schlafmodus ist
    if [[ $(ps -ax -o stat,comm,args | grep '[j]ava' | grep "$JAR_NAME" | awk '{ print $1 }') =~ ^T.*$ ]]; then
        echo "Java-Prozess $JAR_NAME gefunden. Versuche, ihn fortzusetzen..."
        if pkill -CONT -f "$JAR_NAME"; then
            echo "Java-Prozess erfolgreich fortgesetzt."
            rm -f "${PFAD}.paused"
        else
            echo "Fehler beim Fortsetzen des Java-Prozesses."
            exit 1
        fi
    else
        echo "Kein Java-Prozess im Zustand 'S' gefunden."
    fi

    echo "Die Datei ${PFAD}.paused wurde entfernt. Beende die Pause."
}

# Funktion zur Prüfung auf verbundene Spieler
are_players_connected() {
    # Führe den mcrcon-Befehl aus und speichere die Ausgabe
    output=$("${PFAD}mcrcon" -H localhost -P "$RCON_PORT" -p "$RCON_PASSWORD" "list" 2>&1)

    # Überprüfen, ob der Befehl erfolgreich war
    if [[ $? -ne 0 ]]; then
        echo "Fehler beim Abrufen der Spieleranzahl: $output"
        exit 1
    fi

    echo "Ausgabe von mcrcon:"
    echo "$output"

    # Entferne Farbcodes (ANSI Escape Codes) aus der Ausgabe
    clean_output=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')

    # Extrahiere die Anzahl der Spieler mit dem regulären Ausdruck
    player_count=$(echo "$clean_output" | grep -oP "$SEARCH_PATTERN" | grep -oP '^\d+')

    if [[ -n "$player_count" && "$player_count" -gt 0 ]]; then
        echo "Anzahl der verbundenen Spieler: $player_count"
        return 0  # Spieler verbunden
    else
        return 1  # Keine Spieler
    fi
}

# Überwachungs-Loop
while true; do
    if are_players_connected; then
        echo "Spieler sind verbunden. Setze Inaktivitätszeit zurück."
        IDLE_TIME=0
    else
        # Prüfe, ob die Datei .paused existiert, und setze den Timer zurück, falls sie existiert
        if ! [[ -f "${PFAD}.paused" ]]; then
            echo "Spieler verbindet. Setze Inaktivitätszeit zurück."
            IDLE_TIME=0
        fi
        echo "Keine Spieler verbunden. Inaktivitätszeit: $IDLE_TIME Sekunden"
        IDLE_TIME=$((IDLE_TIME + CHECK_INTERVAL))
        if ! [[ -f "${PFAD}.paused" ]]; then
            touch "${PFAD}.paused"
        fi

        # Wenn die Inaktivitätszeit das Timeout erreicht, pausiere den Server und erstelle die Datei .paused
        if [[ $IDLE_TIME -ge $INACTIVITY_TIMEOUT ]]; then
            echo "Keine Spieler für $INACTIVITY_TIMEOUT Sekunden - Pausiere den Server."
            pause
            resume
            IDLE_TIME=0
        fi
    fi

    sleep $CHECK_INTERVAL
done
