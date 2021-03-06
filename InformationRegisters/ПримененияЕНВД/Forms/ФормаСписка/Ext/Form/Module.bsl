﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СтруктурныеЕдиницы.Ссылка
	|ИЗ
	|	Справочник.СтруктурныеЕдиницы КАК СтруктурныеЕдиницы
	|ГДЕ
	|	(СтруктурныеЕдиницы.ТипСтруктурнойЕдиницы = ЗНАЧЕНИЕ(Перечисление.ТипыСтруктурныхЕдиниц.Розница)
	|			ИЛИ СтруктурныеЕдиницы.ТипСтруктурнойЕдиницы = ЗНАЧЕНИЕ(Перечисление.ТипыСтруктурныхЕдиниц.РозницаСуммовойУчет))";
	
	Если Запрос.Выполнить().Пустой() Тогда
		Элементы.Список.ТолькоПросмотр = Истина;
		АвтоЗаголовок = Ложь;
		Заголовок = НСтр("ru = 'Применение ЕНВД предусмотрено, если заведены розничные склады'");
	КонецЕсли;
	
КонецПроцедуры
