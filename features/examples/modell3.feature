# language: de

Funktionalität: Modell

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: sich ergänzende Modelle entfernen (kompatibel)
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein Modell öffne, das bereits ergänzende Modelle hat
    Und ich ein ergänzendes Modell entferne
    Und ich speichere die Informationen
    Dann ist das Modell ohne das gelöschte ergänzende Modell gespeichert

  @javascript
  Szenario: Gruppenverteilung editieren
    Angenommen ich editieren ein bestehndes Modell mit bereits zugeteilten Kapazitäten
    Wenn ich bestehende Zuteilungen entfernen
    Und neue Zuteilungen hinzufügen
    Und ich speichere die Informationen
    Dann sind die geänderten Gruppenzuteilungen gespeichert

  @javascript
  Szenario: Modell löschen
    Angenommen es existiert ein Modell mit folgenden Eigenschaften
      | in keinem Vertrag aufgeführt |
      | keiner Bestellung zugewiesen |
      | keine Gegenstände zugefügt |
    Wenn ich dieses Modell aus der Liste lösche
    Und das Modell wurde aus der Liste gelöscht
    Und das Modell ist gelöscht