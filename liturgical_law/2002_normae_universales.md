---
title: Normae universales de anno liturgico et de calendario
# it is to be checked when the variants differing from the text published in the 1969 "Calendarium Romanum" book were introduced
promulgated: ?
effective_since: ?
source: Missale Romanum editio typica tertia 2002 https://media.musicasacra.com/books/latin_missal2002.pdf
---

# NORMAE UNIVERSALES DE ANNO LITURGICO ET DE CALENDARIO

## Caput I DE ANNO LITURGICO

**1.** Christi opus salutiferum sancta Ecclesia, statis diebus per anni
decursum, sacra recordatione celebrat. In unaquaque hebdomada, die
quae dominica appellatur, memoriam agit Resurrectionis Domini, quam
semel etiam in anno, maxima Paschae sollemnitate, una cum beata eius
Passione frequentat. Per anni vero circulum Christi totum mysterium
explicat nataliciaque Sanctorum commemorat.

Variis autem anni liturgici temporibus, iuxta traditas disciplinas, Ecclesia
fidelium eruditionem perficit, per pias animi et corporis exercitationes,
instructionem, precationem, paenitentiae et misericordiae opera. [1]

**2.** Principia quae sequuntur tum ad Ritum romanum tum ad omnes
alios Ritus applicari possunt ac debent, normae tamen practicae solum
ritum romanum spectare intellegendae sunt, nisi agatur de iis quae ex
ipsa rei natura alios quoque ritus afficiant.

    1 Cf. Conc. Vat. II, Const. de sacra Liturgia, Sacrosanctum Concilium, nn. 102-105.

    2 Cf. ibid., n. 3.

### Titulus I – De diebus liturgicis

#### I. De die liturgico in genere

**3.** Unusquisque dies sanctificatur liturgicis populi Dei celebrationibus,
praesertim vero sacrificio eucharistico et Officio divino.

Dies liturgicus decurrit a media nocte ad mediam noctem. Celebratio
vero dominicae et sollemnitatum incipit iam vespere diei praecedentis.

```ruby
i = 0

CR::Calendar.new(year, CR::Data::GENERAL_ROMAN_LATIN.load, vespers: true)
.each
.each_cons(2) do |yesterday, today|
  ct = today.celebrations.first
  cy = yesterday.celebrations.first

  if (ct.sunday? ||
      [CR::Ranks::SOLEMNITY_GENERAL, CR::Ranks::SOLEMNITY_PROPER].include?(ct.rank)) &&
     ct.rank > cy.rank
    expect(yesterday.vespers).to eq ct
    i += 1
  end
end

expect(i).to be > 0 # make sure that at least some first Vespers were actually encountered
```

#### II. De dominica

**4.** Primo uniuscuiusque hebdomadae die, quae dies Domini seu dies
dominica nuncupatur. Ecclesia, ex traditione apostolica, quae originem
ducit ab ipsa die Resurrectionis Christi, mysterium paschale celebrat.
Itaque dominica uti primordialis dies festus haberi debet. [3]

**5.** Propter suum peculiare momentum, dominica suam cedit celebrationem
solummodo sollemnitatibus necnon festis Domini; dominicae
vero Adventus, Quadragesimae et Paschae super omnia festa Domini et
super omnes sollemnitates praecedentiam habent. Sollemnitates autem in
his dominicis occurrentes ad feriam secundam sequentem transferuntur,
nisi agatur de occurrentia in Dominica in Palmis aut in Dominica Resurrectionis Domini.

```ruby
calendar = CR::PerpetualCalendar.new sanctorale: CR::Data::GENERAL_ROMAN_LATIN.load

annunciation = CR::AbstractDate.new 3, 25

years_with do |y|
  date = annunciation.in_year(y)

  date.sunday? &&
    calendar[date].season == CR::Seasons::LENT &&
    date < CR::Temporale::Dates.palm_sunday(y - 1) # not in Holy week
end
.each do |y|
  date = annunciation.in_year(y) + 1

  expect(date).to be_monday
  expect(calendar[date].celebrations[0].symbol).to be :annunciation
end
```

**6.** Dominica excludit per se assignationem perpetuam alius celebrationis. Attamen:

a) dominica infra octavam Nativitatis Domini, fit festum S. Familiae;

b) dominica post diem 6 ianuarii, fit festum Baptismatis Domini;

c) dominica post Pentecosten, fit sollemnitas Ss.mae Trinitatis;

d) dominica ultima “ per annum ”, fit sollemnitas Domini nostri Iesu Christi universorum Regis.

```ruby
calendar = CR::PerpetualCalendar.new

# a) Dominica infra octavam Nativitatis Domini, fit festum S. Familiae
d = Date.new 2013, 12, 29
expect(d).to be_sunday
day = calendar[d]
expect(day.celebrations[0]).to be_feast
expect(day.celebrations[0].symbol).to be :holy_family

# b) Dominica post diem 6 ianuarii, fit festum Baptismatis Domini;
d = Date.new 2014, 1, 12
expect(d).to be_sunday
day = calendar[d]
expect(day.celebrations[0]).to be_feast
expect(day.celebrations[0].symbol).to be :baptism_of_lord

# c) Dominica post Pentecosten, fit sollemnitas SS.mae Trinitatis;
d1 = Date.new 2014, 6, 8
expect(calendar[d1].celebrations[0].symbol).to be :pentecost

d = Date.new 2014, 6, 15
expect(d).to be_sunday
day = calendar[d]
expect(day.celebrations[0]).to be_solemnity
expect(day.celebrations[0].symbol).to be :holy_trinity

# d) Dominica ultima « per annum », fit sollemnitas D. N. I. C. universorum Regis.
d1 = Date.new 2014, 11, 30
expect(d1).to be_sunday
I18n.with_locale(:en) do
  expect(calendar[d1].celebrations[0].title).to eq '1st Sunday of Advent'
end

d = Date.new 2014, 11, 23
expect(d).to be_sunday
day = calendar[d]
expect(day.celebrations[0]).to be_solemnity
expect(day.celebrations[0].symbol).to be :christ_king
```

**7.** Ubi autem sollemnitates Epiphaniae, Ascensionis et Ss.mi Corporis et Sanguinis Christi
non sunt de praecepto servandae, assignentur dominicae tamquam
diei proprio, hac ratione:

a) Epiphania, dominicae a die 2 ad diem 8 ianuarii occurrenti;

b) Ascensio, dominicae VII Paschae;

c) sollemnitas Ss.mi Corporis et Sanguinis Christi, dominicae post Ss.mam Trinitatem.

```ruby
calendar = CR::PerpetualCalendar.new(temporale_options: {transfer_to_sunday: [:epiphany, :ascension, :corpus_christi]})

2000.upto(2100) do |liturgical_year|
  civil_year = liturgical_year + 1

  # a) Epiphania, dominicae a die 2 ad diem 8 ianuarii occurrenti;
  d = CR::Temporale::Dates.epiphany liturgical_year, sunday: true
  expect(d).to be_sunday
  expect(d).to be_between(Date.new(civil_year, 1, 2), Date.new(civil_year, 1, 8))
  expect(calendar[d].celebrations[0].symbol).to be :epiphany

  # b) Ascensio, dominicae VII Paschae;
  d = CR::Temporale::Dates.ascension liturgical_year, sunday: true
  expect(d).to be_sunday
  expect(d).to eq(CR::Temporale::Dates.pentecost(liturgical_year) - 7)
  expect(calendar[d].celebrations[0].symbol).to be :ascension

  # c) sollemnitas Ss.mi Corporis et Sanguinis Christi, dominicae post Ss.mam Trinitatem.
  d = CR::Temporale::Dates.corpus_christi liturgical_year, sunday: true
  expect(d).to be_sunday
  expect(d).to eq(CR::Temporale::Dates.holy_trinity(liturgical_year) + 7)
  expect(calendar[d].celebrations[0].symbol).to be :corpus_christi
end
```

#### III. De sollemnitatibus, festis et memoriis

**8.** Anni circulo, Ecclesia, mysterium Christi celebrando, etiam beatam
Dei Genetricem Mariam cum peculiari amore veneratur, memoriasque
Martyrum aliorumque Sanctorum pietati fidelium proponit. [4]

**9.** Sancti qui momentum universale prae se ferunt in Ecclesia universa
obligatorie celebrantur; ceteri, aut in calendario inscribuntur ad libitum
tamen celebrandi, aut particulari cuique Ecclesiae, vel nationi, vel
religiosae familiae, relinquuntur colendi. [5]

**10.** Celebrationes, iuxta momentum quod ipsis tribuitur, ita inter se
distinguuntur et nominantur: sollemnitas, festum, memoria.

**11.** Sollemnitates inter dies praecipuos adnumerantur, quorum celebratio
incipit a I Vesperis, die praecedenti. Nonnullae sollemnitates etiam
Missa propria vigiliae ditantur, vespere diei praecedentis adhibenda, si
Missa horis vespertinis celebratur.

**12.** Summarum sollemnitatum Paschae et Nativitatis celebratio per
octo dies continuos protrahitur. Utraque octava legibus propriis ordinatur.

**13.** Festa intra fines diei naturalis celebrantur; proinde non habent
I Vesperas, nisi de festis Domini agatur quae in dominicis “ per annum ”
et temporis Nativitatis occurrunt et pro earum Officio substituuntur.

```ruby
calendar = CR::PerpetualCalendar.new(vespers: true, sanctorale: CR::Data::GENERAL_ROMAN_ENGLISH.load)

presentation = CR::AbstractDate.new 2, 2
years_on_sunday, years_on_weekday = years.partition {|y| presentation.in_year(y).sunday? }

years_on_weekday.each do |year|
  day = calendar[presentation.in_year(year) - 1]
  expect(day.vespers).to be nil
end

years_on_sunday.each do |year|
  day = calendar[presentation.in_year(year) - 1]
  expect(day.vespers).to be_a CR::Celebration
  expect(day.vespers.symbol).to be :presentation_of_lord
end
```

**14.** Memoriae sunt obligatoriae vel ad libitum; earum autem celebratio cum
celebratione feriae occurrentis componitur secundum normas,
quae in Institutionibus generalibus Missalis Romani et de Liturgia Horarum exponuntur.

Memoriae vero obligatoriae, quae occurrunt in feriis Quadragesimae,
solummodo tamquam memoriae ad libitum celebrari possunt.

Si eodem die plures inscribuntur in calendario memoriae ad libitum,
una tantum celebrari potest, omissis ceteris.

**15.** In sabbatis “ per annum ”, in quibus non occurrat memoria obligatoria,
fieri potest memoria ad libitum de beata Maria Virgine.

```ruby
calendar = CR::PerpetualCalendar.new sanctorale: CR::Data::GENERAL_ROMAN_ENGLISH.load

free_saturdays = CR::Util::Year.new(2000).select do |date|
  day = calendar[date]

  date.saturday? &&
    day.season == CR::Seasons::ORDINARY &&
    day.celebrations.find {|c| c.rank > CR::Ranks::MEMORIAL_OPTIONAL }.nil?
end

expect(free_saturdays).not_to be_empty # make sure

free_saturdays.each do |date|
  expect(calendar[date].celebrations.find {|c| c.symbol == :saturday_memorial_bvm })
    .not_to be nil
end
```

    3 Cf. ibid., n. 106.

    4 Cf. ibid., nn. 103-104.

    5 Cf. ibid., n. 111.

#### IV. De feriis

**16.** Hebdomadae dies, qui post dominicam decurrunt, feriae nuncupantur;
diversa tamen ratione celebrantur, iuxta momentum ipsis proprium:

a) feria IV Cinerum et feriae Hebdomadae sanctae, a feria II ad feriam V inclusive, omnibus aliis celebrationibus praeferuntur;

b) feriae Adventus, a die 17 ad diem 24 decembris inclusive, et omnes feriae Quadragesimae memoriis obligatoriis praeferuntur;

c) ceterae feriae omnibus sollemnitatibus et festis cedunt et cum
memoriis componuntur.

### Titulus II – De anni circulo

**17.** Totum Christi mysterium per anni circulum ab Ecclesia recolitur,
ab incarnatione usque ad diem Pentecostes et ad exspectationem adventus
Domini. [6]

    6 Cf. ibid., n. 102.

#### I. De Triduo paschali

**18.** Cum vero humanae redemptionis et perfectae Dei glorificationis
opus adimpleverit Christus praecipue per suum paschale mysterium, quo
mortem nostram moriendo destruxit et vitam resurgendo reparavit,
sacrum paschale Triduum Passionis et Resurrectionis Domini uti totius
anni liturgici culmen effulget. [7] Fastigium igitur, quod dies dominica habet
in hebdomada, sollemnitas Paschae habet in anno liturgico. [8]

**19.** Triduum paschale Passionis et Resurrectionis Domini incipit a Missa
vespertina in Cena Domini, habet suum centrum in Vigilia paschali, et
clauditur Vesperis dominicae Resurrectionis.

**20.** Feria VI in Passione Domini, [9] et, iuxta opportunitatem, etiam
Sabbato sancto usque ad Vigiliam paschalem, [10] ubique celebratur sacrum
ieiunium paschale.

**21.** Vigilia paschalis, nocte sancta qua Dominus resurrexit, habetur
ut “ mater omnium sanctarum Vigiliarum ”, [11] in qua Ecclesia Christi
resurrectionem vigilando exspectat, eamque in sacramentis celebrat. Ergo
tota huius sacrae Vigiliae celebratio nocte peragi debet, ita ut vel incipiatur
post initium noctis vel finiatur ante diei dominicae diluculum.

```ruby
good_friday = CR::Temporale::Dates.good_friday year
easter = CR::Temporale::Dates.easter_sunday(year)

calendar = CR::PerpetualCalendar.new

good_friday.upto(easter) do |date|
  expect(calendar[date].season).to be CR::Seasons::TRIDUUM
end

expect(calendar[good_friday - 1].season).not_to be CR::Seasons::TRIDUUM
expect(calendar[easter + 1].season).not_to be CR::Seasons::TRIDUUM
```

    7 Cf. ibid., n. 5.

    8 Cf. ibid., n. 106.

    9 Cf. Paulus VI, Const. Apost. Paenitemini, 17 febr. 1966, II § 3: A.A.S. 58 (1966) p. 184.

    10 Cf. Conc. Vat. II, Const. de sacra Liturgia, Sacrosanctum Concilium, n. 110.

    11 S. Augustinus, Sermo 219: PL 38, 1088.

#### II. De tempore paschali

**22.** Quinquaginta dies a dominica Resurrectionis ad dominicam Pentecostes
in laetitia et exsultatione celebrantur sicut unus dies festus,
immo “ magna dominica ”. [12]

Hi sunt dies in quibus praecipue cantatur  Allelúia.

**23.** Dominicae huius temporis veluti dominicae Paschae habentur et,
post dominicam Resurrectionis, dominicae II, III, IV, V, VI, VII Paschae
nuncupantur; concluditur autem hoc sacrum quinquaginta dierum tempus dominica Pentecostes.

**24.** Octo primi dies temporis paschalis constituunt octavam Paschae
et uti sollemnitates Domini celebrantur.

```ruby
calendar = CR::PerpetualCalendar.new

easter = CR::Temporale::Dates.easter_sunday 2000

easter.upto(easter + 7) do |d|
  day = calendar[d]
  expect(day.celebrations.size).to be 1
  expect(day.celebrations[0]).to be_solemnity
end
```

**25.** Quadragesima die post Pascha celebratur Ascensio Domini, nisi,
ubi non est de praecepto servanda, VII dominica Paschae fuerit assignata (cf. n. 7).

