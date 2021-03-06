﻿
#Область ОбработчикиСобытийФормы

&НаСервере
// Процедура - обработчик события ПриСозданииНаСервере.
//
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	
	//УНФ.ОтборыСписка
	РаботаСОтборами.ВосстановитьНастройкиОтборов(ЭтотОбъект, ОтчетыОРозничныхПродажах);
	//Так как в отборе есть Касса- обязательное к заполнению поле, отборы всегда показываем
	РаботаСОтборами.СвернутьРазвернутьОтборыНаСервере(ЭтотОбъект, Истина);
	//Конец УНФ.ОтборыСписка
	
	// КассаККМ по умолчанию
	// Определим, сохранялись ли настройки ранее.
	ПользовательСсылка = ПараметрыСеанса.АвторизованныйПользователь;
	Если Не ЗначениеЗаполнено(ПользовательСсылка) Тогда
		ПользовательСсылка = Справочники.Пользователи.ПустаяСсылка();
		ПользовательИнформационнойБазы = "";
	Иначе
		ПользовательИнформационнойБазы = Обработки.НастройкиПользователей.ИмяПользователяИБ(ПользовательСсылка);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ОтборКассаККМ) Тогда
		Отбор = Новый Структура("Пользователь, КлючОбъекта", ПользовательИнформационнойБазы, "Документ.ОтчетОРозничныхПродажах.Форма.ФормаСписка/КлючТекущихНастроекДанных");
		ВыборкаНастроек = ХранилищеСистемныхНастроек.Выбрать(Отбор);
		Если НЕ ВыборкаНастроек.Следующий() Тогда
			// Если не сохранялись, то установим отбор по основной кассе. Иначе отработает обработчик "ПриЗагрузкеДанныхИзНастроекНаСервере".
			ОтборКассаККМ = Справочники.КассыККМ.ПолучитьКассуККМПоУмолчанию();
			КассаФискальныйРегистратор = Справочники.КассыККМ.ПолучитьРеквизитыКассыККМ(ОтборКассаККМ).ТипКассы = Перечисления.ТипыКассККМ.ФискальныйРегистратор;
			Если Не ОтборКассаККМ.Пустая() Тогда
				УстановитьОтборДинамическихСписков();
			КонецЕсли;
		КонецЕсли;
	КонецЕсли; 
	// Конец КассаККМ по умолчанию
	
	// СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки
	ДополнительныеОтчетыИОбработки.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки
	
	// СтандартныеПодсистемы.Печать
	УправлениеПечатью.ПриСозданииНаСервере(ЭтотОбъект, Элементы.ПодменюПечать);
	// Конец СтандартныеПодсистемы.Печать
	УправлениеНебольшойФирмойСервер.УстановитьОтображаниеПодменюПечати(Элементы.ПодменюПечать);
	
	// Установим формат для текущей даты: ДФ=Ч:мм
	УправлениеНебольшойФирмойСервер.УстановитьОформлениеКолонкиДата(ОтчетыОРозничныхПродажах);
	
КонецПроцедуры // ПриСозданииНаСервере()

// Процедура - обработчик события "ПриЗагрузкеДанныхИзНастроекНаСервере" формы.
//
&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	НастройкаКассаККМ = Настройки.Получить("ОтборКассаККМ");
	Если ОтборКассаККМ <> НастройкаКассаККМ Тогда
		ОтборКассаККМ = НастройкаКассаККМ;
		КассаФискальныйРегистратор = Справочники.КассыККМ.ПолучитьРеквизитыКассыККМ(ОтборКассаККМ).ТипКассы = Перечисления.ТипыКассККМ.ФискальныйРегистратор;
		УстановитьОтборДинамическихСписков();
	КонецЕсли;

