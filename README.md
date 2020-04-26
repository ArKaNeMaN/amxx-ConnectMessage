# Connect Message

## Описание
Плагин выводит в чат случайные приветственные сообщения при заходе игрока.

## Требования
AmxModX 1.9.0 или выше

## Настройка
### Текст сообщений
`amxmodx/configs/plugins/ConnectMessage/Messages.json`:
```json
[
    "%%Name%% зашёл на севрер",
    "..."
]
```

`%%Name%%` - Заменяется на ник игрока, зашедшего на сервер.

### КВары

**ConnectMessages_ShowMsgDelay** "1.0"
- Задержка перед показом сообщения


**ConnectMessages_MsgsForBots** "1"
- Приветствовать ли ботов
    - 1 - Да
    - 0 - Нет


**ConnectMessages_MsgMode** "0"
- Способ показа сообщений
    - 0 - Чат
    - 1 - HUD
    - 2 - DHUD


**ConnectMessages_HudColor** "0 255 0"
- Цвет HUD/DHUD сообщения в формате RGB


**ConnectMessages_HudCoords** "-1.0 0.2"
- Координаты HUD/DHUD сообщения


**ConnectMessages_HudHoldTime** "2.0"
- Через сколько пропадёт HUD/DHUD сообщение


**ConnectMessages_HudFadeTime** "0.2"
- Время затухания HUD/DHUD сообщения