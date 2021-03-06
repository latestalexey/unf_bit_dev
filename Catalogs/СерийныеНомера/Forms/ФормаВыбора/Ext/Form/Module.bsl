﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Отбор.Свойство("Владелец") Тогда
		ЭтотОбъект.Заголовок = "Серийные номера "+Параметры.Отбор.Владелец;
	ИначеЕсли Параметры.Свойство("ТекущаяСтрока") И ЗначениеЗаполнено(Параметры.ТекущаяСтрока) Тогда
		ЭтотОбъект.Заголовок = "Серийные номера "+Параметры.ТекущаяСтрока.Владелец;
	КонецЕсли;
	
	Если Параметры.Свойство("ПоказатьПроданные") Тогда
	    ПоказатьПроданные = Параметры.ПоказатьПроданные;
	Иначе	
		ПоказатьПроданные = Ложь;
	КонецЕсли;
	
	Список.Параметры.УстановитьЗначениеПараметра("ПоказатьПроданные", ПоказатьПроданные);
	Элементы.Продан.Видимость = ПоказатьПроданные;
			
КонецПроцедуры

&НаКлиенте
Процедура ПроданныеПриИзменении(Элемент)
	
	Элементы.Продан.Видимость = ПоказатьПроданные;
	Список.Параметры.УстановитьЗначениеПараметра("ПоказатьПроданные", ПоказатьПроданные);
	
КонецПроцедуры
