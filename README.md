# Turno Player — Spotify 24/7 con pausas ergonómicas

App web que reproduce tu Spotify sin parar con géneros movidos aleatorios, detecta turno día/noche, y a horarios configurables pausa la música para reproducir tu MP3 de ejercicios — después retoma la música sola.

---

## 🏢 Deploy para red empresarial (Netlify/GitHub bloqueados)

**Cada PC corre su propio servidor local — NO necesita hosting público.** Spotify acepta `http://127.0.0.1:PUERTO/` como Redirect URI sin requerir HTTPS.

### Paso 1 — Registra una app de Spotify (UNA SOLA VEZ, compartida por todos)

1. Abre https://developer.spotify.com/dashboard → inicia sesión (cualquier cuenta Spotify sirve para registrar la app, no tiene que ser la de cada empleado).
2. **Create app**:
   - **Name:** Turno Player
   - **Description:** Reproductor 24/7 con pausas
   - **Redirect URI:**
     ```
     http://127.0.0.1:8080/
     ```
     (exactamente así, con la `/` final)
   - **APIs used:** marca **Web API** y **Web Playback SDK**
3. **Save** → **Settings** → copia el **Client ID**.
4. **Comparte ese Client ID** con todo tu equipo (no es una contraseña — es seguro compartirlo internamente).

### Paso 2 — En cada PC del equipo

1. **Copia la carpeta `spotify app` entera** al escritorio de esa PC (USB, network share, email, OneDrive, etc.).
2. **Doble clic en `start.bat`**.
3. Se abre una ventana negra con el servidor y el navegador automáticamente en `http://127.0.0.1:8080/`.
4. El usuario pega el **Client ID** que compartiste.
5. **Iniciar sesión con Spotify** → cada usuario entra con **su propia cuenta Spotify Premium**.
6. Configura horarios, sube el MP3, dale ▶.

**Mientras la ventana negra siga abierta, la app funciona.** Al minimizarla sigue andando. Si la cierra, el servidor para.

### Paso 3 — Cada usuario logueado

- Cada PC queda independiente con su propia cuenta Spotify sonando.
- El MP3 de ejercicios y los horarios se guardan por PC.
- Si todos quieren el mismo MP3, comparte el archivo y cada uno lo sube desde su app.

---

## 🧩 ¿`start.bat` no funciona?

El script trata 3 caminos en orden:

1. **Python** (si lo tienes instalado)
2. **py launcher** (instalador de Python oficial)
3. **PowerShell** (viene con Windows, siempre debería funcionar)

Si PowerShell se queja de "execution policy", abrí PowerShell **como administrador** y corré una vez:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Luego cerrá y volvé a hacer doble clic en `start.bat`.

Si tu empresa bloquea PowerShell por completo (raro), instalá Python desde https://python.org (instalador oficial, suele pasar el firewall) — marca "Add Python to PATH" durante la instalación. Después `start.bat` lo detecta y usa Python.

---

## 🌐 Alternativa — hosting que la red empresarial SÍ permite

Si la IT de tu empresa bloquea Netlify y GitHub Pages pero necesitas una URL pública, probá estos (usan dominios distintos y muchas veces están en la lista blanca):

| Opción | Dominio | Por qué suele pasar firewall |
|---|---|---|
| **Azure Static Web Apps** | `*.azurestaticapps.net` | Microsoft — casi siempre permitido en empresas |
| **Cloudflare Pages** | `*.pages.dev` | Cloudflare es infra crítica, rara vez bloqueada |
| **Firebase Hosting** | `*.web.app` / `*.firebaseapp.com` | Google — usualmente permitido |
| **Intranet de tu empresa** | `intranet.empresa.com/...` | Habla con IT — 5 minutos de su tiempo. Piden solo hostear un HTML estático |

Para cualquiera de estos: subes el mismo `index.html` y pones la URL resultante como Redirect URI en Spotify Dashboard (reemplazando o sumada a la de `127.0.0.1`).

---

## Archivos en esta carpeta

```
spotify app/
├── index.html      ← la app completa (un solo archivo)
├── start.bat       ← doble clic para levantar el servidor local
├── serve.ps1       ← servidor PowerShell (fallback)
├── README.md       ← este archivo
└── .nojekyll       ← útil solo si algún día usas GitHub Pages
```

---

## Requisitos

- **Cuenta Spotify Premium** por cada usuario (obligatorio — la API de reproducción no funciona con Free).
- Windows con PowerShell (viene incluido) o Python instalado.
- Navegador moderno (Chrome, Edge, Firefox).

## Qué hace la app

- Login con Spotify (OAuth PKCE + refresh token → aguanta 24/7 sin relogear).
- Canciones aleatorias de playlists oficiales por género: reggaetón, EDM/house, dance pop, rock movido, pop latino.
- Detección automática turno **día** ☀ / **noche** 🌙 (por defecto noche = 19:00–07:00, editable). En noche bloquea géneros que dan sueño.
- Pausas ergonómicas: a la hora configurada pausa Spotify, reproduce tu MP3, retoma solo.
- Aparece como dispositivo **"Turno Player 24/7"** en Spotify Connect — controlable también desde el móvil.

## Troubleshooting

| Síntoma | Fix |
|---|---|
| `start.bat` se cierra de inmediato | Abre PowerShell en la carpeta y corre manualmente: `powershell -ExecutionPolicy Bypass -File serve.ps1` para ver el error |
| "El puerto 8080 está en uso" | Edita `serve.ps1` y `start.bat`, cambia `8080` por `8888` (o el que quieras). Actualiza Redirect URI en Spotify Dashboard con el puerto nuevo |
| "INVALID_CLIENT: Insecure redirect URI" | Debe ser exactamente `http://127.0.0.1:8080/` con la barra — ni `localhost` ni `file://` |
| "Redirect URI mismatch" | La URL del Dashboard no coincide con la del navegador. Copia del navegador y pega en el Dashboard |
| "Premium required" | Esa cuenta Spotify es Free. Solo funciona con Premium |
| La ventana negra se cierra sola | Algún antivirus o política de grupo bloquea PowerShell. Instala Python desde python.org, `start.bat` lo detecta solo |
| "Not allowed to load local resource: file:///..." | Registraste un Redirect URI tipo `file://...`. Cambialo a `http://127.0.0.1:8080/` |

## Operación 24/7 — tips

- Deja la ventana negra del servidor minimizada pero abierta. Al cerrarla para el servidor.
- Deja la pestaña del navegador al frente para que Chrome no suspenda timers en segundo plano.
- Si reinicias el navegador hay que volver a subir el MP3 (archivos locales no persisten por seguridad del browser).
- Configurá el `start.bat` para que se ejecute al iniciar Windows si querés que funcione automático al prender la PC: `Win+R` → `shell:startup` → pega un acceso directo a `start.bat`.
