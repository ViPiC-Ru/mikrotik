# Описание
Здесь находятся **скрипты** для автоматизации различных задач в [RouterOS](https://mikrotik.com/software) на оборудовании [MikroTik](https://mikrotik.com/aboutus). Как правило они запускаются через встроенный планировщик задач или по событию.

### Настройки
- `init-global-values` - Глобальные переменные для всех скриптов.

### Скрипты
- `backup-system-config.rsc` - Резервное копирование конфигурации и прошивки в папку.
- `detect-and-send-wol.rsc` - Обнаружение и отправка WOL пакета для IPv4 и IPv6.
- `detect-fail2ban-action.rsc` - Обнаружение запрещённых действий и блокировка их.
- `torgle-wifi-interfaces` - Отключение или включение Wi-Fi интерфейсов.
- `reconnect-internet-interfaces.rsc` - Переподключение всех Интернет интерфейсов.
- `restart-container.rsc` - Перезапуск контейнера через NetWatch.
- `rotate-ipsec-peer.rsc` - Ротация адреса IPsec пира через NetWatch.
- `sync-user-account.rsc` - Cинхронизация аккаунтов пользователей в разные модули.
- `update-internet-info.rsc` - Обновление информации об выходе в интернет.
- `update-dns-record.rsc` - Синхронизация DNS с DHCP, IPsec, WireGuard и т.д.
- `update-or-reboot-system.rsc` - Обновление или перезагрузка устройства.