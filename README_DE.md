# ZygiskEnv Alpha Bridge v2.0.0 – deutsche Anleitung

**Status:** experimenteller, quelloffener Kompatibilitätspatch für ReZygisk und Magisk Alpha. Auf einem Android-Gerät wurde diese Version noch **nicht getestet**. Die hier angebotene `*_SOURCE.zip` ist **kein** Magisk-Installationspaket!

## Was die Änderung macht

- Korrigiert die CPU-Architekturerkennung des ursprünglichen ZygiskEnv.
- Prüft die Zygisk-/ReZygisk-Kennung des Managers, nicht pauschal die Rootberechtigung beliebiger Apps.
- Setzt `ZYGISK_ENABLED=1` in einem geeigneten Manager-Prozess erst nach der App-Spezialisierung und vermeidet damit, dass die Kennung im falschen Prozess gesetzt wird.
- Erhält die bisherige Erkennung der üblichen Magisk-, Magisk-Alpha- und KernelSU-Next-Paketnamen und unterstützt außerdem die Manager-Kennung von ReZygisk selbst.
- Mit der Aktionstaste im Modul lassen sich grundlegende Diagnosen anzeigen, ohne das System zu verändern.

**Wichtige Einschränkung:** ReZygisk unterstützt Magisk Alpha offiziell nicht. Seine eigene Manager-Erkennung setzt `ZYGISK_ENABLED` bereits. Falls Magisk Alpha intern einen anderen Statuswert verwendet, kann dieses Modul allein die Anzeige nicht zuverlässig reparieren. `ZYGISK_ENABLED=1` ist kein Beweis, dass ReZygisk tatsächlich läuft.

## So wird das installierbare ZIP gebaut

1. Auf GitHub ein **neues, leeres Repository** erstellen, z. B. `ZygiskEnv-Alpha-Bridge`. Nicht die Kernel-Repository überschreiben.
2. Den Inhalt der `ZygiskEnv_AlphaBridge_v2.0.0_SOURCE.zip` einschließlich `.github/workflows/build.yml` in dieses Repository auf den Standardbranch hochladen. Die ZIP ist nur der Quellcode.
3. In GitHub **Actions** → **ZygiskEnv Alpha Bridge - build/test** → **Run workflow** starten (beim Push startet der Build ebenfalls automatisch).
4. Erst bei **grünem** Test- und Buildlauf das Artefakt `ZygiskEnv-Alpha-Bridge-release` herunterladen. Dieses Artefakt ist das **installierbare** Modul-ZIP.
5. Voraussetzung: ReZygisk ist installiert und aktiv; Magisks eingebautes Zygisk bleibt **deaktiviert**. Andere, konkurrierende Zygisk-Implementierungen nicht parallel laufen lassen.
6. Das Release-ZIP über **Magisk Alpha → Module → Aus Speicher installieren** installieren und Android neu starten. Alte ZygiskEnv-Fassung wird durch die gleiche Modul-ID ersetzt.

## Prüfung nach dem Neustart

1. In ReZygisk prüfen, ob der Monitor läuft und deine gewohnten Zygisk-Module laden.
2. Die Magisk-Alpha-Anzeige überprüfen. Auch bei funktionierender ReZygisk-Laufzeit kann sie weiterhin „Zygisk aus“ melden.
3. In Termux (mit Rootfreigabe) den Protokollauszug ansehen:

```sh
su -c 'logcat -d -s ZygiskEnvBridge:I'
```

Steht dort `Set runtime marker post-specialize for ...`, hat die Brücke die Kennung für diesen Prozess gesetzt. Das beweist aber noch nicht, dass Magisk Alpha den Status korrekt anzeigt.

## Fehlerbehebung

Wenn der Manager nicht startet oder die Funktion nicht passt: Das Modul in Magisk Alpha deaktivieren bzw. entfernen und neu starten. Vorher eine funktionierende Konfiguration und einen Recoveryweg bereithalten. Keine Änderungen am Kernel oder `boot.img` nötig.

## Teststand

- 14 Hosttests der Manager-Erkennung und des Ausführungszeitpunkts.
- Vier simulierte Installationsfälle (ARM 32/64 Bit, x86 32/64 Bit).
- Noch **kein** echter Test auf Magisk Alpha und keine lokal kompilierten Android-`.so`-Dateien; diese entstehen erst über GitHub Actions mit Android NDK.

Original: https://github.com/TheSillyOk/ZygiskEnv
Fehlerbericht zur aktuellen Magisk-/ReZygisk-Anzeige: https://github.com/PerformanC/ReZygisk/issues/406
