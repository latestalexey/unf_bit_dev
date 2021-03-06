﻿
&НаСервере
Процедура ЗаполнитьБазуТоваров()
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	Рег.Штрихкод КАК Штрихкод,
	|	ПРЕДСТАВЛЕНИЕ(Рег.Номенклатура) КАК Номенклатура,
	|	ПРЕДСТАВЛЕНИЕ(Рег.Характеристика) КАК Характеристика,
	|	ПРЕДСТАВЛЕНИЕ(Рег.Партия) КАК Партия,
	|	Рег.Номенклатура.АлкогольнаяПродукция КАК Алкоголь,
	|	ВЫБОР
	|		КОГДА Рег.Номенклатура.АлкогольнаяПродукция
	|			ТОГДА Рег.Номенклатура.ВидАлкогольнойПродукции.Маркируемый
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК Маркируемый,
	|	ВЫБОР
	|		КОГДА Рег.Номенклатура.АлкогольнаяПродукция
	|			ТОГДА Рег.Номенклатура.ВидАлкогольнойПродукции.Код
	|		ИНАЧЕ НЕОПРЕДЕЛЕНО
	|	КОНЕЦ КАК КодВидаАлкогольнойПродукции,
	|	ВЫБОР
	|		КОГДА Рег.Номенклатура.АлкогольнаяПродукция
	|			ТОГДА Рег.Номенклатура.ОбъемДАЛ * 10
	|		ИНАЧЕ НЕОПРЕДЕЛЕНО
	|	КОНЕЦ КАК ЕмкостьТары,
	|	ВЫБОР
	|		КОГДА Рег.Номенклатура.АлкогольнаяПродукция
	|			ТОГДА Рег.Номенклатура.Крепость
	|		ИНАЧЕ НЕОПРЕДЕЛЕНО
	|	КОНЕЦ КАК Крепость,
	|	ВЫБОР
	|		КОГДА Рег.Номенклатура.АлкогольнаяПродукция
	|			ТОГДА Рег.Номенклатура.ПроизводительИмпортерАлкогольнойПродукции.ИНН
	|		ИНАЧЕ НЕОПРЕДЕЛЕНО
	|	КОНЕЦ КАК ИННПроизводителя,
	|	ВЫБОР
	|		КОГДА Рег.Номенклатура.АлкогольнаяПродукция
	|			ТОГДА Рег.Номенклатура.ПроизводительИмпортерАлкогольнойПродукции.КПП
	|		ИНАЧЕ НЕОПРЕДЕЛЕНО
	|	КОНЕЦ КАК КПППроизводителя
	|ИЗ
	|	РегистрСведений.ШтрихкодыНоменклатуры КАК Рег
	|
	|УПОРЯДОЧИТЬ ПО
	|	Рег.Штрихкод");
	
	ТекТаблица = Запрос.Выполнить().Выгрузить();
	
	ЗначениеВРеквизитФормы(ТекТаблица, "ТаблицаВыгрузки");
	
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивБазыТоваров()
	
	ТекТаблица = РеквизитФормыВЗначение("ТаблицаВыгрузки");
	
	МассивВыгрузки = Новый Массив();
	
	Для каждого СтрокаТЧ Из ТекТаблица Цикл
		ВыгружаемыйТовар = Новый Структура(
			"Штрихкод, Номенклатура, ЕдиницаИзмерения, ХарактеристикаНоменклатуры, СерияНоменклатуры, Качество, Цена, Количество",
			СтрокаТЧ.Штрихкод, СтрокаТЧ.Номенклатура, СтрокаТЧ.Партия, СтрокаТЧ.Характеристика, "", "" , "", 0);
			
		Если ВыгружатьРеквизитыАлкогольнойПродукции Тогда
			ВыгружаемыйТовар.Вставить("Алкоголь"                   , СтрокаТЧ.Алкоголь);
			ВыгружаемыйТовар.Вставить("Маркируемый"                , СтрокаТЧ.Маркируемый);
			ВыгружаемыйТовар.Вставить("КодВидаАлкогольнойПродукции", СтрокаТЧ.КодВидаАлкогольнойПродукции);
			ВыгружаемыйТовар.Вставить("КодАлкогольнойПродукции"    , "");
			ВыгружаемыйТовар.Вставить("ЕмкостьТары"                , СтрокаТЧ.ЕмкостьТары);
			ВыгружаемыйТовар.Вставить("Крепость"                   , СтрокаТЧ.Крепость);
			ВыгружаемыйТовар.Вставить("ИННПроизводителя"           , СтрокаТЧ.ИННПроизводителя);
			ВыгружаемыйТовар.Вставить("КПППроизводителя"           , СтрокаТЧ.КПППроизводителя);
		КонецЕсли;
		
		МассивВыгрузки.Добавить(ВыгружаемыйТовар);
	КонецЦикла;
	
	Возврат МассивВыгрузки;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьВыполнить()
	
	ЗаполнитьБазуТоваров();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьВыполнить()
	
	ОписаниеОшибки = "";
	ЭтаФорма.Доступность = Ложь; 
	
	ОповещенияПриВыгрузкеВТСД = Новый ОписаниеОповещения("ВыгрузитьВТСДЗавершение", ЭтотОбъект);
	МенеджерОборудованияКлиент.НачатьВыгрузкуДанныеВТСД(ОповещенияПриВыгрузкеВТСД, УникальныйИдентификатор, ПолучитьМассивБазыТоваров());
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьВТСДЗавершение(РезультатВыполнения, Параметры) Экспорт
	
	ЭтаФорма.Доступность = Истина; 
	
	Если РезультатВыполнения.Результат Тогда
		ТекстСообщения = НСтр("ru = 'Данные успешно выгружены в ТСД.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИспользоватьАлкогольнуюПродукцию = ПолучитьФункциональнуюОпцию("ВестиСведенияДляДекларацийПоАлкогольнойПродукции");
	ВыгружатьРеквизитыАлкогольнойПродукции = Ложь;
	Элементы.ВыгружатьРеквизитыАлкогольнойПродукции.Видимость = ИспользоватьАлкогольнуюПродукцию;
	Элементы.ТоварыГруппаАлкоголь.Видимость = ВыгружатьРеквизитыАлкогольнойПродукции;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгружатьРеквизитыАлкогольнойПродукцииПриИзменении(Элемент)
	
	Элементы.ТоварыГруппаАлкоголь.Видимость = ВыгружатьРеквизитыАлкогольнойПродукции;
	
КонецПроцедуры
