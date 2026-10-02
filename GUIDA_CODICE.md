# Guida al codice di SpotIt Madrid

Questa guida serve per studiare come è fatta l'app. Prima la mappa del progetto, poi
cosa fa ogni funzione nuova (Blocco A), poi i concetti di programmazione che incontri,
poi esercizi per provare da solo.

## 1. Come è organizzato il progetto

```
lib/                      <- tutto il codice dell'app (linguaggio Dart, framework Flutter)
  main.dart               <- punto di partenza: decide quale schermata mostrare
  models/                 <- "le forme dei dati": Bar, UserProfile, QuizAnswers, Review...
  data/                   <- dati: mock_data.dart (locali di prova), places_bars.dart (legge il file scaricato)
  services/               <- "la logica", senza grafica: salvataggio, orari, posizione, condivisione
  screens/                <- le schermate intere (login, home, mappa, dettaglio, profilo...)
  widgets/                <- pezzi di schermata riutilizzabili (BarCard = la card di un locale)
  utils/                  <- piccole funzioni di aiuto (geo.dart = distanze)
  l10n/                   <- le traduzioni (italiano, inglese, spagnolo)
assets/data/malasana_bars.json   <- i 60 locali scaricati da OpenStreetMap
tool/                     <- script Python che scaricano i dati (non fanno parte dell'app)
test/                     <- test automatici: verificano che il codice faccia quello che promette
.github/workflows/        <- istruzioni per GitHub: pubblicare il sito, aggiornare i dati
```

Regola d'oro: **la logica sta in `services/` e `utils/`, la grafica in `screens/` e `widgets/`.**
Così la logica si può testare senza aprire l'app.

### Il flusso di avvio (`lib/main.dart`)
1. Si caricano i dati salvati (`DbService.init()`).
2. Se il quiz non è fatto → `OnboardingQuizScreen`.
3. Altrimenti, se non c'è un profilo → `LoginScreen` (con "Continua come ospite").
4. Altrimenti → `MainNavigationWrapper`: la barra in basso con Locali / Mappa / Preferiti / Profilo.

### Dove sono salvati i dati
In `DbService` (`lib/services/db_service.dart`), con `shared_preferences`: nel browser è il
localStorage, sul telefono è un file. **Solo sul tuo dispositivo**: ecco perché gli amici non
vedono i tuoi preferiti. Per condividerli serve un server (Blocco C).

## 2. Cosa abbiamo fatto nel Blocco A

### 2.1 Pulizia delle cose finte (`login_screen.dart`, `db_service.dart`)
- Tolti l'account admin con password scritta nel codice (`admin123`), l'account di prova
  `alex@spotit.com` e i pulsanti "Google"/"Apple" che in realtà ti facevano entrare come Alex.
- Perché: chi legge il codice (è pubblico su GitHub) vede la password; e i pulsanti
  promettevano un login che non esisteva.
- La prenotazione ora dice la verità: "Richiesta salvata", con i pulsanti per chiamare il
  locale e avvisare gli amici (`booking_screen.dart`). Tolta anche la "lista ospiti prioritaria".

### 2.2 Accesso come ospite (`DbService.continueAsGuest`)
Crea un profilo "Ospite" sul dispositivo e chiama `widget.onLoginSuccess()`. Il tasto sta
nel `LoginScreen`. L'età viene presa dalla fascia scelta nel quiz (`quiz.approxAge`).

### 2.3 "Aperto adesso" (`lib/services/opening_hours.dart`)
Il cuore è la funzione `openStatus(orari, adesso)` che restituisce `OpenStatus`
(aperto / chiuso / sconosciuto + un testo come "Aperto · chiude alle 02:30").
Come ragiona:
1. **`_parse`** trasforma il testo `"Lun-Gio 18:00-01:00; Ven-Sab 18:00-03:00"` in una mappa
   "giorno → fasce orarie". Usa un'espressione regolare (`RegExp`) per riconoscere giorni
   (`Lun`, `Lun-Gio`) e orari (`18:00-01:00`). Se trova qualcosa che non capisce → `null`.