КонецПроцедуры // ПриЗагрузкеДанныхИзНастроекНаСервере()

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если НЕ ЗавершениеРаботы Тогда
		//УНФ.ОтборыСписка
		СохранитьНастройкиОтборов();
		//Конец УНФ.ОтборыСписка
	КонецЕсли; 

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура УстановитьДоступностьКнопокСозданияНовыхДокументов()
	
	КассаККМЗаполнена = ЗначениеЗаполнено(ОтборКассаККМ);
	
	Элементы.ОтчетыОРозничныхПродажахСоздать.Доступность                    = НЕ КассаФискальныйРегистратор И КассаККМЗаполнена;
	Элементы.ОтчетыОРозничныхПродажахСкопировать.Доступность                = НЕ КассаФискальныйРегистратор И КассаККМЗаполнена;
	Элементы.КонтекстноеМенюОтчетыОРозничныхПродажахСоздать.Доступность     = НЕ КассаФискальныйРегистратор И КассаККМЗаполнена;
	Элементы.КонтекстноеМенюОтчетыОРозничныхПродажахСкопировать.Доступность = НЕ КассаФискальныйРегистратор И КассаККМЗаполнена;
	
КонецПроцедуры // УстановитьДоступностьКнопокСозданияНовыхДокументов()

// Процедура устанавливает отбор динамических списков формы.
//
&НаСервере
Процедура УстановитьОтборДинамическихСписков()
	
	УправлениеНебольшойФирмойКлиентСервер.УстановитьЭлементОтбораСписка(ОтчетыОРозничныхПродажах, "КассаККМ", ОтборКассаККМ, ЗначениеЗаполнено(ОтборКассаККМ), ВидСравненияКомпоновкиДанных.Равно);
	УправлениеНебольшойФирмойКлиентСервер.УстановитьЭлементОтбораСписка(ОтчетыОРозничныхПродажах, "СтатусКассовойСмены", ОтборСтатусКассовойСмены, ЗначениеЗаполнено(ОтборСтатусКассовойСмены), ВидСравненияКомпоновкиДанных.Равно);
	
КонецПроцедуры // УстановитьОтборДинамическихСписков()

// Процедура - обработчик события "ПриИзменении" поля "КассаККМ".
//
&НаСервере
Процедура КассаОтборПриИзмененииНаСервере()
	
	УстановитьОтборДинамическихСписков();
	КассаФискальныйРегистратор = Справочники.КассыККМ.ПолучитьРеквизитыКассыККМ(ОтборКассаККМ).ТипКассы = Перечисления.ТипыКассККМ.ФискальныйРегистратор;
	
КонецПроцедуры // КассаОтборПриИзмененииНаСервере()

// Процедура - обработчик события "ПриИзменении" поля "КассаККМ" на сервере.
//
&НаКлиенте
Процедура КассаОтборПриИзменении(Элемент)
	
	КассаОтборПриИзмененииНаСервере();
	УстановитьДоступностьКнопокСозданияНовыхДокументов();
	
КонецПроцедуры // КассаОтборПриИзменении()

// Процедура - обработчик события "ПриИзменении" поля "КассаККМ" на сервере.
//
&НаКлиенте
Процедура СтатусКассовойСменыОтборПриИзменении(Элемент)
	
	УстановитьОтборДинамическихСписков();
	
КонецПроцедуры // СтатусКассовойСменыОтборПриИзменении()

&НаКлиенте
// Процедура - обработчик события "ОбработкаОповещения" формы.
//
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	Если ИмяСобытия  = "ОбновитьФормыПослеСнятияZОтчета" Тогда
		Элементы.ОтчетыОРозничныхПродажах.Обновить();
	ИначеЕсли ИмяСобытия = "ОбновитьФормыПослеЗакрытияКассовойСмены" Тогда
		Элементы.ОтчетыОРозничныхПродажах.Обновить();
	КонецЕсли;

КонецПроцедуры // ОбработкаОповещения()

// Процедура - обработчик события "ПриОткрытии" формы.
//
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	УстановитьДоступностьКнопокСозданияНовыхДокументов();

КонецПроцедуры // ПриОткрытии()

// Выбор значения отбора в поле отбора
&НаКлиенте
Процедура ОтборСкладОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("СтруктурнаяЕдиница", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборОтветственныйОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("Ответственный", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборОрганизацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьМеткуИОтборСписка("Организация", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение = Неопределено;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// Процедура - обработчик команды "ОткрытьУправлениеФискальнымРегистратором".
//
&НаКлиенте
Процедура ОткрытьУправлениеФискальнымРегистратором(Команда)
	
	ОткрытьФорму("Справочник.ПодключаемоеОборудование.Форма.УправлениеФискальнымУстройством");

КонецПроцедуры // ОткрытьУправлениеФискальнымРегистратором)(

// Процедура - обработчик команды "ОткрытьУправлениеЭквайринговымТерминалом".
//
&НаКлиенте
Процедура ОткрытьУправлениеЭквайринговымТерминалом(Команда)
	
	ОткрытьФорму("Справочник.ПодключаемоеОборудование.Форма.УправлениеЭквайринговымТерминалом");

КонецПроцедуры // ОткрытьУправлениеЭквайринговымТерминалом()

#КонецОбласти

#Область МеткиОтборов

&НаСервере
Процедура УстановитьМеткуИОтборСписка(ИмяПоляОтбораСписка, ГруппаРодительМетки, ВыбранноеЗначение, ПредставлениеЗначения="")
	
	Если ПредставлениеЗначения="" Тогда
		ПредставлениеЗначения=Строка(ВыбранноеЗначение);
	КонецЕсли; 
	
	РаботаСОтборами.ПрикрепитьМеткуОтбора(ЭтотОбъект, ИмяПоляОтбораСписка, ГруппаРодительМетки, ВыбранноеЗначение, ПредставлениеЗначения);
	РаботаСОтборами.УстановитьОтборСписка(ЭтотОбъект, ОтчетыОРозничныхПродажах, ИмяПоляОтбораСписка);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_МеткаОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	МеткаИД = Сред(Элемент.Имя, СтрДлина("Метка_")+1);
	УдалитьМеткуОтбора(МеткаИД);
	
КонецПроцедуры

&НаСервере
Процедура УдалитьМеткуОтбора(МеткаИД)
	
	РаботаСОтборами.УдалитьМеткуОтбораСервер(ЭтотОбъект, ОтчетыОРозничныхПродажах, МеткаИД);

КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеПериодаНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	РаботаСОтборамиКлиент.ПредставлениеПериодаВыбратьПериод(ЭтотОбъект, "ОтчетыОРозничныхПродажах", "Дата");
	
КонецПроцедуры

&НаСервере
Процедура СохранитьНастройкиОтборов()
	
	РаботаСОтборами.СохранитьНастройкиОтборов(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура СвернутьРазвернутьПанельОтборов(Элемент)
	
	НовоеЗначениеВидимость = НЕ Элементы.ФильтрыНастройкиИДопИнфо.Видимость;
	РаботаСОтборамиКлиент.СвернутьРазвернутьПанельОтборов(ЭтотОбъект, НовоеЗначениеВидимость);
		
КонецПроцедуры

#КонецОбласти

#Область ЗамерыПроизводительности

&НаКлиенте
Процедура ОтчетыОРозничныхПродажахПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	ОценкаПроизводительностиКлиент.НачатьЗамерВремени(Истина, "СозданиеФормы" + РаботаСФормойДокументаКлиентСервер.ПолучитьИмяФормыСтрокой(ЭтотОбъект.ИмяФормы));
	
КонецПроцедуры

&НаКлиенте
Процедура ОтчетыОРозничныхПродажахПередНачаломИзменения(Элемент, Отказ)
	
	ОценкаПроизводительностиКлиент.НачатьЗамерВремени(Истина, "ОткрытиеФормы" + РаботаСФормойДокументаКлиентСервер.ПолучитьИмяФормыСтрокой(ЭтотОбъект.ИмяФормы));
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиБиблиотек

// СтандартныеПодсистемы.Печать
&НаКлиенте
Процедура Подключаемый_ВыполнитьКомандуПечати(Команда)
	УправлениеПечатьюКлиент.ВыполнитьПодключаемуюКомандуПечати(Команда, ЭтотОбъект, Элементы.ОтчетыОРозничныхПродажах);
КонецПроцедуры
// Конец СтандартныеПодсистемы.Печать

#КонецОбласти
