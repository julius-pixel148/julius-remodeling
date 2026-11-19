/* Shared by every page. Edit your business details here once; all pages update. */
/* ===== EDIT YOUR DETAILS HERE ===== */
var CONFIG = {
  phone: "(425) 699-9636",
  email: "ask@juliusremodeling.com",
  license: "JULIURG780NJ",
  insurance: "Licensed, insured & bonded",
  hours: "Mon–Fri 9am–5pm · Sun 10am–3pm",
  address: "800 Bellevue Way NE, Suite 500, Bellevue, WA 98004"
};
/* ================================== */
(function(){
  // Fill details
  document.querySelectorAll('[data-k]').forEach(function(el){
    var v = CONFIG[el.getAttribute('data-k')];
    if (v) el.textContent = v; else el.classList.add('ph-mark');
  });
  if (CONFIG.email) document.querySelectorAll("[data-mail]").forEach(function(a){ a.href = "mailto:" + CONFIG.email; });
  if (CONFIG.phone) {
    var digits = CONFIG.phone.replace(/[^\d+]/g, '');
    document.querySelectorAll('[data-tel]').forEach(function(a){ a.href = 'tel:' + digits; });
  }

  // Header turns solid after the hero headline
  var hdr = document.getElementById('hdr');
  function onScroll(){ hdr.classList.toggle('solid', window.scrollY > 40); }
  onScroll(); window.addEventListener('scroll', onScroll, {passive:true});

  // Mobile menu: the button in the header opens the page list; Services and Areas expand on tap
  var burger = hdr.querySelector(".burger"), small = window.matchMedia("(max-width:1140px)");
  function setMenu(open){
    hdr.classList.toggle("open", open);
    document.documentElement.classList.toggle("menu-open", open);
    burger.setAttribute("aria-expanded", open ? "true" : "false");
    burger.setAttribute("aria-label", open ? "Close menu" : "Menu");
    // While the menu covers the page, keep keyboard and screen-reader focus out of the content behind it
    document.querySelectorAll("main, footer").forEach(function(el){ el.inert = open; });
  }
  if (burger) {
    burger.addEventListener("click", function(){ setMenu(!hdr.classList.contains("open")); });
    hdr.querySelectorAll(".menu a").forEach(function(a){
      a.addEventListener("click", function(e){
        var dd = a.parentNode;
        if (small.matches && dd.classList.contains("dd")) { e.preventDefault(); a.setAttribute("aria-expanded", dd.classList.toggle("open") ? "true" : "false"); return; }
        setMenu(false);
      });
    });
    document.addEventListener("keydown", function(e){
      if (e.key !== "Escape") return;
      if (hdr.classList.contains("open")) { setMenu(false); burger.focus(); }
      else if (document.activeElement && document.activeElement.closest(".dd")) document.activeElement.blur(); // closes a desktop dropdown
    });
    window.addEventListener("resize", function(){ if (!small.matches) setMenu(false); });
  }

  // Tell screen-reader users when a link opens a new tab
  document.querySelectorAll("a[target=_blank]").forEach(function(a){
    var s = document.createElement("span"); s.className = "sr-only"; s.textContent = " (opens in a new tab)"; a.appendChild(s);
  });

  // Offer pages: "Claim this discount" buttons open that page's form in a pop-up
  var claim = document.getElementById("claim");
  if (claim && claim.showModal) {
    document.querySelectorAll("[data-claim]").forEach(function(b){
      b.addEventListener("click", function(e){
        e.preventDefault(); claim.showModal();
        // Load the form the first time the pop-up opens, so GoHighLevel's script can size it while it is visible
        var f = claim.querySelector("iframe[data-src]");
        if (f) {
          f.src = f.getAttribute("data-src"); f.removeAttribute("data-src");
          var s = document.createElement("script"); s.src = "https://link.msgsndr.com/js/form_embed.js"; document.body.appendChild(s);
        }
      });
    });
    claim.querySelector(".x").addEventListener("click", function(){ claim.close(); });
    claim.addEventListener("click", function(e){ if (e.target === claim) claim.close(); }); // click outside the box
  }

  // Newsletter sample form (shown only until the real GoHighLevel form is connected): never submits
  document.querySelectorAll("form[data-example]").forEach(function(f){
    f.addEventListener("submit", function(e){
      e.preventDefault();
      var n = f.querySelector(".nl-note");
      if (n) { n.textContent = "Example only. Nothing was sent: this form is not connected yet."; n.scrollIntoView({block: "nearest"}); }
    });
  });

  // "Copy" buttons next to phone / email
  document.querySelectorAll('[data-copy]').forEach(function(b){
    b.addEventListener('click', function(){
      var v = CONFIG[b.getAttribute('data-copy')], t = b.textContent;
      if (!v) return;
      var ok = function(){ b.textContent = 'Copied'; setTimeout(function(){ b.textContent = t; }, 1600); };
      try { navigator.clipboard.writeText(v).then(ok, function(){}); } catch(e){}
    });
  });
})();

