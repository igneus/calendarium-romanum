---
title: De occurrentia memoriae obligatoriae Immaculati Cordis Beatae Mariae Virginis una cum altera memoria eiusdem gradus
promulgated: 1998-12-08 CCDDS Prot. n. 2671/98/L
source: http://www.vatican.va/roman_curia/congregations/ccdds/documents/rc_con_ccdds_doc_20000630_memoria-immaculati-cordis-mariae-virginis_lt.html
---

# NOTIFICATIO : DE OCCURRENTIA MEMORIAE OBLIGATORIAE IMMACULATI CORDIS BEATAE MARIAE VIRGINIS UNA CUM ALTERA MEMORIA EIUSDEM GRADUS

Per Decretum die 1 ianuarii 1996 datum (Prot. 2376/95/L: cf. Notitiae 32 [1996] 654-656)
Congregatio de Cultu Divino et Disciplina Sacramentorum statuit celebrationem Immaculati Cordis
beatae Mariae Virginis in Calendario Romano generali, die iam statuto, inscribendam esse gradu
memoriae obligatoriae, loco memoriae ad libitum.

In casu quo praedicta memoria, cuius dies celebrationis mobilis est ac dependens a die celebrationis
Paschatis, eodem die occurrat una cum altera memoria obligatoria, illo anno hae duae memoriae
tamquam ad libitum retineri debent, iuxta indicationes quae in Instructione Calendaria particularia
diei 24 iunii 1970 relate ad calendaria particularia (n. 23c) inveniuntur.

Talis occurrentia accidentalis non invenitur ante annum 2003.

Ex aedibus Congregationis de Cultu Divino, die 8 mensis decembris 1998, in Sollemnitate Immaculatae Conceptionis beatae Mariae Virginis.

Georgius A. Card. MEDINA ESTÉVEZ
Praefectus

+ Gerardus M. AGNELO

Archiepiscopus a Secretis

```ruby
sanctorale = CR::Data::GENERAL_ROMAN_LATIN.load
calendar = CR::PerpetualCalendar.new sanctorale: sanctorale

years_with_occurrence = (2000 .. 2100).select do |y|
  celebrations = sanctorale[CR::Temporale::Dates.immaculate_heart(y)]

  (not celebrations.empty?) &&
    celebrations[0].memorial? &&
    celebrations[0].rank != CR::Ranks::MEMORIAL_OPTIONAL
end

expect(years_with_occurrence).not_to be_empty # make sure

# standard rank is obligatory memorial
expect(CR::Temporale::CelebrationFactory.immaculate_heart.rank).to be CR::Ranks::MEMORIAL_GENERAL

years_with_occurrence.each do |y|
  day = calendar[CR::Temporale::Dates.immaculate_heart(y)]
  expect(day.celebrations.size).to be >= 3 # ferial, Immaculate Heart, another optional memorial
  immaculate_heart = day.celebrations.find {|c| c.symbol == :immaculate_heart }

  expect(immaculate_heart.rank).to be CR::Ranks::MEMORIAL_OPTIONAL
end
```
