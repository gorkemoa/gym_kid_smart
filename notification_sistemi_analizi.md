# GymKidSmart — Bildirim Sistemi Detaylı Analizi

> **Son Güncelleme:** Local notification sistemi kaldırılmıştır. Yalnızca FCM push notification ve QRKids API bildirimleri kullanılmaktadır.

## İçindekiler

1. [Genel Mimari](#1-genel-mimari)
2. [Kullanılan Paketler](#2-kullanılan-paketler)
3. [Platform Konfigürasyonu](#3-platform-konfigürasyonu)
4. [Uygulama Başlarken Ne Olur? (LandingScreen)](#4-uygulama-başlarken-ne-olur-landingscreen)
5. [FCM Token Yönetimi](#5-fcm-token-yönetimi)
6. [HomeScreen — FCM Dinleyicileri](#6-homescreen--fcm-dinleyicileri)
7. [Background / Terminated Bildirimleri](#7-background--terminated-bildirimleri)
8. [Bildirime Tıklama ve Yönlendirme (Deep-Link)](#8-bildirime-tıklama-ve-yönlendirme-deep-link)
9. [QRKids Tarafı — API Bildirimleri](#9-qrkids-tarafı--api-bildirimleri)
10. [QrNotificationsProvider](#10-qrnotificationsprovider)
11. [QrNotifications Ekranı](#11-qrnotifications-ekranı)
12. [API Uç Noktaları](#12-api-uç-noktaları)
13. [Veri Modeli](#13-veri-modeli)
14. [Firebase Topic Aboneliği](#14-firebase-topic-aboneliği)
15. [Akış Şeması (Tüm Senaryolar)](#15-akış-şeması-tüm-senaryolar)
16. [Eksiklikler ve Geliştirme Önerileri](#16-eksiklikler-ve-geliştirme-önerileri)

---

## 1. Genel Mimari

Uygulama **iki katmanlı** bir bildirim sistemi kullanır:

| Katman | Teknoloji | Amaç |
|--------|-----------|-------|
| **Push Notification** | Firebase Cloud Messaging (FCM) | Sunucu → Cihaz arası anlık bildirim (sistem seviyesi) |
| **API Bildirimleri** | REST API (QRKids) | Uygulama içinde listelenen, okundu/okunmadı takipli bildirimler |

> Uygulama açıkken (foreground) FCM mesajları ekranda görünmez — sistemin kendisi bildirim göstermez, `flutter_local_notifications` kaldırılmıştır. Arka plan ve tamamen kapalı senaryolarda sistem bildirimi FCM tarafından otomatik gösterilir.

İki farklı giriş türü vardır:
- **SmartKids** hesabıyla giriş → `ApiService.updateFCMToken` çağrılır.
- **QRKids** hesabıyla giriş → `QRApiService.updateFCMToken` çağrılır.

---

## 2. Kullanılan Paketler

```yaml
# pubspec.yaml
firebase_core:      # Firebase başlatma
firebase_messaging: # FCM push notification
# flutter_local_notifications  ← KALDIRILDI
```

---

## 3. Platform Konfigürasyonu

### Android — `AndroidManifest.xml`

```xml
<!-- İzinler -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>  <!-- Android 13+ zorunlu -->

<!-- FCM varsayılan bildirim rengi -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@android:color/black"/>

<!-- Bildirime tıklanınca uygulama açılır -->
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK"/>
    <category android:name="android.intent.category.DEFAULT"/>
</intent-filter>

<!-- Varsayılan notification channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="gymkid"/>
```

**`launchMode="singleTop"`** ayarı önemlidir: Uygulama zaten açıkken bildirime tıklanırsa yeni bir Activity oluşturulmaz, mevcut Activity'de `onNewIntent` tetiklenir.

### iOS — `AppDelegate.swift`

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

`flutter_local_notifications` kaldırıldığı için `setPluginRegistrantCallback` ve `UNUserNotificationCenter.delegate` ayarları temizlenmiştir.

---

## 4. Uygulama Başlarken Ne Olur? (LandingScreen)

**Dosya:** `lib/screen/landing_screen/landing_screen.dart`

```
Uygulama açılır → LandingScreen.initApp() → initFirebaseMessage()
```

### `initFirebaseMessage()` Adım Adım

```dart
Future<void> initFirebaseMessage() async {
  var messaging = FirebaseMessaging.instance;

  // 1. iOS'ta APNS token alınır (FCM token için önkoşul)
  if (Platform.isIOS) {
    apnsToken = await messaging.getAPNSToken();
    await Future.delayed(const Duration(seconds: 3)); // APNS hazır olana kadar bekle
  }

  // 2. APNS token varsa FCM token alınır
  if (apnsToken != null) {
    fcmToken = await messaging.getToken();
  }

  // 3. Zaten giriş yapılmışsa FCM token sunucuya iletilir
  if (context.read<AuthProvider>().isAuth) {
    await ApiService.updateFCMToken(
        schoolID: ..., userKey: ..., token: fcmToken ?? '');
  }

  // 4. Bildirim izni talep edilir
  await messaging.requestPermission();
}
```

**Ardından:**
```dart
void initApp() async {
  await initFirebaseMessage();
  // Arka plan mesaj handler'ı kaydedilir
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Auth durumuna göre yönlendirme yapılır
}
```

---

## 5. FCM Token Yönetimi

### Global Token Değişkenleri

```dart
// landing_screen.dart (global)
String? fcmToken;    // FCM token
String? apnsToken;   // iOS APNS token (FCM için önkoşul)
```

### iOS'ta Özel Durum

iOS'ta FCM token alabilmek için önce APNS token gerekmektedir:

```
iOS cihaz → Apple Push Notification Service (APNS) → apnsToken
apnsToken != null → Firebase → fcmToken
```

Android'de bu adım atlanır; doğrudan `getToken()` çağrılabilir.

### Token Güncelleme — SmartKids API

```dart
// ApiService.updateFCMToken
POST /admin/addToken
{
  "school_id": <schoolID>,
  "user_key": "<userKey>",
  "token": "<fcmToken>"
}
```

### Token Güncelleme — QRKids API

```dart
// QRApiService.updateFCMToken
POST /qr/UpdateFCMToken
{
  "user_key": "<userKey>",
  "fcm_token": "<fcmToken>"
}
```

### Login Anında Token Güncellemesi

Her başarılı giriş sonrasında token sunucuya gönderilir:

```dart
// LoginScreen — SmartKids girişi
var messaging = FirebaseMessaging.instance;
String? token;
if (apnsToken != null) {          // iOS kontrolü
  token = await messaging.getToken();
}
await ApiService.updateFCMToken(..., token: token ?? '');

// LoginScreen — QRKids girişi
await QRApiService.updateFCMToken(user_key: ..., fcm_token: token ?? '');
```

---

## 6. HomeScreen — FCM Dinleyicileri

**Dosya:** `lib/screen/home_screen/home_screen.dart`

`initState()` çağrıldığında:

```dart
@override
void initState() {
  translating();
  initNotification();   // FCM listener'larını kur
  checkUpdate();
  super.initState();
}
```

### `initNotification()` — FCM Dinleyicileri

```dart
Future<void> initNotification() async {
  // 1. Firebase topic'e abone ol (sunucu tüm kullanıcılara bildirim gönderir)
  await FirebaseMessaging.instance
      .subscribeToTopic('php_notification_gymkid');

  // 2. BACKGROUND'dan FOREGROUND'a geçişte (kullanıcı bildirimi tıkladı)
  FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

  // 3. TERMINATED (uygulama kapalıyken) bildirimi ile açıldı mı?
  await FirebaseMessaging.instance.getInitialMessage().then((initMessage) {
    if (initMessage != null) {
      GoRouter.of(context).push(initMessage.data['page']);
    }
  });
}
```

> `FirebaseMessaging.onMessage` (foreground) listener artık dinlenmiyor — local notification kaldırıldığı için uygulama açıkken gelen FCM mesajları ekranda görünmez. Sunucu sadece background/terminated senaryolarını hedeflemeli.

---

## 7. Background / Terminated Bildirimleri

### Background Handler

```dart
// landing_screen.dart — @pragma('vm:entry-point') zorunlu!
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ayrı bir Dart isolate'te çalışır, Flutter context YOK
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
```

Arka planda sistem bildirimi FCM tarafından otomatik gösterilir (notification payload varsa).

### 3 Senaryo Özeti

| Durum | Sonuç |
|-------|-------|
| Foreground | FCM mesajı sessizce yoksayılır (bildirim gösterilmez) |
| Background | Sistem otomatik bildirim gösterir → tıklanırsa `onMessageOpenedApp` → deep-link |
| Terminated | Sistem otomatik bildirim gösterir → tıklanırsa `getInitialMessage` → deep-link |

---

## 8. Bildirime Tıklama ve Yönlendirme (Deep-Link)

### Senaryo A: Background Bildirimine Tıklama

```dart
Future<void> onMessageOpenedApp(RemoteMessage message) async {
  LogService.logLn('onMessageOpenedApp: data: ${message.data}');
  if (message.data['page'] != null) {
    GoRouter.of(context).push(message.data['page']);
  }
}
```

### Senaryo B: Terminated Bildirimine Tıklama

```dart
await FirebaseMessaging.instance.getInitialMessage().then((initMessage) {
  if (initMessage != null) {
    GoRouter.of(context).push(initMessage.data['page']);
  }
});
```

FCM mesajında `data.page` alanı (`"/announcements"` gibi) go_router path'i olarak kullanılır.

---

## 9. QRKids Tarafı — API Bildirimleri

QRKids modülü **iki tür bildirim** kullanır:

1. **FCM Push Notification**: Aynı FCM altyapısı, `QRApiService.updateFCMToken` ile token kaydı.
2. **REST API Bildirimleri**: Sunucuda saklanan, listelenen, okundu işaretlenebilen bildirimler.

---

## 10. QrNotificationsProvider

**Dosya:** `lib/core/service/provider/qr_provider/qr_notifications.dart`

```dart
class QrNotificationsProvider extends ChangeNotifier {
  QRNotificationResponse? _response;

  List<QRNotificationModel> get notifications => _response?.data ?? [];
  int get unreadCount => notifications.where((e) => e.isRead == 0).length;

  // Bildirimleri sunucudan çek
  Future<List<QRNotificationModel>> fetchNotifications() async {
    final res = await QRApiService.getNotifications(
        user_key: qrAuthProvider.user!.data!.userKey);
    if (res != null) _response = res;
    return notifications;
  }

  // Bildirimi okundu işaretle
  Future<bool> markAsRead({required int notificationId}) async {
    final result = await QRApiService.markNotificationRead(
      user_key: qrAuthProvider.user!.data!.userKey,
      notification_id: notificationId.toString(),
    );
    if (result != null) {
      fetchNotifications();
      return true;
    }
    return false;
  }

  void clear() {
    _response = null;
    notifyListeners();
  }
}
```

---

## 11. QrNotifications Ekranı

**Dosya:** `lib/screen/qr_screens/qr_notifications.dart`

```dart
AppFutureBuilder(
  future: qrNotificationsProvider.fetchNotifications(),
  builder: (context, data) {
    return Column(
      children: List.generate(
        data.length,
        (index) => notificationContainers(
            data[index].title, data[index].message),
      ),
    );
  }
)
```

Her bildirim: bildirim ikonu (SVG) + başlık + mesaj olarak gösterilir.

---

## 12. API Uç Noktaları

### SmartKids API

| Uç Nokta | Metod | Amaç | Parametreler |
|----------|-------|------|-------------|
| `admin/addToken` | POST | FCM token kaydet/güncelle | `school_id`, `user_key`, `token` |

### QRKids API

| Uç Nokta | Metod | Amaç | Parametreler |
|----------|-------|------|-------------|
| `qr/UpdateFCMToken` | POST | FCM token kaydet/güncelle | `user_key`, `fcm_token` |
| `qr/GetNotifications` | POST | Bildirimleri listele | `user_key` |
| `qr/MarkNotificationRead` | POST | Bildirimi okundu işaretle | `user_key`, `notification_id` |

---

## 13. Veri Modeli

**Dosya:** `lib/core/model/qr_models/notifications/qr_notifications.dart`

```dart
class QRNotificationModel {
  final int id;           // Bildirim ID
  final int userId;       // Kullanıcı ID
  final String title;     // Bildirim başlığı
  final String message;   // Bildirim içeriği
  final String type;      // Bildirim türü (ör: "lesson", "payment")
  final Map<String, dynamic> extraData;  // Ek JSON verisi
  final bool isRead;      // Okundu mu?
  final String createdAt; // Oluşturulma tarihi
}
```

---

## 14. Firebase Topic Aboneliği

```dart
await FirebaseMessaging.instance
    .subscribeToTopic('php_notification_gymkid');
```

Sunucu bireysel FCM token'ı bilmeden tüm abone cihazlara toplu bildirim gönderebilir. Topic adı `php_notification_gymkid` → sunucu tarafı PHP ile yazılmış.

**Not:** Abonelik `HomeScreen.initNotification()` içinde yapılır. Kullanıcı giriş yapıp ana sayfaya ulaşana kadar topic aboneliği gerçekleşmez.

---

## 15. Akış Şeması (Tüm Senaryolar)

### A. Uygulama İlk Kez Açılıyor

```
main() → Firebase.initializeApp()
       → LandingScreen
         → initFirebaseMessage()
           → iOS: getAPNSToken() [3sn bekle]
           → getToken() → fcmToken
           → isAuth? → ApiService.updateFCMToken()
           → requestPermission()
         → onBackgroundMessage(handler)
         → yönlendirme (/ veya /qrMain veya /redirect)
```

### B. Kullanıcı Giriş Yapıyor

```
LoginScreen → form validate
            → AuthProvider.login() veya QrAuthProvider.login()
            → getAPNSToken() / getToken()
            → ApiService.updateFCMToken() veya QRApiService.updateFCMToken()
            → context.go('/')
```

### C. FCM Mesajı Geldi (Uygulama Açık — Foreground)

```
FCM Server → Firebase SDK → FirebaseMessaging.onMessage
           → Dinleyici YOK → Bildirim gösterilmez
```

### D. FCM Mesajı Geldi (Uygulama Arka Planda — Background)

```
FCM Server → Firebase SDK
           → Sistem otomatik bildirim gösterir
           → _firebaseMessagingBackgroundHandler() → Firebase init
           → Kullanıcı bildirime tıkladı
           → FirebaseMessaging.onMessageOpenedApp
           → onMessageOpenedApp()
           → GoRouter.push(message.data['page'])
```

### E. FCM Mesajı Geldi (Uygulama Kapalı — Terminated)

```
FCM Server → Firebase SDK
           → Sistem bildirim gösterir
           → Kullanıcı tıkladı → Uygulama açıldı
           → HomeScreen.initNotification()
           → getInitialMessage()
           → GoRouter.push(initMessage.data['page'])
```

### F. QRKids API Bildirimleri

```
QrNotifications Ekranı açıldı
  → qrNotificationsProvider.fetchNotifications()
  → QRApiService.getNotifications(user_key)
  → POST /qr/GetNotifications
  → QRNotificationResponse.fromJson()
  → UI'da listele
```

---

## 16. Eksiklikler ve Geliştirme Önerileri

### 🟡 Orta Öncelikli Sorunlar

1. **`onBackgroundMessage` Sırasıyla Kaydediliyor**
   - `FirebaseMessaging.onBackgroundMessage()` teknik olarak `main()` içinde çağrılmalıdır.
   - Mevcut hâlde `LandingScreen.initApp()` içinde çağrılıyor; bu bazen background mesajların kaçırılmasına neden olabilir.
   - **Çözüm:** `main()` fonksiyonuna taşıyın:
     ```dart
     void main() async {
       WidgetsFlutterBinding.ensureInitialized();
       await Firebase.initializeApp(...);
       FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
       ...
     }
     ```

2. **`QrNotifications` Ekranında `markAsRead` Tetiklenmiyor**
   - `isRead` ve `markAsRead` API'si hazır, ancak kullanıcı bildirime dokunduğunda çağrılmıyor.
   - **Çözüm:** `notificationContainers` widget'ına `onTap` ekleyin.

3. **`unreadCount` Getter'ı Kullanılmıyor**
   - `QrNotificationsProvider.unreadCount` hesaplanıyor ama UI'da rozet (badge) olarak gösterilmiyor.

4. **iOS'ta FCM Token Sadece APNS Varsa Alınıyor**
   - iOS Simulator'da APNS çalışmadığı için `fcmToken` `null` kalır.

### 🟢 Geliştirme Önerileri

5. **Token Yenileme (Token Refresh)**
   - `FirebaseMessaging.instance.onTokenRefresh` dinlenmiyor.
   - Token değiştiğinde sunucudaki token güncellenmez.
   - **Çözüm:**
     ```dart
     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
       ApiService.updateFCMToken(..., token: newToken);
     });
     ```

6. **Topic Aboneliği Geç Yapılıyor**
   - Kullanıcı ana sayfaya geçmeden gelen topic mesajları alınamaz.
   - **Çözüm:** `LandingScreen.initFirebaseMessage()`'a taşıyın.

7. **Notification Channel Tekliği**
   - AndroidManifest'te `gymkid` channel tanımlı — artık tek kanal bu.
   - `smartkids` channel tamamen kaldırıldı.

---

## Özet

```
GymKidSmart Bildirim Sistemi
├── FCM (Firebase Cloud Messaging)
│   ├── Token Yönetimi
│   │   ├── Android: getToken()
│   │   └── iOS: getAPNSToken() → getToken()
│   ├── Dinleyiciler (HomeScreen)
│   │   ├── onMessageOpenedApp → background tıklama → deep-link
│   │   └── getInitialMessage → terminated tıklama → deep-link
│   ├── Background Handler (LandingScreen)
│   │   └── _firebaseMessagingBackgroundHandler → Firebase init
│   └── Topic: php_notification_gymkid
│
└── QRKids API Bildirimleri
    ├── GetNotifications → QRNotificationResponse
    ├── MarkNotificationRead
    └── QrNotificationsProvider (ChangeNotifier)

[KALDIRILDI] flutter_local_notifications
[KALDIRILDI] NotificationService
[KALDIRILDI] foregroundMessageListener
[KALDIRILDI] onNotificationClick
```


## İçindekiler

1. [Genel Mimari](#1-genel-mimari)
2. [Kullanılan Paketler](#2-kullanılan-paketler)
3. [Platform Konfigürasyonu](#3-platform-konfigürasyonu)
4. [Uygulama Başlarken Ne Olur? (LandingScreen)](#4-uygulama-başlarken-ne-olur-landingscreen)
5. [FCM Token Yönetimi](#5-fcm-token-yönetimi)
6. [NotificationService (Local Notification Katmanı)](#6-notificationservice-local-notification-katmanı)
7. [HomeScreen — FCM Dinleyicileri](#7-homescreen--fcm-dinleyicileri)
8. [In-App Bildirim (Foreground)](#8-in-app-bildirim-foreground)
9. [Background / Terminated Bildirimleri](#9-background--terminated-bildirimleri)
10. [Bildirime Tıklama ve Yönlendirme (Deep-Link)](#10-bildirime-tıklama-ve-yönlendirme-deep-link)
11. [QRKids Tarafı — API Bildirimleri](#11-qrkids-tarafı--api-bildirimleri)
12. [QrNotificationsProvider](#12-qrnotificationsprovider)
13. [QrNotifications Ekranı](#13-qrnotifications-ekranı)
14. [API Uç Noktaları](#14-api-uç-noktaları)
15. [Veri Modeli](#15-veri-modeli)
16. [Firebase Topic Aboneliği](#16-firebase-topic-aboneliği)
17. [Akış Şeması (Tüm Senaryolar)](#17-akış-şeması-tüm-senaryolar)
18. [Eksiklikler ve Geliştirme Önerileri](#18-eksiklikler-ve-geliştirme-önerileri)

---

## 1. Genel Mimari

Uygulama **iki katmanlı** bir bildirim sistemi kullanır:

| Katman | Teknoloji | Amaç |
|--------|-----------|-------|
| **Push Notification** | Firebase Cloud Messaging (FCM) | Sunucu → Cihaz arası anlık bildirim |
| **Local Notification** | flutter_local_notifications | Uygulama ön plandayken FCM mesajını kullanıcıya görüntüleme |
| **API Bildirimleri** | REST API (QRKids) | Uygulama içinde listelenen, okundu/okunmadı takipli bildirimler |

İki farklı giriş türü vardır:
- **SmartKids** hesabıyla giriş → `ApiService.updateFCMToken` çağrılır.
- **QRKids** hesabıyla giriş → `QRApiService.updateFCMToken` çağrılır.

---

## 2. Kullanılan Paketler

```yaml
# pubspec.yaml
firebase_core: (Firebase başlatma)
firebase_messaging: (FCM push notification)
flutter_local_notifications: ^19.3.1  (yerel bildirim gösterimi)
```

---

## 3. Platform Konfigürasyonu

### Android — `AndroidManifest.xml`

```xml
<!-- İzinler -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>  <!-- Android 13+ zorunlu -->

<!-- FCM varsayılan bildirim rengi -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@android:color/black"/>

<!-- Bildirime tıklanınca uygulama açılır -->
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK"/>
    <category android:name="android.intent.category.DEFAULT"/>
</intent-filter>

<!-- Varsayılan notification channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="gymkid"/>
```

**`launchMode="singleTop"`** ayarı önemlidir: Uygulama zaten açıkken bildirime tıklanırsa yeni bir Activity oluşturulmaz, mevcut Activity'de `onNewIntent` tetiklenir.

### iOS — `AppDelegate.swift`

```swift
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(...) -> Bool {
    // flutter_local_notifications için plugin kaydı (arka plan bildirimleri)
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    // iOS 10+ için UNUserNotificationCenter delegate ayarı
    if #available(iOS 10.0, *) {
       UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

Bu iki satır iOS'ta önemlidir:
- `setPluginRegistrantCallback` → flutter_local_notifications'ın arka plan isolate'inde çalışabilmesi için gerekli.
- `UNUserNotificationCenter.current().delegate = self` → Uygulama ön plandayken sistem bildiriminin gösterilebilmesi için.

---

## 4. Uygulama Başlarken Ne Olur? (LandingScreen)

**Dosya:** `lib/screen/landing_screen/landing_screen.dart`

```
Uygulama açılır → LandingScreen.initApp() → initFirebaseMessage()
```

### `initFirebaseMessage()` Adım Adım

```dart
Future<void> initFirebaseMessage() async {
  var messaging = FirebaseMessaging.instance;

  // 1. iOS'ta APNS token alınır (FCM token için önkoşul)
  if (Platform.isIOS) {
    apnsToken = await messaging.getAPNSToken();
    await Future.delayed(const Duration(seconds: 3)); // APNS hazır olana kadar bekle
  }

  // 2. APNS token varsa FCM token alınır
  if (apnsToken != null) {
    fcmToken = await messaging.getToken();
  }

  // 3. Zaten giriş yapılmışsa FCM token sunucuya iletilir
  if (context.read<AuthProvider>().isAuth) {
    await ApiService.updateFCMToken(
        schoolID: ..., userKey: ..., token: fcmToken ?? '');
  }

  // 4. Bildirim izni talep edilir
  await messaging.requestPermission();
}
```

**Ardından:**
```dart
void initApp() async {
  await initFirebaseMessage();
  // Arka plan mesaj handler'ı kaydedilir
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Auth durumuna göre yönlendirme yapılır
}
```

> **Önemli:** `onBackgroundMessage` handler'ı `initApp()`'te kayıt edilir ama `initFirebaseMessage()` **sonrası** yapılır. Teknik olarak bu handler top-level olmalı; burada `@pragma('vm:entry-point')` ile işaretlenmiş.

---

## 5. FCM Token Yönetimi

### Global Token Değişkenleri

```dart
// landing_screen.dart (global)
String? fcmToken;    // FCM token
String? apnsToken;   // iOS APNS token (FCM için önkoşul)
```

### iOS'ta Özel Durum

iOS'ta FCM token alabilmek için önce APNS token gerekmektedir:

```
iOS cihaz → Apple Push Notification Service (APNS) → apnsToken
apnsToken != null → Firebase → fcmToken
```

Android'de bu adım atlanır; doğrudan `getToken()` çağrılabilir.

### Token Güncelleme — SmartKids API

```dart
// ApiService.updateFCMToken
POST /admin/addToken
{
  "school_id": <schoolID>,
  "user_key": "<userKey>",
  "token": "<fcmToken>"
}
```

### Token Güncelleme — QRKids API

```dart
// QRApiService.updateFCMToken
POST /qr/UpdateFCMToken
{
  "user_key": "<userKey>",
  "fcm_token": "<fcmToken>"
}
```

### Login Anında Token Güncellemesi

Her başarılı giriş sonrasında token sunucuya gönderilir:

```dart
// LoginScreen — SmartKids girişi
var messaging = FirebaseMessaging.instance;
String? token;
if (apnsToken != null) {          // iOS kontrolü
  token = await messaging.getToken();
}
await ApiService.updateFCMToken(..., token: token ?? '');

// LoginScreen — QRKids girişi
await QRApiService.updateFCMToken(user_key: ..., fcm_token: token ?? '');
```

---

## 6. NotificationService (Local Notification Katmanı)

**Dosya:** `lib/core/service/notification.dart`

Bu servis `flutter_local_notifications` paketinin sarmalayıcısıdır. FCM mesajı geldiğinde sistem bildiriminin görünmesini sağlar.

### Başlatma — `initNotification()`

```dart
Future<void> initNotification() async {
  // Android: @mipmap/ic_launcher ikonunu kullan
  AndroidInitializationSettings android =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS: Alert, badge ve ses izni iste
  var ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var settings = InitializationSettings(android: android, iOS: ios);

  // Android 13+ için bildirim izni runtime'da iste
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // Plugin'i başlat, callback'leri ayarla
  await plugin.initialize(
    settings,
    onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );
}
```

### Bildirim Detayları — Kanal Konfigürasyonu

```dart
NotificationDetails notificationDetail() {
  return const NotificationDetails(
    android: AndroidNotificationDetails(
      'smartkids',       // channel id
      'smartkids',       // channel name
      importance: Importance.max,   // En yüksek öncelik → heads-up notification
    ),
    iOS: DarwinNotificationDetails(),
  );
}
```

> **Not:** AndroidManifest'te varsayılan kanal `gymkid` olarak tanımlanmış, ancak `flutter_local_notifications` ile bildirimlerde `smartkids` channel'ı kullanılıyor. Bu iki farklı channel'dır; FCM tarafından gelen passthrough (data-only) bildirimler `smartkids` channel'ına, FCM notification payload'ları ise `gymkid` channel'ına düşer.

### Bildirim Gösterme

```dart
Future<void> showNotification({
  int id = 0,
  String? title,
  String? body,
  String? payload,
}) async {
  return plugin.show(id, title, body, notificationDetail(), payload: payload);
}
```

`payload` parametresi JSON formatında `page` anahtarı içerir ve tıklandığında yönlendirme için kullanılır.

---

## 7. HomeScreen — FCM Dinleyicileri

**Dosya:** `lib/screen/home_screen/home_screen.dart`

`initState()` çağrıldığında iki işlem başlatılır:

```dart
@override
void initState() {
  translating();
  initNotification();   // FCM listener'ları kur
  onNotificationClick(); // Uygulama bildirimle açıldıysa kontrol et
  checkUpdate();
  super.initState();
}
```

### `initNotification()` — Tüm FCM Dinleyicileri

```dart
Future<void> initNotification() async {
  // 1. NotificationService'i başlat (local notification plugin)
  notificationService = NotificationService(context);
  await notificationService.initNotification();

  // 2. Firebase topic'e abone ol (sunucu tüm kullanıcılara bildirim gönderir)
  await FirebaseMessaging.instance
      .subscribeToTopic('php_notification_gymkid');

  // 3. FOREGROUND mesaj dinleyicisi
  FirebaseMessaging.onMessage.listen(foregroundMessageListener);

  // 4. BACKGROUND'dan FOREGROUND'a geçişte (kullanıcı bildirimi tıkladı)
  FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

  // 5. TERMINATED (uygulama kapalıyken) bildirimi ile açıldı mı?
  await FirebaseMessaging.instance.getInitialMessage().then((initMessage) {
    if (initMessage != null) {
      GoRouter.of(context).push(initMessage.data['page']);
    }
  });
}
```

---

## 8. In-App Bildirim (Foreground)

Uygulama açıkken FCM mesajı geldiğinde sistem bildirimi **otomatik gösterilmez**. Bu yüzden `foregroundMessageListener` devreye girer:

```dart
Future<void> foregroundMessageListener(RemoteMessage message) async {
  if (message.data.isNotEmpty) {
    // Data payload varsa → payload ile birlikte göster (deep-link için)
    notificationService.showNotification(
      id: 0,
      body: message.notification?.body,
      title: message.notification?.title,
      payload: jsonEncode(message.data),   // {"page": "/announcements"} gibi
    );
  } else {
    // Sadece notification payload → payload olmadan göster
    notificationService.showNotification(
      id: 0,
      body: message.notification?.body,
      title: message.notification?.title,
    );
  }
}
```

**Akış:**
```
FCM sunucu mesajı → FirebaseMessaging.onMessage → foregroundMessageListener
  → flutter_local_notifications.show() → Sistem bildirim alanında görünür
```

---

## 9. Background / Terminated Bildirimleri

### Background Handler

```dart
// landing_screen.dart — @pragma('vm:entry-point') zorunlu!
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ayrı bir Dart isolate'te çalışır, Flutter context YOK
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // NOT: Burada UI işlemleri YAPILAMAZ
}
```

Bu handler yalnızca Firebase'i yeniden başlatır. Arka planda sistem bildirimi FCM tarafından otomatik gösterilir (notification payload varsa).

### Uygulama Tamamen Kapalıyken (Terminated)

```dart
await FirebaseMessaging.instance.getInitialMessage().then((initMessage) {
  if (initMessage != null) {
    // Uygulama bu bildirimle açıldı
    GoRouter.of(context).push(initMessage.data['page']);
  }
});
```

3 senaryo özeti:

| Durum | FCM Notification Payload | FCM Data Payload | Sonuç |
|-------|--------------------------|------------------|-------|
| Foreground | Gösterilmez (Flutter yakalar) | Gösterilmez | `onMessage` → local notification göster |
| Background | Sistem gösterir | İşlenmez | `onMessageOpenedApp` → deep-link |
| Terminated | Sistem gösterir | İşlenmez | `getInitialMessage` → deep-link |

---

## 10. Bildirime Tıklama ve Yönlendirme (Deep-Link)

### Senaryo A: Uygulama Açıkken Local Notification'a Tıklama

```dart
// NotificationService.onDidReceiveNotificationResponse
static void onDidReceiveNotificationResponse(NotificationResponse details) {
  navigatePage(details.payload);
}

// NotificationService.navigatePage
static void navigatePage(String? payload) async {
  if (payload != null && payload.isNotEmpty) {
    Map json = jsonDecode(payload);
    if (json.containsKey('page')) {
      var list = (json['page'] as String).split('/');
      list.remove('');
      if (list.first == 'kategori') { /* navigate */ }
      else if (list.first == 'sayfa') { /* navigate */ }
      else if (list.first == 'dergi') { /* navigate */ }
    }
  }
}
```

> **Dikkat:** `navigatePage` içindeki navigation kodları **yorum satırına alınmış**. Yani şu an tıklama yönlendirmesi çalışmaz durumda.

### Senaryo B: Background Bildirimine Tıklama

```dart
Future<void> onMessageOpenedApp(RemoteMessage message) async {
  if (message.data['page'] != null) {
    GoRouter.of(context).push(message.data['page']);
  }
}
```

### Senaryo C: Terminated Bildirimine Tıklama

```dart
await FirebaseMessaging.instance.getInitialMessage().then((initMessage) {
  if (initMessage != null) {
    GoRouter.of(context).push(initMessage.data['page']);
  }
});
```

### Senaryo D: Local Notification Arka Planda Tıklandı

```dart
@pragma('vm:entry-point')
static void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse details) {
  navigatePage(details.payload);  // Aynı navigatePage → yorum satırı problemi
}
```

### Senaryo E: Uygulama Bildirimle Tamamen Açıldı (onNotificationClick)

```dart
Future<void> onNotificationClick() async {
  await notificationService.plugin.getNotificationAppLaunchDetails().then(
    (appLaunchDetail) {
      if (appLaunchDetail != null && appLaunchDetail.didNotificationLaunchApp) {
        if (appLaunchDetail.notificationResponse?.payload != null) {
          var json = jsonDecode(appLaunchDetail.notificationResponse!.payload!);
          if (json is Map) {
            var page = json['page'];
            if (page != null) {
              context.push(page);  // go_router ile yönlendirme
            }
          }
        }
      }
    },
  );
}
```

---

## 11. QRKids Tarafı — API Bildirimleri

QRKids modülü **iki tür bildirim** kullanır:

1. **FCM Push Notification**: Aynı FCM altyapısı, `QRApiService.updateFCMToken` ile token kaydı.
2. **REST API Bildirimleri**: Sunucuda saklanan, listelenen, okundu işaretlenebilen bildirimler.

---

## 12. QrNotificationsProvider

**Dosya:** `lib/core/service/provider/qr_provider/qr_notifications.dart`

```dart
class QrNotificationsProvider extends ChangeNotifier {
  QRNotificationResponse? _response;

  List<QRNotificationModel> get notifications => _response?.data ?? [];
  int get unreadCount => notifications.where((e) => e.isRead == 0).length;

  // Bildirimleri sunucudan çek
  Future<List<QRNotificationModel>> fetchNotifications() async {
    final res = await QRApiService.getNotifications(
        user_key: qrAuthProvider.user!.data!.userKey);
    if (res != null) _response = res;
    return notifications;
  }

  // Bildirimi okundu işaretle
  Future<bool> markAsRead({required int notificationId}) async {
    final result = await QRApiService.markNotificationRead(
      user_key: qrAuthProvider.user!.data!.userKey,
      notification_id: notificationId.toString(),
    );
    if (result != null) {
      fetchNotifications(); // Listeyi yenile
      return true;
    }
    return false;
  }

  void clear() {
    _response = null;
    notifyListeners();
  }
}
```

Provider `main.dart`'ta global olarak tanımlanır ve `MultiProvider`'a eklenir:

```dart
// main.dart
late QrNotificationsProvider qrNotificationsProvider;

// firstInit()
qrNotificationsProvider = QrNotificationsProvider();

// GymKidApp build
ChangeNotifierProvider.value(value: qrNotificationsProvider),
```

---

## 13. QrNotifications Ekranı

**Dosya:** `lib/screen/qr_screens/qr_notifications.dart`

```dart
AppFutureBuilder(
  future: qrNotificationsProvider.fetchNotifications(),
  builder: (context, data) {
    return Column(
      children: List.generate(
        data.length,
        (index) => notificationContainers(
            data[index].title, data[index].message),
      ),
    );
  }
)
```

Her bildirim şu şekilde gösterilir:
- Bildirim ikonu (SVG)
- Başlık (`title`)
- Mesaj (`message`)

> **Not:** `isRead` durumu arayüzde görsel olarak ayrıştırılmıyor (okunmuş/okunmamış renk farkı yok). `markAsRead` çağrısı UI'dan tetiklenmiyor.

---

## 14. API Uç Noktaları

### SmartKids API

| Uç Nokta | Metod | Amaç | Parametreler |
|----------|-------|------|-------------|
| `admin/addToken` | POST | FCM token kaydet/güncelle | `school_id`, `user_key`, `token` |

### QRKids API

| Uç Nokta | Metod | Amaç | Parametreler |
|----------|-------|------|-------------|
| `qr/UpdateFCMToken` | POST | FCM token kaydet/güncelle | `user_key`, `fcm_token` |
| `qr/GetNotifications` | POST | Bildirimleri listele | `user_key` |
| `qr/MarkNotificationRead` | POST | Bildirimi okundu işaretle | `user_key`, `notification_id` |

---

## 15. Veri Modeli

**Dosya:** `lib/core/model/qr_models/notifications/qr_notifications.dart`

```dart
class QRNotificationModel {
  final int id;           // Bildirim ID
  final int userId;       // Kullanıcı ID
  final String title;     // Bildirim başlığı
  final String message;   // Bildirim içeriği
  final String type;      // Bildirim türü (ör: "lesson", "payment")
  final Map<String, dynamic> extraData;  // Ek JSON verisi
  final bool isRead;      // Okundu mu?
  final String createdAt; // Oluşturulma tarihi
}

class QRNotificationResponse {
  final bool success;
  final List<QRNotificationModel> data;
}
```

`extraData` alanı JSON string veya Map olarak gelebilir; model her iki formatı da işler.

---

## 16. Firebase Topic Aboneliği

```dart
await FirebaseMessaging.instance
    .subscribeToTopic('php_notification_gymkid');
```

Bu sayede sunucu, bireysel FCM token'ı bilmeden tüm abone cihazlara toplu bildirim gönderebilir. Topic adı `php_notification_gymkid` olduğuna göre sunucu tarafı PHP ile yazılmış.

**Önemli:** Topic aboneliği `HomeScreen.initNotification()` içinde yapılır. Yani kullanıcı giriş yapıp ana ekrana ulaşana kadar (ilk kez) topic aboneliği gerçekleşmez.

---

## 17. Akış Şeması (Tüm Senaryolar)

### A. Uygulama İlk Kez Açılıyor

```
main() → Firebase.initializeApp()
       → LandingScreen
         → initFirebaseMessage()
           → iOS: getAPNSToken() [3sn bekle]
           → getToken() → fcmToken
           → isAuth? → ApiService.updateFCMToken()
           → requestPermission()
         → onBackgroundMessage(handler)
         → yönlendirme (/ veya /qrMain veya /redirect)
```

### B. Kullanıcı Giriş Yapıyor

```
LoginScreen → form validate
            → AuthProvider.login() veya QrAuthProvider.login()
            → getAPNSToken() / getToken()
            → ApiService.updateFCMToken() veya QRApiService.updateFCMToken()
            → context.go('/')
```

### C. FCM Mesajı Geldi (Uygulama Açık — Foreground)

```
FCM Server → Firebase SDK
           → FirebaseMessaging.onMessage
           → foregroundMessageListener()
           → flutter_local_notifications.show()
           → Sistem bildirim alanında görünür
           → Kullanıcı tıkladı
           → onDidReceiveNotificationResponse()
           → navigatePage(payload)  ← ŞU AN DEVRE DIŞI (yorum satırı)
```

### D. FCM Mesajı Geldi (Uygulama Arka Planda — Background)

```
FCM Server → Firebase SDK
           → Sistem otomatik bildirim gösterir (notification payload)
           → _firebaseMessagingBackgroundHandler() → Firebase init
           → Kullanıcı bildirime tıkladı
           → FirebaseMessaging.onMessageOpenedApp
           → onMessageOpenedApp()
           → GoRouter.push(message.data['page'])
```

### E. FCM Mesajı Geldi (Uygulama Kapalı — Terminated)

```
FCM Server → Firebase SDK
           → Sistem bildirim gösterir
           → Kullanıcı tıkladı → Uygulama açıldı
           → HomeScreen.initNotification()
           → getInitialMessage()
           → GoRouter.push(initMessage.data['page'])
```

### F. QRKids API Bildirimleri

```
QrNotifications Ekranı açıldı
  → qrNotificationsProvider.fetchNotifications()
  → QRApiService.getNotifications(user_key)
  → POST /qr/GetNotifications
  → QRNotificationResponse.fromJson()
  → UI'da listele

Kullanıcı bildirime tıkladı (gelecekte):
  → qrNotificationsProvider.markAsRead(notificationId)
  → QRApiService.markNotificationRead(...)
  → fetchNotifications() yenile
```

---

## 18. Eksiklikler ve Geliştirme Önerileri

### 🔴 Kritik Sorunlar

1. **Deep-Link Navigasyonu Devre Dışı**
   - `NotificationService.navigatePage()` içindeki tüm navigasyon kodu yorum satırına alınmış.
   - Foreground bildirimine tıklandığında hiçbir şey olmaz.
   - **Çözüm:** `GoRouter` veya `NavigatorKey` kullanarak yönlendirme eklenmeli.

2. **`onBackgroundMessage` Sırasıyla Kaydediliyor**
   - `FirebaseMessaging.onBackgroundMessage()` teknik olarak `main()` içinde veya `@pragma('vm:entry-point')` ile işaretlenmiş top-level bir fonksiyon olarak çağrılmalıdır. Mevcut hâlde `initApp()` içinde çağrılıyor; bu bazen background mesajların kaçırılmasına neden olabilir.

3. **`QrNotifications` Ekranında `markAsRead` Tetiklenmiyor**
   - `isRead` verisi modelde mevcut, `markAsRead` API'si de hazır, ancak kullanıcı bildirime dokunduğunda hiçbir çağrı yapılmıyor.

### 🟡 Orta Öncelikli Sorunlar

4. **Notification Channel Tutarsızlığı**
   - AndroidManifest'te `gymkid` channel tanımlı.
   - `flutter_local_notifications`'da `smartkids` channel kullanılıyor.
   - FCM notification payload'ları `gymkid`'e, local bildirimler `smartkids`'e gider. Kullanıcı yanlışlıkla bir kanalı kapatırsa bazı bildirimler görünmez.

5. **Topic Aboneliği Geç Yapılıyor**
   - Topic aboneliği `HomeScreen.initState()`'te gerçekleşiyor.
   - Kullanıcı login olup ana sayfaya geçmeden önce gelen topic mesajları alınamaz.
   - **Çözüm:** `LandingScreen.initFirebaseMessage()`'a taşınmalı.

6. **iOS'ta FCM Token Sadece APNS Varsa Alınıyor**
   - iOS Simulator'da APNS çalışmadığı için `fcmToken` `null` kalır ve token sunucuya kaydedilemez.

7. **`unreadCount` Getter'ı Kullanılmıyor**
   - `QrNotificationsProvider.unreadCount` hesaplanıyor ama UI'da rozetde (badge) gösterilmiyor.

### 🟢 Geliştirme Önerileri

8. **Token Yenileme (Token Refresh)**
   - `FirebaseMessaging.instance.onTokenRefresh` dinlenmiyor.
   - Token değiştiğinde (cihaz yenileme, uygulama yeniden yükleme) sunucudaki token güncellenmez.
   - **Çözüm:**
     ```dart
     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
       ApiService.updateFCMToken(..., token: newToken);
     });
     ```

9. **Bildirim Geçmişi (SmartKids)**
   - SmartKids tarafı için API bildirim geçmişi yok; yalnızca FCM push var.
   - Kaçırılan bildirimlere erişim mümkün değil.

10. **Notification ID Sabit Kullanılıyor**
    - Tüm bildirimler `id: 0` ile gösteriliyor.
    - Birden fazla bildirim gelirse önceki bildirim ezilir.
    - **Çözüm:** Timestamp veya hashCode ile unique ID oluştur.

---

## Özet

```
GymKidSmart Bildirim Sistemi
├── FCM (Firebase Cloud Messaging)
│   ├── Token Yönetimi
│   │   ├── Android: Doğrudan getToken()
│   │   └── iOS: getAPNSToken() → getToken()
│   ├── Dinleyiciler (HomeScreen)
│   │   ├── onMessage → foreground → local notification
│   │   ├── onMessageOpenedApp → background tıklama → deep-link
│   │   └── getInitialMessage → terminated tıklama → deep-link
│   ├── Background Handler (LandingScreen)
│   │   └── _firebaseMessagingBackgroundHandler → Firebase init
│   └── Topic: php_notification_gymkid
│
├── flutter_local_notifications (NotificationService)
│   ├── Android channel: smartkids (Importance.max)
│   ├── iOS: DarwinNotificationDetails
│   ├── onDidReceiveNotificationResponse → navigatePage [DEVRE DIŞI]
│   └── onDidReceiveBackgroundNotificationResponse → navigatePage [DEVRE DIŞI]
│
└── QRKids API Bildirimleri
    ├── GetNotifications → QRNotificationResponse
    ├── MarkNotificationRead
    └── QrNotificationsProvider (ChangeNotifier)
```
