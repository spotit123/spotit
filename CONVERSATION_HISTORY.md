# Cronologia e Riepilogo del Progetto: SpotIt Catania 🌋

Questo documento contiene la sintesi completa dello sviluppo dell'applicazione **SpotIt Catania**, i requisiti richiesti, le scelte tecniche effettuate e la cronologia delle conversazioni per consentire a te o ad altre istanze di Antigravity di riprendere il lavoro istantaneamente.

---

## 🎯 Il Concetto dell'App
Un'applicazione Flutter per smartphone (Android, iOS) e Web (Chrome) dedicata alla vita notturna di **Catania**. Aiuta l'utente a scegliere dove andare a bere/mangiare in base al proprio **mood/vibe** e a esigenze in tempo reale.

### Funzionalità Chiave:
1. **Autenticazione & Sessione:** Schermata di Login/Sign Up con validazione e persistenza dello stato di accesso.
2. **Mappa Dark:** Mappa interattiva centrata su Catania in tema scuro per esplorare i locali.
3. **Filtri Vibe:** Filtri rapidi per mood (es. *Chill, Energetic, Underground, Neon, Rooftop*).
4. **Prenotazione Tavoli ("Secure Your Spot"):** Selezione di ospiti, data, orari e lista d'ingresso prioritaria.
5. **Sondaggi Live in Tempo Reale 📣:** Gli utenti nel locale possono inviare riscontri su affollamento, tipo di musica e clientela, aggiornando dinamicamente il database dell'app.
6. **Profilo Utente Editabile:** Dettagli personali modificabili, statistiche d'uso (prenotazioni, preferiti) e badge.
7. **Opzione C (Recensioni, Galleria e Mappe):**
   - **Indicazioni Stradali:** Pulsante che apre Google Maps/Apple Maps puntando alle coordinate esatte del locale.
   - **Galleria Foto Interattiva:** Elenco orizzontale di immagini con pulsante per aggiungere nuove foto (simulazione fotocamera/galleria).
   - **Recensioni con Stelle:** Possibilità di scrivere recensioni con stelle (1-5) e testo. Il voto medio del bar si ricalcola automaticamente.
8. **Portale Web & Simulatore App Interattivo [NEW]:**
   - **Landing Page:** Pagina web a sinistra in tema scuro che descrive le funzionalità dell'app e mostra i locali migliori in tempo reale.
   - **Phone Simulator:** Un iPhone virtuale funzionante a destra che emula la navigazione, la visualizzazione dei dettagli dei bar, i filtri, i preferiti, i commenti e il log out. I dati inseriti rimangono salvati tramite LocalStorage.

---

## 🛠️ Scelte Tecniche & Architettura

- **Persistenza Locale Offline (JSON Database):** Utilizzo di `shared_preferences` (in Flutter) e `localStorage` (nel Simulatore Web) per memorizzare su file/local storage i dati di:
  - `user_profile` (Profilo dell'utente attivo)
  - `bars` (Stato dei locali, inclusi preferiti, modifiche all'affollamento dei sondaggi, nuove foto e recensioni inserite)
  - `bookings` (Lista delle prenotazioni effettuate)
  - `registered_users` (Utenti registrati localmente)
- **Apertura Link Mappe:** Utilizzo del pacchetto `url_launcher` (in Flutter) e link dinamici `window.open` (nel Simulatore Web).
- **Account di Test Predefinito:** `alex@spotit.com` con password `password123` (Nome: *Alex Rivers*, Username: `@vibe_seeker_99`).

---

## 📂 Struttura File Aggiornata

- [lib/main.dart](file:///C:/Users/hp/Desktop/spotit/lib/main.dart): Entrypoint dell'applicazione con gestione sessione utente e caricamento DB all'avvio.
- [lib/services/db_service.dart](file:///C:/Users/hp/Desktop/spotit/lib/services/db_service.dart): Servizio di persistenza offline JSON.
- [lib/models/review.dart](file:///C:/Users/hp/Desktop/spotit/lib/models/review.dart): Modello dati per le recensioni utente.
- [lib/models/booking.dart](file:///C:/Users/hp/Desktop/spotit/lib/models/booking.dart): Modello dati per le prenotazioni dei tavoli.
- [lib/models/user_profile.dart](file:///C:/Users/hp/Desktop/spotit/lib/models/user_profile.dart): Modello del profilo utente.
- [lib/models/bar.dart](file:///C:/Users/hp/Desktop/spotit/lib/models/bar.dart): Modello del locale esteso con recensioni e galleria immagini.
- [lib/screens/login_screen.dart](file:///C:/Users/hp/Desktop/spotit/lib/screens/login_screen.dart): UI di login/registrazione premium.
- [lib/screens/profile_screen.dart](file:///C:/Users/hp/Desktop/spotit/lib/screens/profile_screen.dart): UI del profilo con pulsante **Log Out** e ricalcolo contatori dinamico.
- [lib/screens/booking_screen.dart](file:///C:/Users/hp/Desktop/spotit/lib/screens/booking_screen.dart): Invio e salvataggio prenotazione su database.
- [lib/screens/detail_screen.dart](file:///C:/Users/hp/Desktop/spotit/lib/screens/detail_screen.dart): Live insights, sondaggi live, indicazioni stradali Maps, visualizzazione/inserimento foto e scrittura di recensioni.
- [lib/screens/add_spot_screen.dart](file:///C:/Users/hp/Desktop/spotit/lib/screens/add_spot_screen.dart): Aggiunta nuovo locale da parte dell'utente.
- [lib/data/mock_data.dart](file:///C:/Users/hp/Desktop/spotit/lib/data/mock_data.dart): Popolato con i locali reali di Catania ed i loro dati di prova.
- [spotit_web/index.html](file:///C:/Users/hp/Desktop/spotit/spotit_web/index.html) [NEW]: File HTML principale del portale web e del simulatore.
- [spotit_web/styles.css](file:///C:/Users/hp/Desktop/spotit/spotit_web/styles.css) [NEW]: Foglio di stile CSS per la landing page e l'emulatore.
- [spotit_web/app.js](file:///C:/Users/hp/Desktop/spotit/spotit_web/app.js) [NEW]: Logica JS dell'emulatore con persistenza LocalStorage.

---

## 🚀 Come Eseguire e Testare

### Per l'applicazione Flutter:
Apri il terminale ed esegui:
```powershell
cd C:\Users\hp\Desktop\spotit
C:\src\flutter\bin\flutter.bat run -d chrome
```

### Per il Portale Web & Simulatore (HTML/CSS/JS):
1. Apri la cartella `C:\Users\hp\Desktop\spotit\spotit_web\`
2. Fai **doppio clic** sul file **`index.html`** per aprirlo istantaneamente nel tuo browser web preferito!