```ruby
expect(CR::Temporale::Dates.easter_sunday(year) + 39)
  .to eq CR::Temporale::Dates.ascension(year)
```

**26.** Feriae post Ascensionem usque ad sabbatum ante Pentecosten inclusive ad adventum praeparant Spiritus Sancti Paracliti.

    12 S. Athanasius, Epist. fest. I: PG 26, 1366.

#### III. De tempore Quadragesimae

**27.** Tempus Quadragesimae ordinatur ad praeparationem celebrationis Paschae:
liturgia enim quadragesimalis tam catechumenos, per diversos initiationis christianae
gradus, quam fideles, memoriam Baptismi
recolentes et paenitentiam agentes, componit ad celebrandum paschale
mysterium. [13]

**28.** Tempus Quadragesimae decurrit a feria IV Cinerum ad Missam
in Cena Domini exclusive.

Ab initio Quadragesimae usque ad Vigiliam paschalem non dicitur
Allelúia.

```ruby
ashes = CR::Temporale::Dates.ash_wednesday year
maundy = CR::Temporale::Dates.good_friday(year) - 1

calendar = CR::PerpetualCalendar.new

ashes.upto(maundy) do |date|
  expect(calendar[date].season).to be CR::Seasons::LENT
end

expect(calendar[ashes - 1].season).not_to be CR::Seasons::LENT
expect(calendar[maundy + 1].season).not_to be CR::Seasons::LENT
```

**29.** Feria IV in capite Quadragesimae, quae ubique habetur ut dies
ieiunii, [14] imponuntur cineres.

**30.** Dominicae huius temporis appellantur dominicae I, II, III, IV, V
in Quadragesima. Dominica sexta, in qua initium sumit Hebdomada sancta,
dicitur “ Dominica in palmis de Passione Domini ”.

```ruby
calendar = CR::PerpetualCalendar.new

easter = CR::Temporale::Dates.easter_sunday 2000

I18n.with_locale(:la) do
  expect(calendar[easter - 7 * 6].celebrations[0].title)
    .to eq 'Dominica I Quadragesimae' # a slightly different form of the title

  expect(calendar[easter - 7].celebrations[0].title)
    .to eq 'Dominica in Palmis de Passione Domini'
end
```

**31.** Hebdomada sancta ordinatur ad recolendam Passionem Christi
ab eius ingressu messianico in Ierusalem.

Feria V Hebdomadae sanctae, mane, Episcopus, Missam cum suo presbyterio concelebrans,
olea sancta benedicit et chrisma conficit.

    13 Cf. Conc. Vat. II, Const. de sacra Liturgia, Sacrosanctum Concilium, n. 109.

    14 Cf. Paulus VI, Const. Apost. Paenitemini, 17 febr. 1966, II § 3: A.A.S. 58 (1966) p. 184.

#### IV. De tempore Nativitatis

**32.** Post annuam mysterii paschalis celebrationem, nihil antiquius
habet Ecclesia quam memoriam Nativitatis Domini et primarum eius
manifestationum recolere: quod fit tempore Nativitatis.

**33.** Tempus Nativitatis decurrit a I Vesperis Nativitatis Domini usque
ad dominicam post Epiphaniam, seu post diem 6 ianuarii, inclusive.

```ruby
nativity = CR::Temporale::Dates.nativity year
baptism = CR::Temporale::Dates.baptism_of_lord year

calendar = CR::PerpetualCalendar.new

nativity.upto(baptism) do |date|
  expect(calendar[date].season).to be CR::Seasons::CHRISTMAS
end

expect(calendar[nativity - 1].season).not_to be CR::Seasons::CHRISTMAS
expect(calendar[baptism + 1].season).not_to be CR::Seasons::CHRISTMAS
```

**34.** Missa in Vigilia Nativitatis adhibetur vespere diei 24 decembris
sive ante sive post I Vesperas.

Die autem Nativitatis Domini, Missa ter celebrari potest, secundum
antiquam traditionem romanam, scilicet in nocte, in aurora et in die.

**35.** Nativitas Domini suam habet octavam sic ordinatam:

a) dominica infra octavam, vel, ea deficiente, die 30 decembris, fit festum S. Familiae Iesu, Mariae et Ioseph;

b) die 26 decembris, fit festum S. Stephani, Protomartyris;

c) die 27 decembris, fit festum S. Ioannis, Apostoli et Evangelistae;

d) die 28 decembris, fit festum Ss. Innocentium;

e) dies 29, 30, 31 sunt dies infra octavam;

f) die 1 ianuarii, in octava Nativitatis, fit sollemnitas Sanctae Dei
Genetricis Mariae, in qua commemoratur etiam impositio Ss.mi Nominis Iesu.

