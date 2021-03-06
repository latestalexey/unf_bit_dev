﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПредопределенныеПроцедурыОбработчикиСобытий

// Процедура - обработчик события ПередЗаписью.
//
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоГруппа Тогда
		
		Если ПометкаУдаления И Действует Тогда
			Действует = Ложь;
		КонецЕсли;
		
		ЕстьУточненияПоНоменклатуре = ?(ВариантОграниченияПоНоменклатуре = Перечисления.ВариантыОграниченийСкидокПоНоменклатуре.ПоНоменклатуре, НоменклатураГруппыЦеновыеГруппы.Количество() > 0, Ложь);
		ЕстьУточненияПоКатегориям = ?(ВариантОграниченияПоНоменклатуре = Перечисления.ВариантыОграниченийСкидокПоНоменклатуре.ПоКатегориям, НоменклатураГруппыЦеновыеГруппы.Количество() > 0, Ложь);
		ЕстьУточненияПоЦеновымГруппам = ?(ВариантОграниченияПоНоменклатуре = Перечисления.ВариантыОграниченийСкидокПоНоменклатуре.ПоЦеновымГруппам, НоменклатураГруппыЦеновыеГруппы.Количество() > 0, Ложь);
		
		ЕстьРасписание = Ложь;
		Для Каждого ТекущаяСтрокаРасписания Из ВремяПоДнямНедели Цикл
			Если ТекущаяСтрокаРасписания.Выбран Тогда
				ЕстьРасписание = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		ЕстьОграниченияПоПолучателямКонтрагентам = ПолучателиСкидкиКонтрагенты.Количество() > 0;
		ЕстьОграниченияПоПолучателямСкладам = ПолучателиСкидкиСклады.Количество() > 0;
		
		Если ВариантОграниченияПоНоменклатуре = Перечисления.ВариантыОграниченийСкидокПоНоменклатуре.ПоНоменклатуре Тогда
			Запрос = Новый Запрос;
			Запрос.Текст = 
				"ВЫБРАТЬ
				|	АвтоматическиеСкидкиНоменклатураГруппыЦеновыеГруппы.ЗначениеУточнения
				|ПОМЕСТИТЬ ВТ_АвтоматическиеСкидкиНоменклатураГруппыЦеновыеГруппы
				|ИЗ
				|	&НоменклатураГруппыЦеновыеГруппы КАК АвтоматическиеСкидкиНоменклатураГруппыЦеновыеГруппы
				|;
				|
				|////////////////////////////////////////////////////////////////////////////////
				|ВЫБРАТЬ ПЕРВЫЕ 1
				|	ВТ_АвтоматическиеСкидкиНоменклатураГруппыЦеновыеГруппы.ЗначениеУточнения
				|ИЗ
				|	ВТ_АвтоматическиеСкидкиНоменклатураГруппыЦеновыеГруппы КАК ВТ_АвтоматическиеСкидкиНоменклатураГруппыЦеновыеГруппы
				|ГДЕ
				|	ВТ_АвтоматическиеСкидкиНоменклатураГруппыЦеновыеГруппы.ЗначениеУточнения.ЭтоГруппа";
			
			Запрос.УстановитьПараметр("ПоНоменклатуре", ВариантОграниченияПоНоменклатуре);
			Запрос.УстановитьПараметр("НоменклатураГруппыЦеновыеГруппы", НоменклатураГруппыЦеновыеГруппы.Выгрузить());
			
			Результат = Запрос.Выполнить();
			
			ЕстьГруппыВУточненииПоНоменклатуре = Не Результат.Пустой();
		Иначе
			ЕстьГруппыВУточненииПоНоменклатуре = Ложь;
		КонецЕсли;
		
		// Удалим строки с пустым условием.
		МУдаляемыеСтроки = Новый Массив;
		Для каждого ТекущееУсловие Из УсловияПредоставления Цикл
			Если ТекущееУсловие.УсловиеПредоставления.Пустая() Тогда
				МУдаляемыеСтроки.Добавить(ТекущееУсловие);
			КонецЕсли;
		КонецЦикла;
		
		Для каждого УдаляемаяСтрока Из МУдаляемыеСтроки Цикл
			УсловияПредоставления.Удалить(УдаляемаяСтрока);
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура - обработчик события ОбработкаПроверкиЗаполнения.
//
Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	МассивНепроверяемыхРеквизитов = Новый Массив;
	
	Если СпособПредоставления <> Перечисления.СпособыПредоставленияСкидокНаценок.Сумма Тогда
		МассивНепроверяемыхРеквизитов.Добавить("ВалютаПредоставления");
	КонецЕсли;
	
	ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНепроверяемыхРеквизитов);
	
