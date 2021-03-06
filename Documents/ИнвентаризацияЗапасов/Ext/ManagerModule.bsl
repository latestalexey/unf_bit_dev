﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ИнтерфейсПечати

// Процедура формирует и выводит печатную форму документа по указанному макету.
//
// Параметры:
//	ТабличныйДокумент - ТабличныйДокумент в который будет выводится печатная
//				   форма.
//  ИмяМакета    - Строка, имя макета печатной формы.
//
Функция ПечатнаяФорма(МассивОбъектов, ОбъектыПечати, ИмяМакета)
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	
	ПервыйДокумент = Истина;
	
	Для Каждого ТекущийДокумент Из МассивОбъектов Цикл
	
		Если Не ПервыйДокумент Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		ПервыйДокумент = Ложь;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		Если ИмяМакета = "БланкТоварногоНаполнения" Тогда
			
			Запрос = Новый Запрос();
			Запрос.УстановитьПараметр("ТекущийДокумент", ТекущийДокумент);
			Запрос.Текст = 
			"ВЫБРАТЬ
			|	ИнвентаризацияЗапасов.Дата КАК ДатаДокумента,
			|	ИнвентаризацияЗапасов.СтруктурнаяЕдиница КАК ПредставлениеСклада,
			|	ИнвентаризацияЗапасов.Ячейка КАК ПредставлениеЯчейки,
			|	ИнвентаризацияЗапасов.Номер,
			|	ИнвентаризацияЗапасов.Организация.Префикс КАК Префикс,
			|	ИнвентаризацияЗапасов.Запасы.(
			|		НомерСтроки КАК НомерСтроки,
			|		Номенклатура.Склад КАК Склад,
			|		Номенклатура.Ячейка КАК Ячейка,
			|		ВЫБОР
			|			КОГДА (ВЫРАЗИТЬ(ИнвентаризацияЗапасов.Запасы.Номенклатура.НаименованиеПолное КАК СТРОКА(100))) = """"
			|				ТОГДА ИнвентаризацияЗапасов.Запасы.Номенклатура.Наименование
			|			ИНАЧЕ ИнвентаризацияЗапасов.Запасы.Номенклатура.НаименованиеПолное
			|		КОНЕЦ КАК Запас,
			|		Номенклатура.Артикул КАК Артикул,
			|		Номенклатура.Код КАК Код,
			|		ЕдиницаИзмерения.Наименование КАК ЕдиницаИзмерения,
			|		Количество КАК Количество,
			|		Характеристика,
			|		Номенклатура.ТипНоменклатуры КАК ТипНоменклатуры,
			|		КлючСвязи
			|	),
			|	ИнвентаризацияЗапасов.СерийныеНомера.(
			|		СерийныйНомер,
			|		КлючСвязи
			|	)
			|ИЗ
			|	Документ.ИнвентаризацияЗапасов КАК ИнвентаризацияЗапасов
			|ГДЕ
			|	ИнвентаризацияЗапасов.Ссылка = &ТекущийДокумент
			|
			|УПОРЯДОЧИТЬ ПО
			|	НомерСтроки";
			
			Шапка = Запрос.Выполнить().Выбрать();
			Шапка.Следующий();
			
			ВыборкаСтрокЗапасы = Шапка.Запасы.Выбрать();
			ВыборкаСтрокСерийныеНомера = Шапка.СерийныеНомера.Выбрать();

			ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ИнвентаризацияЗапасов_БланкТоварногоНаполнения";
			
			Макет = УправлениеПечатью.МакетПечатнойФормы("Документ.ИнвентаризацияЗапасов.ПФ_MXL_БланкТоварногоНаполнения");
			
			Если Шапка.ДатаДокумента < Дата('20110101') Тогда
				НомерДокумента = УправлениеНебольшойФирмойСервер.ПолучитьНомерНаПечать(Шапка.Номер, Шапка.Префикс);
			Иначе
				НомерДокумента = ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(Шапка.Номер, Истина, Истина);
			КонецЕсли;
			
			ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
			ОбластьМакета.Параметры.ТекстЗаголовка = "Инвентаризация запасов № "
			+ НомерДокумента
			+ " от "
			+ Формат(Шапка.ДатаДокумента, "ДЛФ=DD");
			
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			ОбластьМакета = Макет.ПолучитьОбласть("Склад");
			ОбластьМакета.Параметры.ПредставлениеСклада = Шапка.ПредставлениеСклада;
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			Если Константы.ФункциональнаяОпцияУчетПоЯчейкам.Получить() Тогда
				
				ОбластьМакета = Макет.ПолучитьОбласть("Ячейка");
				ОбластьМакета.Параметры.ПредставлениеЯчейки = Шапка.ПредставлениеЯчейки;
				ТабличныйДокумент.Вывести(ОбластьМакета);
				
			КонецЕсли;
			
			ОбластьМакета = Макет.ПолучитьОбласть("ВремяПечати");
			ОбластьМакета.Параметры.ВремяПечати = "Дата и время печати: "
			+ ТекущаяДата()
			+ ". Пользователь: "
			+ Пользователи.ТекущийПользователь();
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
			ТабличныйДокумент.Вывести(ОбластьМакета);			
			ОбластьМакета = Макет.ПолучитьОбласть("Строка");
			
			Пока ВыборкаСтрокЗапасы.Следующий() Цикл
				
				Если НЕ ВыборкаСтрокЗапасы.ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Запас Тогда
					Продолжить;
				КонецЕсли;
				
				ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокЗапасы);
				
				СтрокаСерийныеНомера = РаботаССерийнымиНомерами.СтрокаСерийныеНомераИзВыборки(ВыборкаСтрокСерийныеНомера, ВыборкаСтрокЗапасы.КлючСвязи);
				ОбластьМакета.Параметры.Запас = УправлениеНебольшойФирмойСервер.ПолучитьПредставлениеНоменклатурыДляПечати(ВыборкаСтрокЗапасы.Запас, 
					ВыборкаСтрокЗапасы.Характеристика, ВыборкаСтрокЗапасы.Артикул, СтрокаСерийныеНомера);
				
				ТабличныйДокумент.Вывести(ОбластьМакета);
				
			КонецЦикла;
			
			ОбластьМакета = Макет.ПолучитьОбласть("Итого");
			ТабличныйДокумент.Вывести(ОбластьМакета);	
			
		ИначеЕсли ИмяМакета = "ИНВ3" ИЛИ ИмяМакета = "ИНВ3БезФактическихДанных" Тогда
			
			ВалютаПечати = Константы.НациональнаяВалюта.Получить();
			
			Запрос = Новый Запрос;
			Запрос.УстановитьПараметр("ТекущийДокумент", ТекущийДокумент);
			Запрос.УстановитьПараметр("Дата", ТекущийДокумент.Дата);
			Запрос.Текст =
			"ВЫБРАТЬ
			|	ИнвентаризацияЗапасов.Номер КАК Номер,
			|	ИнвентаризацияЗапасов.Дата КАК ДатаДокумента,
			|	ИнвентаризацияЗапасов.Дата КАК ДатаНачалаИнвентаризации,
			|	ИнвентаризацияЗапасов.Дата КАК ДатаОкончанияИнвентаризации,
			|	ИнвентаризацияЗапасов.СтруктурнаяЕдиница.МОЛ КАК ОтветственноеЛицо,
			|	ИнвентаризацияЗапасов.Организация,
			|	ИнвентаризацияЗапасов.СтруктурнаяЕдиница.Представление КАК Подразделение,
			|	ИнвентаризацияЗапасов.Организация.Префикс КАК Префикс,
			|	ИнвентаризацияЗапасов.Запасы.(
			|		НомерСтроки КАК Номер,
			|		Номенклатура,
			|		ВЫБОР
			|			КОГДА (ВЫРАЗИТЬ(ИнвентаризацияЗапасов.Запасы.Номенклатура.НаименованиеПолное КАК СТРОКА(1000))) = """"
			|				ТОГДА ИнвентаризацияЗапасов.Запасы.Номенклатура.Наименование
			|			ИНАЧЕ ВЫРАЗИТЬ(ИнвентаризацияЗапасов.Запасы.Номенклатура.НаименованиеПолное КАК СТРОКА(1000))
			|		КОНЕЦ КАК ТоварНаименование,
			|		Характеристика,
			|		Номенклатура.Артикул КАК Артикул,
			|		Номенклатура.Код КАК ТоварКод,
			|		Номенклатура.ЕдиницаИзмерения.Наименование КАК ЕдиницаИзмеренияНаименование,
			|		Номенклатура.ЕдиницаИзмерения.Код КАК ЕдиницаИзмеренияКодПоОКЕИ,
			|		Номенклатура.СчетУчетаЗапасов.Код КАК СубСчет,
			|		ВЫРАЗИТЬ(ВЫБОР
			|				КОГДА Константы.ВалютаУчета = Константы.НациональнаяВалюта
			|					ТОГДА ИнвентаризацияЗапасов.Запасы.Цена
			|				ИНАЧЕ ИнвентаризацияЗапасов.Запасы.Цена * КурсыУпрВалюты.Курс / КурсыУпрВалюты.Кратность
			|			КОНЕЦ КАК ЧИСЛО(15, 2)) КАК Цена,
			|		Количество КАК ФактКоличество,
			|		КоличествоУчет КАК БухКоличество,
			|		ВЫРАЗИТЬ(ВЫБОР
			|				КОГДА Константы.ВалютаУчета = Константы.НациональнаяВалюта
			|					ТОГДА ИнвентаризацияЗапасов.Запасы.Сумма
			|				ИНАЧЕ ИнвентаризацияЗапасов.Запасы.Сумма * КурсыУпрВалюты.Курс / КурсыУпрВалюты.Кратность
			|			КОНЕЦ КАК ЧИСЛО(15, 2)) КАК ФактСумма,
			|		ВЫРАЗИТЬ(ВЫБОР
			|				КОГДА Константы.ВалютаУчета = Константы.НациональнаяВалюта
			|					ТОГДА ИнвентаризацияЗапасов.Запасы.СуммаУчет
			|				ИНАЧЕ ИнвентаризацияЗапасов.Запасы.СуммаУчет * КурсыУпрВалюты.Курс / КурсыУпрВалюты.Кратность
			|			КОНЕЦ КАК ЧИСЛО(15, 2)) КАК БухСумма
			|	)
			|ИЗ
			|	Документ.ИнвентаризацияЗапасов КАК ИнвентаризацияЗапасов
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(
			|				&Дата,
			|				Валюта В
			|					(ВЫБРАТЬ
			|						КонстантаВалютаУчета.Значение
			|					ИЗ
			|						Константа.ВалютаУчета КАК КонстантаВалютаУчета)) КАК КурсыУпрВалюты
			|		ПО (ИСТИНА),
			|	Константы КАК Константы
			|ГДЕ
			|	ИнвентаризацияЗапасов.Ссылка = &ТекущийДокумент
			|
			|УПОРЯДОЧИТЬ ПО
			|	ИнвентаризацияЗапасов.Запасы.НомерСтроки";
			Шапка = Запрос.Выполнить().Выбрать();
			
			Шапка.Следующий();
			
			ВыборкаСтрокТовары = Шапка.Запасы.Выбрать();
			
			// Зададим параметры макета по умолчанию
			ТабличныйДокумент.ПолеСверху              = 10;
			ТабличныйДокумент.ПолеСлева               = 0;
			ТабличныйДокумент.ПолеСнизу               = 0;
			ТабличныйДокумент.ПолеСправа              = 0;
			ТабличныйДокумент.РазмерКолонтитулаСверху = 10;
			ТабличныйДокумент.ОриентацияСтраницы      = ОриентацияСтраницы.Ландшафт;
			
			ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ИнвентаризацияЗапасов_ИНВ3";
			Макет       = УправлениеПечатью.МакетПечатнойФормы("Документ.ИнвентаризацияЗапасов.ПФ_MXL_ИНВ3");
			
			//////////////////////////////////////////////////////////////////////
			// 1-я страница формы
			
			// Выводим шапку накладной
			ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
			ОбластьМакета.Параметры.Заполнить(Шапка);
			
			СведенияОбОрганизации = УправлениеНебольшойФирмойСервер.СведенияОЮрФизЛице(Шапка.Организация, Шапка.ДатаДокумента);
			ПредставлениеОрганизации = УправлениеНебольшойФирмойСервер.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование,");
			ОбластьМакета.Параметры.ПредставлениеОрганизации = ПредставлениеОрганизации;
			
			Если Шапка.ДатаДокумента < Дата('20110101') Тогда
				НомерДокумента = УправлениеНебольшойФирмойСервер.ПолучитьНомерНаПечать(Шапка.Номер, Шапка.Префикс);
			Иначе
				НомерДокумента = ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(Шапка.Номер, Истина, Истина);
			КонецЕсли;		
			
			ОбластьМакета.Параметры.ОрганизацияПоОКПО        = СведенияОбОрганизации.КодПоОКПО;
			ОбластьМакета.Параметры.ДатаДокумента            = Шапка.ДатаДокумента;
			ОбластьМакета.Параметры.НомерДокумента           = НомерДокумента;
			ОбластьМакета.Параметры.ДатаОкончанияИнвентаризацииЛокальныйФормат = Шапка.ДатаОкончанияИнвентаризации; 
			
			ДанныеМОЛ = УправлениеНебольшойФирмойСервер.ДанныеФизЛица(Шапка.Организация, Шапка.ОтветственноеЛицо, Шапка.ДатаДокумента);
			ОбластьМакета.Параметры.ДолжностьМОЛ1     = ДанныеМОЛ.Должность;
			ОбластьМакета.Параметры.ФИОМОЛ1           = ДанныеМОЛ.Представление;	
			
			ТабличныйДокумент.Вывести(ОбластьМакета);
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			
			//////////////////////////////////////////////////////////////////////
			// 2-я страница формы
			
			ИтогФактКоличество = 0;
			ИтогФактСумма      = 0;
			ИтогФактСуммаВсего = 0;
			ИтогБухКоличество  = 0;
			ИтогБухСумма       = 0;
			
			КолвоСтрокПоСтранице = 0;
			КолвоПоСтранице      = 0;
			СуммаЛиста           = 0;
			ИтогоКолво           = 0;
			
			НомерСтраницы = 2;
			Ном = 0;
			
			// Выводим заголовок таблицы
			ЗаголовокТаблицы = Макет.ПолучитьОбласть("ЗаголовокТаблицы");
			ЗаголовокТаблицы.Параметры.НомерСтраницы = "Страница " + НомерСтраницы; 
			ТабличныйДокумент.Вывести(ЗаголовокТаблицы);
			
			// Выводим многострочную часть документа
			ПодвалСтраницы  = Макет.ПолучитьОбласть("ПодвалСтраницы");	
			
			Пока ВыборкаСтрокТовары.Следующий() Цикл
				
				Ном = Ном + 1;
				СтрокаТаблицы   = Макет.ПолучитьОбласть("Строка");
				СтрокаТаблицы.Параметры.Заполнить(ВыборкаСтрокТовары);
				СтрокаТаблицы.Параметры.ТоварНаименование = УправлениеНебольшойФирмойСервер.ПолучитьПредставлениеНоменклатурыДляПечати(ВыборкаСтрокТовары.ТоварНаименование, 
				ВыборкаСтрокТовары.Характеристика, ВыборкаСтрокТовары.Артикул);
				
				Если ИмяМакета = "ИНВ3БезФактическихДанных" Тогда
					СтрокаТаблицы.Параметры.ФактКоличество = "";
					СтрокаТаблицы.Параметры.ФактСумма = "";	
				КонецЕсли;
				
				СтрокаСПодвалом = Новый Массив;
				СтрокаСПодвалом.Добавить(СтрокаТаблицы);
				СтрокаСПодвалом.Добавить(ПодвалСтраницы);
				
				Если НЕ ТабличныйДокумент.ПроверитьВывод(СтрокаСПодвалом) Тогда
					
					ОбластьИтоговПоСтранице = Макет.ПолучитьОбласть("ПодвалСтраницы");
					
					Если ИмяМакета = "ИНВ3" Тогда
						ОбластьИтоговПоСтранице.Параметры.ИтогоФактКоличество = ИтогФактКоличество;
						ОбластьИтоговПоСтранице.Параметры.ИтогоФактСумма      = ИтогФактСумма;	
					КонецЕсли;
					ОбластьИтоговПоСтранице.Параметры.ИтогоБухКоличество  = ИтогБухКоличество;
					ОбластьИтоговПоСтранице.Параметры.ИтогоБухСумма       = ИтогБухСумма;
					
					ОбластьИтоговПоСтранице.Параметры.КоличествоПорядковыхНомеровНаСтраницеПрописью     = ЧислоПрописью(КолвоСтрокПоСтранице, ,",,,,,,,,0");
					Если ИмяМакета = "ИНВ3" Тогда
						ОбластьИтоговПоСтранице.Параметры.ОбщееКоличествоЕдиницФактическиНаСтраницеПрописью = УправлениеНебольшойФирмойСервер.КоличествоПрописью(КолвоПоСтранице);
						ОбластьИтоговПоСтранице.Параметры.СуммаФактическиНаСтраницеПрописью                 = РаботаСКурсамиВалют.СформироватьСуммуПрописью(СуммаЛиста, ВалютаПечати);	
					КонецЕсли;
					
					ТабличныйДокумент.Вывести(ОбластьИтоговПоСтранице);
					
					НомерСтраницы = НомерСтраницы + 1;
					ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
					
					ЗаголовокТаблицы.Параметры.НомерСтраницы = "Страница " + НомерСтраницы;
					ТабличныйДокумент.Вывести(ЗаголовокТаблицы);
					
					ИтогФактКоличество = 0;
					ИтогФактСумма      = 0;
					ИтогБухКоличество  = 0;
					ИтогБухСумма       = 0;
					
					КолвоСтрокПоСтранице = 0;
					КолвоПоСтранице      = 0;
					СуммаЛиста           = 0;
					
				КонецЕсли;
				
				СтрокаТаблицы.Параметры.Номер = Ном;
				
				ТабличныйДокумент.Вывести(СтрокаТаблицы);
				
				Если ИмяМакета = "ИНВ3" Тогда
					ИтогФактКоличество = ИтогФактКоличество + ВыборкаСтрокТовары.ФактКоличество;
					ИтогФактСумма      = ИтогФактСумма      + ВыборкаСтрокТовары.ФактСумма;
					ИтогФактСуммаВсего = ИтогФактСуммаВсего + ВыборкаСтрокТовары.ФактСумма;
				КонецЕсли;
				ИтогБухКоличество  = ИтогБухКоличество  + ВыборкаСтрокТовары.БухКоличество;
				ИтогБухСумма       = ИтогБухСумма       + ВыборкаСтрокТовары.БухСумма;
				ИтогоКолво         = ИтогоКолво         + ВыборкаСтрокТовары.ФактКоличество;
				
				КолвоСтрокПоСтранице = КолвоСтрокПоСтранице + 1;
				КолвоПоСтранице      = КолвоПоСтранице      + ВыборкаСтрокТовары.ФактКоличество;
				СуммаЛиста           = СуммаЛиста           + ВыборкаСтрокТовары.ФактСумма;
				
			КонецЦикла;
			
			// Выводим итоги по последней странице
			ОбластьИтоговПоСтранице = Макет.ПолучитьОбласть("ПодвалСтраницы");
			
			Если ИмяМакета = "ИНВ3" Тогда
				ОбластьИтоговПоСтранице.Параметры.ИтогоФактКоличество  = ИтогФактКоличество;
				ОбластьИтоговПоСтранице.Параметры.ИтогоФактСумма       = ИтогФактСумма;
				ОбластьИтоговПоСтранице.Параметры.ОбщееКоличествоЕдиницФактическиНаСтраницеПрописью = УправлениеНебольшойФирмойСервер.КоличествоПрописью(КолвоПоСтранице);
				ОбластьИтоговПоСтранице.Параметры.СуммаФактическиНаСтраницеПрописью                 = РаботаСКурсамиВалют.СформироватьСуммуПрописью(СуммаЛиста, ВалютаПечати);
			КонецЕсли;
			ОбластьИтоговПоСтранице.Параметры.ИтогоБухКоличество   = ИтогБухКоличество;
			ОбластьИтоговПоСтранице.Параметры.ИтогоБухСумма        = ИтогБухСумма;
			ОбластьИтоговПоСтранице.Параметры.КоличествоПорядковыхНомеровНаСтраницеПрописью     = ЧислоПрописью(КолвоСтрокПоСтранице, ,",,,,,,,,0");
			ТабличныйДокумент.Вывести(ОбластьИтоговПоСтранице);
			
			// Выводим подвал документа
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			ОбластьМакета = Макет.ПолучитьОбласть("ПодвалОписи");
			ОбластьМакета.Параметры.Заполнить(Шапка);
			Если ИмяМакета = "ИНВ3" Тогда
				ОбластьМакета.Параметры.ОбщееКоличествоЕдиницФактическиНаСтраницеПрописью = УправлениеНебольшойФирмойСервер.КоличествоПрописью(ИтогоКолво);
				ОбластьМакета.Параметры.СуммаФактическиНаСтраницеПрописью                 = РаботаСКурсамиВалют.СформироватьСуммуПрописью(ИтогФактСуммаВсего, ВалютаПечати);
			КонецЕсли;
			ОбластьМакета.Параметры.КоличествоПорядковыхНомеровНаСтраницеПрописью     = ЧислоПрописью(ВыборкаСтрокТовары.Количество(), ,",,,,,,,,0");
			
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			ОбластьМакета = Макет.ПолучитьОбласть("ПодвалОписиМОЛ");
			ОбластьМакета.Параметры.Заполнить(Шапка);
			ОбластьМакета.Параметры.НачальныйНомерПоПорядку = 1;
			ОбластьМакета.Параметры.НомерКонца              = ВыборкаСтрокТовары.Количество();
			
			ОбластьМакета.Параметры.ДолжностьМОЛ1   = ДанныеМОЛ.Должность;
			ОбластьМакета.Параметры.ФИОМОЛ1         = ДанныеМОЛ.Представление;
			
			ОбластьМакета.Параметры.ДатаДокумента 	= Шапка.ДатаДокумента;
			
			ТабличныйДокумент.Вывести(ОбластьМакета);	
			
		ИначеЕсли ИмяМакета = "ИНВ19" Или ИмяМакета = "ИНВ19_УчетныеЦены" Тогда
			
			ВалютаПечати = Константы.НациональнаяВалюта.Получить();

			Запрос       = Новый Запрос;
			Запрос.УстановитьПараметр("ТекущийДокумент", ТекущийДокумент);
			Запрос.УстановитьПараметр("Дата", ТекущийДокумент.Дата);
			Запрос.Текст =
			"ВЫБРАТЬ
			|	ИнвентаризацияЗапасов.Номер КАК Номер,
			|	ИнвентаризацияЗапасов.Дата КАК ДатаДокумента,
			|	ИнвентаризацияЗапасов.Дата КАК ДатаНачалаИнвентаризации,
			|	ИнвентаризацияЗапасов.Дата КАК ДатаОкончанияИнвентаризации,
			|	ИнвентаризацияЗапасов.СтруктурнаяЕдиница.МОЛ КАК ОтветственноеЛицо,
			|	ИнвентаризацияЗапасов.Организация,
			|	ИнвентаризацияЗапасов.Организация КАК Руководители,
			|	ИнвентаризацияЗапасов.СтруктурнаяЕдиница.Представление КАК ПредставлениеПодразделения,
			|	ИнвентаризацияЗапасов.Организация.Префикс КАК Префикс,
			|	ИнвентаризацияЗапасов.Запасы.(
			|		НомерСтроки КАК Номер,
			|		Номенклатура,
			|		ВЫБОР
			|			КОГДА (ВЫРАЗИТЬ(ИнвентаризацияЗапасов.Запасы.Номенклатура.НаименованиеПолное КАК СТРОКА(1000))) = """"
			|				ТОГДА ИнвентаризацияЗапасов.Запасы.Номенклатура.Наименование
			|			ИНАЧЕ ВЫРАЗИТЬ(ИнвентаризацияЗапасов.Запасы.Номенклатура.НаименованиеПолное КАК СТРОКА(1000))
			|		КОНЕЦ КАК ТоварНаименование,
			|		Характеристика,
			|		Номенклатура.Артикул КАК Артикул,
			|		Номенклатура.Код КАК ТоварКод,
			|		Номенклатура.ЕдиницаИзмерения.Представление КАК ЕдиницаИзмеренияНаименование,
			|		Номенклатура.ЕдиницаИзмерения.Код КАК ЕдиницаИзмеренияКодПоОКЕИ,
			|		ВЫРАЗИТЬ(ВЫБОР
			|				КОГДА Константы.ВалютаУчета = Константы.НациональнаяВалюта
			|					ТОГДА ИнвентаризацияЗапасов.Запасы.Цена
			|				ИНАЧЕ ИнвентаризацияЗапасов.Запасы.Цена * КурсыУпрВалюты.Курс / КурсыУпрВалюты.Кратность
			|			КОНЕЦ КАК ЧИСЛО(15, 2)) КАК Цена,
			|		Количество КАК ФактКоличество,
			|		КоличествоУчет КАК БухКоличество,
			|		ВЫРАЗИТЬ(ВЫБОР
			|				КОГДА Константы.ВалютаУчета = Константы.НациональнаяВалюта
			|					ТОГДА ИнвентаризацияЗапасов.Запасы.Сумма
			|				ИНАЧЕ ИнвентаризацияЗапасов.Запасы.Сумма * КурсыУпрВалюты.Курс / КурсыУпрВалюты.Кратность
			|			КОНЕЦ КАК ЧИСЛО(15, 2)) КАК ФактСумма,
			|		ВЫРАЗИТЬ(ВЫБОР
			|				КОГДА Константы.ВалютаУчета = Константы.НациональнаяВалюта
			|					ТОГДА ИнвентаризацияЗапасов.Запасы.СуммаУчет
			|				ИНАЧЕ ИнвентаризацияЗапасов.Запасы.СуммаУчет * КурсыУпрВалюты.Курс / КурсыУпрВалюты.Кратность
			|			КОНЕЦ КАК ЧИСЛО(15, 2)) КАК БухСумма
			|	)
			|ИЗ
			|	Документ.ИнвентаризацияЗапасов КАК ИнвентаризацияЗапасов
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(
			|				&Дата,
			|				Валюта В
			|					(ВЫБРАТЬ
			|						КонстантаВалютаУчета.Значение
			|					ИЗ
			|						Константа.ВалютаУчета КАК КонстантаВалютаУчета)) КАК КурсыУпрВалюты
			|		ПО (ИСТИНА),
			|	Константы КАК Константы
			|ГДЕ
			|	ИнвентаризацияЗапасов.Ссылка = &ТекущийДокумент
			|
			|УПОРЯДОЧИТЬ ПО
			|	ИнвентаризацияЗапасов.Запасы.НомерСтроки";

			Шапка = Запрос.Выполнить().Выбрать();
			Шапка.Следующий();
			ВыборкаСтрокТовары = Шапка.Запасы.Выбрать();

			// Параметры печати.
			ТабличныйДокумент.ПолеСверху = 0;
			ТабличныйДокумент.ПолеСлева  = 0;
			ТабличныйДокумент.ПолеСнизу  = 0;
			ТабличныйДокумент.ПолеСправа = 0;
			ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
			
			ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ИнвентаризацияЗапасов_ИНВ19";
			
			// Получение областей макета.
			Макет = УправлениеПечатью.МакетПечатнойФормы("Документ.ИнвентаризацияЗапасов.ПФ_MXL_ИНВ19");
			
			ОбластьМакетаШапка            = Макет.ПолучитьОбласть("Шапка");
			ОбластьМакетаЗаголовокТаблицы = Макет.ПолучитьОбласть("ЗаголовокТаблицы1");
			ОбластьМакетаСтрока           = Макет.ПолучитьОбласть("СтрокаТаблицы1");
			ОбластьМакетаИтогоПоСтранице  = Макет.ПолучитьОбласть("ИтогоТаблицы1");
			ОбластьМакетаПодвал           = Макет.ПолучитьОбласть("Подвал");

			// Вывод шапки документа.
			ОбластьМакетаШапка.Параметры.Заполнить(Шапка);
			
			СведенияОбОрганизации = УправлениеНебольшойФирмойСервер.СведенияОЮрФизЛице(Шапка.Организация, Шапка.ДатаДокумента);
			ПредставлениеОрганизации = УправлениеНебольшойФирмойСервер.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование,");
			ОбластьМакетаШапка.Параметры.ПредставлениеОрганизации = ПредставлениеОрганизации;
			
			Если Шапка.ДатаДокумента < Дата('20110101') Тогда
				НомерДокумента = УправлениеНебольшойФирмойСервер.ПолучитьНомерНаПечать(Шапка.Номер, Шапка.Префикс);
			Иначе
				НомерДокумента = ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(Шапка.Номер, Истина, Истина);
			КонецЕсли;		
			
			ОбластьМакетаШапка.Параметры.ОрганизацияПоОКПО        = СведенияОбОрганизации.КодПоОКПО;
			ОбластьМакетаШапка.Параметры.ДатаДокумента            = Шапка.ДатаДокумента;
			ОбластьМакетаШапка.Параметры.ДатаНачалаИнвентаризации = Шапка.ДатаНачалаИнвентаризации;
			ОбластьМакетаШапка.Параметры.НомерДокумента           = НомерДокумента;
			
			ДанныеМОЛ = УправлениеНебольшойФирмойСервер.ДанныеФизЛица(Шапка.Организация, Шапка.ОтветственноеЛицо, Шапка.ДатаДокумента);
			ОбластьМакетаШапка.Параметры.ДолжностьМОЛ1     = ДанныеМОЛ.Должность;
			ОбластьМакетаШапка.Параметры.ФИОМОЛ1           = ДанныеМОЛ.Представление;

			Руководители = УправлениеНебольшойФирмойСервер.ОтветственныеЛицаОрганизационнойЕдиницы(Шапка.Руководители, Шапка.ДатаДокумента);
			Руководитель = Руководители.ФИОРуководителя;
			Бухгалтер    = Руководители.ФИОГлавногоБухгалтера;

			ТабличныйДокумент.Вывести(ОбластьМакетаШапка);
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();

			НомерСтраницы   = 2;
			НомерСтроки     = 1;
			КоличествоСтрок = ВыборкаСтрокТовары.Количество();

			ИтогоРезультатИзлишекКоличество   = 0;
			ИтогоРезультатИзлишекСумма        = 0;
			ИтогоРезультатНедостачаКоличество = 0;
			ИтогоРезультатНедостачаСумма      = 0;

			ИтогоСписаниеНедостачКолонка1Количество = 0;
			ИтогоСписаниеНедостачКолонка1Сумма      = 0;
			ИтогоПриходИзлишковКоличество           = 0;
			ИтогоПриходИзлишковСумма                = 0;
			
			// Вывод заголовка таблицы.
			ОбластьМакетаЗаголовокТаблицы.Параметры.НомерСтраницы = "Страница " + НомерСтраницы; 
			ТабличныйДокумент.Вывести(ОбластьМакетаЗаголовокТаблицы);

			// Вывод многострочной части докмента.
			Пока ВыборкаСтрокТовары.Следующий() Цикл

				ОбластьМакетаСтрока.Параметры.Заполнить(ВыборкаСтрокТовары);
				ОбластьМакетаСтрока.Параметры.ТоварНаименование = УправлениеНебольшойФирмойСервер.ПолучитьПредставлениеНоменклатурыДляПечати(ВыборкаСтрокТовары.ТоварНаименование, 
																		ВыборкаСтрокТовары.Характеристика, ВыборкаСтрокТовары.Артикул);
				
				Разница     = 0;
				РазницаСумм = 0;

				Разница     = ВыборкаСтрокТовары.ФактКоличество - ВыборкаСтрокТовары.БухКоличество;
				
				Если ИмяМакета = "ИНВ19" Тогда
					Цена = ВыборкаСтрокТовары.Цена;
				Иначе // ИмяМакета = "ИНВ19_УчетныеЦены"
					Цена = ?(ВыборкаСтрокТовары.БухКоличество = 0, 0, ВыборкаСтрокТовары.БухСумма / ВыборкаСтрокТовары.БухКоличество);
				КонецЕсли;
				
				РазницаСумм = Цена * Разница;
				
				Если Разница = 0 Тогда
					Продолжить;
				КонецЕсли;

				ОбластьМакетаСтрока.Параметры.Номер = НомерСтроки;
				
				Если Разница < 0 Тогда
					
					ОбластьМакетаСтрока.Параметры.РезультатНедостачаКоличество = - Разница;
					ОбластьМакетаСтрока.Параметры.РезультатНедостачаСумма      = - РазницаСумм;
					ОбластьМакетаСтрока.Параметры.РезультатИзлишекКоличество   = 0;
					ОбластьМакетаСтрока.Параметры.РезультатИзлишекСумма        = 0;

					ОбластьМакетаСтрока.Параметры.СписаниеНедостачКолонка1Количество = - Разница;
					ОбластьМакетаСтрока.Параметры.СписаниеНедостачКолонка1Сумма      = - РазницаСумм;
					ОбластьМакетаСтрока.Параметры.ПриходИзлишковКоличество   = 0;
					ОбластьМакетаСтрока.Параметры.ПриходИзлишковСумма        = 0;

					ИтогоРезультатНедостачаКоличество = ИтогоРезультатНедостачаКоличество + ( - Разница);
					ИтогоРезультатНедостачаСумма      = ИтогоРезультатНедостачаСумма      + ( - РазницаСумм);
					ИтогоРезультатИзлишекКоличество   = ИтогоРезультатИзлишекКоличество   + 0;
					ИтогоРезультатИзлишекСумма        = ИтогоРезультатИзлишекСумма        + 0;
					
					ИтогоСписаниеНедостачКолонка1Количество = ИтогоСписаниеНедостачКолонка1Количество + ( - Разница);
					ИтогоСписаниеНедостачКолонка1Сумма      = ИтогоСписаниеНедостачКолонка1Сумма      + ( - РазницаСумм);
					ИтогоПриходИзлишковКоличество   = ИтогоПриходИзлишковКоличество   + 0;
					ИтогоПриходИзлишковСумма        = ИтогоПриходИзлишковСумма        + 0;
					
				Иначе
					
					ОбластьМакетаСтрока.Параметры.РезультатНедостачаКоличество = 0;
					ОбластьМакетаСтрока.Параметры.РезультатНедостачаСумма      = 0;
					ОбластьМакетаСтрока.Параметры.РезультатИзлишекКоличество   = Разница;
					ОбластьМакетаСтрока.Параметры.РезультатИзлишекСумма        = РазницаСумм;

					ОбластьМакетаСтрока.Параметры.СписаниеНедостачКолонка1Количество = 0;
					ОбластьМакетаСтрока.Параметры.СписаниеНедостачКолонка1Сумма      = 0;
					ОбластьМакетаСтрока.Параметры.ПриходИзлишковКоличество   = Разница;
					ОбластьМакетаСтрока.Параметры.ПриходИзлишковСумма        = РазницаСумм;

					ИтогоРезультатНедостачаКоличество = ИтогоРезультатНедостачаКоличество + 0;
					ИтогоРезультатНедостачаСумма      = ИтогоРезультатНедостачаСумма      + 0;
					ИтогоРезультатИзлишекКоличество   = ИтогоРезультатИзлишекКоличество   + Разница;
					ИтогоРезультатИзлишекСумма        = ИтогоРезультатИзлишекСумма        + РазницаСумм;
					
					ИтогоСписаниеНедостачКолонка1Количество = ИтогоСписаниеНедостачКолонка1Количество + 0;
					ИтогоСписаниеНедостачКолонка1Сумма      = ИтогоСписаниеНедостачКолонка1Сумма      + 0;
					ИтогоПриходИзлишковКоличество   = ИтогоПриходИзлишковКоличество   + Разница;
					ИтогоПриходИзлишковСумма        = ИтогоПриходИзлишковСумма        + РазницаСумм;
					
				КонецЕсли;

				// Проверка вывода.
				СтрокаСПодвалом = Новый Массив();
				СтрокаСПодвалом.Добавить(ОбластьМакетаСтрока);
				СтрокаСПодвалом.Добавить(ОбластьМакетаИтогоПоСтранице);
				СтрокаСПодвалом.Добавить(ОбластьМакетаПодвал);
				
				Если НЕ ТабличныйДокумент.ПроверитьВывод(СтрокаСПодвалом) Тогда
					
					Если НЕ КоличествоСтрок = 1 Тогда
				
						// Вывод итого по странице.
						ТабличныйДокумент.Вывести(ОбластьМакетаИтогоПоСтранице);
						
						// Вывод разделителя страниц.
						ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
						
						// Вывод заголовка таблицы.
						НомерСтраницы = НомерСтраницы + 1;
						ОбластьМакетаЗаголовокТаблицы.Параметры.НомерСтраницы = "Страница " + НомерСтраницы;
						ТабличныйДокумент.Вывести(ОбластьМакетаЗаголовокТаблицы);
						
					КонецЕсли;

				КонецЕсли;
				
				ТабличныйДокумент.Вывести(ОбластьМакетаСтрока);
				
				НомерСтроки = НомерСтроки + 1;

			КонецЦикла;

			// Вывод итого по странице.
			ОбластьМакетаИтогоПоСтранице.Параметры.ИтогоРезультатИзлишекКоличество   = ИтогоРезультатИзлишекКоличество;
			ОбластьМакетаИтогоПоСтранице.Параметры.ИтогоРезультатИзлишекСумма        = ИтогоРезультатИзлишекСумма;
			ОбластьМакетаИтогоПоСтранице.Параметры.ИтогоРезультатНедостачаКоличество = ИтогоРезультатНедостачаКоличество;
			ОбластьМакетаИтогоПоСтранице.Параметры.ИтогоРезультатНедостачаСумма      = ИтогоРезультатНедостачаСумма;
			
			ОбластьМакетаИтогоПоСтранице.Параметры.ИтогоПриходИзлишковКоличество   = ИтогоПриходИзлишковКоличество;
			ОбластьМакетаИтогоПоСтранице.Параметры.ИтогоПриходИзлишковСумма        = ИтогоПриходИзлишковСумма;
			ОбластьМакетаИтогоПоСтранице.Параметры.ИтогоСписаниеНедостачКолонка1Количество = ИтогоСписаниеНедостачКолонка1Количество;
			ОбластьМакетаИтогоПоСтранице.Параметры.ИтогоСписаниеНедостачКолонка1Сумма      = ИтогоСписаниеНедостачКолонка1Сумма;
			
			ТабличныйДокумент.Вывести(ОбластьМакетаИтогоПоСтранице);
			
			// Вывод подвала.
			ОбластьМакетаПодвал.Параметры.Заполнить(Шапка);
			ОбластьМакетаПодвал.Параметры.ФИОБухгалтера = Руководители.ФИОГлавногоБухгалтера;
			ОбластьМакетаПодвал.Параметры.ДолжностьМОЛ1 = ДанныеМОЛ.Должность;
			ОбластьМакетаПодвал.Параметры.ФИОМОЛ1       = ДанныеМОЛ.Представление;
			ТабличныйДокумент.Вывести(ОбластьМакетаПодвал);
			
		ИначеЕсли ИмяМакета = "ИнвентаризацияЗапасов" Тогда
			
			ВалютаПечати = Константы.ВалютаУчета.Получить();
			
			Запрос = Новый Запрос;
			Запрос.УстановитьПараметр("ТекущийДокумент", ТекущийДокумент);
			Запрос.Текст =
			"ВЫБРАТЬ
			|	ИнвентаризацияЗапасов.Номер,
			|	ИнвентаризацияЗапасов.Дата КАК ДатаДокумента,
			|	ИнвентаризацияЗапасов.Организация,
			|	ИнвентаризацияЗапасов.СтруктурнаяЕдиница.Представление КАК ПредставлениеСклада,
			|	ИнвентаризацияЗапасов.Организация.Префикс КАК Префикс,
			|	ИнвентаризацияЗапасов.Запасы.(
			|		НомерСтроки,
			|		Номенклатура,
			|		ВЫБОР
			|			КОГДА (ВЫРАЗИТЬ(ИнвентаризацияЗапасов.Запасы.Номенклатура.НаименованиеПолное КАК СТРОКА(1000))) = """"
			|				ТОГДА ИнвентаризацияЗапасов.Запасы.Номенклатура.Наименование
			|			ИНАЧЕ ВЫРАЗИТЬ(ИнвентаризацияЗапасов.Запасы.Номенклатура.НаименованиеПолное КАК СТРОКА(1000))
			|		КОНЕЦ КАК Товар,
			|		Характеристика,
			|		Номенклатура.Артикул КАК Артикул,
			|		Количество КАК Количество,
			|		КоличествоУчет КАК КоличествоПоУчету,
			|		Отклонение КАК Отклонение,
			|		ЕдиницаИзмерения КАК ЕдиницаИзмерения,
			|		Цена,
			|		Сумма,
			|		СуммаУчет КАК СуммаПоУчету,
			|		КлючСвязи
			|	),
			|	ИнвентаризацияЗапасов.СерийныеНомера.(
			|		СерийныйНомер,
			|		КлючСвязи
			|	)
			|ИЗ
			|	Документ.ИнвентаризацияЗапасов КАК ИнвентаризацияЗапасов
			|ГДЕ
			|	ИнвентаризацияЗапасов.Ссылка = &ТекущийДокумент
			|
			|УПОРЯДОЧИТЬ ПО
			|	ИнвентаризацияЗапасов.Запасы.НомерСтроки";
			
			Шапка = Запрос.Выполнить().Выбрать();
			
			Шапка.Следующий();
			
			ВыборкаСтрокТовары = Шапка.Запасы.Выбрать();
			ВыборкаСтрокСерийныеНомера = Шапка.СерийныеНомера.Выбрать();
			
			ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ИнвентаризацияЗапасов_ИнвентаризацияЗапасов";
			
			Макет = УправлениеПечатью.МакетПечатнойФормы("Документ.ИнвентаризацияЗапасов.ПФ_MXL_ИнвентаризацияЗапасов");
			
			Если Шапка.ДатаДокумента < Дата('20110101') Тогда
				НомерДокумента = УправлениеНебольшойФирмойСервер.ПолучитьНомерНаПечать(Шапка.Номер, Шапка.Префикс);
			Иначе
				НомерДокумента = ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(Шапка.Номер, Истина, Истина);
			КонецЕсли;
			
			// Выводим шапку накладной
			ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
			ОбластьМакета.Параметры.ТекстЗаголовка = Нстр("ru ='Инвентаризация запасов № '") + НомерДокумента + Нстр("ru = ' от '") + Формат(Шапка.ДатаДокумента, "ДЛФ=DD");
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			// Выводим данные об организации и складе
			ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
			ОбластьМакета.Параметры.Заполнить(Шапка);
			
			СведенияОбОрганизации    = УправлениеНебольшойФирмойСервер.СведенияОЮрФизЛице(Шапка.Организация, Шапка.ДатаДокумента);
			ПредставлениеОрганизации = УправлениеНебольшойФирмойСервер.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование,");
			ОбластьМакета.Параметры.ПредставлениеОрганизации = ПредставлениеОрганизации;
			
			ОбластьМакета.Параметры.ВалютаНаименование = Строка(ВалютаПечати);
			ОбластьМакета.Параметры.Валюта             = ВалютаПечати;
			ТабличныйДокумент.Вывести(ОбластьМакета);

			// Выводим шапку таблицы
			ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
			ОбластьМакета.Параметры.Заполнить(Шапка);
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			ИтогСуммы        = 0;
			ИтогСуммыПоУчету = 0;

			ОбластьМакета = Макет.ПолучитьОбласть("Строка");
			Пока ВыборкаСтрокТовары.Следующий() Цикл

				ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТовары);
				СтрокаСерийныеНомера = РаботаССерийнымиНомерами.СтрокаСерийныеНомераИзВыборки(ВыборкаСтрокСерийныеНомера, ВыборкаСтрокТовары.КлючСвязи);
				ОбластьМакета.Параметры.Товар = УправлениеНебольшойФирмойСервер.ПолучитьПредставлениеНоменклатурыДляПечати(ВыборкаСтрокТовары.Товар, 
						ВыборкаСтрокТовары.Характеристика, ВыборкаСтрокТовары.Артикул, СтрокаСерийныеНомера);
																		
				ИтогСуммы        = ИтогСуммы        + ВыборкаСтрокТовары.Сумма;
				ИтогСуммыПоУчету = ИтогСуммыПоУчету + ВыборкаСтрокТовары.СуммаПоУчету;
				ТабличныйДокумент.Вывести(ОбластьМакета);

			КонецЦикла;

			// Вывести Итого
			ОбластьМакета                        = Макет.ПолучитьОбласть("Итого");
			ОбластьМакета.Параметры.Всего        = УправлениеНебольшойФирмойСервер.ФорматСумм(ИтогСуммы);
			ОбластьМакета.Параметры.ВсегоПоУчету = УправлениеНебольшойФирмойСервер.ФорматСумм(ИтогСуммыПоУчету);
			ТабличныйДокумент.Вывести(ОбластьМакета);

			// Выводим подписи к документу
			ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
		КонецЕсли;
		
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, ТекущийДокумент);
		
	КонецЦикла;
	
	ТабличныйДокумент.АвтоМасштаб = Истина;
	
	Возврат ТабличныйДокумент;
	
КонецФункции // ПечатнаяФорма()

// Сформировать печатные формы объектов
//
// ВХОДЯЩИЕ:
//   ИменаМакетов    - Строка    - Имена макетов, перечисленные через запятую
//   МассивОбъектов  - Массив    - Массив ссылок на объекты которые нужно распечатать
//   ПараметрыПечати - Структура - Структура дополнительных параметров печати
//
// ИСХОДЯЩИЕ:
//   КоллекцияПечатныхФорм - Таблица значений - Сформированные табличные документы
//   ПараметрыВывода       - Структура        - Параметры сформированных табличных документов
//
Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "БланкТоварногоНаполнения") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "БланкТоварногоНаполнения", "Бланк товарного наполнения", ПечатнаяФорма(МассивОбъектов, ОбъектыПечати, "БланкТоварногоНаполнения"));
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ИНВ3") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ИНВ3", "ИНВ-3 (Инвентаризационная опись товаров)", ПечатнаяФорма(МассивОбъектов, ОбъектыПечати, "ИНВ3"));
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ИНВ3БезФактическихДанных") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ИНВ3БезФактическихДанных", "ИНВ-3 (Инвентаризационная опись с пустыми фактическими данными)", ПечатнаяФорма(МассивОбъектов, ОбъектыПечати, "ИНВ3БезФактическихДанных"));
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ИНВ19") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ИНВ19", "ИНВ-19 (Сличительная ведомость)", ПечатнаяФорма(МассивОбъектов, ОбъектыПечати, "ИНВ19"));
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ИНВ19_УчетныеЦены") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ИНВ19_УчетныеЦены", "ИНВ-19 (Сличительная ведомость). Суммы по данным учета", ПечатнаяФорма(МассивОбъектов, ОбъектыПечати, "ИНВ19_УчетныеЦены"));
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ИнвентаризацияЗапасов") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ИнвентаризацияЗапасов", "Инвентаризация запасов", ПечатнаяФорма(МассивОбъектов, ОбъектыПечати, "ИнвентаризацияЗапасов"));
		
	КонецЕсли;
	
	// параметры отправки печатных форм по электронной почте
	УправлениеНебольшойФирмойСервер.ЗаполнитьПараметрыОтправки(ПараметрыВывода.ПараметрыОтправки, МассивОбъектов, КоллекцияПечатныхФорм);
	
