﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ВидОперацииЗаказНаряд", Истина);
	
	ОткрытьФорму("Документ.ЗаказПокупателя.Форма.ФормаСпискаДокументовКОплате",
		ПараметрыОткрытия,
		ПараметрыВыполненияКоманды.Источник,
		"ЗаказНарядФормаСпискаДокументовКОплате",
		ПараметрыВыполненияКоманды.Окно,
		ПараметрыВыполненияКоманды.НавигационнаяСсылка
	);
	
КонецПроцедуры
