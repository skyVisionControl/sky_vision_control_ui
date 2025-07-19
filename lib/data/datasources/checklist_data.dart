// checklist_data.dart
//
// Uçuş öncesi kontrol listesi verileri.

class ChecklistData {
  static final List<Map<String, dynamic>> checklistItems = [
    {'task': 'KUBBE (Pasha Balloons)', 'completed': false, 'isHeader': true},
    {'task': '1. Tay Halkası - Hasar veya aşınma kontrolü', 'completed': true},
    {'task': '2. Taç Halkası - Hasar ve korozyon kontrolü', 'completed': true},
    {'task': '3. Dikey Yük Şeritleri - Taç halkasındaki geri dönüşler', 'completed': false},
    {'task': '4. Dikey Yük Şeritleri - Diğer şeritler ile kesişme noktası', 'completed': false},
    {'task': '5. Dikey Yük Şeritleri - Hasar ve yanık kontrolü', 'completed': true},
    {'task': '6. Dikey Yük Şeritleri - Bağlantı noktalarında kılıflar ve geri dönüşler', 'completed': false},
    {'task': '7. Yatay Yük Şeritleri - Paragik tenar şeridi kontrolü', 'completed': true},
    {'task': '8. Yatay Yük Şeritleri - Kubbedeki tüm yatay şeritler', 'completed': true},
    {'task': '9. Yatay Yük Şeritleri - Etek ağzı yatay şeridi', 'completed': true},
    {'task': '10. Kumaş Paneller - Hasar veya delik kontrolü', 'completed': false},
    {'task': '11. Kumaş Paneller - Geçirgenlik ve gözenekler', 'completed': true},
    {'task': '12. Kumaş Paneller - Işırı sunma belirtisi kontrolü', 'completed': true},
    {'task': '13. Kumaş Paneller - Birleşme yerleri ve dikişler', 'completed': false},
    {'task': '14. İlimik (Loops) - Hasar kontrolü', 'completed': true},
    {'task': '15. Merkez Hat - Paragütün merkezde ve hasar/aşınma kontrolü', 'completed': true},
    {'task': '16. Kontrol İçleri - Hasar ve aşınma kontrolü', 'completed': true},
    {'task': '17. Kısansıkar - Hasar veya arıza kontrolü', 'completed': true},
    {'task': '18. Yatay Yük Şeritleri - Etek ağzı yatay şeridi (tekrar)', 'completed': true},
    {'task': '19. Tüp Sensörü - Kurulu ve iyi durumda', 'completed': false},
    {'task': '20. Gizli Termometre - Aşırı ısınma kontrolü', 'completed': true},
    {'task': '21. Çelik Halatlar - Hasar ve korozyon kontrolü', 'completed': false},
    {'task': '22. Karabina - Korozyon ve çalışırlık kontrolü', 'completed': false},
    {'task': '23. Bakımlar - Üretici manuellere göre yapıldı', 'completed': true},
    {'task': '24. Velko - Uygunluk ve durum kontrolü', 'completed': false},

    {'task': 'SEPET (Pasha Balloons)', 'completed': true, 'isHeader': true},
    {'task': '1. Sepet Genel Durumu - Hasar kontrolü', 'completed': true},
    {'task': '2. Sepet Çelik Halatları - Hasar ve bükülme kontrolü', 'completed': true},
    {'task': '3. Yük Çerçevesi (Frame) - Direklerin oturması ve hasar', 'completed': true},
    {'task': '4. Bağlantı Noktaları - Sağlamlık ve karabina vidaları', 'completed': true},
    {'task': '5. Yangın Söndürücü - Erişilebilir ve çalışır durumda', 'completed': true},
    {'task': '6. Tüp Bağlama Kemerleri - Doğru yerde ve sabitlenmiş', 'completed': true},

    {'task': 'BURNER (Pasha Balloons)', 'completed': false, 'isHeader': true},
    {'task': '1. Burner Genel Durumu - Hasar kontrolü', 'completed': true},
    {'task': '2. Valfler - Düzgün çalışma ve kapanma kontrolü', 'completed': false},
    {'task': '3. Yakıt Sistemi - Sızıntı kontrolü', 'completed': true},
    {'task': '4. Jeler - Çalışma ve tıkanıklık kontrolü', 'completed': false},
    {'task': '5. Helezonlar - Hasar kontrolü', 'completed': true},
    {'task': '6. Göstergeler - Yerinde ve istenilen değerde', 'completed': true},
    {'task': '7. Yakıt Hortumları - Hasar ve kaçak kontrolü', 'completed': true},

    {'task': 'YAKIT', 'completed': true, 'isHeader': true},
    {'task': '1. Planlanan uçuş süresince yeterli yakıt', 'completed': true},

    {'task': 'EKİPMAN', 'completed': true, 'isHeader': true},
    {'task': '1. Gerekli belge ve ekipmanların hazır olduğu', 'completed': true},

    {'task': 'GENEL ŞARTLAR', 'completed': false, 'isHeader': true},
    {'task': '1. Yük hesaplamalarının uygunluğu', 'completed': true},
    {'task': '2. Meteorolojik raporlar ve uçuş izni', 'completed': true},
    {'task': '3. Kalkış alanının engellerden arınmış olması', 'completed': true},
    {'task': '4. Hava şartlarının uygun olması', 'completed': false},
    {'task': '5. Meteorolojik şartlar ve yükleme hesabı', 'completed': true},
  ];

  // Kontrol listesi verilerini ChecklistItem modeline dönüştürme
  static List<Map<String, dynamic>> getChecklistItemsForInitialization() {
    List<Map<String, dynamic>> items = [];
    String currentCategory = "";
    int idCounter = 1;

    for (var item in checklistItems) {
      if (item['isHeader'] == true) {
        currentCategory = item['task'];
        // Başlıkları dahil etmiyoruz, sadece kategorileri alıyoruz
      } else {
        items.add({
          'id': idCounter.toString(),
          'title': item['task'],
          'description': '', // İhtiyaç halinde açıklama eklenebilir
          'isCompleted': item['completed'],
          'isMandatory': true, // Tüm öğeler zorunlu olarak işaretlendi
          'note': null,
          'category': currentCategory,
        });
        idCounter++;
      }
    }

    return items;
  }
}