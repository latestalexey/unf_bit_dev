﻿////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура();

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

//Процедура заполняет ТЧ "Подписка" дейсвующими подписками
Процедура ЗаполнитьПоПодпискам() Экспорт
	//#Если Клиент Тогда
	Эл = Справочники.бизПериодыПодписокИТС.НайтиПоРеквизиту("Период", НачалоМесяца(Дата));
	Если Эл = Справочники.бизПериодыПодписокИТС.ПустаяСсылка() Тогда
		Эл = Справочники.бизПериодыПодписокИТС.СоздатьЭлемент();
		Эл.Период = НачалоМесяца(Дата);
		Эл.Наименование = Формат(Эл.Период,"ДФ='ММММ гггг'");
		Эл.Записать();
		
		Эл = Эл.Ссылка;
	КонецЕсли; 
	
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("парамНачалоПериода", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("парамОрганизация", Организация);
	Запрос.УстановитьПараметр("парамПериодПодписки",Эл);
	Запрос.УстановитьПараметр("парамРегистратор",ссылка);
   	Запрос.УстановитьПараметр("парамВидДвижения",ВидДвиженияНакопления.Приход);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	ПодпискиИТС.Контрагент,
	               |	ПодпискиИТС.ВидПодписки,
	               |	ПодпискиИТС.СрокПодписки
	               |ИЗ
	               |	(ВЫБРАТЬ
	               |		АО_ПодпискиИТССрезПоследних.Контрагент КАК Контрагент,
	               |		АО_ПодпискиИТССрезПоследних.ВидПодписки КАК ВидПодписки,
	               |		АО_ПодпискиИТССрезПоследних.СрокПодписки КАК СрокПодписки
	               |	ИЗ
	               |		РегистрСведений.бизПодписки.СрезПоследних(
	               |				&парамНачалоПериода,
	               |				Организация = &парамОрганизация
	               |					И ДатаОкончанияПодписки >= &парамНачалоПериода) КАК АО_ПодпискиИТССрезПоследних) КАК ПодпискиИТС
	               |		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	               |			бизДискиИТС.Контрагент КАК Контрагент,
	               |			бизДискиИТС.ВидПодписки КАК ВидПодписки
	               |		ИЗ
	               |			РегистрНакопления.бизДискиИТС КАК бизДискиИТС
	               |		ГДЕ
	               |			бизДискиИТС.Регистратор <> &парамРегистратор
	               |			И бизДискиИТС.ВидДвижения = &парамВидДвижения
	               |			И бизДискиИТС.ПериодПодписки = &парамПериодПодписки) КАК ПоступлениеДискиИТС
	               |		ПО ПодпискиИТС.Контрагент = ПоступлениеДискиИТС.Контрагент
	               |			И ПодпискиИТС.ВидПодписки = ПоступлениеДискиИТС.ВидПодписки
	               |ГДЕ
	               |	ПоступлениеДискиИТС.Контрагент ЕСТЬ NULL ";
	
	ТЗ = Запрос.Выполнить().Выгрузить();
	Подписка.Загрузить(ТЗ);
	
	Для каждого СтрокаПодписки Из Подписка Цикл
	
		СтрокаПодписки.ПериодИТС = Эл;
	
	КонецЦикла; 
	//#КонецЕсли
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

Процедура ПроверитьЗаполнениеШапки(Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	
	// Теперь вызовем общую процедуру проверки.
	бизЗаполнениеДокументов.ПроверитьПоля(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ);

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строк табличной части "Подписка".
//
// Параметры:
// Параметры: 
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиПодписка(Отказ, Заголовок)

	ИмяТабличнойЧасти = "Подписка";

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Контрагент, ВидПодписки, ПериодИТС");
	
КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиПодписка()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаПроведения"
//
Процедура ОбработкаПроведения(Отказ, Режим)
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = "Проведение документа """ + СокрЛП(Ссылка) + """: ";
	
	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(Отказ, Заголовок);
	
	// Проверим правильность заполнения табличной части документа
	ПроверитьЗаполнениеТабличнойЧастиПодписка(Отказ, Заголовок);
	
	// Движения по документу
	Если Не Отказ Тогда
		
		Для Каждого ТекСтрокаПодписка Из Подписка Цикл
			Движение = Движения.бизДискиИТС.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.Организация = Организация;
			Движение.Контрагент = ТекСтрокаПодписка.Контрагент;
			Движение.ВидПодписки = ТекСтрокаПодписка.ВидПодписки;
			Движение.ПериодПодписки = ТекСтрокаПодписка.ПериодИТС;
			Движение.СрокПодписки = ТекСтрокаПодписка.СрокПодписки;
			Движение.Количество = 1;
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры
