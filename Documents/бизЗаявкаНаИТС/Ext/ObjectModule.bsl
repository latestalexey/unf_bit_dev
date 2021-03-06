﻿
Перем АдресФайла;
// Заполняет табличную часть на основании регистра "Подписки ИТС" по тем подпискам, срок которых истек
//
// Параметры
//
//  МесяцЗавершения - месяц, в котором производится поиск подписок
//
//  ЧислоВключаемыхМесяцев - число месяцев, включаемых в заполнение до даты документа. 
//  0 - включать только текущий месяц
//
Процедура ЗаполнитьПоЗавершенным(МесяцЗавершения, ЧислоВключаемыхМесяцев) Экспорт

	ТекстЗапроса = "ВЫБРАТЬ
	               |	АО_ПодпискиИТССрезПоследних.Контрагент,
	               |	АО_ПодпискиИТССрезПоследних.Номенклатура,
	               |	АО_ПодпискиИТССрезПоследних.РегистрационныйНомер,
	               |	АО_ПодпискиИТССрезПоследних.ВидПодписки,
	               |	АО_ПодпискиИТССрезПоследних.СрокПодписки,
	               |	АО_ПодпискиИТССрезПоследних.ВидОплаты,
	               |	АО_ПодпискиИТССрезПоследних.ДатаОкончанияПодписки
	               |ПОМЕСТИТЬ ДанныеОПодписках
	               |ИЗ
	               |	РегистрСведений.бизПодписки.СрезПоследних(, Организация = &Организация) КАК АО_ПодпискиИТССрезПоследних
	               |ГДЕ
	               |	АО_ПодпискиИТССрезПоследних.СрокПодписки <> ЗНАЧЕНИЕ(Перечисление.бизСрокиПодписокИТС.ПустаяСсылка)
	               |	И АО_ПодпискиИТССрезПоследних.ДатаОкончанияПодписки > &ДатаНачалаОтбора
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ДанныеОПодписках.Контрагент,
	               |	МАКСИМУМ(ДанныеОПодписках.ДатаОкончанияПодписки) КАК ДатаОкончанияПодписки
	               |ПОМЕСТИТЬ ДатыПоследнихПодписок
	               |ИЗ
	               |	ДанныеОПодписках КАК ДанныеОПодписках
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ДанныеОПодписках.Контрагент
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	КонтактныеЛицаРолиКонтактногоЛица.Ссылка.Ссылка
	               |ПОМЕСТИТЬ ОтветственныеЗаИТС
	               |ИЗ
	               |	Справочник.КонтактныеЛица.Роли КАК КонтактныеЛицаРолиКонтактногоЛица
	               |ГДЕ
	               |	КонтактныеЛицаРолиКонтактногоЛица.Роль.Наименование = &Наименование
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Контрагенты.КонтактноеЛицо
	               |ПОМЕСТИТЬ Руководители
	               |ИЗ
	               |	Справочник.Контрагенты КАК Контрагенты
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	Контрагенты.КонтактноеЛицо
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Руководители.КонтактноеЛицо.Ссылка,
	               |	ОтветственныеЗаИТС.Ссылка
	               |ПОМЕСТИТЬ ОтветственныеЛицаПодписчиковИТС
	               |ИЗ
	               |	Руководители КАК Руководители
	               |		ПОЛНОЕ СОЕДИНЕНИЕ ОтветственныеЗаИТС КАК ОтветственныеЗаИТС
	               |		ПО Руководители.КонтактноеЛицо.Владелец = ОтветственныеЗаИТС.Ссылка.Владелец
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	СУММА(бизПП1С.КоличествоРабМест) КАК КоличествоРабМест,
	               |	бизПП1С.Владелец
	               |ПОМЕСТИТЬ КолвоРабочихМест
	               |ИЗ
	               |	Справочник.бизПП1С КАК бизПП1С
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	бизПП1С.Владелец
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ДанныеОПодписках.Контрагент,
	               |	ДанныеОПодписках.Номенклатура,
	               |	ДанныеОПодписках.РегистрационныйНомер,
	               |	ДанныеОПодписках.ВидПодписки,
	               |	ДанныеОПодписках.СрокПодписки,
	               |	ДанныеОПодписках.ВидОплаты,
	               |	ОтветственныеЛицаПодписчиковИТС.КонтактноеЛицоСсылка.Ссылка КАК Руководитель,
	               |	ЕСТЬNULL(ОтветственныеЛицаПодписчиковИТС.Ссылка, ОтветственныеЛицаПодписчиковИТС.КонтактноеЛицоСсылка.Ссылка) КАК Ответственный,
	               |	ЗНАЧЕНИЕ(Перечисление.бизОперацииИТС.ЗарегистрироватьПодписку) КАК Операция,
	               |	КолвоРабочихМест.КоличествоРабМест КАК КоличествоРабочихМест
	               |ИЗ
	               |	ДанныеОПодписках КАК ДанныеОПодписках
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ДатыПоследнихПодписок КАК ДатыПоследнихПодписок
	               |		ПО ДанныеОПодписках.Контрагент = ДатыПоследнихПодписок.Контрагент
	               |			И ДанныеОПодписках.ДатаОкончанияПодписки = ДатыПоследнихПодписок.ДатаОкончанияПодписки
	               |		ЛЕВОЕ СОЕДИНЕНИЕ ОтветственныеЛицаПодписчиковИТС КАК ОтветственныеЛицаПодписчиковИТС
	               |		ПО ДанныеОПодписках.Контрагент = ОтветственныеЛицаПодписчиковИТС.КонтактноеЛицоСсылка.Владелец
	               |		ЛЕВОЕ СОЕДИНЕНИЕ КолвоРабочихМест КАК КолвоРабочихМест
	               |		ПО ДанныеОПодписках.Контрагент = КолвоРабочихМест.Владелец
	               |ГДЕ
	               |	ДанныеОПодписках.ДатаОкончанияПодписки <= &ДатаКонца";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ДатаКонца", КонецМесяца(МесяцЗавершения));
	Запрос.УстановитьПараметр("ДатаНачалаОтбора", ДобавитьМесяц(НачалоМесяца(МесяцЗавершения), -ЧислоВключаемыхМесяцев));
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Наименование", "Главный бухгалтер");
	
	Подписки.Загрузить(Запрос.Выполнить().Выгрузить());
	
	Для каждого СтрокаТЗ Из Подписки Цикл
	
		СтрокаТЗ.ДатаНачалаПодписки = НачалоМесяца(ДобавитьМесяц(МесяцЗавершения, 1));
		СтрокаТЗ.ДатаОкончанияПодписки = КонецМесяца(ДобавитьМесяц(СтрокаТЗ.ДатаНачалаПодписки, бизУчетИТСКлиентСервер.ПолучитьКолвоМесяцев(СтрокаТЗ.СрокПодписки) - 1));
	
	КонецЦикла; 

