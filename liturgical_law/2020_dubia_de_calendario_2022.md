---
title: Responsum ad dubia de calendario liturgico exarando pro anno 2022
source: http://www.cultodivino.va/content/cultodivino/it/documenti/responsa-ad-dubia/2020/de-calendario-liturgico-2022.html
---

# RESPONSUM AD DUBIA DE CALENDARIO LITURGICO EXARANDO PRO ANNO 2022

Redactores nonnulli "Ordinis Missae celebrandae et Officii Divini persolvendi" dubia proposuerunt
de Calendario liturgico pro venturo anno 2022 exarando, cum sollemnitas quaedam die sabbati aut feria
secunda occurrit.

Attento numero 60 ["Normarum universalium de anno liturgico et de Calendario"](./2002_normae_universales.md),
infrascriptarum celebrationum ordo sequenti modo erit disponendus:

a) Sollemnitas Sanctae Dei Genetricis Mariae, die 1 ianuarii, sabbato.
   Dominica II Post Nativitatem, die 2 ianuarii.

   - Die 1 ianuarii II Vesperae et Missa vespertina sollemnitatis Sanctae Dei Genetricis Mariae celebrentur.

```ruby
calendar = CR::Calendar.new 2021, CR::Data::GENERAL_ROMAN_LATIN.load, vespers: true

date = Date.new(2022, 1, 1)
expect(date).to be_saturday

day = calendar[date]
expect(day.celebrations[0].symbol).to be :mother_of_god
expect(day.vespers).to be nil

expect(calendar[Date.new(2022, 1, 2)].celebrations[0].rank)
  .to be CR::Ranks::SUNDAY_UNPRIVILEGED
```

b) Sollemnitas S. Ioseph Sponsi Beatae Mariae Virginis, die 19 martii, sabbato.
   Dominica III in Quadragesima, die 20 martii.

   - Die 19 martii I Vesperae et Missa vespertina Dominicae III in Quadragesima celebrentur.

```ruby
calendar = CR::Calendar.new 2021, CR::Data::GENERAL_ROMAN_LATIN.load, vespers: true

date = Date.new(2022, 3, 19)
expect(date).to be_saturday

I18n.with_locale(:la) do
  day = calendar[date]
  expect(day.celebrations[0].symbol).to be :joseph
  expect(day.vespers.title).to eq 'Dominica III Quadragesimae'
end
```

c) Sollemnitas Nativitatis S. Ioanni Baptistae et sollemnitas Sacratissimi Cordis Iesu, eadem die 24 iunii
   coincidentes.

   - Die 24 iunii, feria VI: sollemnitas Sacratissimi Cordis Iesu celebretur.
     Sollemnitas Nativitatis S. Ioannis Baptistae ad diem 23 iunii, feriam V, transferatur,
	 II Vesperae omittantur. I Vesperae sollemnitatis Sacratissimi Cordis Iesu celebrentur.

```ruby
calendar = CR::Calendar.new 2021, CR::Data::GENERAL_ROMAN_LATIN.load, vespers: true

i23 = Date.new(2022, 6, 23)
i24 = i23 + 1

expect(i24).to be_friday

expect(calendar[i24].celebrations[0].symbol).to be :sacred_heart

day = calendar[i23]
expect(day.celebrations[0].symbol).to be :baptist_birth
expect(day.vespers.symbol).to be :sacred_heart
```

Ubi vero S. Ioannes Baptista patronus sit nationis vel dioecesis vel civitatis aut
communitatis religiosae, sollemnitas Nativitatis S. Ioannis Baptistae die 24 iunii,
feria VI, celebretur; sollemnitas autem Sacratissimi Cordis Iesu ad diem 23 iunii,
feriam V transferatur, usque ad horam Nonam inclusive.

```ruby
skip 'there is currently no pretty way how to model this scenario using calendarium-romanum -
  a custom Temporale is required, either with a changed date of Sacred Heart or with
  customized solemnity transfer logic'
```

d) Dominica XX Temporis "per annum", die 14 augusti.
   Sollemnitas Assumptionis Beatae Mariae Virginis, die 15 augusti, feria II.

   - Die 14 augusti I Vesperae et Missa in Vigilia sollemnitatis Assumptionis Beatae Mariae Virginis
     celebrentur.

```ruby
calendar = CR::Calendar.new 2021, CR::Data::GENERAL_ROMAN_LATIN.load, vespers: true

date = Date.new(2022, 8, 14)
expect(date).to be_sunday
expect(calendar[date].vespers.symbol).to be :assumption
```

Ex aedibus Congregationis de Cultu Divino et Disciplina Sacramentorum, die 11 mensis maii 2020.
