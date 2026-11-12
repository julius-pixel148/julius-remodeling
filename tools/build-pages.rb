# Builds every service page, every city page, and service-areas.html, and refreshes the shared header + footer on the
# hand-written pages (index.html, condo-remodeling.html, consultation.html).
#
#   ruby tools/build-pages.rb .
#
# To change a service page, edit its entry in PAGES below and run the command again.
ROOT = ARGV[0] || "."

# ---------------------------------------------------------------- navigation
REMODELING = [
  { slug: "kitchen-remodeling",    name: "Kitchen remodeling" },
  { slug: "bathroom-remodeling",   name: "Bathroom remodeling" },
  { slug: "basement-remodeling",   name: "Basement remodeling" },
  { slug: "whole-home-remodeling", name: "Whole-home remodeling" },
  { slug: "condo-remodeling",      name: "Condos &amp; apartments" },
]
SPECIALTY = [
  { slug: "flooring-installation",      name: "Flooring" },
  { slug: "interior-finish-carpentry",  name: "Interior finish &amp; carpentry" },
  { slug: "door-replacement",           name: "Doors" },
  { slug: "window-replacement",         name: "Windows" },
  { slug: "stairs-and-railings",        name: "Stairs &amp; railings" },
  { slug: "concrete-work",              name: "Concrete" },
  { slug: "drywall-repair",             name: "Drywall repair" },
]
ALL = REMODELING + SPECIALTY
# City pages. Add or remove a city here and in CITY_PAGES (further down), then rebuild.
AREAS = [
  { slug: "remodeling-seattle-wa",       name: "Seattle" },
  { slug: "remodeling-bellevue-wa",      name: "Bellevue" },
  { slug: "remodeling-mercer-island-wa", name: "Mercer Island" },
  { slug: "remodeling-kirkland-wa",      name: "Kirkland" },
  { slug: "remodeling-redmond-wa",       name: "Redmond" },
  { slug: "remodeling-sammamish-wa",     name: "Sammamish" },
  { slug: "remodeling-issaquah-wa",      name: "Issaquah" },
  { slug: "remodeling-bothell-wa",       name: "Bothell" },
  { slug: "remodeling-renton-wa",        name: "Renton" },
  { slug: "remodeling-shoreline-wa",     name: "Shoreline" },
]
LICENSE_URL = "https://secure.lni.wa.gov/verify/Detail.aspx?UBI=604945953&amp;LIC=JULIURG780NJ&amp;SAW="

