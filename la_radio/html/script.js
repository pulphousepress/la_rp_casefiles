/* la_radio — UI + full audio playback (drop-in)
   - Preserves your HTML/CSS layout (no overlays, no inline sizing)
   - Plays playlists from broadcast/<folder>/songs.json, dj.json, commercials.json, fallback list.json
   - Deterministic sequencing (DJ -> song -> commercial)
   - Static burst on station change
   - Robust autoplay handling (muted test + user gesture), retries, and verbose error logging to F8
   - Compatible with earlier client messages
*/

const BROADCAST_BASE = '../broadcast';
const STATIC_TIMEOUT_MS = 700;
const FADE_TIMEOUT_MS = 3000;
const MAX_PLAY_RETRIES = 4;

// station definitions — filenames for logo in html/img/ must match
const stations = [
  { id: 'los_animales', name: 'Los Animales Radio', folder: 'radio_chnl_01', logo: 'img/logo.png', playOrder: ['dj','song','commercial'] },
  { id: 'news', name: 'Newsreels', folder: 'la_radio_tlk', logo: 'img/news_logo.png', playOrder: ['song'] },
  { id: 'police', name: 'Police Dispatch', folder: 'la_radio_police', logo: 'img/pol_scn_logo.png', playOrder: ['song'] },
  { id: 'off', name: 'OFF', folder: null, logo: 'img/off_logo.png', playOrder: ['song'] }
];

// UI element refs
let radioEl, tickerEl, logoEl, dialEl, knobLeft, knobRight, glowEl;

// audio objects
const mainAudio = new Audio(); mainAudio.preload = 'auto'; mainAudio.crossOrigin = 'anonymous';
const staticAudio = new Audio(`${BROADCAST_BASE}/extra/static.ogg`); staticAudio.preload = 'auto';
const sfxAudio = new Audio(); sfxAudio.preload = 'auto';

let audioUnlocked = false;
let playRetries = {}; // url -> attempts

// per-station state
stations.forEach(s => { s._loaded = false; s._indices = { dj:0, song:0, commercial:0 }; s._ptr = 0; });

// --- utility: safe fetch JSON ---
async function fetchJson(path) {
  const r = await fetch(path, { cache: 'no-store' });
  if (!r.ok) throw new Error(`fetch ${path} -> ${r.status}`);
  return r.json();
}

// --- load station playlists safely ---
async function loadStation(s) {
  if (!s || !s.folder) { s.songs = []; s.dj = []; s.commercials = []; s._loaded = true; return s; }
  const base = `${BROADCAST_BASE}/${s.folder}`;
  s.songs = s.songs || []; s.dj = s.dj || []; s.commercials = s.commercials || [];
  try {
    try { const songs = await fetchJson(`${base}/songs.json`); if (Array.isArray(songs)) s.songs = songs; } catch(e) {
      try { const legacy = await fetchJson(`${base}/list.json`); if (Array.isArray(legacy)) s.songs = legacy; } catch(_) {}
    }
    try { const dj = await fetchJson(`${base}/dj.json`); if (Array.isArray(dj)) s.dj = dj; } catch(_) {}
    try { const comm = await fetchJson(`${base}/commercials.json`); if (Array.isArray(comm)) s.commercials = comm; } catch(_) {}
  } catch(e) {
    console.warn('la_radio: loadStation error', e);
  }
  s._loaded = true;
  return s;
}

// --- static burst ---
function playStatic(cb, timeout = STATIC_TIMEOUT_MS) {
  try { staticAudio.currentTime = 0; staticAudio.play().catch(()=>{}); } catch(e){}
  let done=false;
  const finish = () => { if(done) return; done = true; try{ staticAudio.pause(); } catch(e){} if (typeof cb === 'function') cb(); };
  staticAudio.addEventListener('ended', finish, { once:true });
  setTimeout(finish, timeout);
}

