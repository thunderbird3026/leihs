# language: de

Funktionalität: Bestellübersicht

  Um die Bestellung in der Übersicht zu sehen
  möchte ich als Ausleiher
  die Möglichkeit haben meine bestellten Gegenstände in der Übersicht zu sehen

  Grundlage:
    Angenommen man ist "Normin"
    Und ich habe Gegenstände der Bestellung hinzugefügt
    Wenn ich die Bestellübersicht öffne

  @javascript
  Szenario: Bestellübersicht Bestellung löschen
    Wenn ich die Bestellung lösche
    Dann werde ich gefragt ob ich die Bestellung wirklich löschen möchte
    Und alle Einträge werden aus der Bestellung gelöscht
    Und die Gegenstände sind wieder zur Ausleihe verfügbar
    Und ich befinde mich wieder auf der Startseite

  Szenario: Bestellübersicht Bestellen
    Wenn ich einen Zweck eingebe
    Und ich die Bestellung abschliesse
    Dann ändert sich der Status der Bestellung auf Abgeschickt
    Und ich erhalte eine Bestellbestätigung
    Und in der Bestellbestätigung wird mitgeteilt, dass die Bestellung in Kürze bearbeitet wird
    Und ich befinde mich wieder auf der Startseite

  Szenario: Bestellübersicht Zweck nicht eingegeben
    Wenn der Zweck nicht abgefüllt wird
    Dann hat der Benutzer keine Möglichkeit die Bestellung abzuschicken
