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