КонецПроцедуры

// Процедура - обработчик события ОбработкаЗаполнения.
//
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоГруппа Тогда
		ВалютаПредоставления = Константы.ВалютаУчета.Получить();
	Иначе
		ВариантСовместногоПрименения = Константы.ВариантыСовместногоПримененияСкидокНаценок.Получить();
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьИнформациюВСлужебномРегистреСведений(Отказ)
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Обновим информацию в служебном регистре сведений, который используется для оптимизациии количества случаев,
	// в которых требуется выплнять расчёт автоматических скидок.
	МенеджерЗаписи = РегистрыСведений.СлужебныйАвтоматическиеСкидки.СоздатьМенеджерЗаписи();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить();
	ЭлементБлокировки.Область = "РегистрСведений.ДатыЗапретаИзменения";
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		МенеджерЗаписи.Прочитать();
			
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
			|	ИСТИНА КАК Поле1
			|ИЗ
			|	Справочник.АвтоматическиеСкидки.УсловияПредоставления КАК АвтоматическиеСкидкиУсловияПредоставления
			|ГДЕ
			|	АвтоматическиеСкидкиУсловияПредоставления.УсловиеПредоставления.УсловиеПредоставления = &ЗаРазовыйОбъемПродаж
			|	И АвтоматическиеСкидкиУсловияПредоставления.УсловиеПредоставления.КритерийОграниченияПримененияЗаОбъемПродаж = &Сумма
			|	И АвтоматическиеСкидкиУсловияПредоставления.Ссылка.Действует
			|	И НЕ АвтоматическиеСкидкиУсловияПредоставления.Ссылка.ПометкаУдаления
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
			|	ИСТИНА КАК Поле1
			|ИЗ
			|	Справочник.АвтоматическиеСкидки.УсловияПредоставления КАК АвтоматическиеСкидкиУсловияПредоставления
			|ГДЕ
			|	АвтоматическиеСкидкиУсловияПредоставления.УсловиеПредоставления.УсловиеПредоставления = &ЗаКомплектПокупки
			|	И АвтоматическиеСкидкиУсловияПредоставления.Ссылка.Действует
			|	И НЕ АвтоматическиеСкидкиУсловияПредоставления.Ссылка.ПометкаУдаления
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
			|	ИСТИНА КАК Поле1
			|ИЗ
			|	Справочник.АвтоматическиеСкидки.ПолучателиСкидкиКонтрагенты КАК АвтоматическиеСкидкиПолучателиСкидкиКонтрагенты
			|ГДЕ
			|	АвтоматическиеСкидкиПолучателиСкидкиКонтрагенты.Ссылка.Действует
			|	И НЕ АвтоматическиеСкидкиПолучателиСкидкиКонтрагенты.Ссылка.ПометкаУдаления
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
			|	ИСТИНА КАК Поле1
			|ИЗ
			|	Справочник.АвтоматическиеСкидки.ПолучателиСкидкиСклады КАК АвтоматическиеСкидкиПолучателиСкидкиСклады
			|ГДЕ
			|	АвтоматическиеСкидкиПолучателиСкидкиСклады.Ссылка.Действует
			|	И НЕ АвтоматическиеСкидкиПолучателиСкидкиСклады.Ссылка.ПометкаУдаления
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
			|	ИСТИНА КАК Поле1
			|ИЗ
			|	Справочник.АвтоматическиеСкидки.ВремяПоДнямНедели КАК АвтоматическиеСкидкиВремяПоДнямНедели
			|ГДЕ
			|	АвтоматическиеСкидкиВремяПоДнямНедели.Ссылка.Действует
			|	И НЕ АвтоматическиеСкидкиВремяПоДнямНедели.Ссылка.ПометкаУдаления
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
			|	ИСТИНА КАК Поле1
			|ИЗ
			|	Справочник.АвтоматическиеСкидки КАК АвтоматическиеСкидки
			|ГДЕ
			|	НЕ АвтоматическиеСкидки.ПометкаУдаления
			|	И АвтоматическиеСкидки.Действует";
		
		Запрос.УстановитьПараметр("ЗаРазовыйОбъемПродаж", Перечисления.УсловияПредоставленияСкидокНаценок.ЗаРазовыйОбъемПродаж);
		Запрос.УстановитьПараметр("ЗаКомплектПокупки", Перечисления.УсловияПредоставленияСкидокНаценок.ЗаКомплектПокупки);
		Запрос.УстановитьПараметр("Сумма", Перечисления.КритерииОграниченияПримененияСкидкиНаценкиЗаОбъемПродаж.Сумма);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		МРезультатов = Запрос.ВыполнитьПакет();
		
		// Есть скидка с условием от суммы.
		Выборка = МРезультатов[0].Выбрать();
		МенеджерЗаписи.ЕстьСкидкиСУсловиямиОтСуммы = Выборка.Следующий();
		
		// Есть скидка за комплект покупки.
		Выборка = МРезультатов[1].Выбрать();
		МенеджерЗаписи.ЕстьСкидкиСУсловиямиЗаКомплектПокупки = Выборка.Следующий();
		
		// Есть скидки с ограничением по контрагенту.
		Выборка = МРезультатов[2].Выбрать();
		МенеджерЗаписи.ЕстьСкидкиСПолучателямиКонтрагенты = Выборка.Следующий();
		
		// Есть скидки с ограничением по контрагенту.
		Выборка = МРезультатов[3].Выбрать();
		МенеджерЗаписи.ЕстьСкидкиСПолучателямиСклады = Выборка.Следующий();
		
		// Есть скидки с расписанием.
		Выборка = МРезультатов[4].Выбрать();
		МенеджерЗаписи.ЕстьСкидкиСРасписанием = Выборка.Следующий();
		
		МенеджерЗаписи.Записать();
		
		// Есть действующие скидки.
		Выборка = МРезультатов[5].Выбрать();
		Константы.ЕстьАвтоматическиеСкидки.Установить(Выборка.Следующий());
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		Отказ = Истина;
		ПредставлениеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;
	
	УстановитьПривилегированныйРежим(Ложь);
	
	ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Автоматические скидки. Служебная информация по автоматическим скидкам'",
			     ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			?(Отказ, УровеньЖурналаРегистрации.Ошибка, УровеньЖурналаРегистрации.Информация),
			,
			,
			ПредставлениеОшибки,
			РежимТранзакцииЗаписиЖурналаРегистрации.Независимая);
	
	Если Отказ Тогда
		ВызватьИсключение
			НСтр("ru = 'Не удалось записать служебную информацию по автоматическим скидкам, наценкам.
			           |Подробности в журнале регистрации.'");
	КонецЕсли;
	
КонецПроцедуры

// Процедура - обработчик события ПриЗаписи.
//
Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Если НЕ (ДополнительныеСвойства.Свойство("РегистрироватьСлужебныйАвтоматическиеСкидки")
			И ДополнительныеСвойства.РегистрироватьСлужебныйАвтоматическиеСкидки = Ложь) Тогда
			ОбновитьИнформациюВСлужебномРегистреСведений(Отказ);
		КонецЕсли;
		
		Возврат;
	КонецЕсли;
	
	ОбновитьИнформациюВСлужебномРегистреСведений(Отказ);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли