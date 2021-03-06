﻿////////////////////////////////////////////////////////////////////////////////
// Подбор номенклатуры (Клиент)
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЙ ПРОГРАММНЫЙ ИНТЕРФЕЙС

// Округляет число по заданному порядку.
//
// Параметры:
//  Число        - Число, которое необходимо округлить
//  ПорядокОкругления - Перечисления.ПорядкиОкругления - порядок округления
//  ОкруглятьВБольшуюСторону - Булево - округления в большую сторону.
//
// Возвращаемое значение:
//  Число        - результат округления.
//
Функция ОкруглитьЦену(Число, ПравилоОкругления, ОкруглятьВБольшуюСторону) Экспорт
	
	Перем Результат; // Возвращаемый результат.
	
	// Преобразуем порядок округления числа.
	// Если передали пустое значение порядка, то округлим до копеек. 
	Если НЕ ЗначениеЗаполнено(ПравилоОкругления) Тогда
		ПорядокОкругления = ПредопределенноеЗначение("Перечисление.ПорядкиОкругления.Окр0_01"); 
	Иначе
		ПорядокОкругления = ПравилоОкругления;
	КонецЕсли;
	Порядок = Число(Строка(ПорядокОкругления));
	
	// вычислим количество интервалов, входящих в число
	КоличествоИнтервал = Число / Порядок;
	
	// вычислим целое количество интервалов.
	КоличествоЦелыхИнтервалов = Цел(КоличествоИнтервал);
	
	Если КоличествоИнтервал = КоличествоЦелыхИнтервалов Тогда
		
		// Числа поделились нацело. Округлять не нужно.
		Результат	= Число;
	Иначе
		Если ОкруглятьВБольшуюСторону Тогда
			
			// При порядке округления "0.05" 0.371 должно округлиться до 0.4
			Результат = Порядок * (КоличествоЦелыхИнтервалов + 1);
		Иначе
			
			// При порядке округления "0.05" 0.371 должно округлиться до 0.35,
			// а 0.376 до 0.4
			Результат = Порядок * Окр(КоличествоИнтервал, 0, РежимОкругления.Окр15как20);
		КонецЕсли; 
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции // ОкруглитьЦену()