КонецПроцедуры // ЗаполнитьПоЗавершенным()

// Функция формирует файл в формате Excel, данные для файла берутся из макетов
//
// Параметры
//  <ВидФайла>              – <Строка> – описывает вид файла, а также наименование макета,
//                            из которого надо брать шаблон для заполнения файла
//  <ИмяФайла>              – <Строка> – имя создаваемого файла
//  <ИспользуемаяТабЧасть>  – <Строка> – имя используемой табличной части
//
// Возвращаемое значение:
//   <ХранилищеЗначений>   – возвращает сформированный файл в виде хранилища значений
//
Функция СоздатьФайлExcel() экспорт
	
	Таб = СоздатьЗаказИТС();
	ИмяФайла =КаталогВременныхФайлов() + "ip"+СОКРЛП(Организация.бизКодПартнера)+".xls";
	Таб.Записать(ИмяФайла, ТипФайлаТабличногоДокумента.XLS);
	Возврат Новый ДвоичныеДанные (ИмяФайла);
					
КонецФункции // СоздатьФайлExcel()

Функция СоздатьЗаказИТС()
	
	ТабДок = Новый ТабличныйДокумент;
	Макет  = ПолучитьМакет("ZakazITS_309");
	
	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
	
	ОбластьМакета.Параметры.КодПартнера	             = СОКРЛП(Организация.бизКодПартнера);
	ОбластьМакета.Параметры.Ответственный	         = АвторОбращения.Наименование;
	ОбластьМакета.Параметры.ЕмайлПартнера	         = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(Организация, Справочники.ВидыКонтактнойИнформации.EmailОрганизации);
	ОбластьМакета.Параметры.Пароль                   = Пароль;
	ОбластьМакета.Параметры.НовыйПароль              = НовыйПароль;
	ОбластьМакета.Параметры.ЗаказатьСводныйОтчет     = ?(ЗаказатьСводныйОтчет, "1", "");
	ОбластьМакета.Параметры.ЗаказатьОтчетПоПодпискам = ?(ЗаказатьОтчетПоПодпискам, "1", "");


	ТабДок.Вывести(ОбластьМакета);
	
	Нпп = 1;
	Для Каждого СтрокаПодпискиИТС Из Подписки Цикл
		ОбластьМакета = Макет.ПолучитьОбласть("Строка");
		
		ОбластьМакета.Параметры.Нпп = Нпп;
		ОбластьМакета.Параметры.КодПартнера	            = СокрЛП(Организация.бизКодПартнера);
		ОбластьМакета.Параметры.СпособПолучения	        = СпособПолучения;
		ОбластьМакета.Параметры.КодДистрибутора	        = КодДистрибутора;
		ОбластьМакета.Параметры.ВидПодписки	            = СтрокаПодпискиИТС.ВидПодписки.Код;
		ОбластьМакета.Параметры.РегНомер	            = СтрокаПодпискиИТС.РегистрационныйНомер;
		ОбластьМакета.Параметры.Контрагент	            = НаименованиеКонтрагента(СтрокаПодпискиИТС.Контрагент);
		ОбластьМакета.Параметры.ИНН	                    = СокрЛП(СтрокаПодпискиИТС.Контрагент.ИНН);
		ОбластьМакета.Параметры.КПП	                    = СокрЛП(СтрокаПодпискиИТС.Контрагент.КПП);
		ОбластьМакета.Параметры.КоличествоРабочихМест	= СтрокаПодпискиИТС.КоличествоРабочихМест;
		//ОбластьМакета.Параметры.ТипДеятельности	        =
		ОбластьМакета.Параметры.ФИОРуководителя	        = СтрокаПодпискиИТС.Руководитель;
		ОбластьМакета.Параметры.ФИОИсполнителя	        = СтрокаПодпискиИТС.Ответственный;
		ОбластьМакета.Параметры.Индекс	                = ИндексКонтрагента(СтрокаПодпискиИТС.Контрагент);
		ОбластьМакета.Параметры.Город	                = ГородКонтрагента(СтрокаПодпискиИТС.Контрагент);
		ОбластьМакета.Параметры.Улица	                = УлицаКонтрагента(СтрокаПодпискиИТС.Контрагент);
		ОбластьМакета.Параметры.Дом	                    = ЗданияИПомещенияАдреса(СтрокаПодпискиИТС.Контрагент, "Дом");
		ОбластьМакета.Параметры.Корпус	                = ЗданияИПомещенияАдреса(СтрокаПодпискиИТС.Контрагент, "Корпус");
		ОбластьМакета.Параметры.Квартира	            = ЗданияИПомещенияАдреса(СтрокаПодпискиИТС.Контрагент, "Квартира");
		ОбластьМакета.Параметры.ТелКод	                = КодТелефонКонтрагента(СтрокаПодпискиИТС.Контрагент, "КодГорода");
		ОбластьМакета.Параметры.Телефон	                = КодТелефонКонтрагента(СтрокаПодпискиИТС.Контрагент, "Номер");
		ОбластьМакета.Параметры.Факс	                = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(СтрокаПодпискиИТС.Контрагент, Справочники.ВидыКонтактнойИнформации.ФаксКонтрагента);
		ОбластьМакета.Параметры.Емайл	                = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(СтрокаПодпискиИТС.Контрагент, Справочники.ВидыКонтактнойИнформации.EmailКонтрагента);
		ОбластьМакета.Параметры.Операция	            = Строка(Перечисления.бизОперацииИТС.Индекс(СтрокаПодпискиИТС.Операция));
		Если Перечисления.бизОперацииИТС.Индекс(СтрокаПодпискиИТС.Операция) = 1 Тогда
			ОбластьМакета.Параметры.ДатаОтказа = СтрокаПодпискиИТС.ДатаНачалаПодписки;
			ОбластьМакета.Параметры.ПричинаОтказа = СтрокаПодпискиИТС.ПричинаОтказа;
		Иначе
			ОбластьМакета.Параметры.ДатаНачала = СтрокаПодпискиИТС.ДатаНачалаПодписки;
		КонецЕсли;
		ОбластьМакета.Параметры.КоличествоВыпусков	    = бизУчетИТСКлиентСервер.ПолучитьКолвоМесяцев(СтрокаПодпискиИТС.СрокПодписки);
		ОбластьМакета.Параметры.СпособОплаты	        = Строка(Перечисления.бизВидыОплатыИТС.Индекс(СтрокаПодпискиИТС.ВидОплаты));
		СвязанныеРегНомера = ПолучитьРегНомераВключенныеВИТС(СтрокаПодпискиИТС);
		ОбластьМакета.Параметры.Заполнить(СвязанныеРегНомера);
		
		ТабДок.Вывести(ОбластьМакета);
		Нпп = Нпп + 1;
	КонецЦикла;
	
	
	Возврат ТабДок;
	
