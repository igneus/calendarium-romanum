---
title: De celebratione Baptismatis Domini
promulgated: 1998-12-081977-10-07 CSCD Prot. CD 1400/77
source: Notitiae 136/1977, p. 477; http://www.cultodivino.va/content/dam/cultodivino/notitiae/1977/136.pdf#page=11
---

# DECRETUM DE CELEBRATIONE BAPTISMATIS DOMINI

Celebratio Baptismatis Domini in honore posita est per instaurationem Calendarii Romani generalis
et dominicae post Epiphaniam occurrenti assignata, quo facilius ab universa communitate christiana
hac die congregata ageretur. Magni enim momenti sunt aspectus doctrinales, pastorales et oecumenici
huius festi in historia salutis et in anno liturgico.

Attamen, in locis ubi sollemnitas Epiphaniae non est de praecepto servanda, et ideo dominicae intra
diem 2 et 8 ianuarii occurrenti assignatur, haud raro accidit ut festum Baptismatis Domini cum ipsa
sollemnitate Epiphaniae occurrat et proinde celebrari non possit.

Attentis insuper petitionibus pluribus de hac re factis, Sacra haec Congregatio pro Sacramentis
et Cultu Divino, approbante Summo Pontifice PAULO VI, statuit:

In locis ubi sollemnitas Epiphaniae in dominicam est transferenda et haec die 7 vel 8 ianuarii
incidit, ita ut festum Baptismatis Domini, eadem die occurrens, esset omittendum, idem festum
Baptismatis Domini ad feriam II immediate sequentem transferatur.

Contrariis quibuslibet minime obstantibus.

Ex aedibus Sacrae Congregationis pro Sacramentis et Cultu Divino, die 7  Octobris 1977.

Antonius Innocenti
*Archiep. tit. Aeclanen. a Secretis*

Iacobus R. Card. Knox
*Praefectus*

```ruby
is_case_mentionned = proc do |y|
  [7, 8].include? CR::Temporale::Dates.epiphany(y, sunday: true).day
end

years_with(&is_case_mentionned)
.each do |y|
  epiphany = CR::Temporale::Dates.epiphany(y, sunday: true)
  baptism = CR::Temporale::Dates.baptism_of_lord(y, epiphany_on_sunday: true)

  expect(baptism).to eq(epiphany + 1)
  expect(baptism).to be_monday
end

years_with do |y|
  !is_case_mentionned.(y)
end
.each do |y|
  with_translation = CR::Temporale::Dates.baptism_of_lord(y, epiphany_on_sunday: true)
  without_translation = CR::Temporale::Dates.baptism_of_lord(y)

  expect(with_translation).to eq without_translation
end
```
