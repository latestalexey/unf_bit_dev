﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Процедура обновления БРО
// загружает избранные шаблоны статистики
Процедура ЗагрузитьРекомендуемыеЭлектронныеПредставления(Параметры = Неопределено) Экспорт
	
	Перем АдресВременногоХранилища;
	
	КоличествоНезагруженныхШаблонов = 0;
	
	Попытка
		ДобавитьШаблоныИзКонфигурации(АдресВременногоХранилища, КоличествоНезагруженныхШаблонов);
	Исключение
		СтрОш = НСтр("ru = 'Не удалось получить шаблоны для обновления'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
		ЗаписьЖурналаРегистрации(СтрОш, УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат;
	КонецПопытки;
	
	Попытка
		ЗагрузитьШаблоны(АдресВременногоХранилища, КоличествоНезагруженныхШаблонов);
	Исключение
		СтрОш = НСтр("ru = 'Не удалось распаковать шаблоны для обновления'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
		ЗаписьЖурналаРегистрации(СтрОш, УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат;
	КонецПопытки;
	
КонецПроцедуры

Процедура ДобавитьШаблоныИзКонфигурации(АдресВременногоХранилища, КоличествоНезагруженныхШаблонов)
	
	ВремФайлАрхиваШаблонов = ПолучитьИмяВременногоФайла("zip");
	АрхивШаблоновЭВФДвоичныеДанные = РегистрыСведений.ШаблоныЭВФОтчетовСтатистики.ПолучитьМакет("ОбновляемыеШаблоны");
	Попытка
		АрхивШаблоновЭВФДвоичныеДанные.Записать(ВремФайлАрхиваШаблонов);
	Исключение
		ВызватьИсключение "Не удалось сохранить архив шаблонов ЭВФ во временный файл." + Символы.ПС + ОписаниеОшибки();
	КонецПопытки;
	
	КаталогВремФайлов = КаталогВременныхФайлов();
	КаталогВремФайлов = ?(Прав(КаталогВремФайлов, 1) = "\", КаталогВремФайлов, КаталогВремФайлов + "\");
	ВремКаталог = КаталогВремФайлов + Строка(Новый УникальныйИдентификатор) + "\";
	
	Попытка
		ЗИП = Новый ЧтениеZipФайла(ВремФайлАрхиваШаблонов);
		ЗИП.ИзвлечьВсе(ВремКаталог, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
		ЗИП.Закрыть();
	Исключение
		ВызватьИсключение "Не удалось распаковать архив шаблонов ЭВФ.
				|" + ИнформацияОбОшибке().Описание;
		Возврат;
	КонецПопытки;
	
	ОбъектыФайл = НайтиФайлы(ВремКаталог, "*.xml", Ложь);
	
	ШаблоныЭВФ = Новый Массив;
	
	Для Каждого ОбъектФайл Из ОбъектыФайл Цикл
		
		Если ОбъектФайл.Существует() Тогда
			
			ШаблонЭВФ = Новый Структура;
			ШаблонЭВФ.Вставить("ИмяФайлаШаблона", НРег(ОбъектФайл.Имя));
			ШаблонЭВФ.Вставить("Размер", ОбъектФайл.Размер());
			
			Попытка
				ШаблонЭВФ.Вставить("Шаблон", Новый ДвоичныеДанные(ОбъектФайл.ПолноеИмя));
				ШаблоныЭВФ.Добавить(ШаблонЭВФ);
			Исключение
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru='Не удалось загрузить XML-шаблон ""%1"":%2'"), ОбъектФайл.Имя, Символы.ПС + ОписаниеОшибки());
				Сообщение.Сообщить();
				
				КоличествоНезагруженныхШаблонов = КоличествоНезагруженныхШаблонов + 1;
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЦикла;
	
	АдресВременногоХранилища = ПоместитьВоВременноеХранилище(ШаблоныЭВФ, Новый УникальныйИдентификатор);
	
	УдалитьФайлы(ВремФайлАрхиваШаблонов);
	Попытка
		УдалитьФайлы(ВремКаталог);
	Исключение
		СтрОш = НСтр("ru = 'Не удалось удалить временные файлы'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
		ЗаписьЖурналаРегистрации(СтрОш, УровеньЖурналаРегистрации.Предупреждение,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
КонецПроцедуры

Функция ДатаВерсии(СтрДата)
	
	Разделители = "-.,/";
	
	ДлинаСтроки = СтрДлина(СтрДата);
	
	МассивПолей = Новый Массив;
	МассивПолей.Добавить("");
	
	Для НС = 1 По ДлинаСтроки Цикл
		Сим = Сред(СтрДата, НС, 1);
		Если СтрНайти(Разделители, Сим) > 0 Тогда
			МассивПолей.Добавить("");
		ИначеЕсли СтрНайти("0123456789", Сим) > 0 Тогда
			МассивПолей[МассивПолей.ВГраница()] = МассивПолей[МассивПолей.ВГраница()] + Сим;
		КонецЕсли;
	КонецЦикла;
	
	День  = Макс(1, Число("0" + СокрЛП(МассивПолей[0])));
	Месяц = Макс(1, Число("0" + ?(МассивПолей.ВГраница() < 1, "1", СокрЛП(МассивПолей[1]))));
	Год   = Макс(1, Число("0" + ?(МассивПолей.ВГраница() < 2, "1", СокрЛП(МассивПолей[2]))));
	
	Возврат Дата(Год, Месяц, День);
	
КонецФункции

Функция ДобавитьРеквизитыИзФайлаШаблона(РеквизитыШаблона)
	
	Если ТипЗнч(РеквизитыШаблона) <> Тип("Структура") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ВремФайлШаблона = ПолучитьИмяВременногоФайла("." + РеквизитыШаблона.ИмяФайлаШаблона);
	
	Попытка
		РеквизитыШаблона.Шаблон.Записать(ВремФайлШаблона);
	Исключение
		Возврат Ложь;
	КонецПопытки;

	АтрибутыШаблона = Новый Соответствие;
	ОбъектЧтениеXML = Новый ЧтениеXML;
	
	Попытка
		
		ОбъектЧтениеXML.ОткрытьФайл(ВремФайлШаблона);
		ОбъектЧтениеXML.ИгнорироватьПробелы = Ложь;
		
		Пока ОбъектЧтениеXML.Прочитать() Цикл
			Если ОбъектЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
				Если НРег(ОбъектЧтениеXML.Имя) = "metaform" Тогда
					Пока ОбъектЧтениеXML.ПрочитатьАтрибут() Цикл
						Если АтрибутыШаблона[ОбъектЧтениеXML.Имя] = Неопределено Тогда
							АтрибутыШаблона.Вставить(СтрЗаменить(ОбъектЧтениеXML.Имя, "-", "_"), ОбъектЧтениеXML.Значение);
						КонецЕсли;
					КонецЦикла;
					Прервать;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		ОбъектЧтениеXML.Закрыть();
		
	Исключение
		
		Возврат Ложь;
		
	КонецПопытки;
	
	УдалитьФайлы(ВремФайлШаблона);
	
	Если АтрибутыШаблона.Количество() = 0 Тогда
	
		Возврат Ложь;
	
	КонецЕсли;
	
	РеквизитыШаблона.Вставить("ОКУД",             АтрибутыШаблона["OKUD"]);
	РеквизитыШаблона.Вставить("КодШаблона",       АтрибутыШаблона["code"]);
	РеквизитыШаблона.Вставить("Наименование",     ВРег(Лев(АтрибутыШаблона["name"], 1)) + Сред(АтрибутыШаблона["name"], 2));
	РеквизитыШаблона.Вставить("КодПериодичности", Число("0" + АтрибутыШаблона["idp"]));
	РеквизитыШаблона.Вставить("КодФормы",         Число("0" + АтрибутыШаблона["idf"]));
	РеквизитыШаблона.Вставить("Шифр",             АтрибутыШаблона["shifr"]);
	РеквизитыШаблона.Вставить("Версия",           АтрибутыШаблона["version"]);
	РеквизитыШаблона.Вставить("ВерсияФормата",    АтрибутыШаблона["format_version"]);
	
	Возврат Истина;
	
КонецФункции

Процедура ЗагрузитьШаблоны(АдресВременногоХранилища, КоличествоНезагруженныхШаблонов)
	ШаблоныЭВФ = ПолучитьИзВременногоХранилища(АдресВременногоХранилища);
	
	Для Каждого ШаблонЭВФ Из ШаблоныЭВФ Цикл
		
		Если НЕ ДобавитьРеквизитыИзФайлаШаблона(ШаблонЭВФ) Тогда
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru='Не распознан формат XML-шаблона ""%1""'"), ШаблонЭВФ.ИмяФайлаШаблона);
			Сообщение.Сообщить();
			
			КоличествоНезагруженныхШаблонов = КоличествоНезагруженныхШаблонов + 1;
			
			Продолжить;
			
		КонецЕсли;
		
		Если СтрНайти(ШаблонЭВФ.ВерсияФормата, "1.3") = 0 Тогда
		
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru='Версия формата XML-шаблона ""%1"" не соответствует версии ""1.3""'"), ШаблонЭВФ.ИмяФайлаШаблона);
			Сообщение.Сообщить();
			
			КоличествоНезагруженныхШаблонов = КоличествоНезагруженныхШаблонов + 1;
			
			Продолжить;
		
		КонецЕсли;
		
		МенеджерЗаписи = РегистрыСведений.ШаблоныЭВФОтчетовСтатистики.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.ИмяФайлаШаблона  = ШаблонЭВФ.ИмяФайлаШаблона;
		МенеджерЗаписи.Прочитать();
		Если МенеджерЗаписи.Выбран() Тогда
			Если ДатаВерсии(МенеджерЗаписи.Версия) > ДатаВерсии(ШаблонЭВФ.Версия) Тогда
				
				КоличествоНезагруженныхШаблонов = КоличествоНезагруженныхШаблонов + 1;
				
				Продолжить;
				
			КонецЕсли;
		КонецЕсли;
		
		МенеджерЗаписи.ИмяФайлаШаблона  = ШаблонЭВФ.ИмяФайлаШаблона;
		
		МенеджерЗаписи.ОКУД             = ШаблонЭВФ.ОКУД;
		МенеджерЗаписи.КодШаблона       = ШаблонЭВФ.КодШаблона;
		МенеджерЗаписи.Наименование     = ШаблонЭВФ.Наименование;
		МенеджерЗаписи.КодПериодичности = ШаблонЭВФ.КодПериодичности;
		МенеджерЗаписи.КодФормы         = ШаблонЭВФ.КодФормы;
		МенеджерЗаписи.Шифр             = ШаблонЭВФ.Шифр;
		МенеджерЗаписи.Версия           = ШаблонЭВФ.Версия;
		
		МенеджерЗаписи.Размер           = ШаблонЭВФ.Размер;
		МенеджерЗаписи.ДатаДобавления   = ТекущаяДатаСеанса();
		
		Попытка
			
			МенеджерЗаписи.Шаблон = Новый ХранилищеЗначения(ШаблонЭВФ.Шаблон, Новый СжатиеДанных(8));
			МенеджерЗаписи.Записать(Истина);
			
		Исключение
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru='Не удалось записать XML-шаблон ""%1"":%2'"), ШаблонЭВФ.ИмяФайлаШаблона, Символы.ПС + ОписаниеОшибки());
			Сообщение.Сообщить();
			
			КоличествоНезагруженныхШаблонов = КоличествоНезагруженныхШаблонов + 1;
			
		КонецПопытки;
		
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#КонецЕсли