```ruby
calendar = CR::PerpetualCalendar.new sanctorale: CR::Data::GENERAL_ROMAN_LATIN.load

year = 2000 # use fixed year - it would be too unwieldy to make this example work with random year

calendar[Date.new(year, 12, 26)].celebrations[0].tap do |c|
  expect(c).to be_feast
  expect(c.symbol).to be :stephen
end

calendar[Date.new(year, 12, 27)].celebrations[0].tap do |c|
  expect(c).to be_feast
  expect(c.symbol).to be :john_evangelist
end

calendar[Date.new(year, 12, 28)].celebrations[0].tap do |c|
  expect(c).to be_feast
  expect(c.symbol).to be :innocents
end

I18n.with_locale(:la) do
  29.upto(30) do |day|
    date = Date.new year, 12, day
    c = calendar[date].celebrations[0]

    if date.sunday?
      expect(c).to be_feast
      expect(c.symbol).to be :holy_family
    else
      expect(c.title).to match /De die .+? infra octavam Nativitatis/
    end
  end
end

# Dominica infra octavam ... deficiente, die 30 decembris, fit festum S. Familiae
years_with do |y|
  (26..31)
    .collect {|i| Date.new y, 12, i }
    .find(&:sunday?)
    .nil?
end
.each do |y|
  expect(calendar[Date.new(y, 12, 30)].celebrations[0].symbol).to be :holy_family
end
```

**36.** Dominica a die 2 ad diem 5 ianuarii occurrens est Dominica II
post Nativitatem.

```ruby
calendar = CR::PerpetualCalendar.new

second_sundays =
  years
    .collect {|year| (Date.new(year, 1, 2) .. Date.new(year, 1, 5)).select(&:sunday?) }
    .flatten

expect(second_sundays).not_to be_empty # make sure

I18n.with_locale(:la) do
  second_sundays.each do |date|
    expect(calendar[date].celebrations[0].title)
      .to eq 'Dominica II post Nativitatem'
  end
end
```

**37.** Epiphania Domini celebratur die 6 ianuarii, nisi, ubi non est de
praecepto servanda, assignata sit dominicae a die 2 ad diem 8 ianuarii
occurrenti (cf. n. 7).

**38.** Dominica post diem 6 ianuarii occurrente, fit festum Baptismatis Domini.

```ruby
expect(CR::Temporale::Dates.sunday_after(CR::Temporale::Dates.epiphany(year)))
  .to eq CR::Temporale::Dates.baptism_of_lord year
```

#### V. De tempore Adventus

**39.** Tempus Adventus duplicem habet indolem: est enim tempus praeparationis
ad sollemnia Nativitatis, in quibus primus Dei Filii adventus
ad homines recolitur, ac simul tempus quo per hanc recordationem mentes diriguntur
ad exspectationem secundi Christi adventus in fine temporum. His duabus rationibus,
tempus Adventus se praebet ut tempus devotae ac iucundae exspectationis.

**40.** Tempus Adventus incipit a I Vesperis dominicae quae incidit in
diem 30 novembris vel est huic vicinior, et explicit ante I Vesperas Nativitatis Domini.

```ruby
first_advent = CR::Temporale::Dates.first_advent_sunday year
vigil_of_nativity = CR::Temporale::Dates.nativity(year) - 1

# incidit in diem 30 novembris vel est huic vicinior
expect(first_advent).to be_within(6).of(Date.new(year, 11, 30))

calendar = CR::PerpetualCalendar.new

first_advent.upto(vigil_of_nativity) do |date|
  expect(calendar[date].season).to be CR::Seasons::ADVENT
end

expect(calendar[first_advent - 1].season).not_to be CR::Seasons::ADVENT
expect(calendar[vigil_of_nativity + 1].season).not_to be CR::Seasons::ADVENT
```

**41.** Dominicae huius temporis nuncupantur dominicae I, II, III, IV Adventus.

```ruby
calendar = CR::PerpetualCalendar.new

first_advent = CR::Temporale::Dates.first_advent_sunday year
I18n.with_locale(:la) do
  expect(calendar[first_advent].celebrations[0].title)
    .to eq 'Dominica I Adventus'
end
```

**42.** Feriae a die 17 ad diem 24 decembris inclusive modo magis directo ad praeparationem Nativitatis Domini ordinantur.

#### VI. De tempore “ per annum ”

**43.** Praeter tempora propriam indolem habentia, triginta tres vel
triginta quattuor supersunt hebdomadae per anni circulum, in quibus non
celebratur peculiaris mysterii Christi aspectus; sed potius ipsum mysterium
Christi in sua plenitudine recolitur, praesertim vero diebus dominicis.
Huiusmodi periodus, tempus “ per annum ” nuncupatur.

**44.** Tempus “ per annum ” incipit feria II quae sequitur dominicam post
diem 6 ianuarii occurrentem et protrahitur usque ad feriam III ante
Quadragesimam inclusive; iterum incipit feria II post dominicam Pentecostes
et explicit ante I Vesperas dominicae I Adventus.

Eadem ratione adhibetur series formulariorum, quae pro dominicis
et feriis huius temporis invenitur tum in Missali tum in Liturgia Horarum (voll. III-IV).

```ruby
after_baptism = CR::Temporale::Dates.baptism_of_lord(year) + 1
before_ashes = CR::Temporale::Dates.ash_wednesday(year) - 1

after_pentecost = CR::Temporale::Dates.pentecost(year) + 1
before_first_advent = CR::Temporale::Dates.first_advent_sunday(year + 1) - 1

calendar = CR::PerpetualCalendar.new

after_baptism.upto(before_ashes) do |date|
  expect(calendar[date].season).to be CR::Seasons::ORDINARY
end

expect(calendar[after_baptism - 1].season).not_to be CR::Seasons::ORDINARY
expect(calendar[before_ashes + 1].season).not_to be CR::Seasons::ORDINARY

after_pentecost.upto(before_first_advent) do |date|
  expect(calendar[date].season).to be CR::Seasons::ORDINARY
end

expect(calendar[after_pentecost - 1].season).not_to be CR::Seasons::ORDINARY
expect(calendar[before_first_advent + 1].season).not_to be CR::Seasons::ORDINARY
```

#### VII. De Rogationibus et Quattuor anni Temporibus

**45.** In Rogationibus et Quattuor anni Temporibus, Ecclesia solet pro
variis hominum necessitatibus, imprimis vero pro fructibus terrae et
hominum laboribus, Dominum exorare, eique publice gratias referre.

**46.** Ut Rogationes et Quattuor anni Tempora diversis locorum et fidelium
necessitatibus aptari possint, quoad tempus et rationem illa celebrandi
a Conferentiis Episcoporum ordinentur oportet.

De eorum proinde amplitudine celebrationis, per unum vel plures dies
protrahendae, de eorum iteratione per anni decursum, normae statuantur
a competenti auctoritate, attentis necessitatibus localibus.

**47.** Missa pro singulis diebus harum celebrationum, inter Missas pro variis necessitatibus
eligatur, quae sit magis accommodata supplicationum proposito.

## Caput II DE CALENDARIO

### Titulus I – De calendario et celebrationibus in eo inscribendis

**48.** Ordinatio celebrationis anni liturgici calendario regitur, quod est
generale vel particulare, prouti statutum est in usum totius Ritus romani,
vel in usum alicuius Ecclesiae particularis vel familiae religiosae.

**49.** In calendario generali universus cyclus celebrationum inscribitur,
tum mysterii salutis in Proprio de tempore, tum eorum Sanctorum qui
momentum universale prae se ferunt, et ideo obligatorie ab omnibus celebrantur,
tum aliorum qui universalitatem et continuitatem sanctitatis
in populo Dei demonstrant.

Calendaria vero particularia celebrationes magis proprias continent
congruenti ratione cum cyclo generali organice compositas. [15] Singulae enim
Ecclesiae vel familiae religiosae Sanctos, qui ipsis sunt peculiari ratione
propria, peculiari honore prosequantur oportet.

Calendaria tamen particularia, a competenti auctoritate componenda,
ab Apostolica Sede sunt probanda.

**50.** In componendis calendariis particularibus, ad haec attendatur:

a) Proprium de tempore, seu cyclus temporum, sollemnitatum et festorum,
quo mysterium redemptionis in anno liturgico explicatur et
colitur, integer semper servetur, et debita praeminentia gaudeat super
celebrationes particulares.

b) Celebrationes propriae organice cum celebrationibus universalibus
componantur, attentis ordine et praecedentia in tabula dierum liturgicorum
pro singulis indicatis. Ne tamen calendaria particularia plus aequo
onerentur, singuli Sancti unica celebratione in anno liturgico gaudeant,
servata, ubi rationes pastorales id suadeant, altera celebratione in forma
memoriae ad libitum pro translatione aut inventione sanctorum Patronorum
aut Fundatorum Ecclesiarum vel familiarum religiosarum.

c) Celebrationes indultae ne sint duplicatio aliarum celebrationum in
cyclo mysterii salutis iam occurrentium, neque numero plus aequo
augeantur.

**51.** Quamvis conveniat ut quaevis dioecesis suum Calendarium
et Proprium Officiorum atque Missarum habeat, nihil tamen obstat quominus
Calendaria et Propria habeantur universae provinciae aut regioni aut
nationi, vel etiam latiori dicioni, communia, ab iis quorum interest, mutua cooperatione paranda.

Quod principium, aequa ratione, servari potest etiam in calendariis
religiosis pro pluribus provinciis eiusdem dicionis civilis.

**52.** Calendarium particulare conficitur inserendo calendario generali
sollemnitates, festa et memorias quae sunt propria, idest:

a) In calendario dioecesano, praeter celebrationes Patronorum,
et dedicationis ecclesiae cathedralis, Sancti et Beati, qui cum dioecesi
peculiarem habent necessitudinem, ex. gr. originis, commorationis longioris,
obitus.

b) In calendario religioso, praeter celebrationes Tituli, Fundatoris et
Patroni, Sancti et Beati, qui illius familiae religiosae sodales fuerunt vel
cum ea peculiarem relationem habuerunt.

c) In calendario singularum ecclesiarum, praeter celebrationes proprias
dioecesis aut familiae religiosae, celebrationes ipsius ecclesiae propriae,
quae in tabula dierum liturgicorum recensentur, necnon Sancti
quorum corpus in eadem ecclesia asservatur. Sodales autem familiarum
religiosarum cum communitate Ecclesiae localis iunguntur in celebrandis
anniversario dedicationis ecclesiae cathedralis et Patronis principalibus loci et amplioris dicionis ubi degunt.

**53.** Quando aliqua dioecesis vel aliqua familia religiosa pluribus Sanctis
et Beatis decoratur, cavendum est ne calendarium universae dioecesis
vel universi Instituti plus aequo gravetur. Proinde:

a) haberi potest imprimis celebratio communis omnium Sanctorum
et Beatorum dioecesis vel familiae religiosae, vel alicuius ordinis eorum;

b) singulari celebratione inscribantur calendario tantummodo Sancti
vel Beati, qui peculiare momentum prae se ferunt pro universa dioecesi
vel familia religiosa;

