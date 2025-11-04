/* Los Animales loadscreen: slideshow + forced Noir_Detective.mp3 playback */

const $ = (id) => document.getElementById(id);
const els = {
  primary: $('primary-bar'),
  secondary: $('secondary-bar'),
  secondaryWrap: $('secondary-bar-wrapper'),
  action: $('loading-action'),
  msg: $('server-message'),
  finishWrap: $('finishing-wrapper'),
  finishMsg: $('finishing-message'),
  logLine: $('log-line'),
  logo: $('logo'),

  video: $('background-video'),
  audio: $('background-audio'),          // <audio> element in your HTML
  embed: $('background-embed'),

  audioControls: $('audio-controls'),
  vol: $('audio-volume'),                // <input type="range" id="audio-volume">
  muteBtn: $('audio-mute'),
  muteIcon: $('audio-mute-icon'),
};

// Handover/config from server (optional)
const H = /** @type {any} */ (window.nuiHandover || {});
const CFG = Object.assign({
  imageRate: 7500,
  imageShuffle: false,
  initialAudioVolume: 0.5,
  logo: 1,
  serverMessage: '',
  background: 'image',         // 'image' | 'video' | 'embed'
  embedLink: '',
}, H.config || {});

const PATHS = Object.assign({ images: [], videos: [], logo: undefined }, H.paths || {});
const VARS  = Object.assign({ playerName: '', serverName: '' }, H.vars || {});

const clamp01 = (n) => Math.max(0, Math.min(1, Number(n || 0)));
const tpl = (s,c)=>String(s||'').replace(/\$\{(\w+)\}/g,(_,k)=>c[k]??'');

/* ---------------- Progress / text ---------------- */
function setPrimary(v){
  const val = clamp01(v);
  if (els.primary) els.primary.value = val;
  if (val >= 1 && els.finishWrap) els.finishWrap.style.opacity = '1';
}
function setSecondary(v,t){
  if (!els.secondaryWrap || !els.secondary) return;
  els.secondaryWrap.style.display = '';
  els.secondary.value = clamp01(v);
  if (typeof t === 'string' && els.action) els.action.textContent = t;
}
function setMessage(t){ if (typeof t==='string' && els.msg) els.msg.textContent = t; }
function setFinish(t,l){
  if (typeof t==='string' && els.finishMsg) els.finishMsg.textContent=t;
  if (typeof l==='string' && els.logLine) els.logLine.textContent=l;
}

/* ---------------- Background video/embed (opt-in) ---------------- */
function setBgVideo(src){
  if (!els.video || !els.embed) return;
  if (src){
    els.video.src = src; els.video.style.display='';
    els.embed.removeAttribute('src'); els.embed.style.display='none';
  } else {
    els.video.removeAttribute('src'); els.video.style.display='none';
  }
}
function setBgEmbed(src){
  if (!els.video || !els.embed) return;
  if (src){
    els.embed.src = src; els.embed.style.display='';
    els.video.removeAttribute('src'); els.video.style.display='none';
  } else {
    els.embed.removeAttribute('src'); els.embed.style.display='none';
  }
}

/* ---------------- Slideshow (uses CSS transition on <html>) ---------------- */
let slides = Array.isArray(PATHS.images) && PATHS.images.length
  ? PATHS.images.slice()
  : [
      './assets/images/LS00.png','./assets/images/LS02.png',
      './assets/images/LS03B.png',
    ];

if (CFG.imageShuffle) {
  for (let i=slides.length-1;i>0;i--){
    const j=(Math.random()*(i+1))|0; [slides[i],slides[j]]=[slides[j],slides[i]];
  }
}
const slideMs = Number(CFG.imageRate) || 7500;

function preloadSlides(list){ list.forEach(src => { const i=new Image(); i.src = src; }); }
function applySlide(src){ document.documentElement.style.backgroundImage = `url("${encodeURI(src)}")`; }
function startSlideshow(){
  if (!slides.length) return;
  preloadSlides(slides);
  let idx = 0;
  applySlide(slides[idx]);
  setInterval(()=>{ idx = (idx+1)%slides.length; applySlide(slides[idx]); }, slideMs);
}

