﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИнформационныйЦентрСервер.ВывестиКонтекстныеСсылки(ЭтаФорма, Элементы.ИнформационныеСсылки);
	
	СписокЗначений = Новый СписокЗначений;
	ВыборкаОрганизаций = Справочники.Организации.Выбрать();
	Пока ВыборкаОрганизаций.Следующий() Цикл
		СписокЗначений.Добавить(ВыборкаОрганизаций.Ссылка);
	КонецЦикла;
	СписокОрганизаций = СписокЗначений;
	
	// Установим формат для текущей даты: ДФ=Ч:мм
	УправлениеНебольшойФирмойСервер.УстановитьОформлениеКолонкиДата(Список);
	
	ЗаполнитьСписокВыбораВидовОпераций();
	
	ПрочитатьРасчетныеСчета();
	
	//УНФ.ОтборыСписка
	РаботаСОтборами.ВосстановитьНастройкиОтборов(ЭтотОбъект, Список);
	//Конец УНФ.ОтборыСписка
	
	// СтандартныеПодсистемы.ВерсионированиеОбъектов
	ВерсионированиеОбъектов.ПриСозданииНаСервере(ЭтаФорма);
	// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов
	
	// СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки
	ДополнительныеОтчетыИОбработки.ПриСозданииНаСервере(ЭтаФорма);
	// Конец СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки
	
	// СтандартныеПодсистемы.Печать
	УправлениеПечатью.ПриСозданииНаСервере(ЭтаФорма, Элементы.ГруппаВажныеКоманды);
	// Конец СтандартныеПодсистемы.Печать
	
КонецПроцедуры // ПриСозданииНаСервере()

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если НЕ ЗавершениеРаботы Тогда
		//УНФ.ОтборыСписка
		СохранитьНастройкиОтборов();
		//Конец УНФ.ОтборыСписка
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("СправочникСсылка.БанковскиеСчета") Тогда
		ЗагрузитьИзФайлаФрагмент(ВыбранноеЗначение);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Запись_ПоступлениеНаСчет" Тогда
		Если Параметр.Свойство("УдалениеПомеченных") И Параметр.УдалениеПомеченных Тогда
			Возврат;
		КонецЕсли;
		
		Элементы.Список.ТекущаяСтрока = Параметр.Ссылка;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СоздатьПоШаблону(Команда)
	
	ЗаполнениеОбъектовУНФКлиент.ПоказатьВыборШаблонаДляСозданияДокументаИзСписка(Список, Элементы.Список.ТекущаяСтрока);
	
КонецПроцедуры

// Обработчик команды ЗагрузитьИзФайла формы.
//
&НаКлиенте
Процедура ЗагрузитьИзФайла(Команда)
	
	ЗагрузитьИзФайлаФрагмент();
	
КонецПроцедуры // ЗагрузитьИзФайла()

&НаКлиенте
Процедура ЗагрузитьИзФайлаФрагмент(ПараметрБанковскийСчет = Неопределено)
	
	Если ПараметрБанковскийСчет = Неопределено Тогда
		СтруктураПрямогоОбмена = КлиентБанкВызовСервера.ПолучитьСтруктуруПрямогоОбмена();
		Если СтруктураПрямогоОбмена.БанковскийСчет = Неопределено Тогда // Есть несколько счетов, нужно выбирать.
			Отбор = Новый Структура("ЭтоСчетОрганизации", Истина);
			ОткрытьФорму("Справочник.БанковскиеСчета.Форма.ФормаВыбораБезВладельца", Новый Структура("ТекущаяСтрока, Отбор", СтруктураПрямогоОбмена.БанковскийСчет, Отбор), ЭтаФорма);
		ИначеЕсли СтруктураПрямогоОбмена.БанковскийСчет.Пустая() Тогда  // Нет ни одной настройки обмена с банками, можно сразу выбирать файл загрузки.
			УправлениеНебольшойФирмойКлиент.ЗагрузитьДанныеИзФайлаВыписки(УникальныйИдентификатор);
		Иначе                                                           // Один счет, можно сразу подставить его.
			ОткрытьФорму(
				"Обработка.КлиентБанк.Форма.ФормаЗагрузка",
				СтруктураПрямогоОбмена
			);
		КонецЕсли;
	Иначе
		СтруктураОбмена = КлиентБанкВызовСервера.ПолучитьСтруктуруОбмена(ПараметрБанковскийСчет);
		Если НЕ СтруктураОбмена.ПрямойОбмен Тогда
			КлиентБанкКлиент.ЗагрузитьДанныеИзФайлаВыписки(УникальныйИдентификатор, СтруктураОбмена);
		Иначе
			ОткрытьФорму(
				"Обработка.КлиентБанк.Форма.ФормаЗагрузка",
				СтруктураОбмена
			);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВедомостьПерейти(Команда)
	
	ОткрытьФорму("Отчет.ДенежныеСредства.Форма", Новый Структура("КлючВарианта, СформироватьПриОткрытии", "Ведомость", Истина));
	