c) ceteri Sancti et Beati celebrentur tantum iis in locis cum quibus
strictiores habent necessitudines, aut ubi eorum corpus asservatur.

**54.** Celebrationes propriae, nisi aliter pro aliquibus earum in tabula
dierum liturgicorum praevideatur, aut peculiares rationes exstent historicae
aut pastorales, ut memoriae obligatoriae vel ad libitum inscribantur.
Nihil tamen impedit quominus aliquae celebrationes pro certis locis
modo sollemniore fiant quam in universa dioecesi vel familia religiosa.

**55.** Celebrationes calendario proprio inscriptae ab omnibus qui ad
illud calendarium tenentur servari debent; et nonnisi approbante Apostolica
Sede e calendario expungi vel gradu mutari possunt.

    15 Cf. S. Congr. pro Cultu Divino, Instr. Calendaria particularia, 24 iunii 1970: A.A.S. 62 (1970) pp. 651-663.

### Titulus II – De celebrationum die proprio

**56.** Sanctos consuevit Ecclesia celebrare ipsorum die natalicio: quod
opportune servetur etiam in propriis celebrationibus calendario particulari inscribendis.

Attamen, etsi celebrationes propriae peculiare momentum habent pro
singulis Ecclesiis particularibus vel familiis religiosis, valde tamen
expedit ut, in celebrandis sollemnitatibus, festis et memoriis obligatoriis,
quae in calendario generali recensentur, unitas, quantum fieri potest,
habeatur.

Proinde in celebrationibus propriis calendario particulari inscribendis, haec serventur:

a) Celebrationes quae etiam in calendario generali recensentur, eodem
die quo ibi inscriptae sunt, calendario proprio inscribantur, mutato, si
necesse est, gradu celebrationis.

Idem servetur in inscribendis celebrationibus alicui tantum ecclesiae
propriis, ad calendarium dioecesanum vel religiosum quod attinet.

b) Celebrationes Sanctorum, quae in calendario generali non inveniuntur, diei natalicio assignentur.

Quando vero dies natalicius ignoratur, celebratio assignetur diei alia
ratione eidem Sancto proprio, ex. gr. diei ordinationis, inventionis,
translationis; secus diei qui in calendario particulari liber sit ab aliis celebrationibus.

c) Si vero dies natalicius vel proprius impeditur alia celebratione obligatoria,
etiam inferioris gradus, in calendario generali vel particulari, assignetur proximiori diei similiter non impedito.

d) Attamen si agitur de celebrationibus quae ob rationes pastorales ad alium
diem transferri nequeunt, transferatur celebratio impediens.

e) Aliae celebrationes, quae indulta vocantur, inscribantur die aptiore
sub respectu pastorali.

f) Ut autem cyclus anni liturgici plena sua luce fulgeat, neque celebrationes
Sanctorum perpetuo impediantur, dies quibus plerumque tempus Quadragesimae
et octava Paschae occurrunt, necnon dies a 17 ad
31 decembris, a celebrationibus particularibus liberi maneant, nisi agatur
de memoriis non obligatoriis vel de festis de quibus in tabula dierum
liturgicorum, n. 8 a, b, c, d, aut de sollemnitatibus quae ad aliud tempus
nequeunt transferri.

Sollemnitas S. Ioseph, ubi est de praecepto servanda, si cum Dominica
in palmis de Passione Domini occurrit, anticipatur sabbato praecedenti,
die 18 martii. Ubi vero non est de praecepto servanda, a Conferentia Episcoporum
ad alium diem extra Quadragesimam transferri potest.

```ruby
calendar = CR::PerpetualCalendar.new sanctorale: CR::Data::GENERAL_ROMAN_LATIN.load

joseph = CR::AbstractDate.new 3, 19

years_with do |y|
  joseph.in_year(y + 1) == CR::Temporale::Dates.palm_sunday(y)
end
.each do |y|
  date = Date.new(y + 1, 3, 18)
  expect(date).to be_saturday
  expect(calendar[date].celebrations[0].symbol).to be :joseph
end
```

**57.** Si qui Sancti vel Beati una simul calendario inscribuntur, simul
semper celebrantur, quoties eodem gradu sunt celebrandi, etsi unus aut
aliqui eorum sunt magis proprii. Si vero unus aut aliqui ex his Sanctis
vel Beatis gradu superiore sunt celebrandi, fiat Officium de his tantum,
omissa celebratione ceterorum, nisi conveniat eos alii diei assignare ad
modum memoriae obligatoriae.

**58.** Ad bonum pastorale fidelium procurandum, in dominicis “ per annum ”,
licet eas celebrationes agere, quae infra hebdomadam occurrunt,
quaeque ipsorum fidelium pietati sunt acceptae, dummodo hae in tabula
praecedentiae ipsi dominicae praeponantur. De his celebrationibus dici
possunt omnes Missae quae concurrente populo celebrantur.

**59.** Praecedentia inter dies liturgicos, quoad eorum celebrationem,
unice regitur sequenti tabula.

---

Tabula dierum liturgicorum
secundum ordinem praecedentiae disposita

I

**1.** Triduum paschale Passionis et Resurrectionis Domini.