КонецФункции

Функция ЗданияИПомещенияАдреса(КонтрагентСсылка, СтрокаВидаАдреса)
	
	МассивОбъектов = Новый Массив;
	МассивОбъектов.Добавить(КонтрагентСсылка);
	ТаблицаКИ = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъектов(МассивОбъектов,,Справочники.ВидыКонтактнойИнформации.ЮрАдресКонтрагента);
	
	Если ТаблицаКИ.Количество() <> 0 Тогда
		XMLСтрока = ТаблицаКИ[0].ЗначенияПолей;
		XDTOАдрес = УправлениеКонтактнойИнформациейСлужебный.АдресXMLВXDTO(XMLСтрока);
		Таблица = Новый ТаблицаЗначений;
		Если СтрокаВидаАдреса = "Дом" Или СтрокаВидаАдреса = "Корпус" Тогда
			Таблица = УправлениеКонтактнойИнформациейСлужебный.ЗданияИПомещенияАдреса(XDTOАдрес).Здания;
		ИначеЕсли СтрокаВидаАдреса = "Квартира"  Тогда
			Таблица = УправлениеКонтактнойИнформациейСлужебный.ЗданияИПомещенияАдреса(XDTOАдрес).Помещения;
		КонецЕсли;	
		Если Таблица.Количество() <> 0 Тогда
			ОтборСтрок = Новый Структура("Тип", СтрокаВидаАдреса);
			МассивСтрок = Таблица.НайтиСтроки(ОтборСтрок);
			Если МассивСтрок.Количество() <> 0 Тогда
				Возврат МассивСтрок[0].Значение;
			Иначе
				Возврат "";
			КонецЕсли;
			
		Иначе
			Возврат "";
		КонецЕсли;
	Иначе
		Возврат "";
	КонецЕсли;	
	
КонецФункции

Функция ГородКонтрагента(КонтрагентСсылка) Экспорт
	
	// Контактная информация
	ТаблицаКИ = КонтрагентСсылка.КонтактнаяИнформация;
	ПараметрыОтбораКИ = Новый Структура("Тип, Вид");
	
	// Телефон, код телефона
	ПараметрыОтбораКИ.Тип = Перечисления.ТипыКонтактнойИнформации.Адрес;
	ПараметрыОтбораКИ.Вид = Справочники.ВидыКонтактнойИнформации.ЮрАдресКонтрагента;
	МассивИнформации = ТаблицаКИ.НайтиСтроки(ПараметрыОтбораКИ);
	
	Если МассивИнформации.Количество() <> 0 Тогда
		//Из первой строки талицы КонтактнаяИнформация получить значение XML - представления адреса
		//Десериализовать его и получить объект XDTO
		АдресХДТО = УправлениеКонтактнойИнформациейСлужебный.АдресXMLВXDTO(МассивИнформации[0].ЗначенияПолей);
		
		//Получить Компоненты адреса (Регион, Район, Город ..) которые в чтом или инном случае необходимо использовать в значении "Город"
		
		//Регион
		Если  АдресХДТО.Состав.Состав.СубъектРФ <> Неопределено Тогда
			Регион = СокрЛП(АдресХДТО.Состав.Состав.СубъектРФ);
		Иначе Регион = "";
		КонецЕсли;
		
		//Район
		Если АдресХДТО.Состав.Состав.СвРайМО <> Неопределено Тогда
			Район = СокрЛП (АдресХДТО.Состав.Состав.СвРайМО.Район)
		Иначе Район = "";
		КонецЕсли;
		//Город
		Если АдресХДТО.Состав.Состав.Город <> Неопределено Тогда
			Город =СокрЛП (АдресХДТО.Состав.Состав.Город);
		Иначе Город ="";
		КонецЕсли;
		//НаселенныйПункт
		Если АдресХДТО.Состав.Состав.НаселПункт <> Неопределено Тогда 
			НаселенныйПункт = СокрЛП(АдресХДТО.Состав.Состав.НаселПункт);
		Иначе НаселенныйПункт = "";
		КонецЕсли;
		
		//Сформировать представление для подстановки в поле Город		
		Если Регион =  "Санкт-Петербург г" ИЛИ  Регион = "Москва г" Тогда
			Возврат Регион;
		ИначеЕсли Город <> "" Тогда
			Возврат Город;
		ИначеЕсли  НаселенныйПункт <> "" Тогда		
			Возврат Регион + ", "+Район+", "+НаселенныйПункт;
		Иначе Возврат "";
		КонецЕсли;
	КонецЕсли;	
	
КонецФункции

Функция НаименованиеКонтрагента(КонтрагентСсылка)

	Возврат ?(Не ЗначениеЗаполнено(СокрЛП(КонтрагентСсылка.НаименованиеПолное)), СокрЛП(КонтрагентСсылка.Наименование), СокрЛП(КонтрагентСсылка.НаименованиеПолное));
 	
КонецФункции

Функция EmailКонтрагента(КонтрагентСсылка)
	
	// Контактная информация
	ТаблицаКИ = КонтрагентСсылка.КонтактнаяИнформация;
	ПараметрыОтбораКИ = Новый Структура("Тип, Вид");
	
	// Телефон, код телефона
	ПараметрыОтбораКИ.Тип = Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты;
	ПараметрыОтбораКИ.Вид = Справочники.ВидыКонтактнойИнформации.EmailКонтрагенты;
	МассивEmailКонтрагента = ТаблицаКИ.НайтиСтроки(ПараметрыОтбораКИ);
	Если МассивEmailКонтрагента.Количество() <> 0 Тогда
		Возврат МассивEmailКонтрагента[0].Представление;
	Иначе
		Возврат "";
	КонецЕсли;
	               	
КонецФункции

Функция ИндексКонтрагента(КонтрагентСсылка)
	
	МассивОбъектов = Новый Массив;
	МассивОбъектов.Добавить(КонтрагентСсылка);
	ТаблицаКИ = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъектов(МассивОбъектов,,Справочники.ВидыКонтактнойИнформации.ЮрАдресКонтрагента);
	
	Если ТаблицаКИ.Количество() <> 0 Тогда
		XMLСтрока = ТаблицаКИ[0].ЗначенияПолей;
		XDTOАдрес = УправлениеКонтактнойИнформациейСлужебный.АдресXMLВXDTO(XMLСтрока);
		Возврат УправлениеКонтактнойИнформациейСлужебный.ПочтовыйИндексАдреса(XDTOАдрес);	
	Иначе
		Возврат "";
	КонецЕсли;
	
