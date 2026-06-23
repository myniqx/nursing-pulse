# nursing_pulse

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


 Temel İşlevler (Olmazsa olmaz)

  Emzirme takibi
  - Başlat / Bitir butonu + geçen süre sayacı  > burada uygulamanın sürekli açık kalmayacağını unutmamak lazım. bilgi gelir gelmez persist edilip, tekrar açılışta o bilgilerden durum hesaplanmalı, mesela başlatıldı, uygulama kapatıldı. tekrar açıldığında son başlatılan saatten geçen süre ve bitir buttonu görünümü gibi...
  - Sol / Sağ taraf seçimi >> bazen anne hemen sol dan sağa geçiyor. burada Sol ve Sağ bu checkbox gibi işlev mi görecek. misal Sol seçili iken başlat dedi, o sırada 10dakika geçti, annenin minimum çaba ile takip yapması için Sağa tıklaması yeterli olmalı. meme değişimi esnasında stop -> sağ -> start yapma işlemini anneye bırakmamalı bunu kolaylaştırmalıyız.
  - Her seans otomatik kayıt (saat, süre, taraf) > olası anne kapat demeyi unutursa, sessionu editleme özelliği koyabiliriz. atıyorum cocuk ağladı. 10dakika  sonra durdur dedi. elle bitiş süresini X dakika değiştirebilsin.

  Son seans bilgisi
  - "2 saat önce, Sol taraftan" gibi anlık hatırlatma — ekranı açınca ilk göz atılan şey > bu süper

  Sonraki önerilen besleme
  - Son seansın saatine + bebek yaşına göre "~4:30'da besle" tahmini > ayarlar kısmında bebek doğum tarihini sorup bunu biz hesaplayabilir miyiz?

  ---
  İstatistik Ekranı

  - Günlük toplam süre
  - Sol/Sağ denge (yüzde + görsel bar)
  - Günlük/haftalık seans geçmişi listesi
  - Gece beslemesi sayısı (gece 00:00–06:00 arası)
  - Ortalama seans süresi

  ---
  Benim önerdiğim ekstra fikirler

  Bebek profili
  Doğum tarihi girilirse yaşa göre "ideal besleme aralığı" öneri eşiği otomatik ayarlanır (yenidoğan: 2–3 saat, 3 ay+: 3–4 saat). > yes!

  Bez takibi
  Design'da zaten var — "6 today" satırı. Islak / kirli ayrımı + günlük sayım. Sağlık göstergesi olarak önemli. > bunun inputunu nasıl sağlarız. yine ana ekranda altta bir yere mi koyacağız yoksa Diapers cardına tıklanınca başka bir screena mı geçecek?

  Bildirim / hatırlatma
  Son beslemeden X saat sonra sessiz bildirim. Gece modu: titreşim only. > bildirim

  Büyüme notu
  Haftalık kilo girişi + basit grafik. Doktora götürmeden önce "son 2 haftada X gr aldı" özeti. > bu da mantıklı dieper gibi bu veri için ayrı bir screenmı koysak ana ekran emzirmeye odaklı. diğer kısma geçince bez ekleme çocuğun kilosunu girme (ne zaman girilirse default o tarih ve saat ile not alır, istatistiği bu veriden çıkarır, değişim vs.)

  ---
  Şimdilik dışarıda bırakabileceğimiz şeyler

  - Mama/şişe takibi (ml girişi) — karmaşıklık artıyor, v2 olabilir
  - Uyku takibi — ayrı bir uygulama konusu
  - Çoklu bebek — nadir ihtiyaç, ilk sürümü karmaşıklaştırır
