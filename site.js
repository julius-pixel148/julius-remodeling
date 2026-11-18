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
    if (el.closest(".hero, .page-top, .rv") || el.getBoundingClientRect().top < fold) return; // leave what's already on screen alone
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
