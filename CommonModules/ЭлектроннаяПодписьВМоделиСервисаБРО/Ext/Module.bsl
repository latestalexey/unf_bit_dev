﻿////////////////////////////////////////////////////////////////////////////////
// Подсистема "Электронная подпись в модели сервиса".
//  
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

Процедура УстановитьПараметрСеансаСеансовыеКлючиЭлектроннойПодписиВМоделиСервиса(ИмяПараметра = Неопределено, УстановленныеПараметры = Неопределено) Экспорт
	
	ПараметрыСеанса.СеансовыеКлючиЭлектроннойПодписиВМоделиСервиса = Новый ФиксированноеСоответствие(Новый Соответствие);
	
КонецПроцедуры

Функция АдресWSDL(URI) Экспорт
	
	Адрес = СокрЛП(URI);
	Если СтрНайти(НРег(Адрес), "?wsdl") = СтрДлина(Адрес) - 4 Тогда
		Возврат Адрес;
	Иначе
		Возврат Адрес + "?wsdl";		
	КонецЕсли;
	
КонецФункции

Функция ПодробноеПредставлениеИнформацияОбОшибке(ИнформацияОбОшибке) Экспорт
	
	Шаблон = "{%1(%2)}:%3
			|%4
			|%5";
			
	ПредставлениеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
							Шаблон, ИнформацияОбОшибке.ИмяМодуля, ИнформацияОбОшибке.НомерСтроки,
							ИнформацияОбОшибке.Описание, ИнформацияОбОшибке.ИсходнаяСтрока,
							СокрЛП(ПричинаОшибки(ИнформацияОбОшибке.Причина)));
							
	Возврат ПредставлениеОшибки;							

КонецФункции

Функция КраткоеПредставлениеИнформацияОбОшибке(ИнформацияОбОшибке) Экспорт
	
	Возврат ПолучитьИнформациюОбОшибке(ИнформацияОбОшибке).Описание;
	
КонецФункции

Процедура ПолучитьДействующиеКлючи(СтруктураПараметров, АдресХранилища) Экспорт 
	
	ТаблицаКлючей = МодульУчетаЗаявленийАбонентаВМоделиСервиса.ПолучитьДействующиеКлючи(
		СтруктураПараметров.ИНН, СтруктураПараметров.КПП, СтруктураПараметров.ОбластьДанных);
		
	ПоместитьВоВременноеХранилище(ТаблицаКлючей, АдресХранилища);	
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПричинаОшибки(ИнформацияОбОшибке)
	
	Результат = "";
	Если ИнформацияОбОшибке <> Неопределено Тогда
		Результат = "по причине:" + Символы.ПС + ИнформацияОбОшибке.Описание + Символы.ПС;
		Если ИнформацияОбОшибке.Причина <> Неопределено Тогда
			Результат = Результат + ПричинаОшибки(ИнформацияОбОшибке.Причина);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат; 		
		
КонецФункции

Функция ПолучитьИнформациюОбОшибке(ИнформацияОбОшибке)
	
	Результат = ИнформацияОбОшибке;
	Если ИнформацияОбОшибке <> Неопределено Тогда
		Если ИнформацияОбОшибке.Причина <> Неопределено Тогда
			Результат = ПолучитьИнформациюОбОшибке(ИнформацияОбОшибке.Причина);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти