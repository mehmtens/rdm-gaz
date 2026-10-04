## StoryData — 36 bölümün oyun içinde gösterilen hikâye metinleri.
##
## Her bölüm için: `brief` (bölüm başı hikâye kartı), `goal` (HUD'daki hedef satırı)
## ve `outro` (bitiş noktasında oynayan kısa konuşma; [konuşmacı, replik] çiftleri).
## Sıra `GameState.LEVELS` ile aynıdır. Kendi finalini oynatan bölümlerde `outro` boştur.
class_name StoryData
extends RefCounted

const BOOK_NAMES: PackedStringArray = ["GAZELLE'İN İZİ", "HALİÇ'İN İZİ", "İSTANBUL'UN SESİ"]

const CHAPTERS: Array = [
	# ---------------------------- KİTAP 1 ----------------------------
	{
		"brief": "Gazelle, mahallenin ortasında bir minibüse bindirilip kaçırıldı. Sokakları Karahanlı'nın adamları tutuyor. Redmount minibüsün izini sürmek için yola çıkıyor.",
		"goal": "Minibüsün izini sür, Kuzey Hanı'na ulaş",
		"outro": [
			["REDMOUNT", "Kuzey Hanı boşaltılmış. Gazelle'i konvoyla arka sokaklara çıkarmışlar."],
			["REDMOUNT", "Lastik izleri taze. Peşlerindeyim."],
		],
	},
	{
		"brief": "Gazelle'i taşıyan konvoy arka sokaklara daldı. Redmount çatılardan ve ara geçitlerden ilerleyip konvoyun rotasını çözmek zorunda.",
		"goal": "Konvoyun rotasını çöz",
		"outro": [
			["REDMOUNT", "Konvoy raylara gidiyor, ama önce gece pazarından geçmiş."],
			["REDMOUNT", "Pazarda beni bekleyen bir pusu var. Olsun."],
		],
	},
	{
		"brief": "Karahanlı'nın adamları gece pazarının bütün çıkışlarını tuttu. Bu, Redmount için kurulmuş ilk örgütlü pusu.",
		"goal": "Pusuyu kır, pazardan çık",
		"outro": [
			["REDMOUNT", "Karahanlı yalnız Gazelle'i almamış; gördüğünü anlatabilecek herkesi topluyor."],
			["REDMOUNT", "Şehir çıkışını kapatmışlar. Kontrol bölgesini aşmam gerek."],
		],
	},
	{
		"brief": "Şehir çıkışı siperler ve tüfekli muhafızlarla kapatıldı. Gazelle'i taşıyan sevkiyat bu hattın ötesinde.",
		"goal": "Kontrol hattını aş",
		"outro": [
			["REDMOUNT", "Hat düştü. Gazelle'i yük trenine aktarmışlar."],
			["REDMOUNT", "Trene yetişmeliyim."],
		],
	},
	{
		"brief": "Sevkiyat yük trenine aktarıldı. Demiryolu, vagonlar ve depolarla abluka altında.",
		"goal": "Ablukayı geç, sevkiyat hattına gir",
		"outro": [
			["REDMOUNT", "Tren sanayi kuşağına girdi. Gazelle'e yaklaşıyorum."],
			["REDMOUNT", "Buradan sonrası ağır birliklerin bölgesi."],
		],
	},
	{
		"brief": "Sanayi kuşağını zırhlı birlikler, alev bacaları ve presler koruyor. Karahanlı'nın haddehanesi bu hattın sonunda.",
		"goal": "Sanayi kuşağını yar",
		"outro": [
			["REDMOUNT", "Sanayi hattı çöktü. Haddehanenin bacası görünüyor."],
			["REDMOUNT", "Karahanlı orada. İlk kez karşılaşacağız."],
		],
	},
	{
		"brief": "Karahanlı'nın çelik döktüğü haddehane. Redmount onun sesini ilk kez burada duyuyor; Gazelle ise çoktan başka bir yere taşınmış.",
		"goal": "Haddehaneyi geç, vericiyi sustur",
		"outro": [
			["REDMOUNT", "Beni oyalamak için burada beklemiş. Gazelle yeraltı hattıyla dağa götürülüyor."],
			["REDMOUNT", "Tünele iniyorum."],
		],
	},
	{
		"brief": "Gazelle dağın içindeki tünellerden taşınıyor. Geçtiği her kapının sesini sayıp Redmount'a iz bırakıyor: üç kapı kaldı.",
		"goal": "Tünelde Gazelle'in izini sür",
		"outro": [
			["REDMOUNT", "Tünel dağ geçidine açılıyor. Önümde Karahanlı'nın zırhlı üssü var."],
			["REDMOUNT", "Kapıları sayıyorsun Gazelle. Ben de sayıyorum."],
		],
	},
	{
		"brief": "Dağ geçidini Karahanlı'nın zırhlı üssü kapatıyor. Buradaki adamlar tek yumrukla düşmüyor; güçlendiriciler işe yarayacak.",
		"goal": "Zırhlı üssü aş, dağ geçidini aç",
		"outro": [
			["REDMOUNT", "Geçit açıldı. Kalenin kuzey surları tam karşımda."],
			["REDMOUNT", "Ana kapı tutulmuş. Kör noktadan tırmanacağım."],
		],
	},
	{
		"brief": "Karahanlı kapısını açık bırakıp meydan okuyor. Redmount ana kapı yerine surların kör noktasına tırmanıyor.",
		"goal": "Surların kör noktasına çık",
		"outro": [
			["REDMOUNT", "Surları aştım. Gazelle'in sesi duvarın öbür tarafından geliyor."],
			["REDMOUNT", "İç koridorda seçkin muhafızlar var. Sessiz olmalıyım."],
		],
	},
	{
		"brief": "Kalenin dar iç koridoru. Gazelle duvarın hemen ötesinde; arada Karahanlı'nın seçkin muhafızları var.",
		"goal": "Gazelle'in tutulduğu kanada ulaş",
		"outro": [
			["GAZELLE", "Redmount! Beni iç kaleye indiriyorlar. Karahanlı taht salonunda bekliyor."],
			["REDMOUNT", "Dayan. Son kapıya geldim."],
		],
	},
	{
		"brief": "İç kale: cephanelik, sarnıç, tutukevi ve taht salonu. Yolun sonunda Karahanlı tek başına bekliyor. Gazelle onun arkasındaki kapının ardında.",
		"goal": "Karahanlı'yı yen, Gazelle'i kurtar",
		"outro": [],
	},
	# ---------------------------- KİTAP 2 ----------------------------
	{
		"brief": "Karahanlı yenildi, Gazelle kurtuldu. Ama Gazelle kaleden bir sevkiyat defteri çıkardı: kaçırılması tek bir adamın işi değildi. İkili, defterdeki ilk adrese, Haliç kıyısına iniyor.",
		"goal": "Defterdeki ilk adresi bul",
		"outro": [
			["GAZELLE", "Gümrük kaydı tek bir depoyu göstermiyor. Haliç boyunca işleyen koca bir sevkiyat zinciri var."],
			["REDMOUNT", "O zaman zinciri halka halka sökeceğiz."],
		],
	},
	{
		"brief": "Gümrükte bulunan kayıt bir adres değil, sahte bir sevkiyat mührü çıktı. Redmount ve Gazelle mührün kalıbını Cibali'deki baskıhanede arıyor.",
		"goal": "Sahte mührün kalıbını bul",
		"outro": [
			["GAZELLE", "Kalıp burada basılmış. Arkasındaki ikinci adres Zeyrek'in su yollarını gösteriyor."],
			["REDMOUNT", "Mührü kimin bastırdığı hâlâ belli değil. Devam."],
		],
	},
	{
		"brief": "Kalıptaki ikinci adres Zeyrek'in eski su yolları. İkili mahalle çeşmesinden su kemerine, oradan sarnıca iniyor.",
		"goal": "Su yolundaki kaçak geçidi bul",
		"outro": [
			["GAZELLE", "Vanaların hepsinde aynı sahte mühür. Su şebekesini kaçak sevkiyat geçidine çevirmişler."],
			["REDMOUNT", "Çıkış kaydı Süleymaniye'yi gösteriyor."],
		],
	},
	{
		"brief": "Zeyrek vanasının kaydı Süleymaniye'de bir ciltçi deposuna çıkıyor. Kaçak sevkiyatlar kâğıt üzerinde yardım malzemesi gibi gösterilmiş.",
		"goal": "Ciltçi deposundaki asıl listeyi bul",
		"outro": [
			["GAZELLE", "Asıl liste arka terastaymış. Mühürlü üç çuval Beyazıt'taki eski posta hattına gitmiş."],
			["REDMOUNT", "Çuvalların peşine düşelim."],
		],
	},
	{
		"brief": "Listeye göre sahte mühürlü üç çuval Beyazıt posta binasına teslim edildi. İkili sahaflardan tasnif salonuna giriyor.",
		"goal": "Üç çuvalın izini sür",
		"outro": [
			["GAZELLE", "İki çuval boş. Üçüncünün izi telgraf bandında: Kapalıçarşı'nın arka hanı."],
			["REDMOUNT", "Çarşı kalabalık olur. Arkadan gireriz."],
		],
	},
	{
		"brief": "Posta fişi, sevkiyatın Kapalıçarşı'nın arka hanında dağıtıldığını gösteriyor. Hanın kapısı tutulmuş; içeride gizli bir defter var.",
		"goal": "Gizli defteri ele geçir",
		"outro": [
			["GAZELLE", "Defter elimizde. Dağıtım emirleri Çemberlitaş'taki kapalı hamamın külhanından çıkıyor."],
			["REDMOUNT", "Dağıtımı yöneten hâlâ gölgede. Külhana gidiyoruz."],
		],
	},
	{
		"brief": "Hamam kapalı ama külhanı hâlâ yanıyor: dağıtım emirleri buradan çıkıyor. İkili servis yolundan içeri sızıyor.",
		"goal": "Külhandaki kayıtları bul",
		"outro": [
			["GAZELLE", "Kayıtlara göre bütün sevkiyat Samatya'daki taş depolarında birleşiyor."],
			["REDMOUNT", "Taş deposu... Kâğıt saklamak için tuhaf bir yer."],
		],
	},
	{
		"brief": "Sahte evrak ağının bütün sevkiyatı Samatya'da birleşiyor. Taş blokların ağırlığı ise kayıtlarla uyuşmuyor.",
		"goal": "Taş depolarındaki kayıt odasına gir",
		"outro": [
			["GAZELLE", "Blokların içini oymuşlar; evrakı taşın içinde taşıyorlar. Çıkış fişinde \"Yenikapı gece vardiyası\" yazıyor."],
			["REDMOUNT", "Gece bitmeden iskelede olalım."],
		],
	},
	{
		"brief": "Samatya fişi Yenikapı'da bir gece teslimini gösteriyor. Evrak gemiye yüklenecekmiş gibi görünüyor.",
		"goal": "Gece teslimini yakala",
		"outro": [
			["GAZELLE", "Gemi fişi şaşırtmaca. Yük şehirden çıkmıyor; gerçek teslim Aksaray'daki eski pompa istasyonuna."],
			["REDMOUNT", "Demek asıl hedef şehrin içinde."],
		],
	},
	{
		"brief": "Gerçek teslim noktası Aksaray'daki eski pompa istasyonu. Bina şafaktan önce çalıştırılmış; biri su hattında hazırlık yapıyor.",
		"goal": "Pompa istasyonundaki yükü bul",
		"outro": [
			["GAZELLE", "Asıl yük yedek vanalarmış; hepsini değiştirmişler. Şafakta su, Saraçhane ana vanasından kesilecek."],
			["REDMOUNT", "Bütün İstanbul susuz kalacak. Saraçhane'ye!"],
		],
	},
	{
		"brief": "Şafakta İstanbul'un suyu Saraçhane ana vanasından kesilecek. Redmount ve Gazelle vanayı durdurmak için su idaresine giriyor.",
		"goal": "Ana vanayı durdur",
		"outro": [
			["GAZELLE", "Yerel vanayı durdurduk ama üst hat buradan yönetilmiyor. Kumanda Bozdoğan Kemeri'ndeki servis kulesinde."],
			["REDMOUNT", "O zaman kemere çıkıyoruz. Son kumanda orada."],
		],
	},
	{
		"brief": "Su kesintisinin son kumandası Bozdoğan Kemeri'nin servis kulesinde. Kulenin tepesinde Ana Vana Muhafızı bekliyor.",
		"goal": "Kuleye çık, kumanda anahtarını al",
		"outro": [
			["GAZELLE", "Basınç normale döndü. İstanbul'un suyu akıyor."],
			["REDMOUNT", "Anahtardaki mühre bak: bir matbaanın damgası. Bu iş burada bitmedi."],
		],
	},
	# ---------------------------- KİTAP 3 ----------------------------
	{
		"brief": "Kumanda anahtarının mührü Cağaloğlu'nda eski bir matbaaya çıkıyor. Su kesintisini planlayanlar şimdi şehrin haberlerine de el atmış.",
		"goal": "Matbaadaki dağıtım defterini bul",
		"outro": [
			["GAZELLE", "Emir yalnız suya değil, şehirdeki haberlere de yönelikmiş. İlk sevkiyat Sirkeci'ye çıkmış."],
			["REDMOUNT", "Şehri önce susuz, sonra habersiz bırakacaklardı."],
		],
	},
	{
		"brief": "Dağıtım defteri, mühürlü kâğıtların Sirkeci garına indirildiğini gösteriyor. Garın yolcu tarafı ise bir yem.",
		"goal": "Arka yük peronundaki sevk odasına ulaş",
		"outro": [
			["GAZELLE", "Kâğıtlar trene hiç yüklenmemiş. Asıl emirler Galata'daki telgraf hattından dağıtılıyor."],
			["REDMOUNT", "Kâğıt aldatmacaydı. Teli keseceğiz."],
		],
	},
	{
		"brief": "Asıl emirler Galata telgrafından yayılıyor. İkili Karaköy kıyısından telgraf binasına giriyor.",
		"goal": "Galata telgraf hattını kes",
		"outro": [
			["GAZELLE", "Galata hattı kesildi. Ama aynı emir Üsküdar'daki yedek röleye de gönderilmiş."],
			["REDMOUNT", "Karşıya geçiyoruz."],
		],
	},
	{
		"brief": "Galata sustu, ama yayın Üsküdar'daki yedek röleye ulaştı. Şerit makineye takılmadan durdurulmalı.",
		"goal": "Yedek röleyi durdur",
		"outro": [
			["GAZELLE", "Şeridi makineye takılmadan aldık. Alıcı listesinde Kuzguncuk'ta eski bir kıyı deposu var."],
			["REDMOUNT", "Sıradaki iz orası."],
		],
	},
	{
		"brief": "Alıcı listesindeki ilk adres Kuzguncuk'taki eski kıyı deposu. Mahalle sessiz, rıhtım kapısı ise korunuyor.",
		"goal": "Depo defterlerini bul",
		"outro": [
			["GAZELLE", "Defterlere göre evrak Beylerbeyi'ndeki iskele arşivine aktarılmış."],
			["REDMOUNT", "Kıyı boyunca kuzeye çıkıyoruz."],
		],
	},
	{
		"brief": "Evrak Beylerbeyi iskele arşivinde toplanıyor. Muhafızlar kâğıtları içeride yakmaya hazırlanıyor.",
		"goal": "Arşivi yakılmadan ele geçir",
		"outro": [
			["GAZELLE", "Kâğıtları yakamadılar. Emirlerin altındaki mühür Çengelköy'de bir sahil konağına ait."],
			["REDMOUNT", "Mührün sahibini bulmanın zamanı geldi."],
		],
	},
	{
		"brief": "Bütün emirlerin altındaki mühür Çengelköy'deki sahil konağında saklanıyor. Koruma, defteri mühür odasına taşımış.",
		"goal": "Mühür odasına gir",
		"outro": [
			["GAZELLE", "Mühür ve defter bizde. Emirler buradan Kuleli'deki gözetleme hattına fenerle iletiliyor."],
			["REDMOUNT", "Fenerleri izleyelim."],
		],
	},
	{
		"brief": "Kıyıdaki sinyal fenerleri bir teknenin yolunu çiziyor. Boş görünen nöbet noktaları sahte.",
		"goal": "Sinyal kayıt odasını bul",
		"outro": [
			["GAZELLE", "Kayıt odasına göre tekne bu gece Vaniköy'e yanaşacak."],
			["REDMOUNT", "Gece sevkiyatını kaçırmayalım."],
		],
	},
	{
		"brief": "Tekne Vaniköy iskelesine yanaşmış ama yükü boşaltılmış. Kasaların izi kapalı bir yükleme hattına gidiyor.",
		"goal": "Boş kasaların izini sür",
		"outro": [
			["GAZELLE", "Kasalardan çıkan parçalar bir verici oluşturuyor. Kablolar Kandilli sırtına çıkıyor."],
			["REDMOUNT", "Şehri susturmak için kendi yayınlarını kuruyorlar."],
		],
	},
	{
		"brief": "Kablolar evlerin üstünden Kandilli sırtındaki vericiye tırmanıyor. Verici çalışırsa şehrin bütün yayınları bastırılacak.",
		"goal": "Kandilli vericisini durdur",
		"outro": [
			["GAZELLE", "Verici durdu ama kumandası burada değil. Hat Anadoluhisarı'nın içine iniyor."],
			["REDMOUNT", "Hisara giriyoruz."],
		],
	},
	{
		"brief": "Yayının kumandası Anadoluhisarı'nın surları içinde. Kumanda alınmadan susturma planı durmayacak.",
		"goal": "Hisardaki kumanda anahtarını al",
		"outro": [
			["GAZELLE", "Kumanda bizde. Geriye tek şey kaldı: Göksu'daki mavnadan kayıtları bütün şehre yayınlamak."],
			["REDMOUNT", "Sen yayına ver. Ben yayını korurum."],
		],
	},
	{
		"brief": "Göksu'da demirli mavna son yayın istasyonu. Gazelle topladıkları bütün kayıtları şehre duyuracak; Redmount üç bağlantıyı kapatıp Yayın Şefi'ni durdurmalı.",
		"goal": "Üç bağlantıyı kapat, yayını koru",
		"outro": [],
	},
]


static func has(index: int) -> bool:
	return index >= 0 and index < CHAPTERS.size()


static func brief(index: int) -> String:
	return CHAPTERS[index]["brief"] if has(index) else ""


static func goal(index: int) -> String:
	return CHAPTERS[index]["goal"] if has(index) else ""


## Bitiş konuşması — DialogueBox.play() biçiminde ({speaker, text}).
static func outro(index: int) -> Array:
	var lines: Array = []
	if has(index):
		for pair in CHAPTERS[index]["outro"]:
			lines.append({"speaker": pair[0], "text": pair[1]})
	return lines


## Kartın üst satırı: yalnız kitabın adı (numara gösterilmez).
static func header(index: int) -> String:
	return BOOK_NAMES[clampi(index / 12, 0, BOOK_NAMES.size() - 1)]