def links(list, current)
  list.map { |s| %(<a href="#{s[:slug]}.html"#{s[:slug] == current ? ' aria-current="page"' : ''}>#{s[:name]}</a>) }.join
end

def header(current, home: false)
  p = home ? "" : "index.html"
  svc_cur = ALL.any? { |s| s[:slug] == current } ? ' aria-current="page"' : ""
  area_cur = (current == "service-areas" || AREAS.any? { |s| s[:slug] == current }) ? ' aria-current="page"' : ""
  cta = current == "consultation" ?
    %(<a href="tel:" data-tel class="btn btn-brass">Call <span data-k="phone">[Phone]</span></a>) :
    %(<a href="consultation.html" class="btn btn-brass">Free consultation <span class="ar" aria-hidden="true">→</span></a>)
  promo_cur = (current == "promotions" || current.to_s.end_with?("-offer")) ? ' aria-current="page"' : ""
  <<~HTML.chomp
    <header class="top#{current == 'consultation' ? ' solid' : ''}" id="hdr">
      <div class="wrap">
        <a href="#{home ? '#top' : 'index.html'}" class="logo" aria-label="Julius Remodeling Group, home"><img src="assets/wordmark.png" width="560" height="189" alt="Julius Remodeling Group"></a>
        <nav class="menu" id="nav" aria-label="Main">
          <a href="#{p}#work">Projects</a>
          <div class="dd"><a href="#{p}#services"#{svc_cur}>Services</a><div class="dd-panel two"><div><span class="mono">Remodeling</span>#{links(REMODELING, current)}</div><div><span class="mono">Specialty &amp; repairs</span>#{links(SPECIALTY, current)}</div></div></div>
          <div class="dd"><a href="service-areas.html"#{area_cur}>Areas</a><div class="dd-panel areas">#{links(AREAS, current)}<a href="service-areas.html">All service areas</a></div></div>
          <a href="promotions.html"#{promo_cur}>Promotions</a>
          <a href="#{p}#about">About</a><a href="#{p}#reviews">Reviews</a><a href="#{p}#contact">Contact</a>
        </nav>
        #{cta}
        <button class="burger" type="button" aria-label="Menu" aria-expanded="false" aria-controls="nav"><span></span><span></span><span></span></button>
      </div>
    </header>
  HTML
end

def footer(home: false)
  p = home ? "" : "index.html"
  li = ->(list) { list.map { |s| %(<li><a href="#{s[:slug]}.html">#{s[:name]}</a></li>) }.join }
  <<~HTML.chomp
    <footer class="dark">
      <div class="wrap">
        <div class="fgrid">
          <div><p class="tag">Transforming homes. <em>Elevating lives.</em></p><p class="sub">Remodeling for single-family homes, condos, and apartments across Seattle and the Eastside.</p></div>
          <div><h4 class="mono">Remodeling</h4><ul>#{li.(REMODELING)}</ul></div>
          <div><h4 class="mono">Specialty &amp; repairs</h4><ul>#{li.(SPECIALTY)}</ul></div>
          <div><h4 class="mono"><a href="service-areas.html">Service areas</a></h4><ul>#{li.(AREAS)}</ul></div>
          <div><h4 class="mono">Contact</h4><ul><li><a href="tel:" data-tel data-k="phone">[Phone]</a></li><li><a href="mailto:ask@juliusremodeling.com" data-mail data-k="email">ask@juliusremodeling.com</a></li><li data-k="hours">[Business hours]</li><li data-k="address">[Address]</li><li><a href="#{LICENSE_URL}" target="_blank" rel="noopener">WA License <span data-k="license">[License #]</span> ↗</a></li><li data-k="insurance">[Insurance details]</li><li><a href="https://www.youtube.com/@Juliusremodelinggroup" target="_blank" rel="noopener">YouTube ↗</a></li></ul></div>
        </div>
        <div class="legal mono"><span>© 2026 Julius Remodeling Group</span><span class="flinks"><a href="promotions.html">Promotions</a><a href="terms-and-conditions.html">Terms &amp; Conditions</a><a href="privacy-policy.html">Privacy Policy</a></span><span>Bellevue, WA · Serving Seattle &amp; the Eastside</span></div>
      </div>
    </footer>
  HTML
end

# ---------------------------------------------------------------- shared bits
# Photos shown on the site live in assets/photos/ (web-sized copies). The originals stay in assets/work/, which is not uploaded.
PHOTOS = {
  "bath-1"  => { src: "assets/photos/bath-1.jpg", w: 947, h: 1400, tag: "Bathroom", title: "Sage &amp; brass bathroom", sub: "Custom tile, recessed niches, brass fixtures, new vanity",
                 alt: "Remodeled bathroom with sage subway tile, brass-framed glass shower doors, floral wallpaper, and a white vanity with brass pulls" },
  "bath-2"  => { src: "assets/photos/bath-2.jpg", w: 768, h: 1024, tag: "Bathroom", title: "Walk-in shower remodel", sub: "Marble-look tile, pebble floor, frameless glass, full waterproofing",
                 alt: "Walk-in shower with large marble-look tile, pebble floor, frameless glass, and matte black fixtures beside a floating vanity" },
  "kitchen-1" => { src: "assets/photos/kitchen-1.jpg", w: 1320, h: 863, land: true, tag: "Kitchen", title: "Gray shaker &amp; brass kitchen", sub: "Shaker cabinets, quartz counters, farmhouse sink, gas range, LVP flooring",
                 alt: "Remodeled kitchen with gray shaker cabinets, brass pulls, white quartz countertops, a farmhouse sink with a brass faucet, and a stainless gas range" },
  "kitchen-2" => { src: "assets/photos/kitchen-2.jpg", w: 1320, h: 860, land: true, tag: "Kitchen", title: "Peninsula &amp; coffee bar", sub: "Quartz peninsula, open shelving, tile backsplash, recessed lighting",
                 alt: "Kitchen with a white quartz peninsula and brass pull-down faucet, a built-in coffee bar with floating shelves, and gray shaker cabinets" },
  "kitchen-3" => { src: "assets/photos/kitchen-3.jpg", w: 1293, h: 875, land: true, tag: "Kitchen", title: "Open-concept kitchen &amp; living", sub: "Open layout, new peninsula, recessed lighting, flooring throughout",
                 alt: "Open-concept kitchen and living room with gray shaker cabinets, a white peninsula, recessed lights, and gray wood-look flooring" },
  "bath-wetroom" => { src: "assets/photos/bath-wetroom.jpg", w: 1320, h: 990, land: true, tag: "Bathroom", title: "Japanese-style wet room", sub: "Soaking tub inside the shower, large-format tile, brass fixtures, skylight, mosaic floor",
                 alt: "Japanese-style wet room with a freestanding soaking tub inside a walk-in shower, large white tile, brass rain head and hand shower, tiled niches, and a hex mosaic floor" },
  "bath-guest" => { src: "assets/photos/bath-guest.jpg", w: 1320, h: 1971, tag: "Bathroom", title: "Guest bathroom", sub: "Tiled tub-shower with niche, wood vanity with quartz top, hex floor tile",
                 alt: "Guest bathroom with a natural wood vanity and quartz top, matte black fixtures, a tub-shower with large gray tile and a niche, and white hexagon floor tile" },
  "laundry" => { src: "assets/photos/laundry.jpg", w: 1290, h: 1900, tag: "Laundry room", title: "Laundry room build-out", sub: "Custom cabinetry, tile backsplash, new lighting and flooring",
                 alt: "Laundry room with stacked washer and dryer, white custom cabinetry with brass pulls, and a burgundy tile backsplash" },
  # --- added November 2026 (files keep their camera names) ---
  "kitchen-wood" => { src: "assets/photos/IMG_2879.jpg", w: 1320, h: 985, land: true, tag: "Kitchen", title: "Warm wood kitchen with waterfall island", sub: "Flat-panel wood cabinets, quartz waterfall island, open shelving, exposed beams, wood flooring",
                 alt: "Open kitchen with flat-panel natural wood cabinets, a white quartz waterfall island with a black faucet, open shelves, exposed ceiling beams, and light wood flooring" },
  "kitchen-dark" => { src: "assets/photos/IMG_2906.jpg", w: 1320, h: 865, land: true, tag: "Kitchen", title: "Dark wood &amp; stone kitchen", sub: "Dark wood cabinets, stone waterfall island with seating, pendant lighting, stainless appliances",
                 alt: "Kitchen with dark wood cabinets, a stone waterfall island with four stools, pendant lights, a stainless refrigerator, and high windows above the cabinets" },
  "kitchen-dark-2" => { src: "assets/photos/IMG_2907.jpg", w: 1320, h: 865, land: true, tag: "Kitchen", title: "Island seating for four", sub: "Stone island and backsplash, built-in microwave, tall pantry cabinets, high windows",
                 alt: "Dark wood kitchen seen from the living room, with a stone island and four stools, three pendant lights, a built-in microwave, and a row of high windows" },
  "kitchen-open" => { src: "assets/photos/IMG_2905.jpg", w: 1320, h: 874, land: true, tag: "Kitchen &amp; living", title: "Open kitchen &amp; living room", sub: "Kitchen open to the living area, stone island, pendant and recessed lighting, wood flooring",
                 alt: "Open kitchen and living area with dark wood cabinets, a stone island with stools, pendant lights, recessed lighting, and light wood flooring" },
  "bath-white" => { src: "assets/photos/IMG_2870.jpg", w: 1320, h: 877, land: true, tag: "Bathroom", title: "Black &amp; white bathroom", sub: "Stacked white tile shower with niche, sliding glass door, vessel sink vanity, matte black fixtures",
                 alt: "Bathroom with a walk-in shower in stacked white tile, a sliding glass door on a black rail, a white vanity with a vessel sink and black faucet, and gray floor tile" },
  "bath-shower" => { src: "assets/photos/IMG_2901.jpg", w: 1320, h: 1756, tag: "Bathroom", title: "Large-format tile shower", sub: "Floor-to-ceiling stone-look tile, rain head, body sprays, recessed niche, mosaic floor",
                 alt: "Walk-in shower with floor-to-ceiling beige stone-look tile, a black rain shower head, body sprays and hand shower, a recessed niche, a window, and a mosaic tile floor" },
  "bath-warm" => { src: "assets/photos/IMG_2902.jpg", w: 1320, h: 978, land: true, tag: "Bathroom", title: "Warm tile shower bathroom", sub: "Tiled shower with niche and frameless glass, white vanity with quartz top, matte black fixtures",
                 alt: "Bathroom with a shower in warm beige square tile, frameless glass, a mosaic floor, a white vanity with a quartz top, and matte black faucets and hardware" },
  "bath-green" => { src: "assets/photos/IMG_2904.jpg", w: 1320, h: 972, land: true, tag: "Bathroom", title: "Sage green tub bathroom", sub: "Soaking tub with wood-look tile surround, long quartz vanity, matte black fixtures",
                 alt: "Bathroom with sage green walls, a white tub with a wood-look tile surround, a long white quartz vanity with a black faucet, and light floor tile" },
  "floor-great" => { src: "assets/photos/IMG_2880.jpg", w: 1320, h: 977, land: true, tag: "Flooring", title: "Wood flooring, great room", sub: "Wide-plank wood flooring through the main living area, new baseboards and trim",
                 alt: "Large open living room with light wide-plank wood flooring, white walls, recessed lights, and a dark built-in mudroom bench by the door" },
  "floor-plank" => { src: "assets/photos/IMG_2869.jpg", w: 1320, h: 866, land: true, tag: "Flooring", title: "Wood-look plank flooring", sub: "Gray wood-look plank flooring, new baseboards, closet doors, fresh paint",
                 alt: "Bedroom with gray wood-look plank flooring, white baseboards and closet doors, and an open door to a tiled bathroom" },
  "floor-bedroom" => { src: "assets/photos/IMG_2885.jpg", w: 1320, h: 990, land: true, tag: "Flooring", title: "Bedroom wood flooring", sub: "Wide-plank wood flooring, new baseboards, ceiling fan and lighting",
                 alt: "Bedroom with light wide-plank wood flooring, white walls, two black-framed windows, and a white ceiling fan" },
  "door-barn" => { src: "assets/photos/IMG_2881.jpg", w: 1320, h: 982, land: true, tag: "Doors", title: "Sliding barn door", sub: "Black-framed glass barn door on a top rail, new trim, wood flooring",
                 alt: "Room with a black-framed frosted glass barn door sliding on a top rail, three black-framed windows, a ceiling fan, and light wood flooring" },
  "door-interior" => { src: "assets/photos/IMG_2886.jpg", w: 1320, h: 988, land: true, tag: "Doors", title: "New interior doors", sub: "Five-panel interior doors, matte black hardware, new casing and baseboards",
                 alt: "Bedroom with two white five-panel interior doors with matte black handles, white trim, and light wood flooring" },
  "builtin-mudroom" => { src: "assets/photos/IMG_2882.jpg", w: 1320, h: 987, land: true, tag: "Interior finish", title: "Built-in mudroom bench", sub: "Custom built-in bench and cubbies, arched opening, new trim and baseboards",
                 alt: "Entry with a dark custom built-in mudroom bench and cubbies, an arched opening, and light wood flooring running through to the kitchen" },
  # --- added from the sorted folders in assets/work ---
  "bath-gray-bench" => { src: "assets/photos/bath-gray-bench.jpg", w: 1200, h: 1600, tag: "Bathroom", title: "Walk-in shower with bench", sub: "Gray plank tile, floating bench, pebble mosaic niche, rain head and hand shower",
                 alt: "Walk-in shower with gray plank tile, a tiled floating bench, a pebble mosaic niche, a chrome rain head and hand shower, and a linear drain" },
  "bath-dark-shower" => { src: "assets/photos/bath-dark-shower.jpg", w: 1204, h: 1600, tag: "Bathroom", title: "Steam shower interior", sub: "Charcoal tile to the ceiling, long pebble niche, pebble floor, linear drain, grab bar",
                 alt: "Shower with charcoal tile on the walls and ceiling, a long pebble mosaic niche with a grab bar below it, a pebble floor, and a linear drain" },
  "bath-dark-glass" => { src: "assets/photos/bath-dark-glass.jpg", w: 1204, h: 1600, tag: "Bathroom", title: "Fully enclosed steam shower", sub: "Glass to the ceiling to keep the steam in, steam system, ceiling rain head, heated towel rack",
                 alt: "Steam shower fully enclosed in frameless glass with charcoal tile, a ceiling-mounted rain head, a pebble floor, and a black heated towel rack on the wall beside it" },
  "bath-dark-vanity" => { src: "assets/photos/bath-dark-vanity.jpg", w: 1600, h: 1204, land: true, tag: "Bathroom", title: "Primary bathroom with double vanity", sub: "Wood double vanity with vessel sinks, lit mirror, glass steam shower, heated towel racks, skylight",
                 alt: "Primary bathroom with a wood double vanity and two vessel sinks, a lit mirror, a frameless glass shower in charcoal tile, black heated towel racks, and a skylight" },
  "bath-subway" => { src: "assets/photos/bath-subway-after.jpg", w: 1200, h: 1600, tag: "Bathroom", title: "Tub-to-shower conversion", sub: "White subway tile shower with bench and niche, frameless glass, matte black fixtures",
                 alt: "Bathroom after a tub-to-shower conversion: a walk-in shower in white subway tile with a bench, a black niche and fixtures, a white vanity with a granite top, and dark floor tile" },
  "bath-freestanding" => { src: "assets/photos/bath-freestanding.jpg", w: 1200, h: 1600, tag: "Bathroom", title: "Open shower &amp; freestanding tub", sub: "Curbed open shower beside a freestanding tub, tiled niche, marble-look floor",
                 alt: "Bathroom with an open shower in beige plank tile with a rain head and tiled niche, a marble-look curb and floor, and a white freestanding tub beside it" },
  "bath-clay" => { src: "assets/photos/bath-clay-shower.jpg", w: 1200, h: 1600, tag: "Bathroom", title: "Clay tile shower", sub: "Handmade clay tile on walls and floor, enlarged shower footprint, new valve and rain head",
                 alt: "Shower finished in glossy handmade clay tile in deep brown and amber tones on the walls and floor, with a dark rain head and valve trim" },
  "bath-tub" => { src: "assets/photos/bath-tub-after.jpg", w: 1200, h: 1600, tag: "Bathroom", title: "Tub &amp; tile surround", sub: "New tub, large-format tile surround to the ceiling, recessed niche, new valve",
                 alt: "New white bathtub with a gray marble-look tile surround to the ceiling, a recessed niche, and a brushed shower valve and head" },
  "bath-marble" => { src: "assets/photos/bath-marble-room.jpg", w: 1200, h: 1600, tag: "Bathroom", title: "Marble-look tile bathroom", sub: "Bold marble-look tile shower, mitered niche, tile-in linear drain, frameless glass, skylight",
                 alt: "Bathroom with a frameless glass shower in white marble-look tile with bold black veining, a long black penny-tile niche, a gray shaker vanity with a white top, and a skylight" },
  "bath-pebble" => { src: "assets/photos/bath-pebble-accent.jpg", w: 1200, h: 1600, tag: "Bathroom", title: "Shower with pebble accent", sub: "Marble-look tile, pebble accent strip and floor, half wall with glass, ceiling rain head",
                 alt: "Walk-in shower with marble-look tile, a vertical pebble mosaic accent strip, a pebble floor, a tiled half wall with glass, and a ceiling-mounted rain head" },
  "bath-vanity" => { src: "assets/photos/bath-marble-vanity.jpg", w: 1200, h: 1600, tag: "Bathroom", title: "Shaker vanity &amp; lighting", sub: "Gray shaker vanity with quartz top, LED light bar, large-format floor tile, new toilet",
                 alt: "Gray shaker vanity with a white quartz top and chrome faucet under a frameless mirror and an LED light bar, beside a one-piece toilet on dark large-format floor tile" },
  "stairs-balusters" => { src: "assets/photos/team-stair-balusters.jpg", w: 1200, h: 900, land: true, tag: "Stairs &amp; railings", title: "Metal baluster installation", sub: "Black metal balusters set and aligned by hand along a new railing",
                 alt: "Crew member installing a long row of black metal balusters along a wall" },
  "drywall-ceiling" => { src: "assets/photos/team-drywall-ceiling.jpg", w: 560, h: 1200, tag: "Drywall", title: "Ceiling drywall finishing", sub: "Ceiling patches taped, mudded, and sanded smooth, with the room protected in plastic",
                 alt: "Crew member on a work platform applying joint compound to ceiling drywall patches in a room protected with plastic sheeting" },
}
BATH_EXTRA = <<~HTML
  <!-- SPECIAL FEATURES -->
  <section class="sheet sec" aria-labelledby="feat-t">
    <div class="wrap">
      <div class="head">
        <div><p class="eyebrow">Special features</p><h2 id="feat-t">Details worth <em>asking for.</em></h2></div>
        <p>Features we build into bathrooms when they suit the home and the people using it. Each photo is from one of our projects.</p>
      </div>
      <div class="feat-grid">
        <article class="feat"><figure><img src="assets/photos/feature-steam-shower.jpg" width="1204" height="1600" loading="lazy" alt="Inside a steam shower with charcoal tile, a stone bench, a long pebble niche, and a window"></figure><span class="mono">Shower</span><h3>Steam shower</h3><p>A fully glass-enclosed shower with its own steam system. The glass runs to the ceiling, so the steam stays inside.</p></article>
        <article class="feat"><figure><img src="assets/photos/bath-wetroom.jpg" width="1320" height="990" loading="lazy" alt="Japanese-style wet room with a freestanding soaking tub inside the walk-in shower area"></figure><span class="mono">Layout</span><h3>Japanese-style wet room</h3><p>The tub and the shower share one waterproofed area, so you can rinse off and then soak without stepping out.</p></article>
        <article class="feat"><figure><img src="assets/photos/feature-jetted-tub.jpg" width="1200" height="1600" loading="lazy" alt="Jetted tub filled with water, set into a tiled deck beside a pebble mosaic niche"></figure><span class="mono">Tub</span><h3>Jetted tub</h3><p>A Jacuzzi-style jetted tub set into a tiled deck, with a niche beside it to keep everything within reach.</p></article>
        <article class="feat"><figure><img src="assets/photos/feature-mitered-niche.jpg" width="1200" height="1600" loading="lazy" alt="Close-up of a shampoo niche lined with black penny tile, its marble-look tile edges cut at 45 degrees"></figure><span class="mono">Tile detail</span><h3>Mitered shampoo niche</h3><p>The niche edges are cut at 45 degrees so the tile meets in a clean corner, with no metal or plastic trim strip.</p></article>
        <article class="feat"><figure><img src="assets/photos/feature-linear-drain.jpg" width="1200" height="1600" loading="lazy" alt="Shower floor in marble-look mosaic tile with a long linear drain along the wall"></figure><span class="mono">Drain</span><h3>Tile-in linear drain</h3><p>A long drain along the wall that takes the same tile as the floor, so it blends into the shower.</p></article>
        <article class="feat"><figure><img src="assets/photos/feature-grab-bar.jpg" width="1200" height="1600" loading="lazy" alt="Stainless grab bar mounted on a tiled wall beside a toilet"></figure><span class="mono">Comfort &amp; safety</span><h3>Grab bars</h3><p>Placed where they help most. They make a bathroom easier and safer for older family members, not only for accessibility needs.</p></article>
      </div>
      <div class="build-video light">
        <video controls preload="none" playsinline width="540" height="960" poster="assets/photos/bath-marble-tour-poster.jpg" aria-label="Short walk-through video of a finished marble-look tile bathroom">
          <source src="assets/photos/bath-marble-tour.mp4" type="video/mp4">
        </video>
        <div><span class="mono">Video</span><h3>Walk through a finished bathroom</h3><p>A few seconds inside the marble-look tile bathroom: frameless glass shower, mitered niche, linear drain, and new vanity.</p></div>
      </div>
    </div>
  </section>

  <!-- BEFORE & AFTER -->
  <section class="sheet sec" aria-labelledby="ba-t" style="background:var(--paper-2)">
    <div class="wrap">
      <div class="head">
        <div><p class="eyebrow">Before &amp; after</p><h2 id="ba-t">Same room. <em>New bathroom.</em></h2></div>
        <p>Three recent bathrooms, each photographed before we started and after we finished.</p>
      </div>
      <div class="ba-grid">
        <article class="ba">
          <div class="ba-pair">
            <figure><img src="assets/photos/bath-subway-before.jpg" width="1200" height="1600" loading="lazy" alt="Before: a dated bathroom with a tub, a shower curtain, and square white wall tile"><span class="mono">Before</span></figure>
            <figure><img src="assets/photos/bath-subway-after.jpg" width="1200" height="1600" loading="lazy" alt="After: the same bathroom with a walk-in shower in white subway tile, a bench, black fixtures, and a new vanity with a granite top"><span class="mono">After</span></figure>
          </div>
          <h3>Tub to walk-in shower</h3>
          <p>The old tub came out and a walk-in shower went in: subway tile, a bench, a niche, frameless glass, and a new vanity and floor.</p>
        </article>
        <article class="ba">
          <div class="ba-pair">
            <figure><img src="assets/photos/bath-tub-before.jpg" width="1200" height="1600" loading="lazy" alt="Before: an old one-piece fiberglass tub and wall surround"><span class="mono">Before</span></figure>
            <figure><img src="assets/photos/bath-tub-after.jpg" width="1200" height="1600" loading="lazy" alt="After: a new white tub with a gray marble-look tile surround and a recessed niche"><span class="mono">After</span></figure>
          </div>
          <h3>New tub &amp; tile surround</h3>
          <p>A one-piece fiberglass surround replaced with a new tub, tile to the ceiling, a recessed niche, and a new valve.</p>
        </article>
        <article class="ba">
          <div class="ba-pair">
            <figure><img src="assets/photos/bath-marble-before.jpg" width="1200" height="1600" loading="lazy" alt="Before: a dated bathroom with a blue tub behind gold-framed sliding doors, a blue toilet, and a blue sink"><span class="mono">Before</span></figure>
            <figure><img src="assets/photos/bath-marble-after.jpg" width="1200" height="1600" loading="lazy" alt="After: the same bathroom with a frameless glass walk-in shower in bold marble-look tile and a long black niche"><span class="mono">After</span></figure>
          </div>
          <h3>Tub to marble-look shower</h3>
          <p>The old tub and sliding doors made way for a walk-in shower with frameless glass, a mitered niche, and a linear drain.</p>
        </article>
      </div>
    </div>
  </section>

  <!-- SHOWER BUILD -->
  <section class="dark sec" aria-labelledby="build-t">
    <div class="wrap">
      <div class="head">
        <div><p class="eyebrow">Behind the tile</p><h2 id="build-t">How we build <em>a shower.</em></h2></div>
        <p>One recent project, from demolition to finished tile. The waterproofing you never see is what makes a shower last.</p>
      </div>
      <ol class="build">
        <li><figure><img src="assets/photos/shower-build-1-demo.jpg" width="1200" height="1600" loading="lazy" alt="Old shower removed down to the wall studs and floor joists"></figure><span class="mono">01</span><h3>Demolition</h3><p>The old shower comes out down to the studs and joists, so we can see the framing and plumbing.</p></li>
        <li><figure><img src="assets/photos/shower-build-2-subfloor.jpg" width="1200" height="1600" loading="lazy" alt="New framing and subfloor for a larger shower, with the drain set in place"></figure><span class="mono">02</span><h3>Framing &amp; subfloor</h3><p>New framing and subfloor for the larger shower footprint, with the drain set in its new position.</p></li>
        <li><figure><img src="assets/photos/shower-build-3-board.jpg" width="1200" height="1600" loading="lazy" alt="Shower walls covered in waterproof board with sealed seams and a boxed-in niche"></figure><span class="mono">03</span><h3>Waterproof walls</h3><p>Waterproof board on every wall, with seams and fasteners sealed and the niche boxed in.</p></li>
        <li><figure><img src="assets/photos/shower-build-4-pan.jpg" width="1600" height="1200" loading="lazy" alt="Shower floor sloped to a center drain before tile"></figure><span class="mono">04</span><h3>Sloped pan</h3><p>The shower floor is sloped to the drain and waterproofed before any tile goes on.</p></li>
        <li><figure><img src="assets/photos/bath-clay-shower.jpg" width="1200" height="1600" loading="lazy" alt="Finished shower in glossy handmade clay tile on the walls and floor"></figure><span class="mono">05</span><h3>Finished tile</h3><p>Handmade clay tile on the walls and floor, a new valve, and a rain head.</p></li>
      </ol>
      <div class="build-video">
        <video controls preload="none" playsinline width="478" height="850" poster="assets/photos/shower-waterproofing-poster.jpg" aria-label="Short video of the waterproofing work on this shower">
          <source src="assets/photos/shower-waterproofing.mp4" type="video/mp4">
        </video>
        <div><span class="mono">On site</span><h3>Waterproofing in progress</h3><p>A short clip from the same project: fitting the shower pan and wall board before tile.</p></div>
      </div>
    </div>
  </section>

HTML
QUOTES = {
  rebecca: ["What I appreciate most is their patience and professionalism. No matter how many questions I had, Noam always took the time to explain and never rushed the process. They’re always on site when they say they will be, take full responsibility for every detail, and truly stand behind their work. You can feel the integrity.", "Rebecca T.", "Seattle, WA"],
  david:   ["From the first meeting to the final walkthrough, you can tell Julius Remodeling Group runs as a true team. The designers, builders, and project managers all communicate smoothly. Everyone cares about the end result and it shows. Our home turned out even better than we imagined.", "David L.", "Mercer Island, WA"],
}
LICENSED_FAQ = ["Are you licensed, insured, and bonded?", "Yes. Julius Remodeling Group is a licensed, insured, and bonded Washington general contractor (License JULIURG780NJ). <a href=\"#{LICENSE_URL}\" target=\"_blank\" rel=\"noopener\" style=\"text-decoration:underline\">Verify it with Washington L&amp;I</a>."]
CONDO_LINK = "<a href=\"condo-remodeling.html\" style=\"text-decoration:underline\">See how condo remodeling works</a>"

# ---------------------------------------------------------------- page content
PAGES = [
  # ============================== KITCHEN
  {
    slug: "kitchen-remodeling", short: "Kitchen",
    title: "Kitchen Remodeling in Seattle &amp; the Eastside",
    meta: "Kitchen remodeling in Seattle and the Eastside: cabinet repainting, semi-custom and custom cabinets, countertops, islands, sinks, plumbing, electrical, windows, and flooring.",
    eyebrow: "Kitchen remodeling",
    h1: "A kitchen built around <em>how you live.</em>",
    lede: "From repainting the cabinets you have to a fully custom kitchen: countertops, islands, sinks, plumbing, electrical, windows, and flooring for homes, condos, and apartments across Seattle and the Eastside, built by one team under one license.",
    tags: ["Cabinet repainting", "Semi-custom &amp; custom cabinets", "Countertops", "Islands", "Plumbing &amp; electrical", "Windows &amp; flooring"],
    photo: "kitchen-1",
    incl_h: "Everything the kitchen needs, <em>under one roof.</em>",
    incl_p: "From layout to the last outlet cover, one team plans and builds the whole kitchen. Choose any part, or all of it.",
    incl: [
      ["Cabinets", "Repaint your existing cabinets, or replace them with semi-custom or fully custom cabinetry, with new hardware."],
      ["Countertops", "Quartz and natural stone countertops, measured, fabricated, and installed with clean seams and edges."],
      ["Island", "A new island, or a bigger one, with seating, storage, and power or plumbing built in where you want it."],
      ["Sink &amp; plumbing", "New sink and faucet, dishwasher and appliance hookups, and moving plumbing lines when the layout changes."],
      ["Electrical &amp; lighting", "New circuits and outlets, appliance wiring, recessed, pendant, and under-cabinet lighting, with permits when required."],
      ["Windows", "Replace or resize the kitchen window for more light over the sink or counters."],
      ["Flooring", "New flooring through the kitchen and into adjoining rooms, with clean transitions."],
      ["Backsplash &amp; finish", "Tile backsplash, trim, drywall, and paint, the details that finish the room."],
    ],
    options: {
      eyebrow: "Your options", h: "Refresh, replace, <em>or go fully custom.</em>",
      p: "Not every kitchen needs to be gutted. We'll walk through your kitchen at the consultation and help you pick the level that fits your goals and budget.",
      cards: [
        ["Repaint existing cabinets", "If your cabinet boxes are solid, we can repaint them and add new hardware for a completely new look, without the cost of new cabinetry. It pairs well with new countertops, backsplash, and lighting.", ["Keep your current layout", "New color, new hardware", "Least disruption"]],
        ["Semi-custom cabinets", "Factory-built cabinets in standard sizes, with a wide choice of door styles, finishes, and modifications. A strong balance of quality, choice, and budget when old cabinets need replacing.", ["Replace worn or dated cabinets", "Many styles and finishes", "Layout changes possible"]],
        ["Custom cabinets", "Built to your exact dimensions, layout, and finish. Best for unusual spaces, floor-to-ceiling storage, and an island designed around how you cook and gather.", ["Built to exact measurements", "Any finish, any detail", "Full layout freedom"]],
      ],
      table: {
        caption: "Cabinet options at a glance",
        cols: ["Repaint existing", "Semi-custom", "Custom"],
        rows: [
          ["Best for", "Solid cabinets that look dated", "Replacing worn cabinets", "Unique spaces and full redesigns"],
          ["Sizes", "Your existing boxes", "Standard sizes, some modifications", "Built to exact dimensions"],
          ["Finish choices", "Any paint color, new hardware", "Wide range of styles and finishes", "Unlimited"],
          ["Layout changes", "No", "Yes", "Yes, fully flexible"],
          ["Time to complete", "Shortest", "Moderate", "Longest"],
          ["Budget", "$", "$$", "$$$"],
        ],
      },
    },
    gallery: ["kitchen-wood", "kitchen-1", "kitchen-dark", "kitchen-2", "kitchen-dark-2", "kitchen-3"],
    quote: :david,
    faq: [
      ["Should I repaint my cabinets or replace them?", "If the cabinet boxes are solid and you like the layout, repainting with new hardware is the most budget-friendly way to transform the kitchen. If they are worn, water-damaged, or the layout does not work, replacing them with semi-custom or custom cabinets makes more sense. We will give you an honest recommendation at the consultation."],
      ["What is the difference between semi-custom and custom cabinets?", "Semi-custom cabinets come in standard sizes with many styles, finishes, and modifications. Custom cabinets are built to your exact dimensions and design, which suits unusual spaces, full-height storage, and one-of-a-kind islands. See the comparison above."],
      ["Do you handle the electrical and plumbing?", "Yes. Electrical and plumbing work is managed by our team under our license, including new circuits, lighting, sink and appliance hookups, and moving lines for a new layout. Permits are coordinated when required."],
      ["Can you change my kitchen's layout?", "Yes. Layout changes are worked out during design and planning, including any plumbing and electrical moves, and permits are coordinated when required."],
      ["Do you remodel condo kitchens?", "Yes. Kitchens inside buildings also need HOA approvals, elevator bookings, and building rules handled. #{CONDO_LINK}."],
    ],
  },

  # ============================== BATHROOM
  {
    slug: "bathroom-remodeling", short: "Bathroom",
    title: "Bathroom Remodeling in Seattle &amp; the Eastside",
    meta: "Bathroom remodeling in Seattle and the Eastside: bathroom refreshes, full remodels, tub-to-shower conversions, walk-in showers, custom tile, waterproofing, vanities, plumbing, and lighting.",
    eyebrow: "Bathroom remodeling",
    h1: "Bathrooms finished <em>to the last tile.</em>",
    lede: "From a quick refresh to a full remodel down to the studs: walk-in showers, custom tile, waterproofing, vanities, plumbing, and lighting for homes, condos, and apartments across Seattle and the Eastside.",
    tags: ["Walk-in showers", "Tub-to-shower conversions", "Custom tile", "Waterproofing", "Vanities", "Plumbing &amp; lighting"],
    photo: "bath-1",
    incl_h: "From the studs <em>to the shower glass.</em>",
    incl_p: "We specialize in waterproofing, custom tile installation, detailed finishes, and fine trim and paint. Choose any part, or all of it.",
    incl: [
      ["Showers &amp; tubs", "Walk-in showers, new tubs, tub-to-shower conversions, niches, benches, and glass."],
      ["Custom tile", "Floor, wall, and shower tile, laid out and set by hand, with clean edges and niches."],
      ["Waterproofing", "Waterproofing systems behind every wet area, installed before any tile goes on."],
      ["Vanities &amp; counters", "New vanities, quartz or stone counters, mirrors, and storage."],
      ["Toilets &amp; fixtures", "Toilets, faucets, shower valves, and hardware, selected with you up front."],
      ["Plumbing", "Plumbing upgrades and relocations when the layout changes, under our license."],
      ["Lighting &amp; ventilation", "Layered lighting and a properly sized exhaust fan to keep moisture out of the walls."],
      ["Flooring", "Tile or other water-ready flooring, with clean transitions to the rest of the home."],
    ],
    options: {
      eyebrow: "Your options", h: "Refresh, remodel, <em>or convert.</em>",
      p: "Every bathroom starts in a different place. We'll look at yours at the consultation and recommend the level of work that fits your goals and budget.",
      cards: [
        ["Bathroom refresh", "Keep the layout and the shower, and update what you see: a new vanity, counter, mirror, lighting, fixtures, and paint. A big change with the least disruption.", ["Same layout", "New vanity, lighting, fixtures", "Fastest option"]],
        ["Tub-to-shower conversion", "Replace an old tub with a walk-in shower: new waterproofing, custom tile, niches, a bench if you want one, and glass. Easier to use every day.", ["Walk-in shower", "Custom tile and niches", "Easier daily access"]],
        ["Full remodel", "Down to the studs: new layout if needed, plumbing, waterproofing, tile, shower or tub, vanity, lighting, and ventilation. Everything new, behind the walls and in front of them.", ["New everything", "Layout changes possible", "Plumbing and electrical updated"]],
      ],
      table: {
        caption: "Bathroom options at a glance",
        cols: ["Refresh", "Tub-to-shower", "Full remodel"],
        rows: [
          ["Best for", "Dated finishes, solid shower", "Hard-to-use tub", "Worn or leaking bathrooms, new layouts"],
          ["Shower or tub", "Kept", "Tub replaced by walk-in shower", "All new"],
          ["Tile &amp; waterproofing", "Usually not needed", "In the shower area", "Throughout"],
          ["Layout changes", "No", "Limited", "Yes"],
          ["Time to complete", "Shortest", "Moderate", "Longest"],
          ["Budget", "$", "$$", "$$$"],
        ],
      },
    },
    gallery: ["bath-wetroom", "bath-1", "bath-dark-shower", "bath-dark-vanity", "bath-guest", "bath-dark-glass", "bath-gray-bench", "bath-white", "bath-subway", "bath-clay", "bath-warm", "bath-2", "bath-freestanding", "bath-tub", "bath-marble", "bath-pebble", "bath-vanity", "bath-shower", "bath-green"],
    extra: BATH_EXTRA,
    quote: :rebecca,
    faq: [
      ["Do you build walk-in showers?", "Yes. Walk-in showers with custom tile, niches, and glass are one of our most requested projects. You can see two of them above."],
      ["Can you convert my tub into a shower?", "Yes. Tub-to-shower conversions include removing the tub, waterproofing the new shower area, custom tile, and glass."],
      ["Why does waterproofing matter so much?", "Water that gets behind tile causes damage you don't see until it's expensive. Waterproofing is one of our specialties, and it's done before any tile goes on."],
      ["Can you remodel just one bathroom?", "Yes. Whether it's a single powder room or every bathroom in the house, the process is the same: organized, transparent, and carefully executed."],
      ["Do you remodel condo bathrooms?", "Yes, including the HOA approvals, water shutoffs, and building rules that come with it. #{CONDO_LINK}."],
    ],
  },

  # ============================== BASEMENT
  {
    slug: "basement-remodeling", short: "Basement",
    title: "Basement Remodeling &amp; Finishing in Seattle &amp; the Eastside",
    meta: "Basement remodeling and finishing in Seattle and the Eastside: family rooms, guest bedrooms, bathrooms, wet bars, and home offices, with moisture, framing, electrical, plumbing, and permits handled.",
    eyebrow: "Basement remodeling",
    h1: "Turn the basement into <em>real living space.</em>",
    lede: "Finish an unfinished basement or update an old one: family rooms, guest bedrooms, bathrooms, wet bars, and home offices for homes across Seattle and the Eastside, planned and built by one team.",
    tags: ["Family rooms", "Guest bedrooms", "Bathrooms", "Wet bars", "Home offices", "Storage"],
    photo: nil,
    incl_h: "Everything a finished basement needs, <em>done in order.</em>",
    incl_p: "A good basement starts with what's behind the walls. We take care of moisture, framing, and systems first, then the finishes.",
    incl: [
      ["Moisture first", "Signs of moisture are checked and addressed before any walls go up, so the finished space stays dry."],
      ["Framing &amp; insulation", "New walls, insulation, and soffits that work around beams, ducts, and pipes."],
      ["Electrical &amp; lighting", "New circuits, outlets, recessed lighting, and wiring for TVs, offices, and gyms."],
      ["Plumbing", "Bathrooms, wet bars, and laundry, with plumbing run and inspected under our license."],
      ["Egress windows", "For bedrooms, egress windows where code requires them, with permits coordinated."],
      ["Drywall &amp; ceilings", "Drywall, ceilings, and paint, finished like the rest of the house."],
      ["Flooring", "Flooring suited to below-grade spaces, with clean transitions and trim."],
      ["Stairs &amp; storage", "Updated stairs and railings, built-ins, and storage that keeps the space usable."],
    ],
    options: {
      eyebrow: "Your options", h: "What will your basement <em>become?</em>",
      p: "We'll plan the space around how you want to use it, then handle the permits, systems, and finishes to get it there.",
      cards: [
        ["Finish an unfinished basement", "Bare concrete and open framing turned into finished living space: walls, insulation, electrical, lighting, drywall, ceilings, and flooring.", ["Family room or media room", "Home office or gym", "Permits coordinated"]],
        ["Update a finished basement", "An older finished basement brought up to date: new flooring, lighting, paint, trim, and layout changes where they make sense.", ["New flooring and lighting", "Better layout", "Least disruption"]],
        ["Add a bedroom, bath, or wet bar", "Make the basement work like a suite: a guest bedroom with egress, a full or half bathroom, or a wet bar for entertaining.", ["Guest suite", "Bathroom or wet bar", "Plumbing and egress planned"]],
      ],
    },
    gallery: [],
    quote: :david,
    faq: [
      ["Do I need a permit to finish my basement?", "Finishing a basement usually requires permits, especially for framing, electrical, and plumbing. We coordinate permits as part of the project, before construction begins."],
      ["What if my basement has moisture?", "Moisture is the first thing we look at. Any signs of water are checked and addressed before walls and flooring go in, so the finished space stays dry."],
      ["Can you add a bedroom in the basement?", "Often, yes. A basement bedroom needs an egress window or door and has to meet other code requirements, and we plan for those from the start."],
      ["Can you add a bathroom or wet bar downstairs?", "Yes. Bathrooms, wet bars, and laundry rooms are common basement additions. We plan the plumbing during design so everything drains and vents properly."],
      LICENSED_FAQ,
    ],
  },

  # ============================== WHOLE HOME
  {
    slug: "whole-home-remodeling", short: "Whole home",
    title: "Whole-Home Remodeling in Seattle &amp; the Eastside",
    meta: "Whole-home remodeling for single-family homes in Seattle and the Eastside. Several rooms or the whole house, planned as one design, on one schedule and one budget.",
    eyebrow: "Whole-home remodeling",
    h1: "The whole house, <em>one plan.</em>",
    lede: "For single-family homes across Seattle and the Eastside: several rooms, or the whole house, designed together and built by one team, on one schedule and one budget.",
    tags: ["Multiple rooms", "Layout changes", "Plumbing", "Electrical", "Mechanical", "Permits"],
    photo: "laundry",
    incl_h: "One design. One schedule. <em>One budget.</em>",
    incl_p: "We handle every part of your project, from designing, quoting, and budgeting to shopping, prepping, and building.",
    incl: [
      ["One cohesive design", "Kitchens, baths, flooring, and finishes planned together so the house feels like one home."],
      ["Trades &amp; systems", "Demolition, plumbing, electrical, and mechanical work, managed by one team."],
      ["Permits", "Coordinated whenever the work requires them, before construction starts."],
      ["One point of contact", "One management team from first walkthrough to final punch list."],
    ],
    gallery: ["kitchen-open", "bath-1", "bath-2", "kitchen-wood", "floor-great", "laundry"],
    quote: :david,
    faq: [
      ["Can we stay in the house during the remodel?", "It depends on the scope. We'll talk it through at your consultation and, where it makes sense, plan the work in phases so part of the house stays usable."],
      ["Do you handle permits?", "Yes. We coordinate permits when required and prepare your project for construction before demolition begins."],
      ["Do you also remodel condos?", "Yes. Full-unit condo and apartment renovations follow the same process, plus the building approvals. #{CONDO_LINK}."],
    ],
  },

  # ============================== FLOORING
  {
    slug: "flooring-installation", short: "Flooring",
    title: "Flooring Installation in Seattle &amp; the Eastside",
    meta: "Flooring installation in Seattle and the Eastside: hardwood, luxury vinyl plank, and tile, with old floors removed, subfloors prepared, and transitions and trim finished clean.",
    eyebrow: "Flooring",
    h1: "Floors that tie <em>the home together.</em>",
    lede: "New flooring for a single room or the whole house: old floors removed, subfloors prepared, and hardwood, luxury vinyl plank, or tile installed with clean transitions and trim.",
    tags: ["Hardwood", "Luxury vinyl plank", "Tile", "Subfloor prep", "Baseboards &amp; trim", "Whole-home flooring"],
    photo: "floor-great",
    incl_h: "From tear-out <em>to the last baseboard.</em>",
    incl_p: "A floor is only as good as what's under it. We take care of the prep and the finish, not just the install.",
    incl: [
      ["Removal &amp; prep", "Old flooring removed and hauled away, and the subfloor checked, repaired, and leveled."],
      ["Installation", "Hardwood, luxury vinyl plank, or tile, laid out so the pattern runs clean through every room."],
      ["Transitions &amp; trim", "Thresholds, stair nosing, baseboards, and quarter round, finished to match."],
      ["Whole-home continuity", "One floor flowing through kitchens, halls, and living spaces, without awkward breaks."],
    ],
    options: {
      eyebrow: "Materials", h: "Choose the right floor <em>for each room.</em>",
      p: "We'll help you pick a floor that fits the room, how you live, and your budget.",
      cards: [
        ["Hardwood", "Warm, classic, and long-lasting. A great fit for living rooms, bedrooms, and halls.", ["Natural wood look and feel", "Can be refinished later", "Best in dry rooms"]],
        ["Luxury vinyl plank", "Wood looks with water resistance. Durable and comfortable, and a practical choice for kitchens, basements, and busy homes.", ["Water-resistant", "Durable and quiet", "Budget-friendly"]],
        ["Tile", "The go-to for bathrooms, entries, and laundry rooms. Waterproof, easy to clean, and endless in style.", ["Waterproof", "Bathrooms and entries", "Many sizes and patterns"]],
      ],
    },
    gallery: ["floor-great", "floor-plank", "floor-bedroom", "kitchen-3", "door-barn", "door-interior"],
    quote: :rebecca,
    faq: [
      ["Which flooring is best for kitchens and bathrooms?", "Tile and luxury vinyl plank handle water best. Hardwood works beautifully in living spaces and bedrooms. We'll recommend options room by room."],
      ["Do you remove the old flooring?", "Yes. Removal, haul-away, and subfloor prep are part of the job, so the new floor goes down flat and solid."],
      ["Can the same floor run through several rooms?", "Yes. Running one floor through connected rooms makes a home feel larger and more cohesive, and we plan the layout so it flows."],
      ["Do you do flooring as a standalone project?", "Yes. Flooring can be its own project, or part of a kitchen, bathroom, basement, or whole-home remodel."],
    ],
  },

  # ============================== INTERIOR FINISH
  {
    slug: "interior-finish-carpentry", short: "Interior finish",
    title: "Interior Finish &amp; Carpentry in Seattle &amp; the Eastside",
    meta: "Built-ins, fireplaces, feature walls, fine trim, painting, and finish carpentry in Seattle and the Eastside.",
    eyebrow: "Interior finish &amp; carpentry",
    h1: "The details people <em>notice first.</em>",
    lede: "Built-ins, fireplaces, feature walls, fine trim, and painting for homes, condos, and apartments. Finish work as its own project, or as part of a larger remodel.",
    tags: ["Built-ins", "Fireplaces", "Feature walls", "Fine trim", "Painting", "Finish carpentry"],
    photo: "laundry",
    incl_h: "Finish work, <em>done to the detail.</em>",
    incl_p: "Detailed finishes and fine trim and paint are what make a room feel complete, and they're one of our specialties.",
    incl: [
      ["Built-ins &amp; shelving", "Built-in cabinets, bookshelves, window seats, and storage, built to fit the space."],
      ["Fireplaces &amp; feature walls", "Fireplace surrounds, mantels, and paneled or textured feature walls."],
      ["Trim &amp; millwork", "Baseboards, door and window casing, crown molding, and wainscoting."],
      ["Painting", "Walls, ceilings, trim, and doors, prepped and painted for a clean, lasting finish."],
    ],
    gallery: ["builtin-mudroom", "laundry"],
    quote: :rebecca,
    faq: [
      ["Can you build custom built-ins?", "Yes. Built-ins, shelving, and finish carpentry are designed with you and built to fit the space."],
      ["Do you take on painting and trim only?", "Yes. Fine trim and paint work is one of our specialties, whether it's a single room or the whole house."],
      ["Can you update a fireplace?", "Yes. We build new surrounds, mantels, and feature walls around existing fireplaces."],
    ],
  },

  # ============================== DOORS
  {
    slug: "door-replacement", short: "Door",
    title: "Door Replacement &amp; Installation in Seattle &amp; the Eastside",
    meta: "Interior, entry, and patio door replacement and installation in Seattle and the Eastside, with hardware, trim, and paint finished by a licensed general contractor.",
    eyebrow: "Doors",
    h1: "Doors that open, close, <em>and look right.</em>",
    lede: "Interior doors, entry doors, and patio doors, replaced and installed with new hardware, trim, and paint, by the same team that builds our full remodels.",
    tags: ["Interior doors", "Entry doors", "Patio &amp; sliding doors", "Hardware", "Trim &amp; casing"],
    photo: "door-barn",
    incl_h: "New doors, <em>finished properly.</em>",
    incl_p: "A door is only as good as its fit. We take care of the frame, the hardware, and the trim around it.",
    incl: [
      ["Interior doors", "New interior doors throughout the house, in the style you choose, hung to swing and latch smoothly."],
      ["Entry &amp; exterior doors", "Front and side doors installed square, sealed against the weather, with new locks and hardware."],
      ["Patio &amp; sliding doors", "Sliding and hinged patio doors that open your home to the outside."],
      ["Hardware, trim &amp; paint", "Handles, hinges, casing, and paint, so each door looks finished."],
    ],
    gallery: ["door-barn", "door-interior"],
    quote: :rebecca,
    faq: [
      ["Do you replace just the door or the frame too?", "Either. If the frame is in good shape, we can replace the door itself. If not, we install a new pre-hung door with its own frame."],
      ["Can you change every interior door in the house?", "Yes. Updating all interior doors and hardware to one style is one of the most noticeable upgrades you can make."],
      ["Do you paint and trim the new doors?", "Yes. Casing, trim, and paint are included, so the door matches the rest of the room."],
      LICENSED_FAQ,
    ],
  },

  # ============================== WINDOWS
  {
    slug: "window-replacement", short: "Window",
    title: "Window Replacement in Seattle &amp; the Eastside",
    meta: "Window replacement and new or enlarged window openings in Seattle and the Eastside, with framing, trim, drywall, and paint by a licensed general contractor.",
    eyebrow: "Windows",
    h1: "More light, <em>better windows.</em>",
    lede: "Replacement windows, new openings, and bigger windows where you want more light, with framing, trim, drywall, and paint done by one team.",
    tags: ["Window replacement", "New openings", "Enlarged windows", "Trim &amp; sills", "Drywall &amp; paint"],
    photo: nil,
    incl_h: "The window <em>and everything around it.</em>",
    incl_p: "Window work touches framing, the exterior, and the interior finish. We handle all three.",
    incl: [
      ["Replacement windows", "Old, drafty, or failing windows replaced and sealed."],
      ["New or larger openings", "Reframed walls for new windows or bigger ones, with permits coordinated when required."],
      ["Trim &amp; sills", "Interior casing, sills, and exterior trim, finished clean."],
      ["Drywall &amp; paint", "Wall repairs around the opening, painted to blend with the room."],
    ],
    gallery: [],
    quote: :david,
    faq: [
      ["Can you make a window bigger?", "Often, yes. Enlarging an opening means reframing the wall around it, and permits are coordinated when required."],
      ["Do you replace windows in condos?", "In many buildings, windows are shared elements that need HOA approval. We coordinate with your building before any work starts. #{CONDO_LINK}."],
      ["Do you finish the inside after the window is in?", "Yes. Trim, drywall repair, and paint are part of the job, so the room looks finished when we leave."],
      LICENSED_FAQ,
    ],
  },

  # ============================== STAIRS
  {
    slug: "stairs-and-railings", short: "Stairs &amp; railing",
    title: "Stairs &amp; Railings in Seattle &amp; the Eastside",
    meta: "Stair and railing remodeling, repair, and replacement in Seattle and the Eastside: treads, risers, balusters, handrails, and newel posts.",
    eyebrow: "Stairs &amp; railings",
    h1: "Stairs that make <em>an entrance.</em>",
    lede: "New treads, railings, balusters, and newel posts, plus repairs for squeaks and loose rails, so your staircase is safe, solid, and good-looking.",
    tags: ["Stair treads", "Railings &amp; handrails", "Balusters", "Newel posts", "Repairs", "Stain &amp; paint"],
    photo: nil,
    incl_h: "From the first step <em>to the handrail.</em>",
    incl_p: "Stairs get used every day. We build and repair them to stay solid.",
    incl: [
      ["Treads &amp; risers", "New treads and risers, including replacing carpeted stairs with wood."],
      ["Railings &amp; balusters", "New handrails, balusters, and newel posts in wood, metal, or a mix."],
      ["Repairs", "Squeaky steps, loose railings, and worn treads fixed and made solid."],
      ["Stain &amp; paint", "Treads stained and risers and balusters painted for a finished look."],
    ],
    gallery: ["stairs-balusters"],
    quote: :rebecca,
    faq: [
      ["Can you replace carpeted stairs with wood?", "Yes. We remove the carpet, then install new wood treads and risers finished to match your floors."],
      ["Can you fix a loose or wobbly railing?", "Yes. Loose railings and balusters are re-secured or replaced so the rail is solid."],
      ["Can you update just the railing?", "Yes. Swapping out balusters and handrails is a quick way to modernize a staircase without rebuilding it."],
      LICENSED_FAQ,
    ],
  },

  # ============================== CONCRETE
  {
    slug: "concrete-work", short: "Concrete",
    title: "Concrete Work in Seattle &amp; the Eastside",
    meta: "Concrete walkways, steps, patios, slabs, and repairs in Seattle and the Eastside, by a licensed, insured, and bonded general contractor.",
    eyebrow: "Concrete",
    h1: "Concrete done <em>to last.</em>",
    lede: "Walkways, steps, patios, slabs, and repairs, formed, poured, and finished by a licensed general contractor, as its own project or as part of a larger remodel.",
    tags: ["Walkways", "Steps", "Patios", "Slabs", "Repairs"],
    photo: nil,
    incl_h: "Formed, poured, <em>and finished right.</em>",
    incl_p: "Good concrete depends on the prep underneath. We take care of the base, the forms, and the finish.",
    incl: [
      ["Walkways &amp; paths", "New walkways and paths, sloped to shed water and finished for grip."],
      ["Steps &amp; landings", "Concrete steps and landings built solid and to code."],
      ["Patios &amp; slabs", "Patios and slabs for outdoor living, sheds, and equipment."],
      ["Repairs", "Cracked or broken sections removed and replaced."],
    ],
    gallery: [],
    quote: :david,
    faq: [
      ["Do you take on smaller concrete jobs?", "Yes. From a single step to a full patio, concrete can be its own project or part of a larger remodel."],
      ["Should I repair or replace damaged concrete?", "It depends on how widespread the damage is. We'll look at it and give you an honest recommendation."],
      LICENSED_FAQ,
    ],
  },

  # ============================== DRYWALL
  {
    slug: "drywall-repair", short: "Drywall",
    title: "Drywall Repair in Seattle &amp; the Eastside",
    meta: "Drywall repair in Seattle and the Eastside: holes, cracks, water damage, ceilings, texture matching, and paint, finished to blend in.",
    eyebrow: "Drywall repair",
    h1: "Repairs you <em>can't spot.</em>",
    lede: "Holes, cracks, water damage, and ceiling repairs, patched, textured, and painted to blend with the rest of the wall.",
    tags: ["Holes &amp; cracks", "Water damage", "Ceilings", "Texture matching", "Paint"],
    photo: nil,
    incl_h: "Patched, textured, <em>and painted.</em>",
    incl_p: "A good repair disappears. We match the texture and the paint so you can't tell where it was.",
    incl: [
      ["Holes &amp; cracks", "Small holes, large holes, and cracks repaired with new drywall where needed."],
      ["Water damage", "Damaged drywall replaced once the source of the leak is fixed."],
      ["Texture matching", "Smooth, orange peel, or knockdown texture matched to the existing wall."],
      ["Paint", "Repaired areas primed and painted to blend in."],
    ],
    gallery: ["drywall-ceiling"],
    quote: :rebecca,
    faq: [
      ["Can you match my wall texture?", "Yes. We match common textures such as smooth, orange peel, and knockdown, so the repair blends in."],
      ["I have a water stain on my ceiling. Can you fix it?", "Yes. The source of the water has to be found and fixed first. Then we replace the damaged drywall, texture it, and paint."],
      ["Do you take small drywall jobs?", "Yes. Drywall repair can be its own job, or part of a larger project."],
    ],
  },
]

PROCESS = <<~HTML
  <ol class="track" style="list-style:none;margin:0;padding-top:0">
    <li class="stage"><span class="no">01</span><div class="pin"></div><h3>Free consultation</h3><p>We meet and discuss your ideas, needs, priorities, and budget.</p></li>
    <li class="stage"><span class="no">02</span><div class="pin"></div><h3>Design &amp; planning</h3><p>We develop the scope, design, material selections, and project plan.</p></li>
    <li class="stage"><span class="no">03</span><div class="pin"></div><h3>Estimate &amp; agreement</h3><p>You receive a clear proposal outlining the scope, pricing, and payment schedule.</p></li>
    <li class="stage"><span class="no">04</span><div class="pin"></div><h3>Permits &amp; preparation</h3><p>We coordinate permits when required, order materials, and prepare your project for construction.</p></li>
    <li class="demo" aria-label="Demolition begins here"><span class="flag mono">Demo ▼</span><span class="cut"></span></li>
    <li class="stage"><span class="no">05</span><div class="pin"></div><h3>Construction</h3><p>Our team manages the project from demolition through installation, with clear communication throughout.</p></li>
    <li class="stage"><span class="no">06</span><div class="pin"></div><h3>Final walkthrough</h3><p>We review every detail together, complete final touch-ups, and make sure your new space is ready to enjoy.</p></li>
  </ol>
HTML

def strip_tags(s); s.gsub(/<[^>]+>/, ""); end

def options_html(o)
  return "" unless o
  cards = o[:cards].each_with_index.map { |(h, p, bullets), i|
    %(      <article class="opt#{i == o[:cards].size - 1 ? ' feat' : ''}">
        <span class="mono">Option 0#{i + 1}</span>
        <h3>#{h}</h3>
        <p>#{p}</p>
        <ul>#{bullets.map { |b| "<li>#{b}</li>" }.join}</ul>
      </article>)
  }.join("\n")
  table = ""
  if (t = o[:table])
    head = t[:cols].map { |c| %(<th scope="col">#{c}</th>) }.join
    body = t[:rows].map { |r| %(<tr><th scope="row">#{r[0]}</th>#{r[1..].map { |c| "<td>#{c}</td>" }.join}</tr>) }.join("\n          ")
    table = <<~T
      <div class="cmp-wrap">
        <table class="cmp">
          <caption class="mono">#{t[:caption]}</caption>
          <thead><tr><th scope="col"></th>#{head}</tr></thead>
          <tbody>
          #{body}
          </tbody>
        </table>
      </div>
    T
  end
  <<~HTML
    <!-- OPTIONS -->
    <section class="sheet sec" id="options" aria-labelledby="opt-t">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">#{o[:eyebrow]}</p><h2 id="opt-t">#{o[:h]}</h2></div>
          <p>#{o[:p]}</p>
        </div>
        <div class="opts">
    #{cards}
        </div>
    #{table}  </div>
    </section>

  HTML
end

def gallery_html(keys)
  return "" if keys.empty?
  mixed = keys.any? { |k| !PHOTOS[k][:land] }
  cards = keys.each_with_index.map { |k, i|
    g = PHOTOS[k]
    %(    <article class="proj#{mixed && g[:land] ? " span2" : ""}">
      <div class="frame photo#{g[:land] && !mixed ? " land" : ""}"><img src="#{g[:src]}" width="#{g[:w]}" height="#{g[:h]}" loading="lazy" alt="#{g[:alt]}"><span class="mono">#{g[:tag]}</span></div>
      <div class="meta"><div><h3>#{g[:title]}</h3><p>#{g[:sub]}</p></div><span class="mono">#{format("%02d", i + 1)}</span></div>
    </article>)
  }.join("\n")
  <<~HTML
    <!-- PROJECTS -->
    <section class="sheet sec" aria-labelledby="work-t" style="background:var(--paper-2)">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">Recent work</p><h2 id="work-t">From our <em>projects.</em></h2></div>
          <p>A few finished rooms from homes around Seattle.</p>
        </div>
      </div>
      <div class="reel">
    #{cards}
      </div>
    </section>

  HTML
end

def page(pg)
  ph = pg[:photo] && PHOTOS[pg[:photo]]
  hero_cls = ph ? "hero dark photo short" : "hero dark plain short"
  bg = ph ? %(\n  <div class="bg"><img src="#{ph[:src]}" width="#{ph[:w]}" height="#{ph[:h]}" alt="" fetchpriority="high"></div>) : ""
  tags = pg[:tags].map { |t| "<li>#{t}</li>" }.join
  incl = pg[:incl].each_with_index.map { |(h, p), i| %(<div><span class="mono" style="color:var(--gold)">0#{i + 1}</span><h3>#{h}</h3><p>#{p}</p></div>) }.join("\n      ")
  q = QUOTES[pg[:quote]]
  faq = pg[:faq].each_with_index.map { |(qq, a), i|
    %(<details#{i.zero? ? ' open' : ''}><summary><span class="mono">0#{i + 1}</span>#{qq}<span class="pm" aria-hidden="true"></span></summary>\n          <p>#{a}</p></details>)
  }.join("\n        ")
  rel = ALL.reject { |s| s[:slug] == pg[:slug] }.map { |s| %(<a href="#{s[:slug]}.html">#{s[:name]}<span class="ar" aria-hidden="true">→</span></a>) }.join("\n      ")
  service_type = strip_tags(pg[:eyebrow]).gsub("&amp;", "&")

  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#{pg[:title]} · Julius Remodeling Group</title>
    <meta name="description" content="#{pg[:meta]}">
    <meta name="theme-color" content="#0b0a09">
    <link rel="icon" type="image/png" href="assets/favicon.png">
    <link rel="apple-touch-icon" href="assets/apple-touch-icon.png">
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="Julius Remodeling Group">
    <meta property="og:title" content="#{pg[:title]} · Julius Remodeling Group">
    <meta property="og:description" content="#{pg[:meta]}">
    <meta property="og:image" content="assets/logo.jpg">
    <meta name="twitter:card" content="summary">
    <script type="application/ld+json">
    {"@context":"https://schema.org","@type":"Service","serviceType":"#{service_type}","provider":{"@type":"GeneralContractor","name":"Julius Remodeling Group","telephone":"+1-425-699-9636","url":"https://juliusremodeling.com/"},"areaServed":["Seattle","Bellevue","Mercer Island","Eastside"],"url":"https://juliusremodeling.com/#{pg[:slug]}"}
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,500;0,600;1,500&family=Geist:wght@400;500;600&display=swap" rel="stylesheet">
    <script>document.documentElement.className+=' js'</script>
    <link rel="stylesheet" href="site.css">
    </head>
    <body>

    #{header(pg[:slug])}

    <main id="top">

    <!-- HERO -->
    <section class="#{hero_cls}" aria-labelledby="h1">#{bg}
      <div class="wrap hero-in">
        <p class="eyebrow">#{pg[:eyebrow]}</p>
        <h1 id="h1">#{pg[:h1]}</h1>
        <p class="lede">#{pg[:lede]}</p>
        <div class="hero-ctas">
          <a href="consultation.html" class="btn btn-brass">Book a free consultation <span class="ar" aria-hidden="true">→</span></a>
          <a href="tel:" data-tel class="btn btn-line">Call <span data-k="phone">[Phone]</span></a>
        </div>
        <ul class="tags" aria-label="What's included">#{tags}</ul>
      </div>
      <div class="wrap">
        <dl class="creds">
          <div><dt class="mono">License</dt><dd>WA <span data-k="license">[License #]</span></dd></div>
          <div><dt class="mono">Insurance</dt><dd data-k="insurance">[Insurance details]</dd></div>
          <div><dt class="mono">Rating</dt><dd>4.98 ★ from 58 reviews</dd></div>
          <div><dt class="mono">Jobs completed</dt><dd>481</dd></div>
        </dl>
      </div>
    </section>

    <!-- ONES -->
    <div class="ones" role="list" aria-label="Under one roof">
      <div role="listitem"><span class="n"><i>team</i></span><p>One management team, a single point of contact from start to finish.</p></div>
      <div role="listitem"><span class="n"><i>license</i></span><p>Every trade works under our license and accountability.</p></div>
      <div role="listitem"><span class="n"><i>budget</i></span><p>Agreed before demolition, with change orders in writing.</p></div>
      <div role="listitem"><span class="n"><i>vision</i></span><p>One coordinated team building to one clear design.</p></div>
    </div>

    <!-- INCLUDED -->
    <section class="dark sec" aria-labelledby="incl-t">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">What's included</p><h2 id="incl-t">#{pg[:incl_h]}</h2></div>
          <p>#{pg[:incl_p]}</p>
        </div>
        <div class="incl">
          #{incl}
        </div>
      </div>
    </section>

    #{options_html(pg[:options])}#{gallery_html(pg[:gallery])}#{pg[:extra]}<!-- PROCESS -->
    <section class="sheet sec" aria-labelledby="proc-t">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">Process</p><h2 id="proc-t">A simple process. <em>Better results.</em></h2></div>
          <p>Better planning, better building, better results. Four of the six steps happen before anything is torn out.</p>
        </div>
    #{PROCESS.gsub(/^/, '    ').chomp}
      </div>
    </section>

    <!-- REVIEW -->
    <section class="sheet sec" aria-label="Client review" style="background:var(--paper-2)">
      <div class="wrap one-quote">
        <figure class="quote">
          <span class="stars" aria-label="5 out of 5 stars">★★★★★</span>
          <blockquote style="margin:0"><p>“#{q[0]}”</p></blockquote>
          <figcaption><cite><b>#{q[1]}</b> · #{q[2]} · <a href="index.html#reviews" style="text-decoration:underline">4.98 average from 58 reviews</a></cite></figcaption>
        </figure>
      </div>
    </section>

    <!-- FAQ -->
    <section class="sheet sec" aria-labelledby="faq-t">
      <div class="wrap">
        <div class="faq">
          <div class="head">
            <div><p class="eyebrow">FAQ</p><h2 id="faq-t">#{pg[:short]} <em>questions.</em></h2></div>
            <p>Anything else, ask us at your consultation.</p>
          </div>
          <div>
            #{faq}
          </div>
        </div>
      </div>
    </section>

    <!-- OTHER SERVICES -->
    <section class="sheet sec" aria-labelledby="rel-t" style="background:var(--paper-2)">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">More services</p><h2 id="rel-t">Other ways <em>we can help.</em></h2></div>
          <p>Complete general contractor remodeling, A to Z.</p>
        </div>
        <div class="rel">
          #{rel}
        </div>
      </div>
    </section>

    <!-- CTA BAND -->
    <section class="cta-band" aria-labelledby="cta-t">
      <div class="wrap">
        <div>
          <h2 id="cta-t">Ready to start <em>your project?</em></h2>
          <p>Book a free consultation. We'll talk through your ideas, priorities, and budget, with no obligation.</p>
        </div>
        <div class="acts">
          <a href="consultation.html" class="btn btn-night">Book a free consultation <span class="ar" aria-hidden="true">→</span></a>
          <a href="tel:" data-tel class="btn btn-line-n">Call <span data-k="phone">[Phone]</span></a>
        </div>
      </div>
    </section>

    </main>

    #{footer}

    <nav class="mbar" aria-label="Quick actions"><a href="tel:" data-tel class="f-call"><svg viewBox="0 0 24 24" width="17" height="17" aria-hidden="true"><path fill="currentColor" d="M6.6 10.8a15.1 15.1 0 0 0 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1A17 17 0 0 1 3 4c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.2 1l-2.3 2.2z"/></svg><span>Call <span class="num" data-k="phone">(425) 699-9636</span></span></a><a href="consultation.html" class="f-cta">Free consultation <span aria-hidden="true">→</span></a></nav>

    <script src="site.js"></script>
    </body>
    </html>
  HTML
end

# ================================================================ CITY PAGES
# Each city has its own wording so the pages are genuinely different
# (search engines ignore near-identical "city name swapped" pages).
CITY_PAGES = {
  "remodeling-seattle-wa" => {
    h1: "Seattle home remodeling, <em>start to finish.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Seattle houses, condos, and apartments, from early-1900s Craftsmans to downtown high-rises.",
    homes_h: "Remodeling Seattle's <em>older homes.</em>",
    homes: [
      "Many Seattle neighborhoods are full of early-1900s Craftsmans, bungalows, and Tudors with original plumbing, wiring, and layouts that were never designed for how people live today. We plan for what's behind the walls before demolition, so updates to plumbing and electrical are part of the scope and budget from day one.",
      "Seattle also has thousands of condos and apartments, where HOA approvals, elevator bookings, and building rules matter as much as the construction. We handle both.",
    ],
    hoods: ["Ballard", "Capitol Hill", "Queen Anne", "Magnolia", "Fremont", "Wallingford", "Green Lake", "Ravenna", "West Seattle", "Madison Park"],
    permits: "City of Seattle (SDCI)",
    condo: true,
    photo: "bath-1", quote: :rebecca,
    nearby: %w[remodeling-shoreline-wa remodeling-mercer-island-wa remodeling-bellevue-wa],
  },
  "remodeling-bellevue-wa" => {
    h1: "Bellevue remodeling, <em>from our Bellevue office.</em>",
    lede: "Our office is on Bellevue Way NE, so Bellevue is home turf: kitchens, bathrooms, basements, and whole-home remodels for houses, condos, and apartments across the city.",
    homes_h: "Bellevue homes, <em>brought up to date.</em>",
    homes: [
      "Much of Bellevue was built in the 1950s through the 1970s, and many of those ramblers and split-levels still have closed-off kitchens, original bathrooms, and dated basements. Opening up a kitchen, updating baths, and finishing lower levels are some of the most common projects we plan here.",
      "Downtown Bellevue's high-rise condos need a different kind of planning: HOA approvals, certificates of insurance, and elevator reservations are arranged before any work starts.",
    ],
    hoods: ["Downtown Bellevue", "West Bellevue", "Enatai", "Somerset", "Woodridge", "Newport Hills", "Crossroads", "Bridle Trails"],
    permits: "City of Bellevue",
    condo: true,
    photo: "bath-2", quote: :david,
    nearby: %w[remodeling-mercer-island-wa remodeling-kirkland-wa remodeling-redmond-wa],
  },
  "remodeling-mercer-island-wa" => {
    h1: "Mercer Island remodeling, <em>done with care.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Mercer Island homes, planned in detail and built by one team, minutes from our Bellevue office.",
    homes_h: "Island homes, <em>thoughtfully updated.</em>",
    homes: [
      "Mercer Island has many mid-century homes on generous lots, along with newer custom houses. Projects here often mean updating a kitchen or primary bathroom to match the quality of the rest of the home, or remodeling several rooms together as one design.",
      "We've worked with Mercer Island homeowners who say it best: one team, smooth communication, and an end result better than they imagined.",
    ],
    hoods: ["North End", "Town Center", "First Hill", "East Seattle", "Mercerdale", "South End"],
    permits: "City of Mercer Island",
    condo: false,
    photo: "bath-1", quote: :david,
    nearby: %w[remodeling-bellevue-wa remodeling-seattle-wa remodeling-renton-wa],
  },
  "remodeling-kirkland-wa" => {
    h1: "Kirkland home remodeling, <em>planned right.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Kirkland houses, townhomes, and condos, from Juanita to Houghton.",
    homes_h: "From lakefront condos <em>to family homes.</em>",
    homes: [
      "Kirkland mixes older single-family neighborhoods with newer townhomes and condos near downtown and Totem Lake. Whether it's a kitchen in a 1970s home or a bathroom in a waterfront condo, the plan, budget, and schedule are agreed before demolition.",
      "For condos and townhomes with an HOA, we handle the approvals and building rules so you don't have to.",
    ],
    hoods: ["Juanita", "Finn Hill", "Totem Lake", "Rose Hill", "Houghton", "Moss Bay", "Market", "Bridle Trails"],
    permits: "City of Kirkland",
    condo: true,
    photo: "laundry", quote: :rebecca,
    nearby: %w[remodeling-bellevue-wa remodeling-redmond-wa remodeling-bothell-wa],
  },
  "remodeling-redmond-wa" => {
    h1: "Redmond remodeling for <em>busy households.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Redmond homes and townhomes, managed by one team so you can keep working while we build.",
    homes_h: "Suburban homes, <em>made to fit today.</em>",
    homes: [
      "Many Redmond homes were built from the 1970s through the 1990s, with kitchens and bathrooms that are ready for an update. Common projects include opening up the kitchen, adding an island, converting a tub to a walk-in shower, and finishing a basement or bonus room.",
      "Clear communication matters when you're working from home. You'll know what's happening each day, and work areas are protected and contained.",
    ],
    hoods: ["Education Hill", "Downtown Redmond", "Overlake", "Grass Lawn", "Bear Creek", "Idylwood"],
    permits: "City of Redmond",
    condo: false,
    photo: "bath-2", quote: :rebecca,
    nearby: %w[remodeling-kirkland-wa remodeling-sammamish-wa remodeling-bellevue-wa],
  },
  "remodeling-sammamish-wa" => {
    h1: "Sammamish home remodeling, <em>one plan.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Sammamish family homes, from Klahanie to Sahalee.",
    homes_h: "Bigger homes, <em>bigger plans.</em>",
    homes: [
      "Sammamish is mostly single-family homes built in recent decades, many with large kitchens, primary suites, and basements or bonus rooms that are ready for a refresh. These projects often touch several rooms at once, which is where one design, one schedule, and one budget make the biggest difference.",
      "We handle the trades, the permits, and the scheduling, so the house keeps working for your family during the project.",
    ],
    hoods: ["Pine Lake", "Klahanie", "Sahalee", "Trossachs", "Plateau", "Beaver Lake"],
    permits: "City of Sammamish",
    condo: false,
    photo: "laundry", quote: :david,
    nearby: %w[remodeling-issaquah-wa remodeling-redmond-wa remodeling-bellevue-wa],
  },
  "remodeling-issaquah-wa" => {
    h1: "Issaquah remodeling, <em>from Olde Town to the Highlands.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Issaquah houses, townhomes, and condos.",
    homes_h: "Every kind of home, <em>one standard.</em>",
    homes: [
      "Issaquah ranges from older homes near Olde Town to newer master-planned communities like the Issaquah Highlands and Talus. Older homes often need plumbing and electrical updates alongside the new finishes, while newer homes are usually ready for upgraded kitchens, bathrooms, and flooring.",
      "Townhomes and condos with an HOA get the approvals and building coordination handled before work starts.",
    ],
    hoods: ["Olde Town", "Issaquah Highlands", "Talus", "Squak Mountain", "Montreux", "Providence Point"],
    permits: "City of Issaquah",
    condo: true,
    photo: "bath-1", quote: :rebecca,
    nearby: %w[remodeling-sammamish-wa remodeling-bellevue-wa remodeling-renton-wa],
  },
  "remodeling-bothell-wa" => {
    h1: "Bothell home remodeling, <em>handled.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Bothell homes on both sides of the county line.",
    homes_h: "Homes in two counties, <em>one team.</em>",
    homes: [
      "Bothell sits in both King and Snohomish counties, with established neighborhoods, newer subdivisions around Canyon Park and North Creek, and a growing downtown. We coordinate permits with the city when your project requires them, wherever your home is.",
      "Common Bothell projects include kitchen updates, bathroom remodels, new flooring throughout, and finishing basements and bonus rooms.",
    ],
    hoods: ["Downtown Bothell", "Canyon Park", "North Creek", "Thrasher's Corner", "Westhill", "Maywood"],
    permits: "City of Bothell",
    condo: false,
    photo: "bath-2", quote: :david,
    nearby: %w[remodeling-kirkland-wa remodeling-shoreline-wa remodeling-redmond-wa],
  },
  "remodeling-renton-wa" => {
    h1: "Renton remodeling, <em>built to last.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Renton houses, townhomes, and condos, from the Highlands to Kennydale.",
    homes_h: "Updating Renton <em>homes, room by room.</em>",
    homes: [
      "Renton has many mid-century homes, especially in the Highlands and Kennydale, along with newer neighborhoods and condos near The Landing. Older homes often benefit from updated plumbing, electrical, and layouts, while newer ones are usually ready for kitchen, bath, and flooring upgrades.",
      "Whether it's one bathroom or the whole house, the scope and budget are agreed in writing before demolition.",
    ],
    hoods: ["Renton Highlands", "Kennydale", "Benson Hill", "Fairwood", "Talbot Hill", "The Landing"],
    permits: "City of Renton",
    condo: true,
    photo: "laundry", quote: :rebecca,
    nearby: %w[remodeling-mercer-island-wa remodeling-bellevue-wa remodeling-issaquah-wa],
  },
  "remodeling-shoreline-wa" => {
    h1: "Shoreline home remodeling, <em>done right.</em>",
    lede: "Kitchens, bathrooms, basements, and whole-home remodels for Shoreline homes, from Richmond Beach to North City.",
    homes_h: "Post-war homes, <em>made new again.</em>",
    homes: [
      "Much of Shoreline was built in the 1940s through the 1960s, and many of those ramblers have small, closed-off kitchens and original bathrooms. Opening up the kitchen, remodeling the bathroom, refinishing floors, and finishing basements are some of the projects that make the biggest difference here.",
      "Older homes can hold surprises behind the walls. If we find something unexpected, you see it, and the price to fix it, before we continue.",
    ],
    hoods: ["Richmond Beach", "Innis Arden", "Ridgecrest", "Echo Lake", "North City", "Briarcrest"],
    permits: "City of Shoreline",
    condo: false,
    photo: "bath-1", quote: :david,
    nearby: %w[remodeling-seattle-wa remodeling-bothell-wa remodeling-kirkland-wa],
  },
}

def head_html(title, meta, ld)
  <<~HTML.chomp
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#{title} · Julius Remodeling Group</title>
    <meta name="description" content="#{meta}">
    <meta name="theme-color" content="#0b0a09">
    <link rel="icon" type="image/png" href="assets/favicon.png">
    <link rel="apple-touch-icon" href="assets/apple-touch-icon.png">
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="Julius Remodeling Group">
    <meta property="og:title" content="#{title} · Julius Remodeling Group">
    <meta property="og:description" content="#{meta}">
    <meta property="og:image" content="assets/logo.jpg">
    <meta name="twitter:card" content="summary">
    <script type="application/ld+json">
    #{ld}
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,500;0,600;1,500&family=Geist:wght@400;500;600&display=swap" rel="stylesheet">
    <script>document.documentElement.className+=' js'</script>
    <link rel="stylesheet" href="site.css">
    </head>
  HTML
end

def cta_band(h = "Ready to start <em>your project?</em>")
  <<~HTML.chomp
    <section class="cta-band" aria-labelledby="cta-t">
      <div class="wrap">
        <div>
          <h2 id="cta-t">#{h}</h2>
          <p>Book a free consultation. We'll talk through your ideas, priorities, and budget, with no obligation.</p>
        </div>
        <div class="acts">
          <a href="consultation.html" class="btn btn-night">Book a free consultation <span class="ar" aria-hidden="true">→</span></a>
          <a href="tel:" data-tel class="btn btn-line-n">Call <span data-k="phone">[Phone]</span></a>
        </div>
      </div>
    </section>
  HTML
end

def tail_html
  %(<nav class="mbar" aria-label="Quick actions"><a href="tel:" data-tel class="f-call"><svg viewBox="0 0 24 24" width="17" height="17" aria-hidden="true"><path fill="currentColor" d="M6.6 10.8a15.1 15.1 0 0 0 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1A17 17 0 0 1 3 4c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.2 1l-2.3 2.2z"/></svg><span>Call <span class="num" data-k="phone">(425) 699-9636</span></span></a><a href="consultation.html" class="f-cta">Free consultation <span aria-hidden="true">→</span></a></nav>\n\n<script src="site.js"></script>\n</body>\n</html>\n)
end

LD_BUSINESS = ->(area, url) { %({"@context":"https://schema.org","@type":"GeneralContractor","name":"Julius Remodeling Group","image":"https://juliusremodeling.com/assets/logo.jpg","telephone":"+1-425-699-9636","url":"#{url}","address":{"@type":"PostalAddress","streetAddress":"800 Bellevue Way NE, Suite 500","addressLocality":"Bellevue","addressRegion":"WA","postalCode":"98004","addressCountry":"US"},"areaServed":#{area},"aggregateRating":{"@type":"AggregateRating","ratingValue":"4.98","ratingCount":"58","bestRating":"5"}}) }

def city_page(area)
  c = CITY_PAGES.fetch(area[:slug])
  city = area[:name]
  ph = PHOTOS[c[:photo]]
  q = QUOTES[c[:quote]]
  svc = ALL.map { |s| %(<a href="#{s[:slug]}.html">#{s[:name]}<span class="ar" aria-hidden="true">→</span></a>) }.join("\n      ")
  hoods = c[:hoods].map { |h| "<li>#{h}</li>" }.join
  homes = c[:homes].map { |p| "<p>#{p}</p>" }.join("\n        ")
  nearby = c[:nearby].map { |sl| a = AREAS.find { |x| x[:slug] == sl }; %(<a href="#{sl}.html">#{a[:name]}<span class="ar" aria-hidden="true">→</span></a>) }.join("\n      ")
  faq = [
    ["Do you work in #{city}?", "Yes. Julius Remodeling Group remodels homes throughout #{city}, including #{c[:hoods].first(3).join(', ')}, and nearby areas. Our office is at 800 Bellevue Way NE in Bellevue."],
    ["Do you handle permits in #{city}?", "Yes. We coordinate permits with the #{c[:permits]} whenever your project requires them, as part of preparing your project before construction begins."],
    (c[:condo] ? ["Do you remodel condos and apartments in #{city}?", "Yes. We handle the HOA approvals, certificates of insurance, elevator reservations, and work-hour rules that buildings require. #{CONDO_LINK}."] :
                 ["Can you remodel just one room?", "Yes. Whether it's a single bathroom or the whole house, the process is the same: organized, transparent, and carefully executed."]),
    ["How do I get started?", "Book a free consultation. We'll meet, discuss your ideas, needs, priorities, and budget, and then send you a clear proposal."],
  ].each_with_index.map { |(qq, a), i| %(<details#{i.zero? ? ' open' : ''}><summary><span class="mono">0#{i + 1}</span>#{qq}<span class="pm" aria-hidden="true"></span></summary>\n          <p>#{a}</p></details>) }.join("\n        ")
  title = "Home Remodeling in #{city}, WA"
  meta = "Kitchen, bathroom, basement, and whole-home remodeling in #{city}, WA. Licensed, insured, and bonded general contractor serving #{c[:hoods].first(3).join(', ')}, and all of #{city}."
  ld = LD_BUSINESS.(%({"@type":"City","name":"#{city}, WA"}), "https://juliusremodeling.com/#{area[:slug]}")

  <<~HTML
    #{head_html(title, meta, ld)}
    <body>

    #{header(area[:slug])}

    <main id="top">

    <!-- HERO -->
    <section class="hero dark photo short" aria-labelledby="h1">
      <div class="bg"><img src="#{ph[:src]}" width="#{ph[:w]}" height="#{ph[:h]}" alt="" fetchpriority="high"></div>
      <div class="wrap hero-in">
        <p class="eyebrow">Remodeling in #{city}, WA</p>
        <h1 id="h1">#{c[:h1]}</h1>
        <p class="lede">#{c[:lede]}</p>
        <div class="hero-ctas">
          <a href="consultation.html" class="btn btn-brass">Book a free consultation <span class="ar" aria-hidden="true">→</span></a>
          <a href="tel:" data-tel class="btn btn-line">Call <span data-k="phone">[Phone]</span></a>
        </div>
        <ul class="tags" aria-label="#{city} neighborhoods we serve">#{c[:hoods].first(6).map { |h| "<li>#{h}</li>" }.join}</ul>
      </div>
      <div class="wrap">
        <dl class="creds">
          <div><dt class="mono">License</dt><dd>WA <span data-k="license">[License #]</span></dd></div>
          <div><dt class="mono">Insurance</dt><dd data-k="insurance">[Insurance details]</dd></div>
          <div><dt class="mono">Rating</dt><dd>4.98 ★ from 58 reviews</dd></div>
          <div><dt class="mono">Office</dt><dd>Bellevue Way NE, Bellevue</dd></div>
        </dl>
      </div>
    </section>

    <!-- ONES -->
    <div class="ones" role="list" aria-label="Under one roof">
      <div role="listitem"><span class="n"><i>team</i></span><p>One management team, a single point of contact from start to finish.</p></div>
      <div role="listitem"><span class="n"><i>license</i></span><p>Every trade works under our license and accountability.</p></div>
      <div role="listitem"><span class="n"><i>budget</i></span><p>Agreed before demolition, with change orders in writing.</p></div>
      <div role="listitem"><span class="n"><i>vision</i></span><p>One coordinated team building to one clear design.</p></div>
    </div>

    <!-- LOCAL -->
    <section class="sheet sec" aria-labelledby="homes-t">
      <div class="wrap">
        <div class="about" style="margin-bottom:0">
          <div class="ph"><img src="#{ph[:src]}" width="#{ph[:w]}" height="#{ph[:h]}" loading="lazy" alt="#{ph[:alt]}"></div>
          <div class="txt">
            <p class="eyebrow">#{city} homes</p>
            <h2 id="homes-t">#{c[:homes_h]}</h2>
            #{homes}
            <div class="hoods"><span class="mono">Neighborhoods we serve in #{city}</span><ul>#{hoods}</ul></div>
          </div>
        </div>
      </div>
    </section>

    <!-- SERVICES -->
    <section class="sheet sec" aria-labelledby="svc-t" style="background:var(--paper-2)">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">Services in #{city}</p><h2 id="svc-t">What we remodel <em>in #{city}.</em></h2></div>
          <p>Complete general contractor remodeling, A to Z: design, permits, materials, construction, and the finishing details.</p>
        </div>
        <div class="rel">
          #{svc}
        </div>
      </div>
    </section>

    <!-- PROCESS -->
    <section class="sheet sec" aria-labelledby="proc-t">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">Process</p><h2 id="proc-t">A simple process. <em>Better results.</em></h2></div>
          <p>Four of the six steps happen before anything is torn out, including permits with the #{c[:permits]} when required.</p>
        </div>
    #{PROCESS.gsub(/^/, '    ').chomp}
      </div>
    </section>

    <!-- REVIEW -->
    <section class="sheet sec" aria-label="Client review" style="background:var(--paper-2)">
      <div class="wrap one-quote">
        <figure class="quote">
          <span class="stars" aria-label="5 out of 5 stars">★★★★★</span>
          <blockquote style="margin:0"><p>“#{q[0]}”</p></blockquote>
          <figcaption><cite><b>#{q[1]}</b> · #{q[2]} · <a href="index.html#reviews" style="text-decoration:underline">4.98 average from 58 reviews</a></cite></figcaption>
        </figure>
      </div>
    </section>

    <!-- FAQ -->
    <section class="sheet sec" aria-labelledby="faq-t">
      <div class="wrap">
        <div class="faq">
          <div class="head">
            <div><p class="eyebrow">FAQ</p><h2 id="faq-t">#{city} <em>questions.</em></h2></div>
            <p>Anything else, ask us at your consultation.</p>
          </div>
          <div>
            #{faq}
          </div>
        </div>
      </div>
    </section>

    <!-- NEARBY -->
    <section class="sheet sec" aria-labelledby="near-t" style="background:var(--paper-2)">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">Nearby</p><h2 id="near-t">Also serving <em>nearby.</em></h2></div>
          <p><a href="service-areas.html" style="text-decoration:underline">See all the areas we serve</a>.</p>
        </div>
        <div class="rel">
          #{nearby}
        </div>
      </div>
    </section>

    #{cta_band("Remodeling in #{city}? <em>Let's talk.</em>")}

    </main>

    #{footer}

    #{tail_html}
  HTML
end

def areas_hub
  cards = AREAS.map { |a|
    c = CITY_PAGES[a[:slug]]
    %(<a class="area-card" href="#{a[:slug]}.html"><span class="mono">#{c[:hoods].first(3).join(' · ')}</span><b>#{a[:name]}</b><span class="go">Remodeling in #{a[:name]} <span aria-hidden="true">→</span></span></a>)
  }.join("\n      ")
  ld = LD_BUSINESS.("[" + AREAS.map { |a| %({"@type":"City","name":"#{a[:name]}, WA"}) }.join(",") + "]", "https://juliusremodeling.com/service-areas")
  <<~HTML
    #{head_html("Service Areas: Seattle &amp; the Eastside", "Julius Remodeling Group serves Seattle, Bellevue, Mercer Island, Kirkland, Redmond, Sammamish, Issaquah, Bothell, Renton, and Shoreline with kitchen, bathroom, basement, and whole-home remodeling.", ld)}
    <body>

    #{header("service-areas")}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">Service areas</p>
        <h1 id="h1">Remodeling across Seattle <em>&amp; the Eastside.</em></h1>
        <p class="lede">From our office on Bellevue Way NE, we remodel kitchens, bathrooms, basements, and whole homes in these cities and the neighborhoods around them. Choose your city to learn more.</p>
      </div>
    </section>

    <section class="sheet sec" aria-label="Cities we serve" style="padding-top:clamp(56px,6vw,96px)">
      <div class="wrap">
        <div class="area-grid">
          #{cards}
        </div>
        <a class="callout" href="consultation.html">
          <span class="mono">Not on the list?</span>
          <span class="ct">We may still be able to help with your project. <em>Book a free consultation</em> and tell us where you are.</span>
          <span class="ar" aria-hidden="true">→</span>
        </a>
      </div>
    </section>

    #{cta_band}

    </main>

    #{footer}

    #{tail_html}
  HTML
end

# Home page "Areas we serve" section (inserted before the gold band, replaced on rebuild)
def home_areas_section
  cards = AREAS.map { |a| %(<a class="area-card" href="#{a[:slug]}.html"><span class="mono">#{CITY_PAGES[a[:slug]][:hoods].first(2).join(' · ')}</span><b>#{a[:name]}</b><span class="go">View <span aria-hidden="true">→</span></span></a>) }.join("\n      ")
  <<~HTML.chomp
    <!-- AREAS -->
    <section class="sheet sec" id="areas" aria-labelledby="areas-t">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">Service areas</p><h2 id="areas-t">Proudly remodeling <em>Seattle &amp; the Eastside.</em></h2></div>
          <p>From our Bellevue office, we serve homeowners in these cities and the neighborhoods around them. <a href="service-areas.html" style="text-decoration:underline">See all service areas</a>.</p>
        </div>
        <div class="area-grid">
          #{cards}
        </div>
      </div>
    </section>
    <!-- /AREAS -->
  HTML
end

# ---------------------------------------------------------------- terms page

def terms_page
  tel = %(<a href="tel:" data-tel data-k="phone">[Phone]</a>)
  ld = %({"@context":"https://schema.org","@type":"WebPage","name":"Terms and Conditions","url":"https://juliusremodeling.com/terms-and-conditions","publisher":{"@type":"Organization","name":"Julius Remodeling Group"}})
  <<~HTML
    #{head_html("Terms &amp; Conditions", "Terms and conditions, including SMS terms, for Julius Remodeling Group: how to opt out of text messages, how to get help, message rates, and how your phone number is handled.", ld)}
    <body>

    #{header("terms-and-conditions")}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">Legal</p>
        <h1 id="h1">Terms <em>&amp; Conditions.</em></h1>
      </div>
    </section>

    <section class="sheet sec" aria-label="Terms and conditions" style="padding-top:clamp(56px,6vw,96px)">
      <div class="wrap">
        <div class="doc">
          <h2 id="terms">Terms &amp; Conditions</h2>
          <p>Julius Remodeling Group P.C. specializes in full-service residential construction, including remodels, additions, and new builds across Seattle and surrounding areas.</p>
          <p>You must be 18 years of age or older to use this SMS service.</p>
          <p>You can cancel the SMS service at any time. Just text “STOP” to #{tel}. After you send the SMS message “STOP” to us, we will send you an SMS message to confirm that you have been unsubscribed. After this, you will no longer receive SMS messages from us. If you want to join again, just sign up as you did the first time and we will start sending SMS messages to you again.</p>
          <p>If you are experiencing issues with the messaging program, you can reply with the keyword HELP for more assistance, or you can get help directly at <a href="mailto:ask@juliusremodeling.com">ask@juliusremodeling.com</a>.</p>
          <p>Carriers are not liable for delayed or undelivered messages.</p>
          <p>As always, message and data rates may apply for any messages sent to you from us and to us from you. If you have any questions about your text plan or data plan, it is best to contact your wireless provider.</p>
          <p>If you have any questions regarding privacy, please read our <a href="privacy-policy.html">privacy policy</a>.</p>

          <h2 id="sms">SMS Terms &amp; Conditions</h2>
          <p>By providing your mobile number, you consent to receive SMS messages from Julius Remodeling Group related to remodeling.</p>
          <p>Message frequency may vary.</p>
          <p>Standard message and data rates may apply.</p>
          <p>You may opt out of receiving SMS messages at any time by replying with “STOP” to any SMS message you receive from us. After opting out, you will receive a confirmation message and we will cease sending SMS messages to your number.</p>
          <p>If you need assistance or have any questions about our SMS service, reply with “HELP” to any message you receive or contact our customer support team at #{tel}.</p>
          <p>Your phone number will be handled with privacy in accordance with our <a href="privacy-policy.html">Privacy Policy</a>.</p>
          <p>No mobile information will be shared with third parties/affiliates for marketing/promotional purposes. All the above categories exclude text messaging originator opt-in data and consent; this information will not be shared with any third parties.</p>
        </div>
      </div>
    </section>

    </main>

    #{footer}

    #{tail_html}
  HTML
end

# ---------------------------------------------------------------- privacy policy page
def privacy_page
  ul = ->(items) { "<ul>" + items.map { |i| "<li>#{i}</li>" }.join + "</ul>" }
  ld = %({"@context":"https://schema.org","@type":"WebPage","name":"Privacy Policy","url":"https://juliusremodeling.com/privacy-policy","publisher":{"@type":"Organization","name":"Julius Remodeling Group"}})
  <<~HTML
    #{head_html("Privacy Policy", "How Julius Remodeling Group collects, uses, shares, and protects your information, including phone numbers and text messaging consent.", ld)}
    <body>

    #{header("privacy-policy")}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">Legal</p>
        <h1 id="h1">Privacy <em>Policy.</em></h1>
      </div>
    </section>

    <section class="sheet sec" aria-label="Privacy policy" style="padding-top:clamp(56px,6vw,96px)">
      <div class="wrap">
        <div class="doc">
          <p class="mono eff">Effective date: November 11, 2026</p>

          <h2>1. Introduction</h2>
          <p>Julius Remodeling Group P.C. (“Company,” “we,” “our,” or “us”) respects your privacy and is committed to protecting it through this Privacy Policy. This policy describes how we collect, use, disclose, and safeguard your information when you visit our website.</p>
          <p>By using our website, you agree to the terms of this Privacy Policy.</p>

          <h2>2. Information We Collect</h2>
          <h3>Personal Information</h3>
          <p>We may collect personally identifiable information that you voluntarily provide to us, including:</p>
          #{ul.(["Full name", "Email address", "Phone number", "Address or project location", "Any details you submit through contact forms or quote requests"])}
          <h3>Non-Personal Information</h3>
          <p>We may automatically collect certain information about your device and browsing activity, such as:</p>
          #{ul.(["IP address", "Browser type", "Operating system", "Pages visited and time spent on the website"])}

          <h2>3. How We Use Your Information</h2>
          <p>We use the information we collect to:</p>
          #{ul.(["Respond to inquiries and provide quotes", "Communicate about services, appointments, or projects", "Improve our website and customer experience", "Send updates or marketing communications (only if you opt in)", "Maintain security and prevent fraud"])}

          <h2>4. Sharing Your Information</h2>
          <p>We do not sell your data.</p>
          <p>We do not sell, trade or otherwise transfer to outside parties your personally identifiable information for marketing or promotional purposes. Your information will never be sold, exchanged, transferred or given to any other company for any reason whatsoever, without your consent, other than for the express purpose of delivering the purchased service requested.</p>
          <p>No mobile information will be shared with third parties or affiliates for marketing/promotional purposes.</p>
          <p>Text messaging originator opt-in data and consent will not be shared with any third parties, except for aggregators and providers of the text message services.</p>
          <p>No mobile information will be shared with third parties/affiliates for marketing/promotional purposes. Information sharing to subcontractors in support services, such as customer service, is permitted. All other use case categories exclude text messaging originator opt-in data and consent; this information will not be shared with any third parties.</p>

          <h2>5. Cookies and Tracking Technologies</h2>
          <p>Our website may use cookies and similar tracking technologies to:</p>
          #{ul.(["Enhance user experience", "Analyze website traffic", "Understand user behavior"])}
          <p>You can choose to disable cookies through your browser settings.</p>

          <h2>6. Data Security</h2>
          <p>We implement reasonable administrative, technical, and physical security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.</p>

          <h2>7. Your Privacy Rights</h2>
          <p>Depending on your location, you may have the right to:</p>
          #{ul.(["Request access to the personal data we hold about you", "Request correction or deletion of your data", "Opt out of marketing communications"])}
          <p>To exercise these rights, contact us using the information below.</p>

          <h2>8. Third-Party Links</h2>
          <p>Our website may contain links to third-party websites. We are not responsible for the privacy practices of those websites.</p>

          <h2>9. Children’s Privacy</h2>
          <p>You must be 18 years of age or older to use this SMS service.</p>

          <h2>10. Changes to This Privacy Policy</h2>
          <p>We may update this Privacy Policy from time to time. Changes will be posted on this page with an updated effective date.</p>

          <h2>11. Contact Us</h2>
          <p>If you have any questions about this Privacy Policy or how your information is handled, please contact us:</p>
          <p>Julius Remodeling Group P.C., based in Bellevue, Washington<br>
          Email: <a href="mailto:ask@juliusremodeling.com">ask@juliusremodeling.com</a><br>
          Phone: <a href="tel:" data-tel data-k="phone">[Phone]</a></p>

          <h2 id="sms">SMS Communications</h2>
          <p>Julius Remodeling Group P.C. uses SMS to communicate with customers about estimates, appointments, project updates, scheduling, invoices, payments, and customer support. Customers opt in by requesting a service, submitting a contact form, signing a proposal, or providing consent to receive text messages. Message frequency varies based on the project. Reply STOP to opt out at any time or HELP for assistance. Message and data rates may apply.</p>
        </div>
      </div>
    </section>

    </main>

    #{footer}

    #{tail_html}
  HTML
end

# ---------------------------------------------------------------- promotions
# To add, change, or remove a deal, edit this list and run: ruby tools/build-pages.rb .
# Each deal gets its own page (<slug>.html) and a card on promotions.html.
# form_id is that deal's GoHighLevel form; it opens in a pop-up from the "Claim this discount" buttons on that page only.
PROMOS = [
  { slug: "bathroom-remodel-offer", amount: "$1,500", project: "bathroom remodel", label: "Bathroom remodeling", service: "bathroom-remodeling", form_id: "zVU6tpjeGSNDg2uBhzmy", form_name: "$1500 Discount Bathroom Remodeling", form_height: 720,
    blurb: "Take $1,500 off a full bathroom remodel: tile, shower or tub, vanity, fixtures, and lighting, handled by one team." },
  { slug: "kitchen-remodel-offer",  amount: "$1,000", project: "kitchen remodel",  label: "Kitchen remodeling",  service: "kitchen-remodeling", form_id: "sV78tURz979hTq0AppZt", form_name: "$1000 Off Kitchen Upgrade", form_height: 400,
    blurb: "Take $1,000 off a kitchen remodel: cabinets, countertops, backsplash, flooring, and lighting, handled by one team." },
]
# Countdown timer from GoHighLevel. Change the timerId here to use a different timer.
PROMO_TIMER = %(<script src="https://widgets.leadconnectorhq.com/cdt/remoteEntry.js" timerId=6af4cf7678a6a6baacefb635 position="left" altText="Countdown Timer" data-v2='true'></script>)

def promo_ld(name, slug)
  %({"@context":"https://schema.org","@type":"WebPage","name":"#{name}","url":"https://juliusremodeling.com/#{slug}","publisher":{"@type":"Organization","name":"Julius Remodeling Group"}})
end

def promo_page(pr)
  form_url = "https://api.leadconnectorhq.com/widget/form/#{pr[:form_id]}"
  band = cta_band("Ready to save <em>#{pr[:amount]}?</em>").sub(%(<a href="consultation.html" class="btn btn-night">Book a free consultation), %(<a href="#{form_url}" data-claim class="btn btn-night">Claim this discount))
  title = "#{pr[:amount]} Off Your #{pr[:project].split.map(&:capitalize).join(' ')}"
  <<~HTML
    #{head_html(title, "Limited-time offer from Julius Remodeling Group: #{pr[:amount]} off your #{pr[:project]} in Seattle and the Eastside. Book a free consultation before the offer ends.", promo_ld(title, pr[:slug]))}
    <body>

    #{header(pr[:slug])}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">Limited-time offer</p>
        <h1 id="h1">#{pr[:amount]} off <em>your #{pr[:project]}.</em></h1>
        <p class="lede">#{pr[:blurb]} Claim it before the countdown ends.</p>
        <div class="promo-time">
          <span class="mono">Offer ends in</span>
          <div class="timer">#{PROMO_TIMER}</div>
        </div>
        <div class="promo-acts">
          <a href="#{form_url}" data-claim class="btn btn-brass">Claim this discount <span class="ar" aria-hidden="true">→</span></a>
          <a href="tel:" data-tel class="btn btn-line">Call <span data-k="phone">[Phone]</span></a>
        </div>
      </div>
    </section>

    <section class="sheet sec" aria-labelledby="how" style="padding-top:clamp(56px,6vw,96px)">
      <div class="wrap promo-how">
        <div>
          <p class="eyebrow">How it works</p>
          <h2 id="how">Three steps to <em>claim your discount.</em></h2>
          <p class="note">Want to see what goes into the work first? Read about our <a href="#{pr[:service]}.html">#{pr[:label].downcase}</a>.</p>
        </div>
        <div>
          <ol class="promo-steps">
            <li><span class="no">1</span><div><h3>Claim this discount</h3><p>Press the button and send us the short form before the countdown ends. There is no obligation.</p></div></li>
            <li><span class="no">2</span><div><h3>We'll contact you</h3><p>We'll get in touch to set up your free consultation and talk through your #{pr[:project]}.</p></div></li>
            <li><span class="no">3</span><div><h3>Save #{pr[:amount]}</h3><p>The discount comes off the price of your #{pr[:project]}.</p></div></li>
          </ol>
          <p class="fine">Terms and conditions apply.</p>
          <a href="#{form_url}" data-claim class="btn btn-ink" style="margin-top:24px">Claim this discount <span class="ar" aria-hidden="true">→</span></a>
        </div>
      </div>
    </section>

    #{band}

    </main>

    #{footer}

    <dialog class="claim" id="claim" aria-labelledby="claim-t">
      <div class="hd">
        <div><span class="mono">Limited-time offer</span><h2 id="claim-t">#{pr[:amount]} off your #{pr[:project]}</h2></div>
        <button type="button" class="x" aria-label="Close">×</button>
      </div>
      <iframe
        data-src="#{form_url}"
        id="inline-#{pr[:form_id]}"
        data-layout="{'id':'INLINE'}"
        data-trigger-type="alwaysShow"
        data-trigger-value=""
        data-activation-type="alwaysActivated"
        data-activation-value=""
        data-deactivation-type="neverDeactivate"
        data-deactivation-value=""
        data-form-name="#{pr[:form_name]}"
        data-height="#{pr[:form_height]}"
        data-layout-iframe-id="inline-#{pr[:form_id]}"
        data-form-id="#{pr[:form_id]}"
        style="height:#{pr[:form_height]}px;min-height:#{pr[:form_height]}px"
        title="#{pr[:form_name]}"></iframe>
      <p class="fallback">Form not loading? <a href="#{form_url}" target="_blank" rel="noopener">Open it in a new tab</a> or call us.</p>
    </dialog>

    #{tail_html}
  HTML
end

def promos_hub
  cards = PROMOS.map { |pr|
    %(<a class="promo-card" href="#{pr[:slug]}.html"><span class="mono">#{pr[:label]}</span><b>#{pr[:amount]} <em>off</em></b><p>#{pr[:blurb]}</p><span class="go">See this offer <span aria-hidden="true">→</span></span></a>)
  }.join("\n          ")
  <<~HTML
    #{head_html("Promotions &amp; Deals", "Current remodeling promotions from Julius Remodeling Group: #{PROMOS.map { |pr| "#{pr[:amount]} off a #{pr[:project]}" }.join(', ')}. Serving Seattle and the Eastside.", promo_ld("Promotions and Deals", "promotions"))}
    <body>

    #{header("promotions")}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">Promotions</p>
        <h1 id="h1">Current <em>promotions.</em></h1>
        <p class="lede">Limited-time savings on remodeling projects across Seattle and the Eastside. Choose an offer to see the details and how to claim it.</p>
      </div>
    </section>

    <section class="sheet sec" aria-label="Current offers" style="padding-top:clamp(56px,6vw,96px)">
      <div class="wrap">
        <div class="promo-grid">
          #{cards}
        </div>
        <a class="callout" href="consultation.html">
          <span class="mono">Different project?</span>
          <span class="ct">Planning something that isn't listed here? <em>Book a free consultation</em> and ask what we can do.</span>
          <span class="ar" aria-hidden="true">→</span>
        </a>
      </div>
    </section>

    #{cta_band}

    </main>

    #{footer}

    #{tail_html}
  HTML
end

# ================================================================ write files
PAGES.each { |pg| File.write(File.join(ROOT, "#{pg[:slug]}.html"), page(pg)) }
AREAS.each { |a| File.write(File.join(ROOT, "#{a[:slug]}.html"), city_page(a)) }
File.write(File.join(ROOT, "service-areas.html"), areas_hub)
File.write(File.join(ROOT, "terms-and-conditions.html"), terms_page)
File.write(File.join(ROOT, "privacy-policy.html"), privacy_page)
PROMOS.each { |pr| File.write(File.join(ROOT, "#{pr[:slug]}.html"), promo_page(pr)) }
File.write(File.join(ROOT, "promotions.html"), promos_hub)

{ "index.html" => [nil, true], "condo-remodeling.html" => ["condo-remodeling", false], "consultation.html" => ["consultation", false] }.each do |file, (cur, home)|
  path = File.join(ROOT, file)
  s = File.read(path)
  s = s.sub(%r{<header class="top[^"]*" id="hdr">.*?</header>}m) { header(cur, home: home) }
  s = s.sub(%r{<footer class="dark">.*?</footer>}m) { footer(home: home) }
  if home
    if s.include?("<!-- AREAS -->")
      s = s.sub(%r{<!-- AREAS -->.*?<!-- /AREAS -->}m) { home_areas_section }
    else
      s = s.sub("<!-- CTA BAND -->") { home_areas_section + "\n\n<!-- CTA BAND -->" }
    end
    s = s.sub(%r{<div class="areas">.*?</div>}m) {
      %(<div class="areas">\n          <span class="mono">Areas we serve</span>\n          <ul>#{AREAS.map { |a| %(<li><a href="#{a[:slug]}.html">#{a[:name]}</a></li>) }.join}</ul>\n        </div>)
    }
  end
  File.write(path, s)
end
puts "built #{PAGES.size} service pages, #{AREAS.size} city pages, and service-areas.html"

# sitemap.xml for search engines (the hidden consultation page is left out on purpose)
urls = [""] + ALL.map { |s| s[:slug] } + ["service-areas"] + AREAS.map { |a| a[:slug] } + ["promotions"] + PROMOS.map { |pr| pr[:slug] } + ["terms-and-conditions", "privacy-policy"]
File.write(File.join(ROOT, "sitemap.xml"), %(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n) +
  urls.map { |u| "  <url><loc>https://juliusremodeling.com/#{u}</loc></url>" }.join("\n") + "\n</urlset>\n")
puts "wrote sitemap.xml (#{urls.size} pages)"

# Google tag (container GTM-PFW84R3L): goes right after <head> on every page, once.
GOOGLE_TAG = <<~HTML.chomp
  <!-- Google tag -->
  <script async src="https://www.googletagmanager.com/gtm.js?id=GTM-PFW84R3L"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
  </script>
HTML
tagged = Dir.glob(File.join(ROOT, "*.html")).sort.count do |path|
  s = File.read(path)
  next true if s.include?("googletagmanager.com")
  File.write(path, s.sub("<head>") { "<head>\n#{GOOGLE_TAG}" })
  true
end
puts "Google tag present on #{tagged} pages"

# Accessibility: a "Skip to main content" link as the first thing on every page, and a focusable <main> for it to land on.
SKIP_LINK = %(<a class="skip" href="#top">Skip to main content</a>)
Dir.glob(File.join(ROOT, "*.html")).sort.each do |path|
  s = File.read(path)
  s = s.sub(/<body([^>]*)>/) { "<body#{$1}>\n#{SKIP_LINK}" } unless s.include?(%(class="skip"))
  s = s.sub(/<main(?![^>]*\bid=)/) { %(<main id="top") }
  s = s.sub(/<main(?![^>]*tabindex)([^>]*)>/) { "<main#{$1} tabindex=\"-1\">" }
  File.write(path, s)
end
puts "skip link present on every page"
