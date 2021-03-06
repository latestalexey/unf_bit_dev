﻿
#Область СлужебныеПроцедурыФункции

&НаСервере
Процедура ПолучитьНоменклатуруСЦеной(АдресВременногоХранилища)
	
	ДеревоНоменклатуры = Новый ДеревоЗначений;
	
	// 1. Получим СКД
	ИмяСхемыКД = "ПоВидамЦенСЦеной";
	СхемаКомпоновкиДанных = Обработки.Ценообразование.ПолучитьМакет(ИмяСхемыКД);
	
	// 2. создаем настройки для схемы 
	НастройкиКомпоновкиДанных = СхемаКомпоновкиДанных.НастройкиПоУмолчанию;
	
	// 2.1 установим значения параметров
	ПараметрКД = СхемаКомпоновкиДанных.Параметры.Найти("МассивВидовЦен");
	ПараметрКД.Значение = ВидыЦен.ВыгрузитьЗначения();
	
	ПараметрКД = СхемаКомпоновкиДанных.Параметры.Найти("ОтборПоПериоду");
	Если ЗначениеЗаполнено(ОтборПоПериоду) Тогда
		
		ПараметрКД.Значение = ОтборПоПериоду;
		
		ТекстЗапроса = СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос;
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ОтборПоПериоду", "Период < &ОтборПоПериоду");
		СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос = ТекстЗапроса;
		
	Иначе
		
		ПараметрКД.Значение = Истина;
		
	КонецЕсли;
	
	Если ИспользоватьХарактеристики = 0 Тогда
		
		ТекстЗапроса = СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос;
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ОтборПоХарактеристикам", "Характеристика = Значение(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка)");
		СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос = ТекстЗапроса;
		
	Иначе
		
		ПараметрКД = СхемаКомпоновкиДанных.Параметры.Найти("ОтборПоХарактеристикам");
		ПараметрКД.Значение = Истина;
		
	КонецЕсли;
	
	// 3. готовим макет 
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Макет = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновкиДанных, , , Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	
	// 4. исполняем макет 
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(Макет);
	ПроцессорКомпоновки.Сбросить();
	
	// 5. выводим результат 
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.УстановитьОбъект(ДеревоНоменклатуры);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	СтруктураТаблицДанных = Обработки.Ценообразование.РазобратьДеревоНоменклатуры(ДеревоНоменклатуры);
	АдресВременногоХранилища = ПоместитьВоВременноеХранилище(СтруктураТаблицДанных);
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьНоменклатуруБезЦеной(АдресВременногоХранилища)
	
	ДеревоНоменклатуры = Новый ДеревоЗначений;
	
	// 1. Получим СКД
	ИмяСхемыКД = "ПоВидамЦенБезЦен";
	СхемаКомпоновкиДанных = Обработки.Ценообразование.ПолучитьМакет(ИмяСхемыКД);
	
	// 2. создаем настройки для схемы 
	НастройкиКомпоновкиДанных = СхемаКомпоновкиДанных.НастройкиПоУмолчанию;
	
	// 2.1 установим значения параметров
	ПараметрКД = СхемаКомпоновкиДанных.Параметры.Найти("МассивВидовЦен");
	ПараметрКД.Значение = ВидыЦен.ВыгрузитьЗначения();
	
	Если ИспользоватьХарактеристики = 0 Тогда
		
		ТекстЗапроса = СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос;
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ОтборПоХарактеристикам", "Характеристика = Значение(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка)");
		СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос = ТекстЗапроса;
		
		НастройкиКомпоновкиДанных.Структура[0].Структура[0].Использование = Ложь;
		
	КонецЕсли;
	
	// 3. готовим макет 
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Макет = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновкиДанных, , , Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	
	// 4. исполняем макет 
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(Макет);
	ПроцессорКомпоновки.Сбросить();
	
	// 5. выводим результат 
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.УстановитьОбъект(ДеревоНоменклатуры);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	СтруктураТаблицДанных = Обработки.Ценообразование.РазобратьДеревоНоменклатуры(ДеревоНоменклатуры);
	АдресВременногоХранилища = ПоместитьВоВременноеХранилище(СтруктураТаблицДанных);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьОтчетСПредварительнымРезультатом()
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ИмяСКД",					?(ВидЗаписейРегистраКОтбору = Истина, "ПоВидамЦенСЦеной", "ПоВидамЦенБезЦен"));
	ПараметрыОткрытия.Вставить("МассивВидовЦен", 			ВидыЦен.ВыгрузитьЗначения());
	ПараметрыОткрытия.Вставить("ВыбиратьНоменклатуру",		?(ВидЗаписейРегистраКОтбору = Истина, 1, 0));
	ПараметрыОткрытия.Вставить("ОтборПоПериоду", 			ОтборПоПериоду);
	ПараметрыОткрытия.Вставить("ИспользоватьХарактеристики",ИспользоватьХарактеристики);
	
	ОткрытьФорму("Обработка.Ценообразование.Форма.ФормаПредварительногоПросмотра", ПараметрыОткрытия, ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьВХранилищеДанныеТабличнойЧасти(АдресВременногоХранилища)
	
	Если ВидЗаписейРегистраКОтбору Тогда
		
		ПолучитьНоменклатуруСЦеной(АдресВременногоХранилища);
		
	Иначе
		
		ПолучитьНоменклатуруБезЦеной(АдресВременногоХранилища);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВывестиСообщениеОНеправильномВыборе()
	
	ТекстСообщения = НСтр("ru ='Необходимо заполнить виды цен'");
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "ВидыЦен");
	
