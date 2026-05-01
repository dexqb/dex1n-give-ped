Config = {}

-- Yetkili Discord ID Listesi.
Config.Admins = {
    "", -- Buraya yetkili Discord ID'lerini ekleyin.
}

-- Veritabanı Tablo Adı.
Config.DatabaseTable = "user_peds"

-- Karakter Sistemi Seçimi: 'qb-clothing' veya 'illenium-appearance'.
Config.SkinScript = 'qb-clothing' 

-- Komut Ayarları.
Config.Commands = {
    admin = "adminped", -- Yönetici menüsünü açar.
    user = "pedmenu"    -- Oyuncu ped menüsünü açar.
}

-- Bildirim Ayarları.
Config.Notifications = {
    no_permission = "Bu komutu kullanmak için yetkiniz yok!",
    no_identifier = "Hedef oyuncu bulunamadı!",
    give_success = "Ped başarıyla verildi!",
    give_fail = "Veritabanı hatası oluştu!",
    target_receive = "Size yeni bir ped verildi: %s.",
    delete_success = "Ped başarıyla silindi!",
    delete_fail = "Ped silinirken bir hata oluştu!",
    no_ped_found = "Bu oyuncuya ait herhangi bir ped bulunamadı.",
    invalid_model = "Geçersiz ped modeli!",
    apply_success = "Ped başarıyla uygulandı.",
    skin_restored = "Karakteriniz başarıyla geri yüklendi.",
    banned_ped = "Bu ped modelini vermek yasaktır!"
}

-- Yasaklı Ped Modelleri.
Config.BlacklistedPeds = {
    "mp_m_freemode_01",
    "mp_f_freemode_01",
}

-- Webhook Ayarları.
Config.Webhooks = {
    give = "", -- Ped verme log kanalı URL'si.
    delete = "" -- Ped silme log kanalı URL'si.
}

-- 🐝 Bee Mods & FiveM discord sunucumuza katılırsanız sevinirim: https://discord.gg/3PB4FHaCJs