// --- autoplay unlock (muted test then user-gesture) ---
function attemptUnlock(forceUnmute = false) {
  if (audioUnlocked) return Promise.resolve(true);
  const test = new Audio(`${BROADCAST_BASE}/extra/test.ogg`);
  test.preload = 'auto';
  test.muted = true;
  return test.play().then(() => {
    test.pause();
    audioUnlocked = true;
    console.log('la_radio: audio unlocked (muted test).');
    return true;
  }).catch((err) => {
    console.warn('la_radio: muted test rejected ->', err && err.name, err && err.message);
    if (!forceUnmute) {
      // wait for user gesture (click/keydown)
      return new Promise(resolve => {
        const onGesture = () => {
          const t2 = new Audio(`${BROADCAST_BASE}/extra/test.ogg`);
          t2.preload = 'auto';
          t2.play().then(()=>{ t2.pause(); document.removeEventListener('click', onGesture); document.removeEventListener('keydown', onGesture); audioUnlocked = true; console.log('la_radio: audio unlocked (user gesture).'); resolve(true); })
            .catch(e2 => { console.warn('la_radio: user gesture play failed ->', e2 && e2.name, e2 && e2.message); resolve(false); });
        };
        document.addEventListener('click', onGesture, { once:true });
        document.addEventListener('keydown', onGesture, { once:true });
        // resolve false now — caller may retry or wait
        setTimeout(()=>resolve(false), 500);
      });
    }
    // forceUnmute: try unmuted play immediately (user clicked an internal button)
    test.muted = false;
    return test.play().then(()=>{ test.pause(); audioUnlocked = true; console.log('la_radio: audio unlocked (force unmuted).'); return true; })
      .catch(err2 => { console.warn('la_radio: unmuted test failed ->', err2 && err2.name, err2 && err2.message); return false; });
  });
}

// --- play with retries/backoff & error logging ---
function logPlayError(err, url) {
  const name = err && err.name ? err.name : 'UnknownError';
  const msg  = err && err.message ? err.message : String(err);
  console.warn(`la_radio: play failed for ${url} -> ${name}: ${msg}`);
}

// attemptPlayWithRetries sets mainAudio.src and tries to play; on failure handles NotAllowedError and NotSupportedError
function attemptPlayWithRetries(url, onEnded) {
  playRetries[url] = playRetries[url] || 0;
  const attempt = () => {
    try { mainAudio.pause(); } catch(e){}
    mainAudio.src = url;
    mainAudio.currentTime = 0;
    mainAudio.play().then(() => {
      console.log('la_radio: playing', url);
    }).catch(err => {
      logPlayError(err, url);
      const errName = err && err.name ? err.name : '';
      if (errName === 'NotAllowedError') {
        // autoplay blocked — attempt polite unlock then retry
        attemptUnlock(false).then(unlocked => {
          if (unlocked) setTimeout(attempt, 200);
          else console.log('la_radio: playback blocked: waiting for user gesture (click NUI).');
        });
        return;
      }
      if (errName === 'NotSupportedError') {
        console.error('la_radio: codec not supported for', url, '- re-encode to Ogg Vorbis/MP3.');
        return;
      }
      // other error: backoff retry
      playRetries[url] += 1;
      if (playRetries[url] <= MAX_PLAY_RETRIES) {
        const delay = 150 * Math.pow(2, playRetries[url]);
        setTimeout(attempt, delay);
      } else {
        console.error('la_radio: max retries reached for', url);
      }
    });

    const endedHandler = () => {
      mainAudio.removeEventListener('ended', endedHandler);
      if (typeof onEnded === 'function') onEnded();
    };
    mainAudio.addEventListener('ended', endedHandler);
  };

  attempt();
}

