---
title: Notificatio de memoria beatae Mariae Virginis Ecclesiae Matris
promulgated: 2018-03-24 Prot. N. 138/18
source: Notitiae 2018, p. 80-81. www.cultodivino.va/content/dam/cultodivino/notitiae/2018/2018.pdf#page=82
---

# NOTIFICATIO DE MEMORIA BEATAE MARIAE VIRGINIS ECCLESIAE MATRIS

Post inscriptionem in Calendarium Romanum memoriæ obligatoriæ B.M.V. Ecclesiæ Matris, iam hoc anno
feria secunda post Pentecosten ab omnibus celebrandæ, opportunum visum est indicationes quæ sequuntur
præbere.

Rubrica quæ in Missali Romano legitur post formularia Missæ Pentecostes: « Ubi feria II vel
etiam III post Pentecosten sunt dies quibus fideles debent vel solent Missam frequentare, resumi
potest Missa dominicæ Pentecostes, vel dici potest Missa de Spiritu Sancto »
(*Missale Romanum,* p. 448), adhuc viget quia non derogat præcedentiæ inter dies liturgicos quæ,
quoad eorum celebrationem, unice regitur a *Tabula dierum liturgicorum* (cf. *Normæ universales
de Anno liturgico et de Calendario,* n. 59). Simili modo præcedentia ordinatur a normis de Missis
votivis: « Missæ votivæ per se prohibentur in diebus quibus occurrit memoria obligatoria aut feria
Adventus usque ad diem 16 decembris, feria temporis Nativitatis a die 2 ianuarii, et temporis
paschalis post octavam Paschatis. Si tamen utilitas pastoralis id postulet, in celebratione cum
populo adhiberi potest Missa votiva huic utilitati respondens, de iudicio rectoris ecclesiæ vel
ipsius sacerdotis celebrantis » (*Missale Romanum,* p. 1156; cf. *Institutio Generalis Missalis
Romani,* n. 376).

Tamen, ceteris paribus, præferenda est memoria obligatoria B.M.V. Ecclesiæ Matris, textibus Decreto
adnexis, cum Lectionibus indicatis, quæ tamquam propriæ censendæ sunt, quia mysterium Maternitatis
spiritualis illustrant. In proxima editione *Ordinis lectionum Missæ* n. 572 bis in rubrica expresse
indicabitur lectiones esse propriæ et ideo, quamvis agatur de memoria, dici debent loco lectionum
pro feriis occurrentium (cf. *Ordo lectionum Missæ, Prænotanda, n.* 83).

In casu occurrentiæ huius memoriæ cum alia memoria principia generalia normarum universalium
de Anno liturgico et de Calendario (cf. *Tabula dierum liturgicorum,* n. 60) sequenda sunt. Cum autem
memoria B.M.V. Ecclesiæ Matris sit Pentecoste coniuncta, sicut pariter memoria Immaculati Cordis
B.M.V. celebrationi Sacratissimi Cordis Iesu coniuncta est, in casu occurrentiæ cum alia memoria
alicuius Sancti vel Beati, iuxta liturgicam traditionem præstantiæ inter personas, memoria B.M.V.
prævalere debet.

```ruby
sanctorale = CR::Data::GENERAL_ROMAN_LATIN.load
calendar = CR::PerpetualCalendar.new sanctorale: sanctorale

has_occurrence = proc do |y|
  celebrations = sanctorale[CR::Temporale::Dates.mother_of_church(y)]

  (not celebrations.empty?) &&
    celebrations[0].obligatory_memorial?
end

years_with(&has_occurrence).each do |y|
  day = calendar[CR::Temporale::Dates.mother_of_church(y)]
  expect(day.celebrations.size).to be 1

  cel = day.celebrations[0]
  expect(cel.symbol).to be :mother_of_church
  expect(cel.rank).to be CR::Ranks::MEMORIAL_GENERAL
end
```

Ex Ædibus Congregationis de Cultu Divino et Disciplina Sacramentorum, die 24 mensis martii 2018.

Robertus Card. Sarah
*Præfectus*

Arturus Roche
*Archiepiscopus a Secretis*
