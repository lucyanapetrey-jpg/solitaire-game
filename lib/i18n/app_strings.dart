import 'package:flutter/material.dart';

class AppStrings {
  final String klondike;
  final String solitaire;
  final String newGame;
  final String shop;
  final String missions;
  final String dailyBonus;
  final String dayOf7;
  final String day;
  final String claim;
  final String streak;
  final String stackEmpty;
  final String drawFromStack;
  final String next3Cards;
  final String moveToFoundation;
  final String moveWasteToFoundation;
  final String win;
  final String shopUnavailable;
  final String notEnoughDiamonds;
  final String owned;
  final String settings;
  final String language;
  final String musicOn;
  final String musicOff;
  final String systemDefault;

  const AppStrings({
    required this.klondike,
    required this.solitaire,
    required this.newGame,
    required this.shop,
    required this.missions,
    required this.dailyBonus,
    required this.dayOf7,
    required this.day,
    required this.claim,
    required this.streak,
    required this.stackEmpty,
    required this.drawFromStack,
    required this.next3Cards,
    required this.moveToFoundation,
    required this.moveWasteToFoundation,
    required this.win,
    required this.shopUnavailable,
    required this.notEnoughDiamonds,
    required this.owned,
    required this.settings,
    required this.language,
    required this.musicOn,
    required this.musicOff,
    required this.systemDefault,
  });

  static AppStrings of(BuildContext context) {
    final code = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    return _all[code] ?? _all['en']!;
  }

  static const supportedLocales = <Locale>[
    Locale('en'), Locale('zh'), Locale('es'), Locale('hi'), Locale('ar'),
    Locale('pt'), Locale('ru'), Locale('ja'), Locale('de'), Locale('fr'),
    Locale('ro'),
  ];

