---
title: Ordo lectionum missae, editio typica
promulgated: 1969-05-25 S. C. C. D. Prot. n. 106/69
source: https://archive.org/details/OLM1969/
notice: |
  Because most of the (lengthy) document deals with matters not relevant
  for our purposes, reproduced are only portions defining calendar rules,
  and only those which are not contained in "Normae universales"
  or other documents dedicated specifically to the calendar.
---

# Ordo lectionum missae

## Praenotanda

...

### Caput II: Descriptio ordinis lectionum

...

#### V. Tempus « per annum »

##### I. De ordinatione et electione textuum

Tempus « per annum » complectitur 33 vel 34 hebdomadas, quae extra tempora iam memorata
occurrunt. Incipit feria secunda quae sequitur dominicam post diem 6 ianuarii occurrentem,
et protrahitur usque ad feriam tertiam ante Quadragesimam inclusive; iterum incipit
feria secunda post Dominicam Pentecostes et explicit ante I Vesperas dominicae primae Adventus.

Lectionarium exhibet lectiones pro 34 dominicis et subsequentibus hebdomadis. Attamen
aliquando hebdomadae « per annum » sunt tantum 33. Praeterea aliquae dominicae aut ad
aliud tempus pertinent (dominica in qua fit Festum Baptismatis Domini et Dominica Pentecostes),
vel ab occurrente Sollemnitate impediuntur (ex. gr. Ss.ma Trinitate, D.N.I.C.
universorum Rege).

Ad recte ordinandum usum lectionum, quae pro tempore « per annum » statuuntur, ea
quae sequuntur serventur:

1. Dominica in qua fit Festum Baptismatis Domini locum tenet dominicae I «per annum »;
proinde, lectiones hebdomadae I inchoantur feria secunda post dominicam quae post diem
6 ianuarii occurrit.

```ruby
calendar = CR::Calendar.new year
day = calendar[CR::Temporale::Dates.baptism_of_lord(year) + 1]
expect(day.celebrations[0].rank).to be_ferial
expect(day.season).to be CR::Seasons::ORDINARY
expect(day.season_week).to be 1
```

2. Dominica quae sequitur Festum Baptismatis Domini est secunda « per annum ». Reliquae
ordine progressivo numerantur, usque ad dominicam quae praecedit initium Quadragesimae.
Lectiones hebdomadae in qua occurrit feria quarta Cinerum, post diem quae illam praecedit
intermittuntur.

```ruby
calendar = CR::Calendar.new year
day = calendar[CR::Temporale::DateHelper.sunday_after(CR::Temporale::Dates.baptism_of_lord(year))]
expect(day.celebrations[0].rank).to be_sunday
expect(day.season).to be CR::Seasons::ORDINARY
expect(day.season_week).to be 2
```

3. Quando lectiones temporis « per annum » post Dominicam .Pentecostes resumuntur,
ordinantur hoc modo:

a) Si dominicae « per annum » sunt 34, ea sumitur hebdomada quae immediate sequitur
hebdomadam cuius lectiones ultimo loco adhibitae sunt ante Quadragesimam. Ita, ex. gr.,
si hebdomadae ante Quadragesimam fuerunt sex, feria secunda post Pentecosten incipitur ab
hebdomada septima. Sollemnitas Ss.mae Trinitatis locum tenet dominicae « per annum ».

```ruby
calendar = CR::PerpetualCalendar.new

years_with do |y|
  sunday_count = (
    (CR::Temporale::Dates.baptism_of_lord(y) .. CR::Temporale::Dates.ash_wednesday(y))
	  .select(&:sunday?).size +
    (CR::Temporale::Dates.pentecost(y) ... CR::Temporale::Dates.first_advent_sunday(y + 1))
	  .select(&:sunday?).size
  )

  # make sure there is no third possibility
  raise "unexpected #{sunday_count} - year #{y}" unless [34, 33].include?(sunday_count)

  sunday_count == 34
end
.each do |y|
  before_ash_wednesday = CR::Temporale::Dates.ash_wednesday(y) - 1
  after_pentecost = CR::Temporale::Dates.pentecost(y) + 1

  expect(calendar[after_pentecost].season_week)
    .to eq(calendar[before_ash_wednesday].season_week + 1)
end
```

b) Si dominicae « per annum » sunt 33, omittitur prima hebdomada quae sumenda esset
post Pentecosten, ut retineantur in fine anni textus eschatologici qui ultimis duabus hebdomadis
assignantur. Ita, ex. gr. si hebdomadae ante Quadragesimam fuerunt quinque, feria secunda
post Pentecosten, omissa hebdomada sexta, incipitur ab hebdomada septima.

```ruby
calendar = CR::PerpetualCalendar.new

years_with do |y|
  (
    (CR::Temporale::Dates.baptism_of_lord(y) .. CR::Temporale::Dates.ash_wednesday(y))
	  .select(&:sunday?).size +
    (CR::Temporale::Dates.pentecost(y) ... CR::Temporale::Dates.first_advent_sunday(y + 1))
	  .select(&:sunday?).size
  ) == 33
end
.each do |y|
  before_ash_wednesday = CR::Temporale::Dates.ash_wednesday(y) - 1
  after_pentecost = CR::Temporale::Dates.pentecost(y) + 1

  expect(calendar[after_pentecost].season_week)
    .to eq(calendar[before_ash_wednesday].season_week + 2)
end
```



```ruby
# data from the table on page XXIII of the document,
# columns "Annus" and "Hebd. post Pent. est Hebd. per annum"

calendar = CR::PerpetualCalendar.new
[
  # [1969, 8], # calendarium-romanum does not operate in this period
  [1970, 7],
  [1971, 9],
  [1972, 7],
  # [1973, 11], # TODO: investigate - is incorrect the table, or our implementation?
  [1974, 9],
  [1975, 7],
  [1976, 10],
  [1977, 9],
  [1978, 6],
  [1979, 9],
  [1980, 8],
].each do |civil_year, ot_week_after_pentecost|
  liturgical_year = civil_year - 1
  day = calendar[CR::Temporale::Dates.pentecost(liturgical_year) + 1]
  expect(day.season).to be CR::Seasons::ORDINARY
  expect(day.season_week).to be ot_week_after_pentecost
end
```