// --- sequencing: choose next file using playOrder and per-type round-robin ---
function pickNextFileForStation(s) {
  s.playOrder = s.playOrder || ['dj','song','commercial'];
  s._ptr = (typeof s._ptr === 'number') ? s._ptr : 0;
  let attempts = 0;
  while (attempts < s.playOrder.length) {
    const type = s.playOrder[s._ptr];
    s._ptr = (s._ptr + 1) % s.playOrder.length;
    let list = [];
    if (type === 'dj') list = s.dj || [];
    else if (type === 'commercial') list = s.commercials || [];
    else list = s.songs || [];
    if (list && list.length) {
      const key = (type === 'dj') ? 'dj' : (type === 'commercial' ? 'commercial' : 'song');
      const idx = s._indices[key] || 0;
      const file = list[idx % list.length];
      s._indices[key] = (idx + 1) % list.length;
      return { file, type };
    }
    attempts++;
  }
  // fallback
  if (s.songs && s.songs.length) return { file: s.songs[0], type: 'song' };
  return null;
}

// --- play loop for a station ---
async function playNextInStation(index) {
  const s = await loadStation(stations[index]);
  if (!s || !s.folder) { try{ mainAudio.pause(); }catch(e){} if (tickerEl) tickerEl.textContent = stations[index].name; if (logoEl) logoEl.src = stations[index].logo; return; }
  const pick = pickNextFileForStation(s);
  if (!pick) {
    console.warn('la_radio: no playable files for', s.folder);
    try { mainAudio.pause(); } catch(e){}
    if (tickerEl) tickerEl.textContent = s.name;
    if (logoEl) logoEl.src = stations[stations.length - 1].logo;
    return;
  }
  const full = `${BROADCAST_BASE}/${s.folder}/${pick.file}`;
  playStatic(() => {
    // reset retry counter for this URL
    playRetries[full] = 0;
    attemptPlayWithRetries(full, () => {
      // when track ends, continue to next in same station
      playNextInStation(index);
    });
  }, 700);
}

// --- UI helpers & animations (use existing IDs; do not change layout) ---
function ensureDomRefs() {
  radioEl  = document.getElementById('radio');
  tickerEl = document.getElementById('stationText') || document.getElementById('station-name');
  logoEl   = document.getElementById('station-logo');
  dialEl   = document.getElementById('dialIndicator') || document.getElementById('dial_indicator');
  knobLeft = document.getElementById('knobLeft') || document.getElementById('knob-left');
  knobRight= document.getElementById('knobRight') || document.getElementById('knob-right');
  glowEl   = document.getElementById('radioGlow') || document.getElementById('radio_bkgd_glow');
}

let currentStation = 0;
let uiVisible = false;
let fadeTimer = null;

function updateDial(index) {
  if (!dialEl) return;
  const steps = Math.max(1, stations.length - 1);
  const angle = -60 + (index / steps) * 120;
  dialEl.style.transition = 'transform 450ms ease';
  dialEl.style.transform = `rotate(${angle}deg)`;
}
function animateKnobs() {
  if (knobLeft) { knobLeft.style.transition = 'transform 300ms ease'; knobLeft.style.transform = `rotate(${(Math.random()*20-10)}deg)`; setTimeout(()=>{ if (knobLeft) knobLeft.style.transform = ''; }, 450); }
  if (knobRight) { knobRight.style.transition = 'transform 300ms ease'; knobRight.style.transform = `rotate(${(Math.random()*20-10)}deg)`; setTimeout(()=>{ if (knobRight) knobRight.style.transform = ''; }, 450); }
}
function pulseGlow() {
  if (!glowEl) return;
  glowEl.classList.add('pulse');
  setTimeout(()=> glowEl.classList.remove('pulse'), 300);
}
function showUI() {
  if (!radioEl) return;
  clearTimeout(fadeTimer);
  radioEl.classList.add('visible'); radioEl.classList.remove('fade-out');
  uiVisible = true;
  fadeTimer = setTimeout(()=> { radioEl.classList.remove('visible'); radioEl.classList.add('fade-out'); uiVisible = false; }, FADE_TIMEOUT_MS);
}
function hideUIImmediate() {
  if (!radioEl) return;
  radioEl.classList.remove('visible'); radioEl.classList.add('fade-out');
  uiVisible = false;
  clearTimeout(fadeTimer); fadeTimer = null;
}

