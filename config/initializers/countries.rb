# ActionKit uses some country names which don't match up to their official
# ISO names. So, we need to do some replacement on those names.

class CountriesExtension
  COUNTRIES = {
    bo: "Bolivia",
    cg: "Congo, PR",
    cd: "Congo, DPR",
    ci: "Cote d'Ivoire",
    ir: "Iran",
    kr: "South Korea",
    la: "Laos",
    kp: "North Korea",
    mo: "Macau",
    mk: "Macedonia",
    fm: "Micronesia",
    md: "Moldova",
    ps: "Palestine",
    ru: "Russia",
    mf: "Saint Martin",
    sx: "Sint Maarten",
    sy: "Syria",
    tz: "Tanzania",
    us: "United States of America",
    ve: "Venezuela",
    va: "Vatican",
    vg: "British Virgin Islands",
    bn: "Brunei",
    tl: "East Timor",
    fk: "Falkland Islands",
    an: "Netherlands Antilles",
    sh: "St. Helena",
    vn: "Vietnam"
  }
end

CountriesExtension::COUNTRIES.each do |code, country|
  ISO3166::Country.search(code).translations['en'] = country
end

