---
source: Notitiae 549-550/2012, p. 269; http://www.cultodivino.va/content/dam/cultodivino/notitiae/2012/549-550 DEF.pdf#page=80
note: |
  Not an act of liturgical legislation in a proper sense, but an authoritative example
  of correct application of the law in force.
---

# Declaratio circa Sollemnitatem Annuntiationis Domini anno 2013 celebrandam

Cum anno 2013, die 25 martii incidat feria II Hebdomadae
Sanctae, iuxta Tabulam dierum liturgicorum secundum ordinem
praecedentiae dispositam et secundum n. 60 Normarum de Anno
liturgico et de Calendario, sollemnitas Annuntiationis Domini
celebrabitur die 8 aprilis, scilicet feria II post Dominicam II Paschae, sicut
ex editione typica tertia Missalis Romani patet.

```ruby
calendar = CR::Calendar.new(2012, CR::Data::GENERAL_ROMAN.load)

day = calendar[Date.new(2013, 4, 8)]
expect(day.celebrations.first.symbol).to be :annunciation
```

# Declaratio circa sollemnitatem Immaculatae Conceptionis Beatae Mariae Virginis a. 2013 in Dominica II Adventus incidentem

Cum anno 2013, die 8 decembris incidat Dominica II Adventus,
iuxta Tabulam dierum liturgicorum secundum ordinem praecedentiae
dispositam et secundum nn. 5 et 60 Normarum de Anno liturgico
et de Calendario, sollemnitas Immaculatae Conceptionis Beatae
Mariae Virginis celebrabitur die 9 decembris, feria II post Dominica
II Adventus.

```ruby
calendar = CR::Calendar.new(2013, CR::Data::GENERAL_ROMAN.load)

day = calendar[Date.new(2013, 12, 9)]
expect(day.celebrations.first.symbol).to be :bvm_immaculate
```
