﻿
&НаКлиенте
Процедура Реквизит1Выбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ВыбранноеЗначение = Элементы.Реквизит1.ТекущиеДанные.Ссылка;
	
	стр = ВыбранныеОКУН.НайтиСтроки(Новый Структура("ОКУНЗначение", ВыбранноеЗначение));
	
	Если Стр.Количество() > 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Такой код уже выбран'"));
	Иначе
		новстр = ВыбранныеОКУН.Добавить();
		новстр.ОКУНЗначение = ВыбранноеЗначение;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбранныеОКУНВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Исключить(Неопределено);
КонецПроцедуры


&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если НЕ ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	стр = ВыбранныеОКУН.НайтиСтроки(Новый Структура("ОКУНЗначение", ВыбранноеЗначение));
	
	Если Стр.Количество() > 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Такой код уже выбран'"));
	Иначе
		новстр = ВыбранныеОКУН.Добавить();
		новстр.ОКУНЗначение = ВыбранноеЗначение;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Добавить(Команда)
	Для Каждого строка Из Элементы.Реквизит1.ВыделенныеСтроки Цикл
		стр = ВыбранныеОКУН.НайтиСтроки(Новый Структура("ОКУНЗначение", строка));
		
		Если Стр.Количество() > 0 Тогда
		Иначе
			новстр = ВыбранныеОКУН.Добавить();
			новстр.ОКУНЗначение = строка;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура Исключить(Команда)
	
	Для Каждого строка Из Элементы.ВыбранныеОКУН.ВыделенныеСтроки Цикл
		ВыбранныеОКУН.Удалить(ВыбранныеОКУН.НайтиПоИдентификатору(строка));
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
	
	массивУдаляемых = Новый Массив;
	
	Для Каждого Строка Из ВыбранныеОКУН Цикл
		Если НЕ ЗначениеЗаполнено(Строка.ОКУНЗначение) Тогда
			массивУдаляемых.Добавить(строка);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого Строка Из массивУдаляемых Цикл
		ВыбранныеОКУН.Удалить(Строка);
	КонецЦикла;
	
	Если ВыбранныеОКУН.Количество() > 0 Тогда
		массив = Новый Массив;
		
		Для Каждого Строка Из ВыбранныеОКУН Цикл
			массив.Добавить(Строка.ОКУНЗначение);
		КонецЦикла;
	Иначе
		массив = новый Массив;
	КонецЕсли;
	
	ОповеститьОВыборе(массив);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗакрыватьПриВыборе = Истина;
	
	Если Параметры.МассивОКУНОВ <> Неопределено Тогда
		Для Каждого Строка Из Параметры.МассивОКУНОВ Цикл
			ВыбранныеОКУН.Добавить().ОКУНЗначение = Строка;
		КонецЦикла;
	КонецЕсли;
	
	КлассификаторОКУН.Параметры.УстановитьЗначениеПараметра("ПараметрКОД", Параметры.КодПД);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбранныеОКУНПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	
	СтандартнаяОбработка = Ложь;
	ПараметрыПеретаскивания.ДопустимыеДействия = ДопустимыеДействияПеретаскивания.Копирование;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбранныеОКУНПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	Добавить(Элемент);
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура Реквизит1ПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	
	СтандартнаяОбработка = Ложь;
	ПараметрыПеретаскивания.ДопустимыеДействия = ДопустимыеДействияПеретаскивания.Копирование;
	
КонецПроцедуры

&НаКлиенте
Процедура Реквизит1Перетаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	
	Исключить(Элемент);
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры



