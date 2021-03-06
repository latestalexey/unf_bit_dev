﻿
&НаКлиенте
Процедура ОтборСтатусПриИзменении(Элемент)
	
	Если НЕ ЗначениеЗаполнено(ОтборСтатус) Тогда
		ОтключитьОтбор(ОтборСтатусИндекс);
		Возврат;
	КонецЕсли;
	
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ИмяПоляКД","Статус");
	СтруктураОтбора.Вставить("ВидСравнения", ВидСравненияКомпоновкиДанных.Равно);
	СтруктураОтбора.Вставить("ЗначениеСравнения", ОтборСтатус);
	СтруктураОтбора.Вставить("ИндексПреведущегоЗначения", ОтборСтатусИндекс);

	ОтборСтатусИндекс = УстановитьОтборСКД(СтруктураОтбора);
	УстановитьОтображениеСостоянияОтчета();
КонецПроцедуры

&НаКлиенте
Процедура ОтборКонтрагентПриИзменении(Элемент)
	
	Если НЕ ЗначениеЗаполнено(ОтборКонтрагент) Тогда
		ОтключитьОтбор(ОтборКонтрагентИндекс);
		Возврат;
	КонецЕсли;
	
	
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ИмяПоляКД","Контрагент");
	СтруктураОтбора.Вставить("ВидСравнения", ВидСравненияКомпоновкиДанных.Равно);
	СтруктураОтбора.Вставить("ЗначениеСравнения", ОтборКонтрагент);
	СтруктураОтбора.Вставить("ИндексПреведущегоЗначения", ОтборКонтрагентИндекс);

	ОтборКонтрагентИндекс = УстановитьОтборСКД(СтруктураОтбора);
    УстановитьОтображениеСостоянияОтчета();
КонецПроцедуры

&НаКлиенте
Процедура ОтборИсполнительПриИзменении(Элемент)
	
	Если НЕ ЗначениеЗаполнено(ОтборИсполнитель) Тогда
		ОтключитьОтбор(ОтборИсполнительИндекс);	
		Возврат;
	КонецЕсли;	
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ИмяПоляКД","Исполнитель");
	СтруктураОтбора.Вставить("ВидСравнения", ВидСравненияКомпоновкиДанных.Равно);
	СтруктураОтбора.Вставить("ЗначениеСравнения", ОтборИсполнитель);
	СтруктураОтбора.Вставить("ИндексПреведущегоЗначения", ОтборИсполнительИндекс);

	ОтборИсполнительИндекс = УстановитьОтборСКД(СтруктураОтбора);
	УстановитьОтображениеСостоянияОтчета();		
КонецПроцедуры

// <Описание процедуры>
&НаКлиенте
Процедура УстановитьОтображениеСостоянияОтчета()
	ОтображениеСостояния = Элементы.Результат.ОтображениеСостояния;
	ОтображениеСостояния.Видимость                      = Истина;
	ОтображениеСостояния.ДополнительныйРежимОтображения = ДополнительныйРежимОтображения.Неактуальность;
	ОтображениеСостояния.Картинка                       = Новый Картинка;
	ОтображениеСостояния.Текст                          = НСтр("ru = 'Отчет не сформирован. Нажмите ""Сформировать"" для получения отчета.'");;
		
КонецПроцедуры // УстановитьОтображениеСостоянияОтчета()

&НаСервере
Функция  УстановитьОтборСКД(СтруктураОтбора)
                                            
	ЭлементыОтбора = Отчет.КомпоновщикНастроек.Настройки.Отбор.Элементы;
	ПолеКД = Новый ПолеКомпоновкиДанных(СтруктураОтбора.ИмяПоляКД);
		
	Если НЕ ЗначениеЗаполнено(СтруктураОтбора.ИндексПреведущегоЗначения) Тогда		
		ПолеОтбора = ЭлементыОтбора.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ПолеОтбора.ЛевоеЗначение	= ПолеКД;
		ПолеОтбора.ВидСравнения		= СтруктураОтбора.ВидСравнения;
		ПолеОтбора.ПравоеЗначение	= СтруктураОтбора.ЗначениеСравнения;
		ПолеОтбора.Использование	= Истина;
		ОтборИндекс	= ЭлементыОтбора.Индекс(ПолеОтбора) + 1;
		Возврат ОтборИндекс
	Иначе
		ПолеОтбора = ЭлементыОтбора.Получить(СтруктураОтбора.ИндексПреведущегоЗначения - 1);
		ПолеОтбора.ПравоеЗначение 	= СтруктураОтбора.ЗначениеСравнения;
		ПолеОтбора.Использование = Истина;
		Возврат СтруктураОтбора.ИндексПреведущегоЗначения;
	КонецЕсли;	

