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
ADDITIONS = [
  { slug: "adu-dadu",                name: "ADU &amp; DADU" },
  { slug: "second-story-additions",  name: "Second-story additions" },
  { slug: "home-additions",          name: "Home additions" },
  { slug: "new-construction",        name: "New construction" },
]
EXTERIOR = [
  { slug: "roofing",              name: "Roofing" },
  { slug: "siding",               name: "Siding" },
  { slug: "window-replacement",   name: "Windows" },
  { slug: "decks",                name: "Decks" },
  { slug: "patios-and-pavers",    name: "Patios &amp; pavers" },
  { slug: "concrete-work",        name: "Concrete" },
  { slug: "driveways",            name: "Driveways" },
  { slug: "foundation-repair",    name: "Foundation repair" },
  { slug: "landscaping",          name: "Landscaping" },
  { slug: "fencing",              name: "Fencing" },
]
INTERIOR = [
  { slug: "flooring-installation",      name: "Flooring" },
  { slug: "interior-finish-carpentry",  name: "Interior finish &amp; carpentry" },
  { slug: "door-replacement",           name: "Doors" },
  { slug: "stairs-and-railings",        name: "Stairs &amp; railings" },
  { slug: "drywall-repair",             name: "Drywall repair" },
  { slug: "plumbing",                   name: "Plumbing" },
  { slug: "electrical",                 name: "Electrical" },
  { slug: "hvac",                       name: "Heating &amp; cooling" },
  { slug: "insulation",                 name: "Insulation" },
]
# Menu, footer, and home page show these groups. To add a service: add it to a group here and add its page to PAGES.
SERVICE_GROUPS = [
  ["Remodeling", REMODELING],
  ["Additions &amp; new builds", ADDITIONS],
  ["Exterior &amp; outdoor", EXTERIOR],
  ["Interior &amp; systems", INTERIOR],
]
ALL = REMODELING + ADDITIONS + EXTERIOR + INTERIOR
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
  promo_cur = (current == "specials" || current.to_s.end_with?("-offer")) ? ' aria-current="page"' : ""
  <<~HTML.chomp
    <header class="top#{current == 'consultation' ? ' solid' : ''}" id="hdr">#{holiday_bar(current)}
      <div class="wrap">
        <a href="#{home ? '#top' : 'index.html'}" class="logo" aria-label="Julius Remodeling Group, home"><img src="assets/wordmark.png" width="560" height="189" alt="Julius Remodeling Group"></a>
        <nav class="menu" id="nav" aria-label="Main">
          <a href="#{p}#work">Projects</a>
          <div class="dd svc"><a href="#{p}#services"#{svc_cur}>Services</a><div class="dd-panel two four">#{SERVICE_GROUPS.map { |(t, l)| %(<div><span class="mono">#{t}</span>#{links(l, current)}</div>) }.join}</div></div>
          <div class="dd"><a href="service-areas.html"#{area_cur}>Areas</a><div class="dd-panel areas">#{links(AREAS, current)}<a href="service-areas.html">All service areas</a></div></div>
          <a href="specials.html"#{promo_cur}>Specials</a>
          <a href="about.html"#{current == "about" ? ' aria-current="page"' : ""}>About</a><a href="#{p}#reviews">Reviews</a><a href="#{p}#contact">Contact</a>
        </nav>
        #{cta}
        <button class="burger" type="button" aria-label="Menu" aria-expanded="false" aria-controls="nav"><span></span><span></span><span></span></button>
      </div>
    </header>
  HTML
end

# ---------------------------------------------------------------- holiday campaign (Black Friday / holiday season)
# on: true shows the gold bar at the top of every page, the holiday section near the top of the home page,
# and the holiday heading on specials.html. Set on: false after the season and rebuild to remove all of it.
HOLIDAY = {
  on: true,
  tag: "Black Friday",
  eyebrow: "Black Friday &amp; holiday season",
  hub_lede: "Our Black Friday and holiday season specials are here.",
}
def holiday_max_amount
  PROMOS.max_by { |pr| pr[:amount].delete("^0-9").to_i }[:amount]
