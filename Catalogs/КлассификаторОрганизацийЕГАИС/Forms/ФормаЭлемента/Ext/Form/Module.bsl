﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(Объект.Код) Тогда
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ИдентификаторФСРАР", Объект.Код);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ФорматыОбменаЕГАИС.ФорматОбмена КАК ФорматОбмена
		|ИЗ
		|	РегистрСведений.ФорматыОбменаЕГАИС КАК ФорматыОбменаЕГАИС
		|ГДЕ
		|	ФорматыОбменаЕГАИС.ИдентификаторФСРАР = &ИдентификаторФСРАР";
		
		РезультатЗапроса = Запрос.Выполнить();
		Элементы.ФорматОбмена.ТолькоПросмотр = НЕ РезультатЗапроса.Пустой();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ДоступностьЭлементовФормы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ТипОрганизацииПриИзменении(Элемент)
	
	ДоступностьЭлементовФормы();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ДоступностьЭлементовФормы()
	
	Элементы.ГруппаЮЛ.Видимость = Объект.ТипОрганизации = ПредопределенноеЗначение("Перечисление.ТипыОрганизацийЕГАИС.ЮридическоеЛицоРФ")
		ИЛИ Объект.ТипОрганизации.Пустая();
		
	Элементы.ГруппаИП.Видимость = Объект.ТипОрганизации = ПредопределенноеЗначение("Перечисление.ТипыОрганизацийЕГАИС.ИндивидуальныйПредпринимательРФ");
	Элементы.ГруппаТС.Видимость = Объект.ТипОрганизации = ПредопределенноеЗначение("Перечисление.ТипыОрганизацийЕГАИС.КонтрагентТаможенногоСоюза");
	
КонецПроцедуры

#КонецОбласти
