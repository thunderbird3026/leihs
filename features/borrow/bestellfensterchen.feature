# language: de

Funktionalität: Bestellfensterchen

  Um Gegenstände ausleihen zu können
  möchte ich als Ausleiher
  die möglichkeit haben Modelle zu bestellen

  Grundlage:
    Angenommen man ist "Normin"

  Szenario: Bestellfensterchen
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Dann sehe ich das Bestellfensterchen

  Szenario: Kein Bestellfensterchen
    Angenommen man befindet sich auf der Bestellübersicht
    Dann sehe ich kein Bestellfensterchen

  Szenario: Bestellfensterchen Inhalt
    Angenommen ich ein Modell der Bestellung hinzufüge
    Dann erscheint es im Bestellfensterchen
    Und die Modelle im Bestellfensterchen sind alphabetisch sortiert
    Und gleiche Modelle werden zusammengefasst
    Wenn das gleiche Modell nochmals hinzugefügt wird
    Dann wird die Anzahl dieses Modells erhöht
    Und die Modelle im Bestellfensterchen sind alphabetisch sortiert
    Und gleiche Modelle werden zusammengefasst
    Und ich kann zur detaillierten Bestellübersicht gelangen

  @javascript
  Szenario: Bestellfensterchen aus Kalender updaten
    Wenn ich mit dem Kalender ein Modell der Bestellung hinzufüge
    Dann wird das Bestellfensterchen aktualisiert