end
def holiday_bar(current)
  return "" unless HOLIDAY[:on]
  return "" if %w[specials consultation].include?(current.to_s)
  %(\n      <a class="hbar" href="specials.html"><span class="hb-tag">#{HOLIDAY[:tag]}</span><span class="hb-long">Holiday specials: up to #{holiday_max_amount} toward finish materials for your remodel</span><span class="hb-short">Holiday specials are here</span><span class="hb-go">See the specials <span aria-hidden="true">→</span></span></a>)
end
HOL_STARS = [[70, 60, 1.0], [210, 300, 0.6], [520, 40, 0.7], [760, 330, 0.9], [980, 90, 1.2], [1130, 260, 0.6], [1250, 140, 0.8], [400, 210, 0.5], [880, 200, 0.5]]
def home_holiday_section
  return "<!-- HOLIDAY -->\n<!-- /HOLIDAY -->" unless HOLIDAY[:on]
  stars = HOL_STARS.each_with_index.map { |(x, y, k), i|
    %(<path transform="translate(#{x} #{y}) scale(#{k})" style="animation-delay:#{(i * 0.7).round(1)}s" d="M0-14 3.2-3.2 14 0 3.2 3.2 0 14-3.2 3.2-14 0-3.2-3.2Z"/>)
  }.join
  tickets = PROMOS.map { |pr|
    %(<a class="ticket" href="#{pr[:slug]}.html"><span class="mono">#{pr[:label]}</span><b>#{pr[:amount]}</b><span class="t-for">toward finish materials</span><span class="t-go">Claim this special <span aria-hidden="true">→</span></span></a>)
  }.join
  <<~HTML.chomp
    <!-- HOLIDAY -->
    <section class="hol" aria-labelledby="hol-t">
      <svg class="hol-stars" viewBox="0 0 1320 380" preserveAspectRatio="xMidYMid slice" aria-hidden="true">#{stars}</svg>
      <div class="wrap hol-in">
        <div class="hol-copy">
          <p class="hol-tag"><span>#{HOLIDAY[:tag]}</span><span>Holiday season</span></p>
          <h2 id="hol-t">The season for <em>a new space.</em></h2>
          <p>This holiday season, our specials put real money toward the finish materials for your remodel. Claim one, book your free consultation, and start the new year with the room you've been waiting for.</p>
          <div class="hol-acts"><a href="specials.html" class="btn btn-brass">Explore the specials <span class="ar" aria-hidden="true">→</span></a><a href="consultation.html" class="btn btn-line">Book a free consultation</a></div>
        </div>
        <div class="hol-tickets">#{tickets}</div>
      </div>
    </section>
    <!-- /HOLIDAY -->
  HTML
end

# ---------------------------------------------------------------- kitchen refresh (home page, between Projects and Services)
# Set REFRESH_ON = false and rebuild to remove the section.
REFRESH_ON = true
REFRESH_ITEMS = ["Cabinets painted white or a natural, modern color", "New handles", "Recessed lighting", "Pendant lights",
                 "Quartz countertops", "New sink &amp; faucet", "Backsplash", "Appliances"]
def home_refresh_section
  return "<!-- REFRESH -->\n<!-- /REFRESH -->" unless REFRESH_ON
  items = REFRESH_ITEMS.map { |t| "<li>#{t}</li>" }.join
  <<~HTML.chomp
    <!-- REFRESH -->
    <section class="sheet sec refresh" aria-labelledby="refresh-t">
      <div class="wrap refresh-in">
        <div class="refresh-copy">
          <p class="eyebrow">Kitchen refresh</p>
          <h2 id="refresh-t">Tired of your old cabinets? <em>Skip the huge remodel.</em></h2>
          <p class="lead">Save your cabinets and get a fresh, modern kitchen on a budget. We paint the cabinets you already have and update everything around them.</p>
          <ul class="refresh-list">#{items}</ul>
          <p class="refresh-note">We've completed many kitchen refresh projects this year. It's one of our specialties.</p>
          <div class="acts">
            <a href="consultation.html" class="btn btn-ink">Book a free consultation <span class="ar" aria-hidden="true">→</span></a>
            <a href="kitchen-remodeling.html#ba-t" class="btn btn-line-n">See the before &amp; after</a>
          </div>
        </div>
        <div class="refresh-ba">
          <figure><img src="assets/photos/kitchen-white-sink-before.jpg" width="1600" height="1200" loading="lazy" alt="Before: kitchen with brown cherry-stained cabinets and dark speckled granite counters"><span class="mono">Before</span></figure>
          <figure><img src="assets/photos/kitchen-white-sink-after.jpg" width="1600" height="1200" loading="lazy" alt="After: the same kitchen with white painted cabinets, white quartz counters, and wood-and-glass pendant lights over the island"><span class="mono">After</span></figure>
          <figure><img src="assets/photos/kitchen-white-range-before.jpg" width="1600" height="1200" loading="lazy" alt="Before: range wall with brown cabinets, a glass tile strip backsplash, and dark granite counters"><span class="mono">Before</span></figure>
          <figure><img src="assets/photos/kitchen-white-range-after.jpg" width="1600" height="1200" loading="lazy" alt="After: the range wall with white cabinets, a full-height quartz slab backsplash, and white quartz counters"><span class="mono">After</span></figure>
        </div>
      </div>
    </section>
    <!-- /REFRESH -->
  HTML
end

# ---------------------------------------------------------------- materials & suppliers (home page, above Reviews)
# Each row: name, logo file in assets/brands/, label, what you buy there, their website.
# To remove a store, delete its row. To remove the whole section, set SUPPLIERS_ON = false. Then rebuild.
SUPPLIERS_ON = true
SUPPLIERS = [
  ["MSI Surfaces", "msi-surfaces.svg", "Countertops &amp; tile", "Quartz and natural stone countertops, porcelain tile, and backsplash", "https://www.msisurfaces.com/"],
  ["Floor &amp; Decor", "floor-and-decor.svg", "Flooring &amp; tile", "Tile, wood, laminate, and luxury vinyl flooring", "https://www.flooranddecor.com/"],
  ["Dunn Lumber", "dunn-lumber.png", "Lumber &amp; millwork", "Framing lumber, trim, millwork, and building materials from a local Seattle-area yard", "https://www.dunnlumber.com/"],
  ["The Home Depot", "home-depot.svg", "Building supplies", "Fixtures, hardware, building materials, and appliances", "https://www.homedepot.com/"],
  ["Lowe's", "lowes.svg", "Building supplies", "Fixtures, hardware, building materials, and appliances", "https://www.lowes.com/"],
  ["Wayfair", "wayfair.svg", "Fixtures &amp; finishes", "Vanities, lighting, mirrors, and finishing pieces you pick out", "https://www.wayfair.com/"],
  ["Amazon", "amazon.svg", "Fixtures &amp; finishes", "Hardware, lighting, and specialty items you choose", "https://www.amazon.com/"],
]
def home_suppliers_section
  return "<!-- SUPPLIERS -->\n<!-- /SUPPLIERS -->" unless SUPPLIERS_ON
  cards = SUPPLIERS.map { |name, logo, cat, what, url|
    %(<a class="vend-card" href="#{url}" target="_blank" rel="noopener"><span class="vend-logo"><img src="assets/brands/#{logo}" alt="#{name}" loading="lazy"></span><span class="mono">#{cat}</span><p>#{what}</p><span class="go">Browse their selection ↗</span></a>)
  }.join
  cards += %(<a class="vend-card cta" href="consultation.html"><span class="mono">Something else?</span><b>We'll source <em>it for you.</em></b><p>Found a product somewhere else? Send it to us and we'll check that it fits your project and order it.</p><span class="go">Book a free consultation →</span></a>)
  <<~HTML.chomp
    <!-- SUPPLIERS -->
    <section class="sheet sec vend" aria-labelledby="vend-t">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">Materials &amp; suppliers</p><h2 id="vend-t">Quality materials from <em>names you know.</em></h2></div>
          <p>We buy from trusted suppliers across the Seattle area and online, and we help you choose and shop for your finishes. Browse their selections to get ideas before your consultation.</p>
        </div>
        <div class="vend-grid">#{cards}</div>
        <p class="vend-note">Logos and store names belong to their owners. We buy from these suppliers; they don't sponsor or endorse our work.</p>
      </div>
    </section>
    <!-- /SUPPLIERS -->
  HTML
end

# ---------------------------------------------------------------- social media (Instagram + YouTube)
# The footer strip appears on every page with a footer; the two sections appear on the home page between Reviews and FAQ.
# To change the YouTube videos shown, edit YT_VIDEOS (the id is the part after "v=" in the video's address).
IG_URL = "https://www.instagram.com/juliusremodeling/"
IG_HANDLE = "@juliusremodeling"
YT_URL = "https://www.youtube.com/@Juliusremodelinggroup"
YT_VIDEOS = [
  ["Z-EL9TteaCM", "Kitchen renovation on a budget"],
  ["NImXZL295qQ", "Client testimonial"],
]
IG_PHOTOS = %w[kitchen-1 bath-1 bath-wetroom kitchen-wood bath-2 laundry]  # keys from PHOTOS
IG_GLYPH = %(<svg class="ig-glyph" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4.2"/><circle cx="17.4" cy="6.6" r="1.1" fill="currentColor" stroke="none"/></svg>)
YT_GLYPH = %(<svg class="yt-glyph" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><rect x="2" y="5" width="20" height="14" rx="4" fill="none" stroke="currentColor" stroke-width="1.6"/><path d="M10 9.2v5.6l4.8-2.8z" fill="currentColor"/></svg>)
SOCIAL_STRIP = %(\n        <div class="ig-strip"><p class="l">#{IG_GLYPH}#{YT_GLYPH}Follow along for our latest projects</p><div class="links"><a href="#{IG_URL}" target="_blank" rel="noopener">Instagram #{IG_HANDLE} ↗</a><a href="#{YT_URL}" target="_blank" rel="noopener">YouTube ↗</a></div></div>)

def home_social_section
  vids = YT_VIDEOS.map { |id, t|
    %(<figure><div class="yt-frame"><iframe src="https://www.youtube-nocookie.com/embed/#{id}?rel=0" title="#{t}" loading="lazy" allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe></div><figcaption>#{t}</figcaption></figure>)
  }.join
  tiles = IG_PHOTOS.map { |k|
    ph = PHOTOS.fetch(k)
    %(<a href="#{IG_URL}" target="_blank" rel="noopener" aria-label="See this project and more on Instagram"><img src="#{ph[:src]}" width="#{ph[:w]}" height="#{ph[:h]}" alt="" loading="lazy"></a>)
  }.join
  <<~HTML.chomp
    <!-- SOCIAL -->
    <section class="dark sec yt" aria-labelledby="yt-t">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">YouTube</p><h2 id="yt-t">See our work <em>in motion.</em></h2></div>
          <p>Project walkthroughs and what our clients have to say, on our YouTube channel.</p>
        </div>
        <div class="yt-grid">#{vids}</div>
        <div class="yt-act">
          <a href="#{YT_URL}" target="_blank" rel="noopener" class="btn btn-brass">Watch more on YouTube <span class="ar" aria-hidden="true">↗</span></a>
          <span class="yt-handle">#{YT_GLYPH}Julius Remodeling Group</span>
        </div>
      </div>
    </section>

    <section class="sheet sec ig" aria-labelledby="ig-t">
      <div class="wrap ig-in">
        <div class="ig-copy">
          <p class="eyebrow">Instagram</p>
          <h2 id="ig-t">Follow the work <em>as it happens.</em></h2>
          <p>Before-and-afters, projects in progress, and the details we're proud of. See our latest work on Instagram.</p>
          <p class="ig-handle">#{IG_GLYPH}#{IG_HANDLE}</p>
          <a href="#{IG_URL}" target="_blank" rel="noopener" class="btn btn-ink">Follow us on Instagram <span class="ar" aria-hidden="true">↗</span></a>
        </div>
        <div class="ig-grid">#{tiles}</div>
      </div>
    </section>
    <!-- /SOCIAL -->
  HTML
end

NEWS_STRIP = <<~HTML.chomp

        <div class="news">
          <div>
            <span class="mono">Newsletter</span>
            <p class="nt">Our latest work and specials, <em>in your inbox.</em></p>
            <p class="ns">Be the first to hear about new offers and see our most recent projects. Unsubscribe anytime.</p>
          </div>
          <a href="newsletter.html" class="btn btn-brass">Sign up for the newsletter <span class="ar" aria-hidden="true">→</span></a>
        </div>
HTML

def footer(home: false, news: true)
  p = home ? "" : "index.html"
  li = ->(list) { list.map { |s| %(<li><a href="#{s[:slug]}.html">#{s[:name]}</a></li>) }.join }
  <<~HTML.chomp
    <footer class="dark">
      <div class="wrap">#{SOCIAL_STRIP}#{news ? NEWS_STRIP : ""}
        <div class="fgrid">
          <div><p class="tag">Transforming homes. <em>Elevating lives.</em></p><p class="sub">Remodeling for single-family homes, condos, and apartments across Seattle and the Eastside.</p><p class="sister">Need a repair or a quick service call instead? Chimney, garage door, plumbing and electrical repairs, and more are handled by our sister company, <a href="https://www.juliusservices.com/" target="_blank" rel="noopener">Julius Services ↗</a></p></div>
          <div><h4 class="mono">Remodeling</h4><ul>#{li.(REMODELING)}</ul><h4 class="mono">Additions &amp; new builds</h4><ul>#{li.(ADDITIONS)}</ul></div>
          <div><h4 class="mono">Exterior &amp; outdoor</h4><ul>#{li.(EXTERIOR)}</ul></div>
          <div><h4 class="mono">Interior &amp; systems</h4><ul>#{li.(INTERIOR)}</ul></div>
          <div><h4 class="mono"><a href="service-areas.html">Service areas</a></h4><ul>#{li.(AREAS)}</ul></div>
          <div><h4 class="mono">Contact</h4><ul><li><a href="tel:" data-tel data-k="phone">[Phone]</a></li><li><a href="mailto:ask@juliusremodeling.com" data-mail data-k="email">ask@juliusremodeling.com</a></li><li data-k="hours">[Business hours]</li><li data-k="address">[Address]</li><li><a href="#{LICENSE_URL}" target="_blank" rel="noopener">WA License <span data-k="license">[License #]</span> ↗</a></li><li data-k="insurance">[Insurance details]</li><li><a href="https://www.youtube.com/@Juliusremodelinggroup" target="_blank" rel="noopener">YouTube ↗</a></li><li><a href="#{IG_URL}" target="_blank" rel="noopener">Instagram ↗</a></li></ul></div>
        </div>
        <div class="legal mono"><span>© 2026 Julius Remodeling Group</span><span class="flinks"><a href="about.html">About us</a><a href="specials.html">Specials</a><a href="newsletter.html">Newsletter</a><a href="terms-and-conditions.html">Terms &amp; Conditions</a><a href="privacy-policy.html">Privacy Policy</a></span><span>Bellevue, WA · Serving Seattle &amp; the Eastside</span></div>
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
  "basement-stairs-gray" => { src: "assets/photos/basement-stairs-gray.jpg", w: 1320, h: 813, land: true, tag: "Basement", title: "Modern basement, open stairs", sub: "Floating wood stairs with a black steel railing, gray accent wall, recessed lighting, patterned carpet",
                 alt: "Finished basement with a gray accent wall, floating light wood stairs with a black horizontal-bar railing, recessed lights, and light patterned carpet" },
  "basement-stairs-open" => { src: "assets/photos/basement-stairs-open.jpg", w: 1320, h: 809, land: true, tag: "Basement", title: "Open family room", sub: "Bright open space under the new stairs, built-in ledge, recessed lighting",
                 alt: "Large finished basement room with white walls, a floating staircase with a black railing, a built-in ledge, and light gray patterned carpet" },
  "basement-soffit-doors" => { src: "assets/photos/basement-soffit-doors.jpg", w: 1320, h: 824, land: true, tag: "Basement", title: "Finished basement, soffits &amp; storage", sub: "Soffits around beams and ducts, new doors, black railing, plush carpet",
                 alt: "Finished basement with beige walls, white doors, soffits along the ceiling, a black railing at the stairs, and beige carpet" },
  "basement-soffit-closet" => { src: "assets/photos/basement-soffit-closet.jpg", w: 1320, h: 812, land: true, tag: "Basement", title: "Soffited ceiling &amp; closet", sub: "Clean soffit lines, recessed lights, bifold closet doors, new carpet",
                 alt: "Finished basement with soffits on the ceiling, recessed lights, a small window, white bifold closet doors, and beige carpet" },
  "basement-soffit-room" => { src: "assets/photos/basement-soffit-room.jpg", w: 1320, h: 816, land: true, tag: "Basement", title: "One big open space", sub: "Soffits frame the ceiling, doors to a bathroom and storage, new carpet throughout",
                 alt: "Wide finished basement room with stepped soffits on the ceiling, white doors, recessed lights, and beige carpet" },
  "second-story-finished" => { src: "assets/photos/second-story-finished.jpg", w: 1142, h: 970, land: true, tag: "Second story", title: "Finished second story", sub: "New upper floor with black windows, cedar soffits, and new siding that ties into the original house",
                 alt: "Finished two-story home with a new upper floor, black-framed windows, cedar soffits, green siding, red French doors, and a stone patio" },
  "second-story-dormer" => { src: "assets/photos/second-story-dormer.jpg", w: 1047, h: 1618, land: false, tag: "Second story", title: "Dormer addition, during &amp; after", sub: "Roof opened and framed, then finished with siding, windows, and a new roof",
                 alt: "Two photos of the same house: top, the roof opened and new walls framed; bottom, the finished second-floor dormer with white siding, two windows, and a new red roof" },
  "second-story-roof-crew" => { src: "assets/photos/second-story-roof-crew.jpg", w: 1320, h: 1411, land: true, tag: "Second story", title: "Our crew framing the roof", sub: "Rafters and ceiling joists going up on a full second floor",
                 alt: "Aerial view of four crew members standing on new roof framing over a full second-story addition" },
  "second-story-framing" => { src: "assets/photos/second-story-framing.jpg", w: 1320, h: 1185, land: true, tag: "Second story", title: "A full second floor, framed", sub: "New walls and rooms framed on top of the existing house, with materials staged on site",
                 alt: "Aerial view of a house with a full second floor framed in wood, a dumpster and stacked lumber in the front yard" },
  "second-story-split-level" => { src: "assets/photos/second-story-split-level.jpg", w: 1306, h: 1512, land: false, tag: "Second story", title: "Split-level, before &amp; during", sub: "The original roofline, then the new second-floor walls going up",
                 alt: "Two photos of the same split-level house: top, crew framing a new second floor; bottom, the original house before the addition" },
  "second-story-stairs" => { src: "assets/photos/second-story-stairs.jpg", w: 815, h: 1443, land: false, tag: "Second story", title: "New stairs to the new floor", sub: "Stair and wall framing inside, with systems run before drywall",
                 alt: "Interior framing of a second-story addition with a new wooden staircase, open stud walls, and exposed ceiling joists" },
  "addition-rear-framing" => { src: "assets/photos/addition-rear-framing.jpg", w: 1133, h: 973, land: true, tag: "Home addition", title: "Addition with a new gable roof", sub: "New foundation, sheathed walls, and roof framing tied into the existing house",
                 alt: "A home addition under construction on a block foundation, with sheathed walls, a crew member framing the gable roof, and the existing house with brown siding beside it" },
  "addition-hip-roof" => { src: "assets/photos/addition-hip-roof.jpg", w: 1121, h: 980, land: true, tag: "Home addition", title: "Front addition, hip roof", sub: "Wall framing and roof sheathing going on, built to match the existing roofline",
                 alt: "A single-story addition framed in wood on a concrete foundation, with a crew member sheathing the hip roof next to the existing house" },
  "addition-family-room" => { src: "assets/photos/addition-family-room.jpg", w: 1133, h: 979, land: true, tag: "Home addition", title: "Rear family-room addition", sub: "Sheathed walls, window openings, and roof framing against a two-story home",
                 alt: "A rear addition with sheathed walls, large window openings, and roof framing built against a white two-story house with red shutters" },
  "newbuild-two-story-framing" => { src: "assets/photos/newbuild-two-story-framing.jpg", w: 1120, h: 714, land: true, tag: "New construction", title: "Two-story home, framed", sub: "Walls sheathed and roof framing up, with lumber staged on site",
                 alt: "A new two-story house framed and sheathed in OSB, with roof trusses, window openings, and stacked lumber in front" },
  "newbuild-single-story-framing" => { src: "assets/photos/newbuild-single-story-framing.jpg", w: 1142, h: 870, land: true, tag: "New construction", title: "Single-story home, framed", sub: "Roof trusses, arched window openings, and a covered entry taking shape",
                 alt: "A new single-story house under construction with sheathed walls, roof trusses, an arched window opening, and a covered porch" },
  "newbuild-modern-finished" => { src: "assets/photos/newbuild-modern-finished.jpg", w: 1134, h: 556, land: true, tag: "New construction", title: "Modern new build, finished", sub: "Board-and-batten and lap siding, black-framed windows, and a cedar entry",
                 alt: "Two finished modern homes at dusk, one with white board-and-batten siding and one with gray lap siding, black-framed windows, and a cedar front entry" },
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
# Kitchen page "Before & after" section (wide photos, one project per row)
KITCHEN_BA = <<~HTML
  <!-- BEFORE & AFTER -->
  <section class="sheet sec" aria-labelledby="ba-t" style="background:var(--paper-2)">
    <div class="wrap">
      <div class="head">
        <div><p class="eyebrow">Before &amp; after</p><h2 id="ba-t">Same kitchen. <em>A whole new look.</em></h2></div>
        <p>A recent kitchen, photographed before we started and after we finished. Same layout, transformed with painted cabinets and new quartz.</p>
      </div>
      <div class="ba-grid ba-wide">
        <article class="ba">
          <div class="ba-pair">
            <figure><img src="assets/photos/kitchen-white-sink-before.jpg" width="1600" height="1200" loading="lazy" alt="Before: kitchen with brown cherry-stained cabinets, dark speckled granite counters, a glass tile accent backsplash, and a brushed nickel pendant"><span class="mono">Before</span></figure>
            <figure><img src="assets/photos/kitchen-white-sink-after.jpg" width="1600" height="1200" loading="lazy" alt="After: the same kitchen with white painted cabinets, white quartz counters with gray veining, wood-and-glass pendants over the island, and floating wood shelves"><span class="mono">After</span></figure>
          </div>
          <h3>Brown cabinets to bright white</h3>
          <p>The cherry-stained cabinets were repainted white, and dark granite was replaced with white quartz on the counters and island. New pendants and floating shelves finish the room.</p>
        </article>
        <article class="ba">
          <div class="ba-pair">
            <figure><img src="assets/photos/kitchen-white-range-before.jpg" width="1600" height="1200" loading="lazy" alt="Before: range wall with brown cabinets, a stainless hood, a glass tile strip backsplash, and dark granite counters"><span class="mono">Before</span></figure>
            <figure><img src="assets/photos/kitchen-white-range-after.jpg" width="1600" height="1200" loading="lazy" alt="After: the range wall with white cabinets, a full-height quartz slab backsplash behind the range, white quartz counters, and a white island"><span class="mono">After</span></figure>
          </div>
          <h3>Quartz slab backsplash</h3>
          <p>A full-height quartz slab now runs behind the range, matching the new counters, with fresh white paint on every cabinet and the island.</p>
        </article>
      </div>
    </div>
  </section>

HTML

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
# ---------------------------------------------------------------- bathroom page: "Upgrade Your Bathroom Experience"
# Edit, replace, or add upgrades here. Each one becomes a card on the bathroom page.
#   img:  a photo in assets/photos (only photos you own or have a license for). nil = a gold icon tile is shown instead.
#   icon: the icon used when there is no photo (fan, heat, mirror, toilet, bench, niche, paper, panel).
# Never put prices here: pricing depends on the product, existing conditions, and the project.
BATH_UPGRADES = [
  { id: "smart-fan", name: "Smart exhaust fan with LED light & Bluetooth speaker", tag: "Technology", icon: "fan", img: ["upg-bath-fan.jpg", 380, 311, "Ceiling exhaust fan with a glowing LED ring and a Bluetooth symbol"],
    p: "A multifunction exhaust fan that clears steam and adds built-in LED lighting, Bluetooth audio, and modern controls.",
    more: "We size the fan for your room so it moves enough air to protect paint and drywall from moisture, and vent it to the outside. Lighting, speaker, and control options vary by model, and we help you choose one that fits the ceiling and your wiring." },
  { id: "floating-bench", name: "Floating shower bench", tag: "Shower", icon: "bench", img: ["upg-bath-bench.jpg", 376, 311, "Floating stone shower bench with warm LED light underneath"],
    p: "A clean, modern bench built into the shower wall for comfort, shaving, and a spa-like look.",
    more: "The bench is framed into the wall structure, waterproofed with the rest of the shower, and tiled to match. We plan its height, depth, and position with you during design." },
  { id: "led-niche", name: "LED shower shampoo niche", tag: "Shower", icon: "niche", img: ["upg-bath-niche.jpg", 380, 311, "Recessed shower niche with LED accent lighting beside a rain shower head"],
    p: "A recessed niche for shampoo and soap, with optional waterproof-rated LED accent lighting.",
    more: "Niches are framed between the studs and fully waterproofed. With lighting, we use fixtures rated for wet locations, installed and wired by a licensed electrician." },
  { id: "heated-floors", name: "Heated bathroom floors", tag: "Comfort", icon: "heat", img: ["upg-bath-heated.jpg", 372, 311, "Bathroom floor showing radiant heating lines under the tile and a wall thermostat set to 72 degrees"],
    p: "Warm, comfortable floors from an electric radiant heating system under the tile, with a programmable thermostat.",
    more: "The heating mat goes down under the tile and connects to a thermostat you can set to warm the floor before you wake up. We check the electrical circuit and plan the layout around the vanity, toilet, and tub." },
  { id: "led-mirror", name: "LED bathroom mirror", tag: "Vanity", icon: "mirror", img: ["upg-bath-mirror.jpg", 380, 314, "Large backlit LED mirror with a touch button above a vanity"],
    p: "A modern mirror with built-in lighting and touch controls, with optional anti-fog.",
    more: "LED mirrors are hard-wired behind the mirror for a clean look with no visible cords. Features like anti-fog, dimming, and color temperature depend on the model you choose." },
  { id: "wallpaper", name: "Designer wallpaper", tag: "Design", icon: "paper", img: ["upg-bath-wallpaper.jpg", 376, 314, "Bathroom accent wall with large tropical leaf designer wallpaper"],
    p: "A one-of-a-kind accent wall with decorative wallpaper, including moisture-resistant options made for bathrooms.",
    more: "We help you choose a wallpaper suited to bathroom humidity, prepare and prime the wall, and pair it with good ventilation so it lasts." },
  { id: "wall-panels", name: "Decorative wall panels & custom wall designs", tag: "Design", icon: "panel", img: ["upg-bath-panels.jpg", 380, 314, "Fluted wood wall panels with LED lighting beside marble-look tile"],
    p: "Modern wall panels, fluted designs, textured finishes, and custom accent walls, using materials made for bathrooms.",
    more: "From fluted panels behind the vanity to a mosaic stripe in the shower, we design the accent with you and choose materials rated for the moisture in each area." },
  { id: "smart-toilet", name: "Smart toilet & electronic bidet seat", tag: "Technology", icon: "toilet", img: ["upg-bath-toilet.jpg", 372, 314, "Smart toilet with an electronic bidet seat, soft night light, and a wall remote"],
    p: "Comfort and hygiene with an electronic bidet seat or smart toilet. Available options include heated seating, adjustable water temperature, self-cleaning, and remote controls.",
    more: "Most electronic bidet seats need an outlet near the toilet, which we add during the remodel. Features vary by model, and we help you compare options before ordering." },
]

BATH_ICONS = {
  "fan"    => %(<circle cx="24" cy="24" r="17"/><circle cx="24" cy="24" r="3"/><path d="M24 21c-1-5 0-9 4-10 3 3 1 7-4 10zM27 25c5-1 9 0 10 4-3 3-7 1-10-4zM21 27c1 5 0 9-4 10-3-3-1-7 4-10zM21 23c-5 1-9 0-10-4 3-3 7-1 10 4z"/>),
  "bench"  => %(<path d="M8 8v32M8 22h26v5H8"/><path d="M14 27v4M28 27v4"/>),
  "niche"  => %(<rect x="11" y="8" width="26" height="32" rx="1"/><path d="M11 24h26"/><path d="M17 24v-7h4v7M25 24v-9h4v9"/>),
  "heat"   => %(<path d="M6 38h36"/><path d="M14 31c-3-4 3-6 0-10s3-6 0-10M24 31c-3-4 3-6 0-10s3-6 0-10M34 31c-3-4 3-6 0-10s3-6 0-10"/>),
  "mirror" => %(<rect x="12" y="6" width="24" height="32" rx="12"/><rect x="15.5" y="9.5" width="17" height="25" rx="8.5" stroke-dasharray="2 3"/><path d="M18 43h12"/>),
  "paper"  => %(<rect x="10" y="6" width="28" height="36"/><path d="M18 12c3 3 0 6 3 9s0 6 3 9M28 12c3 3 0 6 3 9s0 6 3 9M10 16c3 2 0 5 3 7"/>),
  "panel"  => %(<path d="M10 6v36M17 6v36M24 6v36M31 6v36M38 6v36"/>),
  "toilet" => %(<path d="M14 8h14v12H14zM10 20h26c0 8-6 12-12 12h-2c-6 0-12-4-12-12zM18 32l-2 10h14l-2-10"/><path d="M33 13h5"/>),
}

def bath_upgrade_icon(name)
  %(<svg viewBox="0 0 48 48" width="64" height="64" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">#{UPGRADE_ICONS.fetch(name)}</svg>)
end

# ---------------------------------------------------------------- kitchen page: "Upgrade Your Kitchen Experience"
# Same design and picker as the bathroom upgrades. Edit, replace, or add upgrades here.
#   img:  [file in assets/photos, width, height, alt] for a photo you own or have a license for. nil = gold icon tile.
#   list: the feature bullets shown when "More details" is opened.
KITCHEN_UPGRADES = [
  { id: "under-cabinet-led", name: "Under-cabinet LED lighting", tag: "Lighting", icon: "ucled", img: ["upg-kit-led.jpg", 488, 330, "Warm LED strip lighting under dark upper cabinets over a marble backsplash"],
    p: "Modern LED lighting under the upper cabinets that lights up your countertops for cooking and prep.",
    list: ["Continuous LED strip lighting", "Warm, neutral, or adjustable color", "Dimmable controls", "Wiring hidden in aluminum LED channels", "Smart lighting options"] },
  { id: "pop-up-outlets", name: "Pop-up countertop outlets & wireless charging", tag: "Power", icon: "popup", img: ["upg-kit-popup.jpg", 520, 330, "Pop-up countertop outlet with USB ports raised from a stone countertop, next to a phone on a wireless charging pad"],
    p: "Outlets that rise out of the countertop when you need them and retract flush when you don't.",
    list: ["Retractable countertop power outlets", "Built-in USB-A and USB-C charging", "Wireless phone charging pads", "Modern flush-mounted designs", "Concealed electrical connections"],
    note: "We only install products listed for countertop installation, wired by a licensed electrician to the electrical code." },
  { id: "make-up-air", name: "Make-up air system for high-capacity range hoods", tag: "Ventilation", icon: "mua", img: ["upg-kit-mua.jpg", 506, 330, "Stainless range hood over a steaming pot, with a make-up air unit and duct bringing in fresh air"],
    p: "A powerful range hood pushes a lot of air out of the house. A make-up air system brings fresh outdoor air back in to replace it, so the hood works properly.",
    list: ["Make-up air for range hoods over 400 CFM, where required by code", "Fresh outdoor air supply", "Turns on automatically with the range hood", "Optional tempered (heated) make-up air", "Airflow balanced for proper ventilation"],
    note: "Code requirements depend on your hood and your city. We size the system to your hood and handle the permit." },
  { id: "pot-filler", name: "Pot filler faucet above the stove", tag: "Plumbing", icon: "potfill", img: ["upg-kit-potfiller.jpg", 636, 320, "Brushed gold wall-mounted pot filler faucet filling a stock pot on a gas cooktop"],
    p: "A wall-mounted faucet right above the cooktop, so you can fill big pots where you cook.",
    list: ["Fill large pots without carrying them from the sink", "Wall-mounted, folding faucet arm", "Brushed nickel, chrome, matte black, or brushed gold", "Water right where you cook", "Plumbing hidden in the wall"],
    note: "We run a new water line inside the wall to the cooktop, installed and inspected under our license." },
  { id: "waterfall", name: "Waterfall countertops", tag: "Countertops", icon: "waterfall", img: ["upg-kit-waterfall.jpg", 886, 320, "Kitchen island with a marble-look waterfall countertop running down the side"],
    p: "The countertop continues straight down the side of the island or peninsula for a dramatic, modern centerpiece.",
    list: ["Countertop runs vertically down the island side", "Quartz, porcelain, or natural stone", "Slab patterns and veining matched at the corner", "Custom fabrication and professional installation", "One-sided or two-sided waterfall"] },
]

UPGRADE_ICONS = BATH_ICONS.merge(
  "ucled"     => %(<rect x="6" y="8" width="36" height="12" rx="1"/><path d="M6 20h36"/><path d="M12 24l-3 8M20 24l-1 8M28 24l1 8M36 24l3 8"/><path d="M4 40h40"/>),
  "popup"     => %(<path d="M4 34h40"/><rect x="17" y="10" width="14" height="24" rx="2"/><path d="M21 16v4M27 16v4M22 26h4"/><path d="M24 4v3M20 5l1 2M28 5l-1 2"/>),
  "mua"       => %(<path d="M17 6h14v8l8 10H9l8-10z"/><path d="M9 24h30"/><path d="M14 30c3 2 3 5 0 7M24 30c3 2 3 5 0 7M34 30c3 2 3 5 0 7"/><path d="M40 12h5M43 9l2 3-2 3"/>),
  "potfill"   => %(<path d="M6 8v8h18v6"/><path d="M6 12h4"/><path d="M24 26v4"/><path d="M12 30h24v8a4 4 0 0 1-4 4H16a4 4 0 0 1-4-4z"/><path d="M8 32h4M36 32h4"/>),
  "waterfall" => %(<path d="M6 14h36v26"/><path d="M6 14v5h31v21h5"/><path d="M14 19l6 21M24 19l4 12"/>),
)

# Builds one upgrades section. Used by the bathroom and kitchen pages.
def upgrade_section(o)
  cards = o[:items].each_with_index.map { |u, i|
    media = if u[:img]
      f, w, h, alt = u[:img]
      %(<figure class="upg-media"><img src="assets/photos/#{f}" width="#{w}" height="#{h}" loading="lazy" alt="#{alt}"></figure>)
    else
      %(<figure class="upg-media upg-ico">#{bath_upgrade_icon(u[:icon])}</figure>)
    end
    more = u[:list] ? %(<ul>#{u[:list].map { |t| "<li>#{t}</li>" }.join}</ul>#{u[:note] ? "<p>#{u[:note]}</p>" : ""}) : %(<p>#{u[:more]}</p>)
    q = "consultation.html?type=#{o[:type]}&amp;upgrades=" + u[:name].gsub("&", "and").gsub(" ", "+")
    <<~CARD.chomp
      <article class="upg" data-upg="#{u[:id]}" data-name="#{u[:name]}">
                #{media}
                <div class="upg-body">
                  <div class="upg-top"><span class="mono">#{format('%02d', i + 1)} · #{u[:tag]}</span><span class="upg-opt mono">Optional upgrade</span></div>
                  <h3>#{u[:name].gsub(" & ", " &amp; ")}</h3>
                  <p>#{u[:p]}</p>
                  <details><summary>More details</summary>#{more}</details>
                  <div class="upg-acts">
                    <button type="button" class="upg-pick" aria-pressed="false"><span class="ck" aria-hidden="true"></span><span class="t">#{o[:pick]}</span></button>
                    <a class="upg-ask" href="#{q}">Ask about this upgrade <span aria-hidden="true">→</span></a>
                  </div>
                </div>
              </article>
    CARD
  }.join("\n          ")
  <<~HTML
    <!-- #{o[:type].upcase} UPGRADES -->
    <section class="sheet sec upgs" id="upgrades" aria-labelledby="upg-t" data-kind="#{o[:type]}" data-pick="#{o[:pick]}" data-picked="#{o[:picked]}" data-send="#{o[:send]}" data-none="#{o[:none]}">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">Optional upgrades</p><h2 id="upg-t">#{o[:h2]}</h2></div>
          <div>
            <p class="upg-sub">#{o[:sub]}</p>
            <p>#{o[:intro]}</p>
          </div>
        </div>
        <div class="upg-build">
          <span class="mono">#{o[:build_t]}</span>
          <p>Tap <b>#{o[:pick]}</b> on the upgrades you like. We'll send your picks with your free consultation request.</p>
        </div>
        <div class="upg-grid#{o[:items].size == 5 ? " five" : ""}">
          #{cards}
        </div>
        <p class="upg-fine">These are optional upgrades, not part of a standard #{o[:type].downcase} remodel. Pricing depends on the products you choose, the existing conditions, and your project. Photos show example designs. Features vary by product and model. Electrical, plumbing, and ventilation work is installed to the applicable building codes, with permits where required.</p>
        <div class="upg-sum" aria-live="polite">
          <div class="upg-sum-in">
            <div><span class="mono">#{o[:sum_t]}</span><p class="upg-list">#{o[:none]}</p></div>
            <a class="btn btn-brass upg-send" href="consultation.html">Book a free consultation <span class="ar" aria-hidden="true">→</span></a>
          </div>
        </div>
        <div class="upg-cta">
          <div>
            <h3>#{o[:cta_h]}</h3>
            <p>#{o[:cta_p]}</p>
          </div>
          <div class="acts">
            <a href="consultation.html" class="btn btn-brass upg-send">Book a free consultation <span class="ar" aria-hidden="true">→</span></a>
            <a href="#{o[:cta2_href]}" class="btn btn-line">#{o[:cta2]}</a>
          </div>
        </div>
      </div>
    </section>

  HTML
end

def bath_upgrades_html
  upgrade_section(type: "Bathroom", items: BATH_UPGRADES,
    h2: "Upgrade your <em>bathroom experience.</em>", sub: "More than a bathroom. Your personal retreat.",
    intro: "Turn an everyday bathroom into a comfortable, modern, and luxurious space with upgrades that combine technology, function, and beautiful design.",
    build_t: "Build your bathroom experience", sum_t: "Your bathroom experience",
    pick: "Add to my bathroom", picked: "Added to my bathroom", send: "Send my picks with a free consultation",
    none: "No upgrades selected yet. Tap <b>Add to my bathroom</b> on any card.",
    cta_h: "Your bathroom. Your style. <em>Your experience.</em>",
    cta_p: "From heated floors and smart technology to custom shower features and decorative finishes, we'll help you create a bathroom designed around your lifestyle.",
    cta2: "Explore your bathroom upgrades", cta2_href: "#upg-t")
end

def kitchen_upgrades_html
  upgrade_section(type: "Kitchen", items: KITCHEN_UPGRADES,
    h2: "Upgrade your <em>kitchen experience.</em>", sub: "Smarter features. Better function. Beautiful design.",
    intro: "Turn an everyday kitchen into a modern, functional, and luxurious space with upgrades that combine convenience, technology, and custom design.",
    build_t: "Build your dream kitchen", sum_t: "Your kitchen wishlist",
    pick: "Add to my kitchen wishlist", picked: "Added to my wishlist", send: "Get a consultation for my kitchen upgrades",
    none: "Nothing on your wishlist yet. Tap <b>Add to my kitchen wishlist</b> on any card.",
    cta_h: "Your kitchen. Your style. <em>Your experience.</em>",
    cta_p: "From smart lighting and hidden charging to custom countertops and professional-grade ventilation, discover the upgrades that make your kitchen more beautiful, comfortable, and functional.",
    cta2: "Explore kitchen remodeling services", cta2_href: "#incl-t")
end

QUOTES = {
  rebecca: ["What I appreciate most is their patience and professionalism. No matter how many questions I had, Noam always took the time to explain and never rushed the process. They’re always on site when they say they will be, take full responsibility for every detail, and truly stand behind their work. You can feel the integrity.", "Rebecca T.", "Seattle, WA"],
  david:   ["From the first meeting to the final walkthrough, you can tell Julius Remodeling Group runs as a true team. The designers, builders, and project managers all communicate smoothly. Everyone cares about the end result and it shows. Our home turned out even better than we imagined.", "David L.", "Mercer Island, WA"],
}
LICENSED_FAQ = ["Are you licensed, insured, and bonded?", "Yes. Julius Remodeling Group is a licensed, insured, and bonded Washington general contractor (License JULIURG780NJ). <a href=\"#{LICENSE_URL}\" target=\"_blank\" rel=\"noopener\" style=\"text-decoration:underline\">Verify it with Washington L&amp;I</a>."]
SISTER_LINK = %(<a href="https://www.juliusservices.com/" target="_blank" rel="noopener" style="text-decoration:underline">Julius Services</a>)
CONDO_LINK = "<a href=\"condo-remodeling.html\" style=\"text-decoration:underline\">See how condo remodeling works</a>"

# ---------------------------------------------------------------- page content
PAGES = [
  # ============================== KITCHEN
  {
    slug: "kitchen-remodeling", short: "Kitchen",
    financing: { url: "https://www.acornfinance.com/remodel/kitchen-remodel-financing/", project: "kitchen remodel" },
    title: "Kitchen Remodeling in Seattle &amp; the Eastside",
    meta: "Kitchen remodeling in Seattle and the Eastside: cabinet repainting, semi-custom and custom cabinets, countertops, islands, sinks, plumbing, electrical, windows, and flooring.",
    eyebrow: "Kitchen remodeling",
    h1: "A kitchen built around <em>how you live.</em>",
    lede: "From repainting the cabinets you have to a fully custom kitchen: countertops, islands, sinks, plumbing, electrical, windows, and flooring for homes, condos, and apartments across Seattle and the Eastside, built by one team under one license.",
    tags: ["Cabinet repainting", "Semi-custom &amp; custom cabinets", "Countertops", "Islands", "Plumbing &amp; electrical", "Windows &amp; flooring"],
    photo: "kitchen-1",
    extra: KITCHEN_BA + kitchen_upgrades_html,
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
    financing: { url: "https://www.acornfinance.com/remodel/bathroom-remodel-renovation-financing/", project: "bathroom remodel" },
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
    extra: BATH_EXTRA + bath_upgrades_html,
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
    financing: { url: "https://www.acornfinance.com/remodel/basement-remodel-financing/", project: "basement remodel" },
    title: "Basement Remodeling &amp; Finishing in Seattle &amp; the Eastside",
    meta: "Basement remodeling and finishing in Seattle and the Eastside: guest suites, kitchenettes, bathrooms, laundry rooms, playrooms, and man caves, plus support beams, drain lines, foundation repair, and egress windows.",
    eyebrow: "Basement remodeling",
    h1: "Turn the basement into <em>real living space.</em>",
    lede: "Finish an unfinished basement or update an old one. Add a kitchenette, a bathroom, or a laundry room, and make it the perfect place for your guests, a playroom for your kids, or your own man cave. One team handles everything, from support beams and drain lines to egress windows.",
    tags: ["Guest suites", "Kitchenettes", "Bathrooms", "Laundry rooms", "Playrooms", "Man caves", "Egress windows"],
    photo: "basement-stairs-gray",
    incl_h: "Everything a finished basement needs, <em>done in order.</em>",
incl_p: "A good basement starts with what's behind the walls and under the floor. We take care of the structure, moisture, and systems first, then the finishes.",
incl: [
  ["Moisture &amp; foundation", "Signs of moisture and foundation cracks are checked and repaired before any walls go up, so the finished space stays dry. <a href=\"foundation-repair.html\" style=\"text-decoration:underline\">Foundation repair</a>."],
  ["Support beams &amp; openings", "We move or replace support posts and beams and create new openings to open up the space, engineered and permitted."],
  ["Soffits &amp; framing", "Soffits built around ducts, pipes, and beams, plus new walls and insulation, for clean lines throughout."],
  ["Drain lines in the slab", "We cut and dig through the concrete slab to run new drain lines, so a bathroom, kitchenette, or laundry can go where you want it."],
  ["Egress windows", "We cut the opening in the foundation, dig the window well, and install a code-compliant egress window for a legal bedroom."],
  ["Plumbing &amp; laundry", "Bathrooms, kitchenettes, wet bars, and laundry rooms, with plumbing run and inspected under our license."],
  ["Electrical &amp; lighting", "New circuits, outlets, recessed lighting, and wiring for TVs, games, offices, and gyms."],
  ["Drywall, floors &amp; finish", "Drywall, ceilings, paint, and flooring suited to below-grade spaces, finished like the rest of the house."],
],
    options: {
      eyebrow: "Your options", h: "What will your basement <em>become?</em>",
      p: "We'll plan the space around how you want to use it, then handle the permits, systems, and finishes to get it there.",
cards: [
  ["A suite for your guests", "A private place for family and friends to stay: a bedroom with an egress window, a full bathroom, and a kitchenette.", ["Bedroom with egress window", "Full bathroom", "Kitchenette or wet bar"]],
  ["A playroom for your kids", "Room to run, play, and make noise, away from the main floor, with durable floors and plenty of storage.", ["Open play space", "Durable flooring", "Built-in storage"]],
  ["A man cave or media room", "Your own space for the game, movies, and friends: big-screen wiring, lighting you can dim, and a wet bar.", ["TV and sound wiring", "Wet bar or kitchenette", "Gym or home office"]],
],
    },
    gallery: ["basement-stairs-gray", "basement-stairs-open", "basement-soffit-room", "basement-soffit-doors", "basement-soffit-closet"],
    quote: :david,
    faq: [
      ["Do I need a permit to finish my basement?", "Finishing a basement usually requires permits, especially for framing, electrical, and plumbing. We coordinate permits as part of the project, before construction begins."],
      ["What if my basement has moisture?", "Moisture is the first thing we look at. Any signs of water are checked and addressed before walls and flooring go in, so the finished space stays dry."],
      ["Can you add a bedroom in the basement?", "Often, yes. A basement bedroom needs an egress window or door and has to meet other code requirements. We cut the opening, dig the window well, and install the egress window as part of the project."],
      ["Can you move a support beam or post?", "Often, yes. A structural engineer designs the new beam or post layout, we pull the permit, and we install temporary supports while the work is done."],
      ["Can you add a bathroom, kitchenette, or laundry downstairs?", "Yes. When there's no drain where you need one, we cut and dig through the concrete slab to run a new drain line, then patch the floor. We plan the plumbing during design so everything drains and vents properly."],
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
    financing: { url: "https://www.acornfinance.com/home-improvement/flooring-financing/", project: "flooring project" },
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
  # ============================== ADU & DADU
  {
    slug: "adu-dadu", short: "ADU",
    title: "ADU &amp; DADU Builders in Seattle &amp; the Eastside",
    meta: "Accessory dwelling units in Seattle and the Eastside: detached backyard cottages (DADUs), attached ADUs, and garage and basement conversions, from feasibility and permits to the finished unit.",
    eyebrow: "ADU &amp; DADU",
    h1: "More home on the lot <em>you already own.</em>",
    lede: "Detached backyard cottages, attached ADUs, and garage or basement conversions for rental income, family, or a home office, planned, permitted, and built by one team.",
    tags: ["Detached ADUs (DADUs)", "Attached ADUs", "Garage conversions", "Basement units", "Permits &amp; utilities"],
    incl_h: "A second home, <em>start to finish.</em>",
    incl_p: "An ADU is a small house with every system a full house has. We manage all of it, from the first site check to the final inspection.",
    incl: [
      ["Feasibility &amp; design", "We check your lot, zoning, setbacks, and utilities, then plan a size and layout that fit your budget and what your city allows."],
      ["Permits &amp; approvals", "Drawings, engineering, and permit applications, handled for you, with the city's review comments answered along the way."],
      ["Foundation, framing &amp; utilities", "Site work, foundation, framing, and the water, sewer, and power connections the unit needs."],
      ["Finished, livable interiors", "Kitchen, bathroom, flooring, and finishes built to the same standard as our full remodels."],
    ],
    gallery: [],
    quote: :david,
    faq: [
      ["What is the difference between an ADU and a DADU?", "An ADU (accessory dwelling unit) is a second, self-contained home on your property. A DADU is the detached kind: a separate backyard cottage. An attached ADU is part of the main house, such as a basement unit or an addition."],
      ["Can I build an ADU on my lot?", "In most Seattle-area cities, yes, but the rules on size, height, setbacks, and parking vary by city and by lot. We check what applies to your property before any design work starts."],
      ["Can I convert my garage or basement instead?", "Often, yes. Converting existing space can cost less than building new, as long as it can meet code for ceiling height, egress, insulation, and utilities. We'll tell you honestly which option makes more sense."],
      LICENSED_FAQ,
    ],
  },
  # ============================== SECOND-STORY ADDITIONS
  {
    slug: "second-story-additions", short: "Second-story",
    gallery_p: "Second-story additions from start to finish: framing, roofing, and the finished homes.",
    photo: "second-story-roof-crew",
    title: "Second-Story Additions in Seattle &amp; the Eastside",
    meta: "Second-story and second-floor additions in Seattle and the Eastside: engineering, permits, structural work, framing, roofing, and finished bedrooms and baths from one licensed general contractor.",
    eyebrow: "Second-story additions",
    h1: "Build up, <em>not out.</em>",
    lede: "Add bedrooms, bathrooms, or a primary suite on a new second floor without giving up your yard. We handle the engineering, permits, structure, and the finished rooms.",
    tags: ["Full second floors", "Partial additions", "Primary suites", "Structural engineering", "Roof &amp; siding tie-in"],
    incl_h: "A new floor <em>that belongs to the house.</em>",
    incl_p: "A second story changes the structure, the roof, and the stairs. We plan all of it together, so the addition looks like it was always there.",
    incl: [
      ["Engineering &amp; permits", "A structural engineer reviews the existing foundation and framing, and we handle the drawings and the permit process."],
      ["Structure &amp; framing", "Reinforcement where it's needed, new floor framing, walls, and a new roof, built to the engineer's plans."],
      ["Stairs, systems &amp; insulation", "A new staircase, plus plumbing, electrical, heating, and insulation extended to the new floor."],
      ["Finished rooms &amp; exterior", "Bedrooms, bathrooms, and closets finished inside, with siding and roofing matched to the rest of the house."],
    ],
    gallery: ["second-story-finished", "second-story-dormer", "second-story-roof-crew", "second-story-split-level", "second-story-framing", "second-story-stairs"],
    quote: :rebecca,
    faq: [
      ["Can my house support a second story?", "Many can, but it depends on the existing foundation and framing. A structural engineer reviews your home first, and we tell you what reinforcement, if any, is needed before you commit."],
      ["Can we live in the house during construction?", "Sometimes, for part of the project. Because the roof comes off, most families plan to move out for at least some of the work. We'll walk you through the schedule at the start."],
      ["Is a second story better than a ground-level addition?", %(It depends on your lot and goals. Building up keeps your yard and works on smaller lots; building out is often simpler structurally. We'll compare both for your home. See <a href="home-additions.html" style="text-decoration:underline">home additions</a>.)],
      LICENSED_FAQ,
    ],
  },
  # ============================== HOME ADDITIONS
  {
    slug: "home-additions", short: "Addition",
    photo: "addition-rear-framing",
    gallery_p: "Home additions in progress: new foundations, framing, and roofs tied into the existing house.",
    title: "Home Additions in Seattle &amp; the Eastside",
    meta: "Home additions in Seattle and the Eastside: room additions, bump-outs, primary suites, and larger kitchens and family rooms, designed and built by a licensed general contractor.",
    eyebrow: "Home additions",
    h1: "The room you're missing, <em>added on.</em>",
    lede: "Room additions, bump-outs, primary suites, and bigger kitchens or family rooms, planned to match your home and built by one team from foundation to finish.",
    tags: ["Room additions", "Bump-outs", "Primary suites", "Sunrooms", "Kitchen expansions"],
    incl_h: "More space, <em>seamlessly joined.</em>",
    incl_p: "The hardest part of an addition is where new meets old. We plan the roofline, floors, and finishes so the seam disappears.",
    incl: [
      ["Design &amp; permits", "Layout, drawings, engineering, and permits, with the size and placement checked against your lot's rules."],
      ["Foundation &amp; framing", "Excavation, foundation, framing, and a roof tied into the existing house."],
      ["Systems &amp; insulation", "Plumbing, electrical, heating, and insulation extended into the new space."],
      ["Matching finishes", "Siding, roofing, windows, floors, and trim matched to what you already have."],
    ],
    gallery: ["addition-rear-framing", "addition-hip-roof", "addition-family-room"],
    quote: :david,
    faq: [
      ["What is a bump-out?", "A bump-out is a small addition, often just a few feet deep, that extends one room, such as a kitchen or bathroom. It adds space without the scope of a full room addition."],
      ["Will the addition match my house?", "That's the goal. We match the roofline, siding, windows, and interior finishes wherever possible, so the addition doesn't look added on."],
      ["Do I need a permit for an addition?", "Yes. Additions need permits and inspections. We prepare the drawings and handle the permit process for you."],
      LICENSED_FAQ,
    ],
  },
  # ============================== NEW CONSTRUCTION
  {
    slug: "new-construction", short: "New construction",
    photo: "newbuild-two-story-framing",
    gallery_p: "New homes from framing to the finished build.",
    title: "New Home Construction in Seattle &amp; the Eastside",
    meta: "New home construction in Seattle and the Eastside: custom homes and teardown rebuilds, managed by a licensed general contractor from permits and site work to the final walkthrough.",
    eyebrow: "New construction",
    h1: "A new home, <em>built around you.</em>",
    lede: "Custom homes and teardown rebuilds, managed by one team from permits and site work to the final walkthrough, with the same attention to finish as our remodels.",
    tags: ["Custom homes", "Teardown rebuilds", "Site work", "Permits", "Interior finishes"],
    incl_h: "One team, <em>from the ground up.</em>",
    incl_p: "Building new means hundreds of decisions and dozens of trades. We keep them on one schedule and one budget, with one point of contact for you.",
    incl: [
      ["Planning &amp; permits", "We work from your architect's plans or bring in a designer and engineer, handle permits, and price the build before it starts."],
      ["Site work &amp; foundation", "Demolition of an existing house if needed, excavation, utilities, and the foundation."],
      ["Framing, roofing &amp; systems", "Structure, roof, windows, siding, plumbing, electrical, and HVAC, built and inspected in order."],
      ["Interiors &amp; finishes", "Kitchens, bathrooms, flooring, trim, and paint, finished to the standard you see in our remodels."],
    ],
    gallery: ["newbuild-modern-finished", "newbuild-two-story-framing", "newbuild-single-story-framing"],
    quote: :david,
    faq: [
      ["Do I need my own architect?", "Not necessarily. If you already have one, we're happy to build from their plans. If not, we can bring in a designer and engineer we work with."],
      ["Can you tear down my existing house and rebuild?", "Yes. A teardown rebuild starts with a demolition permit and utility disconnects, then proceeds like any new home build."],
      ["How do you keep a new build on budget?", "We price the project from complete plans, agree on the budget before work starts, and put any changes in writing before they happen."],
      LICENSED_FAQ,
    ],
  },
  # ============================== ROOFING
  {
    slug: "roofing", short: "Roofing",
    title: "Roof Replacement &amp; Roofing in Seattle &amp; the Eastside",
    meta: "Roof replacement and new roofing in Seattle and the Eastside: asphalt shingles, metal roofing, flashing, ventilation, and gutters, installed by a licensed general contractor.",
    eyebrow: "Roofing",
    h1: "A roof built for <em>Northwest rain.</em>",
    lede: "Full roof replacements and new roofs for additions, in asphalt shingle or metal, with proper flashing and ventilation and gutters that carry the water away.",
    tags: ["Roof replacement", "Asphalt shingles", "Metal roofing", "Flashing &amp; ventilation", "Gutters"],
    incl_h: "Everything <em>under the shingles too.</em>",
    incl_p: "A roof is only as good as what's under it. We inspect the decking, replace what's damaged, and get the flashing and ventilation right.",
    incl: [
      ["Tear-off &amp; decking", "We remove the old roofing down to the deck and replace any rotted or damaged sheathing."],
      ["Underlayment &amp; flashing", "Waterproof underlayment, plus new flashing at chimneys, skylights, walls, and valleys, where most leaks start."],
      ["Shingles or metal", "Architectural asphalt shingles or standing-seam metal, installed to the manufacturer's specifications."],
      ["Ventilation &amp; gutters", "Roof vents to keep the attic dry, and new gutters and downspouts if yours need replacing."],
    ],
    gallery: [],
    quote: :rebecca,
    faq: [
      ["Do I need a new roof or just a repair?", %(Widespread curling, cracking, or missing shingles, moss damage, and repeated leaks usually mean it's time to replace. A single leak or a few damaged shingles can often be repaired; for repairs, our sister company #{SISTER_LINK} can help.)],
      ["Asphalt or metal roofing?", "Asphalt shingles cost less up front. Metal costs more but lasts longer and sheds rain and moss well. We'll go over the trade-offs for your home and budget."],
      ["Do you handle permits for a roof replacement?", "Yes. Where your city requires a permit for a re-roof, we apply for it and schedule the inspections."],
      LICENSED_FAQ,
    ],
  },
  # ============================== SIDING
  {
    slug: "siding", short: "Siding",
    title: "Siding Replacement &amp; Installation in Seattle &amp; the Eastside",
    meta: "Siding replacement and installation in Seattle and the Eastside: fiber cement, wood, and vinyl siding, house wrap, trim, and exterior paint from a licensed general contractor.",
    eyebrow: "Siding",
    h1: "A new face <em>for your home.</em>",
    lede: "Fiber cement, wood, and vinyl siding, installed over a proper weather barrier and finished with new trim and paint, so your home looks new and stays dry.",
    tags: ["Fiber cement", "Wood siding", "Vinyl siding", "House wrap", "Trim &amp; paint"],
    incl_h: "Siding that <em>keeps water out.</em>",
    incl_p: "Siding is your home's rain jacket. We fix what's behind it before the new siding goes up.",
    incl: [
      ["Removal &amp; inspection", "We take off the old siding and repair any rotted sheathing or framing we find."],
      ["Weather barrier", "New house wrap and flashing around windows and doors: the layer that actually keeps water out."],
      ["New siding", "Fiber cement, wood, or vinyl siding, installed to the manufacturer's specifications."],
      ["Trim &amp; paint", "Corner boards, window trim, soffits, and fascia, finished and painted."],
    ],
    gallery: [],
    quote: :rebecca,
    faq: [
      ["What siding works best in the Seattle climate?", "Fiber cement is a popular choice here because it resists rot, moisture, and fire. Wood looks great but needs more upkeep. Vinyl costs least. We'll help you compare."],
      ["Can you replace just part of the siding?", %(For small damaged sections, our sister company #{SISTER_LINK} handles siding repairs. We focus on full and large-area replacements.)],
      ["Should I replace my windows at the same time?", %(It's a good time to. With the siding off, the flashing around new windows can be done properly. See <a href="window-replacement.html" style="text-decoration:underline">window replacement</a>.)],
      LICENSED_FAQ,
    ],
  },
  # ============================== DECKS
  {
    slug: "decks", short: "Deck",
    title: "Deck Building &amp; Replacement in Seattle &amp; the Eastside",
    meta: "Deck building and replacement in Seattle and the Eastside: composite and wood decks, stairs, railings, and covered decks, designed and built by a licensed general contractor.",
    eyebrow: "Decks",
    h1: "Outdoor living, <em>built to last.</em>",
    lede: "New decks and deck replacements in composite or wood, with stairs, railings, and covers, built on solid footings and designed for how you'll use the space.",
    tags: ["Composite decks", "Wood decks", "Stairs &amp; railings", "Covered decks", "Deck replacement"],
    incl_h: "A deck that's <em>solid underfoot.</em>",
    incl_p: "What you don't see matters most: the footings, the framing, and how the deck connects to your house.",
    incl: [
      ["Design &amp; permits", "Size, shape, and layout planned around your yard, with permits where they're required."],
      ["Footings &amp; framing", "Concrete footings, treated framing, and a properly flashed connection to the house."],
      ["Decking", "Low-maintenance composite or natural wood decking, in the color and style you choose."],
      ["Stairs, railings &amp; covers", "Stairs, railings built to code, and optional covers or pergolas so you can use the deck in the rain."],
    ],
    gallery: [],
    quote: :rebecca,
    faq: [
      ["Composite or wood decking?", "Composite costs more up front but doesn't need staining and resists rot. Wood costs less and looks natural but needs regular maintenance in our climate."],
      ["Can you replace the boards but keep the frame?", "Sometimes. If the framing is sound, we can replace just the decking and railings. We inspect the frame first and tell you honestly."],
      ["Do I need a permit for a deck?", "Many decks do, especially ones attached to the house or above a certain height. We check your city's rules and handle the permit."],
      LICENSED_FAQ,
    ],
  },
  # ============================== PATIOS & PAVERS
  {
    slug: "patios-and-pavers", short: "Patio",
    title: "Paver Patios &amp; Walkways in Seattle &amp; the Eastside",
    meta: "Paver patios, walkways, and hardscaping in Seattle and the Eastside: base preparation, drainage, pavers, steps, and borders from a licensed general contractor.",
    eyebrow: "Patios &amp; pavers",
    h1: "Hardscaping <em>that stays level.</em>",
    lede: "Paver patios, walkways, steps, and fire-pit areas, built on a compacted base with drainage planned in, so they stay flat and dry for years.",
    tags: ["Paver patios", "Walkways", "Steps", "Fire-pit areas", "Drainage"],
    incl_h: "It starts <em>below the surface.</em>",
    incl_p: "Pavers sink and shift when the base is skipped. We dig, compact, and grade properly first.",
    incl: [
      ["Layout &amp; grading", "We plan the shape and slope so water runs away from your home."],
      ["Excavation &amp; base", "Excavation, fabric, and a compacted gravel base sized for the load."],
      ["Pavers &amp; stone", "Concrete pavers or natural stone, laid in the pattern you choose, with edge restraints."],
      ["Finishing", "Polymeric sand in the joints, plus steps, borders, and clean transitions to lawn or planting beds."],
    ],
    gallery: [],
    quote: :david,
    faq: [
      ["Pavers or poured concrete?", %(Pavers cost more but can be repaired one piece at a time and come in many styles. Poured concrete costs less up front; see our <a href="concrete-work.html" style="text-decoration:underline">concrete</a> page for that option.)],
      ["Will weeds grow between the pavers?", "Polymeric sand in the joints greatly reduces weeds and keeps the pavers locked in place."],
      ["Can you add a cover over the patio?", "Yes. We can build a covered area or pergola over a patio so you can use it year-round."],
      LICENSED_FAQ,
    ],
  },
  # ============================== DRIVEWAYS
  {
    slug: "driveways", short: "Driveway",
    title: "Driveway Replacement &amp; Installation in Seattle &amp; the Eastside",
    meta: "Driveway replacement and installation in Seattle and the Eastside: concrete and paver driveways, removal, base, drainage, and aprons from a licensed general contractor.",
    eyebrow: "Driveways",
    h1: "A driveway <em>without the cracks.</em>",
    lede: "Concrete and paver driveways, from tearing out the old one to a new base, drainage, and a clean finish, built to carry your cars for decades.",
    tags: ["Concrete driveways", "Paver driveways", "Removal", "Base &amp; drainage", "Aprons &amp; walkways"],
    incl_h: "Built for <em>the weight it carries.</em>",
    incl_p: "Most driveway cracks come from a weak base or poor drainage. We fix both before the new surface goes down.",
    incl: [
      ["Removal &amp; haul-away", "We break out and haul away the old driveway."],
      ["Base &amp; drainage", "A compacted gravel base and a slope that sends water away from the house and garage."],
      ["Concrete or pavers", "Reinforced concrete with control joints, or interlocking pavers, in the finish you choose."],
      ["Aprons &amp; connections", "Clean transitions to the street, garage, and walkways, with permits for street connections where required."],
    ],
    gallery: [],
    quote: :david,
    faq: [
      ["How soon can I drive on new concrete?", "Usually about a week for ordinary cars, and longer for heavy vehicles. We'll give you exact timing for your pour and the weather."],
      ["Can you widen my driveway?", "Often, yes, depending on your lot and your city's rules. We check before planning the new layout."],
      ["Concrete or pavers for a driveway?", "Concrete costs less and is simple to maintain. Pavers cost more but are easy to repair and offer more design options."],
      LICENSED_FAQ,
    ],
  },
  # ============================== FOUNDATION REPAIR
  {
    slug: "foundation-repair", short: "Foundation",
    title: "Foundation Repair in Seattle &amp; the Eastside",
    meta: "Foundation repair in Seattle and the Eastside: crack repair, settlement, drainage, seismic retrofits, and structural work, engineered and permitted, from a licensed general contractor.",
    eyebrow: "Foundation repair",
    h1: "Fix the base <em>everything rests on.</em>",
    lede: "Foundation cracks, settling, and water problems assessed with a structural engineer, then repaired, drained, and permitted by one team.",
    tags: ["Crack repair", "Settlement", "Drainage", "Structural reinforcement", "Seismic retrofits"],
    incl_h: "Engineered, <em>not guessed.</em>",
    incl_p: "Foundation work should start with a diagnosis. We bring in a structural engineer so the fix matches the actual problem.",
    incl: [
      ["Assessment", "We inspect the cracks, settlement, and moisture, and bring in a structural engineer when the problem calls for it."],
      ["Repair &amp; reinforcement", "Crack repair, new footings or wall sections, and reinforcement built to the engineer's plan."],
      ["Drainage &amp; waterproofing", "Grading, drains, and waterproofing that keep water away from the foundation."],
      ["Seismic retrofits", "Bolting and bracing that tie an older house to its foundation, to help it ride out an earthquake."],
    ],
    gallery: [],
    quote: :rebecca,
    faq: [
      ["Are foundation cracks always serious?", "No. Thin hairline cracks from concrete shrinking are common. Wide, growing, or uneven cracks, sticking doors, and sloping floors are worth having checked."],
      ["Do I need a structural engineer?", "For anything beyond minor cracks, yes. The engineer designs the repair, and we build it under permit."],
      ["What is a seismic retrofit?", "It strengthens how an older house connects to its foundation, usually by bolting the frame to the foundation and bracing the crawl space walls. It's often recommended for older homes in our area."],
      LICENSED_FAQ,
    ],
  },
  # ============================== LANDSCAPING
  {
    slug: "landscaping", short: "Landscaping",
    title: "Landscaping &amp; Yard Renovation in Seattle &amp; the Eastside",
    meta: "Landscaping and yard renovation in Seattle and the Eastside: lawns, turf, planting beds, retaining walls, drainage, irrigation, and outdoor lighting from a licensed general contractor.",
    eyebrow: "Landscaping",
    h1: "A yard you'll <em>actually use.</em>",
    lede: "Lawns, planting beds, retaining walls, drainage, irrigation, and lighting, planned together with your patio or deck so the whole yard works as one.",
    tags: ["Lawns &amp; turf", "Planting beds", "Retaining walls", "Drainage", "Irrigation &amp; lighting"],
    incl_h: "The whole yard, <em>in one plan.</em>",
    incl_p: "Good landscaping starts with grading and drainage. The walls, plants, and lighting come after.",
    incl: [
      ["Grading &amp; drainage", "Shaping the yard so water drains away from your home, with drains where they're needed."],
      ["Retaining walls", "Block or stone walls that turn slopes into usable, level space."],
      ["Lawns &amp; planting", "New sod, artificial turf, or planting beds with plants suited to our climate."],
      ["Irrigation &amp; lighting", "Drip and sprinkler systems, plus low-voltage lighting for paths and patios."],
    ],
    gallery: [],
    quote: :david,
    faq: [
      ["Can you do the yard along with a deck or patio?", %(Yes, and it's the best way to do it. Planning the <a href="decks.html" style="text-decoration:underline">deck</a> or <a href="patios-and-pavers.html" style="text-decoration:underline">patio</a> and the landscaping together avoids tearing up new work later.)],
      ["Do you install artificial turf?", "Yes. Artificial turf is a good option for shady or heavily used areas where grass struggles."],
      ["Do retaining walls need a permit?", "Taller walls, and walls holding back a load such as a driveway, often need a permit and engineering. We check your city's rules."],
      LICENSED_FAQ,
    ],
  },
  # ============================== FENCING
  {
    slug: "fencing", short: "Fence",
    title: "Fence Installation &amp; Replacement in Seattle &amp; the Eastside",
    meta: "Fence installation and replacement in Seattle and the Eastside: wood, horizontal, and metal fences and gates, set on concrete posts by a licensed general contractor.",
    eyebrow: "Fencing",
    h1: "Privacy and style, <em>built straight.</em>",
    lede: "Wood, horizontal, and metal fences and gates, set on concrete posts and built straight and level along your property line.",
    tags: ["Wood fences", "Horizontal fences", "Metal fences", "Gates", "Fence replacement"],
    incl_h: "A fence that <em>stays standing.</em>",
    incl_p: "Most fences fail at the posts. We set ours in concrete and build the rest to match.",
    incl: [
      ["Layout", "We confirm the line with you, check height rules, and have underground utilities located before digging."],
      ["Posts &amp; rails", "Posts set in concrete, with rails built straight and level, even on slopes."],
      ["Fence panels", "Cedar, horizontal slat, or metal styles, built to the height and privacy you want."],
      ["Gates &amp; hardware", "Walk and drive gates with sturdy hinges, latches, and locks."],
    ],
    gallery: [],
    quote: :rebecca,
    faq: [
      ["How tall can my fence be?", "It depends on your city and where the fence sits on your lot; front yards usually have lower limits. We check the rules for your address."],
      ["Do I need to know my property line?", "Yes. We build along the line you confirm, and a survey is the surest way to know where it is."],
      ["Can you remove my old fence?", "Yes. Removing and hauling away the old fence is part of a replacement."],
      LICENSED_FAQ,
    ],
  },
  # ============================== PLUMBING
  {
    slug: "plumbing", short: "Plumbing",
    title: "Remodel Plumbing &amp; Repiping in Seattle &amp; the Eastside",
    meta: "Remodel plumbing and repiping in Seattle and the Eastside: fixture relocation, whole-house repiping, water heaters, and drain, sewer, and gas lines, done by licensed plumbers under permit.",
    eyebrow: "Plumbing",
    h1: "The pipes behind <em>a great remodel.</em>",
    lede: "Moving fixtures, repiping older homes, new water heaters, and drain and sewer work, done by licensed plumbers under permit as part of your project.",
    tags: ["Repiping", "Fixture relocation", "Water heaters", "Drain &amp; sewer lines", "Gas lines"],
    incl_h: "Plumbing done <em>before the walls close.</em>",
    incl_p: "The best time to upgrade plumbing is during a remodel, while the walls are open.",
    incl: [
      ["Fixture relocation", "Moving sinks, toilets, showers, and appliances to where your new layout needs them."],
      ["Whole-house repiping", "Replacing old galvanized or failing pipes with new supply lines throughout the house."],
      ["Water heaters", "Tank and tankless water heaters, sized for your household and installed to code."],
      ["Drains, sewer &amp; gas", "New drain lines, sewer connections, and gas lines for ranges, fireplaces, and heaters."],
    ],
    gallery: [],
    quote: :rebecca,
    faq: [
      ["Who does the plumbing work?", "Licensed plumbers, working under permit as part of our team. The work is inspected before the walls are closed."],
      ["Do you handle small plumbing repairs?", %(For leaks, clogs, and other repairs, our sister company #{SISTER_LINK} is the right call. We focus on plumbing that's part of a remodel or upgrade.)],
      ["Should I repipe my older home?", "If your home still has galvanized steel or polybutylene pipes, repiping is often worth it, especially if you're already opening walls for a remodel."],
      LICENSED_FAQ,
    ],
  },
  # ============================== ELECTRICAL
  {
    slug: "electrical", short: "Electrical",
    title: "Remodel Electrical &amp; Upgrades in Seattle &amp; the Eastside",
    meta: "Remodel electrical work in Seattle and the Eastside: panel upgrades, rewiring, lighting, EV chargers, and new circuits for kitchens and additions, done by licensed electricians under permit.",
    eyebrow: "Electrical",
    h1: "Power and light <em>where you need them.</em>",
    lede: "Panel upgrades, rewiring, recessed and accent lighting, EV chargers, and new circuits for kitchens and additions, done by licensed electricians under permit.",
    tags: ["Panel upgrades", "Rewiring", "Lighting", "EV chargers", "New circuits"],
    incl_h: "Wiring that's <em>safe and up to date.</em>",
    incl_p: "New kitchens, additions, and EV chargers often need more power than an older home has. We plan the electrical along with the rest of the project.",
    incl: [
      ["Panel &amp; service upgrades", "Larger panels and service upgrades for new appliances, heat pumps, and EV chargers."],
      ["Rewiring", "Replacing old or unsafe wiring, such as knob-and-tube, while the walls are open."],
      ["Lighting", "Recessed, pendant, under-cabinet, and exterior lighting, with switches and dimmers where you want them."],
      ["Circuits &amp; EV chargers", "Dedicated circuits for kitchens and appliances, plus Level 2 EV charger installation."],
    ],
    gallery: [],
    quote: :david,
    faq: [
      ["Who does the electrical work?", "Licensed electricians, working under permit as part of our team. The work is inspected before the walls are closed."],
      ["Do you handle small electrical repairs?", %(For repairs and service calls, our sister company #{SISTER_LINK} is the right call. We focus on electrical work that's part of a remodel or upgrade.)],
      ["Do I need a panel upgrade for an EV charger?", "Not always. It depends on your panel's capacity and what else it powers. We check your panel before installing the charger and tell you what's needed."],
      LICENSED_FAQ,
    ],
  },
  # ============================== HVAC
  {
    slug: "hvac", short: "HVAC",
    title: "Heat Pumps, Mini-Splits &amp; HVAC in Seattle &amp; the Eastside",
    meta: "Heating and cooling in Seattle and the Eastside: heat pumps, ductless mini-splits, furnaces, ductwork, and ventilation for remodels, additions, and ADUs, installed by licensed technicians.",
    eyebrow: "Heating &amp; cooling",
    h1: "Comfortable <em>in every season.</em>",
    lede: "Heat pumps, ductless mini-splits, furnaces, and ductwork for remodels, additions, and ADUs, sized for your home and installed by licensed technicians.",
    tags: ["Heat pumps", "Ductless mini-splits", "Furnaces", "Ductwork", "Ventilation"],
    incl_h: "Heating and cooling, <em>sized right.</em>",
    incl_p: "A system that's too big or too small wastes energy and never feels right. We size the equipment to the home, then install it properly.",
    incl: [
      ["Heat pumps", "Efficient heating and cooling in one system, a strong fit for our mild climate."],
      ["Ductless mini-splits", "Heating and cooling for additions, ADUs, and rooms without ducts."],
      ["Furnaces &amp; ductwork", "Furnace replacement and new or extended ductwork for remodeled spaces."],
      ["Ventilation", "Bathroom and kitchen exhaust, plus fresh-air ventilation to control moisture."],
    ],
    gallery: [],
    quote: :david,
    faq: [
      ["Is a heat pump a good choice in Seattle?", "Usually, yes. Our mild winters suit heat pumps well, and they cool the house in summer too."],
      ["Can I heat and cool an addition without new ducts?", "Yes. A ductless mini-split is often the simplest way to heat and cool an addition, ADU, or converted space."],
      ["Do you repair existing HVAC systems?", %(For service and repairs, our sister company #{SISTER_LINK} can help. We focus on new systems and replacements as part of a project.)],
      LICENSED_FAQ,
    ],
  },
  # ============================== INSULATION
  {
    slug: "insulation", short: "Insulation",
    title: "Home Insulation &amp; Air Sealing in Seattle &amp; the Eastside",
    meta: "Home insulation in Seattle and the Eastside: attic, wall, crawl space, and basement insulation, air sealing, and vapor barriers, installed by a licensed general contractor.",
    eyebrow: "Insulation",
    h1: "A warmer home <em>for less energy.</em>",
    lede: "Attic, wall, crawl space, and basement insulation, with air sealing and vapor barriers, so your home stays comfortable and your heating bills come down.",
    tags: ["Attic insulation", "Wall insulation", "Crawl spaces", "Air sealing", "Vapor barriers"],
    incl_h: "Stop paying <em>to heat the outdoors.</em>",
    incl_p: "Insulation works best with air sealing. We close the gaps first, then insulate.",
    incl: [
      ["Attics", "Blown-in or batt insulation to bring older attics up to current levels."],
      ["Walls", "Insulation in open walls during a remodel, or blown into closed walls where possible."],
      ["Crawl spaces &amp; basements", "Insulated floors and walls, plus vapor barriers that keep ground moisture out."],
      ["Air sealing", "Sealing the gaps around lights, pipes, and the attic hatch, where heated air escapes."],
    ],
    gallery: [],
    quote: :rebecca,
    faq: [
      ["How do I know if my home needs more insulation?", "Cold rooms, drafts, high heating bills, and an attic where you can see the tops of the ceiling joists are all signs."],
      ["Can you insulate walls without opening them?", "Often, yes. Insulation can be blown into closed walls through small holes that are patched afterward."],
      ["Are there rebates for insulation?", "Some utilities offer rebates for insulation and air sealing. Check with yours; we can provide the project details they ask for."],
      LICENSED_FAQ,
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

def gallery_html(keys, note = nil)
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
          <p>#{note || "A few finished rooms from homes around Seattle."}</p>
        </div>
      </div>
      <div class="reel">
    #{cards}
      </div>
    </section>

  HTML
end

# ---------------------------------------------------------------- financing (Acorn Finance)
# Add  financing: { url: "...", project: "kitchen remodel" }  to a page in PAGES to show this section on it.
# The logo lives in assets/partners/acorn-finance.svg (Acorn's own logo file, unchanged).
def financing_html(f)
  return "" unless f
  <<~HTML
    <!-- FINANCING -->
    <section class="sheet sec fin" aria-labelledby="fin-t">
      <div class="wrap fin-in">
        <div class="fin-copy">
          <p class="eyebrow">Financing available</p>
          <h2 id="fin-t">Pay for your #{f[:project]} <em>over time.</em></h2>
          <p>We partner with Acorn Finance so you can compare loan offers from multiple lenders for your #{f[:project]}. Checking your options won't affect your credit score.</p>
          <a href="#{f[:url]}" target="_blank" rel="noopener" class="btn btn-ink">See financing options <span class="ar" aria-hidden="true">↗</span></a>
        </div>
        <a class="fin-card" href="#{f[:url]}" target="_blank" rel="noopener" aria-label="Acorn Finance: #{f[:project]} financing (opens in a new tab)">
          <span class="mono">Financing partner</span>
          <img src="assets/partners/acorn-finance.svg" width="438" height="155" alt="Acorn Finance">
          <span class="go">Visit Acorn Finance <span aria-hidden="true">↗</span></span>
        </a>
      </div>
      <div class="wrap"><p class="fin-fine">Financing is offered through Acorn Finance and its lending partners, not by Julius Remodeling Group. Acorn Finance is not a lender and does not make loans or credit decisions. Approval, rates, and terms depend on your credit and are set by the lender. Viewing offers uses a soft credit check; a lender may run a hard credit check if you choose to move forward with an offer.</p></div>
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
          <div><dt class="mono">Projects completed</dt><dd>1,500+</dd></div>
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

    #{options_html(pg[:options])}#{gallery_html(pg[:gallery], pg[:gallery_p])}#{pg[:extra]}<!-- PROCESS -->
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

    #{financing_html(pg[:financing])}<!-- FAQ -->
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

# Home page "Services" list: entries 06 onward, one per service group after Remodeling.
HOME_SVC_BLURBS = {
  "Additions &amp; new builds" => ["ADUs, second stories, additions, new homes", "More space on your lot: backyard cottages and ADUs, second-story and ground-level additions, and new custom homes."],
  "Exterior &amp; outdoor" => ["Roofing, siding, decks, driveways, landscaping", "The outside of your home and yard: roofing, siding, windows, decks, patios, concrete, driveways, foundations, landscaping, and fencing."],
  "Interior &amp; systems" => ["Flooring, carpentry, plumbing, electrical, HVAC", "Finish work and the systems behind the walls: flooring, carpentry, doors, stairs, drywall, plumbing, electrical, heating and cooling, and insulation."],
}
def home_svc_groups
  SERVICE_GROUPS.drop(1).each_with_index.map { |(t, list), i|
    sh, p = HOME_SVC_BLURBS.fetch(t)
    links = list.map { |x| %(<a href="#{x[:slug]}.html">#{x[:name]} <span aria-hidden="true">→</span></a>) }.join
    %(<details><summary><span class="mono">0#{i + 6}</span>#{t}<span class="sh">#{sh}</span><span class="pm" aria-hidden="true"></span></summary>\n        <div class="more"><p>#{p} Choose a service for the details.</p><div class="acts"><a href="consultation.html" class="btn btn-brass">Start with this <span class="ar" aria-hidden="true">→</span></a></div>\n          <div class="svc-links">#{links}</div></div></details>)
  }.join("\n      ")
end

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
# Each deal gets its own page (<slug>.html) and a card on specials.html.
# form_id is that deal's GoHighLevel form; it opens in a pop-up from the "Claim this offer" buttons on that page only.
PROMOS = [
  { slug: "bathroom-remodel-offer", amount: "$1,500", project: "bathroom remodel", label: "Bathroom remodeling", service: "bathroom-remodeling", form_id: "zVU6tpjeGSNDg2uBhzmy", form_name: "$1500 Discount Bathroom Remodeling", form_height: 720,
    blurb: "Get $1,500 toward the finish materials for a full bathroom remodel, such as tile, vanity, fixtures, and lighting. One team handles the whole job." },
  { slug: "kitchen-remodel-offer",  amount: "$1,000", project: "kitchen remodel",  label: "Kitchen remodeling",  service: "kitchen-remodeling", form_id: "sV78tURz979hTq0AppZt", form_name: "$1000 Off Kitchen Upgrade", form_height: 400,
    blurb: "Get $1,000 toward the finish materials for a kitchen remodel, such as countertops, backsplash tile, flooring, and lighting. One team handles the whole job." },
]
# Countdown timer from GoHighLevel. Change the timerId here to use a different timer.
PROMO_TIMER = %(<script src="https://widgets.leadconnectorhq.com/cdt/remoteEntry.js" timerId=6af4cf7678a6a6baacefb635 position="left" altText="Countdown Timer" data-v2='true'></script>)

def promo_ld(name, slug)
  %({"@context":"https://schema.org","@type":"WebPage","name":"#{name}","url":"https://juliusremodeling.com/#{slug}","publisher":{"@type":"Organization","name":"Julius Remodeling Group"}})
end

def promo_page(pr)
  form_url = "https://api.leadconnectorhq.com/widget/form/#{pr[:form_id]}"
  band = cta_band("Ready for #{pr[:amount]} <em>toward finish materials?</em>").sub(%(<a href="consultation.html" class="btn btn-night">Book a free consultation), %(<a href="#{form_url}" data-claim class="btn btn-night">Claim this offer))
  title = "#{pr[:amount]} Toward Finish Materials for Your #{pr[:project].split.map(&:capitalize).join(' ')}"
  <<~HTML
    #{head_html(title, "Limited-time offer from Julius Remodeling Group: #{pr[:amount]} toward finish materials for your #{pr[:project]} in Seattle and the Eastside. Book a free consultation before the offer ends.", promo_ld(title, pr[:slug]))}
    <body>

    #{header(pr[:slug])}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">Limited-time offer</p>
        <h1 id="h1">#{pr[:amount]} toward finish materials <em>for your #{pr[:project]}.</em></h1>
        <p class="lede">#{pr[:blurb]} Claim it before the countdown ends.</p>
        <div class="promo-time">
          <span class="mono">Offer ends in</span>
          <div class="timer">#{PROMO_TIMER}</div>
        </div>
        <div class="promo-acts">
          <a href="#{form_url}" data-claim class="btn btn-brass">Claim this offer <span class="ar" aria-hidden="true">→</span></a>
          <a href="tel:" data-tel class="btn btn-line">Call <span data-k="phone">[Phone]</span></a>
        </div>
      </div>
    </section>

    <section class="sheet sec" aria-labelledby="how" style="padding-top:clamp(56px,6vw,96px)">
      <div class="wrap promo-how">
        <div>
          <p class="eyebrow">How it works</p>
          <h2 id="how">Three steps to <em>claim your offer.</em></h2>
          <p class="note">Want to see what goes into the work first? Read about our <a href="#{pr[:service]}.html">#{pr[:label].downcase}</a>.</p>
        </div>
        <div>
          <ol class="promo-steps">
            <li><span class="no">1</span><div><h3>Claim this offer</h3><p>Press the button and send us the short form before the countdown ends. There is no obligation.</p></div></li>
            <li><span class="no">2</span><div><h3>We'll contact you</h3><p>We'll get in touch to set up your free consultation and talk through your #{pr[:project]}.</p></div></li>
            <li><span class="no">3</span><div><h3>Get #{pr[:amount]} in finish materials</h3><p>We put #{pr[:amount]} toward the finish materials for your #{pr[:project]}.</p></div></li>
          </ol>
          <p class="fine">Terms and conditions apply.</p>
          <a href="#{form_url}" data-claim class="btn btn-ink" style="margin-top:24px">Claim this offer <span class="ar" aria-hidden="true">→</span></a>
        </div>
      </div>
    </section>

    #{band}

    </main>

    #{footer}

    <dialog class="claim" id="claim" aria-labelledby="claim-t">
      <div class="hd">
        <div><span class="mono">Limited-time offer</span><h2 id="claim-t">#{pr[:amount]} toward finish materials</h2></div>
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

# ---------------------------------------------------------------- monthly giveaway (Specials page)
# UPDATE THIS EVERY MONTH: dates, headline, ways to qualify, gifts, and terms. Then rebuild.
#   on: false        hides the whole section
#   ends:            the section shows "X days left" and switches to "has ended" after this moment
#   image:           a photo in assets/photos/ ONLY if you own it or have permission (official press/media kit, or a
#                    licensed stock photo). nil = a designed gift tile is shown instead.
GIVEAWAY = {
  on: true,
  month: "November 2026",
  ends: "2026-11-30T23:59:59-08:00",
  title: "November giveaways. <em>Your next project comes with a little extra fun.</em>",
  sub: "Book a project or refer a friend, and get rewarded. For November 2026, choose one gift: Grand Theft Auto V or an Activate gaming experience.",
  ways: [
    { k: "Option 1", big: "$10,000<em>+</em>", h: "Book a remodeling project",
      items: ["Sign a remodeling contract valued over $10,000 during November 2026.", "Choose one of the two gifts below."] },
    { k: "Option 2", big: "Referrals", h: "Refer a friend · $10K+ project",
      items: ["Refer a new customer to Julius Remodeling Group.", "When they sign a remodeling contract over $10,000, you get a gift.", "Their project must be over $10,000 before taxes, the same as Option 1.", "Choose one of the two gifts below."] },
  ],
  gifts: [
    { no: "Gift 1", name: "Grand Theft Auto V", by: "Rockstar Games", theme: "gta", image: "assets/photos/giveaway-gta-v.jpg", w: 1106, h: 690, credit: "Image © Rockstar Games", alt: "Grand Theft Auto V cover art on a gold map of Los Santos",
      desc: "One of the best-selling video games of all time. Explore the huge open world of Los Santos and Blaine County, switch between three main characters, and pull off heists in story mode or online.",
      link: "https://www.rockstargames.com/gta-v", link_t: "Official Grand Theft Auto V site", note: "Rated M for Mature 17+" },
    { no: "Gift 2", name: "Activate gaming experience", by: "Activate · Tukwila, WA", theme: "act", image: "assets/photos/giveaway-activate.jpg", w: 1093, h: 683, credit: "Photo © Activate", alt: "Friends throwing glowing balls at targets in a neon-lit Activate game room",
      desc: "A real-life, interactive game experience for you and your crew. Move through game rooms full of light, sound, and physical challenges that test your speed, strategy, and teamwork.",
      link: "https://playactivate.com/location/tukwila-seattle", link_t: "Activate Tukwila location", note: "Great for families and friends" },
  ],
  terms: [
    "Promotion valid November 1–30, 2026.",
    "Remodeling contracts must exceed $10,000 before taxes. This applies to both booked projects and referrals.",
    "A signed contract is required to qualify.",
    "Referral gifts are awarded only after the referred customer signs a remodeling contract over $10,000.",
    "One gift per qualifying contract or successful referral. You choose one: Grand Theft Auto V or the Activate gaming experience, not both.",
    "Gifts are subject to availability.",
    "The Grand Theft Auto V platform and Activate experience details will be coordinated with the recipient.",
    "Grand Theft Auto V is rated M for Mature (17+). Gift recipients must be 18 or older.",
    "Gifts have no cash redemption value.",
    "Grand Theft Auto V is a trademark of Take-Two Interactive Software. Activate is a trademark of its owner. Julius Remodeling Group is not affiliated with, sponsored, or endorsed by Rockstar Games, Take-Two Interactive, or Activate.",
    "Julius Remodeling Group reserves the right to modify or discontinue the promotion, subject to applicable laws and commitments already made.",
  ],
}
# Referral form: set to a GoHighLevel form id to show that form in the pop-up instead.
# nil = the built-in form, which opens the visitor's email app with the referral filled in, addressed to your email.
REFERRAL_FORM_ID = nil
REFERRAL_PROJECTS = ["Kitchen", "Bathroom", "Basement", "Whole-home remodel", "ADU or addition", "Exterior or outdoor", "Other", "Not sure yet"]

GIFT_ART = {
  "gta" => %(<svg viewBox="0 0 120 80" width="150" height="100" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M30 22h60c10 0 16 8 18 20l3 16c1 8-8 12-14 6l-10-10H33L23 64c-6 6-15 2-14-6l3-16c2-12 8-20 18-20z"/><path d="M36 34v14M29 41h14"/><circle cx="80" cy="36" r="3"/><circle cx="88" cy="44" r="3"/></svg>),
  "act" => %(<svg viewBox="0 0 120 80" width="150" height="100" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M66 6L38 44h22l-6 30 28-40H60z"/><path d="M18 22l8 4M14 42h9M18 62l8-4M102 22l-8 4M106 42h-9M102 62l-8-4"/></svg>),
}

def giveaway_section
  g = GIVEAWAY
  return "" unless g[:on]
  ways = g[:ways].map { |w|
    %(<div class="gw-way"><span class="mono">#{w[:k]}</span><b>#{w[:big]}</b><h3>#{w[:h]}</h3><ul>#{w[:items].map { |t| "<li>#{t}</li>" }.join}</ul></div>)
  }.join("\n          ")
  gifts = g[:gifts].map { |x|
    media = x[:image] ? %(<img src="#{x[:image]}" width="#{x[:w]}" height="#{x[:h]}" loading="lazy" alt="#{x[:alt]}">#{x[:credit] ? %(<span class="gw-cr">#{x[:credit]}</span>) : ""}) : %(<div class="gw-art">#{GIFT_ART[x[:theme]]}<span>#{x[:name]}</span></div>)
    <<~CARD.chomp
      <article class="gw-gift gw-#{x[:theme]}">
                <figure class="gw-media">#{media}<span class="mono gw-no">#{x[:no]}</span></figure>
                <div class="gw-body">
                  <span class="mono">#{x[:by]}</span>
                  <h3>#{x[:name]}</h3>
                  <p>#{x[:desc]}</p>
                  <div class="gw-foot"><a href="#{x[:link]}" target="_blank" rel="noopener">#{x[:link_t]} <span aria-hidden="true">↗</span></a><span class="mono">#{x[:note]}</span></div>
                </div>
              </article>
    CARD
  }.join("\n          ")
  terms = g[:terms].map { |t| "<li>#{t}</li>" }.join("\n              ")
  <<~HTML
    <!-- GIVEAWAY -->
    <section class="sheet sec gw" id="giveaway" aria-labelledby="gw-t" data-ends="#{g[:ends]}">
      <div class="wrap">
        <div class="gw-head">
          <div class="gw-label"><span class="gw-gift-ico" aria-hidden="true"><svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="8" width="18" height="4" rx="1"/><path d="M12 8v13M5 12v9h14v-9M12 8c-2-4-6-4-6-1s4 1 6 1zM12 8c2-4 6-4 6-1s-4 1-6 1z"/></svg></span><span class="mono">#{g[:month]} · Limited time</span><span class="mono gw-left" hidden></span></div>
          <h2 id="gw-t">#{g[:title]}</h2>
          <p class="lede">#{g[:sub]}</p>
        </div>
        <div class="gw-ways">
          #{ways}
        </div>
        <div class="gw-choose"><span class="mono">Choose one gift: Gift 1 <b>or</b> Gift 2</span></div>
        <div class="gw-gifts" data-or="or">
          #{gifts}
        </div>
        <div class="gw-cta">
          <div>
            <h3>Ready to get <em>rewarded?</em></h3>
            <p>Whether you're planning your next remodeling project or know someone who is, Julius Remodeling Group wants to thank you.</p>
          </div>
          <div class="acts">
            <a href="consultation.html" class="btn btn-brass">Book a free consultation <span class="ar" aria-hidden="true">→</span></a>
            <button type="button" class="btn btn-line" data-refer>Refer a friend</button>
          </div>
        </div>
        <details class="gw-terms">
          <summary>Terms &amp; conditions</summary>
          <ul>
              #{terms}
          </ul>
        </details>
      </div>
    </section>

  HTML
end

def referral_dialog
  return "" unless GIVEAWAY[:on]
  if REFERRAL_FORM_ID
    url = "https://api.leadconnectorhq.com/widget/form/#{REFERRAL_FORM_ID}"
    body = %(<iframe data-src="#{url}" id="inline-#{REFERRAL_FORM_ID}" data-layout="{'id':'INLINE'}" data-trigger-type="alwaysShow" data-trigger-value="" data-activation-type="alwaysActivated" data-activation-value="" data-deactivation-type="neverDeactivate" data-deactivation-value="" data-form-name="Referral" data-height="760" data-layout-iframe-id="inline-#{REFERRAL_FORM_ID}" data-form-id="#{REFERRAL_FORM_ID}" style="height:760px;min-height:760px" title="Referral form"></iframe>)
  else
    opts = REFERRAL_PROJECTS.map { |o| "<option>#{o}</option>" }.join
    body = <<~FORM.chomp
      <form class="ref-form" novalidate>
            <fieldset><legend class="mono">About you</legend>
              <div class="field"><label for="rf-name">Your name</label><input id="rf-name" name="Your name" autocomplete="name" required></div>
              <div class="two"><div class="field"><label for="rf-phone">Your phone</label><input id="rf-phone" name="Your phone" type="tel" autocomplete="tel" required></div>
              <div class="field"><label for="rf-email">Your email</label><input id="rf-email" name="Your email" type="email" autocomplete="email" required></div></div>
            </fieldset>
            <fieldset><legend class="mono">Who you're referring</legend>
              <div class="field"><label for="rf-fname">Their name</label><input id="rf-fname" name="Friend's name" autocomplete="off" required></div>
              <div class="field"><label for="rf-fcontact">Their phone or email</label><input id="rf-fcontact" name="Friend's phone or email" autocomplete="off" required></div>
              <div class="field"><label for="rf-proj">Project type <span>(optional)</span></label><select id="rf-proj" name="Project type"><option value="">Choose one</option>#{opts}</select></div>
            </fieldset>
            <label class="nl-check"><input type="checkbox" name="consent" required><span>I confirm that the person I'm referring has agreed to be contacted by Julius Remodeling Group about their project.</span></label>
            <p class="ref-err" role="alert" hidden>Please fill in the required fields and check the box.</p>
            <button type="submit" class="btn btn-ink">Send my referral <span class="ar" aria-hidden="true">→</span></button>
            <p class="ref-note" role="status" hidden></p>
            <p class="nl-fine">We'll only use this information to contact your friend about their project and to send your gift. See our <a href="privacy-policy.html">Privacy Policy</a>.</p>
          </form>
    FORM
  end
  <<~HTML
    <dialog class="claim refer" id="refer" aria-labelledby="refer-t">
      <div class="hd">
        <div><span class="mono">#{GIVEAWAY[:month]} giveaway</span><h2 id="refer-t">Refer a friend</h2></div>
        <button type="button" class="x" aria-label="Close">×</button>
      </div>
      #{body}
    </dialog>
  HTML
end

# Two tiles at the top of the Specials page: one for the monthly giveaway, one for the booking rewards
def specials_jump
  best = PROMOS.map { |pr| pr[:amount].delete("$,").to_i }.max
  gw = GIVEAWAY[:on] ? %(<a class="sp-tile sp-gw" href="#giveaway"><span class="mono">#{GIVEAWAY[:month]} giveaway</span><b>Free gift</b><span class="t">#{GIVEAWAY[:gifts].map { |g| g[:name] }.join(" <i>or</i> ")}</span><span class="go">See the giveaway ↓</span></a>) : ""
  rw = %(<a class="sp-tile sp-rw" href="#rewards"><span class="mono">Booking rewards</span><b>Up to $#{best.to_s.reverse.scan(/\d{1,3}/).join(",").reverse}</b><span class="t">toward finish materials for your kitchen or bathroom</span><span class="go">See the rewards ↓</span></a>)
  %(<div class="sp-jump">#{gw}#{rw}</div>)
end

def promos_hub
  cards = PROMOS.map { |pr|
    %(<a class="promo-card" href="#{pr[:slug]}.html"><span class="rw-rib">Booking reward</span><span class="mono">#{pr[:label]}</span><b>#{pr[:amount]}</b><span class="pc-for">toward finish materials</span><p>#{pr[:blurb]}</p><span class="go">See this offer <span aria-hidden="true">→</span></span></a>)
  }.join("\n          ")
  <<~HTML
    #{head_html("Specials", "Current remodeling specials from Julius Remodeling Group: #{PROMOS.map { |pr| "#{pr[:amount]} toward finish materials for a #{pr[:project]}" }.join(', ')}. Serving Seattle and the Eastside.", promo_ld("Specials", "specials"))}
    <body>

    #{header("specials")}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">#{HOLIDAY[:on] ? HOLIDAY[:eyebrow] : "Specials"}</p>
        <h1 id="h1">#{HOLIDAY[:on] ? "Holiday <em>specials.</em>" : "Current <em>specials.</em>"}</h1>
        <p class="lede">#{HOLIDAY[:on] ? HOLIDAY[:hub_lede] + " " : ""}Limited-time offers on remodeling projects across Seattle and the Eastside. Choose an offer to see the details and how to claim it.</p>
        #{specials_jump}
      </div>
    </section>

    #{giveaway_section}<section class="sheet sec rw" id="rewards" aria-labelledby="rw-t">
      <div class="wrap">
        <div class="rw-head">
          <p class="eyebrow">Booking rewards</p>
          <h2 id="rw-t">Book your remodel. <em>Get rewarded.</em></h2>
          <p class="lede">Book a kitchen or bathroom remodel and we put <b>real money toward your finish materials</b>: tile, countertops, fixtures, lighting, and more.</p>
        </div>
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

    #{referral_dialog}
    #{tail_html}
  HTML
end

# ---------------------------------------------------------------- newsletter page
# GoHighLevel form "Newsletter Signup". If this id is set to nil, the page shows a sample form that does NOT send anything.
NEWSLETTER_FORM_ID = "8J9srvv6uEPwCzcWuH4n"
NEWSLETTER_FORM_HEIGHT = 600

def newsletter_form
  if NEWSLETTER_FORM_ID
    url = "https://msgsndr.com/widget/form/#{NEWSLETTER_FORM_ID}"
    <<~HTML.chomp
      <iframe
              src="#{url}"
              id="inline-#{NEWSLETTER_FORM_ID}"
              data-layout="{'id':'INLINE','minimizedTitle':'','isLeftAligned':true,'isRightAligned':false,'allowMinimize':true}"
              data-trigger-type="alwaysShow"
              data-trigger-value=""
              data-activation-type="alwaysActivated"
              data-activation-value=""
              data-deactivation-type="neverDeactivate"
              data-deactivation-value=""
              data-form-name="Newsletter Signup"
              data-height="#{NEWSLETTER_FORM_HEIGHT}"
              data-layout-iframe-id="inline-#{NEWSLETTER_FORM_ID}"
              data-form-id="#{NEWSLETTER_FORM_ID}"
              style="height:#{NEWSLETTER_FORM_HEIGHT}px;min-height:#{NEWSLETTER_FORM_HEIGHT}px"
              title="Newsletter Signup"></iframe>
            <p class="fallback">Form not loading? <a href="#{url}" target="_blank" rel="noopener">Open it in a new tab</a>.</p>
            <script src="https://link.msgsndr.com/js/form_embed.js"></script>
    HTML
  else
    <<~HTML.chomp
      <form class="nl-form" data-example novalidate>
              <p class="nl-note" role="status">Example only. This form is not connected yet and does not save anything.</p>
              <div class="field"><label for="nl-name">First name</label><input id="nl-name" name="first_name" type="text" autocomplete="given-name"></div>
              <div class="field"><label for="nl-email">Email</label><input id="nl-email" name="email" type="email" autocomplete="email" required></div>
              <label class="nl-check"><input type="checkbox" name="consent" required><span>Yes, send me project updates and specials from Julius Remodeling Group by email.</span></label>
              <button type="submit" class="btn btn-ink">Sign me up <span class="ar" aria-hidden="true">→</span></button>
              <p class="nl-fine">We only email when we have something worth sharing. Unsubscribe anytime. See our <a href="privacy-policy.html">Privacy Policy</a>.</p>
            </form>
    HTML
  end
end

def newsletter_page
  ld = %({"@context":"https://schema.org","@type":"WebPage","name":"Newsletter","url":"https://juliusremodeling.com/newsletter","publisher":{"@type":"Organization","name":"Julius Remodeling Group"}})
  <<~HTML
    #{head_html("Newsletter Sign-Up", "Sign up for the Julius Remodeling Group newsletter: new specials first, recent projects, and before-and-afters from Seattle and the Eastside.", ld)}
    <body>

    #{header("newsletter")}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">Newsletter</p>
        <h1 id="h1">Stay <em>in the loop.</em></h1>
        <p class="lede">Get our latest work and our specials by email. Sign up below and you'll hear about new offers before anyone else.</p>
      </div>
    </section>

    <section class="sheet sec" aria-labelledby="nl-t" style="padding-top:clamp(56px,6vw,96px)">
      <div class="wrap promo-how nl">
        <div>
          <p class="eyebrow">What you'll get</p>
          <h2 id="nl-t">Worth opening, <em>every time.</em></h2>
          <ol class="promo-steps">
            <li><span class="no">1</span><div><h3>Specials first</h3><p>New offers, like money toward finish materials for a kitchen or bathroom remodel, sent to subscribers as soon as they open.</p></div></li>
            <li><span class="no">2</span><div><h3>Our latest work</h3><p>Recently finished kitchens, bathrooms, and flooring, with before-and-after photos.</p></div></li>
            <li><span class="no">3</span><div><h3>No clutter</h3><p>We only email when we have something worth sharing, and you can unsubscribe with one click.</p></div></li>
          </ol>
          <p class="fine">Looking for a current deal? See our <a href="specials.html">specials</a>.</p>
        </div>
        <div class="form-card offer-form nl-card">
          #{NEWSLETTER_FORM_ID ? "" : %(<h3 class="nl-h">Sign up for the newsletter</h3>)}
          #{newsletter_form}
        </div>
      </div>
    </section>

    </main>

    #{footer(news: false)}

    #{tail_html}
  HTML
end

# ---------------------------------------------------------------- about page (about.html)
def about_page
  ld = %({"@context":"https://schema.org","@type":"AboutPage","name":"About Julius Remodeling Group","url":"https://juliusremodeling.com/about","publisher":{"@type":"Organization","name":"Julius Remodeling Group"}})
  goals = [
    ["01", "Vision", "Understand your vision", "We start by listening: what you want, what you need, and how you live in your home."],
    ["02", "Budget", "Work with your budget and schedule", "We plan around the number and the timing that work for you, and we're honest about what fits."],
    ["03", "Options", "Find the right solutions", "We help you explore your options and recommend practical ways to get there."],
    ["04", "Quality", "Deliver work you can trust", "Quality workmanship, clear communication, and clean, organized, respectful job sites."],
  ].map { |n, k, h, t| %(<article class="goal"><div class="idx mono"><span>#{n}</span><span>#{k}</span></div><h3>#{h}</h3><p>#{t}</p></article>) }.join("\n          ")
  <<~HTML
    #{head_html("About Us: Family Owned, 15+ Years", "Julius Remodeling Group is a family-owned company with over 15 years of experience and more than 1,500 completed projects across Seattle, Bellevue, and the Eastside.", ld)}
    <body>

    #{header("about")}

    <main id="top">

    <section class="dark page-top" aria-labelledby="h1">
      <div class="wrap">
        <p class="eyebrow">About us</p>
        <h1 id="h1">Family owned. <em>Built on experience.</em></h1>
        <p class="lede">Julius Remodeling &amp; Services is a family-owned company with over 15 years of experience in residential construction, remodeling, and home services.</p>
      </div>
    </section>

    <section class="sheet sec" aria-labelledby="story-t" style="padding-top:clamp(56px,6vw,96px)">
      <div class="wrap">
        <div class="stats about-stats">
          <div><b>15<em>+</em></b><span class="mono">Years of experience</span></div>
          <div><b>1,500<em>+</em></b><span class="mono">Completed projects</span></div>
          <div><b>10<em>+</em></b><span class="mono">Years in Greater Seattle</span></div>
        </div>
        <div class="about" style="margin:clamp(56px,6vw,96px) 0 0">
          <figure class="ph about-family"><img src="assets/photos/team-family.jpg" width="1274" height="1336" loading="lazy" alt="The Julius Remodeling family and team in matching Julius shirts"><figcaption class="mono">The Julius family &amp; team</figcaption></figure>
          <div class="txt">
            <p class="eyebrow">Our story</p>
            <h2 id="story-t">From Los Angeles <em>to Seattle.</em></h2>
            <p class="lead">Our journey began in Los Angeles, where we worked with one of the area's largest construction companies.</p>
            <p>There we gained hands-on experience in everything from basic home improvements to high-end custom renovations, ADU/DADU construction, garage conversions, additions, and complete home remodels.</p>
            <p>Over a decade ago, we brought that experience to the Greater Seattle area. Today, with more than 1,500 completed projects, we proudly serve homeowners throughout Seattle, Bellevue, the Eastside, and surrounding communities.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="sheet sec" aria-labelledby="how-t" style="background:var(--paper-2)">
      <div class="wrap">
        <div class="head">
          <div><p class="eyebrow">How we work</p><h2 id="how-t">Small on purpose. <em>Personal by design.</em></h2></div>
          <div class="about-cols">
            <p>We believe every successful project starts with understanding our customers' vision, needs, budget, and schedule. Our role is to help homeowners explore their options, find practical solutions, and turn their ideas into reality while making the process as straightforward and efficient as possible.</p>
            <p>As a small, family-owned business, we maintain low overhead and an organized, efficient operation. We don't take on more projects than we can properly manage, so we stay personally involved and give each customer the time and attention they deserve.</p>
          </div>
        </div>
        <h3 class="why-t" style="margin-top:clamp(48px,5vw,80px)">Our goal <em>is simple.</em></h3>
        <div class="goals">
          #{goals}
        </div>
        <a class="callout" href="https://www.juliusservices.com/" target="_blank" rel="noopener">
          <span class="mono">Repairs &amp; maintenance</span>
          <span class="ct">From complete home renovations to everyday repairs and maintenance. Smaller repairs and service calls are handled by our sister company, <em>Julius Services</em>.</span>
          <span class="ar" aria-hidden="true">↗</span>
        </a>
      </div>
    </section>

    #{cta_band("Let's talk about <em>your vision.</em>")}

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
File.write(File.join(ROOT, "specials.html"), promos_hub)
# The old address keeps working: promotions.html sends visitors to specials.html (vercel.json also redirects /promotions).
File.write(File.join(ROOT, "promotions.html"), %(<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>Specials · Julius Remodeling Group</title>\n<meta name="robots" content="noindex">\n<link rel="canonical" href="https://juliusremodeling.com/specials">\n<meta http-equiv="refresh" content="0; url=specials.html">\n</head>\n<body>\n<p>This page has moved to <a href="specials.html">Specials</a>.</p>\n</body>\n</html>\n))
File.write(File.join(ROOT, "newsletter.html"), newsletter_page)
File.write(File.join(ROOT, "about.html"), about_page)

{ "index.html" => [nil, true], "condo-remodeling.html" => ["condo-remodeling", false], "consultation.html" => ["consultation", false] }.each do |file, (cur, home)|
  path = File.join(ROOT, file)
  s = File.read(path)
  s = s.sub(%r{<header class="top[^"]*" id="hdr">.*?</header>}m) { header(cur, home: home) }
  s = s.sub(%r{<footer class="dark">.*?</footer>}m) { footer(home: home) }
  if home
    if s.include?("<!-- HOLIDAY -->")
      s = s.sub(%r{<!-- HOLIDAY -->.*?<!-- /HOLIDAY -->}m) { home_holiday_section }
    else
      s = s.sub("<!-- ONES -->") { home_holiday_section + "\n\n<!-- ONES -->" }
    end
    if s.include?("<!-- REFRESH -->")
      s = s.sub(%r{<!-- REFRESH -->.*?<!-- /REFRESH -->}m) { home_refresh_section }
    else
      s = s.sub("<!-- SERVICES -->") { home_refresh_section + "\n\n<!-- SERVICES -->" }
    end
    if s.include?("<!-- SUPPLIERS -->")
      s = s.sub(%r{<!-- SUPPLIERS -->.*?<!-- /SUPPLIERS -->}m) { home_suppliers_section }
    else
      s = s.sub("<!-- REVIEWS -->") { home_suppliers_section + "\n\n<!-- REVIEWS -->" }
    end
    if s.include?("<!-- SOCIAL -->")
      s = s.sub(%r{<!-- SOCIAL -->.*?<!-- /SOCIAL -->}m) { home_social_section }
    else
      s = s.sub("<!-- FAQ -->") { home_social_section + "\n\n<!-- FAQ -->" }
    end
    if s.include?("<!-- AREAS -->")
      s = s.sub(%r{<!-- AREAS -->.*?<!-- /AREAS -->}m) { home_areas_section }
    else
      s = s.sub("<!-- CTA BAND -->") { home_areas_section + "\n\n<!-- CTA BAND -->" }
    end
    s = s.sub(%r{<details><summary><span class="mono">06</span>.*?</details>(?=\n    </div>\n  </div>\n</section>)}m) { home_svc_groups }
    s = s.sub(%r{<div class="areas">.*?</div>}m) {
      %(<div class="areas">\n          <span class="mono">Areas we serve</span>\n          <ul>#{AREAS.map { |a| %(<li><a href="#{a[:slug]}.html">#{a[:name]}</a></li>) }.join}</ul>\n        </div>)
    }
  end
  File.write(path, s)
end
puts "built #{PAGES.size} service pages, #{AREAS.size} city pages, and service-areas.html"

# sitemap.xml for search engines (the hidden consultation page is left out on purpose)
urls = [""] + ALL.map { |s| s[:slug] } + ["service-areas"] + AREAS.map { |a| a[:slug] } + ["about", "specials", "newsletter"] + PROMOS.map { |pr| pr[:slug] } + ["terms-and-conditions", "privacy-policy"]
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

# Photo addresses carry a version number. Raise PHOTO_VERSION when photos are replaced or re-uploaded,
# so browsers fetch them fresh instead of using an old saved copy (or a saved "not found").
PHOTO_VERSION = 2
Dir.glob(File.join(ROOT, "*.html")).sort.each do |path|
  t = File.read(path)
  n = t.gsub(%r{(assets/photos/[^"?\s]+\.(?:jpg|png|mp4))(?:\?v=\d+)?"}) { %(#{$1}?v=#{PHOTO_VERSION}") }
  File.write(path, n) if n != t
end
puts "photo version #{PHOTO_VERSION} applied"