КонецФункции // УстановитьОтборСКД()

&НаКлиенте
Процедура ОтключитьОтбор(ИндексОтбора)
	
	Если ИндексОтбора <> 0 Тогда
		ЭлементыОтбора = Отчет.КомпоновщикНастроек.Настройки.Отбор.Элементы;	
	    ПолеОтбора = ЭлементыОтбора.Получить(ИндексОтбора - 1);
		ПолеОтбора.Использование = Ложь;
	КонецЕсли;

КонецПроцедуры // ОтключитьОтбор()

&НаКлиенте
Процедура ПериодПриИзменении(Элемент)

	Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("Период", РФСтандартныйПериод);

КонецПроцедуры

&НаКлиенте
Процедура СкрытьНастройки(Команда)
	
	ЭлементФормыСкрытьНастройки = Элементы.ФормаСкрытьНастройки;
	ГруппаОтборы = Элементы.ГруппаОтборы;
	
	Если ЭлементФормыСкрытьНастройки.Пометка Тогда
		ЭлементФормыСкрытьНастройки.Пометка = Ложь;
		ГруппаОтборы.Видимость = Истина;
	Иначе
	    ЭлементФормыСкрытьНастройки.Пометка = Истина;
		ГруппаОтборы.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("ПериодОтчета") Тогда				
	    РФСтандартныйПериод = Параметры.ПериодОтчета;
	КонецЕсли;

		
	Если Параметры.Свойство("Исполнитель") Тогда		
		ОтборИсполнитель = Параметры.Исполнитель;
	КонецЕсли;
	
	Если Параметры.Свойство("Контрагент") Тогда		
		ОтборКонтрагент = Параметры.Контрагент;
	КонецЕсли;
	
	Если Параметры.Свойство("Статус") Тогда		
		ОтборСтатус = Параметры.Статус;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеВариантаНаСервере(Настройки)
	
	Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("Период", РФСтандартныйПериод);
	
	СтруктураОтбора = Новый Структура;
	ОтборИсполнительИндекс = 0;
	ОтборКонтрагентИндекс = 0;
	ОтборСтатусИндекс = 0;
	
	Если ЗначениеЗаполнено(ОтборИсполнитель) Тогда
		СтруктураОтбора.Вставить("ИмяПоляКД","Исполнитель");
		СтруктураОтбора.Вставить("ВидСравнения", ВидСравненияКомпоновкиДанных.Равно);
		СтруктураОтбора.Вставить("ЗначениеСравнения", ОтборИсполнитель);
		СтруктураОтбора.Вставить("ИндексПреведущегоЗначения", ОтборИсполнительИндекс);
		ОтборИсполнительИндекс = УстановитьОтборСКД(СтруктураОтбора);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОтборКонтрагент) Тогда
		СтруктураОтбора.Вставить("ИмяПоляКД","Контрагент");
		СтруктураОтбора.Вставить("ВидСравнения", ВидСравненияКомпоновкиДанных.Равно);
		СтруктураОтбора.Вставить("ЗначениеСравнения", ОтборКонтрагент);
		СтруктураОтбора.Вставить("ИндексПреведущегоЗначения", ОтборКонтрагентИндекс);
		ОтборКонтрагентИндекс = УстановитьОтборСКД(СтруктураОтбора);		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОтборСтатус) Тогда		
		СтруктураОтбора.Вставить("ИмяПоляКД","Статус");
		СтруктураОтбора.Вставить("ВидСравнения", ВидСравненияКомпоновкиДанных.Равно);
		СтруктураОтбора.Вставить("ЗначениеСравнения", ОтборКонтрагент);
		СтруктураОтбора.Вставить("ИндексПреведущегоЗначения", ОтборСтатусИндекс);	
		ОтборСтатусИндекс = УстановитьОтборСКД(СтруктураОтбора);		
	КонецЕсли;
	
КонецПроцедуры