  static const Map<String, AppStrings> _all = {
    'en': AppStrings(
      klondike: 'KLONDIKE', solitaire: 'Solitaire', newGame: 'New Game',
      shop: 'Shop', missions: 'Missions', dailyBonus: 'DAILY BONUS!',
      dayOf7: 'Day {n} / 7', day: 'Day', claim: 'CLAIM',
      streak: 'Streak: {n} consecutive days',
      stackEmpty: 'Stack empty', drawFromStack: 'Draw a card from stack',
      next3Cards: 'Next 3 cards',
      moveToFoundation: 'Move {card} to foundation!',
      moveWasteToFoundation: 'Move {card} from waste to foundation!',
      win: 'Congratulations! All cards arranged.',
      shopUnavailable: 'Shop unavailable',
      notEnoughDiamonds: 'Not enough diamonds',
      owned: 'Owned: {n}', settings: 'Settings', language: 'Language',
      musicOn: 'Music: On', musicOff: 'Music: Off', systemDefault: 'System default',
    ),
    'zh': AppStrings(
      klondike: '克朗代克', solitaire: '纸牌', newGame: '新游戏',
      shop: '商店', missions: '任务', dailyBonus: '每日奖励！',
      dayOf7: '第 {n} 天 / 共 7 天', day: '天', claim: '领取',
      streak: '连续 {n} 天',
      stackEmpty: '牌堆为空', drawFromStack: '从牌堆抽一张牌',
      next3Cards: '接下来 3 张牌',
      moveToFoundation: '把 {card} 移到基础堆！',
      moveWasteToFoundation: '把 {card} 从废牌堆移到基础堆！',
      win: '恭喜！所有牌都已排好。',
      shopUnavailable: '商店不可用',
      notEnoughDiamonds: '钻石不足',
      owned: '已拥有：{n}', settings: '设置', language: '语言',
      musicOn: '音乐：开', musicOff: '音乐：关', systemDefault: '系统默认',
    ),
    'es': AppStrings(
      klondike: 'KLONDIKE', solitaire: 'Solitario', newGame: 'Nuevo Juego',
      shop: 'Tienda', missions: 'Misiones', dailyBonus: '¡BONO DIARIO!',
      dayOf7: 'Día {n} / 7', day: 'Día', claim: 'RECLAMAR',
      streak: 'Racha: {n} días consecutivos',
      stackEmpty: 'Pila vacía', drawFromStack: 'Roba una carta de la pila',
      next3Cards: 'Próximas 3 cartas',
      moveToFoundation: '¡Mueve {card} a la fundación!',
      moveWasteToFoundation: '¡Mueve {card} del descarte a la fundación!',
      win: '¡Felicitaciones! Todas las cartas ordenadas.',
      shopUnavailable: 'Tienda no disponible',
      notEnoughDiamonds: 'Diamantes insuficientes',
      owned: 'Posee: {n}', settings: 'Ajustes', language: 'Idioma',
      musicOn: 'Música: Activada', musicOff: 'Música: Desactivada', systemDefault: 'Sistema',
    ),
    'hi': AppStrings(
      klondike: 'क्लोंडाइक', solitaire: 'सॉलिटेयर', newGame: 'नया खेल',
      shop: 'दुकान', missions: 'मिशन', dailyBonus: 'दैनिक बोनस!',
      dayOf7: 'दिन {n} / 7', day: 'दिन', claim: 'प्राप्त करें',
      streak: 'लगातार {n} दिन',
      stackEmpty: 'स्टैक खाली', drawFromStack: 'स्टैक से एक कार्ड निकालें',
      next3Cards: 'अगले 3 कार्ड',
      moveToFoundation: '{card} को फाउंडेशन पर ले जाएँ!',
      moveWasteToFoundation: '{card} को वेस्ट से फाउंडेशन पर ले जाएँ!',
      win: 'बधाई हो! सभी कार्ड व्यवस्थित।',
      shopUnavailable: 'दुकान उपलब्ध नहीं',
      notEnoughDiamonds: 'पर्याप्त डायमंड नहीं',
      owned: 'स्वामित्व: {n}', settings: 'सेटिंग्स', language: 'भाषा',
      musicOn: 'संगीत: चालू', musicOff: 'संगीत: बंद', systemDefault: 'सिस्टम डिफ़ॉल्ट',
    ),
    'ar': AppStrings(
      klondike: 'كلوندايك', solitaire: 'سوليتير', newGame: 'لعبة جديدة',
      shop: 'المتجر', missions: 'المهام', dailyBonus: 'مكافأة يومية!',
      dayOf7: 'اليوم {n} / 7', day: 'اليوم', claim: 'استلام',
      streak: 'سلسلة: {n} أيام متتالية',
      stackEmpty: 'المكدس فارغ', drawFromStack: 'اسحب بطاقة من المكدس',
      next3Cards: 'البطاقات الـ3 التالية',
      moveToFoundation: 'انقل {card} إلى الأساس!',
      moveWasteToFoundation: 'انقل {card} من النفايات إلى الأساس!',
      win: 'تهانينا! تم ترتيب جميع البطاقات.',
      shopUnavailable: 'المتجر غير متوفر',
      notEnoughDiamonds: 'الألماس غير كافٍ',
      owned: 'مملوك: {n}', settings: 'الإعدادات', language: 'اللغة',
      musicOn: 'الموسيقى: تشغيل', musicOff: 'الموسيقى: إيقاف', systemDefault: 'النظام',
    ),
    'pt': AppStrings(
      klondike: 'KLONDIKE', solitaire: 'Paciência', newGame: 'Novo Jogo',
      shop: 'Loja', missions: 'Missões', dailyBonus: 'BÔNUS DIÁRIO!',
      dayOf7: 'Dia {n} / 7', day: 'Dia', claim: 'RESGATAR',
      streak: 'Sequência: {n} dias consecutivos',
      stackEmpty: 'Pilha vazia', drawFromStack: 'Pegue uma carta da pilha',
      next3Cards: 'Próximas 3 cartas',
      moveToFoundation: 'Mova {card} para a fundação!',
      moveWasteToFoundation: 'Mova {card} do descarte para a fundação!',
      win: 'Parabéns! Todas as cartas arrumadas.',
      shopUnavailable: 'Loja indisponível',
      notEnoughDiamonds: 'Diamantes insuficientes',
      owned: 'Possui: {n}', settings: 'Configurações', language: 'Idioma',
      musicOn: 'Música: Ligada', musicOff: 'Música: Desligada', systemDefault: 'Sistema',
    ),
    'ru': AppStrings(
      klondike: 'КЛОНДАЙК', solitaire: 'Пасьянс', newGame: 'Новая игра',
      shop: 'Магазин', missions: 'Задания', dailyBonus: 'ЕЖЕДНЕВНЫЙ БОНУС!',
      dayOf7: 'День {n} / 7', day: 'День', claim: 'ЗАБРАТЬ',
      streak: 'Серия: {n} дней подряд',
      stackEmpty: 'Колода пуста', drawFromStack: 'Возьмите карту из колоды',
      next3Cards: 'Следующие 3 карты',
      moveToFoundation: 'Переместите {card} в основание!',
      moveWasteToFoundation: 'Переместите {card} в основание!',
      win: 'Поздравляем! Все карты собраны.',
      shopUnavailable: 'Магазин недоступен',
      notEnoughDiamonds: 'Недостаточно алмазов',
      owned: 'Куплено: {n}', settings: 'Настройки', language: 'Язык',
      musicOn: 'Музыка: Вкл.', musicOff: 'Музыка: Выкл.', systemDefault: 'По умолчанию',
    ),
    'ja': AppStrings(
      klondike: 'クロンダイク', solitaire: 'ソリティア', newGame: '新しいゲーム',
      shop: 'ショップ', missions: 'ミッション', dailyBonus: 'デイリーボーナス！',
      dayOf7: '{n} 日目 / 7', day: '日目', claim: '受け取る',
      streak: '連続 {n} 日',
      stackEmpty: 'スタックが空', drawFromStack: 'スタックからカードを引く',
      next3Cards: '次の3枚',
      moveToFoundation: '{card} を基礎に移動！',
      moveWasteToFoundation: '{card} をウェイストから基礎に移動！',
      win: 'おめでとう！全てのカードが揃いました。',
      shopUnavailable: 'ショップ利用不可',
      notEnoughDiamonds: 'ダイヤモンドが不足',
      owned: '所持: {n}', settings: '設定', language: '言語',
      musicOn: '音楽：オン', musicOff: '音楽：オフ', systemDefault: 'システム標準',
    ),
    'de': AppStrings(
      klondike: 'KLONDIKE', solitaire: 'Solitär', newGame: 'Neues Spiel',
      shop: 'Shop', missions: 'Missionen', dailyBonus: 'TÄGLICHER BONUS!',
      dayOf7: 'Tag {n} / 7', day: 'Tag', claim: 'EINFORDERN',
      streak: 'Serie: {n} Tage in Folge',
      stackEmpty: 'Stapel leer', drawFromStack: 'Karte vom Stapel ziehen',
      next3Cards: 'Nächste 3 Karten',
      moveToFoundation: 'Bewege {card} zur Grundlage!',
      moveWasteToFoundation: 'Bewege {card} vom Abfall zur Grundlage!',
      win: 'Glückwunsch! Alle Karten geordnet.',
      shopUnavailable: 'Shop nicht verfügbar',
      notEnoughDiamonds: 'Nicht genügend Diamanten',
      owned: 'Besitzt: {n}', settings: 'Einstellungen', language: 'Sprache',
      musicOn: 'Musik: An', musicOff: 'Musik: Aus', systemDefault: 'Systemstandard',
    ),
    'fr': AppStrings(
      klondike: 'KLONDIKE', solitaire: 'Solitaire', newGame: 'Nouvelle Partie',
      shop: 'Boutique', missions: 'Missions', dailyBonus: 'BONUS QUOTIDIEN !',
      dayOf7: 'Jour {n} / 7', day: 'Jour', claim: 'RÉCLAMER',
      streak: 'Série : {n} jours consécutifs',
      stackEmpty: 'Pile vide', drawFromStack: 'Pioche une carte de la pile',
      next3Cards: '3 prochaines cartes',
      moveToFoundation: 'Déplace {card} vers la fondation !',
      moveWasteToFoundation: 'Déplace {card} vers la fondation !',
      win: 'Félicitations ! Toutes les cartes arrangées.',
      shopUnavailable: 'Boutique indisponible',
      notEnoughDiamonds: 'Diamants insuffisants',
      owned: 'Possédé : {n}', settings: 'Paramètres', language: 'Langue',
      musicOn: 'Musique : activée', musicOff: 'Musique : désactivée', systemDefault: 'Système',
    ),
    'ro': AppStrings(
      klondike: 'KLONDIKE', solitaire: 'Solitaire', newGame: 'Joc Nou',
      shop: 'Magazin', missions: 'Misiuni', dailyBonus: 'BONUS ZILNIC!',
      dayOf7: 'Ziua {n} / 7', day: 'Ziua', claim: 'PRIMEȘTE',
      streak: 'Streak: {n} zile consecutive',
      stackEmpty: 'Stack gol', drawFromStack: 'Trage o carte din stack',
      next3Cards: 'Următoarele 3 cărți',
      moveToFoundation: 'Mută {card} la fundație!',
      moveWasteToFoundation: 'Mută {card} de la waste la fundație!',
      win: 'Felicitări! Ai aranjat toate cărțile.',
      shopUnavailable: 'Magazin indisponibil',
      notEnoughDiamonds: 'Diamante insuficiente',
      owned: 'Deținute: {n}', settings: 'Setări', language: 'Limbă',
      musicOn: 'Muzică: Pornită', musicOff: 'Muzică: Oprită', systemDefault: 'Sistem',
    ),
  };
}