2. Gli orari sono in **minuti dalla mezzanotte** (18:00 = 1080). Una fascia che finisce
   prima di iniziare (`19:00-02:30`) è "notturna": continua dopo mezzanotte.
3. Per sapere se è aperto adesso guarda due cose: le fasce di **oggi**, e le fasce notturne
   di **ieri** (se sono le 01:00 di martedì e il bar ha aperto lunedì alle 19:00, è aperto).
4. Se è chiuso, cerca la prossima apertura nei 7 giorni successivi.
5. Se gli orari mancano o non si leggono → `unknown`: **mai** "chiuso" per sbaglio.

Test: `test/opening_hours_test.dart`, compreso uno che legge **tutti** gli orari veri del file.

### 2.4 "Vicino a me" (`location_service.dart`, `utils/geo.dart`, `home_screen.dart`)
- `LocationService.currentPosition()` chiede il permesso al browser/telefono e restituisce
  la posizione, oppure `null` se l'utente rifiuta (l'app continua a funzionare).
- `distanceKm` calcola la distanza tra due coordinate con la formula di Haversine
  (la Terra è una sfera, non un piano). `walkMinutes` assume 5 km/h → 12 minuti per km.
- Nella home: premendo il filtro, si chiede la posizione, si calcola la distanza di ogni
  locale e si ordina la lista per distanza.
- Permessi: `AndroidManifest.xml` (Android) e `Info.plist` (iPhone) li devono dichiarare.

### 2.5 Filtri rapidi (`home_screen.dart`)
Quattro variabili di stato (`_openNow`, `_withMusic`, `_budget`, `_nearMe`). In `build()`
la lista viene filtrata con `.where(...)`: un locale resta solo se soddisfa **tutti** i
filtri attivi. Con "Aperto ora" i locali senza orari non si possono valutare: invece di
nasconderli in silenzio, la home scrive quanti sono.

### 2.6 Condividi su WhatsApp (`share_service.dart`)
Costruisce un testo (nome, indirizzo, link a Google Maps, link al sito) e apre
`https://wa.me/?text=...`: funziona su iPhone, Android e computer, senza account né chiavi.
- Nel dettaglio di un locale: pulsante **Condividi**.
- Nei Preferiti: **Manda agli amici** invia la lista numerata ("dove andiamo stasera?").

## 2b. Cosa abbiamo fatto nel Blocco B

### Le lingue (`lib/l10n/`)
- **`strings_*.dart`** contengono tutte le frasi dell'app in un dizionario:
  `'open.until': ['Aperto · chiude alle {t}', 'Open · closes at {t}', 'Abierto · cierra a las {t}']`.
  Le tre voci sono italiano, inglese, spagnolo. `{t}` è un segnaposto.
- **`tr('open.until', {'t': '02:30'})`** (in `l10n.dart`) restituisce la frase nella lingua corrente e
  sostituisce i segnaposto. Nel codice non c'è più testo scritto a mano: c'è `tr('chiave')`.
- **La lingua**: all'avvio si usa quella scelta dall'utente (salvata con `DbService.saveLang`),
  altrimenti quella del dispositivo se è it/en/es, altrimenti l'inglese.
- **`L10n.lang`** è un `ValueNotifier`: un contenitore che avvisa chi lo ascolta quando cambia.
  `main.dart` lo ascolta con `ValueListenableBuilder` e ridisegna l'app. `LangButton` (il piccolo
  "EN ▾") fa la stessa cosa per ridisegnarsi da solo.
- I dati che arrivano da fuori (tipo di locale, musica, età, vibe) si traducono con `trType`,
  `trMusic`, `trAge`, `trVibe`. Se un valore non è nel dizionario resta com'è: niente crash.
- Le **descrizioni** dei locali sono generate in 3 lingue da `tool/fetch_osm.py`
  (campo `descriptions`). Se manca la lingua si usa quella italiana (`Bar.localDescription`).
- **Test** (`test/l10n_test.dart`): ogni frase ha 3 lingue non vuote; i segnaposto sono uguali
  nelle 3 lingue; ogni chiave usata nel codice esiste nel dizionario.

### "Perché è per te" (`recommendation_service.dart`)
`RecommendationService.match(bar, quiz)` restituisce un oggetto `Match` con il punteggio **e** la
lista dei motivi: ogni criterio che dà punti aggiunge anche una frase ("Vibe Chill, come volevi").
I motivi sono ordinati per peso: la card mostra i primi due, il dettaglio li mostra tutti.
Idea da imparare: **calcolare il risultato e la spiegazione insieme**, nello stesso punto, così non
possono andare fuori sincrono.

### Un bug interessante (da studiare)
Il pulsante lingua restava su "ES" anche con l'app già in inglese. Causa: era un widget `const`
(creato una volta sola) e Flutter salta il ridisegno dei widget identici. Soluzione: farlo
ascoltare `L10n.lang` con `ValueListenableBuilder`.

## 3. Concetti di programmazione che trovi nel codice

| Concetto | Dove lo vedi | In parole semplici |
|---|---|---|
| **Widget** | tutto in `screens/` e `widgets/` | In Flutter ogni pezzo di schermata è un widget, annidato come scatole dentro scatole. |
| **StatefulWidget / `setState`** | `home_screen.dart` | Un widget che cambia nel tempo. `setState(() { ... })` dice a Flutter "i dati sono cambiati, ridisegna". |
| **`async` / `await` / `Future`** | `LocationService`, `DbService` | Operazioni lente (posizione, salvataggio) non bloccano l'app: `await` aspetta il risultato. |
| **Null safety (`?`)** | `LatLng? _myPos`, `int? _budget` | Il `?` dice "può essere vuoto (null)". Dart ti obbliga a gestire il caso. |
| **`List.where / map / sort`** | filtri nella home | `where` tiene gli elementi giusti, `map` li trasforma, `sort` li ordina. |
| **JSON** | `Bar.fromJson / toJson` | Testo strutturato per salvare e scambiare dati. |
| **Test** | cartella `test/` | `expect(risultato, atteso)`: se il codice cambia e rompe qualcosa, il test diventa rosso. |
| **Enum** | `OpenState`, `AppLang` | Un insieme chiuso di valori possibili (`open`, `closed`, `unknown`). |
| **ValueNotifier** | `L10n.lang` | Un valore che avvisa chi lo ascolta quando cambia: base di molte funzioni "reattive". |
| **Record `(int, String)`** | `scored` in `match()` | Una coppia di valori senza dover creare una classe. |

## 4. Come provare sul tuo computer
Servono Flutter (flutter.dev) e Chrome.
```
flutter pub get          # scarica le librerie
flutter run -d chrome    # avvia l'app nel browser
flutter test             # esegue tutti i test
flutter analyze          # cerca errori e cattive abitudini
```

## 5. Esercizi (dal più facile)
1. In `opening_hours_test.dart` aggiungi un test con gli orari di un locale tuo preferito.
2. In `walkMinutes` cambia la velocità a 4 km/h e correggi i test che si rompono.
3. In `home_screen.dart` aggiungi un filtro "Pub" che mostri solo i locali con `type == 'Pub'`.
4. In `barShareText` aggiungi gli orari del locale nel messaggio WhatsApp.
5. (Più difficile) Fai comparire "Aperto ora" anche nelle card della mappa.
6. Aggiungi il **francese**: una colonna in ogni riga dei dizionari, `AppLang.fr`, e il test ti dice cosa manca.
7. Aggiungi un motivo nuovo in `match()`, per esempio "Aperto fino a tardi" se chiude dopo le 03:00.

## 6. Cose ancora da fare (non è finito!)
- **Blocco C:** account veri, recensioni e foto condivise → serve un server (es. Supabase).
- **Blocco D:** trasformare il sito in app per iPhone/Android (serve un Mac o un servizio
  cloud per la build iOS).
