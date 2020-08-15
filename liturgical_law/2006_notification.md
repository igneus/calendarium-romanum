---
source: Notitiae 475-476/2006, p. 96 http://www.cultodivino.va/content/dam/cultodivino/notitiae/2006/475-476%20DEF.pdf#page=34
note: |
  Not an act of liturgical legislation in a proper sense, but an authoritative example
  of correct application of the law in force.
---

CONGREGATIO DE CULTU DIVINO ET DISCIPLINA SACRAMENTORUM

NOTIFICAZIONE

La Congregazione per il Culto Divino e la Disciplina dei Sacramenti si fa premura
di attirare l’attenzione sulla occorrenza di alcune celebrazioni che ricorreranno
nell’anno 2008. In particolare, si fa presente che la solennità di San Giuseppe (19 marzo)
ricorre il mercoledì della Settimana Santa e la solennità dell’Annunciazione del Signore
(25 marzo) il martedì fra l’Ottava di Pasqua.

Secondo la normativa vigente contenuta nelle Normae Universales de Anno Liturgico
et de Calendario, le summenzionate solennità devono essere trasferite in tal modo:
« Sollemnitas S. Ioseph, ubi est de praecepto servanda, si cum Dominica
in Palmis de Passione Domini occurrit, anticipatur sabbato praecedenti, die 18 martii.
Ubi vero non est de praecepto servanda, a Conferentia Episcoporum ad alium diem
extra Quadragesimam transferri potest » (n. 56 f);
« Sollemnitas vero Annuntiationis Domini, quotiescumque occurrit aliquo die Hebdomadae
Sanctae, semper ad feriam II post dominicam II Paschae erit transferenda » (n. 60).

Pertanto, è stabilito che nell’anno 2008 la solennità di San Giuseppe sarà celebrata
il 15 marzo, ovvero il sabato precedente la Domenica delle Palme, mentre la solennità
dell’Annunciazione del Signore sarà celebrata il 31 marzo, ovvero il lunedì dopo
la II Domenica di Pasqua.

```ruby
calendar = CR::PerpetualCalendar.new(sanctorale: CR::Data::GENERAL_ROMAN.load)

expect(calendar[Date.new(2008, 3, 15)].celebrations[0].symbol).to be :joseph
expect(calendar[Date.new(2008, 3, 31)].celebrations[0].symbol).to be :annunciation
```