КонецПроцедуры // ВедомостьПерейти()

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура Подключаемый_НажатиеНаИнформационнуюСсылку(Элемент)
	
	ИнформационныйЦентрКлиент.НажатиеНаИнформационнуюСсылку(ЭтаФорма, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_НажатиеНаСсылкуВсеИнформационныеСсылки(Элемент)
	
	ИнформационныйЦентрКлиент.НажатиеНаСсылкуВсеИнформационныеСсылки(ЭтаФорма.ИмяФормы);
	
КонецПроцедуры

#КонецОбласти

#Область ЗамерыПроизводительности

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	ОценкаПроизводительностиКлиент.НачатьЗамерВремени(Истина, "СозданиеФормы" + РаботаСФормойДокументаКлиентСервер.ПолучитьИмяФормыСтрокой(ЭтотОбъект.ИмяФормы));
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередНачаломИзменения(Элемент, Отказ)
	
	ОценкаПроизводительностиКлиент.НачатьЗамерВремени(Истина, "ОткрытиеФормы" + РаботаСФормойДокументаКлиентСервер.ПолучитьИмяФормыСтрокой(ЭтотОбъект.ИмяФормы));
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиБиблиотек

// СтандартныеПодсистемы.Печать
&НаКлиенте
Процедура Подключаемый_ВыполнитьКомандуПечати(Команда)
	УправлениеПечатьюКлиент.ВыполнитьПодключаемуюКомандуПечати(Команда, ЭтотОбъект, Элементы.Список);
КонецПроцедуры
// Конец СтандартныеПодсистемы.Печать

#КонецОбласти

#Область МеткиОтборов

&НаСервере
Процедура УстановитьМеткуИОтборСписка(СписокДляОтбора, ИмяПоляОтбораСписка, ГруппаРодительМетки, ВыбранноеЗначение, ПредставлениеЗначения="")
	
	Если ПредставлениеЗначения="" Тогда
		ПредставлениеЗначения=Строка(ВыбранноеЗначение);
	КонецЕсли; 
	
	РаботаСОтборами.ПрикрепитьМеткуОтбора(ЭтотОбъект, ИмяПоляОтбораСписка, ГруппаРодительМетки, ВыбранноеЗначение, ПредставлениеЗначения, СписокДляОтбора);
	РаботаСОтборами.УстановитьОтборСписка(ЭтотОбъект, ЭтотОбъект[СписокДляОтбора], ИмяПоляОтбораСписка);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_МеткаОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	МеткаИД = Сред(Элемент.Имя, СтрДлина("Метка_")+1);
	
	ИмяРеквизитаСписка = "Список";
	УдалитьМеткуОтбора(МеткаИД, ИмяРеквизитаСписка);
	
КонецПроцедуры

&НаСервере
Процедура УдалитьМеткуОтбора(МеткаИД, ИмяРеквизитаСписка)
	
	РаботаСОтборами.УдалитьМеткуОтбораСервер(ЭтотОбъект, ЭтотОбъект[ИмяРеквизитаСписка], МеткаИД);

КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеПериодаНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	РаботаСОтборамиКлиент.ПредставлениеПериодаВыбратьПериод(ЭтотОбъект, "Список", "Дата");
	
КонецПроцедуры

&НаСервере
Процедура СохранитьНастройкиОтборов()
	
	РаботаСОтборами.СохранитьНастройкиОтборов(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура СвернутьРазвернутьПанельОтборов(Элемент)
	
	НовоеЗначениеВидимость = НЕ Элементы.ФильтрыНастройкиИДопИнфо.Видимость;
	РаботаСОтборамиКлиент.СвернутьРазвернутьПанельОтборов(ЭтотОбъект, НовоеЗначениеВидимость);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ДИНАМИЧЕСКОГО СПИСКА

// Выбор значения отбора в поле отбора
&НаКлиенте
Процедура ОтборКонтрагентОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("Список", "Контрагент", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборОрганизацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("Список", "Организация", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборХозяйственнаяОперацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("Список", "ВидОперации", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборСчетИКассаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("Список", "БанковскийСчет", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборВалютаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("Список", "ВалютаДенежныхСредств", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборАвторОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("Список", "Автор", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

#КонецОбласти

#Область ОбщегоНазначения

// Процедура дополняет список выбора видов операций.
//
&НаСервере
Процедура ЗаполнитьСписокВыбораВидовОпераций()
	
	СписокВидовОпераций = ДвиженияДенежныхСредствВызовСервера.ПолучитьСписокВидовОперацийПоступленияДСБанк();
	Элементы.ОтборВидОперации.СписокВыбора.ЗагрузитьЗначения(СписокВидовОпераций.ВыгрузитьЗначения());
	
КонецПроцедуры // ДополнитСписокВыбораВидовОпераций()

&НаСервере
Процедура ПрочитатьРасчетныеСчета()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	БанковскиеСчета.Ссылка,
		|	ПРЕДСТАВЛЕНИЕ(БанковскиеСчета.Ссылка) КАК Представление
		|ИЗ
		|	Справочник.БанковскиеСчета КАК БанковскиеСчета
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Организации КАК Организации
		|		ПО БанковскиеСчета.Владелец = Организации.Ссылка";
	
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаСчетов = РезультатЗапроса.Выбрать();
	
	Элементы.ОтборБанковскийСчет.СписокВыбора.Очистить();
	
	Если НЕ РезультатЗапроса.Пустой() И НЕ ВыборкаСчетов.Количество() = 1 Тогда
		Пока ВыборкаСчетов.Следующий() Цикл
			Элементы.ОтборБанковскийСчет.СписокВыбора.Добавить(ВыборкаСчетов.Ссылка);
		КонецЦикла;
	Иначе
		Элементы.ОтборБанковскийСчет.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ПоступлениеНаСчет

&НаКлиенте
Процедура ПоступлениеОтПокупателяБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ОтПокупателя", ДанныеМеток);
	
КонецПроцедуры


&НаКлиенте
Процедура ПоступлениеПрочееБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "Прочее", ДанныеМеток);
	
КонецПроцедуры


&НаКлиенте
Процедура ПоступлениеОтПоставщикаБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ОтПоставщика", ДанныеМеток);
	
КонецПроцедуры


&НаКлиенте
Процедура ПоступлениеПолучениеКредитаБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "РасчетыПоКредитам", ДанныеМеток);
	
КонецПроцедуры


&НаКлиенте
Процедура ПоступлениеВозвратЗаймаСотрудникомБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ВозвратЗаймаСотрудником", ДанныеМеток);
	
КонецПроцедуры


&НаКлиенте
Процедура ПоступлениеПрочиеРасчетыБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ПрочиеРасчеты", ДанныеМеток);
	
КонецПроцедуры


&НаКлиенте
Процедура ПоступлениеОтПодотчетникаБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ОтПодотчетника", ДанныеМеток);
	
КонецПроцедуры


&НаКлиенте
Процедура ПоступлениеОтчетЭквайрераБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ПоступлениеОплатыПоКартам", ДанныеМеток);
	
КонецПроцедуры


&НаКлиенте
Процедура ПоступлениеНалогиБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "Налоги", ДанныеМеток);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоступлениеПокупкаВалютыБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ПокупкаВалюты", ДанныеМеток);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоступлениеВзносНаличнымиБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ВзносНаличными", ДанныеМеток);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоступлениеПереводСДругогоСчетаБанк(Команда)
	
	ДвиженияДенежныхСредствКлиент.СоздатьДокумент("ПоступлениеНаСчет", "ПереводСДругогоСчета", ДанныеМеток);
	
КонецПроцедуры

#КонецОбласти