КонецПроцедуры // Печать()

// Заполняет список команд печати.
// 
// Параметры:
//   КомандыПечати - ТаблицаЗначений - состав полей см. в функции УправлениеПечатью.СоздатьКоллекциюКомандПечати.
//
Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "ИнвентаризацияЗапасов,ИНВ3,ИНВ3БезФактическихДанных,ИНВ19,ИНВ19_УчетныеЦены";
	КомандаПечати.Представление = НСтр("ru = 'Настраиваемый комплект документов'");
	КомандаПечати.СписокФорм = "ФормаДокумента,ФормаСписка";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Порядок = 1;
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "ИнвентаризацияЗапасов";
	КомандаПечати.Представление = НСтр("ru = 'Инвентаризация запасов'");
	КомандаПечати.СписокФорм = "ФормаДокумента,ФормаСписка";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Порядок = 4;
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "ИНВ3";
	КомандаПечати.Представление = НСтр("ru = 'ИНВ-3 (Инвентаризационная опись товаров)'");
	КомандаПечати.СписокФорм = "ФормаДокумента,ФормаСписка";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Порядок = 7;
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "ИНВ3БезФактическихДанных";
	КомандаПечати.Представление = НСтр("ru = 'ИНВ-3 (Инвентаризационная опись с пустыми фактическими данными)'");
	КомандаПечати.СписокФорм = "ФормаДокумента,ФормаСписка";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Порядок = 10;
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "ИНВ19";
	КомандаПечати.Представление = НСтр("ru = 'ИНВ-19 (Сличительная ведомость)'");
	КомандаПечати.СписокФорм = "ФормаДокумента,ФормаСписка";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Порядок = 14;
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "ИНВ19_УчетныеЦены";
	КомандаПечати.Представление = НСтр("ru = 'ИНВ-19 (Сличительная ведомость). Суммы по данным учета'");
	КомандаПечати.СписокФорм = "ФормаДокумента,ФормаСписка";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Порядок = 15;
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "БланкТоварногоНаполнения";
	КомандаПечати.Представление = НСтр("ru = 'Бланк товарного наполнения'");
	КомандаПечати.СписокФорм = "ФормаДокумента,ФормаСписка";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Порядок = 17;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли