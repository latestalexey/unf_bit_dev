﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Документы.ТТНИсходящаяЕГАИС.УстановитьУсловноеОформлениеСтатусаОбработки(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ОбновитьСписокЗапросовЕГАИС" Тогда
		Элементы.Список.Обновить();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыгрузитьТТН(Команда)
	
	НачатьВыгрузкуДокумента(ПредопределенноеЗначение("Перечисление.ВидыДокументовЕГАИС.ТТН"));
	
КонецПроцедуры

&НаКлиенте
Процедура ПодтвердитьАктРасхождений(Команда)
	
	НачатьВыгрузкуДокумента(ПредопределенноеЗначение("Перечисление.ВидыДокументовЕГАИС.ПодтверждениеАктаРасхожденийТТН"));
	
КонецПроцедуры

&НаКлиенте
Процедура ОтказатьсяОтАктаРасхождений(Команда)
	
	НачатьВыгрузкуДокумента(ПредопределенноеЗначение("Перечисление.ВидыДокументовЕГАИС.ОтказОтАктаРасхожденийТТН"));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура НачатьВыгрузкуДокумента(ВидДокумента)
	
	Если Элементы.Список.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыЗапроса = ИнтеграцияЕГАИСКлиентСервер.ПараметрыИсходящегоЗапроса(ВидДокумента);
	ПараметрыЗапроса.ДокументСсылка = Элементы.Список.ТекущиеДанные.Ссылка;
	
	ОповещениеПриЗавершении = Новый ОписаниеОповещения("ВыгрузкаДокумента_Завершение", ЭтотОбъект);
	ИнтеграцияЕГАИСКлиент.НачатьФормированиеИсходящегоЗапроса(
		ОповещениеПриЗавершении,
		ВидДокумента,
		ПараметрыЗапроса);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузкаДокумента_Завершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат.Результат Тогда
		Элементы.Список.Обновить();
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Документ успешно выгружен.'"));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти