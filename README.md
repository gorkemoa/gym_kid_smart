SmartKid Adında Ama appde GyBoree olacak bir app yapacağız.
Gönderdiğim Ekran görüntülerini baz alacak.
UYGULAMA TÜRKÇE İNGİLİZCE OLACAK JSONA GÖRE HER ZAMAN YAZACAKSIN SAKIN UNUTMA!
ASLA RENKLER STATİK OLAYACAK APİDEN GELEN RENKLERİ KULLAN!
DEĞİŞTİRİLEMEZ KURALLAR (TARTIŞMASIZ) 1.1 Statik veri kesinlikle YASAK
Dummy / mock / hardcoded veri yok

Local JSON yok

“Şimdilik böyle gösterelim” yok

UI’da sahte metin/sayı/flag yok

Her şey API’dan gelir. API eksikse AI SORAR.

1.2 API Response eksiksiz kullanılacak

Backend’in döndürdüğü:

data, meta, pagination, status, message, errors vb. alanların tamamı modele karşılık gelmek zorundadır. “Lazım değil” denilerek atlanamaz.

1.3 Kurumsal disiplin

AI:

Feature ekleyemez

Field uyduramaz

Backend’de yokken UI state alanı üretip “veri varmış” gibi gösteremez

Onaysız refactor/yeniden mimari öneremez

Emin değilse: SOR.

ZORUNLU MİMARİ
Bu proje sadece şu mimaride ilerler:

Models → Views → ViewModels → Services → Core

Başka mimari (clean architecture, bloc-first, redux vs.) önerilemez.

ZORUNLU KLASÖR YAPISI lib/ app/ app_constants.dart api_constants.dart app_theme.dart
core/ network/ api_client.dart api_result.dart api_exception.dart responsive/ size_config.dart size_tokens.dart utils/ logger.dart validators.dart

models/ services/ viewmodels/

views/ home/ home_view.dart widgets/ ... job_detail/ job_detail_view.dart widgets/ ... profile/ profile_view.dart widgets/ ...

🔴 Global widgets klasörü YASAK

Aşağıdakiler kesinlikle OLMAZ:

core/widgets/ common/widgets/ shared/widgets/

Her ekranın widget’ları kendi klasöründe olmak zorundadır: views//widgets/

RESPONSIVE / ÖLÇÜ SİSTEMİ (ZORUNLU) 4.1 Sabit pixel ile ölçü vermek YASAK
padding: 16

fontSize: 14

height: 52

radius: 12

Bu tarz değerler View içinde yazılamaz.

4.2 Yüzdeli / token bazlı ölçü zorunlu

Tüm boyutlar buradan referans alınır:

core/responsive/size_config.dart (ekran ölçülerini çıkarır)

core/responsive/size_tokens.dart (tek kaynak ölçü seti)

Padding / margin / radius / font / icon size / box ölçüleri → sadece token.

4.3 Theme üzerinden yönetim

Renk, tipografi, spacing yaklaşımı:

app/app_theme.dart

core/responsive/size_tokens.dart

View içinde inline stil minimum.

4.4 Büyük Ekran ve Sistem Ayarı Koruması (ZORUNLU)

Uygulamanın iPhone Pro Max, Tabletler ve büyük ekranlı Android cihazlarda devasa görünmesini engellemek için:

Scaling Cap (Ölçekleme Sınırı): size_config.dart içindeki hesaplamalar iPhone 13 ölçüleri (Genişlik: 390px, Yükseklik: 844px) ile sınırlandırılmalıdır. Bu sınırın üzerindeki cihazlarda öğeler büyümez, ekran ferahlar.
Font Scaling Protection: Sistem ayarlarından yazı tipi boyutu değiştirilse bile tasarımın bozulmaması için main.dart içinde MediaQuery'ye textScaler: TextScaler.noScaling eklenmelidir.
Platform Uyumu: Bu kurallar hem iOS hem de Android için ortak uygulanır.
MVVM AKIŞI (NET)
View → ViewModel → Service → ApiClient → HTTP

5.1 View (UI)

Sadece render eder

ViewModel state dinler

Event çağırır

View içinde:

API çağrısı YASAK

JSON parse YASAK

Business logic YASAK

5.2 ViewModel (Ekran mantığı)

Her ViewModel tek ekrana hizmet eder. Mega ViewModel YASAK.

Zorunlu state standardı:

bool isLoading

String? errorMessage

T? data veya List

pagination varsa: page, hasMore, isLoadingMore

Zorunlu metotlar:

init() / onReady()

refresh()

loadMore() (varsa)

onRetry()

5.3 Service (API + mapping)

Endpoint’e gider

Response’u model’e map eder

ViewModel’e model döndürür

Service içinde:

Endpoint string yazmak YASAK (ApiConstants kullanılacak)

Ham HTTP response döndürmek YASAK

5.4 Model (JSON)

Her model:

fromJson(Map<String, dynamic>)

toJson()

Unused alanlar bile:

Model’de bulunur

Nullable olabilir

Silinmez

UI alanları (örn isSelected) modele yazılmaz; ViewModel state’idir.

API STANDARTLARI (ZORUNLU) 6.1 Authorization header zorunlu
Tüm isteklerde:

Accept: application/json

Bu olmadan istek atılamaz.
6.2 Endpoint yönetimi tek yerde

Service / ViewModel içinde "/v1/..." gibi string YASAK.

Tümü:

app/api_constants.dart

NETWORK STANDARDI (TEK YERDEN) 7.1 ApiClient
ApiClient şunları tek yerde yönetir:

baseUrl

ortak header

timeout

error handling

logging

7.2 ApiResult

Service dönüşleri standart:

Success(data)

Failure(error)

7.3 ApiException

Hatalar normalize edilir:

network / timeout

401/403 auth

404

500

parse error

ViewModel içinde statusCode == ... kontrolü YASAK.

LOGLAMA STANDARTI (ZORUNLU)
Uygulama genelinde Debugging ve monitoring için detaylı loglama zorunludur:

Tüm API istekleri (Request) ve cevapları (Response) core/utils/logger.dart üzerinden loglanmalıdır.
Hata durumlarında StackTrace ve detaylı hata mesajı basılmalıdır.
"Print" kullanımı kesinlikle YASAK. Sadece Logger sınıfı kullanılabilir.
Loglar kategorize edilmelidir: INFO, ERROR, WARNING, DEBUG, REQUEST, RESPONSE.
TEKRAR KULLANIM KURALI (WIDGET)
Bir widget 2+ ekranda kullanılacaksa:

AI önce sorar

Onay alınırsa, ortak alana taşınır

Ortak alan (istisna):

core/ui_components/

Onaysız taşıma / ortak widget havuzu YASAK.

DOSYALAMA ve İSİMLENDİRME
Dosya isimleri: snake_case.dart

Sınıf isimleri: PascalCase

Örnek:

home_view.dart

home_view_model.dart

job_service.dart

job_detail_response.dart

TASARIM REFERANSI
Uygulama tasarım dili:

dryfix.com.tr web tasarımını baz alır

Renk / tipografi / spacing:

AppTheme ve SizeTokens üzerinden yönetilir

Keyfi UI/UX kararı YASAK.

AI İÇİN SON TALİMAT (EN ÖNEMLİ)
AI:

Bu dokümana %100 uyar

Statik veri kullanmaz

Kafasına göre alan/feature üretmez

Widget’ları sadece ilgili ekran klasörüne koyar

Emin olmadığı her noktada SORAR

Endpoint string yazmaz, sadece ApiConstants kullanır

API response’u eksiksiz modeller

## ÇOKLU BASE URL VE SEÇİM EKRANI
Uygulama iki farklı çalışma ortamı (Environment) destekler:
1.  **Anaokulu** (Mevcut yapı)
2.  **Oyun Grubu** (Yeni eklenecek yapı)

**KURALLAR:**
- Uygulama açılışta kullanıcıya hangi bölüme gitmek istediğini soran "Netflix profil seçimi" tarzı premium bir ekran sunmalıdır.
- Seçilen base URL, uygulama genelinde dinamik olarak set edilmelidir.
- `ApiConstants` içindeki `baseUrl` statik olmaktan çıkarılmalı, çalışma anında seçilen değere göre güncellenmelidir.
- Seçim ekranı `views/environment_selection/` klasörü altında olmalı, projenin yüksek görsel standartlarına (`AppTheme`, `SizeTokens`) uymalıdır.
- Mimaride karışıklık olmaması için tüm servisler seçili base URL üzerinden istek atmalıdır.