КонецПроцедуры

#КонецОбласти

#Область СобытияФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("КэшЗначений", КэшЗначений);
	
	Если КэшЗначений.ВыбранныеВидыЦен <> Неопределено Тогда
		
		Для каждого ЭлементСоответствия Из КэшЗначений.ВыбранныеВидыЦен Цикл
			
			ВидыЦен.Добавить(ЭлементСоответствия.Ключ);
			
		КонецЦикла;
		
	КонецЕсли;
	
	// Только номенклатуру(0); Номенкатуру и ее характеристики(1);
	ИспользоватьХарактеристики = ?(Параметры.ХарактеристикиВидны = Истина, 1, 0);
	
	ВидЗаписейРегистраКОтбору = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область СобытияРеквизитовФормы

&НаКлиенте
Процедура ВидыЦенНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ВидыЦен",			ВидыЦен.ВыгрузитьЗначения());
	
	ОбработкаОповещения = Новый ОписаниеОповещения("ПослеВыбораВидовЦен", ЭтотОбъект);
	ОткрытьФорму("Обработка.Ценообразование.Форма.ВидыЦен", ПараметрыОткрытия, ЭтаФорма, , , , ОбработкаОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораВидовЦен(Результат, ДополнительныеПараметры) Экспорт
	
	Если ТипЗнч(Результат) = Тип("Структура")
		И Результат.ВыборПроизведен Тогда
		
		ВидыЦен.Очистить();
		Для каждого ВыбранныйВидЦен Из Результат.ВыбранныеВидыЦен Цикл
			
			ВидыЦен.Добавить(ВыбранныйВидЦен.Ключ);
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВидЗаписейРегистраКОтборуПриИзменении(Элемент)
	
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "ОтборПоПериоду", "Доступность", ВидЗаписейРегистраКОтбору);
	Если НЕ ВидЗаписейРегистраКОтбору Тогда
		
		ОтборПоПериоду = Неопределено;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура ОК(Команда)
	
	Если ВидыЦен.Количество() > 0 Тогда
		
		АдресВременногоХранилища = "";
		ЗаписатьВХранилищеДанныеТабличнойЧасти(АдресВременногоХранилища);
		
		Закрыть(Новый Структура("ВыборПроизведен, АдресВременногоХранилища", Истина, АдресВременногоХранилища));
		
	Иначе
		
		ВывестиСообщениеОНеправильномВыборе();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	Закрыть(Новый Структура("ВыборПроизведен", Ложь));
	
КонецПроцедуры

&НаКлиенте
Процедура ПредварительныйПросмотр(Команда)
	
	Если ВидыЦен.Количество() > 0 Тогда
		
		ПоказатьОтчетСПредварительнымРезультатом();
		
	Иначе
		
		ВывестиСообщениеОНеправильномВыборе();
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
