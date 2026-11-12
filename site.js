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
