﻿
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

Функция ПолучитьСтруктуруПараметровОбмена()

	ОсновныеПараметры = ОбменССайтом.ПолучитьСтруктуруОсновныхПараметровОбмена();
	
	ОсновныеПараметры.Вставить("ОбменЧерезВебСервис", Истина);
	ОсновныеПараметры.Вставить("МассивВидовЦен", Новый Массив);
	ОсновныеПараметры.Вставить("ВыгружатьОстаткиПоСкладам", Ложь);
	
	// Для совместимости с функциями общего модуля ОбменССайтом
	ОсновныеПараметры.Вставить("ВыгружатьКартинки", Ложь);
	
	СтруктураТаблицыКаталогов = Новый Структура;
	
	СписокГрупп = Новый СписокЗначений;
	СтруктураТаблицыКаталогов.Вставить("СписокГрупп", СписокГрупп);
	
	СтруктураРезультата = Новый Структура("ВыгруженоТоваров,ВыгруженоКартинок,ВыгруженоПредложений,ОписаниеОшибки", 0, 0, 0, "");
	СтруктураТаблицыКаталогов.Вставить("СтруктураРезультата", СтруктураРезультата);
	
	ОсновныеПараметры.Вставить("СтрокаТаблицыКаталогов", СтруктураТаблицыКаталогов);
	
	URI = "urn:1C.ru:commerceml_205";
	ПакетCML = ФабрикаXDTO.Пакеты.Получить(URI);
	
	КоммерческаяИнформацияТип = ПакетCML.Получить("КоммерческаяИнформация");
	КоммерческаяИнформацияXDTO = ФабрикаXDTO.Создать(КоммерческаяИнформацияТип);
	
	КоммерческаяИнформацияXDTO.ВерсияСхемы = "2.05";
	КоммерческаяИнформацияXDTO.ДатаФормирования = ОсновныеПараметры.ДатаФормирования;
	
	ОсновныеПараметры.Вставить("ПустойПакетXDTO", КоммерческаяИнформацияXDTO);
	
	Возврат ОсновныеПараметры;
	
КонецФункции // ПолучитьСтруктуруПараметровОбмена()

Функция ПолучитьСсылкуПоИдентификатору(МенеджерОбъекта, Знач СтрокаGUID)
	
	НовыйGUID = Новый УникальныйИдентификатор(СтрокаGUID);
	
	Попытка
		СсылкаНаОбъект = МенеджерОбъекта.ПолучитьСсылку(НовыйGUID);
	Исключение
		ОписаниеОшибки = ИнформацияОбОшибке();
		ЗаписьЖурналаРегистрации(НСТр("ru = 'GetPicture: не удалось получить объект по идентификатору.'"), УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки.Описание);
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат СсылкаНаОбъект;
	
КонецФункции

// Получает файлы, присоединенные к товарам.
//
// Параметры:
//	МассивСссылокНаТовары - массив, содержащий ссылки на товары.
//	РазрешенныеТипыКартинок - массив, содержащий разрешенные типы картинок.
//
// Возвращаемое значение:
//	Выборка файлов.
//
Функция ПолучитьПрисоединенныеФайлы(МассивСссылокНаТовары, РазрешенныеТипыКартинок)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.ФайлКартинки КАК ФайлКартинки
	|ПОМЕСТИТЬ ВременнаяТаблицаОсновныеИзображения
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Ссылка В(&МассивСссылокНаТовары)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ФайлКартинки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Файлы.ВладелецФайла КАК Номенклатура,
	|	Файлы.Ссылка КАК Файл,
	|	Файлы.Наименование КАК Наименование,
	|	Файлы.Описание КАК Описание,
	|	Файлы.ТекущаяВерсияТом КАК Том,
	|	Файлы.ТекущаяВерсияРасширение КАК Расширение,
	|	Файлы.ТекущаяВерсияПутьКФайлу КАК ПутьКФайлу,
	|	Файлы.ТекущаяВерсия КАК ТекущаяВерсия
	|ПОМЕСТИТЬ ВременнаяТаблицаФайлы
	|ИЗ
	|	Справочник.Файлы КАК Файлы
	|ГДЕ
	|	Файлы.ВладелецФайла В(&МассивСссылокНаТовары)
	|	И Файлы.ТекущаяВерсияРасширение В(&РазрешенныеТипыКартинок)
	|	И Файлы.Ссылка = ВЫРАЗИТЬ(Файлы.ВладелецФайла КАК Справочник.Номенклатура).Ссылка.ФайлКартинки
	|	И Файлы.Ссылка В
	|			(ВЫБРАТЬ
	|				ВременнаяТаблицаОсновныеИзображения.ФайлКартинки
	|			ИЗ
	|				ВременнаяТаблицаОсновныеИзображения КАК ВременнаяТаблицаОсновныеИзображения)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ТекущаяВерсия
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВременнаяТаблицаФайлы.Номенклатура КАК Номенклатура,
	|	ВременнаяТаблицаФайлы.Файл КАК Файл,
	|	ВременнаяТаблицаФайлы.Наименование КАК Наименование,
	|	ВременнаяТаблицаФайлы.Описание КАК Описание,
	|	ВременнаяТаблицаФайлы.Том КАК Том,
	|	ВременнаяТаблицаФайлы.Расширение КАК Расширение,
	|	ВременнаяТаблицаФайлы.ПутьКФайлу КАК ПутьКФайлу,
	|	ХранимыеФайлыВерсий.ВерсияФайла.ТипХраненияФайла КАК ТипХраненияФайла,
	|	ХранимыеФайлыВерсий.ХранимыйФайл КАК ХранимыйФайл
	|ИЗ
	|	ВременнаяТаблицаФайлы КАК ВременнаяТаблицаФайлы
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ХранимыеФайлыВерсий КАК ХранимыеФайлыВерсий
	|		ПО ВременнаяТаблицаФайлы.ТекущаяВерсия = ХранимыеФайлыВерсий.ВерсияФайла
	|			И (ХранимыеФайлыВерсий.ВерсияФайла.ТипХраненияФайла = ЗНАЧЕНИЕ(Перечисление.ТипыХраненияФайлов.ВИнформационнойБазе))
	|
	|УПОРЯДОЧИТЬ ПО
	|	Номенклатура";
	
	Запрос.УстановитьПараметр("РазрешенныеТипыКартинок", РазрешенныеТипыКартинок);
	Запрос.УстановитьПараметр("МассивСссылокНаТовары", МассивСссылокНаТовары);
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