КонецФункции

Функция УлицаКонтрагента(КонтрагентСсылка)
	
	МассивОбъектов = Новый Массив;
	МассивОбъектов.Добавить(КонтрагентСсылка);
	ТаблицаКИ = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъектов(МассивОбъектов,,Справочники.ВидыКонтактнойИнформации.ЮрАдресКонтрагента);
	
	Если ТаблицаКИ.Количество() <> 0 Тогда
		XMLСтрока = ТаблицаКИ[0].ЗначенияПолей;
		XDTOАдрес = УправлениеКонтактнойИнформациейСлужебный.АдресXMLВXDTO(XMLСтрока);
		Возврат XDTOАдрес.Состав.Состав.Улица;	
	Иначе
		Возврат "";
	КонецЕсли;
	
КонецФункции

Функция КодТелефонКонтрагента(КонтрагентСсылка, СтрокаВидТелефона)
	
	ТаблицаКИ = КонтрагентСсылка.КонтактнаяИнформация;
	
	ПараметрыОтбораКИ = Новый Структура("Тип, Вид");
	
	// Телефон, код телефона
	ПараметрыОтбораКИ.Тип = Перечисления.ТипыКонтактнойИнформации.Телефон;
	ПараметрыОтбораКИ.Вид = Справочники.ВидыКонтактнойИнформации.ТелефонКонтрагента;
	МассивТелефонКонтрагента = ТаблицаКИ.НайтиСтроки(ПараметрыОтбораКИ);
	Если МассивТелефонКонтрагента.Количество() <> 0 Тогда
		XMLСтрока = МассивТелефонКонтрагента[0].ЗначенияПолей;
		XDTOОбъект = УправлениеКонтактнойИнформациейСлужебный.ДесериализацияТелефона(XMLСтрока);
		Возврат XDTOОбъект.Состав[СтрокаВидТелефона];
	Иначе
		Возврат "";
	КонецЕсли;
	
КонецФункции

Функция ПолучитьРегНомераВключенныеВИТС(СтрокаПодпискиИТС)

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	бизПП1С.РегНомер
	               |ИЗ
	               |	Справочник.бизПП1С КАК бизПП1С
	               |ГДЕ
	               |	бизПП1С.Владелец = &Владелец
	               |	И бизПП1С.ВключатьВПодпискуИТС = ИСТИНА
	               |	И бизПП1С.РегНомер <> &РегНомер";
	Запрос.УстановитьПараметр("Владелец",СтрокаПодпискиИТС.Контрагент);
	Запрос.УстановитьПараметр("РегНомер",СтрокаПодпискиИТС.РегистрационныйНомер);
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	СвязанныеРегНомера = Новый Структура;
	Сч = 0;
	Пока Выборка.Следующий() Цикл
		Сч = Сч +1;
		
		Ключ = "РегНомер"+Сч;
	
		СвязанныеРегНомера.Вставить(Ключ,Выборка.РегНомер);
	
	КонецЦикла;
	
    Возврат СвязанныеРегНомера;

КонецФункции



