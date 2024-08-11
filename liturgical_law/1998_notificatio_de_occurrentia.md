---
title: De occurrentia memoriae obligatoriae Immaculati Cordis Beatae Mariae Virginis una cum altera memoria eiusdem gradus
promulgated: 1998-12-08 CCDDS Prot. n. 2671/98/L
source:
- http://www.vatican.va/roman_curia/congregations/ccdds/documents/rc_con_ccdds_doc_20000630_memoria-immaculati-cordis-mariae-virginis_lt.html
- Notitiae 392-393/1999, p. 157; http://www.cultodivino.va/content/dam/cultodivino/notitiae/1999/392-393.pdf#page=63
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

```ruby
sanctorale = CR::Data::GENERAL_ROMAN_LATIN.load
calendar = CR::PerpetualCalendar.new sanctorale: sanctorale

has_occurrence = proc do |y|
  celebrations = sanctorale[CR::Temporale::Dates.immaculate_heart(y)]

  (not celebrations.empty?) &&
    celebrations[0].obligatory_memorial?
end

# "Talis occurrentia accidentalis non invenitur ante annum 2003."
# (civil year 2003 is meant, i.e. liturgical year 2002/3, denoted simply as 2002 by the library)
expect((1996 .. 2001).select(&has_occurrence))
  .to be_empty

# standard rank is obligatory memorial
expect(CR::Temporale::CelebrationFactory.immaculate_heart.rank).to be CR::Ranks::MEMORIAL_GENERAL

years_with(from: 2002, &has_occurrence).each do |y|
  day = calendar[CR::Temporale::Dates.immaculate_heart(y)]
  expect(day.celebrations.size).to be >= 3 # ferial, Immaculate Heart, another optional memorial
  immaculate_heart = day.celebrations.find {|c| c.symbol == :immaculate_heart }

  expect(immaculate_heart.rank).to be CR::Ranks::MEMORIAL_OPTIONAL
end
```

Talis occurrentia accidentalis non invenitur ante annum 2003.

Ex aedibus Congregationis de Cultu Divino, die 8 mensis decembris 1998, in Sollemnitate Immaculatae Conceptionis beatae Mariae Virginis.

Georgius A. Card. MEDINA ESTÉVEZ
*Praefectus*

Gerardus M. AGNELO
*Archiepiscopus a Secretis*