Процедура ОткрытьПодбор(ФормаВладелец, ИмяТабличнойЧасти, ПолноеИмяФормыПодбора) Экспорт
	
	ПараметрыПодбора = Новый Структура;
	Отказ = Ложь;
	
	ЗаполнитьЗначенияПараметровПодбора(ФормаВладелец, ИмяТабличнойЧасти, ПолноеИмяФормыПодбора, ПараметрыПодбора);
	
	Если НЕ Отказ Тогда
		
		ОписаниеОповещенияПриЗакрытииПодбора = Новый ОписаниеОповещения("ПриЗакрытииПодбора", ПодборНоменклатурыВДокументахКлиент.ЭтотОбъект);
		ОткрытьФорму(ПолноеИмяФормыПодбора, ПараметрыПодбора, ФормаВладелец, Истина, , , ОписаниеОповещенияПриЗакрытииПодбора, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура обработки результатов закрытия подбора
//
Процедура ПриЗакрытииПодбора(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если ТипЗнч(РезультатЗакрытия) = Тип("Структура") Тогда
		
		Если НЕ ПустаяСтрока(РезультатЗакрытия.АдресКорзиныВХранилище) Тогда
			
			Оповестить("ПодборПроизведен", РезультатЗакрытия.АдресКорзиныВХранилище, РезультатЗакрытия.УникальныйИдентификаторФормыВладельца);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры // ПриЗакрытииПодбора()

// Получение данных из форм-владельцев

Процедура ЗаполнитьЗначенияПараметровПодбора(ФормаВладелец, ИмяТабличнойЧасти, ПолноеИмяФормыПодбора, ПараметрыПодбора)
	
	ПараметрыПодбора.Вставить("Организация", ФормаВладелец.ЭтотОбъект.Объект.Организация);
	ПараметрыПодбора.Вставить("Дата", ФормаВладелец.ЭтотОбъект.Объект.Дата);
	ПараметрыПодбора.Вставить("ПериодЦен", ФормаВладелец.ЭтотОбъект.Объект.Дата);
	ПараметрыПодбора.Вставить("УникальныйИдентификаторФормыВладельца", ФормаВладелец.УникальныйИдентификатор);
	
	ЗаполнитьВидОперацииДокумента(ФормаВладелец, ПараметрыПодбора);
	ЗаполнитьПараметрВалютаДокумента(ФормаВладелец, ПараметрыПодбора);
	ЗаполнитьПараметрСтруктурнаяЕдиница(ФормаВладелец, ПараметрыПодбора);
	ЗаполнитьПараметрыНалогооблаженияДокумента(ФормаВладелец, ПараметрыПодбора);
	ЗаполнитьТипыНоменклатуры(ФормаВладелец, ИмяТабличнойЧасти, ПараметрыПодбора);
	ЗаполнитьВидыЦен(ФормаВладелец, ПолноеИмяФормыПодбора, ПараметрыПодбора);
	ЗаполнитьВидСкидкиНаценки(ФормаВладелец, ПолноеИмяФормыПодбора, ПараметрыПодбора);
	ЗаполнитьДополнительныеПараметры(ФормаВладелец, ПараметрыПодбора);
	// ДисконтныеКарты
	ЗаполнитьДисконтнуюКарту(ФормаВладелец, ПолноеИмяФормыПодбора, ПараметрыПодбора);
	// Конец ДисконтныеКарты
	
КонецПроцедуры

Процедура ЗаполнитьВидОперацииДокумента(ФормаВладелец, ПараметрыПодбора)
	Перем ВидОперации;
	
	Если ФормаВладелец.Объект.Свойство("ВидОперации", ВидОперации) Тогда
		
		ПараметрыПодбора.Вставить("ВидОперации", ВидОперации);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрВалютаДокумента(ФормаВладелец, ПараметрыПодбора)
	
	Если ФормаВладелец.Объект.Свойство("ВалютаДокумента") Тогда
		
		ПараметрыПодбора.Вставить("ВалютаДокумента", ФормаВладелец.Объект.ВалютаДокумента);
		
	Иначе
		
		ПараметрыПодбора.Вставить("ВалютаДокумента", Неопределено);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрСтруктурнаяЕдиница(ФормаВладелец, ПараметрыПодбора)
	Перем СтруктурнаяЕдиница;
	
	Если СтрНайти(ФормаВладелец.ИмяФормы, "ЗаказПокупателя") > 0 
		ИЛИ СтрНайти(ФормаВладелец.ИмяФормы, "ЗаказПоставщику") > 0 Тогда
		
		ФормаВладелец.ЭтотОбъект.Объект.Свойство("СтруктурнаяЕдиницаРезерв", СтруктурнаяЕдиница);
		ПараметрыПодбора.Вставить("СтруктурнаяЕдиница", СтруктурнаяЕдиница);
		
	ИначеЕсли ФормаВладелец.ИмяФормы = "Документ.ПеремещениеЗапасов.Форма.ФормаДокумента" Тогда
		
		ФормаВладелец.ЭтотОбъект.Объект.Свойство("СтруктурнаяЕдиница", СтруктурнаяЕдиница);
		ПараметрыПодбора.Вставить("СтруктурнаяЕдиницаОтправитель", СтруктурнаяЕдиница);
		
		ФормаВладелец.ЭтотОбъект.Объект.Свойство("СтруктурнаяЕдиницаПолучатель", СтруктурнаяЕдиница);
		ПараметрыПодбора.Вставить("СтруктурнаяЕдиницаПолучатель", СтруктурнаяЕдиница);
		
	Иначе
		
		ФормаВладелец.ЭтотОбъект.Объект.Свойство("СтруктурнаяЕдиница", СтруктурнаяЕдиница);
		ПараметрыПодбора.Вставить("СтруктурнаяЕдиница", СтруктурнаяЕдиница);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрыНалогооблаженияДокумента(ФормаВладелец, ПараметрыПодбора)
	
	Если ФормаВладелец.ИмяФормы = "Документ.СчетФактура.Форма.ФормаДокумента" 
		ИЛИ ФормаВладелец.ИмяФормы = "Документ.СчетФактураПолученный.Форма.ФормаДокумента" Тогда
		
		ПараметрыПодбора.Вставить("НалогообложениеНДС", ПредопределенноеЗначение("Перечисление.ТипыНалогообложенияНДС.ОблагаетсяНДС"));
		ПараметрыПодбора.Вставить("СуммаВключаетНДС", Ложь);
		
	ИначеЕсли ФормаВладелец.ИмяФормы = "Документ.ПеремещениеЗапасов.Форма.ФормаДокумента"
		ИЛИ ФормаВладелец.ИмяФормы = "Документ.ПересортицаЗапасов.Форма.ФормаДокумента" Тогда 
		// Для перемещения не требуется заполнение реквизита
		
	Иначе
		
		ПараметрыПодбора.Вставить("НалогообложениеНДС", ФормаВладелец.ЭтотОбъект.Объект.НалогообложениеНДС);
		ПараметрыПодбора.Вставить("СуммаВключаетНДС", ФормаВладелец.ЭтотОбъект.Объект.СуммаВключаетНДС);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьТипыНоменклатуры(ФормаВладелец, ИмяТабличнойЧасти, ПараметрыПодбора)
	
	ТипНоменклатуры = Новый СписокЗначений;
	
	Для каждого ЭлементМассива Из ФормаВладелец.Элементы[ИмяТабличнойЧасти + "Номенклатура"].ПараметрыВыбора Цикл
		
		Если ЭлементМассива.Имя = "Отбор.ТипНоменклатуры" Тогда
			
			Если ТипЗнч(ЭлементМассива.Значение) = Тип("ФиксированныйМассив") Тогда
				
				Для каждого ЭлементФиксМассива Из ЭлементМассива.Значение Цикл
					
					ТипНоменклатуры.Добавить(ЭлементФиксМассива);
					
				КонецЦикла; 
				
			Иначе
				
				ТипНоменклатуры.Добавить(ЭлементМассива.Значение);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ПараметрыПодбора.Вставить("ТипНоменклатуры", ТипНоменклатуры);
	
КонецПроцедуры

Процедура ЗаполнитьВидыЦен(ФормаВладелец, ПолноеИмяФормыПодбора, ПараметрыПодбора)
	
	Если ПолноеИмяФормыПодбора = "Обработка.ПодборПоступление.Форма.КорзинаЦенаОстатокРезервХарактеристика" Тогда
	// Вид цен для поступления
		
		Если ФормаВладелец.ИмяФормы = "Документ.СчетФактураПолученный.Форма.ФормаДокумента" Тогда
		// Определение видов цен для вход. документов без явного реквизита ВидыЦенКонтрагента
			
			ВидЦенКонтрагента = ПодборНоменклатурыВДокументахПереопределяемый.ВидЦенСчетФактуры(ФормаВладелец.ЭтотОбъект.Объект.Контрагент, ФормаВладелец.ЭтотОбъект.Объект.Договор, Истина);
			ПараметрыПодбора.Вставить("ВидЦенКонтрагента", ВидЦенКонтрагента);
			
		Иначе
			
			ПараметрыПодбора.Вставить("ВидЦенКонтрагента", ФормаВладелец.ЭтотОбъект.Объект.ВидЦенКонтрагента);
			
		КонецЕсли;
		
	ИначеЕсли ПолноеИмяФормыПодбора = "Обработка.ПодборРеализация.Форма.КорзинаЦенаОстатокРезервХарактеристика" Тогда
	// Вид цен для реализации
		
		Если ФормаВладелец.ИмяФормы = "Документ.СчетФактура.Форма.ФормаДокумента" Тогда
			
			ВидЦен = ПодборНоменклатурыВДокументахПереопределяемый.ВидЦенСчетФактуры(ФормаВладелец.ЭтотОбъект.Объект.Контрагент, ФормаВладелец.ЭтотОбъект.Объект.Договор, Ложь);
			ПараметрыПодбора.Вставить("ВидЦен", ВидЦен);
			
		Иначе
			
			ПараметрыПодбора.Вставить("ВидЦен", ФормаВладелец.ЭтотОбъект.Объект.ВидЦен);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьВидСкидкиНаценки(ФормаВладелец, ПолноеИмяФормыПодбора, ПараметрыПодбора)
	
	СкидкиНаценкиВидны = Ложь;
	Если ПолноеИмяФормыПодбора = "Обработка.ПодборРеализация.Форма.КорзинаЦенаОстатокРезервХарактеристика" Тогда
		
		Если ФормаВладелец.ЭтотОбъект.Объект.Свойство("ВидСкидкиНаценки") Тогда
			
			ПараметрыПодбора.Вставить("ВидСкидкиНаценки", ФормаВладелец.ЭтотОбъект.Объект.ВидСкидкиНаценки);
			СкидкиНаценкиВидны = Истина;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ПараметрыПодбора.Вставить("СкидкиНаценкиВидны", СкидкиНаценкиВидны);
	
КонецПроцедуры

Процедура ЗаполнитьДополнительныеПараметры(ФормаВладелец, ПараметрыПодбора)
	
	Если ФормаВладелец.ИмяФормы = "Документ.ЧекККМ.Форма.ФормаДокумента" 
		ИЛИ ФормаВладелец.ИмяФормы = "Документ.ЧекККМ.Форма.ФормаДокумента_РМК" Тогда
		
		ПараметрыПодбора.Вставить("ЭтоЧекККМ", Истина);
		
	ИначеЕсли (ФормаВладелец.ИмяФормы = "Документ.ПриходнаяНакладная.Форма.ФормаДокумента"
		И ФормаВладелец.Объект.ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийПриходнаяНакладная.ВозвратОтПокупателя"))
		ИЛИ (ФормаВладелец.ИмяФормы = "Документ.РасходнаяНакладная.Форма.ФормаДокумента"
		И ФормаВладелец.Объект.ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийРасходнаяНакладная.ВозвратПоставщику")) Тогда
		
		ПараметрыПодбора.Вставить("ЭтоВозврат", Истина);
		
	КонецЕсли;
	
КонецПроцедуры

#Область ДисконтныеКарты

Процедура ЗаполнитьДисконтнуюКарту(ФормаВладелец, ПолноеИмяФормыПодбора, ПараметрыПодбора)
	
	ДисконтнаяКартаВидна = Ложь;
	Если ПолноеИмяФормыПодбора = "Обработка.ПодборРеализация.Форма.КорзинаЦенаОстатокРезервХарактеристика" Тогда
		
		ТекОбъект = ФормаВладелец.ЭтотОбъект.Объект;
		Если ТекОбъект.Свойство("ДисконтнаяКарта") Тогда
			
			ДисконтнаяКартаВидна = Истина;
			Если ТипЗнч(ТекОбъект) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
				Если ТекОбъект.ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийЗаказПокупателя.ЗаказНаПереработку") Тогда
					ДисконтнаяКартаВидна = Ложь;
				КонецЕсли;
			ИначеЕсли ТипЗнч(ТекОбъект) = Тип("ДокументСсылка.РасходнаяНакладная") Тогда
				Если ТекОбъект.ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийРасходнаяНакладная.ПродажаПокупателю") Тогда
					ДисконтнаяКартаВидна = Ложь;
				КонецЕсли;
			КонецЕсли;
			
			Если ДисконтнаяКартаВидна = Истина Тогда
				ПараметрыПодбора.Вставить("ДисконтнаяКарта", ФормаВладелец.ЭтотОбъект.Объект.ДисконтнаяКарта);
				ПараметрыПодбора.Вставить("ПроцентСкидкиПоДисконтнойКарте", ФормаВладелец.ЭтотОбъект.Объект.ПроцентСкидкиПоДисконтнойКарте);			
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ПараметрыПодбора.Вставить("ДисконтнаяКартаВидна", ДисконтнаяКартаВидна);
	
КонецПроцедуры

#КонецОбласти

// Конец Получение данных из форм-владельцев