/* ===== Motion: reveal blocks as they scroll into view, and count up the big numbers ===== */
(function(){
  if (!("IntersectionObserver" in window) || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
  var sel = [".head", ".why-t", ".proj", ".card", ".goal", ".area-card", ".vend-card", ".promo-card", ".fin-card", ".opt",
    ".stage", ".worry", ".ba", ".stats > div", ".about .ph", ".about .txt", ".refresh-copy", ".refresh-ba figure",
    ".gal figure", ".incl > *", ".rel a", ".callout", ".quote", ".yt-frame", ".ig-grid a", ".cta-band .wrap", "main details"].join(",");
  var fold = window.innerHeight * 0.92;
  var io = new IntersectionObserver(function(es){
    es.forEach(function(e){
      if (!e.isIntersecting) return;
      var el = e.target; el.classList.add("in"); io.unobserve(el);
      // Once it has finished appearing, hand it back to its normal hover effects
      setTimeout(function(){ el.classList.remove("rv", "in"); el.style.removeProperty("--d"); }, 1700 + parseFloat(el.style.getPropertyValue("--d") || 0) * 1000);
    });
  }, {rootMargin: "0px 0px -8% 0px", threshold: 0.08});
  document.querySelectorAll(sel).forEach(function(el){
    if (el.closest(".hero, .page-top, .rv, .upg, .gw-terms") || el.getBoundingClientRect().top < fold) return; // leave what's already on screen alone
    // Items in the same row come in one after another
    var i = 0, s = el.previousElementSibling;
    while (s && i < 6) { if (s.className === el.className) i++; else break; s = s.previousElementSibling; }
    el.style.setProperty("--d", (i * 0.09) + "s");
    el.classList.add("rv"); io.observe(el);
  });
  // Count-up numbers ("1,500+", "4.98★", "15+")
  var co = new IntersectionObserver(function(es){
    es.forEach(function(e){
      if (!e.isIntersecting) return; co.unobserve(e.target);
      var t = e.target.firstChild, raw = t.nodeValue, end = parseFloat(raw.replace(/,/g, "")),
          dec = (raw.split(".")[1] || "").length, comma = raw.indexOf(",") > -1, t0 = null;
      function fmt(v){ var s = v.toFixed(dec); return comma ? Number(s).toLocaleString("en-US", {minimumFractionDigits: dec}) : s; }
      function step(ts){
        if (!t0) t0 = ts; var p = Math.min((ts - t0) / 1600, 1);
        t.nodeValue = p < 1 ? fmt(end * (1 - Math.pow(1 - p, 3))) : raw;
        if (p < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
    });
  }, {threshold: 0.4});
  document.querySelectorAll(".stats b").forEach(function(b){
    var t = b.firstChild;
    if (t && t.nodeType === 3 && /^[\d.,]+$/.test(t.nodeValue.trim())) co.observe(b);
  });
})();

/* ===== Background music =====
   Browsers never allow a website to start sound by itself, so the music starts on the visitor's
   first tap or click anywhere on the page. The round button in the bottom-left corner mutes or
   plays it, and the site remembers that choice on every page.
   To turn music off for the whole site, set MUSIC_ON to false. To only play when a visitor presses
   the button (never on their first tap), set START_ON_FIRST_TAP to false. */
(function(){
  var MUSIC_ON = true, START_ON_FIRST_TAP = true, VOLUME = 0.35;
  var SRC = "assets/music/julius-build-with-pride.mp3";
  if (!MUSIC_ON || !window.Audio) return;
  function get(k, s){ try { return (s ? sessionStorage : localStorage).getItem(k); } catch(e){ return null; } }
  function put(k, v, s){ try { (s ? sessionStorage : localStorage).setItem(k, v); } catch(e){} }
  var a = new Audio(), playing = false, timer, resumeAt = parseFloat(get("jr-music-t", 1)) || 0;
  a.src = SRC; a.loop = true; a.preload = "none"; a.volume = 0;
  a.addEventListener("loadedmetadata", function(){ if (resumeAt) { try { a.currentTime = resumeAt % (a.duration || 1e9); } catch(e){} resumeAt = 0; } });
  var b = document.createElement("button");
  b.type = "button"; b.className = "music";
  b.innerHTML = '<span class="mi" aria-hidden="true"><svg viewBox="0 0 24 24" width="22" height="22"><path class="nt" d="M9.2 17.6V7.1l10.3-2.6v10.4" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linejoin="round"/><path class="nt" d="M9.2 7.1l10.3-2.6v2.9L9.2 10z" fill="currentColor"/><ellipse class="nt" cx="6.6" cy="17.7" rx="2.9" ry="2.3" fill="currentColor"/><ellipse class="nt" cx="16.9" cy="15" rx="2.9" ry="2.3" fill="currentColor"/><line class="sl" x1="3.5" y1="3.5" x2="20.5" y2="20.5" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/></svg></span><span class="music-t">Music</span><span class="music-tip" aria-hidden="true">Tap to mute</span>';
  a.addEventListener("error", function(){ b.remove(); }); // file missing: hide the button
  document.body.appendChild(b);
  function ui(){
    b.classList.toggle("on", playing);
    b.setAttribute("aria-pressed", playing ? "true" : "false");
    b.setAttribute("aria-label", playing ? "Mute music" : "Play music");
    b.querySelector(".music-t").textContent = playing ? "Mute" : "Play music";
  }
  function fade(to){ // gentle fade in / out (iPhones ignore volume, so it just starts and stops)
    clearInterval(timer);
    var from = a.volume, n = 0, steps = 16;
    timer = setInterval(function(){
      n++; try { a.volume = Math.max(0, Math.min(1, from + (to - from) * n / steps)); } catch(e){}
      if (n >= steps) { clearInterval(timer); if (to === 0) a.pause(); }
    }, 40);
  }
  function play(){
    playing = true; ui();
    var p = a.play();
    if (p && p.catch) p.catch(function(){ playing = false; ui(); waitForTap(); });
    fade(VOLUME);
  }
  function stop(){ playing = false; ui(); fade(0); }
  function waitForTap(){
    function go(e){
      if (e.target.closest && e.target.closest(".music")) return; // the button handles its own click
      off(); if (get("jr-music") !== "off") { play(); b.classList.add("tip"); setTimeout(function(){ b.classList.remove("tip"); }, 4000); }
    }
    function off(){ document.removeEventListener("pointerdown", go, true); document.removeEventListener("keydown", go, true); }
    document.addEventListener("pointerdown", go, true); document.addEventListener("keydown", go, true);
  }
  b.addEventListener("click", function(){
    b.classList.remove("tip");
    if (playing) { stop(); put("jr-music", "off"); } else { put("jr-music", "on"); play(); }
  });
  // Keep the song going from the same spot when the visitor opens another page
  window.addEventListener("pagehide", function(){ if (playing) put("jr-music-t", String(a.currentTime), 1); else put("jr-music-t", "0", 1); });
  ui();
  var pref = get("jr-music");
  if (pref === "on") play();                       // chose music before: try to continue right away
  else if (pref !== "off" && START_ON_FIRST_TAP) waitForTap();
})();

/* ===== 24/7 phone line: label every Call button and explain the AI receptionist =====
   To remove the labels, set PHONE_247 to false. */
(function(){
  var PHONE_247 = true;
  var NOTE = "Answered 24/7 by our AI receptionist. It can answer your questions and take down your project details any time, day or night, and our team follows up.";
  if (!PHONE_247) return;
  var tip = "Answered 24/7 by our AI receptionist";
  // Small "24/7" tag on the Call buttons (hero, contact, bottom bar)
  document.querySelectorAll("a.btn[data-tel], .mbar .f-call").forEach(function(a){
    var s = document.createElement("span"); s.className = "b247"; s.textContent = "24/7"; s.title = tip;
    a.appendChild(s); a.setAttribute("title", tip);
  });
  // A line under the phone number on the contact card
  document.querySelectorAll(".card .v[data-tel]").forEach(function(v){
    var p = document.createElement("p"); p.className = "n247";
    p.innerHTML = '<span class="b247">24/7</span> ' + NOTE;
    v.parentNode.appendChild(p);
  });
  // Footer: "24/7" after the phone number
  document.querySelectorAll("footer li > a[data-tel]").forEach(function(a){
    var s = document.createElement("span"); s.className = "b247 sm"; s.textContent = "24/7"; s.title = tip;
    a.parentNode.appendChild(document.createTextNode(" ")); a.parentNode.appendChild(s);
  });
})();

/* ===== Monthly giveaway: days left, and the "Refer a friend" pop-up ===== */
(function(){
  var gw = document.querySelector(".gw[data-ends]");
  if (gw) {
    var end = new Date(gw.getAttribute("data-ends")), left = gw.querySelector(".gw-left");
    var days = Math.ceil((end - new Date()) / 864e5);
    if (left) {
      if (isNaN(days)) {}
      else if (days <= 0) { left.textContent = "This giveaway has ended"; gw.classList.add("ended"); left.hidden = false; }
      else { left.textContent = days === 1 ? "Last day" : days + " days left"; left.hidden = false; }
    }
  }
  var dlg = document.getElementById("refer");
  if (!dlg || !dlg.showModal) return;
  document.querySelectorAll("[data-refer]").forEach(function(b){
    b.addEventListener("click", function(e){
      e.preventDefault(); dlg.showModal();
      var f = dlg.querySelector("iframe[data-src]"); // GoHighLevel referral form, if one is connected
      if (f) { f.src = f.getAttribute("data-src"); f.removeAttribute("data-src"); var s = document.createElement("script"); s.src = "https://link.msgsndr.com/js/form_embed.js"; document.body.appendChild(s); }
    });
  });
  dlg.querySelector(".x").addEventListener("click", function(){ dlg.close(); });
  dlg.addEventListener("click", function(e){ if (e.target === dlg) dlg.close(); });
  // Built-in referral form: opens the visitor's email app with everything filled in
  var form = dlg.querySelector(".ref-form");
  if (!form) return;
  form.addEventListener("submit", function(e){
    e.preventDefault();
    var err = form.querySelector(".ref-err"), note = form.querySelector(".ref-note");
    if (!form.checkValidity()) { err.hidden = false; var bad = form.querySelector(":invalid"); if (bad) bad.focus(); return; }
    err.hidden = true;
    var lines = [];
    form.querySelectorAll("input:not([type=checkbox]), select").forEach(function(el){ lines.push(el.name + ": " + (el.value || "-")); });
    lines.push("Friend agreed to be contacted: Yes");
    var to = CONFIG.email || "", subject = "Referral: " + (form.querySelector("#rf-fname").value || "new customer");
    var body = "New referral from the website giveaway page.\n\n" + lines.join("\n");
    window.location.href = "mailto:" + to + "?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body);
    note.innerHTML = "Your email app should open with the referral ready. Just press <b>Send</b>. Nothing opened? Call or text us at <a href=\"tel:" + (CONFIG.phone || "").replace(/[^\d+]/g, "") + "\">" + CONFIG.phone + "</a> or email <a href=\"mailto:" + to + "\">" + to + "</a>.";
    note.hidden = false;
  });
})();

/* ===== Bathroom upgrades: pick the ones you like, then send them with the consultation request ===== */
(function(){
  var cards = document.querySelectorAll(".upg[data-upg]");
  if (!cards.length) return;
  var sec = document.querySelector(".upgs"), kind = sec.getAttribute("data-kind") || "Bathroom";
  var KEY = "jr-upgrades-" + kind.toLowerCase(), picked = [];
  try { picked = JSON.parse(sessionStorage.getItem(KEY) || "[]"); } catch(e){}
  var list = document.querySelector(".upg-list"), sends = document.querySelectorAll(".upg-send");
  function names(){ return picked.map(function(id){ var c = document.querySelector('.upg[data-upg="' + id + '"]'); return c ? c.getAttribute("data-name") : null; }).filter(Boolean); }
  function update(){
    cards.forEach(function(c){
      var on = picked.indexOf(c.getAttribute("data-upg")) > -1, b = c.querySelector(".upg-pick");
      c.classList.toggle("on", on); b.setAttribute("aria-pressed", on ? "true" : "false");
      b.querySelector(".t").textContent = on ? sec.getAttribute("data-picked") : sec.getAttribute("data-pick");
    });
    var n = names();
    if (list) list.innerHTML = n.length ? n.length + " selected: " + n.map(function(t){ return '<span class="chipx">' + t.replace(/&/g, "&amp;").replace(/</g, "&lt;") + "</span>"; }).join("") : sec.getAttribute("data-none");
    var href = n.length ? "consultation.html?type=" + kind + "&upgrades=" + encodeURIComponent(n.join("; ")) : "consultation.html";
    sends.forEach(function(a){ a.href = href; var t = a.firstChild; if (t && t.nodeType === 3) t.nodeValue = n.length ? sec.getAttribute("data-send") + " " : "Book a free consultation "; });
    try { sessionStorage.setItem(KEY, JSON.stringify(picked)); } catch(e){}
  }
  cards.forEach(function(c){
    c.querySelector(".upg-pick").addEventListener("click", function(){
      var id = c.getAttribute("data-upg"), i = picked.indexOf(id);
      if (i > -1) picked.splice(i, 1); else picked.push(id);
      update();
    });
  });
  update();
})();

/* ===== Consultation page: show the upgrades picked on the bathroom page and pass them to the form =====
   In GoHighLevel, give a form field the query key "upgrades" and it fills in automatically. */
(function(){
  var q, type; try { var sp = new URLSearchParams(location.search); q = sp.get("upgrades"); type = (sp.get("type") || "Bathroom").replace(/[^A-Za-z ]/g, ""); } catch(e){ return; }
  var frame = document.querySelector(".form-card iframe");
  if (!q || !frame) return;
  var items = q.split(/;\s*/).filter(Boolean);
  var box = document.createElement("div"); box.className = "upg-box";
  box.innerHTML = '<span class="mono">' + type + ' upgrades you\'re interested in</span><ul></ul><p>Please mention these in the message box below so we can prepare for your consultation.</p><button type="button">Copy list</button>';
  var ul = box.querySelector("ul");
  items.forEach(function(t){ var li = document.createElement("li"); li.textContent = t; ul.appendChild(li); });
  box.querySelector("button").addEventListener("click", function(){
    var b = this, text = type + " upgrades I'm interested in: " + items.join(", ");
    try { navigator.clipboard.writeText(text).then(function(){ b.textContent = "Copied"; setTimeout(function(){ b.textContent = "Copy list"; }, 1600); }); } catch(e){}
  });
  frame.parentNode.insertBefore(box, frame);
  try { var u = new URL(frame.src); u.searchParams.set("upgrades", type + ": " + items.join(", ")); frame.src = u.toString(); } catch(e){}
})();