/* ---------------- Music: force Noir_Detective.mp3 using <audio> element ---------------- */
function showAudioUI(){ if (els.audioControls) els.audioControls.style.display=''; }
function setVolumeUI(v){
  if (!els.vol) return;
  // reflect on a CSS var (optional if your slider styles use it)
  els.vol.style.setProperty('--value', `${v*100}%`);
  els.vol.value = String(v);
}

async function tryPlayWithRetries(el, attempts=6){
  for (let i=0;i<attempts;i++){
    try { await el.play(); return true; }
    catch {
      await new Promise(r=>setTimeout(r, 250 + i*200));
    }
  }
  return false;
}

function playNoirTrack() {
  if (!els.audio) return;

  const src = './assets/music/Noir_Detective.mp3'; // relative to html/
  els.audio.src = encodeURI(src);
  els.audio.load();
  els.audio.loop = true;
  els.audio.muted = false; // CEF allows autoplay; if blocked we'll unlock below

  const vol = clamp01(CFG.initialAudioVolume ?? 0.5);
  els.audio.volume = vol;
  setVolumeUI(vol);

  tryPlayWithRetries(els.audio).then(ok=>{
    if (!ok){
      // Browser preview may block; NUI usually won’t. Unlock on first gesture.
      const unlock = () => {
        tryPlayWithRetries(els.audio);
        window.removeEventListener('pointerdown', unlock);
        window.removeEventListener('keydown', unlock);
      };
      window.addEventListener('pointerdown', unlock, { once:true });
      window.addEventListener('keydown', unlock, { once:true });
    }
  });
}

function bindAudioUI(){
  if (els.vol){
    els.vol.addEventListener('input', (e)=>{
      const v = clamp01(e.target.value);
      if (els.audio) els.audio.volume = v;
      setVolumeUI(v);
    });
  }
  if (els.muteBtn){
    els.muteBtn.addEventListener('click', ()=>{
      if (!els.audio) return;
      els.audio.muted = !els.audio.muted;
      if (els.muteIcon){
        els.muteIcon.src = els.audio.muted ? './assets/icons/no_sound.svg' : './assets/icons/volume_up.svg';
      }
    });
  }

  // Helpful logs
  if (els.audio){
    els.audio.addEventListener('play', ()=>console.log('[LS] audio playing:', els.audio.currentSrc));
    els.audio.addEventListener('error', (e)=>console.log('[LS] audio error', e, 'src=', els.audio.currentSrc));
  }
}

/* ---------------- Optional NUI messages ---------------- */
window.addEventListener('message', (e)=>{
  const d=e.data||{};
  switch(d.type){
    case 'primary': setPrimary(d.value); break;
    case 'secondary': setSecondary(d.value, d.text); break;
    case 'message': setMessage(d.text); break;
    case 'finish': setFinish(d.title, d.line); break;
    case 'bgVideo': setBgVideo(d.src); break;
    case 'bgEmbed': setBgEmbed(d.src); break;
    default: break;
  }
});

/* ---------------- init ---------------- */
(function init(){
  // Header text & logo
  if (CFG.logo && PATHS.logo && els.logo){ els.logo.src = PATHS.logo; els.logo.style.display=''; }
  if (CFG.serverMessage) setMessage(tpl(CFG.serverMessage, VARS));

  // Background: default to image slideshow
  const mode = String(CFG.background || 'image').toLowerCase();
  if (mode === 'video' && PATHS.videos?.length) setBgVideo(PATHS.videos[0]);
  else if (mode === 'embed' && CFG.embedLink) setBgEmbed(CFG.embedLink);
  else { setBgVideo(null); setBgEmbed(null); startSlideshow(); }

  // Music: always show controls; play Noir_Detective
  showAudioUI();
  bindAudioUI();
  playNoirTrack();

  // Browser preview progress (NUI won’t set invokeNative in real runtime)
  if (!('invokeNative' in window) && els.primary && els.secondary){
    let p=0; const t=setInterval(()=>{
      p+=0.02;
      setPrimary(p);
      setSecondary((p%0.25)*4, 'Developing negatives…');
      if(p>=1) clearInterval(t);
    }, 150);
  }
})();
