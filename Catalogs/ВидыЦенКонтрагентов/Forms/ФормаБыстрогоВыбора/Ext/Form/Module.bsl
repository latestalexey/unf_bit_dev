﻿
&НаКлиенте
//Процедура - обработчик события ПриИзменении поля Контрагент
//
Процедура КонтрагентПриИзменении(Элемент)
	
	УправлениеНебольшойФирмойКлиентСервер.УстановитьЭлементОтбораСписка(Список, "Владелец", Контрагент, ЗначениеЗаполнено(Контрагент));
	
КонецПроцедуры // КонтрагентПриИзменении()