**2.** Nativitas Domini, Epiphania, Ascensio et Pentecostes.
Dominicae Adventus, Quadragesimae et Paschae.
Feria IV Cinerum.
Feriae Hebdomadae sanctae, a feria II ad feriam V inclusive.
Dies infra octavam Paschae.

**3.** Sollemnitates Domini, beatae Mariae Virginis, et Sanctorum in Calendario generali inscriptae.
Commemoratio omnium fidelium defunctorum.

**4.** Sollemnitates propriae, nempe:
- a) Sollemnitas Patroni principalis loci seu oppidi aut civitatis.
- b) Sollemnitas dedicationis et anniversarii dedicationis ecclesiae propriae.
- c) Sollemnitas Tituli ecclesiae propriae.
- d) Sollemnitas aut Tituli, aut Fundatoris, aut Patroni principalis Ordinis seu Congregationis.

II

**5.** Festa Domini in Calendario generali inscripta.

**6.** Dominicae temporis Nativitatis et dominicae “ per annum ”.

**7.** Festa beatae Mariae Virginis et Sanctorum Calendarii generalis.

**8.** Festa propria, nempe:
- a) Festum Patroni principalis dioecesis.
- b) Festum anniversarii dedicationis ecclesiae cathedralis.
- c) Festum Patroni principalis regionis aut provinciae, nationis, amplioris territorii.
- d) Festum Tituli, Fundatoris, Patroni principalis Ordinis seu Congregationis et provinciae religiosae, salvis praescriptis sub n. 4.
- e) Alia festa alicui ecclesiae propria.
- f) Alia festa inscripta in calendario cuiusque dioecesis vel Ordinis seu Congregationis.

**9.** Feriae Adventus a die 17 ad 24 decembris inclusive.
Dies infra octavam Nativitatis.
Feriae Quadragesimae.

III

**10.** Memoriae obligatoriae Calendarii generalis.

**11.** Memoriae obligatoriae propriae, nempe:
- a) Memoriae Patroni secundarii loci, dioecesis, regionis aut provinciae religiosae.
- b) Aliae memoriae obligatoriae inscriptae in calendario cuiusque dioecesis, vel Ordinis seu Congregationis.

**12.** Memoriae ad libitum, quae tamen, modo quidem peculiari in Institutionibus generalibus Missalis Romani et de Liturgia Horarum descripto, fieri possunt etiam diebus de quibus sub n. 9.
Hac eadem ratione, ut memoriae ad libitum celebrari possunt memoriae obligatoriae, quae accidentaliter occurrunt in feriis Quadragesimae.

**13.** Feriae Adventus usque ad diem 16 decembris inclusive.
Feriae temporis Nativitatis a die 2 ianuarii ad sabbatum post Epiphaniam.
Feriae temporis paschalis a feria II post octavam Paschae ad sabbatum ante Pentecosten inclusive.
Feriae “ per annum ”.

---

**60.** Si eodem die plures celebrationes occurrunt, fit de ea quae in tabula dierum liturgicorum superiorem obtinet locum.

Attamen sollemnitas, quae impeditur a die liturgico, qui praecedentia gaudeat,
ad proximiorem diem transferatur qui sit liber a diebus sub nn. 1-8 in tabula
praecedentiae recensitis, servatis iis quae n. 5 statuuntur. Sollemnitas vero
Annuntiationis Domini, quotiescumque occurrit aliquo die Hebdomadae sanctae,
semper ad feriam II post dominicam II Paschae erit transferenda.
Reliquae celebrationes eo anno omittuntur.

```ruby
# Sollemnitas ... Annuntiationis Domini, quotiescumque occurrit aliquo die Hebdomadae sanctae,
# semper ad feriam II post dominicam II Paschae erit transferenda.

calendar = CR::PerpetualCalendar.new sanctorale: CR::Data::GENERAL_ROMAN_LATIN.load

annunciation = CR::AbstractDate.new 3, 25

years_in_holy_week = years.select do |y|
  date = annunciation.in_year y + 1

  date >= CR::Temporale::Dates.palm_sunday(y) &&
    date <= CR::Temporale::Dates.easter_sunday(y)
end

expect(years_in_holy_week).not_to be_empty

years_in_holy_week.each do |y|
  date = CR::Temporale::Dates.easter_sunday(y) + 8
  expect(date).to be_monday
  expect(calendar[date].celebrations[0].symbol).to be :annunciation
end
```

**61.** Si vero eodem die celebrandae sint Vesperae Officii currentis et
I Vesperae diei sequentis, praevalent Vesperae celebrationis quae in
tabula dierum liturgicorum superiorem obtinet locum; in casu autem
paritatis, Vesperae diei currentis.

```ruby
# for general example of first vespers, see p. 3

# "... in casu autem paritatis, Vesperae diei currentis"
i = 0

CR::Calendar.new(year, CR::Data::GENERAL_ROMAN_LATIN.load, vespers: true)
.each
.each_cons(2) do |yesterday, today|
  ct = today.celebrations.first
  cy = yesterday.celebrations.first

  if (ct.sunday? ||
      [CR::Ranks::SOLEMNITY_GENERAL, CR::Ranks::SOLEMNITY_PROPER].include?(ct.rank)) &&
     ct.rank == cy.rank # casus paritatis
    expect(yesterday.vespers).to be nil
    i += 1
  end
end

expect(i).to be > 0 # make sure that at least some first Vespers were actually encountered
```