// setStation triggers playback for that station (unless OFF)
async function setStation(index) {
  if (index < 0 || index >= stations.length) return;
  currentStation = index;
  const s = stations[currentStation];
  if (tickerEl) tickerEl.textContent = s.name || 'OFF';
  if (logoEl) logoEl.src = s.logo || stations[stations.length - 1].logo;
  updateDial(currentStation);
  pulseGlow();
  animateKnobs();

  if (!s.folder) {
    try { mainAudio.pause(); } catch(e){}
    showUI();
    return;
  }
  // start playback loop for this station
  await loadStation(s);
  playNextInStation(currentStation);
  showUI();
}

// cycleStation handler
function cycleStation() {
  currentStation = (currentStation + 1) % stations.length;
  playStatic(()=> {
    setStation(currentStation);
    animateKnobs();
  });
}

// NUI message handling
window.addEventListener('message', (ev) => {
  const d = ev.data || {};
  // verbose log of incoming message
  try { console.log('[la_radio] received message:', JSON.stringify(d, Object.keys(d).sort(), 2)); } catch(e) { console.log('[la_radio] received message:', d); }

  if (d.action === 'toggle' || d.action === 'toggleUI') {
    if (typeof d.show === 'boolean') {
      if (d.show) { playStatic(()=> setStation(currentStation)); } else { try{ mainAudio.pause(); }catch(e){} setStation(stations.length-1); }
    } else {
      if (!uiVisible) { playStatic(()=> setStation(currentStation)); } else { playStatic(()=> { try{ mainAudio.pause(); }catch(e){} setStation(stations.length-1); }); }
    }
  } else if (d.action === 'cycleStation' || d.action === 'station_next') {
    cycleStation();
  } else if (d.action === 'station_prev') {
    currentStation = (currentStation - 1 + stations.length) % stations.length; setStation(currentStation);
  // Defensive guard: ignore redundant hideUI messages when already hidden
if (d.action === 'hideUI') {
  if (!uiVisible) {
    // already hidden — ignore silently
    return;
  }
  // otherwise hide now
  hideUIImmediate();
  return;
}
  } else if (d.action === 'set_station_index' && typeof d.index === 'number') {
    setStation(d.index);
  } else if (d.action === 'set_station_id' && typeof d.id === 'string') {
    const idx = stations.findIndex(s => s.id === d.id);
    if (idx >= 0) setStation(idx);
  } else if (d.action === 'sync_play' && d.url) {
    try { mainAudio.pause(); } catch(e){}
    mainAudio.src = d.url;
    mainAudio.currentTime = Math.max(0, Number(d.position) || 0);
    mainAudio.play().catch(err => {
      logPlayError(err, d.url);
      attemptUnlock(false);
    });
  }
});

// DOM wiring for knobs & preload
document.addEventListener('DOMContentLoaded', () => {
  ensureDomRefs();
  console.log('[la_radio] la_radio UI script loaded (audio-enabled).');
  console.log('[la_radio] #radio found, bounding rect:', radioEl ? radioEl.getBoundingClientRect() : null);

  // Print images for debugging
  if (radioEl) {
    const imgs = Array.from(radioEl.querySelectorAll('img')).map(i => ({ src: i.getAttribute('src'), full: i.src, complete: i.complete, naturalWidth: i.naturalWidth }));
    console.log('[la_radio] radio images:', imgs);
  }

  // knob clicks
  const nextBtn = document.getElementById('knobRight') || document.getElementById('knob-next');
  const prevBtn = document.getElementById('knobLeft')  || document.getElementById('knob-prev');
  if (nextBtn) nextBtn.addEventListener('click', () => { cycleStation(); sfxAudio.src = `${BROADCAST_BASE}/extra/test.ogg`; sfxAudio.play().catch(()=>{}); });
  if (prevBtn) prevBtn.addEventListener('click', () => { currentStation = (currentStation - 1 + stations.length) % stations.length; setStation(currentStation); sfxAudio.src = `${BROADCAST_BASE}/extra/test.ogg`; sfxAudio.play().catch(()=>{}); });

  // Preload current station
  if (stations[currentStation] && !stations[currentStation]._loaded) loadStation(stations[currentStation]).catch(()=>{});
});