// Формирует пакетный запрос для получения необходимых данных для выгрузки классификатора и каталога.
//
Процедура ДобавитьЗапросыВПакетныйЗапросДляВыгрузкиНоменклатуры(ТекстЗапроса, Параметры)
	
	ТекстЗапроса = ТекстЗапроса + Символы.ПС + ";" + Символы.ПС
		+ "ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВременнаяТаблицаНоменклатура.Номенклатура КАК Номенклатура,
		|	ВременнаяТаблицаНоменклатура.ПометкаУдаления КАК ПометкаУдаления,
		|	ВременнаяТаблицаНоменклатура.Родитель КАК Родитель,
		|	ВременнаяТаблицаНоменклатура.Код КАК Код,
		|	ВременнаяТаблицаНоменклатура.Наименование КАК Наименование,
		|	ПОДСТРОКА(ВременнаяТаблицаНоменклатура.Номенклатура.НаименованиеПолное, 1, 100) КАК НаименованиеПолное,
		|	ПОДСТРОКА(ВременнаяТаблицаНоменклатура.Номенклатура.Комментарий, 1, 200) КАК Комментарий,
		|	ВременнаяТаблицаНоменклатура.Артикул КАК Артикул,
		|	ВременнаяТаблицаНоменклатура.ВидНоменклатуры КАК ВидНоменклатуры,
		|	ВременнаяТаблицаНоменклатура.ТипНоменклатуры КАК ТипНоменклатуры,
		|	ВременнаяТаблицаНоменклатура.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
		|	ВременнаяТаблицаНоменклатура.ЕдиницаИзмеренияКод КАК ЕдиницаИзмеренияКод,
		|	ВременнаяТаблицаНоменклатура.ЕдиницаИзмеренияНаименованиеПолное КАК ЕдиницаИзмеренияНаименованиеПолное,
		|	ВременнаяТаблицаНоменклатура.ЕдиницаИзмеренияМеждународноеСокращение КАК ЕдиницаИзмеренияМеждународноеСокращение,
		|	ВременнаяТаблицаНоменклатура.СтавкаНДС КАК СтавкаНДС,
		|	ВременнаяТаблицаНоменклатура.ФайлКартинки КАК ФайлКартинки,
		|	ЕСТЬNULL(ВременнаяТаблицаШтрихкодыДляКаталога.Штрихкод, """") КАК ШтрихКод
		|ИЗ
		|	ВременнаяТаблицаНоменклатура КАК ВременнаяТаблицаНоменклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВременнаяТаблицаШтрихкодыДляКаталога КАК ВременнаяТаблицаШтрихкодыДляКаталога
		|		ПО ВременнаяТаблицаНоменклатура.Номенклатура = ВременнаяТаблицаШтрихкодыДляКаталога.Номенклатура
		|
		|УПОРЯДОЧИТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ВременнаяТаблицаШтрихкодыДляКаталога
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВременнаяТаблицаНоменклатура.Номенклатура КАК Номенклатура,
		|	ВременнаяТаблицаНоменклатура.Характеристика КАК Характеристика,
		|	ХарактеристикиНоменклатурыДополнительныеРеквизиты.Свойство КАК Свойство,
		|	ХарактеристикиНоменклатурыДополнительныеРеквизиты.Свойство.Наименование КАК Наименование,
		|	ХарактеристикиНоменклатурыДополнительныеРеквизиты.Значение КАК Значение
		|ИЗ
		|	ВременнаяТаблицаНоменклатура КАК ВременнаяТаблицаНоменклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ХарактеристикиНоменклатуры.ДополнительныеРеквизиты КАК ХарактеристикиНоменклатурыДополнительныеРеквизиты
		|		ПО ВременнаяТаблицаНоменклатура.Характеристика = ХарактеристикиНоменклатурыДополнительныеРеквизиты.Ссылка
		|ГДЕ
		|	НЕ ВременнаяТаблицаНоменклатура.Характеристика = ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка)
		|ИТОГИ ПО
		|	Номенклатура, Характеристика
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
		|	ДополнительныеРеквизиты.Номенклатура КАК Номенклатура,
		|	ДополнительныеРеквизиты.Свойство КАК Свойство,
		|	ЗначенияДополнительныхРеквизитов.Значение КАК Значение
		|ПОМЕСТИТЬ ВременнаяТаблицаСвойстваНоменклатуры
		|ИЗ
		|	(ВЫБРАТЬ
		|		ВременнаяТаблицаНоменклатура.Номенклатура КАК Номенклатура,
		|		НаборыДополнительныхРеквизитовИСведенийДополнительныеРеквизиты.Свойство КАК Свойство
		|	ИЗ
		|		ВременнаяТаблицаНоменклатура КАК ВременнаяТаблицаНоменклатура
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеРеквизиты КАК НаборыДополнительныхРеквизитовИСведенийДополнительныеРеквизиты
		|			ПО (НаборыДополнительныхРеквизитовИСведенийДополнительныеРеквизиты.Ссылка = ЗНАЧЕНИЕ(Справочник.НаборыДополнительныхРеквизитовИСведений.Справочник_Номенклатура))) КАК ДополнительныеРеквизиты
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура.ДополнительныеРеквизиты КАК ЗначенияДополнительныхРеквизитов
		|		ПО ДополнительныеРеквизиты.Номенклатура = ЗначенияДополнительныхРеквизитов.Ссылка
		|			И ДополнительныеРеквизиты.Свойство = ЗначенияДополнительныхРеквизитов.Свойство
		|	
		|ОБЪЕДИНИТЬ
		|	
		|ВЫБРАТЬ
		|	ДополнительныеСведения.Номенклатура,
		|	ДополнительныеСведения.Свойство,
		|	ЗначенияДополнительныхСведений.Значение
		|ИЗ
		|	(ВЫБРАТЬ
		|		ВременнаяТаблицаНоменклатура.Номенклатура КАК Номенклатура,
		|		НаборыДополнительныхРеквизитовИСведенийДополнительныеСведения.Свойство КАК Свойство
		|	ИЗ
		|		ВременнаяТаблицаНоменклатура КАК ВременнаяТаблицаНоменклатура
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеСведения КАК НаборыДополнительныхРеквизитовИСведенийДополнительныеСведения
		|			ПО (НаборыДополнительныхРеквизитовИСведенийДополнительныеСведения.Ссылка = ЗНАЧЕНИЕ(Справочник.НаборыДополнительныхРеквизитовИСведений.Справочник_Номенклатура))) КАК ДополнительныеСведения
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК ЗначенияДополнительныхСведений
		|		ПО ДополнительныеСведения.Номенклатура = ЗначенияДополнительныхСведений.Объект
		|			И ДополнительныеСведения.Свойство = ЗначенияДополнительныхСведений.Свойство
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаСвойстваНоменклатуры.Свойство КАК Свойство,
		|	ТаблицаСвойстваНоменклатуры.Свойство.ТипЗначения КАК ТипЗначения,
		|	ТаблицаСвойстваНоменклатуры.Значение КАК Значение
		|ИЗ
		|	(ВЫБРАТЬ РАЗЛИЧНЫЕ
		|		ВременнаяТаблицаСвойстваНоменклатуры.Свойство КАК Свойство,
		|		ВременнаяТаблицаСвойстваНоменклатуры.Значение КАК Значение
		|	ИЗ
		|		ВременнаяТаблицаСвойстваНоменклатуры КАК ВременнаяТаблицаСвойстваНоменклатуры) КАК ТаблицаСвойстваНоменклатуры
		|ИТОГИ ПО
		|	Свойство
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВременнаяТаблицаСвойстваНоменклатуры.Номенклатура КАК Номенклатура,
		|	ВременнаяТаблицаСвойстваНоменклатуры.Свойство КАК Свойство,
		|	ВременнаяТаблицаСвойстваНоменклатуры.Значение КАК Значение
		|ИЗ
		|	ВременнаяТаблицаСвойстваНоменклатуры КАК ВременнаяТаблицаСвойстваНоменклатуры
		|
		|УПОРЯДОЧИТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ВременнаяТаблицаСвойстваНоменклатуры
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
		|	Организации.Ссылка КАК Контрагент,
		|	Организации.Наименование КАК Наименование,
		|	Организации.НаименованиеПолное КАК НаименованиеПолное,
		|	Организации.ЮридическоеФизическоеЛицо КАК ЮрФизЛицо,
		|	Организации.ИНН КАК ИНН,
		|	Организации.КПП КАК КПП,
		|	Организации.КодПоОКПО КАК КодПоОКПО,
		|	Организации.КонтактнаяИнформация.(
		|		Тип КАК Тип,
		|		Вид КАК Вид,
		|		Представление КАК Представление,
		|		ЗначенияПолей КАК ЗначенияПолей
		|	) КАК КонтактнаяИнформация
		|ИЗ
		|	Справочник.Организации КАК Организации
		|ГДЕ
		|	Организации.Ссылка = &ОрганизацияВладелецКаталога
		|;
		|
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВременнаяТаблицаНоменклатура.Номенклатура КАК Номенклатура
		|ИЗ
		|	ВременнаяТаблицаНоменклатура КАК ВременнаяТаблицаНоменклатура
		|ИТОГИ ПО
		|	Номенклатура ТОЛЬКО ИЕРАРХИЯ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ВременнаяТаблицаНоменклатура";
	
КонецПроцедуры

Процедура УстановитьОтборыКомпоновщика(	КомпоновщикНастроек, 
										ДатаИзменения = Неопределено, 
										КодГруппы = Неопределено, 
										КодСклада = Неопределено, 
										КодОрганизации = Неопределено) Экспорт
	
	Отбор = КомпоновщикНастроек.Настройки.Отбор;
	
	Если ТипЗнч(ДатаИзменения) = Тип("Дата") И ЗначениеЗаполнено(ДатаИзменения) Тогда
		
		НовыйЭлемент = Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		НовыйЭлемент.ИдентификаторПользовательскойНастройки = "ПрограммныйОтборПоДатеИзменения";
		НовыйЭлемент.ЛевоеЗначение 	= Новый ПолеКомпоновкиДанных("Номенклатура.ДатаИзменения");
		НовыйЭлемент.ВидСравнения 	= ВидСравненияКомпоновкиДанных.БольшеИлиРавно;
		НовыйЭлемент.ПравоеЗначение = ДатаИзменения;
		НовыйЭлемент.Использование 	= Истина;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КодГруппы) Тогда
		
		ГруппаНоменклатуры = Справочники.Номенклатура.НайтиПоКоду(КодГруппы);
		
		Если ЗначениеЗаполнено(ГруппаНоменклатуры) Тогда
			НовыйЭлемент = Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
			НовыйЭлемент.ИдентификаторПользовательскойНастройки = "ПрограммныйОтборПоГруппе";
			НовыйЭлемент.ЛевоеЗначение 	= Новый ПолеКомпоновкиДанных("Номенклатура");
			НовыйЭлемент.ВидСравнения 	= ВидСравненияКомпоновкиДанных.ВИерархии;
			НовыйЭлемент.ПравоеЗначение = ГруппаНоменклатуры;
			НовыйЭлемент.Использование 	= Истина;
		КонецЕсли;
		
	КонецЕсли;

	Если ЗначениеЗаполнено(КодСклада) Тогда
		
		Склад = Справочники.СтруктурныеЕдиницы.НайтиПоКоду(КодСклада);
		Если Склад = Неопределено Тогда
			Склад = Справочники.СтруктурныеЕдиницы.ПустаяСсылка();
		КонецЕсли;
		
		НовыйЭлемент = Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		НовыйЭлемент.ИдентификаторПользовательскойНастройки = "ПрограммныйОтборПоСкладу";
		НовыйЭлемент.ЛевоеЗначение 	= Новый ПолеКомпоновкиДанных("СкладДляОстатков");
		НовыйЭлемент.ВидСравнения 	= ВидСравненияКомпоновкиДанных.Равно;
		НовыйЭлемент.ПравоеЗначение = Склад;
		НовыйЭлемент.Использование 	= Истина;
		
		НовыйЭлемент = Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		НовыйЭлемент.ИдентификаторПользовательскойНастройки = "ПрограммныйОтборПоОстатку";
		НовыйЭлемент.ЛевоеЗначение 	= Новый ПолеКомпоновкиДанных("Остаток");
		НовыйЭлемент.ВидСравнения 	= ВидСравненияКомпоновкиДанных.Больше;
		НовыйЭлемент.ПравоеЗначение = 0;
		НовыйЭлемент.Использование 	= Истина;
		
	КонецЕсли;
		
	Если ЗначениеЗаполнено(КодОрганизации) Тогда
		
		Организация = Справочники.Организации.НайтиПоКоду(КодОрганизации);
		Если Организация = Неопределено Тогда
			Организация = Справочники.Организации.ПустаяСсылка();
		КонецЕсли;
		
		НовыйЭлемент = Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		НовыйЭлемент.ИдентификаторПользовательскойНастройки = "ПрограммныйОтборПоОрганизации";
		НовыйЭлемент.ЛевоеЗначение 	= Новый ПолеКомпоновкиДанных("Организация");
		НовыйЭлемент.ВидСравнения 	= ВидСравненияКомпоновкиДанных.Равно;
		НовыйЭлемент.ПравоеЗначение = Организация;
		НовыйЭлемент.Использование 	= Истина;
		
		Если Не ЗначениеЗаполнено(КодСклада) Тогда
			НовыйЭлемент = Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
			НовыйЭлемент.ИдентификаторПользовательскойНастройки = "ПрограммныйОтборПоОстатку";
			НовыйЭлемент.ЛевоеЗначение 	= Новый ПолеКомпоновкиДанных("Остаток");
			НовыйЭлемент.ВидСравнения 	= ВидСравненияКомпоновкиДанных.Больше;
			НовыйЭлемент.ПравоеЗначение = 0;
			НовыйЭлемент.Использование 	= Истина;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПодготовитьДанныеДляВыгрузкиНоменклатуры(Параметры)

	СхемаВыгрузкиТоваров = ПланыОбмена.ОбменУправлениеНебольшойФирмойСайт.ПолучитьМакет("СхемаВыгрузкиТоваровВебСервис");
	
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаВыгрузкиТоваров)); 
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаВыгрузкиТоваров.НастройкиПоУмолчанию);

	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("ИспользоватьХарактеристики");
	ПараметрСКД.Значение = Параметры.ИспользоватьХарактеристики;
	ПараметрСКД.Использование = Истина;
	
	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("ОрганизацияВладелецКаталога");
	ПараметрСКД.Значение = Параметры.ОрганизацияВладелецКаталога;
	ПараметрСКД.Использование = Истина;
	
	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("РазрешенныеТипыКартинок");
	ПараметрСКД.Значение = Параметры.РазрешенныеТипыКартинок;
	ПараметрСКД.Использование = Истина;
	
	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("РазрешенныеТипыНоменклатуры");
	ПараметрСКД.Значение = Параметры.РазрешенныеТипыНоменклатуры;
	ПараметрСКД.Использование = Истина;
	
	//Отбор.
	
	УстановитьОтборыКомпоновщика(КомпоновщикНастроек, Параметры.ДатаИзменения, Параметры.КодГруппы);
	
	// Запрос.
	
	Запрос = ОбменССайтом.ПолучитьЗапросИзМакетаКомпоновки(КомпоновщикНастроек, СхемаВыгрузкиТоваров);
	ДобавитьЗапросыВПакетныйЗапросДляВыгрузкиНоменклатуры(Запрос.Текст, Параметры);
	
	МассивРезультатовЗапроса = Запрос.ВыполнитьПакет();
	
	Параметры.Вставить("ВыборкаНоменклатуры", МассивРезультатовЗапроса[6].Выбрать());
	
	Параметры.Вставить("ДеревоСвойствХарактеристик", 
		МассивРезультатовЗапроса[8].Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам));
	
	Параметры.Вставить("ВыборкаСвойствНоменклатурыДляКлассификатора", 
		МассивРезультатовЗапроса[10].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам));
	
	РезультатЗапросаСвойствНоменклатуры = МассивРезультатовЗапроса[11];
	Если РезультатЗапросаСвойствНоменклатуры.Пустой() Тогда
		ВыборкаСвойствНоменклатуры = Неопределено;
	Иначе
		ВыборкаСвойствНоменклатуры = РезультатЗапросаСвойствНоменклатуры.Выбрать();
		ВыборкаСвойствНоменклатуры.Следующий();
	КонецЕсли;
		
	Параметры.Вставить("ВыборкаСвойствНоменклатуры", ВыборкаСвойствНоменклатуры);
	
	РезультатЗапросаДанныхОрганизацииВладельцаКаталога = МассивРезультатовЗапроса[13];
	Если РезультатЗапросаДанныхОрганизацииВладельцаКаталога.Пустой() Тогда
		ВыборкаДанныхОрганизацииВладельцаКаталога = Неопределено;
	Иначе
		ВыборкаДанныхОрганизацииВладельцаКаталога = РезультатЗапросаДанныхОрганизацииВладельцаКаталога.Выбрать();
		ВыборкаДанныхОрганизацииВладельцаКаталога.Следующий();
	КонецЕсли;
	
	Параметры.Вставить("ДанныеОрганизацииВладельцаКаталога", ВыборкаДанныхОрганизацииВладельцаКаталога);
	
	Параметры.Вставить("ДеревоГрупп", МассивРезультатовЗапроса[14].Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией));
	Параметры.Вставить("ВыборкаФайлов", Неопределено);
		
КонецПроцедуры // ПодготовитьДанныеДляВыгрузкиНоменклатуры(Параметры)

Функция ПолучитьКлассификаторИКаталог(ДатаИзменения, КодГруппы)
	
	Параметры = ПолучитьСтруктуруПараметровОбмена();
	
	Если ЗначениеЗаполнено(КодГруппы)
		И Не ЗначениеЗаполнено(Справочники.Номенклатура.НайтиПоКоду(КодГруппы)) Тогда
		Возврат Параметры.ПустойПакетXDTO;
	КонецЕсли;
	
	Параметры.Вставить("ДатаИзменения", ДатаИзменения);
	Параметры.Вставить("КодГруппы"	  , КодГруппы);
	
	ПодготовитьДанныеДляВыгрузкиНоменклатуры(Параметры);
	
	Если Параметры.ВыборкаНоменклатуры.Количество() = 0 Тогда
		Возврат Параметры.ПустойПакетXDTO;
	КонецЕсли;
	
	ИДКаталога = Строка(Новый УникальныйИдентификатор);
	
	URI = "urn:1C.ru:commerceml_205";
	ПакетCML = ФабрикаXDTO.Пакеты.Получить(URI);	
	
	КоммерческаяИнформацияТип = ПакетCML.Получить("КоммерческаяИнформация");
	КоммерческаяИнформацияXDTO = ФабрикаXDTO.Создать(КоммерческаяИнформацияТип);
	
	КоммерческаяИнформацияXDTO.ВерсияСхемы = "2.05";
	КоммерческаяИнформацияXDTO.ДатаФормирования = Параметры.ДатаФормирования;
	
	КлассификаторТип = ПакетCML.Получить("Классификатор");
	КлассификаторXDTO = ФабрикаXDTO.Создать(КлассификаторТип);
	
	КлассификаторXDTO.ИД = ИДКаталога;
	КлассификаторXDTO.Наименование = "Классификатор";
	
	КлассификаторXDTO.Владелец = ОбменССайтом.ПолучитьКонтрагентаXDTO(Параметры.ДанныеОрганизацииВладельцаКаталога, ПакетCML);
	
	ОбменССайтом.ДобавитьГруппыКлассификатораXDTO(КлассификаторXDTO, Параметры.ДеревоГрупп.Строки, Неопределено, ПакетCML, Параметры);
	ОбменССайтом.ДобавитьСвойстваНоменклатурыВКлассификаторXDTO(КлассификаторXDTO, ПакетCML, Параметры.ВыборкаСвойствНоменклатурыДляКлассификатора, Параметры);
	
	Попытка
		КлассификаторXDTO.Проверить();
		КоммерческаяИнформацияXDTO.Классификатор = КлассификаторXDTO;
	Исключение
		Возврат Параметры.ПустойПакетXDTO;
	КонецПопытки;
	
	КаталогТип = ПакетCML.Получить("Каталог");
	КаталогXDTO = ФабрикаXDTO.Создать(КаталогТип);
	
	КаталогXDTO.СодержитТолькоИзменения = Параметры.ДатаИзменения <> '00010101';
	КаталогXDTO.СодержитТолькоИзменения = Ложь;
	КаталогXDTO.Ид = ИДКаталога;
	КаталогXDTO.ИдКлассификатора = ИДКаталога;
	КаталогXDTO.Наименование = "Каталог";
	
	КаталогXDTO.Владелец = ОбменССайтом.ПолучитьКонтрагентаXDTO(Параметры.ДанныеОрганизацииВладельцаКаталога, ПакетCML);
	
	ОбменССайтом.ДобавитьНоменклатуруВКаталогXDTO(КаталогXDTO, ПакетCML, Параметры);
	
	Попытка
		КаталогXDTO.Проверить();
		КоммерческаяИнформацияXDTO.Каталог = КаталогXDTO;
	Исключение
		Возврат Параметры.ПустойПакетXDTO;
	КонецПопытки;
	
	Возврат КоммерческаяИнформацияXDTO;
	
КонецФункции

// Формирует пакетный запрос для получения необходимых данных для выгрузки остатков и цен.
//
Процедура ДобавитьЗапросыВПакетныйЗапросДляВыгрузкиОстатковИЦен(ТекстЗапроса, Параметры)
	
	ТекстЗапроса = ТекстЗапроса + Символы.ПС + ";" + Символы.ПС
	  	+ "УНИЧТОЖИТЬ ВременнаяТаблицаНоменклатураХарактеристикиОстатки
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ВременнаяТаблицаШтрихкодыДляЦен
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВременнаяТаблицаВидыЦен.ВидЦен КАК ВидЦен,
		|	ВременнаяТаблицаВидыЦен.ВалютаЦены КАК ВалютаЦены,
		|	ВременнаяТаблицаВидыЦен.ЦенаВключаетНДС КАК ЦенаВключаетНДС
		|ИЗ
		|	ВременнаяТаблицаВидыЦен КАК ВременнаяТаблицаВидыЦен
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВременнаяТаблицаЦены.Характеристика КАК Характеристика,
		|	ХарактеристикиНоменклатурыДополнительныеРеквизиты.Свойство КАК Свойство,
		|	ХарактеристикиНоменклатурыДополнительныеРеквизиты.Свойство.Наименование КАК Наименование,
		|	ХарактеристикиНоменклатурыДополнительныеРеквизиты.Значение КАК Значение
		|ИЗ
		|	ВременнаяТаблицаЦены КАК ВременнаяТаблицаЦены
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ХарактеристикиНоменклатуры.ДополнительныеРеквизиты КАК ХарактеристикиНоменклатурыДополнительныеРеквизиты
		|		ПО ВременнаяТаблицаЦены.Характеристика = ХарактеристикиНоменклатурыДополнительныеРеквизиты.Ссылка
		|ИТОГИ ПО
		|	Характеристика
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ВременнаяТаблицаЦены
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
		|	Организации.Ссылка КАК Контрагент,
		|	Организации.Наименование КАК Наименование,
		|	Организации.НаименованиеПолное КАК НаименованиеПолное,
		|	Организации.ЮридическоеФизическоеЛицо КАК ЮрФизЛицо,
		|	Организации.ИНН КАК ИНН,
		|	Организации.КПП КАК КПП,
		|	Организации.КодПоОКПО КАК КодПоОКПО,
		|	Организации.КонтактнаяИнформация.(
		|		Тип КАК Тип,
		|		Вид КАК Вид,
		|		Представление КАК Представление,
		|		ЗначенияПолей КАК ЗначенияПолей
		|	) КАК КонтактнаяИнформация
		|ИЗ
		|	Справочник.Организации КАК Организации
		|ГДЕ
		|	Организации.Ссылка = &ОрганизацияВладелецКаталога";
	
	КонецПроцедуры

// Заполняет массив всеми видами цен.
//
Процедура ЗаполнитьМассивВидовЦенПоУмолчанию(МассивВидовЦен)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВидыЦен.Ссылка КАК ВидЦен
	|ИЗ
	|	Справочник.ВидыЦен КАК ВидыЦен";
	
	МассивВидовЦен = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ВидЦен");
	
КонецПроцедуры // ЗаполнитьМассивВидовЦенПоУмолчанию(МассивВидовЦен)

Процедура ПодготовитьДанныеДляВыгрузкиОстатовИЦен(Параметры)
	
	МассивВидовЦен = Параметры.МассивВидовЦен;
	Если МассивВидовЦен.Количество() = 0 Тогда
		ЗаполнитьМассивВидовЦенПоУмолчанию(МассивВидовЦен);
	КонецЕсли;
	
	СхемаВыгрузкиТоваров = ПланыОбмена.ОбменУправлениеНебольшойФирмойСайт.ПолучитьМакет("СхемаВыгрузкиТоваров");
	
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаВыгрузкиТоваров)); 
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаВыгрузкиТоваров.НастройкиПоУмолчанию);
	
	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("ИспользоватьХарактеристики");
	ПараметрСКД.Значение = Параметры.ИспользоватьХарактеристики;
	ПараметрСКД.Использование = Истина;
	
	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("ОрганизацияВладелецКаталога");
	ПараметрСКД.Значение = Параметры.ОрганизацияВладелецКаталога;
	ПараметрСКД.Использование = Истина;
	
	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("ВидыЦен");
	ПараметрСКД.Значение = МассивВидовЦен;
	ПараметрСКД.Использование = Истина;
	
	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("УчетВалютныхОпераций");
	ПараметрСКД.Значение = Параметры.УчетВалютныхОпераций;
	ПараметрСКД.Использование = Истина;
	
	ПараметрСКД = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("РазрешенныеТипыНоменклатуры");
	ПараметрСКД.Значение = Параметры.РазрешенныеТипыНоменклатуры;
	ПараметрСКД.Использование = Истина;
	
	 //Отбор.
	 
	УстановитьОтборыКомпоновщика(КомпоновщикНастроек, Параметры.ДатаИзменения, Параметры.КодГруппы, Параметры.КодСклада, Параметры.КодОрганизации);
	
	// Запрос.
	
	Запрос = ОбменССайтом.ПолучитьЗапросИзМакетаКомпоновки(КомпоновщикНастроек, СхемаВыгрузкиТоваров);
	ДобавитьЗапросыВПакетныйЗапросДляВыгрузкиОстатковИЦен(Запрос.Текст, Параметры);
	
	МассивРезультатовЗапроса = Запрос.ВыполнитьПакет();
	
	Параметры.Вставить("ВыборкаЦен", МассивРезультатовЗапроса[12].Выбрать());
	Параметры.Вставить("ВыборкаВидовЦен", МассивРезультатовЗапроса[15].Выбрать());
	
	Параметры.Вставить("ДеревоСвойствХарактеристик", 
		МассивРезультатовЗапроса[16].Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам));
	
	РезультатЗапросаДанныхОрганизацииВладельцаКаталога = МассивРезультатовЗапроса[18];
	Если РезультатЗапросаДанныхОрганизацииВладельцаКаталога.Пустой() Тогда
		ВыборкаДанныхОрганизацииВладельцаКаталога = Неопределено;
	Иначе
		ВыборкаДанныхОрганизацииВладельцаКаталога = РезультатЗапросаДанныхОрганизацииВладельцаКаталога.Выбрать();
		ВыборкаДанныхОрганизацииВладельцаКаталога.Следующий();
	КонецЕсли;
	
	Параметры.Вставить("ДанныеОрганизацииВладельцаКаталога", ВыборкаДанныхОрганизацииВладельцаКаталога);
	
КонецПроцедуры

Функция ПолучитьОстаткиИЦены(ДатаИзменения, КодГруппы, КодСклада, КодОрганизации)
	
	Параметры = ПолучитьСтруктуруПараметровОбмена();
	
	Если ЗначениеЗаполнено(КодГруппы)
		И Не ЗначениеЗаполнено(Справочники.Номенклатура.НайтиПоКоду(КодГруппы)) Тогда
		Возврат Параметры.ПустойПакетXDTO;
	КонецЕсли;
	
	Параметры.Вставить("ДатаИзменения" , ДатаИзменения);
	Параметры.Вставить("КодГруппы"	   , КодГруппы);
	Параметры.Вставить("КодСклада"	   , КодСклада);
	Параметры.Вставить("КодОрганизации", КодОрганизации);
	
	ИДКаталога = Строка(Новый УникальныйИдентификатор);
	
	URI = "urn:1C.ru:commerceml_205";
	ПакетCML = ФабрикаXDTO.Пакеты.Получить(URI);
	
	КоммерческаяИнформацияТип = ПакетCML.Получить("КоммерческаяИнформация");
	КоммерческаяИнформацияXDTO = ФабрикаXDTO.Создать(КоммерческаяИнформацияТип);
	
	КоммерческаяИнформацияXDTO.ВерсияСхемы = "2.05";
	КоммерческаяИнформацияXDTO.ДатаФормирования = Параметры.ДатаФормирования;
	
	ПодготовитьДанныеДляВыгрузкиОстатовИЦен(Параметры);
	
	Если Параметры.ВыборкаЦен.Количество() = 0 Тогда
		Возврат Параметры.ПустойПакетXDTO;
	КонецЕсли;
	
	ПакетПредложенийXDTO = ФабрикаXDTO.Создать(ПакетCML.Получить("ПакетПредложений"));
	
	ПакетПредложенийXDTO.СодержитТолькоИзменения = Ложь;
	ПакетПредложенийXDTO.Ид = ИДКаталога;
	ПакетПредложенийXDTO.Наименование = "Пакет предложений";
	ПакетПредложенийXDTO.ИдКаталога = ИДКаталога;
	ПакетПредложенийXDTO.ИдКлассификатора = ИДКаталога;
	
	ОбменССайтом.ДобавитьВидыЦенВПакетПредложенийXDTO(ПакетПредложенийXDTO, ПакетCML, Параметры);
	
	ОбменССайтом.ДобавитьПредложенияВПакетПредложенийXDTO(ПакетПредложенийXDTO, ПакетCML, Параметры);
	
	Попытка
		ПакетПредложенийXDTO.Проверить();
		КоммерческаяИнформацияXDTO.ПакетПредложений = ПакетПредложенийXDTO;
	Исключение
		Возврат Параметры.ПустойПакетXDTO;
	КонецПопытки;
	
	Возврат КоммерческаяИнформацияXDTO;
	
КонецФункции

// Получает заказы покупателей, которые были модифицированы.
//
// Параметры:
//	ДатаИзменения - дата-время, начиная с которого заказ был изменен.
//
// Возвращаемое значение:
//	Массив заказов покупателей.
//
Функция ПолучитьЗаказыДляВыгрузки(ДатаИзменения)
	
	Если ДатаИзменения = '00010101' Тогда
		Возврат Новый Массив;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ЗаказыПокупателейССайта.ЗаказПокупателя КАК ЗаказПокупателя
	|ИЗ
	|	РегистрСведений.ЗаказыПокупателейССайта КАК ЗаказыПокупателейССайта
	|ГДЕ
	|	ЗаказыПокупателейССайта.ЗаказПокупателя.ДатаИзменения >= &ДатаИзменения";
	
	Запрос.УстановитьПараметр("ДатаИзменения", ДатаИзменения);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ЗаказПокупателя");
	
КонецФункции // ПолучитьЗаказыДляВыгрузки()

Функция ПолучитьЗаказы(ДатаИзменения)
	
	Параметры = ПолучитьСтруктуруПараметровОбмена();
	
	СтруктураСтатистики = Новый Структура;
	
	СтруктураСтатистики.Вставить("ОбработаноНаЗагрузке", 0);
	СтруктураСтатистики.Вставить("Загружено" , Новый Массив);
	СтруктураСтатистики.Вставить("Пропущено" , Новый Массив);
	СтруктураСтатистики.Вставить("Обновлено" , Новый Массив);
	СтруктураСтатистики.Вставить("Создано"   , Новый Массив);
	СтруктураСтатистики.Вставить("Выгружено" , Новый Массив);
	
	МассивИзменений = ПолучитьЗаказыДляВыгрузки(ДатаИзменения);
	Если ЗначениеЗаполнено(ДатаИзменения) И МассивИзменений.Количество() = 0 Тогда
		Возврат Параметры.ПустойПакетXDTO;
	Иначе
		ЗаказыXDTO = ОбменССайтом.СформироватьЗаказыXDTO(МассивИзменений, СтруктураСтатистики, Параметры);
	КонецЕсли;
	
	Если ЗаказыXDTO = Неопределено Тогда
		Возврат Параметры.ПустойПакетXDTO;
	КонецЕсли;
	
	Возврат ЗаказыXDTO;
	
КонецФункции // ПолучитьЗаказы()

Функция ЗагрузитьЗаказы(ДанныеЗаказовXDTO)
	
	Параметры = ПолучитьСтруктуруПараметровОбмена();
	
	Параметры.Вставить("СпособИдентификацииКонтрагентов", Перечисления.СпособыИдентификацииКонтрагентов.Наименование);
	Параметры.Вставить("ГруппаДляНовыхКонтрагентов", Справочники.Контрагенты.ПустаяСсылка());
	Параметры.Вставить("ГруппаДляНовойНоменклатуры", Справочники.Номенклатура.ПустаяСсылка());
	Параметры.Вставить("ОбменТоварами", Ложь);
	Параметры.Вставить("ВыгружатьТолькоИзменения", Ложь);
	Параметры.Вставить("ТаблицаСоответствияСтатусовЗаказов", Новый  ТаблицаЗначений);
	Параметры.Вставить("ОрганизацияДляПодстановкиВЗаказы", Справочники.Организации.ПустаяСсылка());
	Параметры.Вставить("ОбновлятьТолькоНеПроведенныеЗаказыПриЗагрузке", Ложь);
	
	СтруктураСтатистики = Новый Структура;
	
	СтруктураСтатистики.Вставить("ОбработаноНаЗагрузке", 0);
	СтруктураСтатистики.Вставить("Загружено" , Новый Массив);
	СтруктураСтатистики.Вставить("Пропущено" , Новый Массив);
	СтруктураСтатистики.Вставить("Обновлено" , Новый Массив);
	СтруктураСтатистики.Вставить("Создано"   , Новый Массив);
	
	ЕстьОшибки = Ложь;
	ОписаниеОшибки = "";
	
	Если Не ОбменССайтом.ЗагрузитьЗаказы(ДанныеЗаказовXDTO, СтруктураСтатистики, Параметры, ОписаниеОшибки) Тогда 
		
		ОбменССайтом.ДобавитьОписаниеОшибки(ОписаниеОшибки, НСтр("ru = 'Не удалось обработать документы, загруженные с сервера.'"));
		ЕстьОшибки = Истина;
		
	КонецЕсли;
	
	ЗаписатьРезультатВыполненияОперацииВЖурналРегистрации(НСтр("ru = 'ОбменССайтом.ЗагрузкаЗаказов'"), ОписаниеОшибки, ЕстьОшибки);
	
	Возврат Не ЕстьОшибки;
	
КонецФункции // ЗагрузитьЗаказы()

Функция ПолучитьДвоичныеДанныеФайла(ДанныеФайла)
	
	ДвоичныеДанныеФайла = Неопределено;
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ПлатформаWindows = СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86
		ИЛИ СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64;
	
	ФайлВХранилище = ДанныеФайла.ТипХраненияФайла = Перечисления.ТипыХраненияФайлов.ВИнформационнойБазе;
	Если ФайлВХранилище Тогда
		
		Если ДанныеФайла.ХранимыйФайл = NULL Тогда
			ДвоичныеДанныеФайла = Неопределено;
		Иначе
			ДвоичныеДанныеФайла = ДанныеФайла.ХранимыйФайл.Получить();
		КонецЕсли;
		
		Если ДвоичныеДанныеФайла = Неопределено Тогда
			
			ОписаниеОшибки = ИнформацияОбОшибке();
			ЗаписьЖурналаРегистрации(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСТр("ru = 'GetPicture: не удалось получить данные файла %1 номенклатуры %2.'"),
				ДанныеФайла.Файл,
				ДанныеФайла.Номенклатура),
				УровеньЖурналаРегистрации.Ошибка,,,
				ОписаниеОшибки.Описание);
			ВызватьИсключение ОписаниеОшибки;
		КонецЕсли;
		
	Иначе
		
		ИмяФайла = ОбменССайтом.ПодготовитьПутьДляПлатформы(ПлатформаWindows,
			ОбменССайтом.ПолучитьПутьТомаДляПлатформы(ПлатформаWindows, ДанныеФайла.Том) + "\" + ДанныеФайла.ПутьКФайлу);
		
		Попытка
			
			ДвоичныеДанныеФайла = Новый ДвоичныеДанные(ИмяФайла);
			
		Исключение
			
			ВызватьИсключение ИнформацияОбОшибке();
			
		КонецПопытки;
	КонецЕсли;
	
	Возврат ДвоичныеДанныеФайла;
	
КонецФункции

Функция ПолучитьКартинку(ИдентификаторТовараСтрока)
	
	Параметры = ПолучитьСтруктуруПараметровОбмена();
	
	МенеджерОбъекта = Справочники.Номенклатура;
	СсылкаНаОбъект = ПолучитьСсылкуПоИдентификатору(МенеджерОбъекта, ИдентификаторТовараСтрока);
	
	МассивСссылокНаТовары = Новый Массив;
	МассивСссылокНаТовары.Добавить(СсылкаНаОбъект);
	
	Выборка = ПолучитьПрисоединенныеФайлы(МассивСссылокНаТовары, Параметры.РазрешенныеТипыКартинок);
	Если Выборка.Следующий() Тогда
		
		СериализиаторXDTO = Новый СериализаторXDTO(ФабрикаXDTO);
		ДвоичныеДанныеФайла = ПолучитьДвоичныеДанныеФайла(Выборка);
		
		Попытка
			КартинкаXDTO = СериализиаторXDTO.ЗаписатьXDTO(ДвоичныеДанныеФайла);
		Исключение
			ВызватьИсключение ОписаниеОшибки();
		КонецПопытки;
		
	КонецЕсли;
	
	Возврат КартинкаXDTO;
	
КонецФункции

Процедура ЗаписатьРезультатВыполненияОперацииВЖурналРегистрации(СобытиеЖурнала, Описание, Ошибка = Ложь)
	
	Если Ошибка Тогда
		УровеньЖурнала = УровеньЖурналаРегистрации.Ошибка;
	Иначе
		УровеньЖурнала = УровеньЖурналаРегистрации.Информация;
	КонецЕсли;
	
	ЗаписьЖурналаРегистрации(СобытиеЖурнала, УровеньЖурнала,,, Описание);
	
КонецПроцедуры

// ФУНКЦИИ ОПЕРАЦИЙ

Функция GetItems(ModificationDate, GroupCode) Экспорт
	
	Возврат ПолучитьКлассификаторИКаталог(ModificationDate, GroupCode);

КонецФункции

Функция GetAmountAndPrices(ModificationDate, GroupCode, WarehouseCode, OrganizationCode) Экспорт
	
	Возврат ПолучитьОстаткиИЦены(ModificationDate, GroupCode, WarehouseCode, OrganizationCode);
	
КонецФункции

Функция GetOrders(ModificationDate) Экспорт
	
	Возврат ПолучитьЗаказы(ModificationDate);
	
КонецФункции

Функция LoadOrders(OrdersData) Экспорт
	
	Возврат ЗагрузитьЗаказы(OrdersData);
	
КонецФункции

Функция GetPicture(ItemID) Экспорт
	
	Возврат ПолучитьКартинку(ItemID);
	
КонецФункции

